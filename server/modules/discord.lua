Cake.Discord.GetStatus = function()
    return MaxPlayers, Players, Queue
end

Cake.Discord.Status = { 
    MaxPlayers = GetConvarInt("sv_maxclients", 128), 
    Players = 0, 
    Queue = 0 
}

Cake.Discord.WatchPlayers = function()
    Cake.Discord.Status.MaxPlayers = GetConvarInt("sv_maxclients", 128)

    while true do
        Cake.Discord.Status.Players = #GetPlayers()
        Cake.Discord.Status.Queue = GetConvar("QueueSize", "0")
        Cake.Discord.Status.MaxPlayers = GetConvarInt("sv_maxclients", 128)

        TriggerLatentClientEvent("prp-core:Discord:PlayerUpdate", -1, 100000, Cake.Discord.Status)

        Wait(60000)
    end
end

local RoleCache = {}
local IdCache = {}

Cake.Discord.GetRoles = function(Id, GuildId, IgnoreCache)
    if not GuildId then
        GuildId = Config.Discord.GuildId
    end

    if RoleCache[Id] ~= nil and not IgnoreCache then
        return RoleCache[Id]
    end

    local DiscordId = Cake.Discord.GetDiscordId(Id, IgnoreCache)

    if DiscordId ~= nil then
        DiscordId = DiscordId:gsub("discord:", "")

        local Member = Cake.Discord.Request("GET", ("guilds/%s/members/%s"):format(GuildId, DiscordId), {})

        if Member.Code == 200 then
            local MemberData = json.decode(Member.Response)
            RoleCache[Id] = MemberData.roles
            
            return RoleCache[Id]
        else

            return {}
        end
    else
        return {}
    end
end

Cake.Discord.GetDiscordId = function(Id, IgnoreCache)
    if IdCache[Id] == nil or IgnoreCache then
        IdCache[Id] = GetPlayerIdentifierByType(Id, "discord")
    end

    return IdCache[Id]
end

Cake.Discord.HasDiscordRole = function(Id, Role)
    if Config.Discord.Roles[Role] ~= nil then
        local Roles = Cake.Discord.GetRoles(Id)

        for k, v in ipairs(Roles) do
            if v == Config.Discord.Roles[Role] or v == Role then
                return true
            end
        end
    end

    return false
end

local FormattedToken = "Bot " .. Config.Discord.Token

Cake.Discord.Request = function(Method, EndPoint, Payload)
    local Promise = promise.new()

    PerformHttpRequest(Config.Discord.API .. EndPoint, function(Code, Response, Headers)
		Data = { 
            Response = Response, 
            Code = Code, 
            Headers = Headers
        }

        Promise:resolve(Data)
    end, Method, #Payload > 0 and json.encode(Payload) or "", {
        ["Content-Type"] = "application/json", ["Authorization"] = FormattedToken
    })

    local Results = Citizen.Await(Promise)

    return Results
end

RegisterNetEvent("prp-core:Discord:PlayerUpdate", function()
    Cake.Discord.Status.Players =  #GetPlayers()

    TriggerLatentClientEvent("prp-core:Discord:PlayerUpdate", source, 100000, Cake.Discord.Status)
end)

RegisterNetEvent("playerConnected", function()
    Cake.Discord.Status.Players =  #GetPlayers()

    TriggerLatentClientEvent("prp-core:Discord:PlayerUpdate", source, 100000, Cake.Discord.Status)
end)

SetTimeout(5000, function()
    Cake.Discord.WatchPlayers()
end)

