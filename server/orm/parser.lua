local function GetEntities(TableName)
    if Cake.ORM.Models[TableName] then
        local Entities = {}
        local Model = Cake.ORM.Models[TableName]
        local Entity = { PrimaryKey = Model.PrimaryKey, Name = TableName, Columns = {}, Lookup = "", Indexes = Model.Indexes, SoftDeletes = Model.SoftDeletes }

        for k, v in ipairs(Model.Columns) do
            table.insert(Entity.Columns, { Name = v.Name, Addon = v.Extra, DataType = v.Type, Default = v.Default, OnUpdate = v.OnUpdate})

            if #Entity.Lookup == 0 then
                Entity.Lookup = "`" ..v.Name .. "`"
            else
                Entity.Lookup = Entity.Lookup .. ", `" .. v.Name .. "`"
            end
        end

        Entities[TableName] = Entity

        return Entities
    end
end

function CreateModel(TableName)
    local Entities = GetEntities(TableName)

    if not Entities then
        return false
    end

    for EntityName, Entity in pairs(Entities) do
        local CreateQuery = 'CREATE TABLE IF NOT EXISTS ' .. EntityName .. ' ('

        for _, Column in pairs(Entity.Columns) do
            local DataType = Column.DataType

            if DataType == 'string' then
                DataType = 'varchar(255)'
            elseif DataType == 'number' then
                DataType = 'int'
            end

            if #Column.Addon > 1 then
                DataType = DataType .. ' ' .. Column.Addon
            end

            if Column.Default then
                if Column.Default == "current_timestamp()" then
                    DataType = DataType .. " DEFAULT " .. Column.Default
                else
                    DataType = DataType .. " DEFAULT '" .. Column.Default .. "'"
                end
            end

            if Column.OnUpdate then
                DataType = DataType .. " on update " .. Column.OnUpdate
            end

            CreateQuery = CreateQuery .. "`" .. Column.Name .. '` ' .. DataType .. ', '
        end

        if Entity.PrimaryKey then
            CreateQuery = CreateQuery .. 'PRIMARY KEY (' .. Entity.PrimaryKey .. ')'
        else
            CreateQuery = CreateQuery:sub(1, -3)
        end

        CreateQuery = CreateQuery .. ')'

        MySQL.single("SHOW TABLES LIKE '" .. EntityName .. "'", {}, function(Result)
            if Result == nil then
                MySQL.query(CreateQuery, {}, function()
                    Cake.Log.Debug("ORM", 'Created table: ' ..EntityName)

                    if Entity.Indexes then
                        for k, v in pairs(Entity.Indexes) do
                            local Query = "CREATE INDEX " .. k .. " ON " .. EntityName .. "("

                            for ki, vi in ipairs(v) do
                                if ki == #v then
                                    Query = Query .. vi
                                else
                                    Query = Query .. vi .. ", "
                                end
                            end

                            Query = Query .. ")"

                            print(Query)

                            MySQL.query(Query, {}, function()
                                TriggerEvent("prp-core:ORM:Finished", EntityName)
                            end)
                        end
                    end
                end)
            else
                Cake.Log.Debug("ORM", 'Loaded table: ' ..EntityName)
                TriggerEvent("prp-core:ORM:Finished", EntityName)
            end
        end)
    end

    local NewObject = CreateRepositoryObject

    return NewObject(Entities[next(Entities)])
end