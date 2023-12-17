Cake.Account = {}

Cake.Account.GetByPlayerId = function(Id)
    return Cake.Accounts[Id]
end

Cake.Account.Get = Cake.Database.GetAccount

Cake.Account.Register = Cake.Database.RegisterAccount

Cake.Account.Create = function(Source, Result, Identifier)
    local self = {}

    self.Source = Source

    self.Id = Result.id
    self.Name = Result.name
    self.Group = Result.group
    self.SavePending = false
    self.Op = false
    self.Migrated = Result.migrated
    self.Identifier = Identifier
    self.Identifiers = {}
    self.DiscordRoles = nil
    self.PowerLevel = 0
    self.OnlineTime = Result.online_time

    self.getSource = function()
        return self.Source
    end

    self.getId = function()
        return self.Id
    end

    self.getIdentifier = function(Specific)
        if Specific == nil then
            return self.Identifier
        else
            return self.Identifiers[Specific]
        end
    end

    self.getIdentifiers = function()
        return Identifiers
    end

    self.setGroup = function(Group)
        local OldGroup = self.Group

        self.Group = Group
        self.SavePending = true

        Cake.Permissions.SetGroup(self, self.Identifier, self.Group, OldGroup)
    end

    self.getGroup = function()
        return self.Group
    end

    self.setName = function(Name)
        self.Name = Group
        self.SavePending = true
    end

    self.getName = function()
        return self.Name
    end

    self.isOp = function()
        return self.Op
    end

    self.setOp = function(Value)
        self.Op = Value
    end

    self.isMigrated = function()
        return self.Migrated
    end

    self.setMigrated = function(Value)
        self.Migrated = Value
        self.SavePending = true
    end

    self.getCharacters = function(Cb)
        Cake.Characters.GetCharacters(self, function(Characters, IsMigrated)
            Cb(Characters, IsMigrated)
        end)
    end

    self.Save = function(Force, Cb)
        if self.SavePending or Force then
            MySQL.Async.execute('UPDATE account SET `name` = @name, `online_time` = @time, `group` = @group, `migrated` = @migrated WHERE id = @id', {
                ['@name']   = self.Name,
                ['@group']  = self.Group,
                ['@id']     = self.Id,
                ['@time'] = self.OnlineTime,
                ['@migrated'] = self.Migrated
            }, Cb)

            self.SavePending = false
        end
    end

    self.save = self.Save

    self.initialiseCharacter = function(UUID)
        Cake.ORM.Characters:FindOneBy({uuid = UUID, owner = self.Id}, function(Result)
            if Result then
                TriggerEvent("prp-core:LoadPlayer", self.Source, self, Result.id, false)
            end
        end)
    end

    self.newCharacter = function()
        local UUID = Cake.Math.GetUUID()
        local NewCharacter = {owner = self.Id, uuid = UUID, phone_number = math.random(100000, 999999)}

        for k, v in pairs(Config.Defaults.NewCharacter.Columns) do
            NewCharacter[k] = v
        end

        Cake.ORM.Characters:Save(NewCharacter, function(GenerateId)
            if NewCharacter then
                TriggerEvent("prp-core:LoadPlayer", self.Source, self, GenerateId, true)
            else
                self.newCharacter()
            end
        end, true)
    end

    self.deleteCharacter = function(UUID, Callback)
        Cake.ORM.Characters:FindOneBy({uuid = UUID, owner = self.Id}, function(Result)
            if Result then
                Cake.Characters.Delete(UUID)

                Callback(Result)
            end
        end)
    end

    self.getDiscordRoles = function(ClearCache)
        if ClearCache or self.DiscordRoles == nil then
            self.DiscordRoles = Cake.Discord.GetRoles(self.Source)

            return self.DiscordRoles
        else
            return self.DiscordRoles
        end 
    end

    self.getPowerLevel = function()
        return self.PowerLevel
    end

    self.setPowerLevel = function(PowerLevel)
        self.PowerLevel = PowerLevel
    end

    self.addOnlineTime = function(Value)
        self.OnlineTime = self.OnlineTime + Value
    end

    self.getOnlineTime = function()
        return self.OnlineTime
    end

    Cake.Permissions.SetGroup(self, self.Identifier, self.Group)

    for k, v in ipairs(Config.OtherIdentifiers) do
        self.Identifiers[v] = GetPlayerIdentifierByType(Source, v)
    end

    -- Save the account to update last_connected
    self.save(true)

    return self
end

RegisterNetEvent("prp-core:Account:IncreasePlayTime", function(Time)
    local Source = source

    if Cake.Accounts[Source] ~= nil then
        if Time ~= 30 then
            Cake.AntiCheat.Ban(Source, "Account", "Sent an invalid online time increment")
        else
            Cake.Accounts[Source].addOnlineTime(Time)
        end
    end
end)