Cake.Zones.InZone = {}
Cake.Zones.ZoneEvents = {}

local CurrentZones = {}
local ZoneParams = {}

Cake.Zones.ProcessZones = function(PlayerPed, Coords)
    for _, zone in pairs(CurrentZones) do
        if CurrentZones[_]:isPointInside(Coords) then
            if (not Cake.Zones.InZone[_]) then

                Cake.Zones.InZone[_] = true

                Citizen.CreateThread(function()
                    if Cake.Zones.ZoneEvents[_] ~= nil then
                        TriggerEvent(Cake.Zones.ZoneEvents[_], _, true, ZoneParams[_])
                    else
                        TriggerEvent("prp-core:Zones:Enter", _, ZoneParams[_])
                    end
                    
                    Citizen.Wait(100)

                    while Cake.Zones.InZone[_] do
                        if Cake.Cache.CurrentCoords.z == 0 and Cake.Cache.CurrentCoords.y == 0 and Cake.Cache.CurrentCoords.z == 0 then
                            -- Ignore, something went very wrong for this to happen, perhaps in teleport?
                        else
                            if not CurrentZones[_]:isPointInside(Cake.Cache.CurrentCoords) then 
                                Cake.Zones.InZone[_] = false
    
                                if Cake.Zones.ZoneEvents[_] ~= nil then
                                    TriggerEvent(Cake.Zones.ZoneEvents[_], _, false, ZoneParams[_])
                                else
                                    TriggerEvent("prp-core:Zones:Exit", _, ZoneParams[_])
                                end
                            end
                        end

                        Citizen.Wait(250)
                    end
                end)
            end
        end
    end
end

Cake.Zones.AddCircleZone = function(Name, Center, Radius, Options, Param)
    if CurrentZones[Name] ~= nil then
        Cake.Zones.RemoveZone(Name)
    end

    Center = vector3(Center.x, Center.y, Center.z)
    Cake.Zones.InZone[Name] = false

    if Param ~= nil then
        ZoneParams[Name] = Param
    else
        ZoneParams[Name] = nil
    end

    CurrentZones[Name] = CircleZone:Create(Center, Radius, Options)
end

Cake.Zones.AddBoxZone = function(Name, Center, Length, Width, Options, Param)
    if CurrentZones[Name] ~= nil then
        Cake.Zones.RemoveZone(Name)
    end

    Center = vector3(Center.x, Center.y, Center.z)
    Cake.Zones.InZone[Name] = false

    if Param ~= nil then
        ZoneParams[Name] = Param
    else
        ZoneParams[Name] = nil
    end

    CurrentZones[Name] = BoxZone:Create(Center, Length, Width, Options)
end

Cake.Zones.AddPolyZone = function(Name, Points, Options, Param)
    if CurrentZones[Name] ~= nil then
        Cake.Zones.RemoveZone(Name)
    end

    Cake.Zones.InZone[Name] = false

    if Param ~= nil then
        ZoneParams[Name] = Param
    else
        ZoneParams[Name] = nil
    end

    CurrentZones[Name] = PolyZone:Create(Points, Options)
end

Cake.Zones.RemoveZone = function(Name)
    if CurrentZones[Name] ~= nil then
        CurrentZones[Name]:destroy()
        CurrentZones[Name] = nil
        Cake.Zones.InZone[Name] = nil
        Cake.Zones.ZoneEvents[Name] = nil
    end
end

Cake.Zones.ClearAllZones = function()
    for k, v in pairs(CurrentZones) do
        Cake.Zones.RemoveZone(k)
    end

    CurrentZones = {}
    ZoneParams = {}
    Cake.Zones.InZone = {}
    Cake.Zones.ZoneEvents = {}
end

Cake.Zones.GetCurrentZone = function()
    for k, v in pairs(Cake.Zones.InZone) do
        return k
    end

    return nil
end

Cake.Zones.RegisterZoneEvent = function(Name, Event)
    Cake.Zones.ZoneEvents[Name] = Event
end

Cake.Zones.IsInZone = function(Name, Coords)
    if CurrentZones[Name] ~= nil then
        return CurrentZones[Name]:isPointInside(Coords) 
    end

    return false
end

AddEventHandler("prp-core:Zones:AddCircleZone", Cake.Zones.AddCircleZone)
AddEventHandler("prp-core:Zones:AddBoxZone", Cake.Zones.AddBoxZone)
AddEventHandler("prp-core:Zones:AddPolyZone", Cake.Zones.AddPolyZone)
AddEventHandler("prp-core:Zones:RemoveZone", Cake.Zones.RemoveZone)
AddEventHandler("prp-core:Zones:ClearAllZones", Cake.Zones.ClearAllZones)
AddEventHandler("prp-core:Zones:GetCurrentZone",function(Cb)
    Cb(Cake.Zones.GetCurrentZone)
end)
AddEventHandler("prp-core:Zones:RegisterZoneEvent", Cake.Zones.RegisterZoneEvent)

Cake.Log.Info("Zones", "Loaded")
