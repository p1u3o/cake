Cake.Party = {}
Cake.Party.Create = function(Name, Owner)
    local OwnerMember = Cake.Party.CreateMember(Owner, true)

    return 
    {
        Name = Name,
        Owner = OwnerMember,
        Members = {}
    }
end

Cake.Party.CreateMember = function(Source, IsOwner)
    local xPlayer = Cake.GetPlayerFromId(Source)

    if xPlayer then
        return {
            Name     = xPlayer.getCompleteName(),
            UUID     = xPlayer.getUUID(),
            PlayerId = xPlayer.source,
            IsOwner  = IsOwner 
        }
    end
    
    return false
end