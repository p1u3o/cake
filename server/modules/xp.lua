local Cache = {}

Cake.XP = {}

Cake.XP.GetAllSkills = function(PlayerId)
    if Cache[PlayerId] then
        return Cache[PlayerId]
    end

    local xPlayer = Cake.GetPlayerFromId(PlayerId)

    if xPlayer then
        local Result = Cake.ORM.Experience:Limit(10):Where("uuid", xPlayer.uuid):FindAll()
        local Skills = {}

        for k, v in ipairs(Result) do
            if Config.XP.Skills[v.name] then
                Skills[v.name] = v.experience
            end
        end

        for k, v in pairs(Config.XP.Skills) do
            if not Skills[k] then
                Skills[k] = 0
            end
        end

        Cache[PlayerId] = Skills

        return Cache[PlayerId], xPlayer.uuid
    else
        return nil
    end
end

Cake.XP.GetSkill = function(PlayerId, Skill)
    if Config.XP.Skills[Skill] then
        if not Cache[PlayerId] then
            Cake.XP.GetAllSkills(PlayerId)
        end

        return Cache[PlayerId][Skill]
    end
    
    return nil
end

Cake.Net.RegisterServerCallback("prp-core:xp:GetAllSkills", function(Source)
    local RetreiveSkills = Cake.XP.GetAllSkills(Source)

    return RetreiveSkills
end)

Cake.XP.AddExperience = function(PlayerId, Skill, Experience)
    local Source = source
    local Skills, UUID = Cake.XP.GetAllSkills(PlayerId)

    if Skills then
        if Skills[Skill] then
            Skills[Skill] = Skills[Skill] + Experience

            Cake.XP.Save(PlayerId, Skills)
            return Skills[Skill]
        end
    else
        return nil
    end
end

RegisterNetEvent("prp-core:xp:AddXP", function(Skill, Experience)
    local Source = source
    Cake.XP.AddExperience(Source, Skill, Experience)
    TriggerClientEvent("prp-phone:Client:NewNotification", Source, "Skill Update", "You gained + "..Experience.." "..Skill.." xp", "#3dc91a", "fas fa-chart-line", 5000)
end)

Cake.XP.Save = function(PlayerId, NewSkills)
    local Skills, UUID = Cake.XP.GetAllSkills(PlayerId)

    if Skills then
        for k, v in pairs(Skills) do
            if Skills[k] ~= NewSkills[k] then
                Cake.XP.SaveSkill(PlayerId, UUID, k, NewSkills[k])
            end
        end
    end
end

Cake.XP.SaveSkill = function(PlayerId, UUID, Skill, Value)
    if Cache[PlayerId] and Cache[PlayerId][Skill] then
        Cache[PlayerId][Skill] = Value
    end

    Cake.ORM.Experience:FindOneBy({uuid = UUID, name = Skill}, function(Row)
        if not Row then
            Row = {uuid = UUID, name = Skill}
        end

        Row.experience = Value

        Cake.ORM.Experience:Save(Row)
    end)
end