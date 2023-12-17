Cake.Database = {}

Cake.Database.GetAccount = function(Identifier, Cb)
    MySQL.Async.fetchSingle('SELECT * FROM `account` WHERE `identifier` = @identifier', {
        ['@identifier'] = Identifier
    }, function(Result)
        if Result ~= nil then
            Cb(true, Result)
        else
            Cb(false, nil)
        end
    end)
end

Cake.Database.RegisterAccount = function(Source, Identifier, Cb)
    MySQL.Async.insert('INSERT INTO `account` (`identifier`, `name`, `group`) VALUES (@identifier, @name, @group)', {
        ['@identifier'] = Identifier,
        ['@name'] = GetPlayerName(Source),
        ['@group'] = Config.AccountDefaults.Group
    }, function(Result)
        if Result ~= nil then
            Cake.Database.GetAccount(Identifier, function(IsRegistered, Result)
                Cb(Result)
            end)
        end
    end)
end

Cake.Database.GetCharacters = function(Identifier, Cb)

end