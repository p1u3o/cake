Cake.Crews = {}

Cake.Crews.List = {}
Cake.Crews.Members = {}

Cake.Crews.LoadCrewList = function()
    local Results = Cake.ORM.CrewsMembers:Columns({"crew"}):GroupBy('crew'):FindAll()
    local Count = 0
    local Crews = {}

    for k, v in pairs(Results) do
        Count = Count + 1
        table.insert(Cake.Crews.List, v.crew)
    end

    Cake.Crews.List = Crews

    Cake.Log.Debug('Crews', 'Loaded ' .. tostring(Count) .. ' Crews')
end

Cake.Crews.IsValidCrew = function(Name)
    for k, v in ipairs(Cake.Crews.List) do
        if v == Name then
            return true
        end
    end

    return false
end

Cake.Crews.SetActiveCrew = function(UUID, Name)
    Cake.Crews.GetPlayersCrews(UUID)
    
    for k, v in ipairs(Cake.Crews.Members[UUID]) do
        if Cake.Crews.Members[UUID][k].crew == Name then
            Cake.Crews.Members[UUID][k].is_active = true 
        else
            Cake.Crews.Members[UUID][k].is_active = false 
        end
    end

    Cake.Crews.SaveCrews(UUID)
end

Cake.Crews.GetPlayersCrews = function(UUID)
    if Cake.Crews.Members[UUID] then
        return Cake.Crews.Members[UUID]
    else
        local Results = Cake.ORM.CrewsMembers:Where("uuid", UUID):FindAll()
        local Crews = {}

        for k, v in ipairs(Results) do
            Crews[v.crew] = {
                crew = v.crew,
                id = v.id,
                grade = v.grade,
                is_active = v.is_active
            }
        end

        Cake.Crews.Members[UUID] = Crews

        return Cake.Crews.Members[UUID]
    end
end

Cake.Crews.SaveCrews = function(UUID)
    for k, v in ipairs(Cake.Crews.Members[UUID]) do
        Cake.ORM.CrewsMembers:Save(v)
    end
end

Cake.Crews.GetCrewMembers = function(Name)
    if Cake.Crews.Members[Name] ~= nil then
        return Cake.Crews.Members[Name] 
    else
        local Results = MySQL.query.await('SELECT crew.*, firstname, lastname FROM crew LEFT JOIN users ON crew.identifier = users.token WHERE crew.name = ?', {Name})
        
        Cake.Crews.Members[Name] = Results
    end
end

CreateThread(function()
    Cake.Crews.LoadCrewList()
end)

