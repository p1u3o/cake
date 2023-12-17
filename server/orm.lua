Cake.ORM.Accounts = CreateModel("account")
Cake.ORM.BanInfo = CreateModel("baninfo")
Cake.ORM.Vehicles = CreateModel("owned_vehicles")
Cake.ORM.Characters = CreateModel("users")
Cake.ORM.BoxingBoard = CreateModel("boxing_board")
Cake.ORM.Experience = CreateModel("experience")

Cake.ORM.Cad = {
    Impounds = CreateModel("granite_impounds")
}

Cake.ORM.Appearance = {
    Skin = CreateModel("character_face"),
    Clothes = CreateModel("character_current"),
    Tattoos = CreateModel("character_tattoos"),
    Outfits = CreateModel("character_outfits"),
    Codes = CreateModel("outfit_codes"),
}

Cake.ORM.Crews = CreateModel("crews")
Cake.ORM.CrewsMembers = CreateModel("crews_members")

Cake.ORM.Society = CreateModel("society")

-- Inventory
Cake.ORM.Inventory = CreateModel("inventory")
Cake.ORM.Weapons = CreateModel("inventory_weapons")