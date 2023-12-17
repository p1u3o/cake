local CurrentParties = {}
local CurrentMembers = {}

Cake.Parties.CreateParty = function(Name, Owner) 
    if not CurrentParties[Name] then
        CurrentParties[Name] = Cake.Party.Create(Name, Owner)        
        Cake.Parties.AddMemberToParty(Name, Owner, true)
    end

    return CurrentParties[Name]
end

Cake.Parties.GetParty = function(Name)
    if not CurrentParties[Name] then
        return nil
    end

    return CurrentParties[Name]
end

Cake.Parties.GetMembers = function(Name, OnlineCheck)
    if not CurrentParties[Name] then
        return nil
    end

    if OnlineCheck then
        for k, v in pairs(CurrentParties[Name].Members) do
            if Cake.UUIDToSrcMap[k] then
                CurrentParties[Name].Members[k].Online = true
            else
                CurrentParties[Name].Members[k].Online = false
            end
        end
    end

    return CurrentParties[Name].Members
end

Cake.Parties.AddMemberToParty = function(Name, PlayerId, IsOwner) 
    if CurrentParties[Name] then
        local Member = Cake.Party.CreateMember(PlayerId, IsOwner)

        if Member then
            if not CurrentMembers[Member.UUID] then
                CurrentParties[Name].Members[Member.UUID] = Member
                CurrentMembers[Member.UUID] = Name

                Player(PlayerId).state:set('party', Name, true)
                TriggerClientEvent("prp-core:Party:JoinedParty", PlayerId, Name)

                return true
            end
        end
    end

    return false
end

Cake.Parties.GetPartyMemberBelongsTo = function(PlayerId)
    local Member = Cake.Party.CreateMember(PlayerId)

    if CurrentMembers[Member.UUID] then
        if CurrentParties[CurrentMembers[Member.UUID]] then
            if CurrentParties[CurrentMembers[Member.UUID]].Members[Member.UUID] then
                return CurrentParties[CurrentMembers[Member.UUID]], Member, CurrentParties[CurrentMembers[Member.UUID]].Members[Member.UUID].IsOwner
            end
        end
    end

    return nil
end

Cake.Parties.Leave = function(PlayerId)
    local Party, Member, IsOwner = Cake.Parties.GetPartyMemberBelongsTo(PlayerId)

    if Party then
        CurrentParties[Party.Name].Members[Member.UUID] = nil
        CurrentMembers[Member.UUID] = nil
        Player(PlayerId).state:set('party', nil, true)
        TriggerClientEvent("prp-core:Party:LeftParty", PlayerId, Party.Name)

        if IsOwner then
            local NewOwner = nil
            /* Look for new owner*/
            for UUID, Member in pairs(CurrentParties[Party.Name].Members) do
                local xPlayer = Cake.GetPlayerFromUUID(UUID)

                if xPlayer then
                    NewOwner = Member
                    TriggerClientEvent("prp-core:Party:NewLeaderOfParty", xPlayer.source, Party.Name)

                    break
                end
            end

            if NewOwner then
                CurrentParties[Party.Name].Owner = Member
                CurrentParties[Party.Name].Members[NewOwner.UUID].IsOwner = true
            else
                for UUID, Member in pairs(CurrentParties[Party.Name].Members) do
                    CurrentMembers[UUID] = nil
                end

                CurrentParties[Party.Name] = nil
            end
        end
    end
end

Cake.Parties.Kick = function(Name, PlayerId, TargetUUID)
    local Party, Member, IsOwner = Cake.Parties.GetPartyMemberBelongsTo(PlayerId)

    if Party and Party.Name == Name and IsOwner then
        if CurrentParties[Party.Name].Members[TargetUUID] then
            local xPlayer = Cake.GetPlayerFromUUID(TargetUUID) 
            
            if xPlayer then
                Cake.Parties.Leave(xPlayer.source)
                TriggerClientEvent("prp-core:Party:KickedFromParty", xPlayer.source, Party.Name)
            else
                CurrentParties[Party.Name].Members[TargetUUID] = nil
                CurrentMembers[TargetUUID] = nil    
            end

            return true
        end
    end

    return false
end

Cake.Parties.AreTwoPlayersInSameGroup = function(PlayerSrc1, PlayerSrc2)
    local xPlayer = Cake.GetPlayerFromId(PlayerSrc1)
    local yPlayer = Cake.GetPlayerFromId(PlayerSrc2)

    if xPlayer and yPlayer then
        if CurrentMembers[xPlayer.uuid] == CurrentMembers[yPlayer.uuid] then
            return true
        end
    end

    return false
end

RegisterCommand("TestParties", function()
    print(json.encode(CurrentParties))
    print(json.encode(CurrentMembers))
end)