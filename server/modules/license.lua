local LicenseCache = {}

Cake.License = {}

Cake.License.Add = function(Source, Type)
    if Config.Licenses[Type] then
        local xPlayer = Cake.GetPlayerFromId(Source)
        local Result = MySQL.single.await('SELECT id FROM user_licenses WHERE owner = ? AND type = ?', {xPlayer.uuid, Type})

        if LicenseCache[Source] == nil then
            LicenseCache[Source] = {}
        end

        LicenseCache[Source][Type] = true

        if Result then
            return false
        else
            local Result = MySQL.insert.await('INSERT INTO user_licenses (owner, type) VALUES (?, ?)', {xPlayer.uuid, Type})

            return true
        end
    else
        return false
    end
end

Cake.License.Check = function(Source, Type)
    if Config.Licenses[Type] then
        if LicenseCache[Source] ~= nil and LicenseCache[Source][Type] ~= nil then
            return LicenseCache[Source][Type]
        end

        local xPlayer = Cake.GetPlayerFromId(Source)
        local Result = MySQL.single.await('SELECT id FROM user_licenses WHERE owner = ? AND type = ?', {xPlayer.uuid, Type})

        if Result then
            if LicenseCache[Source] == nil then
                LicenseCache[Source] = {}
            end

            LicenseCache[Source][Type] = true

            return LicenseCache[Source][Type]
        else
            return false
        end
    else
        return false
    end
end

Cake.License.Remove = function(Source, Type)
    if Config.Licenses[Type] then
        local xPlayer = Cake.GetPlayerFromId(Source)
        local Result = MySQL.single.await('SELECT id FROM user_licenses WHERE owner = ? AND type = ?', {xPlayer.uuid, Type})

        if LicenseCache[Source] ~= nil then
            LicenseCache[Source][Type] = nil
        end

        if Result then
            MySQL.update.await('DELETE FROM user_licenses WHERE owner = ? AND type = ?', {xPlayer.uuid, Type})

            return true
        else
            return false
        end
    else
        return false
    end
end

Cake.Net.RegisterServerCallback("prp-core:License:Add", Cake.License.Add)
Cake.Net.RegisterServerCallback("prp-core:License:Check", Cake.License.Check)
Cake.Net.RegisterServerCallback("prp-core:License:Remove", Cake.License.Remove)