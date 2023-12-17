Cake                           = {}
Cake.PlayerData                = {}
Cake.PlayerLoaded              = false
Cake.CurrentRequestId          = 0
Cake.ServerCallbacks           = {}
Cake.ClientCallbacks           = {}
Cake.TimeoutCallbacks          = {}
Cake.TimeoutCount              = 0
Cake.LockedCallbacks           = {}

Cake.Game                      = {}
Cake.Game.Utils                = {}

Cake.Scaleform                 = {}
Cake.Scaleform.Utils           = {}

Cake.Streaming                 = {}
Cake.CancelledTimeouts         = {}
Cake.TimeoutCallbacks = {}
Cake.NamedTimeouts = {}

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
		Cake.NamedTimeouts[id] = true
	end
end

Cake.ClearTimeout = function(id)
	Cake.CancelledTimeouts[id] = true
	Cake.TimeoutCallbacks[id] = nil
	Cake.NamedTimeouts[id] = true
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

Cake.IsPlayerLoaded = function()
	return Cake.PlayerLoaded
end

Cake.GetPlayerData = function()
	return Cake.PlayerData
end

Cake.SetPlayerData = function(key, val)
	Cake.PlayerData[key] = val
end

Cake.ShowNotification = function(msg)
	SetNotificationTextEntry('STRING')
	AddTextComponentSubstringWebsite(msg)
	DrawNotification(false, true)
end

Cake.ShowAdvancedNotification = function(title, subject, msg, icon, iconType)
	SetNotificationTextEntry('STRING')
	AddTextComponentSubstringWebsite(msg)
	SetNotificationMessage(icon, icon, false, iconType, title, subject)
	DrawNotification(false, false)
end

Cake.ShowHelpNotification = function(msg)
	if not IsHelpMessageOnScreen() then
		BeginTextCommandDisplayHelp('STRING')
		AddTextComponentSubstringWebsite(msg)
		EndTextCommandDisplayHelp(0, false, true, -1)
	end
end

Cake.TriggerServerCallback = function(name, cb, ...)
	local CurrentTime = GetGameTimer()

	if Cake.LockedCallbacks[name] ~= nil then
		if CurrentTime - Cake.LockedCallbacks[name] < 10000 then
			print(name .. " is currently locked, callback rejected!")
			return
		end
	end

	if cb ~= nil then
		Cake.LockedCallbacks[name] = CurrentTime
		Cake.ServerCallbacks[Cake.CurrentRequestId] = cb
		TriggerServerEvent('prp:triggerServerCallback', name, Cake.CurrentRequestId, ...)
	else
		TriggerServerEvent('prp:triggerServerEvent', name, Cake.CurrentRequestId, ...)
	end
	
	if Cake.CurrentRequestId < 65535 then
		Cake.CurrentRequestId = Cake.CurrentRequestId + 1
	else
		Cake.CurrentRequestId = 0
	end
end

Cake.Game.GetPedMugshot = function(ped, transparent)
	if DoesEntityExist(ped) then
		local mugshot

		if transparent then
			mugshot = RegisterPedheadshotTransparent(ped)
		else
			mugshot = RegisterPedheadshot(ped)
		end

		while not IsPedheadshotReady(mugshot) do
			Citizen.Wait(0)
		end

		return mugshot, GetPedheadshotTxdString(mugshot)
	else
		return
	end
end

Cake.Game.Teleport = function(entity, coords, cb)
	RequestCollisionAtCoord(coords.x, coords.y, coords.z)

	while not HasCollisionLoadedAroundEntity(entity) do
		RequestCollisionAtCoord(coords.x, coords.y, coords.z)
		Citizen.Wait(0)
	end

	SetEntityCoords(entity, coords.x, coords.y, coords.z)

	if cb ~= nil then
		cb()
	end
end

Cake.Game.SpawnObject = function(model, coords, cb)
	local model = (type(model) == 'number' and model or GetHashKey(model))

	Citizen.CreateThread(function()
		Cake.Streaming.RequestModel(model)

		local obj = CreateObject(model, coords.x, coords.y, coords.z, true, false, true)

		if cb then
			cb(obj)
		end
	end)
end

Cake.Game.SpawnLocalObject = function(model, coords, cb)
	local model = (type(model) == 'number' and model or GetHashKey(model))

	Citizen.CreateThread(function()
		Cake.Streaming.RequestModel(model)

		local obj = CreateObject(model, coords.x, coords.y, coords.z, false, false, true)

		if type(coords) == "vector4" then
			if coords.w ~= nil then
				SetEntityHeading(obj, coords.w)
			end
		end
		
		if cb then
			cb(obj)
		end
	end)
end

--[[Cake.Game.DeleteVehicle = function(vehicle)
	NetworkRequestControlOfEntity(vehicle)
	SetEntityAsMissionEntity(vehicle, false, true)
	DeleteVehicle(vehicle)
end]]

Cake.Game.DeleteObject = function(object)
	NetworkRequestControlOfEntity(object)
	SetEntityAsMissionEntity(object, false, true)
	DeleteObject(object)
end

Cake.Game.SpawnVehicle = function(modelName, coords, heading, cb, networked)
	local model = (type(modelName) == 'number' and modelName or GetHashKey(modelName))
	local vector = type(coords) == "vector3" and coords or vec(coords.x, coords.y, coords.z)

	Citizen.CreateThread(function()
		if not HasModelLoaded(model) then
            Cake.Streaming.RequestModel(model)
        end

		local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, false)

		if networked then
			local id = NetworkGetNetworkIdFromEntity(vehicle)
			SetNetworkIdCanMigrate(id, true)
			SetEntityAsMissionEntity(vehicle, true, false)
		end

		SetVehicleHasBeenOwnedByPlayer(vehicle, true)
		SetVehicleNeedsToBeHotwired(vehicle, false)
		SetModelAsNoLongerNeeded(model)

		local playerPed = GetPlayerPed(-1)
        SetPedIntoVehicle(playerPed, vehicle, -1)
		SetVehicleDirtLevel(GetVehiclePedIsUsing(playerPed))
		WashDecalsFromVehicle(GetVehiclePedIsUsing(playerPed), 1.0)

		local plate = GetVehicleNumberPlateText(vehicle)
    	TriggerEvent("ARPF:spawn:recivekeys", vehicle,plate)

		RequestCollisionAtCoord(coords.x, coords.y, coords.z)

		while not HasCollisionLoadedAroundEntity(vehicle) do
			Citizen.Wait(0)
		end

		SetVehRadioStation(vehicle, 'OFF')
		SetModelAsNoLongerNeeded(model)

		if cb ~= nil then
			cb(vehicle)
		end
	end)
end

Cake.Game.SpawnVehicleInPlace = function(modelName, coords, heading, cb)
	local model = (type(modelName) == 'number' and modelName or GetHashKey(modelName))

	Citizen.CreateThread(function()
		if not HasModelLoaded(model) then
            Cake.Streaming.RequestModel(model)
        end

		local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, false)
		SetVehicleOnGroundProperly(vehicle)
		SetVehicleHasBeenOwnedByPlayer(vehicle, true)
		SetEntityAsMissionEntity(vehicle, true, false)
		local id = NetworkGetNetworkIdFromEntity(vehicle)
		SetNetworkIdCanMigrate(id, true)
		--local playerPed = GetPlayerPed(-1)
        --SetPedIntoVehicle(playerPed, vehicle, -1)
		SetVehicleDirtLevel(vehicle)
		WashDecalsFromVehicle(vehicle, 1.0)
		NetworkRequestControlOfEntity(vehicle)

		RequestCollisionAtCoord(coords.x, coords.y, coords.z)

		while not HasCollisionLoadedAroundEntity(vehicle) do
			RequestCollisionAtCoord(coords.x, coords.y, coords.z)
			Citizen.Wait(0)
		end

		SetVehRadioStation(vehicle, 'OFF')
		SetModelAsNoLongerNeeded(model)

		if cb ~= nil then
			cb(vehicle)
		end
	end)
end

function Cake.Game.IsVehicleEmpty(vehicle)
	local passengers = GetVehicleNumberOfPassengers(vehicle)
	local driverSeatFree = IsVehicleSeatFree(vehicle, -1)

	return passengers == 0 and driverSeatFree
end

function DrawScreenText(text)
    DrawNetText = 0
    while DrawNetText < 100 do
        if DrawNetText < 100 then
            Citizen.Wait(5)
            DrawNetText = DrawNetText + 5
            SetTextFont(4)
            SetTextScale(0.0, 0.5)
            SetTextColour(255, 255, 255, 150)
            SetTextDropshadow(0, 0, 0, 0, 255)
            SetTextEdge(1, 0, 0, 0, 255)
            SetTextDropShadow()
            SetTextOutline()
            SetTextCentre(true)

            BeginTextCommandDisplayText("STRING")
            AddTextComponentSubstringPlayerName(text)
            EndTextCommandDisplayText(0.5, 0.5)
        else
            break
        end
    end
end

Cake.Game.SpawnLocalVehicle = function(modelName, coords, heading, cb)
	local model = (type(modelName) == 'number' and modelName or GetHashKey(modelName))

	Citizen.CreateThread(function()
		Cake.Streaming.RequestModel(model)

		local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, false, false)

		SetEntityAsMissionEntity(vehicle, true, false)
		SetVehicleHasBeenOwnedByPlayer(vehicle, true)
		SetVehicleNeedsToBeHotwired(vehicle, false)
		SetModelAsNoLongerNeeded(model)
		RequestCollisionAtCoord(coords.x, coords.y, coords.z)

		while not HasCollisionLoadedAroundEntity(vehicle) do
			RequestCollisionAtCoord(coords.x, coords.y, coords.z)
			Citizen.Wait(0)
		end

		SetVehRadioStation(vehicle, 'OFF')

		if cb then
			cb(vehicle)
		end
	end)
end

Cake.Game.IsVehicleEmpty = function(vehicle)
	local passengers = GetVehicleNumberOfPassengers(vehicle)
	local driverSeatFree = IsVehicleSeatFree(vehicle, -1)

	return passengers == 0 and driverSeatFree
end

Cake.Game.GetObjects = function()
	local objects = {}

	for object in EnumerateObjects() do
		table.insert(objects, object)
	end

	return objects
end

Cake.Game.GetClosestObject = function(filter, coords)
	local objects = Cake.Game.GetObjects()
	local closestDistance, closestObject = -1, -1
	local filter, coords = filter, coords

	if type(filter) == 'string' then
		if filter ~= '' then
			filter = {filter}
		end
	end

	if coords then
		coords = vector3(coords.x, coords.y, coords.z)
	else
		local playerPed = PlayerPedId()
		coords = GetEntityCoords(playerPed)
	end

	for i=1, #objects, 1 do
		local foundObject = false

		if filter == nil or (type(filter) == 'table' and #filter == 0) then
			foundObject = true
		else
			local objectModel = GetEntityModel(objects[i])

			for j=1, #filter, 1 do
				if objectModel == GetHashKey(filter[j]) then
					foundObject = true
					break
				end
			end
		end

		if foundObject then
			local objectCoords = GetEntityCoords(objects[i])
			local distance = #(objectCoords - coords)

			if closestDistance == -1 or closestDistance > distance then
				closestObject = objects[i]
				closestDistance = distance
			end
		end
	end

	return closestObject, closestDistance
end

Cake.Game.GetPlayers = function()
	local players = {}

	for _,player in ipairs(GetActivePlayers()) do
		local ped = GetPlayerPed(player)

		if DoesEntityExist(ped) then
			table.insert(players, player)
		end
	end

	return players
end

Cake.Game.GetClosestPlayer = function(coords, ignorePlayer)
	local players, closestDistance, closestPlayer = Cake.Game.GetPlayers(), -1, -1
	local coords, usePlayerPed = coords, false
	local playerPed, playerId = PlayerPedId(), PlayerId()

	if coords then
		coords = vector3(coords.x, coords.y, coords.z)
	else
		usePlayerPed = true
		coords = GetEntityCoords(playerPed)
	end

	if ignorePlayer ~= nil and ignorePlayer == true then
		usePlayerPed = true
	end

	for i=1, #players, 1 do
		local target = GetPlayerPed(players[i])

		if not usePlayerPed or (usePlayerPed and players[i] ~= playerId) then
			local targetCoords = GetEntityCoords(target)
			local distance = #(coords - targetCoords)

			if closestDistance == -1 or closestDistance > distance then
				closestPlayer = players[i]
				closestDistance = distance
			end
		end
	end

	return closestPlayer, closestDistance
end

Cake.Game.GetPlayersInArea = function(coords, area)
	local players, playersInArea = Cake.Game.GetPlayers(), {}
	coords = vector3(coords.x, coords.y, coords.z)

	for i=1, #players, 1 do
		local target = GetPlayerPed(players[i])
		local targetCoords = GetEntityCoords(target)

		if #(coords - targetCoords) <= area then
			table.insert(playersInArea, players[i])
		end
	end

	return playersInArea
end

Cake.Game.GetVehicles = function()
	local vehicles = {}

	for vehicle in EnumerateVehicles() do
		table.insert(vehicles, vehicle)
	end

	return vehicles
end

Cake.Game.GetClosestVehicle = function(coords)
	local vehicles = Cake.Game.GetVehicles()
	local closestDistance, closestVehicle, coords = -1, -1, coords

	if coords then
		coords = vector3(coords.x, coords.y, coords.z)
	else
		local playerPed = PlayerPedId()
		coords = GetEntityCoords(playerPed)
	end

	for i=1, #vehicles, 1 do
		local vehicleCoords = GetEntityCoords(vehicles[i])
		local distance = #(coords - vehicleCoords)

		if closestDistance == -1 or closestDistance > distance then
			closestVehicle, closestDistance = vehicles[i], distance
		end
	end

	return closestVehicle, closestDistance
end

Cake.Game.GetVehiclesInArea = function(coords, area)
	local vehicles       = Cake.Game.GetVehicles()
	local vehiclesInArea = {}

	for i=1, #vehicles, 1 do
		local vehicleCoords = GetEntityCoords(vehicles[i])
		local distance      = #(vehicleCoords-vector3(coords.x, coords.y, coords.z))

		if distance <= area then
			table.insert(vehiclesInArea, vehicles[i])
		end
	end

	return vehiclesInArea
end

Cake.Game.GetVehicleInDirection = function(distance)
	if distance == nil then
		distance = 5.0
	end
	local playerPed    = PlayerPedId()
	local playerCoords = GetEntityCoords(playerPed)
	local inDirection  = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, distance, 0.0)
	local rayHandle    = StartShapeTestRay(playerCoords, inDirection, 10, playerPed, 0)
	local numRayHandle, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)

	if hit == 1 and GetEntityType(entityHit) == 2 then
		return entityHit
	end

	return nil
end

Cake.Game.IsSpawnPointClear = function(coords, radius)
	local vehicles = Cake.Game.GetVehiclesInArea(coords, radius)

	return #vehicles == 0
end

Cake.Game.GetPeds = function(ignoreList)
	local ignoreList = ignoreList or {}
	local peds       = {}

	for ped in EnumeratePeds() do
		local found = false

		for j=1, #ignoreList, 1 do
			if ignoreList[j] == ped then
				found = true
			end
		end

		if not found then
			table.insert(peds, ped)
		end
	end

	return peds
end

Cake.Game.GetClosestPed = function(coords, ignoreList)
	local ignoreList      = ignoreList or {}
	local peds            = Cake.Game.GetPeds(ignoreList)
	local closestDistance = -1
	local closestPed      = -1

	for i=1, #peds, 1 do
		local pedCoords = GetEntityCoords(peds[i])
		local distance  = #(pedCoords - vector3(coords.x, coords.y, coords.z))

		if closestDistance == -1 or closestDistance > distance then
			closestPed      = peds[i]
			closestDistance = distance
		end
	end

	return closestPed, closestDistance
end

Cake.Game.GetVehicleProperties = function(vehicle)
	if DoesEntityExist(vehicle) then
		local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
		local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
		local dashboardColor = GetVehicleDashboardColour(vehicle)
		local interiorColor = GetVehicleInteriorColour(vehicle)

		local hasCustomPrimaryColor = GetIsVehiclePrimaryColourCustom(vehicle)
		local customPrimaryColor = nil
		if hasCustomPrimaryColor then
			local r, g, b = GetVehicleCustomPrimaryColour(vehicle)
			customPrimaryColor = { r, g, b }
		end

		local hasCustomSecondaryColor = GetIsVehicleSecondaryColourCustom(vehicle)
		local customSecondaryColor = nil
		if hasCustomSecondaryColor then
			local r, g, b = GetVehicleCustomSecondaryColour(vehicle)
			customSecondaryColor = { r, g, b }
		end

		local extras = {}	    

		for id=0, 12 do
			if DoesExtraExist(vehicle, id) then
				local state = IsVehicleExtraTurnedOn(vehicle, id) == 1
				extras[tostring(id)] = state
			end
		end

		return {
			model             = GetEntityModel(vehicle),

			plate             = tostring(GetVehicleNumberPlateText(vehicle)),	
			plateIndex        = GetVehicleNumberPlateTextIndex(vehicle),

			bodyHealth        = Cake.Math.Round(GetVehicleBodyHealth(vehicle)),
			engineHealth      = Cake.Math.Round(GetVehicleEngineHealth(vehicle)),
			tankHealth        = Cake.Math.Round(GetVehiclePetrolTankHealth(vehicle)),

			fuelLevel		  = Cake.Math.Round(DecorGetInt(vehicle, "_FUEL_LEVEL")),
			dirtLevel         = Cake.Math.Round(GetVehicleDirtLevel(vehicle), 1),
			color1            = colorPrimary,
			color2            = colorSecondary,
			customPrimaryColor = customPrimaryColor,
			customSecondaryColor = customSecondaryColor,

			pearlescentColor  = pearlescentColor,
			wheelColor        = wheelColor,

			dashboardColor 	  = dashboardColor,
			interiorColor 	  = interiorColor,

			wheels            = GetVehicleWheelType(vehicle),
			windowTint        = GetVehicleWindowTint(vehicle),
			xenonColor        = GetVehicleXenonLightsColour(vehicle),

			neonEnabled       = {
				IsVehicleNeonLightEnabled(vehicle, 0),
				IsVehicleNeonLightEnabled(vehicle, 1),
				IsVehicleNeonLightEnabled(vehicle, 2),
				IsVehicleNeonLightEnabled(vehicle, 3)
			},

			neonColor         = table.pack(GetVehicleNeonLightsColour(vehicle)),
			extras            = extras,
			tyreSmokeColor    = table.pack(GetVehicleTyreSmokeColor(vehicle)),

			modSpoilers       = GetVehicleMod(vehicle, 0),
			modFrontBumper    = GetVehicleMod(vehicle, 1),
			modRearBumper     = GetVehicleMod(vehicle, 2),
			modSideSkirt      = GetVehicleMod(vehicle, 3),
			modExhaust        = GetVehicleMod(vehicle, 4),
			modFrame          = GetVehicleMod(vehicle, 5),
			modGrille         = GetVehicleMod(vehicle, 6),
			modHood           = GetVehicleMod(vehicle, 7),
			modFender         = GetVehicleMod(vehicle, 8),
			modRightFender    = GetVehicleMod(vehicle, 9),
			modRoof           = GetVehicleMod(vehicle, 10),

			modEngine         = GetVehicleMod(vehicle, 11),
			modBrakes         = GetVehicleMod(vehicle, 12),
			modTransmission   = GetVehicleMod(vehicle, 13),
			modHorns          = GetVehicleMod(vehicle, 14),
			modSuspension     = GetVehicleMod(vehicle, 15),
			--modArmor          = GetVehicleMod(vehicle, 16),

			modTurbo          = IsToggleModOn(vehicle, 18),

			modSmokeEnabled   = IsToggleModOn(vehicle, 20),
			modXenon          = IsToggleModOn(vehicle, 22),

			modFrontWheels    = GetVehicleMod(vehicle, 23),
			modBackWheels     = GetVehicleMod(vehicle, 24),

			modPlateHolder    = GetVehicleMod(vehicle, 25),
			modVanityPlate    = GetVehicleMod(vehicle, 26),
			modTrimA          = GetVehicleMod(vehicle, 27),
			modOrnaments      = GetVehicleMod(vehicle, 28),
			modDashboard      = GetVehicleMod(vehicle, 29),
			modDial           = GetVehicleMod(vehicle, 30),
			modDoorSpeaker    = GetVehicleMod(vehicle, 31),
			modSeats          = GetVehicleMod(vehicle, 32),
			modSteeringWheel  = GetVehicleMod(vehicle, 33),
			modShifterLeavers = GetVehicleMod(vehicle, 34),
			modAPlate         = GetVehicleMod(vehicle, 35),
			modSpeakers       = GetVehicleMod(vehicle, 36),
			modTrunk          = GetVehicleMod(vehicle, 37),
			modHydrolic       = GetVehicleMod(vehicle, 38),
			modEngineBlock    = GetVehicleMod(vehicle, 39),
			modAirFilter      = GetVehicleMod(vehicle, 40),
			modStruts         = GetVehicleMod(vehicle, 41),
			modArchCover      = GetVehicleMod(vehicle, 42),
			modAerials        = GetVehicleMod(vehicle, 43),
			modTrimB          = GetVehicleMod(vehicle, 44),
			modTank           = GetVehicleMod(vehicle, 45),
			modWindows        = GetVehicleMod(vehicle, 46),
			modLivery         = GetVehicleMod(vehicle, 48),
			modLivery2        = GetVehicleLivery(vehicle),

			modDoorR          = GetVehicleMod(vehicle, 47),
			modLivery         = GetVehicleMod(vehicle, 48),
			modLightbar       = GetVehicleMod(vehicle, 49),
		}
	else
		return
	end
end

Cake.Game.SetVehicleProperties = function(vehicle, props)
	if DoesEntityExist(vehicle) then
		SetVehicleModKit(vehicle, 0)
		local pearlescentColor = 0
		if props.plate then SetVehicleNumberPlateText(vehicle, props.plate) end
		if props.plateIndex then SetVehicleNumberPlateTextIndex(vehicle, props.plateIndex) end

		--if props.bodyHealth then SetVehicleBodyHealth(vehicle, props.bodyHealth + 0.0) end
		--if props.engineHealth then SetVehicleEngineHealth(vehicle, props.engineHealth + 0.0) end
		--if props.tankHealth then SetVehiclePetrolTankHealth(vehicle, props.tankHealth + 0.0) end

		--if props.fuelLevel then DecorSetInt(vehicle, "_FUEL_LEVEL", Cake.Math.Round(props.fuelLevel)) end
		if props.dirtLevel then SetVehicleDirtLevel(vehicle, props.dirtLevel + 0.0) end
		if props.customPrimaryColor then SetVehicleCustomPrimaryColour(vehicle, props.customPrimaryColor[1], props.customPrimaryColor[2], props.customPrimaryColor[3]) end 
		if props.customSecondaryColor then SetVehicleCustomSecondaryColour(vehicle, props.customSecondaryColor[1], props.customSecondaryColor[2], props.customSecondaryColor[3]) end
		if props.color1 then SetVehicleColours(vehicle, props.color1, props.color2) end
		if props.color2 then SetVehicleColours(vehicle, props.color1, props.color2) end
		if props.pearlescentColor then 
			pearlescentColor = props.pearlescentColor 
			SetVehicleExtraColours(vehicle, props.pearlescentColor, props.wheelColor) 
		end
		if props.wheelColor then SetVehicleExtraColours(vehicle, pearlescentColor, props.wheelColor) end
		if props.wheels then SetVehicleWheelType(vehicle, props.wheels) end
		if props.windowTint then SetVehicleWindowTint(vehicle, props.windowTint) end

		if props.neonEnabled then
			SetVehicleNeonLightEnabled(vehicle, 0, props.neonEnabled[1])
			SetVehicleNeonLightEnabled(vehicle, 1, props.neonEnabled[2])
			SetVehicleNeonLightEnabled(vehicle, 2, props.neonEnabled[3])
			SetVehicleNeonLightEnabled(vehicle, 3, props.neonEnabled[4])
		end

		if props.extras then
			for id,enabled in pairs(props.extras) do
				if enabled then
					SetVehicleExtra(vehicle, tonumber(id), 0)
				else
					SetVehicleExtra(vehicle, tonumber(id), 1)
				end
			end
		end
		
		if props.neonColor then SetVehicleNeonLightsColour(vehicle, props.neonColor[1], props.neonColor[2], props.neonColor[3]) end
		if props.xenonColor then SetVehicleXenonLightsColour(vehicle, props.xenonColor) end
		if props.modSmokeEnabled then ToggleVehicleMod(vehicle, 20, true) end
		if props.tyreSmokeColor then SetVehicleTyreSmokeColor(vehicle, props.tyreSmokeColor[1], props.tyreSmokeColor[2], props.tyreSmokeColor[3]) end
		if props.modSpoilers then SetVehicleMod(vehicle, 0, props.modSpoilers, false) end
		if props.modFrontBumper then SetVehicleMod(vehicle, 1, props.modFrontBumper, false) end
		if props.modRearBumper then SetVehicleMod(vehicle, 2, props.modRearBumper, false) end
		if props.modSideSkirt then SetVehicleMod(vehicle, 3, props.modSideSkirt, false) end
		if props.modExhaust then SetVehicleMod(vehicle, 4, props.modExhaust, false) end
		if props.modFrame then SetVehicleMod(vehicle, 5, props.modFrame, false) end
		if props.modGrille then SetVehicleMod(vehicle, 6, props.modGrille, false) end
		if props.modHood then SetVehicleMod(vehicle, 7, props.modHood, false) end
		if props.modFender then SetVehicleMod(vehicle, 8, props.modFender, false) end
		if props.modRightFender then SetVehicleMod(vehicle, 9, props.modRightFender, false) end
		if props.modRoof then SetVehicleMod(vehicle, 10, props.modRoof, false) end
		if props.modEngine then SetVehicleMod(vehicle, 11, props.modEngine, false) end
		if props.modBrakes then SetVehicleMod(vehicle, 12, props.modBrakes, false) end
		if props.modTransmission then SetVehicleMod(vehicle, 13, props.modTransmission, false) end
		if props.modHorns then SetVehicleMod(vehicle, 14, props.modHorns, false) end
		if props.modSuspension then SetVehicleMod(vehicle, 15, props.modSuspension, false) end
		if props.modArmor then SetVehicleMod(vehicle, 16, props.modArmor, false) end
		if props.modTurbo then ToggleVehicleMod(vehicle,  18, props.modTurbo) end
		if props.modXenon then ToggleVehicleMod(vehicle,  22, props.modXenon) end
		if props.modFrontWheels then SetVehicleMod(vehicle, 23, props.modFrontWheels, false) end
		if props.modBackWheels then SetVehicleMod(vehicle, 24, props.modBackWheels, false) end
		if props.modPlateHolder then SetVehicleMod(vehicle, 25, props.modPlateHolder, false) end
		if props.modVanityPlate then SetVehicleMod(vehicle, 26, props.modVanityPlate, false) end
		if props.modTrimA then SetVehicleMod(vehicle, 27, props.modTrimA, false) end
		if props.modOrnaments then SetVehicleMod(vehicle, 28, props.modOrnaments, false) end
		if props.modDashboard then SetVehicleMod(vehicle, 29, props.modDashboard, false) end
		if props.modDial then SetVehicleMod(vehicle, 30, props.modDial, false) end
		if props.modDoorSpeaker then SetVehicleMod(vehicle, 31, props.modDoorSpeaker, false) end
		if props.modSeats then SetVehicleMod(vehicle, 32, props.modSeats, false) end
		if props.modSteeringWheel then SetVehicleMod(vehicle, 33, props.modSteeringWheel, false) end
		if props.modShifterLeavers then SetVehicleMod(vehicle, 34, props.modShifterLeavers, false) end
		if props.modAPlate then SetVehicleMod(vehicle, 35, props.modAPlate, false) end
		if props.modSpeakers then SetVehicleMod(vehicle, 36, props.modSpeakers, false) end
		if props.modTrunk then SetVehicleMod(vehicle, 37, props.modTrunk, false) end
		if props.modHydrolic then SetVehicleMod(vehicle, 38, props.modHydrolic, false) end
		if props.modEngineBlock then SetVehicleMod(vehicle, 39, props.modEngineBlock, false) end
		if props.modAirFilter then SetVehicleMod(vehicle, 40, props.modAirFilter, false) end
		if props.modStruts then SetVehicleMod(vehicle, 41, props.modStruts, false) end
		if props.modArchCover then SetVehicleMod(vehicle, 42, props.modArchCover, false) end
		if props.modAerials then SetVehicleMod(vehicle, 43, props.modAerials, false) end
		if props.modTrimB then SetVehicleMod(vehicle, 44, props.modTrimB, false) end
		if props.modTank then SetVehicleMod(vehicle, 45, props.modTank, false) end
		if props.modWindows then SetVehicleMod(vehicle, 46, props.modWindows, false) end

		if props.modLivery then SetVehicleMod(vehicle, 48, props.modLivery, false) end
		if props.modLivery2 then SetVehicleLivery(vehicle, props.modLivery2) end

		if props.dashboardColor ~= nil then
			SetVehicleDashboardColour(vehicle, props.dashboardColor)
		end
	
		if props.interiorColor ~= nil then
			SetVehicleInteriorColour(vehicle, props.interiorColor)
		end

	end
end

local LastMessage = nil
local LastCount = 1
local LastFactor = 0

Cake.Game.Utils.DrawText3D = function(coords, text, size, font)
    x = coords.x
    y = coords.y
    z = coords.z
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    SetTextDropshadow(0, 0, 0, 0, 55)
    SetTextDropShadow()
    AddTextComponentString(text)
    DrawText(_x,_y)

	if text ~= LastMessage then
		LastCount = get_line_count(text)
		LastMessage = text
		LastFactor = (string.len(text)) / 390
	end

    DrawRect(_x,_y+0.0125*LastCount, 0.015+ LastFactor, 0.03*LastCount, 0, 0, 0, 150)
end

function get_line_count(str)
    local lines = 1
    for i = 1, #str do
        local c = str:sub(i, i)
        if c == '\n' then lines = lines + 1 end
    end

    return lines
end

local LastMessage = ""

Cake.ShowFloatingHelpNotification = function(msg, coords)
	Cake.Game.Utils.DrawText3D(coords, msg)
end

Cake.CanDoAnything = function()
	local PlayerPed = Cake.Cache.PlayerPedId()

	return not exports["prp-policejob"]:CheckCuffed() and not exports["prp-ambulancejob"]:CheckCarry() and not exports["prp-ambulancejob"]:CheckDead() and not IsPedBeingStunned(PlayerPedId()) and not IsPedRagdoll(PlayerPed) and not IsEntityPlayingAnim(PlayerPed, "random@mugging3", "handsup_standing_base", 3)
end

RegisterNetEvent('prp:serverCallback', function(name, requestId, ...)
	Cake.LockedCallbacks[name]      = nil
	if requestId ~= nil and Cake.ServerCallbacks[requestId] ~= nil then
		Cake.ServerCallbacks[requestId](...)
		Cake.ServerCallbacks[requestId] = nil
	else
		print(name .. " requestId nil")
	end
end)
 
RegisterNetEvent('esx:showNotification', function(msg)
	Cake.ShowNotification(msg)
end)

RegisterNetEvent('esx:showAdvancedNotification', function(title, subject, msg, icon, iconType)
	Cake.ShowAdvancedNotification(title, subject, msg, icon, iconType)
end)

RegisterNetEvent('esx:showHelpNotification', function(msg)
	Cake.ShowHelpNotification(msg)
end)

Cake.RegisterClientCallback = function(name, cb)
	Cake.ClientCallbacks[name] = cb
end

Cake.TriggerClientCallback = function(name, requestId, cb, ...)
	if Cake.ClientCallbacks[name] ~= nil then
		Cake.ClientCallbacks[name](cb, ...)
	else
		print('prp-framework: TriggerClientCallback => [' .. name .. '] does not exist')
	end
end

DrawBusySpinner = function(Text)
    SetLoadingPromptTextEntry("STRING")
    AddTextComponentSubstringPlayerName(Text)
    ShowLoadingPrompt(3)
end