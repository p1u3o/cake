Cake.Utils.GetRoadName = function(X, Y, Z)
	local CurrentStreet, Intersection = GetStreetNameAtCoord(X, Y, Z)

    CurrentStreet = GetStreetNameFromHashKey(CurrentStreet)
    Intersection  = GetStreetNameFromHashKey(Intersection)

    local Zone = tostring(GetNameOfZone(X, Y, Z))

    if not Zone then
        Zone = "Unknown"
    elseif Config.ZoneNames[Zone] then
        Zone = Config.ZoneNames[Zone]
    end

    if CurrentStreet == nil or CurrentStreet == "" then
        if Intersection ~= nil and Intersection ~= "" then
            CurrentStreet = Intersection
        else
            CurrentStreet = "Unknown"
        end
    end

    return {CurrentStreet, Zone}
end

Cake.Utils.GetVehicleColour = function(Vehicle)
    local Primary, Secondary = GetVehicleColours(Vehicle)

    for k, v in pairs (Config.CarColours) do
        if v.Value == Primary then
            return v.Label, Primary, Secondary
        end
    end

    return nil
end

Cake.Utils.GetPedGender = function(Ped)
    local EntityModel = GetEntityModel(Ped)

    if EntityModel == `mp_f_freemode_01` then
        return "female"
    elseif EntityModel == `mp_m_freemode_01` then
        return "male"
    else
        return "person"
    end
end