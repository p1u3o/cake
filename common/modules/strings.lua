-- Example:
-- Remove unnecesary spaces
--[[
local str = '   this is a test   '
print( str:trim() ) -- prints: 'this is a test'
]]
function string:trim()
	local n = self:find"%S"
	return n and self:match(".*%S", n) or ""
end

-- Example:
--[[
local str = 'this is a test'
if str:startsWith('this') then
	-- returns true or false
	...
end
]]
function string:startsWith(start)
	return self:sub(1, #start) == start
end

-- Example:
--[[
local str = 'this is a test'
if str:endsWith('test') then
	-- returns true or false
	...
end
]]
function string:endsWith(ending)
	return ending == "" or self:sub(-#ending) == ending
end

-- THIS IS AN ITERATOR
-- Example:
--[[
local str = "hello world!"
for word in str:split() do
	print(word)
end
]]
-- Example returning table of words:
--[[
table.build(("hello world!"):split())
-- this returns a table {'hello', 'world!'}
table.build(("foo,bar,bee,bear"):split(','))
-- this returns {'foo','bar','bee','bear'}
]]
function string:split(pat)
	pat = pat or '%s+'
	local st, g = 1, self:gmatch("()("..pat..")")
	local function getter(segs, seps, sep, cap1, ...)
	st = sep and seps + #sep
	return self:sub(segs, (seps or 0) - 1), cap1 or sep, ...
	end
	return function() if st then return getter(st, g()) end end
end