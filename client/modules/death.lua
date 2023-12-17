Cake.Death.Dead = false
Cake.Death.PausingAnimation = false
Cake.Death.SoftDeath = false
Cake.Death.KillingBlow = nil

Cake.Death.IsDead = function()
	return Cake.Death.Dead
end

Cake.Death.PlayerDied = function()
	if not Cake.Death.Dead then
		Cake.Death.PausingAnimation = false
		Cake.Death.Dead = true

		local KillingEntity, CauseOfDeath = GetPedSourceOfDeath(Cake.Cache.PlayerPed), GetPedCauseOfDeath(Cake.Cache.PlayerPed)
		local KillingPlayer = NetworkGetPlayerIndexFromPed(KillingEntity)

		if KillingEntity ~= Cake.Cache.PlayerPed and KillingPlayer and NetworkIsPlayerActive(KillingPlayer) then
			PlayerKilledByPlayer(GetPlayerServerId(KillingPlayer), KillingPlayer, CauseOfDeath)
		else
			PlayerKilled(CauseOfDeath)
		end

		if Config.NonLethal[CauseOfDeath] then
			Cake.Death.SoftDeath = true
		else
			Cake.Death.SoftDeath = false
		end

		TriggerServerEvent("prp-core:Death:ChangeDeathState", Cake.Death.Dead, Cake.Death.SoftDeath)
		TriggerEvent("prp-core:Death:PlayerDead", KillingEntity, CauseOfDeath, KillingPlayer, Cake.Death.SoftDeath)

		SetCurrentPedWeapon(Cake.Cache.PlayerPedId(), `WEAPON_UNARMED`, true)

		--CreateThread(Cake.Death.RagLoop)
		--CreateThread(Cake.Death.Loop)
	end
end

Cake.Death.GetKillingBlow = function()
	return Cake.Death.KillingBlow
end

Cake.Death.PlayerAlive = function()
	Cake.Death.Dead = false
	Cake.Death.KillingBlow = nil

	TriggerServerEvent("prp-core:Death:ChangeDeathState", false)
	TriggerEvent("prp-core:Death:PlayerAlive")
end

Cake.Death.PauseAnimation = function(Value)
	Cake.Death.PausingAnimation = Value
end

function PlayerKilledByPlayer(killerServerId, killerClientId, killerWeapon)
	local victimCoords = GetEntityCoords(PlayerPedId())
	local killerCoords = GetEntityCoords(GetPlayerPed(killerClientId))
	local distance     = GetDistanceBetweenCoords(victimCoords, killerCoords, true)

	local data = {
		victimCoords = { x = Cake.Math.Round(victimCoords.x, 1), y = Cake.Math.Round(victimCoords.y, 1), z = Cake.Math.Round(victimCoords.z, 1) },
		killerCoords = { x = Cake.Math.Round(killerCoords.x, 1), y = Cake.Math.Round(killerCoords.y, 1), z = Cake.Math.Round(killerCoords.z, 1) },

		killedByPlayer = true,
		deathCause     = killerWeapon,
		distance       = Cake.Math.Round(distance, 1),

		killerServerId = killerServerId,
		killerClientId = killerClientId
	}

	TriggerEvent('prp:PlayerDeath', data)
end

function PlayerKilled()
	local playerPed = PlayerPedId()
	local victimCoords = GetEntityCoords(PlayerPedId())

	local data = {
		victimCoords = { x = Cake.Math.Round(victimCoords.x, 1), y = Cake.Math.Round(victimCoords.y, 1), z = Cake.Math.Round(victimCoords.z, 1) },

		killedByPlayer = false,
		deathCause     = GetPedCauseOfDeath(playerPed)
	}

	TriggerEvent('prp:PlayerDeath', data)
end

--[[
CreateThread(function()
	
	local Player = PlayerId()

	while true do
		local Sleep = 100

		if NetworkIsPlayerActive(Player) then
			local PlayerPed = PlayerPedId()

			if (IsPedFatallyInjured(PlayerPed) or IsEntityDead(PlayerPed) or GetEntityHealth(PlayerPed)) < 75 and not IsDead then
				Sleep = 0
				IsDead = true

				local killerEntity, deathCause = GetPedSourceOfDeath(PlayerPed), GetPedCauseOfDeath(PlayerPed)
				local killerClientId = NetworkGetPlayerIndexFromPed(killerEntity)

				if killerEntity ~= PlayerPed and killerClientId and NetworkIsPlayerActive(killerClientId) then
					PlayerKilledByPlayer(GetPlayerServerId(killerClientId), killerClientId, deathCause)
				else
					PlayerKilled(deathCause)
				end

			elseif not IsPedFatallyInjured(PlayerPed) and IsDead then
				Sleep = 0
				IsDead = false
			end
		end
qui
		Wait(Sleep)
	end
end)


]]

Cake.Log.Info("Death", "Loaded")