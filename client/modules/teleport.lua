Cake.Teleport = {}

local IsTeleporting = false

Cake.Teleport.Goto = function(Ped, X, Y, Z, W, Delay, ManualCancel)
    Ped = Cake.Cache.PlayerPedId()
    
    if W == nil then
        Position = vector4(X, Y, Z, GetEntityHeading(Ped))
    else
        Position = vector4(X, Y, Z, W)
    end

    IsTeleporting = true

    local Message = Config.TeleportMessages[math.random(1, #Config.TeleportMessages)]
    
    RequestCollisionAtCoord(Position.x, Position.y, Position.z)
    SetEntityInvincible(Ped, true)

    if Delay == nil then
        exports['prp-notify']:TeleportOn(500)
    end

    if IsPedInAnyVehicle(Ped, true) then
        ClearPedTasksImmediately(Ped)
    end

    if Delay == nil then
        if GameVersion == "fivem" then
            NetworkFadeOutEntity(Ped, 0)
        end

        Wait(500)
    end

    local Timeout = 0

    SetEntityCoords(Ped, Position.x, Position.y, Position.z, false, false, false, false)

    Cake.Cache.SetCurrentCoords(Position.xyz)
    Cake.Zones.ProcessZones(Ped, Cake.Cache.CurrentCoords)

    SetEntityHeading(Ped, Position.w)

    Citizen.Wait(1000)

    SetFocusEntity(Ped)

    while (not HasCollisionLoadedAroundEntity(Ped) or IsEntityInAir(Ped)) and Timeout < 10000 do
        Timeout = Timeout + 1
        Citizen.Wait(1)
    end

    FreezeEntityPosition(Ped, true)

    if Delay ~= nil then
        Citizen.Wait(Delay)
    end
    
    if GameVersion == "fivem" then
        NetworkFadeInEntity(Ped, 0)
    end
    
    Wait(500)

    SetEntityInvincible(Ped, false)

    SetEntityCollision(Ped, true)
    FreezeEntityPosition(Ped, false)

    ClampGameplayCamYaw(0.0, 0.0)

    Citizen.Wait(500)

    if Delay == nil and ManualCancel == nil then
        exports['prp-notify']:TeleportOff(500)
    end

    IsTeleporting = false
end

Cake.Teleport.GotoWithVehicle = function(Ped, X, Y, Z, W)
    IsTeleporting = true
    RequestCollisionAtCoord(X, Y, Z)

    while not HasCollisionLoadedAroundEntity(Ped) do
        RequestCollisionAtCoord(X, Y, Z)
        Citizen.Wait(1)
    end

    if IsPedInAnyVehicle(Ped, true) then
        DoScreenFadeOut(950)
        Wait(1000)                            
        SetEntityCoords(GetVehiclePedIsUsing(Ped), X, Y, Z)
        SetEntityHeading(GetVehiclePedIsUsing(Ped), W)
        Wait(1000)
        DoScreenFadeIn(3000)
    else
        DoScreenFadeOut(950)
        Wait(1000)                            
        SetEntityCoords(Ped, X, Y, Z)
        SetEntityHeading(Ped, W)
        Wait(1000)
        DoScreenFadeIn(3000)
    end
    IsTeleporting = false
end

Cake.Teleport.IsTeleporting = function()
    return IsTeleporting
end

AddEventHandler("prp-core:Teleport:Goto", Cake.Teleport.Goto)
AddEventHandler("prp-core:Teleport:GotoWithVehicle", Cake.Teleport.GotoWithVehicle)
AddEventHandler("prp-core:Teleport:IsTeleporting", function(Cb)
    Cb(Cake.Teleport.IsTeleporting())
end)

Cake.Log.Info("Teleport", "Loaded")
