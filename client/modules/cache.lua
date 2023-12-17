Cake.Cache = {}

Cake.Cache.PlayerPed = PlayerPedId()
Cake.Cache.Player = 0
Cake.Cache.NetworkId = 0

Cake.Cache.CurrentVehicle = nil
Cake.Cache.CurrentCoords = vector3(0, 0, 0)

Cake.Cache.PlayerPedId = function()
    return Cake.Cache.PlayerPed
end

Cake.Cache.PlayerId = function()
    return Cake.Cache.Player
end

Cake.Cache.GetPlayerNetworkId = function()
    return Cake.Cache.NetworkId
end

Cake.Cache.GetCurrentVehicle = function()
    return Cake.Cache.CurrentVehicle
end

Cake.Cache.IsInVehicle = function()
    return Cake.Cache.CurrentVehicle ~= nil
end

Cake.Cache.GetCurrentCoords = function()
    return Cake.Cache.CurrentCoords
end

Cake.Cache.SetCurrentCoords = function(Position)
    Cake.Cache.CurrentCoords =  Position
end

Cake.Log.Info("Cache", "Loaded")
