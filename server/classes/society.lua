Cake.Society.CreateAccount = function(name, money)
	local self = {}

	self.name  = name
	self.money = money
    self.changed = false

	self.addMoney = function(m)
		self.money = self.money + m

        self.changed = true
	end

	self.removeMoney = function(m)
		self.money = self.money - m

        self.changed = true
	end

	self.setMoney = function(m)
		self.money = m

        self.changed = true
	end

	self.Save = function(Force)
        if self.changed or Force then
            MySQL.Async.execute('UPDATE society SET money = @money WHERE account_name = @account_name', {
                ['@account_name'] = self.name,
                ['@money']        = self.money
            })

            self.changed = false
        end
	end

	return self
end