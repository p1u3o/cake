RegisterNetEvent("prp-core:UI:CreateNetworkedPrompt", function(Name, Duration, Position, Text, Entity, Text2)
    Name = Name .. "-" .. tostring(source)
    TriggerClientEvent("prp-core:UI:CreateNetworkedPrompt", -1, Name, Duration, Position, Text, Entity, Text2)
end)