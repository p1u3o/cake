local FirstTime = false

RegisterNetEvent("prp-core:Discord:PlayerUpdate", function(Status)
    if not FirstTime then
        FirstTime = true

        for k, v in pairs(Config.DiscordPresence.Buttons) do
            SetDiscordRichPresenceAction(k, v.Name, v.URL)
        end
    end

    SetDiscordAppId(Config.DiscordPresence.AppId)
    SetDiscordRichPresenceAsset(Config.DiscordPresence.Icon)
    SetDiscordRichPresenceAssetText(Config.DiscordPresence.Text)
    SetDiscordRichPresenceAssetSmall(Config.DiscordPresence.SmallIcon)
    SetDiscordRichPresenceAssetSmallText(Config.DiscordPresence.SmallText)

    local Presence = ""

    if Status.Queue == "0" then
        Presence = Presence .. string.format("Roleplaying (%s/%s)", Status.Players, Status.MaxPlayers)
    else
        Presence = Presence .. string.format("Roleplaying (%s/%s %s Queue)", Status.Players, Status.MaxPlayers, Status.Queue)
    end

    if not Cake.PlayerLoaded then
        Presence = Presence .. "\nChoosing Character.."
    else
        if Cake.PlayerData.creation then
            Presence = Presence .. "\nCreating Character.."
        elseif Config.DiscordPresence.JobEmoji[Cake.PlayerData.job.name] ~= nil then
            Presence = Presence .. "\n" .. Config.DiscordPresence.JobEmoji[Cake.PlayerData.job.name] .." " .. Cake.PlayerData.completename
        else
            Presence = Presence .. "\n" .. Config.DiscordPresence.JobEmoji["default"] .." " .. Cake.PlayerData.completename
        end
    end

    SetRichPresence(Presence)
end)

Cake.Log.Info("Discord", "Loaded")
