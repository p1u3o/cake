local Hexset = {}

for i = 97, 102 do table.insert(Hexset, string.char(i)) end
for i = 48,  57 do table.insert(Hexset, string.char(i)) end

Cake.Math.Round = function(value, numDecimalPlaces)
	return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", value))
end

-- credit http://richard.warburton.it
Cake.Math.GroupDigits = function(value)
	local left,num,right = string.match(value,'^([^%d]*%d)(%d*)(.-)$')

	return left..(num:reverse():gsub('(%d%d%d)','%1' .. _U('locale_digit_grouping_symbol')):reverse())..right
end

Cake.Math.Trim = function(value)
	if value then
		return (string.gsub(value, "^%s*(.-)%s*$", "%1"))
	else
		return nil
	end
end

Cake.Math.Comma = function(amount)
	local formatted = amount
	while true do  
	  formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
	  if (k==0) then
		break
	  end
	end
	return formatted
end

Cake.Math.Format = function(amount, decimal, prefix, neg_prefix)
	local str_amount,  formatted, famount, remain
  
	decimal = decimal or 2  -- default 2 decimal places
	neg_prefix = neg_prefix or "-" -- default negative sign
  
	famount = math.abs(Cake.Math.Round(amount,decimal))
	famount = math.floor(famount)
  
	remain = Cake.Math.Round(math.abs(amount) - famount, decimal)
  
		  -- comma to separate the thousands
	formatted = Cake.Math.Comma(famount)
  
		  -- attach the decimal portion
	if (decimal > 0) then
	  remain = string.sub(tostring(remain),3)
	  formatted = formatted .. "." .. remain ..
				  string.rep("0", decimal - string.len(remain))
	end
  
		  -- attach prefix string e.g '$' 
	formatted = (prefix or "") .. formatted 
  
		  -- if value is negative then format accordingly
	if (amount<0) then
	  if (neg_prefix=="()") then
		formatted = "("..formatted ..")"
	  else
		formatted = neg_prefix .. formatted 
	  end
	end
  
	return formatted
end

Cake.Math.GetRandomHex = function(length)
	math.randomseed(GetGameTimer())

	if length > 0 then
		return Cake.Math.GetRandomHex(length - 1) .. Hexset[math.random(1, #Hexset)]
	else
		return ''
	end
end

Cake.Math.GetUUID = function()
	math.randomseed(GetGameTimer())

	local Template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'

    return string.gsub(Template, '[xy]', function (c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
end

-- Add to the maths library
math.round = Cake.Math.Round

Cake.Log.Info("Math", "Loaded")
