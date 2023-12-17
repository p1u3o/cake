local HashedEvents = {}
local Callbacks = {}
local CurrentId = 1
local LockedCallbacks = {}
local PendingCallbacks = {}

Cake.Net.RegisteredCallbacks = {}

Cake.Net.TriggerServerEvent = function(Event, ...)
    local Payload = msgpack.pack({...})

    if Payload:len() < 5000 then
        TriggerServerEventInternal(Event, Payload, Payload:len())
    else
        TriggerLatentServerEventInternal(Event, Payload, Payload:len(), 128000)
    end
end

Cake.Net.TriggerServerCallback = function(Event, ...)
    local CurrentTime = GetGameTimer()

    if LockedCallbacks[Event] ~= nil then
		if CurrentTime - LockedCallbacks[Event] < 10000 then
        Cake.Log.Warn("Net", Event .. " still in queue")

            Wait(250)

            return Cake.Net.TriggerServerCallback(Event, ...)
        elseif PendingCallbacks[Event] ~= nil then
            TriggerEvent("prp-core:Net:TriggerServerCallbackResult", PendingCallbacks[Event], nil)
        end
    end

    LockedCallbacks[Event] = CurrentTime

    if HashedEvents[Event] == nil then
        HashedEvents[Event] = Cake.Crypto.MD5.SumHex(Event)
    end

    local CallbackId = CurrentId

    Callbacks[CallbackId] = promise.new()
    PendingCallbacks[Event] = CallbackId

    Cake.Net.TriggerServerEvent("prp-core:Net:TriggerServerCallback", HashedEvents[Event], CallbackId, ...)

	if CurrentId < 65535 then
		CurrentId = CurrentId + 1
	else
		CurrentId = 0
	end
    
    local Result = Citizen.Await(Callbacks[CallbackId])

    LockedCallbacks[Event] = nil
    PendingCallbacks[Event] = nil

    return table.unpack(Result)
end

Cake.Net.RegisterClientCallback = function(Name, Cb)
    HashedEvents[Cake.Crypto.MD5.SumHex(Name)] = Name
    Cake.Net.RegisteredCallbacks[Name] = Cb
end

Cake.Net.TriggerClientCallback = function(Name, RequestId, ...)
	if Cake.Net.RegisteredCallbacks[Name] ~= nil then
		return Cake.Net.RegisteredCallbacks[Name](...)
	end
end

RegisterNetEvent("prp-core:Net:TriggerServerCallbackResult", function(CallbackId, Response)
    if Callbacks[CallbackId] ~= nil then
        Callbacks[CallbackId]:resolve(Response)
        Callbacks[CallbackId] = nil
    else
        print("RequestId invalid")
    end
end)

RegisterNetEvent("prp-core:Net:TriggerClientCallback", function(Name, RequestId, ...)
    if HashedEvents[Name] ~= nil then
        local Result = table.pack(Cake.Net.TriggerClientCallback(HashedEvents[Name], RequestId, ...))

        Cake.Net.TriggerServerEvent('prp-core:Net:TriggerClientCallbackResult', RequestId, Result)
    end
end)

RegisterNetEvent("prp-core:Net:ReloadedCallback", function(Name)
    LockedCallbacks[Name] = nil
end)

RegisterCommand("ClearAllLocks", function()
    LockedCallbacks = {}
end)

Cake.Log.Info("Net", "Loaded")
