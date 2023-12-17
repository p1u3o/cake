Cake.XP.GetInfo = function(Skill)
    if Config.XP.Skills[Skill] then
        return Config.XP.Skills[Skill]
    else
        return nil
    end
end