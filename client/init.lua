Citizen.CreateThread( function()
    while true do
        if NetworkIsSessionStarted() then
            Cake.Cache.Player = PlayerId()
            Cake.Cache.NetworkId = GetPlayerServerId(Cake.Cache.Player)

            Cake.Log.Info("Cake", "Network Ready")

            TriggerServerEvent("prp-core:Session:Started")
            TriggerServerEvent("playerConnected")
            TriggerServerEvent("Queue:playerActivated")

            break
        end

        Citizen.Wait(0)
    end
end)