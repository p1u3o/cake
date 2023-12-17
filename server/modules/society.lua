Cake.Society.Loaded = false
Cake.Society.Accounts = {}

Cake.Society.Save = function(Force)
    for Name, Society in pairs(Cake.Society.Accounts) do
        Society.Save(Force)
    end
end

AddEventHandler("prp-core:ORM:Finished", function(EntityName)
    if EntityName == "society" then
        MySQL.Async.fetchAll('SELECT * FROM society', {}, function(Results)
            for i=1, #Results, 1 do
                Cake.Society.Accounts[Results[i].account_name] = Cake.Society.CreateAccount(Results[i].account_name, Results[i].money)
            end

            Cake.Society.Loaded = true
        end)
    end
end)

Cake.Society.GetAccount = function(name)
    if Cake.Society.Loaded then
        if Cake.Society.Accounts[name] == nil then
            MySQL.Sync.execute('INSERT INTO society (account_name, money, owner) VALUES (@account_name, @money, NULL)', {
                ['@account_name'] = name,
                ['@money']        = Config.Society.StartMoney
            })

            Cake.Society.Accounts[name] = Cake.Society.CreateAccount(name, Config.Society.StartMoney)
        end

        return Cake.Society.Accounts[name]
    else
        return nil
    end
end

AddEventHandler('prp-core:Society:GetAccount', function(name, cb)
	cb(Cake.Society.GetAccount(name))
end)