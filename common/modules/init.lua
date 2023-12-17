-- Initialise empty objects for modules

Cake.Society = {}
Cake.KvP = {}
Cake.Log = {}
Cake.Crypto = {}
Cake.Math = {}
Cake.License = {}
Cake.Net = {}
Cake.RPC = {}
Cake.UI = {}
Cake.KeyBindings = {}
Cake.CarKeys = {}
Cake.Death = {}
Cake.Inventory = {}
Cake.Zones = {}
Cake.Characters = {}
Cake.Permissions = {}
Cake.Logs = {}
Cake.AntiCheat = {}
Cake.Parties = {}
Cake.Discord = {}
Cake.XP = {}
Cake.Appearance = {}
Cake.Utils = {}
Cake.Upgrades = {}

CreateThread(function()
    Wait(5000)
    local Logo = LoadResourceFile(GetCurrentResourceName(), "config/logo.txt")

    for s in Logo:gmatch("[^\r\n]+") do
        print(s)
    end

    print("            Version: " .. GetResourceMetadata(GetCurrentResourceName(), "version"))
    print("")
end)