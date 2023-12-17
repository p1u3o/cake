AddEventHandler('prp:getSharedObject', function(cb)
	cb(Cake)
end)

local AlreadyTrigged = false

function getSharedObject()
	return Cake
end

RegisterNetEvent('esx:triggerClientCallback')
AddEventHandler('esx:triggerClientCallback', function(name, requestId, ...)
	Cake.TriggerClientCallback(name, requestId, function(...)
		TriggerServerEvent('prp:clientCallback', requestId, ...)
	end, ...)
end)
