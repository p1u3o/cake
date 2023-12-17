Cake.Permissions = {}

Cake.Permissions.GetPermissionGroups = function()
    return spairs(Config.Groups, function(t,a,b) return t[b] > t[a] end)
end

Cake.Permissions.SetACE = function()
    local PreviousGroup = nil

    for k, v in Cake.Permissions.GetPermissionGroups() do
        if PreviousGroup ~= nil then
            ExecuteCommand('add_principal group.' .. k .. ' group.' .. PreviousGroup)
            Cake.Log.Debug('Permissions', 'add_principal group.' .. k .. ' group.' .. PreviousGroup)
        end

        PreviousGroup = k
    end
end

Cake.Permissions.SetGroup = function(Account, Identifier, Group, OldGroup)
    if Config.Groups[Group] ~= nil then
        ExecuteCommand('add_principal identifier.' .. Identifier .. " group." .. Group)
        Cake.Log.Debug('Permissions', 'add_principal identifier.' .. Identifier .. " group." .. Group)

        if Config.Groups[Group] > 0 then
            Account.setOp(true)
            Account.setPowerLevel(Config.Groups[Group])
        else
            Account.setOp(false)
            Account.setPowerLevel(0)
        end

        if OldGroup ~= nil and OldGroup ~= Group then
            ExecuteCommand('remove_principal identifier.' .. Identifier .. " group." .. OldGroup)
            Cake.Log.Debug('Permissions', 'remove_principal identifier.' .. Identifier .. " group." .. OldGroup)
        end
    end
end

Cake.Permissions.GetPowerForGroup = function(Name)
    if Config.Groups[Name] ~= nil then
        return Config.Groups[Name]
    end

    return 10000
end

Cake.Permissions.RestrictCommand = function(Command, Group)
    ExecuteCommand('add_ace command.' .. Command .. " group." .. Group .. " allow")
    Cake.Log.Debug('Permissions', 'add_ace command.' .. Command .. " group." .. Group .. " allow")
end

Cake.Permissions.AddCommand = function(Command, Permission, Function)
    Cake.Log.Info('Permissions', 'Registered /' .. Command)

    RegisterCommand(Command, function(Source, Args)
        if Cake.Permissions.HasPermission(Source, Permission) then
            Function(Source, Args)
        else
            Cake.Permissions.PermissionDenied(Source)
        end
    end)
end

Cake.Permissions.HasPermission = function(Source, Permission)
    local SourceAccount = Cake.Account.GetByPlayerId(Source)

    if SourceAccount then
        for k, v in pairs(Config.Groups) do
            if SourceAccount.PowerLevel >= v then
                if Config.Permissions[k] then
                    for ki, vi in pairs(Config.Permissions[k]) do
                        if vi == Permission then
                            return true
                        end
                    end
                end
            end
        end

        local xPlayer = Cake.Characters.GetByPlayerId(Source)

        if xPlayer then
            if Config.Jobs[xPlayer.job.name] and Config.Jobs[xPlayer.job.name].Permissions then
                for ki, vi in ipairs(Config.Jobs[xPlayer.job.name].Permissions) do
                    if vi == Permission then
                        return true
                    end
                end
            end
        end
    end

    return false
end

Cake.Permissions.CanTarget = function(Source, Target)
    local SourceAccount = Cake.Account.GetByPlayerId(Source)
    local TargetAccount = Cake.Account.GetByPlayerId(Target)

    if SourceAccount ~= nil and TargetAccount ~= nil then
        if SourceAccount.PowerLevel >= TargetAccount.PowerLevel then
            return true
        else
            return false
        end
    else
        return false
    end
end

Cake.Permissions.PermissionDenied = function(Source)
    if Source then
        TriggerClientEvent('prp-notify:client:SendAlert:custom', Source, { type = 'error', text = Config.SystemMessages["NoPermission"], length = 10000})
    end
end