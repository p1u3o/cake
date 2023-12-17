Cake.AntiCheat.Ban = function(Source, Module, Reason)
    print("Anticheat Debug")
    print(Module)
    print(Source)
    print(Reason)
    print(GetPlayerName(Source))
    local Message = "[" .. tostring(Module) .. "] " .. GetPlayerName(Source) .. " (" .. tostring(Source) .. ") " .. tostring(Reason)

    exports['prp-tab']:WebhookBasic("Exploit", "Framework", "@everyone " .. Message)
    TriggerEvent('prp_admin:mtL3Ad9TOa8/IvSbRa5DUhugZcY+zaoRc46feBayzRo=', Source)

    print(Message)
end