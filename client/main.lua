local PlayerSpawned = false
local HasLoadedIn   = false
local FrozenPos     = true

AddEventHandler("onClientMapStart", function()
	exports.spawnmanager:spawnPlayer()
	exports.spawnmanager:setAutoSpawn(false)
end)

RegisterNetEvent('prp-core:Session:PlayerLoaded', function(xPlayer)
	Cake.PlayerLoaded = true
	Cake.PlayerData   = xPlayer
	TriggerEvent('es:setMoneyDisplay', 0.0)

	--LocalPlayer.state:set("playerData", Cake.PlayerData, false)
	LocalPlayer.state:set("currentJob", Cake.PlayerData.job, false)
	LocalPlayer.state:set("currentJobName", Cake.PlayerData.job.name, false)

	while Cake.PlayerData.ped == nil do Wait(20) end

	-- enable PVP
	if Config.EnablePVP then
		SetCanAttackFriendly(Cake.PlayerData.ped, true, false)
		NetworkSetFriendlyFireOption(true)
	end

	if Config.DisableHealthRegen then
		SetPlayerHealthRechargeMultiplier(PlayerId(), 0.0)
	end

	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(1000 * 60 * 30)
			TriggerServerEvent("prp-core:Account:IncreasePlayTime", 30)
		end
	end)
end)

AddEventHandler('playerSpawned', function()
	while not Cake.PlayerLoaded do
		Citizen.Wait(50)
	end

	local PlayerPed = PlayerPedId()

	-- Restore position
	if HasLoadedIn and Cake.PlayerData.lastPosition ~= nil then
		SetEntityCoords(PlayerPed, Cake.PlayerData.lastPosition.x, Cake.PlayerData.lastPosition.y, Cake.PlayerData.lastPosition.z)
	end
	
	PlayerSpawned = true

	Cake.Death.Dead = false
end)

AddEventHandler("prp-core:PlayerPed", function(PlayerPed)
	Cake.SetPlayerData('ped', PlayerPed)

	if Config.EnablePVP then
		SetCanAttackFriendly(Cake.PlayerData.ped, true, false)
		NetworkSetFriendlyFireOption(true)
	end

	if Config.DisableHealthRegen then
		SetPlayerHealthRechargeMultiplier(PlayerId(), 0.0)
	end
end)

AddEventHandler("prp-admin:HasLoadedIn", function()
	HasLoadedIn = true
	PlayerSpawned = true
end)

RegisterNetEvent('prp-core:Session:JobChange', function(job)
	Cake.PlayerData.job = job
	LocalPlayer.state:set("currentJob", Cake.PlayerData.job, false)
	LocalPlayer.state:set("currentJobName", Cake.PlayerData.job.name, false)
end)

RegisterNetEvent('esx:addWeapon', function(weaponName, ammo)
	local playerPed  = PlayerPedId()
	local weaponHash = GetHashKey(weaponName)

	GiveWeaponToPed(playerPed, weaponHash, ammo, false, false)
	--AddAmmoToPed(playerPed, weaponHash, ammo) possibly not needed
end)

RegisterNetEvent('esx:addWeaponComponent', function(weaponName, weaponComponent)
	local playerPed  = PlayerPedId()
	local weaponHash = GetHashKey(weaponName)
	local componentHash = Cake.GetWeaponComponent(weaponName, weaponComponent).hash

	GiveWeaponComponentToPed(playerPed, weaponHash, componentHash)
end)

RegisterNetEvent('esx:setWeaponTint', function(weaponName, weaponTintIndex)
	local playerPed = PlayerPedId()
	local weaponHash = GetHashKey(weaponName)

	SetPedWeaponTintIndex(playerPed, weaponHash, weaponTintIndex)
end)

RegisterNetEvent('esx:removeWeapon', function(weaponName, ammo)
	local playerPed  = PlayerPedId()
	local weaponHash = GetHashKey(weaponName)

	RemoveWeaponFromPed(playerPed, weaponHash)

	if ammo then
		local pedAmmo = GetAmmoInPedWeapon(playerPed, weaponHash)
		local finalAmmo = math.floor(pedAmmo - ammo)
		SetPedAmmo(playerPed, weaponHash, finalAmmo)
	else
		SetPedAmmo(playerPed, weaponHash, 0) -- remove leftover ammo
	end
end)

RegisterNetEvent('esx:removeWeaponComponent', function(weaponName, weaponComponent)
	local playerPed  = PlayerPedId()
	local weaponHash = GetHashKey(weaponName)
	local componentHash = Cake.GetWeaponComponent(weaponName, weaponComponent).hash

	RemoveWeaponComponentFromPed(playerPed, weaponHash, componentHash)
end)

-- Commands
RegisterNetEvent('esx:teleport', function(pos)
	pos.x = pos.x + 0.0
	pos.y = pos.y + 0.0
	pos.z = pos.z + 0.0

	RequestCollisionAtCoord(pos.x, pos.y, pos.z)

	while not HasCollisionLoadedAroundEntity(PlayerPedId()) do
		RequestCollisionAtCoord(pos.x, pos.y, pos.z)
		Citizen.Wait(1)
	end

	SetEntityCoords(PlayerPedId(), pos.x, pos.y, pos.z)
end)

RegisterNetEvent('prp:spawnVehicle', function(model, plate)
	local playerPed = PlayerPedId()
	local coords    = GetEntityCoords(playerPed)

	TriggerEvent('prp-admin:Functions:SpawnVehicle',model, coords, 90.0, false, plate, 100, true, false)
end)

RegisterNetEvent('esx:spawnEventVehicle', function(model, plate)
	local playerPed = PlayerPedId()
	local coords    = GetEntityCoords(playerPed)
	local heading   = GetEntityHeading(playerPed)
	if plate == nil then
		TriggerEvent('prp-admin:Functions:SpawnVehicle', model, coords, heading, false, "EVENTCAR", 100, true, true, true)
	else
		TriggerEvent('prp-admin:Functions:SpawnVehicle', model, coords, heading, false, plate, 100, true, true, true)
	end
end)

RegisterNetEvent('esx:spawnObject', function(model)
	local playerPed = PlayerPedId()
	local coords    = GetEntityCoords(playerPed)
	local forward   = GetEntityForwardVector(playerPed)
	local x, y, z   = table.unpack(coords + forward * 1.0)

	Cake.Game.SpawnObject(model, {
		x = x,
		y = y,
		z = z
	}, function(obj)
		SetEntityHeading(obj, GetEntityHeading(playerPed))
		PlaceObjectOnGroundProperly(obj)
	end)
end)

RegisterNetEvent('esx:spawnPed', function(model)
	model           = (tonumber(model) ~= nil and tonumber(model) or GetHashKey(model))
	local playerPed = PlayerPedId()
	local coords    = GetEntityCoords(playerPed)
	local forward   = GetEntityForwardVector(playerPed)
	local x, y, z   = table.unpack(coords + forward * 1.0)

	Citizen.CreateThread(function()
		RequestModel(model)

		while not HasModelLoaded(model) do
			Citizen.Wait(1)
		end

		CreatePed(5, model, x, y, z, 0.0, true, false)
	end)
end)

Citizen.CreateThread(function()
	while not NetworkIsSessionStarted() do
		Citizen.Wait(25)
	end

	Cake.Cache.Player = PlayerId()
	Cake.Cache.NetworkId = GetPlayerServerId(Cake.Cache.Player)

	while true do
		local PlayerPed = PlayerPedId()

		if PlayerPed ~= Cake.Cache.PlayerPed then
			Cake.Cache.PlayerPed = PlayerPed
			TriggerEvent("prp-core:PlayerPed", PlayerPed)
		end

		if Cake.PlayerLoaded and PlayerSpawned then
			local CurrentCoords = GetEntityCoords(Cake.Cache.PlayerPed)

			if Cake.PlayerData.CurrentCoords ~= CurrentCoords then
				Cake.PlayerData.CurrentCoords = CurrentCoords
				Cake.Cache.CurrentCoords = CurrentCoords

				if not FrozenPos then
					TriggerServerEvent('prp-core:UpdateLastPosition', {x = Cake.PlayerData.CurrentCoords.x, y = Cake.PlayerData.CurrentCoords.y, z = Cake.PlayerData.CurrentCoords.z})
				end
			end

			if Cake.Cache.CurrentVehicle ~= nil and not IsPedInAnyVehicle(PlayerPed, true) then
				TriggerEvent("prp-core:Vehicle:ExitVehicle", Cake.Cache.CurrentVehicle, PlayerPed)
	
				Cake.Cache.CurrentVehicle = nil
			end

			Cake.PlayerData.lastPosition = {x = Cake.PlayerData.CurrentCoords.x, y = Cake.PlayerData.CurrentCoords.y, z = Cake.PlayerData.CurrentCoords.z}

			Cake.Zones.ProcessZones(Cake.Cache.PlayerPed, Cake.Cache.CurrentCoords)
			
			if HasLoadedIn and not Cake.Death.Dead then
				if IsPedFatallyInjured(PlayerPed) or IsEntityDead(PlayerPed) or GetEntityHealth(PlayerPed) < 75 then
					print("Found via Loop")
					Cake.Death.PlayerDied()
				end
			end
		end

		Citizen.Wait(300)
	end
end)

RegisterNetEvent('prp-core:Functions:SetPos', function(Coords)
    SetEntityCoords(Cake.Cache.PlayerPed, Coords.x, Coords.y, Coords.z)
end)

exports('FreezeLastLocation', function(Value)
	FrozenPos = Value
end)

AddEventHandler('gameEventTriggered', function (Name, Args)
	--print(json.encode(Args))

    if Name == "CEventNetworkPlayerEnteredVehicle" and Args[1] == Cake.Cache.Player and Args[2] ~= Cake.Cache.CurrentVehicle then
		Cake.Cache.CurrentVehicle = Args[2]
		TriggerEvent("prp-core:Vehicle:EnterVehicle", Cake.Cache.CurrentVehicle, Cake.Cache.PlayerPed)
	elseif Name == "CEventNetworkEntityDamage" then
		if Args[1] == Cake.Cache.PlayerPed then
			if not Cake.Death.Dead then
				Citizen.Wait(3)
				if Args[4] == 1 or IsPedFatallyInjured(Cake.Cache.PlayerPed) or IsEntityDead(Cake.Cache.PlayerPed) or GetEntityHealth(Cake.Cache.PlayerPed) < 75 then
					print("Death via Event")
					Cake.Death.KillingBlow = Args
					Cake.Death.PlayerDied()
				end
			end
		end
	end
end)

Citizen.CreateThread(function() 
	while true do 
		Citizen.Wait(30000) 
		collectgarbage() 
	end 
end)

Cake.Log.Info("Cake", "Loaded")
