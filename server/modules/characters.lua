Cake.Characters = {}

Cake.Characters.GetCharacters = function(Account, Cb)
    local MigratedJustNow = false

    --[[if Account.isMigrated() == 0 then
        -- Migrate older characters
        local Steam = GetPlayerIdentifierByType(Account.Source, "steam")

        if Steam ~= nil then
            MigratedJustNow = true
            MySQL.update.await('UPDATE users SET owner = ? WHERE identifier LIKE ? AND owner IS NULL', { Account.Id, '%' .. string.gsub(Steam, "steam", "")})
            
            local OnlineTime = MySQL.scalar.await('SELECT online_time FROM account_info WHERE steam64_hex = ?', {Steam})
            
            if OnlineTime ~= nil then
                Account.addOnlineTime(OnlineTime)
            end

            Account.setMigrated(1)
            Account.save(true)
        end
    end
    ]]

    MySQL.Async.fetchAll("SELECT * FROM users WHERE `owner` = @owner AND `firstname` != ''", {['@owner'] = Account.Id}, function(Result)
        Cb(Result, MigratedJustNow)
    end)
end

Cake.Characters.Lock = function(UUID)
    MySQL.update.await('UPDATE users SET deleted_at = ? WHERE `token` = ?', { 1, UUID })
end

Cake.Characters.Delete = function(UUID)
    MySQL.update.await('UPDATE users SET deleted_at = ? WHERE `token` = ?', { os.time(), UUID })
end

Cake.Characters.GetByPlayerId = function(PlayerId)
    return Cake.Players[tonumber(PlayerId)]
end

Cake.Characters.GetByUUID = function(UUID)
	if Cake.UUIDToSrcMap[UUID] ~= nil and Cake.Players[Cake.UUIDToSrcMap[UUID]] ~= nil then
		return Cake.Players[Cake.UUIDToSrcMap[UUID]]
	end

	for k,v in pairs(Cake.Players) do
		if v.uuid == UUID then
			Cake.UUIDToSrcMap[UUID] = tonumber(v.source)
			return v
		end
	end
end

Cake.Characters.GetAll = function()
    local Players = {}

	for k, v in pairs(Cake.Players) do
		table.insert(Players, v)
	end

	return Players
end

Cake.Characters.GetJob = function(Name)
    return Config.Jobs[Name]
end

Cake.GetPlayerFromId = Cake.Characters.GetByPlayerId
Cake.GetPlayerFromToken = Cake.Characters.GetByUUID
Cake.GetPlayerFromUUID = Cake.Characters.GetByUUID
Cake.GetCharacters = Cake.Characters.GetAll