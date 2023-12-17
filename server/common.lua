Cake                      = {}
Cake.Players              = {}
Cake.Items                = {}
Cake.ServerCallbacks      = {}
Cake.ClientCallbacks      = {}
Cake.TimeoutCount         = -1
Cake.CancelledTimeouts    = {}
Cake.LastPlayerData       = {}
Cake.Pickups              = {}
Cake.PickupId             = 0
Cake.Jobs                 = {}
Cake.Accounts             = {}

AddEventHandler('prp:getSharedObject', function(cb)
	cb(Cake)
end)

function getSharedObject()
	return Cake
end

CreateThread(function()
	for k, v in pairs(Config.Jobs) do
		Cake.Jobs[k] = { 
			name = k,
			grades = {} ,
			label = v.Name,
		}

		for k2, v2 in pairs(v.Grades) do
			Cake.Jobs[k].grades[tostring(k2)] = {
				job_name = k,
				grade = k2, 
				label = v2.Title,
				name = k .. "-" .. tostring(k2),
				salary = v2.Pay,
			}
	end

		if v.Offduty then
			Cake.Jobs["off" .. k] = { 
				name = "off" .. k,
				grades = {},
				label = v.Name,
			}

			for k2, v2 in pairs(v.Grades) do
				Cake.Jobs["off" .. k].grades[tostring(k2)] = {
					job_name = "off" .. k,
					grade = k2, 
					label = "Off Duty",
					name = k .. "-" .. tostring(k2),
					salary = Config.UniversalIncome,
				}
		end
	end
	end
end)

AddEventHandler('prp-core:Session:PlayerLoaded', function(source)
	local xPlayer         = Cake.Characters.GetByPlayerId(source)
	local accounts        = {}
	local xPlayerAccounts = xPlayer.getAccounts()

	for i=1, #xPlayerAccounts, 1 do
		accounts[xPlayerAccounts[i].name] = xPlayerAccounts[i].money
	end

	Cake.LastPlayerData[source] = {accounts = accounts}
end)

local LastRequestId = {}

RegisterServerEvent('prp:triggerServerCallback', function(name, requestId, ...)
	local _source = source

	if LastRequestId[_source] ~= requestId then
		LastRequestId[_source] = requestId

		Cake.TriggerServerCallback(name, requestID, _source, function(...)
			TriggerClientEvent('prp:serverCallback', _source, name, requestId, ...)
		end, ...)
	else
		exports['prp-tab']:WebhookBasic("Exploit", "Framework", "@here [" .. name .. "] " .. GetPlayerName(_source) .. " attempted a replay attack")
		TriggerEvent('prp_admin:mtL3Ad9TOa8/IvSbRa5DUhugZcY+zaoRc46feBayzRo=', _source)
	end
end)

RegisterServerEvent('prp:triggerServerEvent', function(name, requestId, ...)
	local _source = source

	if LastRequestId[_source] ~= requestId then
		LastRequestId[_source] = requestId

		Cake.TriggerServerCallback(name, requestID, _source, nil, ...)
	else
		exports['prp-tab']:WebhookBasic("Exploit", "Framework", "@here [" .. name .. "] " .. GetPlayerName(_source) .. " attempted a replay attack")
		TriggerEvent('prp_admin:mtL3Ad9TOa8/IvSbRa5DUhugZcY+zaoRc46feBayzRo=', _source)
	end
end)

RegisterServerEvent('prp:clientCallback', function(requestId, ...)
	_source = source
	Cake.ClientCallbacks[requestId](_source, ...)
	Cake.ClientCallbacks[requestId] = nil
end)