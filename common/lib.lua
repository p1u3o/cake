-- This file is to make the framework modules loadable somewhat independently
-- It's never loaded as part of the framework

local Cake = {}

function getCake()
    return Cake
end