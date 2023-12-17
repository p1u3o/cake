Cake.Inventory = {}

local Callbacks = {}

Cake.Inventory.RegisterUsableItem = function(Item, Cb)
    Callbacks[Item] = Cb
end

Cake.Inventory.UseItem =  function(Source, Item, Slot)
    if Callbacks[Item] ~= nil then
		Callbacks[Item](Source, Slot)
	else
		TriggerClientEvent("prp-core:Inventory:UseItem", Source, Item, Slot)
	end
end

Cake.Inventory.RemoveItem = function(Item)
    local xPlayer = Cake.GetPlayerFromId(source)

    if xPlayer ~= nil then
        xPlayer.removeInventoryItem(Item, 1)
    end
end

Cake.Inventory.HasItem = function(Source, Item, Quantity)
    local xPlayer = Cake.GetPlayerFromId(Source)

    if Quantity == nil then
        Quantity = 1
    end

    local Count = xPlayer.getInventoryItem(Item).count

    if Count >= Quantity then
        return true
    else
        return false
    end
end

Cake.Inventory.GetItemCount = function(Source, Item)
    local xPlayer = Cake.GetPlayerFromId(Source)

    local Count = xPlayer.getInventoryItem(Item).count

    return Count
end

Cake.Inventory.CheckSpace = function(Source, Item, Quantity)
    local xPlayer = Cake.GetPlayerFromId(Source)
    local Promise = promise.new()

    if Quantity == nil then
        Quantity =1
    end

	exports["prp-inventory"]:canAdd(Source, Item, Quantity, function(HasSpace)	
        Promise:resolve(HasSpace)
    end) 

    local HasSpace = Citizen.Await(Promise)

    return HasSpace
end

Cake.Inventory.GetLabel = function(Item)
    if Cake.Items[Item] ~= nil then
        return Cake.Items[Item].label
    end

    return nil
end

Cake.Inventory.GetItems = function()
    return Cake.Items
end

Cake.Inventory.RegisterMetadataCreator = function(Name, Generator)
    TriggerEvent("prp-inventory:registerMetaCreator", Name, function(Item, Source, cb)
        if Item.metadata == nil then
            Item.metadata = {}
        end
        
        local Result = Generator(Source, Item)
        
        if Result ~= false then
            cb(Result)
        end
    end)
end

RegisterNetEvent("prp-core:Inventory:RemoveItem", Cake.Inventory.RemoveItem)

RegisterNetEvent('removeItem', function(Item, Amount)
    local xPlayer = Cake.GetPlayerFromId(source)

    if xPlayer ~= nil then
        if Amount == nil then
            Amount = 1
        end
        
        xPlayer.removeInventoryItem(Item, Amount)
    else
        Cake.AntiCheat.Ban(source, "CivScripts", "attempted to remove item " .. Item .. " before character init")
    end
end)

CreateThread(function()
    Cake.Net.RegisterServerCallback('prp-core:Inventory:GetItemCount', Cake.Inventory.GetItemCount)
    Cake.Net.RegisterServerCallback('prp-core:Inventory:HasItem', Cake.Inventory.HasItem)
    Cake.Net.RegisterServerCallback('prp-core:Inventory:CheckSpace', Cake.Inventory.CheckSpace)
end)

Cake.RegisterUsableItem = Cake.Inventory.RegisterUsableItem
Cake.UseItem = Cake.Inventory.UseItem
Cake.GetItemLabel = Cake.Inventory.GetLabel
Cake.GetItemsData = Cake.Inventory.GetItems