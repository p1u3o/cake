Cake.Log = {}

Cake.Log.Debug = function(Module, Message)
    if Config.LogLevel >= 4 then
        print("[DEBUG] " .. Module .. ": ", Message)
    end
end

Cake.Log.Info = function(Module, Message)
    if Config.LogLevel >= 3 then
        print("[INFO] " .. Module .. ": ", Message)
    end
end

Cake.Log.Warn = function(Module, Message)
    if Config.LogLevel >= 2 then
        print("[WARN] " .. Module .. ": ", Message)
    end
end

Cake.Log.Error = function(Module, Message)
    if Config.LogLevel >= 1 then
        print("[ERROR] " .. Module .. ": ", Message)
    end
end