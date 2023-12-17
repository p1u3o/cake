local HashedEvents = {}
local Callbacks = {}
local LastRequests = {}
local CurrentId = 1
local LockedEvents = {}

Cake.Net = {}
Cake.Net.RegisteredCallbacks = {}

Cake.Net.TriggerClientEvent = function(Event, Target, ...)
    local Payload = msgpack.pack({...})

    if Payload:len() < 5000 then
        TriggerClientEventInternal(Event, Target, Payload, Payload:len())
    else
        TriggerLatentClientEventInternal(Event, Target, Payload, Payload:len(), 128000)
    end
end

Cake.Net.RegisterServerCallback = function(Name, Cb)
    HashedEvents[Cake.Crypto.MD5.SumHex(Name)] = Name
    Cake.Net.RegisteredCallbacks[Name] = Cb

    if LockedEvents[Name] ~= nil then
        TriggerClientEvent("prp-core:Net:ReloadedCallback", -1, Name)
    end

    LockedEvents[Name] = {}
end

Cake.Net.TriggerServerCallback = function(Name, Source, ...)
	if Cake.Net.RegisteredCallbacks[Name] ~= nil then
		return Cake.Net.RegisteredCallbacks[Name](Source, ...)
	end
end

Cake.Net.TriggerClientCallback = function(Event, Target, ...)
    if HashedEvents[Event] == nil then
        HashedEvents[Event] = Cake.Crypto.MD5.SumHex(Event)
    end

    local CallbackId = CurrentId

    Callbacks[CallbackId] = promise.new()

    Cake.Net.TriggerClientEvent("prp-core:Net:TriggerClientCallback", Target, HashedEvents[Event], CallbackId, ...)

	if CurrentId < 65535 then
		CurrentId = CurrentId + 1
	else
		CurrentId = 0
	end
    
    local Result = Citizen.Await(Callbacks[CallbackId])

    return table.unpack(Result)
end

local JobEvents = {}

Cake.Net.RegisterJobEvent = function(EventName, Cb, Jobs)
    if JobEvents[EventName] ~= nil then
        RemoveEventHandler(JobEvents[EventName])
    end

    JobEvents[EventName] = RegisterNetEvent(EventName, function(...)
        local Source = source
        local xPlayer = Cake.GetPlayerFromId(Source)
        
        if xPlayer ~= nil then
            for k, v in ipairs(Jobs) do
                if v == xPlayer.job.name then
                    Cb(xPlayer, ...)   

                    return
                end
            end
        end

        Cake.AntiCheat.Ban(Source, "RegisterJobEvent", "attempted to trigger " .. EventName)
    end)
end

RegisterNetEvent("prp-core:Net:TriggerClientCallbackResult", function(CallbackId, Response)
    if Callbacks[CallbackId] ~= nil then
        Callbacks[CallbackId]:resolve(Response)
        Callbacks[CallbackId] = nil
    end
end)

RegisterNetEvent("prp-core:Net:TriggerServerCallback", function(Name, RequestId, ...)
    local Source = source

    if HashedEvents[Name] ~= nil then
        if LastRequests[Source] == nil or LastRequests[Source] ~= RequestId then
            local CallbackName = HashedEvents[Name]
            LastRequests[Source] = RequestId

            while LockedEvents[CallbackName][Source] do
                Citizen.Wait(25)
            end

            LockedEvents[CallbackName][Source] = true

            Cake.Net.TriggerClientEvent('prp-core:Net:TriggerServerCallbackResult', Source, RequestId, table.pack(Cake.Net.TriggerServerCallback(HashedEvents[Name], Source, ...)))
        
            LockedEvents[CallbackName][Source] = nil
        else
            Cake.AntiCheat.Ban(Source, Name, "attempted to trigger an a replay attack")
        end
    else
        Cake.AntiCheat.Ban(Source, Name, "attempted to trigger an unregistered callback")
    end
end)