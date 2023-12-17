Cake.Modules = {}

Cake.Modules.Register = function(Name)
    Cake[Name] = {}
end

Cake.Modules.RegisterFunction = function(Module, Name, Function)
    Cake[Module][Name] = Function
end