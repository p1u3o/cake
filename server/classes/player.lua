Cake.Player = {}

Cake.Player.Create = function(Id, Source, Account, UserData)
	local self = {}

	self.id           = Id
	self.account      = Account
	self.inventory    = UserData.inventory
	self.job          = UserData.job
	self.name         = Account.getName()

	if UserData.lastPosition ~= nil then
		self.lastPosition = UserData.lastPosition
	else
		self.lastPosition = Config.DefaultSpawn
	end

	self.completename = UserData.completename
	self.firstname = UserData.firstname
	self.lastname = UserData.lastname

	self.bank       = UserData.bank
	self.phone      = UserData.phoneNumber
	self.source     = Source
	self.identifier = Account.getIdentifier()

	self.uuid       = UserData.uuid
	self.token      = UserData.uuid
	self.character  = UserData.uuid

	self.dob        = UserData.dob
	self.height     = UserData.height
	self.sex        = UserData.sex
	self.dead       = UserData.dead

	self.inventoryLoaded = false
	self.inventoryLoading = false

	self.getMoney = function()
		return self.getInventoryItemTotal(Config.Items.Money).count
	end

	self.getDirtyMoney = function()
		return self.getInventoryItemTotal(Config.Items.DirtyMoney).count
	end

	self.setBankBalance = function(money)
		money = Cake.Math.Round(money)

		if money >= 0 then
			self.bank = money
		else
			print(('prp-core: %s attempted exploiting! (reason: player tried setting -1 bank balance)'):format(self.identifier))
		end
	end

	self.getBank = function()
		return self.bank
	end

	self.getCoords = function(vector)		
		if vector then
			return vector3(self.lastPosition.x, self.lastPosition.y, self.lastPosition.z)
		else
			return self.lastPosition
		end
	end

	self.setCoords = function(pos)
		if pos ~= nil then
			self.setLastPosition({x = pos.x, y = pos.y, z = pos.z})
			TriggerClientEvent('prp-core:Functions:SetPos', self.source, pos)
		end
	end

	self.kick = function(reason)
		DropPlayer(self.source, reason)
	end

	self.addMoney = function(money)
		money = Cake.Math.Round(money)

		if money >= 0 then
			self.addInventoryItem(Config.Items.Money, money)
		else
			print(('prp-core: %s attempted exploiting! (reason: player tried adding -1 cash balance)'):format(self.identifier))
		end
	end

	self.removeMoney = function(money)
		money = Cake.Math.Round(money)

		if money >= 0 then
			self.removeInventoryItem(Config.Items.Money,money)
		else
			print(('prp-core: %s attempted exploiting! (reason: player tried removing -1 cash balance)'):format(self.identifier))
		end
	end

	self.addBank = function(money)
		money = Cake.Math.Round(money)

		if money >= 0 then
			local newBank = self.bank + money

			self.bank = newBank
		else
			print(('prp-core: %s attempted exploiting! (reason: player tried adding -1 bank balance)'):format(self.identifier))
		end
	end

	self.removeBank = function(money)
		money = Cake.Math.Round(money)

		if money >= 0 then
			local newBank = self.bank - money

			self.bank = newBank
		else
			print(('prp-core: %s attempted exploiting! (reason: player tried removing -1 bank balance)'):format(self.identifier))
		end
	end

	self.getPermissions = self.account.isOp

	self.getPowerLevel = self.account.getPowerLevel

	self.get = function(Key)
		if Key == "permission_level" then
			return self.account.isOp()
		end
	end

	self.set = function(Key, Value)
		if Key == "permission_level" then
			self.account.setOp(Value)
			self.account.save()
		end
	end

	self.setPermissions = function(Value)
		self.account.setOp(Value)
	end

	self.getIdentifier = self.account.getIdentifier

	self.getGroup = self.account.getGroup

	self.setGroup = function(Group)
		self.account.setGroup(Group)
		self.account.save()
	end

	self.getPlayer = function()
		return self.account
	end
	
	self.getAccounts = function()
		local accounts = {}

		for i=1, #Config.Accounts, 1 do
			if Config.Accounts[i] == 'bank' then

				table.insert(accounts, {
					name  = 'bank',
					money = self.bank,
					label = Config.AccountLabels['bank']
				})

			end
		end

		return accounts
	end

	self.getAccount = function(a)
		if a == 'bank' then
			return {
				name  = 'bank',
				money = self.bank,
				label = Config.AccountLabels['bank']
			}
		end

		if a == 'black_money' then
			return {
				{
					name  = 'black_money',
					money = self.getInventoryItemTotal('black_money').count,
					label = Config.AccountLabels['black_money']
				}
			}
		end
	end

	self.getInventory = function()
		if not self.inventoryLoaded then
			if not self.inventoryLoading then
				self.inventoryLoading = true

				Citizen.CreateThread( function()
					exports['prp-inventory']:getInventory(self.token, 'player', function(Results)		
						self.inventoryLoaded = true
						self.inventoryLoading = false
					end)
				end)
			end
			
			return {}
		else
			local Request = promise.new()	

			exports['prp-inventory']:getInventory(self.token, 'player', function(Inventory)
				Request:resolve(Inventory)
			end)

			return Citizen.Await(Request)
		end
	end

	self.getJob = function()
		return self.job
	end

	self.getName = function()
		return self.name
	end

	self.setName = function(newName)
		self.name = newName
	end

	self.getLastPosition = function()
		if self.lastPosition and self.lastPosition.x and self.lastPosition.y and self.lastPosition.z then
			self.lastPosition.x = Cake.Math.Round(self.lastPosition.x, 1)
			self.lastPosition.y = Cake.Math.Round(self.lastPosition.y, 1)
			self.lastPosition.z = Cake.Math.Round(self.lastPosition.z, 1)
		end
		
		return self.lastPosition
	end

	self.setLastPosition = function(position)
		if position ~= nil then
			self.lastPosition = position
		end
	end

	self.setAccountMoney = function(acc, money)
		if money < 0 then
			print(('prp-core: %s attempted exploiting! (reason: player tried setting -1 account balance)'):format(self.identifier))
			return
		end

		local account   = self.getAccount(acc)
		local prevMoney = account.money
		local newMoney  = Cake.Math.Round(money)

		account.money = newMoney

		if acc == 'bank' then
			self.bank = newMoney
		end
	end

	self.addAccountMoney = function(acc, money)
		if money < 0 then
			print(('prp-core: %s attempted exploiting! (reason: player tried adding -1 account balance)'):format(self.identifier))
			return
		end
		if acc == 'black_money' then
			TriggerClientEvent('prp-notify:client:SendAlert', self.source, { type = 'info', text = 'Has recibido $'..money.." Dinero Sucio", length = 3000})
			self.addInventoryItem('black_money',money)
			local account  = self.getAccount(acc)
			return
		elseif acc == 'Ecoin' then
			TriggerClientEvent('prp-notify:client:SendAlert', self.source, { type = 'info', text = 'Has recibido $'..money.." Ecoins", length = 3000})
		end

		local account  = self.getAccount(acc)
		local newMoney = account.money + Cake.Math.Round(money)

		account.money = newMoney

		if acc == 'bank' then
			self.bank = newMoney
		end
	end

	self.removeAccountMoney = function(a, m)
		if m < 0 then
			print(('prp-core: %s attempted exploiting! (reason: player tried removing -1 account balance)'):format(self.identifier))
			return
		end

		local account  = self.getAccount(a)
		local newMoney = account.money - m

		account.money = newMoney

		if a == 'bank' then
			self.bank = newMoney
		elseif a == 'black_money' then
			self.removeInventoryItem("black_money",m)
		end
	end

	self.getCompleteName = function ()
		return self.completename
	end

	self.getPhone = function ()
		return self.phone
	end

	self.setPhone = function (number)
		self.phone = number

		MySQL.Async.execute('UPDATE users SET `phone_number` = @number WHERE id = @id', {
			['@number']     = self.phone,
			['@identifier'] = self.id
		})
	end

	self.setCompleteName = function (first, last)
		self.firstname = first:trim()
		self.lastname = last:trim()
		self.completename = first .. " " .. last

		MySQL.Async.execute('UPDATE users SET `firstname` = @first, `lastname` = @last WHERE id = @id', {
			['@first'] = self.firstname,
			['@last']  = self.lastname,
			['@id']    = self.id
		})
	end

	self.getDob = function ()
		return self.dob
	end

	self.setDob = function (dob)
		self.dob = dob

		MySQL.Async.execute('UPDATE users SET `dateofbirth` = @dob WHERE id = @id', {
			['@dob'] = self.dob,
			['@id']  = self.id
		})
	end

	self.setHeight = function (height)
		self.height = height

		MySQL.Async.execute('UPDATE users SET `height`= @height WHERE id = @id', {
			['@height'] = self.height,
			['@id']     = self.id
		})
	end

	self.setSex = function (sex)
		self.sex = sex

		MySQL.Async.execute('UPDATE users SET `sex` = @sex WHERE id = @id', {
			['@sex'] = self.sex,
			['@id']  = self.id
		})
	end

	self.getInventoryItem = function(name,slot)

		local inventory = self.getInventory()
		if inventory then
			for c,v in pairs(inventory) do
				if slot then
					if c == slot then
						v.limit = -1
						v.slot = c
						--v.label = exports['prp-inventory']:itemLabel(name)
						return v
					end
				else
					if v.name == name then
						v.limit = -1
						v.slot = c
						--v.label = exports['prp-inventory']:itemLabel(name)
						return v
					end
				end
			end
		end
		
		local itemdata = {
			name = name,
			--label = exports['prp-inventory']:itemLabel(name),
			count = 0,
			slot = nil,
			limit = -1,
		}

		return itemdata
	end

	self.getInventoryItemTotal = function(name)
		local inventory = self.getInventory()
		
		if inventory then
			local itemSend = nil
			for c,v in pairs(inventory) do
				if v.name == name then
					if itemSend == nil then
						--v.label = exports['prp-inventory']:itemLabel(name)
						itemSend = v
					else
						itemSend.count = itemSend.count + v.count
					end
				end
			end
			if itemSend ~= nil then
				return itemSend
			end
		end
		
		local itemdata = {
			name = name,
			count = 0,
			--label = exports['prp-inventory']:itemLabel(name),
		}

		return itemdata
	end


	self.getInventoryItemTotalMulti = function(items)

		local inventory = self.getInventory()

		local itemsFormatted = {}

		for k, v in ipairs(items) do
			itemsFormatted[v] = 0
		end

		if inventory then
			local itemSend = nil
			for c,v in pairs(inventory) do
				if itemsFormatted[v.name] ~= nil then
					itemsFormatted[v.name] = itemsFormatted[v.name] + v.count
				end
			end
		end
		
		return itemsFormatted
	end

	self.isWeapon = function(name)
		return string.find(name, 'WEAPON_') ~= nil
	end

	self.addInventoryItem = function(name, count, metadata)
		if count ~= nil and count > 0 then
			if self.isWeapon(string.upper(name)) then
				if exports['prp-inventory']:getItem(string.upper(name)).nonStack == true then
					metadata["owner"] = "Unregistered"
					self.addWeapon(string.upper(name), count, metadata)
				else
					TriggerEvent('prp-inventory:AddInventoryItem', self.source, name, count, metadata)
				end
			else
				TriggerEvent('prp-inventory:AddInventoryItem', self.source, name, count, metadata)
			end
		end
	end

	self.updateMetadata = function(slot, metadata, cb)
		TriggerEvent('prp-inventory:updateMetadata', slot, metadata, self.source, cb)
	end

	self.removeInventoryItem = function(name, count, slot)
		TriggerEvent('prp-inventory:RemoveInventoryItem', name, count, slot, self.source)
	end

	self.setJob = function(job, grade)
		grade = tostring(grade)
		local lastJob = json.decode(json.encode(self.job))

		if Cake.DoesJobExist(job, grade) then
			local jobObject, gradeObject = Cake.Jobs[job], Cake.Jobs[job].grades[grade]

			self.job.id    = jobObject.id
			self.job.name  = jobObject.name
			self.job.label = jobObject.label

			self.job.grade        = tonumber(grade)
			self.job.grade_name   = gradeObject.name
			self.job.grade_label  = gradeObject.label
			self.job.grade_salary = gradeObject.salary

			TriggerEvent('prp-core:Session:JobChange', self.source, self.job, lastJob)
			TriggerClientEvent('prp-core:Session:JobChange', self.source, self.job)
		else
			print(('prp-core: ignoring setJob for %s due to job not found!'):format(self.source))
		end
	end

	self.addWeapon = function(weaponName, ammo, metadata, dontRegister)
		local Throwables = {
			WEAPON_MOLOTOV = false,
			WEAPON_GRENADE = true,
			WEAPON_STICKYBOMB = true,
			WEAPON_PROXMINE = true,
			WEAPON_SMOKEGRENADE = true,
			WEAPON_PIPEBOMB = true,
			WEAPON_SNOWBALL = true,
			WEAPON_BZGAS = true,
			WEAPON_FLASHBANG = true,
		}

		if Throwables[weaponName] then 
			TriggerEvent('prp-inventory:AddInventoryItem', self.source, weaponName, 1, metadata)
		else
			metadata = metadata or {}

			metadata.owner  = self.getUUID()
			metadata.serial = Cake.Math.GetRandomHex(10):upper()
			metadata.date   = os.time()
			metadata.components = metadata.components or {}
			metadata.quality = metadata.quality or 100
			metadata.ammo = ammo or 0
			metadata.registered = 0

			if not dontRegister then
            	MySQL.insert('INSERT INTO inventory_weapons (`serial`, `owner`, `name`, `weapon`, `date`, `source`, `registered`) VALUES (?, ?, ?, ?, ?, ?, ?)', {metadata.serial, metadata.owner, exports['prp-inventory']:itemLabel(weaponName), weaponName, metadata.date, "resource:" .. GetInvokingResource(), 0}, function(Result)
				if Result then
					TriggerEvent('prp-inventory:AddInventoryItem', self.source, weaponName, 1, metadata)
					end
				end)
			else
				TriggerEvent('prp-inventory:AddInventoryItem', self.source, weaponName, 1, metadata)
			end
		end
	end

	self.addWeaponComponent = function(weaponName, weaponComponent, slot)
		local item = self.getInventoryItem(weaponName, tostring(slot))

		if not item.slot then
			return
		end

		local component = Cake.GetWeaponComponent(weaponName, weaponComponent)
		local tint = tonumber(component.hash) < 10 and tonumber(component.hash) > 0 and true or false

		if not component and not tint then
			return
		end

		if self.hasWeaponComponent(item.metadata, weaponComponent) then
			return
		end

		if self.checkAlreadyComponent(item.metadata, weaponComponent) then
			return
		end

		if tint then
			local tinteano = self.hasWeaponTint(item.metadata)
			if tinteano then
				table.remove(item.metadata.components, tinteano)
			end
			table.insert(item.metadata.components, tint)
			TriggerClientEvent('esx:setWeaponTint', self.source, weaponName, component.hash)
		else
			table.insert(item.metadata.components, component)
			TriggerClientEvent('esx:addWeaponComponent', self.source, weaponName, weaponComponent)
		end

		local Response = false

		self.updateMetadata(item.slot, item.metadata, function()
			Response = true
		end)

		while Response == false do
			Citizen.Wait(100)
		end

		local item = self.getInventoryItem(weaponName, tostring(slot))

		if self.hasWeaponComponent(item.metadata, weaponComponent) then
			return true
		end

		return false
	end

	self.hasWeaponTint = function(metadata)
		local tints = Cake.GetTintsList()

		for i=1, #metadata.components, 1 do
			for c,v in pairs(tints) do
				if metadata.components[i].name == v then
					return metadata.components[i].name
				end
			end
		end

		return false
	end

	self.removeWeaponComponent = function(weaponName, weaponComponent, slot)
		local item     = self.getInventoryItem(weaponName,  tostring(slot))

		if not item.slot then
			return
		end

		local component = Cake.GetWeaponComponent(weaponName, weaponComponent)
		local tint = tonumber(component.hash) < 10 and tonumber(component.hash) > 0 and true or false

		if not component and not tint then
			return
		end

		for i=1, #item.metadata.components, 1 do
			if item.metadata.components[i].name == weaponComponent then
				table.remove(item.metadata.components, i)
				break
			end
		end

		if tint then
			TriggerClientEvent('esx:setWeaponTint', self.source,weaponName, component.hash)
		else
			self.addInventoryItem(weaponComponent,1)
			TriggerClientEvent('esx:removeWeaponComponent', self.source, weaponName, weaponComponent)
		end
		self.updateMetadata(item.slot,item.metadata)
	end

	self.removeWeapon = function(weaponName, ammo, slot)
		local item = self.getInventoryItem(weaponName,slot)
		if item.slot then
			self.removeInventoryItem(item.name,item.count,item.slot)
		end
	end
	
	self.checkAlreadyComponent = function(metadata, weaponComponent)
		for i=1, #metadata.components, 1 do
			if weaponComponent == "clip_extended" or weaponComponent == "clip_drum" or weaponComponent == "clip_box" then
				if string.match(metadata.components[i].name, "clip_") then
					TriggerClientEvent('prp-notify:client:SendAlert', self.source, { type = 'info', text = 'You must remove the existing clip first!', length = 4000})
					return true
				end
			elseif weaponComponent == "flashlight" then
				if metadata.components[i].name == "grip" then
					TriggerClientEvent('prp-notify:client:SendAlert', self.source, { type = 'info', text = 'You must remove your grip first!', length = 4000})
					return true
				end
			elseif weaponComponent == "grip" then
				if metadata.components[i].name == "flashlight" then
					TriggerClientEvent('prp-notify:client:SendAlert', self.source, { type = 'info', text = 'You must remove your flashlight first!', length = 4000})
					return true
				end
			end
		end

		return false
	end

	self.hasWeaponComponent = function(metadata, weaponComponent)

		for i=1, #metadata.components, 1 do
			if metadata.components[i].name == weaponComponent then
				return true
			end
		end

		return false
	end

	self.getDnaSequence = function()
		if self.token ~= nil then
			local sequence = 
			{
				Config.Phonetics[self.token:sub(16, 16)],
				Config.Phonetics[self.token:sub(12, 12)],
				Config.Phonetics[self.token:sub(13, 13)],
				Config.Phonetics[self.token:sub(10, 10)],
				Config.Phonetics[self.token:sub(14, 14)],
				Config.Phonetics[self.token:sub(15, 15)],
				Config.Phonetics[self.token:sub(17, 17)],
				Config.Phonetics[self.token:sub(1, 1)]
			}

			--return table.concat(sequence, "-")
			return sequence
		end

		return "invalid-sample"
	end

	self.getDnaRaw = function()
		if self.token ~= nil then
			local sequence = 
			{
				self.token:sub(16, 16),
				self.token:sub(12, 12),
				self.token:sub(13, 13),
				self.token:sub(10, 10),
				self.token:sub(14, 14),
				self.token:sub(15, 15),
				self.token:sub(17, 17),
				self.token:sub(1, 1)
			}

			--return table.concat(sequence, "-")
			return sequence
		end

		return false
	end

	self.setDead = function(value)
		if value then
			self.dead = 1
		else
			self.dead = 0
		end

		MySQL.Async.execute('UPDATE users SET `is_dead` = @dead WHERE id = @id', {
			['@dead'] = self.dead,
			['@id'] = self.id
		})
	end

	self.isDead = function()
		return self.dead == 1
	end

	self.getUUID = function()
		return self.uuid
	end

	return self
end