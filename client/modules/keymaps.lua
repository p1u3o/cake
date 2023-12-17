local KeyBindsEnabled = true

Cake.KeyBindings.RegisterKeyMapping = function(Command, Name, ControlGroup, Control)
    RegisterKeyMapping(Command, Name, ControlGroup, Control)
end

Cake.KeyBindings.RegisterKeyCommand = function(Name, Function)
    RegisterCommand(Name, function()
        if KeyBindsEnabled then
            Function()
        end
    end)
end

Cake.KeyBindings.RegisterCommand = Cake.KeyBindings.RegisterKeyCommand

Cake.KeyBindings.AreKeysEnabled = function()
    return KeyBindsEnabled
end

Cake.KeyBindings.EnableKeybinds = function(Value)
    KeyBindsEnabled = Value
end

AddEventHandler("prp-core:KeyBindings:RegisterKeyMapping", Cake.KeyBindings.RegisterKeyMapping)
AddEventHandler("prp-core:KeyBindings:RegisterKeyCommand", Cake.KeyBindings.RegisterKeyCommand)
AddEventHandler("prp-core:KeyBindings:RegisterCommand", Cake.KeyBindings.RegisterKeyCommand)
AddEventHandler("prp-core:KeyBindings:AreKeysEnabled", function(Cb)
    Cb(Cake.KeyBindings.AreKeysEnabled())
end)
AddEventHandler("prp-core:KeyBindings:EnableKeybinds", Cake.KeyBindings.EnableKeybinds)

Cake.Log.Info("Keymaps", "Loaded")
