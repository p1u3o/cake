RegisterNetEvent("prp-core:Session:Started", function()
    local Source = source
    local Identifier = GetPlayerIdentifierByType(Source, Config.Identifier)
    
    Cake.Account.Get(Identifier, function(IsRegistered, Result)
        if IsRegistered then
            Cake.Accounts[Source] = Cake.Account.Create(Source, Result, Identifier)
            TriggerClientEvent("prp-core:Session:Started", Source, Result, Identifier)
        else
            Cake.Account.Register(Source, Identifier, function(Result)
                Cake.Accounts[Source] = Cake.Account.Create(Source, Result, Identifier)
                TriggerClientEvent("prp-core:Session:Started", Source, Result, Identifier)
            end)
        end

        TriggerEvent("prp-core:Session:NewSession", Source)
    end)

    for k, v in pairs(Config.DefaultStateBags) do
        Player(Source).state:set(k, v, true)
    end
end)