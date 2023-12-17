Cake.CarKeys = {}
Cake.CarKeys.Salt = nil
Cake.CarKeys.Keys = {}

Cake.CarKeys.GiveKey = function(Plate)
    Cake.CarKeys.Keys[Plate] = true
    Cake.CarKeys.SaveKeys()
end

Cake.CarKeys.TakeKey = function(Plate)
    Cake.CarKeys.Keys[Plate] = nil
    Cake.CarKeys.SaveKeys()
end

Cake.CarKeys.HasKey = function(Plate)
    return Cake.CarKeys.Keys[Plate] ~= nil
end

Cake.CarKeys.SaveKeys = function()
    Cake.KvP.Set.String(Cake.KvP.GetSaveForIdentifier("SavedKeys"), json.encode({
        Salt = Cake.CarKeys.Salt,
        Keys = Cake.CarKeys.Keys
    }))
end

RegisterNetEvent("prp-core:Session:PlayerLoaded", function(xPlayer)
    Cake.CarKeys.Salt = GlobalState.carKeySalt

    local Save = Cake.KvP.Get.String(Cake.KvP.GetSaveForIdentifier("SavedKeys"), nil)

    if Save then
        Save = json.decode(Save)

        if Save.Salt == Cake.CarKeys.Salt then
            Cake.CarKeys.Keys = Save.Keys
        end
    end
end)