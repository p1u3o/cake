local Rules = {}

Cake.RPC.MigrateNetId = function(NetId, Owner)
    Cake.Net.TriggerClientEvent("prp-core:RPC:MigrateNetId", Owner, NetId)
end

Cake.RPC.SyncNative = function(Resource, Native, Owner, NetId, Param2, ...)
    local Source = source
    Owner = tonumber(Owner)

    if Native ~= nil and Owner ~= -1 and Owner ~= nil then
        Cake.Net.TriggerClientEvent("prp-core:RPC:SyncNative:Execute", Owner, Native, NetId, Param2, ...)

        if Resource ~= nil then
            if Config.RPC.Learn then
                if Rules[Resource] == nil then
                    Rules[Resource] = {}
                end

                Rules[Resource][Native] = true
            else
                if Rules[Resource] == nil or Rules[Resource][Native] == nil then
                    Cake.AntiCheat.Ban(Source, "RPC", "with resource " .. Resource .. " attempted to use " .. Native)
                end
            end
        end
    else
        if Native == nil then
            Native = "nil"
        end
        
        if Resource ~= nil then
            Cake.AntiCheat.Ban(Source, "RPC", "with resource " .. Resource .. " attempted to use " .. Native .. " on everyone")
        else
            Cake.AntiCheat.Ban(Source, "RPC", "nil resource attempted to use " .. Native .. " on everyone")
        end
    end
end

Cake.RPC.SyncTransaction = function(Owner, Transactions)
    Cake.Net.TriggerClientEvent("prp-core:RPC:SyncTransaction", Owner, Transactions)
end

Cake.RPC.SaveRules = function(Timer)
    SaveResourceFile(GetCurrentResourceName(), Config.RPC.Rules, json.encode(Rules, { indent = true }), -1)

    if Timer then
        Citizen.SetTimeout(60000, function()
            Cake.RPC.SaveRules(true)
        end)
    end
end

Cake.RPC.LoadRules = function()
    local StoredRules = LoadResourceFile(GetCurrentResourceName(), Config.RPC.Rules)

    if StoredRules ~= nil then
        Rules = json.decode(StoredRules)
    end

    if Config.RPC.Learn then
        Cake.RPC.SaveRules(true)
    end
end

Cake.RPC.LoadRules()

RegisterNetEvent("prp-core:RPC:MigrateNetId", Cake.RPC.MigrateNetId)
RegisterNetEvent("prp-core:RPC:SyncNative", Cake.RPC.SyncNative)
RegisterNetEvent("prp-core:RPC:SyncTransaction", Cake.RPC.SyncTransaction)
