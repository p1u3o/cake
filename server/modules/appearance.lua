Cake.Appearance.GetSkin = function(UUID, Callback)
    Cake.ORM.Appearance.Skin:FindOneBy("identifier", UUID, Callback)
end

Cake.Appearance.GetClothes = function(UUID, Callback)
    Cake.ORM.Appearance.Clothes:FindOneBy("identifier", UUID, Callback)
end

Cake.Appearance.GetTattoos = function(UUID, Callback)
    Cake.ORM.Appearance.Tattoos:FindOneBy("identifier", UUID, Callback)
end

Cake.Appearance.GetAll = function(UUID, Callback)
    local Data = {}

    Cake.Appearance.GetSkin(UUID, function(Result)
        Data.Skin = Result

        Cake.Appearance.GetClothes(UUID, function(Result)
            Data.Clothes = Result

            Cake.Appearance.GetTattoos(UUID, function(Result)
                Data.Tattoos = Result

                Callback(Data)
            end)
        end)
    end)
end