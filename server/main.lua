AddEventHandler('prp-core:LoadPlayer', function(Source, Account, ID, NewCharacter)
	local UserData = {
		inventory    = {},
		job          = {},
		playerName   = Account.getName(),
		completename = nil,
		firstname = nil,
		lastname = nil,
		lastPosition = nil,
		dob = nil
	}

	MySQL.Async.fetchSingle('SELECT * FROM `users` WHERE `id` = @id', {
		['@id'] = ID
	}, function(result)
		local Job, Grade = result.job, tostring(result.job_grade)

		if not Cake.DoesJobExist(Job, Grade) then
			Job, Grade = 'unemployed', '0'
			print(('prp-core: %s had an unknown job [job: %s, grade: %s], setting as unemployed!'):format(Account.getIdentifier(), Job, Grade))
		end
				
		local JobObject, GradeObject = Cake.Jobs[Job], Cake.Jobs[Job].grades[Grade]

		UserData.job = {}

		UserData.job.id    = JobObject.id
		UserData.job.name  = JobObject.name
		UserData.job.label = JobObject.label

		UserData.job.grade        = tonumber(Grade)
		UserData.job.grade_name   = GradeObject.name
		UserData.job.grade_label  = GradeObject.label
		UserData.job.grade_salary = GradeObject.salary

		if result.firstname ~= nil and result.firstname ~= "" and result.lastname ~= nil and result.lastname ~= ""  then
			UserData.completename = result.firstname:trim().." "..result.lastname:trim()
			UserData.firstname = result.firstname
			UserData.lastname = result.lastname
		end

		if result.bank ~= nil then
			UserData.bank = tonumber(result.bank)
		end

		if result.position ~= nil then
			UserData.lastPosition = json.decode(result.position)
		end

		if result.phone_number ~= nil then
			UserData.phoneNumber = result.phone_number
		end

		if result.dateofbirth ~= nil then
			UserData.dob = result.dateofbirth
		end

		if result.height ~= nil then
			UserData.height = result.height
		end

		if result.sex ~= nil then
			UserData.sex = result.sex
		end

		if result.is_dead ~= nil then
			UserData.dead = result.is_dead
		else
			UserData.dead = 0
		end

		-- We need to stop using this, asap!
		if result.character ~= nil and result.character ~= "" then
			UserData.character = result.character
		else
			UserData.character = UserData.ID
		end

		if result.uuid ~= nil then
			UserData.uuid = result.uuid
			UserData.token  = result.uuid
		else
			-- We don't have a UUID? Generate one
			UserData.uuid = Cake.Math.GetUUID()
			UserData.token = UserData.uuid

			MySQL.Async.execute('UPDATE `users` SET `token` = @token WHERE `id` = @id', {
				['@id']    = ID,
				['@token'] = UserData.uuid
			})
		end

		local xPlayer = Cake.Player.Create(ID, Source, Account, UserData)

		Cake.Players[Source] = xPlayer

		TriggerEvent('prp-core:Session:PlayerLoaded', Source, xPlayer)

		TriggerClientEvent('prp-core:Session:PlayerLoaded', Source, {
			source       = Source,
			identifier   = xPlayer.identifier,
			job          = xPlayer.getJob(),
			lastPosition = xPlayer.getLastPosition(),
			money        = xPlayer.getMoney(),
			completename = xPlayer.completename,
			phone        = xPlayer.phone,
			character    = xPlayer.character,
			dna			 = xPlayer.getDnaSequence(),
			firstname    = xPlayer.firstname,
			lastname     = xPlayer.lastname,
			token 		 = xPlayer.token,
			uuid 		 = xPlayer.token,
			creation     = NewCharacter,
		})
	end)
end)

AddEventHandler('playerDropped', function(reason)
	local Source = source
	local xPlayer = Cake.Characters.GetByPlayerId(Source)
	
	if xPlayer ~= nil then
		TriggerEvent('prp-core:Session:PlayerDropped', Source, reason, xPlayer)

		Citizen.Wait(2000)

		Cake.SavePlayer(xPlayer, function()
			Cake.UUIDToSrcMap[xPlayer.uuid] = nil
			Cake.Players[Source]        = nil
			Cake.LastPlayerData[Source] = nil
		end)
	end	
end)

RegisterServerEvent('prp-core:UpdateLastPosition', function(position)
	local _source = source

	if Cake.Players[_source] ~= nil then
		Cake.Players[_source].setLastPosition(position)
	end
end)

RegisterServerEvent('prp-core:UseItem', function(itemName)
	local xPlayer = Cake.Characters.GetByPlayerId(source)
	local count   = xPlayer.getInventoryItem(itemName).count

	if count > 0 then
		Cake.UseItem(xPlayer.source, itemName)
	else
		TriggerClientEvent('prp-notify:client:SendAlert:long', xPlayer.source, { type = 'error', text = 'Action impossible.'})
	end
end)

Cake.RegisterServerCallback('prp-core:GetPlayerData', function(source, cb)
	local xPlayer = Cake.Characters.GetByPlayerId(source)

	cb({
		identifier   = xPlayer.identifier,
		inventory    = xPlayer.getInventory(),
		job          = xPlayer.getJob(),
		lastPosition = xPlayer.getLastPosition(),
		money        = xPlayer.getMoney(),
		bank         = xPlayer.getBank(),
		dead         = xPlayer.isDead(),
		completeName = xPlayer.getCompleteName(),
		dob          = xPlayer.getDob()
	})
end)

Cake.StartDBSync()
Cake.StartPayCheck()

