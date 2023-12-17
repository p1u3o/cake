local Transaction = {}

Cake.RPC.TransactionTarget = nil
Cake.RPC.TransactionPlayerId = nil
Cake.RPC.TransactionNetworkId = nil
Cake.RPC.TransactionCallbacks = {OnSuccess = nil, OnSuccess = nil}
Cake.RPC.TransactionId = 1

Cake.RPC.StartTransaction = function(Target)
    if Cake.RPC.TransactionTarget ~= nil and Cake.RPC.TransactionTarget ~= Target then 
        Cake.RPC.FinishTransaction()
    end

    Cake.RPC.TransactionId = Cake.RPC.TransactionId + 1
    Cake.RPC.TransactionTarget = Target
    Cake.RPC.TransactionPlayerId = GetPlayerServerId(NetworkGetEntityOwner(Target))
    Cake.RPC.TransactionNetworkId = NetworkGetNetworkIdFromEntity(Target)
end

Cake.RPC.FinishTransaction = function(Target)
    --print("Sending to Transaction")
    Cake.Net.TriggerServerEvent("prp-core:RPC:SyncTransaction", Cake.RPC.TransactionPlayerId, Transaction)
    Cake.RPC.TransactionTarget = nil
    Transaction = {}
end

Cake.RPC.SyncTransaction = function(Transactions)
    --print("Received Transaction")
    for k, v in ipairs(Transactions) do
        Cake.RPC.SyncNativeExecute(v[1], v[2], table.unpack(v[3]))
    end
end

Cake.RPC.SyncNative = function(Native, Entity, Param2, ...)
    if DoesEntityExist(Entity) then
        if Entity == Cake.RPC.TransactionTarget then
            --print("Adding to Transaction")
            if Native == "AttachEntityToEntity" then
                table.insert(Transaction, {Native, Cake.RPC.TransactionNetworkId, { NetworkGetNetworkIdFromEntity(Param2), ...}})
            else
                table.insert(Transaction, {Native, Cake.RPC.TransactionNetworkId, { Param2, ...}})
            end
        else
            if Native == "AttachEntityToEntity" then
                Cake.Net.TriggerServerEvent('prp-core:RPC:SyncNative', GetInvokingResource(), Native, GetPlayerServerId(NetworkGetEntityOwner(Entity)), NetworkGetNetworkIdFromEntity(Entity), NetworkGetNetworkIdFromEntity(Param2), ...)
            else
                Cake.Net.TriggerServerEvent('prp-core:RPC:SyncNative', GetInvokingResource(), Native, GetPlayerServerId(NetworkGetEntityOwner(Entity)), NetworkGetNetworkIdFromEntity(Entity), Param2, ...)
            end
        end
    end
end

Cake.RPC.SyncNativeExecute = function(Native, NetId, Param2, ...)
    --print("Performing " .. Native .. " on " .. NetId)
    
    if NetworkDoesNetworkIdExist(NetId) then
        local Entity = NetworkGetEntityFromNetworkId(NetId)
        
        if not DoesEntityExist(Entity) then
            return TriggerServerEvent('prp-core:RPC:SyncNative:Error', Native, NetId)
        end

        if Native == "AttachEntityToEntity" then
            Param2 = NetworkGetEntityFromNetworkId(Param2)
        end

        if Cake.RPC[Native] then
            Cake.RPC[Native](Entity, Param2, ...)
        end
    end
end

Cake.RPC.ExecuteNativeMulti = function(Native, NetIds)
    ---
end

Cake.RPC.RequestOwnership = function(Entity, Cb)
    Cake.Net.TriggerServerEvent("prp-core:RPC:MigrateNetId", NetworkGetNetworkIdFromEntity(Entity), GetPlayerServerId(NetworkGetEntityOwner(Entity)))

    local Attempts = 5

    while not NetworkHasControlOfEntity(Entity) and Attempts > 0 do
        Citizen.Wait(100)
        NetworkRequestControlOfEntity(Entity)
        Attempts = Attempts - 1
    end

    if NetworkHasControlOfEntity(Entity) then
        if Cb ~= nil then
        Cb(true)
        end

        return true
    else
        if Cb ~= nil then
        Cb(false)
    end

        return false
    end
end

Cake.RPC.MigrateNetId = function(NetId)
    if NetworkDoesNetworkIdExist(NetId) then
        local Entity = NetworkGetEntityFromNetworkId(NetId)

        if DoesEntityExist(Entity) and NetworkHasControlOfEntity(Entity) then
            SetNetworkIdExistsOnAllMachines(NetId, true)
            SetNetworkIdCanMigrate(NetId, true)
        end
    end
end

Cake.RPC.AttachEntityToEntity = function(Entity, Entity2, ...) 
    if NetworkHasControlOfEntity(Entity) then
        AttachEntityToEntity(Entity, Entity2, ...)
    else
        Cake.RPC.SyncNative("AttachEntityToEntity", Entity, Entity2, ...)
    end
end

Cake.RPC.ClearPedTasks = function(Entity) 
    if NetworkHasControlOfEntity(Entity) then
        ClearPedTasks(Entity)
    else
        Cake.RPC.SyncNative("ClearPedTasks", Entity)
    end
end

Cake.RPC.DeleteObject = function(Entity) 
    if NetworkHasControlOfEntity(Entity) then
        SetEntityAsMissionEntity(Entity)
        SetEntityAsNoLongerNeeded(Entity)
        DeleteObject(Entity)
        DeleteEntity(Entity)
    else
        Cake.RPC.SyncNative("DeleteObject", Entity)
    end
end

Cake.RPC.DeleteVehicle = function(Entity) 
    if NetworkHasControlOfEntity(Entity) then
        SetEntityAsMissionEntity(Entity)
        TriggerServerEvent("prp-vehiclescripts:RemoveNetworkId", VehToNet(Entity))
        SetVehicleHasBeenOwnedByPlayer(Entity, true)
        NetworkFadeOutEntity(Entity, true, true)
        Citizen.Wait(100)
        SetEntityAsNoLongerNeeded(Entity)
        DeleteEntity(Entity)
        DeleteVehicle(Entity)
    else
        Cake.RPC.SyncNative("DeleteVehicle", Entity)
    end
end

Cake.RPC.DetachEntity = function(Entity, ...) 
    if NetworkHasControlOfEntity(Entity) then
        DetachEntity(Entity, ...)
    else
        Cake.RPC.SyncNative("DetachEntity", Entity, ...)
    end
end

Cake.RPC.FreezeEntityPosition = function(Entity, ...) 
    if NetworkHasControlOfEntity(Entity) then
        FreezeEntityPosition(Entity, ...)
    else
        Cake.RPC.SyncNative("FreezeEntityPosition", Entity, ...)
    end
end

Cake.RPC.SetEntityCoords = function(Entity, ...) 
    if NetworkHasControlOfEntity(Entity) then
        SetEntityCoords(Entity, ...)
    else
        Cake.RPC.SyncNative("SetEntityCoords", Entity, ...)
    end
end

Cake.RPC.SetEntityCoordsNoOffset = function(Entity, ...) 
    if NetworkHasControlOfEntity(Entity) then
        SetEntityCoordsNoOffset(Entity, ...)
    else
        Cake.RPC.SyncNative("SetEntityCoordsNoOffset", Entity, ...)
    end
end

Cake.RPC.SetPedToRagdoll = function(Entity, ...)
    if NetworkHasControlOfEntity(Entity) then
        SetPedToRagdoll(Entity, ...)
    else
        Cake.RPC.SyncNative("SetPedToRagdoll", Entity, ...)
    end
end

Cake.RPC.SetVehicleBodyHealth = function(Entity, Health) 
    if NetworkHasControlOfEntity(Entity) then
        SetVehicleBodyHealth(Entity, Health + 0.0)
    else
        SetVehicleBodyHealth(Entity, Health + 0.0)
        Cake.RPC.SyncNative("SetVehicleBodyHealth", Entity, Health + 0.0)
    end
end

Cake.RPC.SetVehicleDirtLevel = function(Entity, ...) 
    if NetworkHasControlOfEntity(Entity) then
        SetVehicleDirtLevel(Entity, ...)
    else
        SetVehicleDirtLevel(Entity, ...)
        Cake.RPC.SyncNative("SetVehicleDirtLevel", Entity, ...)
    end
end

Cake.RPC.SetVehicleDoorsLocked = function(Entity, State) 
    if NetworkHasControlOfEntity(Entity) then
        SetVehicleDoorsLocked(Entity, State)

        if State == 2 then
            SetVehicleDoorsLockedForPlayer(Entity, PlayerId(), true)
        else
            SetVehicleDoorsLockedForPlayer(Entity, PlayerId(), false)
        end
    else
        SetVehicleDoorsLocked(Entity, State)

        if State == 2 then
            SetVehicleDoorsLockedForPlayer(Entity, PlayerId(), true)
        else
            SetVehicleDoorsLockedForPlayer(Entity, PlayerId(), false)
        end

        Cake.RPC.SyncNative("SetVehicleDoorsLocked", Entity, State)
    end
end

Cake.RPC.SetVehicleDoorBroken = function(Entity, ...) 
    if NetworkHasControlOfEntity(Entity) then
        SetVehicleDoorBroken(Entity, ...)
    else
        Cake.RPC.SyncNative("SetVehicleDoorBroken", Entity, ...)
    end
end

Cake.RPC.SetVehicleDoorOpen = function(Entity, ...) 
    if NetworkHasControlOfEntity(Entity) then
        SetVehicleDoorOpen(Entity, ...)
    else
        Cake.RPC.SyncNative("SetVehicleDoorOpen", Entity, ...)
    end
end

Cake.RPC.SetVehicleDoorShut = function(Entity, ...) 
    if NetworkHasControlOfEntity(Entity) then
        SetVehicleDoorShut(Entity, ...)
    else
        Cake.RPC.SyncNative("SetVehicleDoorShut", Entity, ...)
    end
end

Cake.RPC.SetVehicleDeformationFixed = function(Entity) 
    if NetworkHasControlOfEntity(Entity) then
        SetVehicleDeformationFixed(Entity)
    else
        SetVehicleDeformationFixed(Entity)
        Cake.RPC.SyncNative("SetVehicleDeformationFixed", Entity)
    end
end

Cake.RPC.SetVehicleEngineHealth = function(Entity, Health) 
    if NetworkHasControlOfEntity(Entity) then
        SetVehicleEngineHealth(Entity, Health + 0.0)
    else
        SetVehicleEngineHealth(Entity, Health + 0.0)
        Cake.RPC.SyncNative("SetVehicleEngineHealth", Entity, Health + 0.0)
    end
end

Cake.RPC.SetVehicleEngineOn = function(Entity, ...) 
    if NetworkHasControlOfEntity(Entity) then
        SetVehicleEngineOn(Entity, ...)
    else
        Cake.RPC.SyncNative("SetVehicleEngineOn", Entity, ...)
    end
end

Cake.RPC.SetVehicleHandbrake = function(Entity, Value) 
    if NetworkHasControlOfEntity(Entity) then
        SetVehicleHandbrake(Entity, Value)
    else
        SetVehicleHandbrake(Entity, Value)
        Cake.RPC.SyncNative("SetVehicleHandbrake", Entity, Value)
    end
end

Cake.RPC.SetVehicleFixed = function(Entity) 
    if NetworkHasControlOfEntity(Entity) then
        SetVehicleFixed(Entity)
    else
        SetVehicleFixed(Entity)
        Cake.RPC.SyncNative("SetVehicleFixed", Entity)
    end
end

Cake.RPC.SetVehicleLightsFlicker = function(Entity) 
    if NetworkHasControlOfEntity(Entity) then
        Citizen.CreateThread(function()
            SetVehicleLights(Entity, 2)
            SetVehicleFullbeam(Entity, true)
            SetVehicleBrakeLights(Entity, true)
            SetVehicleInteriorlight(Entity, true)
            SetVehicleIndicatorLights(Entity, 0, true)
            SetVehicleIndicatorLights(Entity, 1, true)
            Citizen.Wait(450)
        
            SetVehicleIndicatorLights(Entity, 0, false)
            SetVehicleIndicatorLights(Entity, 1, false)
            Citizen.Wait(450)
            
            SetVehicleInteriorlight(Entity, true)
            SetVehicleIndicatorLights(Entity, 0, true)
            SetVehicleIndicatorLights(Entity, 1, true)
            Citizen.Wait(450)
        
            SetVehicleLights(Entity, 0)
            SetVehicleFullbeam(Entity, false)
            SetVehicleBrakeLights(Entity, false)
            SetVehicleInteriorlight(Entity, false)
            SetVehicleIndicatorLights(Entity, 0, false)
            SetVehicleIndicatorLights(Entity, 1, false)
        end)
    else
        Cake.RPC.SyncNative("SetVehicleLightsFlicker", Entity)
    end
end

Cake.RPC.SetVehicleFuelLevel = function(Entity, Value) 
    TriggerServerEvent('prp-hud:Fuel:ValueChange', GetPlayerServerId(NetworkGetEntityOwner(Entity)), NetworkGetNetworkIdFromEntity(Entity), Value)
end

Cake.RPC.SetVehicleOnGroundProperly = function(Entity) 
    if NetworkHasControlOfEntity(Entity) then
        SetVehicleOnGroundProperly(Entity)
    else
        SetVehicleOnGroundProperly(Entity)
        Cake.RPC.SyncNative("SetVehicleOnGroundProperly", Entity)
    end
end

Cake.RPC.SetVehicleDirtLevel = function(Entity, Value) 
    if NetworkHasControlOfEntity(Entity) then
        SetVehicleDirtLevel(Entity, Value)
    else
        SetVehicleDirtLevel(Entity, Value)
        Cake.RPC.SyncNative("SetVehicleDirtLevel", Entity, Value)
    end
end

Cake.RPC.SetVehiclePetrolTankHealth = function(Entity, Health) 
    if NetworkHasControlOfEntity(Entity) then
        SetVehiclePetrolTankHealth(Entity, Health + 0.0)
    else
        SetVehiclePetrolTankHealth(Entity, Health + 0.0)
        Cake.RPC.SyncNative("SetVehiclePetrolTankHealth", Entity, Health + 0.0)
    end
end

Cake.RPC.SetVehicleTyreBurst = function(Entity, ...) 
    if NetworkHasControlOfEntity(Entity) then
        SetVehicleTyreBurst(Entity, ...)
    else
        SetVehicleTyreBurst(Entity, ...)
        Cake.RPC.SyncNative("SetVehicleTyreBurst", Entity, ...)
    end
end

Cake.RPC.TaskPlayAnim = function(Entity, Dict, Anim, ...) 
    if NetworkHasControlOfEntity(Entity) then
        RequestAnimDict(Dict)

        while not HasAnimDictLoaded(Dict) do
            Wait(10)
        end

        TaskPlayAnim(Entity, Dict, Anim, ...)
    else
        Cake.RPC.SyncNative("TaskPlayAnim", Entity, Dict, Anim, ...)
    end
end

Cake.RPC.WashDecalsFromVehicle = function(Entity, ...) 
    if NetworkHasControlOfEntity(Entity) then
        WashDecalsFromVehicle(Entity, ...)
    else
        WashDecalsFromVehicle(Entity, ...)
        Cake.RPC.SyncNative("WashDecalsFromVehicle", Entity, ...)
    end
end

RegisterNetEvent("prp-core:RPC:MigrateNetId", Cake.RPC.MigrateNetId)
RegisterNetEvent("prp-core:RPC:SyncNative:Execute", Cake.RPC.SyncNativeExecute)
RegisterNetEvent("prp-core:RPC:SyncTransaction", Cake.RPC.SyncTransaction)

Cake.Log.Info("RPC", "Loaded")
