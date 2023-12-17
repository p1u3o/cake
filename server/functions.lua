Cake.CurrentRequestId          = 0
Cake.UUIDToSrcMap = {}
Cake.ChidToSrcMap = {}
Cake.TimeoutCallbacks = {}
Cake.NamedTimeouts = {}

Cake.Trace = function(str)
	if Config.EnableDebug then
		print('Cake! ' .. str)
	end
end

Cake.SetTimeout = function(msec, cb, name)
	local id = Cake.TimeoutCount + 1

	Cake.TimeoutCallbacks[id] = cb

	SetTimeout(msec, function()
		if Cake.CancelledTimeouts[id] then
			Cake.CancelledTimeouts[id] = nil
		else
			Cake.TimeoutCallbacks[id](id)
		end

		Cake.TimeoutCallbacks[id] = nil
		Cake.NamedTimeouts[id] = nil
	end)

	Cake.TimeoutCount = id

	if name ~= nil then
		Cake.NamedTimeouts[id] = name
	end

	return id
end

Cake.RunTimeout = function(id)
	if Cake.TimeoutCallbacks[id] then
		Cake.CancelledTimeouts[id] = true
		Cake.TimeoutCallbacks[id](id)
	end
end

Cake.ClearTimeout = function(id)
	Cake.CancelledTimeouts[id] = true
	Cake.TimeoutCallbacks[id] = nil
end

Cake.DoesTimeoutExist = function(name)
	for k, v in pairs(Cake.NamedTimeouts) do
		if v == name then
			return k
		end
	end

	return nil
end

Cake.ClearTimeoutByName = function(name)
	local TimeoutCheck = Cake.DoesTimeoutExist(name)

	if TimeoutCheck ~= nil then
		Cake.ClearTimeout(TimeoutCheck)

		return true
	end

	return false
end

Cake.RunTimeoutByName = function(name)
	local TimeoutCheck = Cake.DoesTimeoutExist(name)

	if TimeoutCheck ~= nil then
		Cake.RunTimeout(TimeoutCheck)

		return true
	end

	return false
end

Cake.Timeout = {}
Cake.Timeout.Set = Cake.SetTimeout
Cake.Timeout.Run = Cake.RunTimeout
Cake.Timeout.Clear = Cake.ClearTimeout
Cake.Timeout.Exists = Cake.DoesTimeoutExist
Cake.Timeout.ClearByName = Cake.ClearTimeoutByName
Cake.Timeout.RunByName = Cake.RunTimeoutByName

Cake.RegisterServerCallback = function(name, cb)
	Cake.ServerCallbacks[name] = cb
end

Cake.TriggerServerCallback = function(name, requestId, source, cb, ...)
	if Cake.ServerCallbacks[name] ~= nil then
		if cb ~= nil then
			Cake.ServerCallbacks[name](source, cb, ...)
		else
			Cake.ServerCallbacks[name](source, ...)
		end
	else
		Cake.AntiCheat.Ban(source, "TriggerServerCallback", "attempted to trigger " .. name)
		
		print('[prp-core]: TriggerServerCallback => [' .. name .. '] does not exist')
	end
end

Cake.TriggerClientCallback = function(name, target, cb, ...)
	Cake.ClientCallbacks[Cake.CurrentRequestId] = cb

	TriggerClientEvent('esx:triggerClientCallback', target, name, Cake.CurrentRequestId, ...)

	if Cake.CurrentRequestId < 65535 then
		Cake.CurrentRequestId = Cake.CurrentRequestId + 1
	else
		Cake.CurrentRequestId = 0
	end
end

Cake.SavePlayer = function(xPlayer, cb)
	local asyncTasks     = {}

	xPlayer.setLastPosition(xPlayer.getCoords())

	-- Job, loadout and position
	table.insert(asyncTasks, function(cb)
		MySQL.Async.execute('UPDATE users SET `job` = @job, `job_grade` = @job_grade, `position` = @position, `bank` = @bank WHERE id = @id', {
			['@job']        = xPlayer.job.name,
			['@job_grade']  = xPlayer.job.grade,
			['@position']   = json.encode(xPlayer.getLastPosition()),
			['@bank']       = xPlayer.bank,
			['@id']      = xPlayer.id
		}, function(rowsChanged)
			cb()
		end)
	end)

	table.insert(asyncTasks, function(cb)
		xPlayer.account.save(true, function()
			cb()
		end)
	end)

	Async.parallel(asyncTasks, function(results)
		RconPrint('[SAVED] ' .. xPlayer.name .. "\n")

		if cb ~= nil then
			cb()
		end
	end)
end

Cake.SavePlayers = function(cb)
	local asyncTasks = {}
	local xPlayers   = Cake.GetPlayers()

	for i=1, #xPlayers, 1 do
		table.insert(asyncTasks, function(cb)
			local xPlayer = Cake.Characters.GetByPlayerId(xPlayers[i])
			Cake.SavePlayer(xPlayer, cb)
		end)
	end

	Async.parallelLimit(asyncTasks, 8, function(results)
		RconPrint('[SAVED] All players' .. "\n")

		if cb ~= nil then
			cb()
		end
	end)
end

Cake.StartDBSync = function()
	function saveData()
		Cake.SavePlayers()
		Cake.Society.Save()
		SetTimeout(10 * 60 * 1000, saveData)
	end

	SetTimeout(10 * 60 * 1000, saveData)
end

AddEventHandler("prp-core:SavePlayers", function()
	Cake.SavePlayers()
	Cake.Society.Save()
end)

Cake.GetPlayers = function()
	local sources = {}

	for k,v in pairs(Cake.Players) do
		table.insert(sources, k)
	end

	return sources
end

Cake.Characters.GetByPlayerIdentifier = function(identifier)
	for k,v in pairs(Cake.Players) do
		if v.identifier == identifier then
			return v
		end
	end
end

Cake.GetPlayerFromCharacter = function(identifier)
	if Cake.ChidToSrcMap[identifier] ~= nil and Cake.Players[Cake.ChidToSrcMap[identifier]] ~= nil then
		return Cake.Players[Cake.ChidToSrcMap[identifier]]
	end
	for k,v in pairs(Cake.Players) do
		if v.character == identifier then
			Cake.ChidToSrcMap[identifier] = tonumber(v.source)
			return v
		end
	end
end

Cake.GetOfflinePlayerFromUUID = function(identifier)
	-- Todo
end

Cake.DoesJobExist = function(job, grade)
	grade = tostring(grade)

	if job and grade then
		if Cake.Jobs[job] and Cake.Jobs[job].grades[grade] then
			return true
		end
	end

	return false
end

function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

function isWeapon(name)
	return string.find(name, 'WEAPON_') ~= nil
end

local Charset = {}
for i = 65,  90 do table.insert(Charset, string.char(i)) end

function GetRandomLetter(length)
	if length > 0 then
		return GetRandomLetter(length - 1) .. Charset[math.random(1, #Charset)]
	else
		return ''
	end
end