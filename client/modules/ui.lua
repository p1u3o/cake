Cake.UI.Menu                   = {}
Cake.UI.Menu.RegisteredTypes   = {}
Cake.UI.Menu.Opened            = {}

Cake.UI.Menu.RegisterType = function(type, open, close)
	Cake.UI.Menu.RegisteredTypes[type] = {
		open   = open,
		close  = close
	}
end

Cake.UI.Menu.Open = function(type, namespace, name, data, submit, cancel, change, close)
	local menu = {}

	menu.type      = type
	menu.namespace = namespace
	menu.name      = name
	menu.data      = data
	menu.submit    = submit
	menu.cancel    = cancel
	menu.change    = change

	menu.close = function()

		Cake.UI.Menu.RegisteredTypes[type].close(namespace, name)

		for i=1, #Cake.UI.Menu.Opened, 1 do
			if Cake.UI.Menu.Opened[i] then
				if Cake.UI.Menu.Opened[i].type == type and Cake.UI.Menu.Opened[i].namespace == namespace and Cake.UI.Menu.Opened[i].name == name then
					Cake.UI.Menu.Opened[i] = nil
				end
			end
		end

		if close then
			close()
		end

	end

	menu.update = function(query, newData)

		for i=1, #menu.data.elements, 1 do
			local match = true

			for k,v in pairs(query) do
				if menu.data.elements[i][k] ~= v then
					match = false
				end
			end

			if match then
				for k,v in pairs(newData) do
					menu.data.elements[i][k] = v
				end
			end
		end

	end

	menu.refresh = function()
		Cake.UI.Menu.RegisteredTypes[type].open(namespace, name, menu.data)
	end

	menu.setElement = function(i, key, val)
		menu.data.elements[i][key] = val
	end

	menu.setElements = function(newElements)
		menu.data.elements = newElements
	end

	menu.setTitle = function(val)
		menu.data.title = val
	end

	menu.removeElement = function(query)
		for i=1, #menu.data.elements, 1 do
			for k,v in pairs(query) do
				if menu.data.elements[i] then
					if menu.data.elements[i][k] == v then
						table.remove(menu.data.elements, i)
						break
					end
				end

			end
		end
	end

	table.insert(Cake.UI.Menu.Opened, menu)
	Cake.UI.Menu.RegisteredTypes[type].open(namespace, name, data)

	return menu
end

Cake.UI.Menu.Close = function(type, namespace, name)
	for i=1, #Cake.UI.Menu.Opened, 1 do
		if Cake.UI.Menu.Opened[i] then
			if Cake.UI.Menu.Opened[i].type == type and Cake.UI.Menu.Opened[i].namespace == namespace and Cake.UI.Menu.Opened[i].name == name then
				Cake.UI.Menu.Opened[i].close()
				Cake.UI.Menu.Opened[i] = nil
			end
		end
	end
end

Cake.UI.Menu.CloseAll = function()
	for i=1, #Cake.UI.Menu.Opened, 1 do
		if Cake.UI.Menu.Opened[i] then
			Cake.UI.Menu.Opened[i].close()
			Cake.UI.Menu.Opened[i] = nil
		end
	end
end

Cake.UI.Menu.GetOpened = function(type, namespace, name)
	for i=1, #Cake.UI.Menu.Opened, 1 do
		if Cake.UI.Menu.Opened[i] then
			if Cake.UI.Menu.Opened[i].type == type and Cake.UI.Menu.Opened[i].namespace == namespace and Cake.UI.Menu.Opened[i].name == name then
				return Cake.UI.Menu.Opened[i]
			end
		end
	end
end

Cake.UI.Menu.GetOpenedMenus = function()
	return Cake.UI.Menu.Opened
end

Cake.UI.Menu.IsOpen = function(type, namespace, name)
	return Cake.UI.Menu.GetOpened(type, namespace, name) ~= nil
end

Cake.UI.Menu.GetCount = function()
	return #Cake.UI.Menu.Opened
end

local ActivePrompt = {}

Cake.UI.Prompt = {}

Cake.UI.Prompt.IsActive = function(Name)
    return ActivePrompt[Name] ~= nil 
end

Cake.UI.Prompt.Create = function(Name, Position, Text, Entity, Text2)
    if ActivePrompt[Name] ~= nil then
        Cake.UI.Prompt.Delete(Name)
    end

	if not Text2 then
		Text2 = ""
	end

    if Entity == nil then
        ActivePrompt[Name] = true
        TriggerEvent("prp-prompt:AddNewPrompt", Name, {
            objecttext = Text2, 
            actiontext = Text, 
            holdtime = 1, 
            key = "", 
            position = Position, 
            deletion = function()
                ActivePrompt[Name] = nil
            end,
            drawdist = 1000.0,
            usagedist = 1000.0
        })
    else
        ActivePrompt[Name] = true
        TriggerEvent("prp-prompt:AddNewPrompt", Name, {
            objecttext = Text2, 
            actiontext = Text, 
            holdtime = 1, 
            key = "", 
            position = GetEntityCoords(Entity),
            entity = Entity,
            deletion = function()
                ActivePrompt[Name] = nil
            end,
            drawdist = 1000.0,
            usagedist = 1000.0
        })
    end
end

Cake.UI.Prompt.CreateNetworked = function(Name, Duration, Position, Text, Entity, Text2)
	if not Text2 then
		Text2 = ""
	end

	if Entity then
		TriggerServerEvent("prp-core:UI:CreateNetworkedPrompt", Name, Duration, Position, Text, NetworkGetNetworkIdFromEntity(Entity), Text2)
	else
		TriggerServerEvent("prp-core:UI:CreateNetworkedPrompt", Name, Duration, Position, Text, nil, Text2, Duration)
	end
end

Cake.UI.Prompt.Update = function(Name, Text)
    if ActivePrompt[Name] ~= nil then
		TriggerEvent("prp-prompt:UpdateText", Name, Text)
	end
end

Cake.UI.Prompt.Move = function(Name, Position)
	if ActivePrompt[Name] ~= nil then
		TriggerEvent("prp-prompt:UpdatePosition", Name, Position)
	end
end

Cake.UI.Prompt.Delete = function(Name)
    TriggerEvent("prp-prompt:RemovePrompt", Name)
    ActivePrompt[Name] = nil
end

Cake.UI.Prompt.DeleteAll = function(Name)
    for k, v in pairs(ActivePrompt) do
        Cake.UI.Prompt.Delete(k)
    end
end

RegisterNetEvent("prp-core:UI:CreateNetworkedPrompt", function(Name, Duration, Position, Text, Entity, Text2)
	if #(Cake.Cache.GetCurrentCoords() - Position) < 10.0 then
		if Entity ~= nil then
			if NetworkDoesEntityExistWithNetworkId(Entity) then
				Cake.UI.Prompt.Create(Name, Position, Text, NetworkGetEntityFromNetworkId(Entity), Text2)
			else
				return
			end
		else
			Cake.UI.Prompt.Create(Name, Position, Text, nil, Text2)
		end

		SetTimeout(Duration, function()
			Cake.UI.Prompt.Delete(Name)
		end)
	end
end)

Cake.Log.Info("UI", "Loaded")