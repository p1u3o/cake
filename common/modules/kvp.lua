Cake.KvP = {}

if IsDuplicityVersion() then
    -- Use Server Based ID
    Cake.GetIdentifier = function()
        return GetInvokingResource()
    end
else
    -- Use Character Based ID
    Cake.GetIdentifier = function()
        return Cake.PlayerData.uuid
    end
end

Cake.KvP.Get = {}

Cake.KvP.GetSaveForIdentifier = function(Key)
    return Cake.GetIdentifier() .. "-" .. Key
end

Cake.KvP.Get.String = function(Key, Default)
    local Value = GetResourceKvpString(Key)

    if Value == nil then
        return Default
    else
        return Value
    end
end

Cake.KvP.Get.Int = function(Key, Default)
    local Value = GetResourceKvpInt(Key)

    if Value == nil then
        return Default
    else
        return Value
    end
end

Cake.KvP.Get.Float = function(Key, Default)
    local Value = GetResourceKvpFloat(Key)

    if Value == nil then
        return Default
    else
        return Value
    end
end

Cake.KvP.Set = {}

if IsDuplicityVersion() then
    Cake.KvP.Set.String = function(Key, Value)
        SetResourceKvpNoSync(Key, Value)
    end

    Cake.KvP.Set.Int = function(Key, Value)
        SetResourceKvpIntNoSync(Key, Value)
    end

    Cake.KvP.Set.Float = function(Key, Value)
        SetResourceKvpFloatNoSync(Key, Value)
    end
else
    Cake.KvP.Set.String = function(Key, Value)
        SetResourceKvp(Key, Value)
    end

    Cake.KvP.Set.Int = function(Key, Value)
        SetResourceKvpInt(Key, Value)
    end

    Cake.KvP.Set.Float = function(Key, Value)
        SetResourceKvpFloat(Key, Value)
    end
end

Cake.Log.Info("KVP", "Loaded")
