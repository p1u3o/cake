Cake.Death = {}

Cake.Death.ChangeDeathState = function(State, Reason)
    local xPlayer = Cake.GetPlayerFromId(source)

    if xPlayer ~= nil then
        xPlayer.setDead(State)
        Player(xPlayer.source).state:set("isDead", State, true)
    end
end

RegisterNetEvent("prp-core:Death:ChangeDeathState", Cake.Death.ChangeDeathState)