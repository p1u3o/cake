local Charset = {}

for i = 48,  57 do table.insert(Charset, string.char(i)) end
for i = 65,  90 do table.insert(Charset, string.char(i)) end
for i = 97, 122 do table.insert(Charset, string.char(i)) end

Cake.GetRandomString = function(length)
	math.randomseed(GetGameTimer())

	if length > 0 then
		return Cake.GetRandomString(length - 1) .. Charset[math.random(1, #Charset)]
	else
		return ''
	end
end

Cake.GetConfig = function()
	return Config
end

Cake.GetWeapon = function(weaponName)
	weaponName = string.upper(weaponName)
	local weapons = Cake.GetWeaponList()

	for i=1, #weapons, 1 do
		if weapons[i].name == weaponName then
			return i, weapons[i]
		end
	end
end

Cake.GetWeaponList = function()
	return Config.Weapons
end

Cake.GetTintsList = function()
	return Config.DefaultWeaponTints
end
Cake.GetWeaponLabel = function(weaponName)
	weaponName = string.upper(weaponName)
	local weapons = Cake.GetWeaponList()

	for i=1, #weapons, 1 do
		if weapons[i].name == weaponName then
			return weapons[i].label
		end
	end
end

Cake.GetWeaponComponent = function(weaponName, weaponComponent)
	weaponName = string.upper(weaponName)
	local weapons = Cake.GetWeaponList()

	for i=1, #weapons, 1 do
		if weapons[i].name == weaponName then
			for j=1, #weapons[i].components, 1 do
				if weapons[i].components[j].name == weaponComponent then
					return weapons[i].components[j]
				end
			end
			for c,v in pairs(weapons[i].tints) do
				if v == tint then
					return {name = 'v', label = v, hash = c}
				end
			end
		end
	end

end

Cake.GetWeaponTint = function(weaponName,tint)
	weaponName = string.upper(weaponName)
	local weapons = Cake.GetWeaponList()

	for i=1, #weapons, 1 do
		if weapons[i].name == weaponName then
			if weapons[i].tints then
				for c,v in pairs(weapons[i].tints) do
					if v == tint then
						return c
					end
				end
			else
				return nil
			end
		end
	end

	return nil
end

Cake.TableContainsValue = function(table, value)
	for k, v in pairs(table) do
		if v == value then
			return true
		end
	end

	return false
end

Cake.DumpTable = function(table, nb)
	if nb == nil then
		nb = 0
	end

	if type(table) == 'table' then
		local s = ''
		for i = 1, nb + 1, 1 do
			s = s .. "    "
		end

		s = '{\n'
		for k,v in pairs(table) do
			if type(k) ~= 'number' then k = '"'..k..'"' end
			for i = 1, nb, 1 do
				s = s .. "    "
			end
			s = s .. '['..k..'] = ' .. Cake.DumpTable(v, nb + 1) .. ',\n'
		end

		for i = 1, nb, 1 do
			s = s .. "    "
		end

		return s .. '}'
	else
		return tostring(table)
	end
end

Cake.Round = function(value, numDecimalPlaces)
	return Cake.Math.Round(value, numDecimalPlaces)
end