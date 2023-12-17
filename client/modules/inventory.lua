local Callbacks = {}

Cake.Inventory.RegisterUsableItem = function(Item, Cb)
    Callbacks[Item] = Cb
end

Cake.Inventory.UseItem =  function(Item, Slot)
    if Callbacks[Item] ~= nil then
        if Cake.Net.TriggerServerCallback("prp-core:Inventory:HasItem", Item, 1) then
            Callbacks[Item](Item, Slot, function()
                TriggerServerEvent("prp-core:Inventory:RemoveItem", Item)
            end)
        end
	end
end

RegisterNetEvent("prp-core:Inventory:UseItem", Cake.Inventory.UseItem)

Cake.Log.Info("Inventory", "Loaded")
