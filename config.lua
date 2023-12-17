Config                      = {}
Config.Locale               = 'en'

Config.Accounts             = { 'bank' }
Config.AccountLabels        = { bank = _U('bank') }

Config.EnableSocietyPayouts = true 

Config.DisableWantedLevel   = true

Config.PaycheckInterval     = 30 * 60000
Config.PaycheckMultiplier   = 2.0

--Config.MaxPlayers           = GetConvarInt('sv_maxclients', 255)

Config.EnableDebug          = false

Config.Throwables = {
    WEAPON_MOLOTOV = 615608432,
    WEAPON_GRENADE = -1813897027,
    WEAPON_STICKYBOMB = 741814745,
    WEAPON_PROXMINE = -1420407917,
    WEAPON_SMOKEGRENADE = -37975472,
    WEAPON_PIPEBOMB = -1169823560,
    WEAPON_SNOWBALL = 126349499,
    WEAPON_BZGAS = -1600701090,
    WEAPON_SMOKEGR = -225150656,
    WEAPON_FLASHBANG = -73270376
}

Config.Phonetics = {
    ['a'] = "alpha",
    ['b'] = "bravo",
    ['c'] = "charlie",
    ['d'] = "delta",
    ['e'] = "echo",
    ['f'] = "foxtrot",
    ['g'] = "golf",
	["0"] = "zero",
    ["1"] = "one",
    ["2"] = "two",
    ["3"] = "three",
    ["4"] = "four",
    ["5"] = "five",
    ["6"] = "six",
    ["7"] = "seven",
    ["8"] = "eight",
    ["9"] = "nine",
}

Config.EnablePVP = true

Config.DisableHealthRegen = true

Config.TeleportMessages = {
  "A spider a day keeps the rainbows away...",
  "Munching on some sausage rolls...",
  "Calculating the average radius of a dolphin...",
  "Do dogs dream in color or black and white?",
  "Sonic the Hedgehog’s full name is Ogilvie Maurice Hedgehog...",
  "Sometimes bees sting other bees",
  "Smoking is good for the environment...",
  "The purpose of a lock is to turn a door into a wall",
  "A snail can sleep for three years",
  "Peanuts are one of the ingredients of dynamite"
}

Config.Items = {}
Config.Items.Money = "money"
Config.Items.DirtyMoney = "black_money"

Config.Identifier = "discord" -- Identifier to use for account registration

-- These become accessible in the account object
Config.OtherIdentifiers = {
    "discord",
    "steam",
    "xbl",
    "live",
    "license",
    "ip"
}

Config.Society = {}
Config.Society.StartMoney = 100

Config.DefaultSpawn =  { x = 190.93, y = -884.31, z = 30.71 }

Config.AccountDefaults = {
    Group = "user"
}

-- Name => PowerLevel


--[[ 
0 = Nothing
1 = Errors
2 = Warnings
3 = Info
4 = Debug -]]

Config.LogLevel = 4

Config.DefaultStateBags = {
    ["isDead"] = false,
    ["isPointing"] = false,
    ["playerName"] = 'NULL',
    ["seatbelt"] = false,
    ["racingharness"] = false,
    ["hasAnkleTag"] = false,
    ['isCuffed'] = false,
}


-- Columns that the client can update
Config.ClientValueWhitelist = {"jail", "is_dead", "skellydata"}

Config.Death = {}
Config.Death.Animation = {
    Dict = "dead",
    Anims = {"dead_a", "dead_b", "dead_c", "dead_d"}
}



Config.UniversalIncome = 125

Config.NonLethal = 
{
    [`WEAPON_UNARMED`] = true,
}

Config.SystemMessages = 
{
    ["NoPermission"] = "You do not have permission to do this"
}