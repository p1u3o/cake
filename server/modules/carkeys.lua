Cake.CarKeys = {}

CreateThread(function()
    Cake.CarKeys.Salt = Cake.GetRandomString(32)

    GlobalState.carKeySalt = Cake.CarKeys.Salt
end)