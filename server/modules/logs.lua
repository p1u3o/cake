local LogSinks = {}
local SinkNames = {}

Cake.Logs.Basic = function(Module, Name, Text)
    if type(Module) == 'table' then
        for k, v in ipairs(Module) do
            exports['prp-tab']:WebhookBasic(v, Name, Text)
        end
    else
        exports['prp-tab']:WebhookBasic(Module, Name, Text)
    end
end

Cake.Logs.Write = function(Log, Name, Payload)
    for k, v in ipairs(SinkNames) do
        LogSinks[v](Log, Name, Payload)
    end
end

Cake.Logs.RegisterLogSink = function(Name, Cb)
    if LogSinks[Name] ~= nil then
        LogSinks[Name] = nil
    else
        table.insert(SinkNames, Name)
    end

    LogSinks[Name] = Cb
end

AddEventHandler("prp-core:Logs:Basic", Cake.Logs.Basic)
AddEventHandler("prp-core:Logs:Write", Cake.Logs.Write)
AddEventHandler("prp-core:Logs:RegisterLogSink", Cake.Logs.RegisterLogSink)