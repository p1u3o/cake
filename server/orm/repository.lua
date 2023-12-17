local function FormatInsertQuery(TableName, TableColumns, Data)
    local Columns = ''
    local InsertValues = ""
    local Values = {}

    for _, Column in pairs(TableColumns) do
        if Data[Column.Name] ~= nil then
            Columns = Columns .. Column.Name .. ','
            InsertValues = InsertValues .. '?,'
            table.insert(Values, Data[Column.Name])
        end
    end

    Columns = Columns:sub(1, -2)
    InsertValues = InsertValues:sub(1, -2)

    return 'INSERT INTO ' .. TableName .. ' (' .. Columns .. ') VALUES (' .. InsertValues .. ')', Values
end

local function FormatUpdateQuery(TableName, TableColumns, PrimaryKey, Data)
    local Columns = ''
    local Values = {}

    for _, Column in pairs(TableColumns) do
        if Data[Column.Name] ~= nil and Column.Name ~= PrimaryKey then
            Columns = Columns .. Column.Name .. ' = ?, '
            table.insert(Values, Data[Column.Name])
        end
    end

    table.insert(Values, Data[PrimaryKey])

    Columns = Columns:sub(1, -3)

    return 'UPDATE ' .. TableName .. ' SET ' .. Columns .. ' WHERE ' .. PrimaryKey .. ' = ?', Values
end

function TableCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

local function FormatObject(Object)
    --Object._parent = TableCopy(Object)
    
    return Object
end

function CreateRepositoryObject(Entity)
    local Repository = {
        Entity = Entity,
        PrimaryKey = Entity.PrimaryKey,
        QueryBuilder = {}
    }

    function Repository:Reset()
        self.QueryBuilder = {
            SortBy = nil,
            Limit = nil,
            WhereBy = {},
            OrWhereBy = {},
            Columns = nil,
            GroupBy = nil,
        }
    end

    Repository:Reset()
    
    function Repository:Save(Data, Callback, ForceInsert)
        local Status = nil
        local Result = nil

        if Data[self.PrimaryKey] ~= nil and not ForceInsert then
            -- Update
            local UpdateQuery, ParsedData = FormatUpdateQuery(self.Entity.Name, self.Entity.Columns, self.PrimaryKey, Data)

            if Callback ~= nil then
                MySQL.update(UpdateQuery, ParsedData, Callback)
            else
                return MySQL.update.await(UpdateQuery, ParsedData)
            end
        else
            -- Create
            local InsertQuery, ParsedData = FormatInsertQuery(self.Entity.Name, self.Entity.Columns, Data)

            if Callback ~= nil then
                MySQL.insert(InsertQuery, ParsedData, function(GeneratedId)
                    if GeneratedId ~= nil then
                        Data[self.PrimaryKey] = GeneratedId
                        
                        Callback(GeneratedId)
                    else
                        Callback(false)
                    end
                end)
            else
                local GeneratedId = MySQL.insert.await(InsertQuery, ParsedData)

                if GeneratedId ~= nil then
                    Data[self.PrimaryKey] = GeneratedId

                    return GeneratedId
                else
                    return false
                end
            end
        end
    end

    function Repository:Delete(Data, Callback)
        if type(Data) == "table" then
            if Data[self.PrimaryKey] ~= nil then
                Data = Data[self.PrimaryKey]
            else
                return false
            end
        elseif not Data then
            return false
        end

        local DeleteQuery = 'DELETE FROM ' .. self.Entity.Name .. ' WHERE ' .. self.PrimaryKey .. ' = ?'

        if Callback ~= nil then
            MySQL.query(DeleteQuery, {Data}, function(Result)
                if Result.affectedRows > 0 then
                    Callback(true)
                else
                    Callback(false)
                end
            end)
        else
            local Result = MySQL.query.await(DeleteQuery, {Data})
            
            if Result.affectedRows > 0 then
                return true
            else
                return false
            end
        end
    end
    
    function Repository:Find(Value, Callback)
        local Query = 'SELECT ' .. self.Entity.Lookup .. ' FROM ' .. self.Entity.Name .. ' WHERE `' .. self.PrimaryKey .. '` = ?'
        
        if self.Entity.SoftDeletes then
            Query = Query .. " AND `deleted_at` IS NULL"
        end

        if CallBack == nil then
            return MySQL.query.await(Query, { Value })
        else
            MySQL.query(Query, { Value }, function(Result)
                if Callback then
                    if Result[1] ~= nil then
                        Callback(Result)
                    else
                        Callback({})
                    end
                end
            end)
        end
    end

    function Repository:FindBy(Filter, Value, Callback)     
        local Values = {}

        if type(Filter) ~= 'table' then
            Filter = {[Filter] = Value}
        elseif not Callback then
            Callback = Value
        end

        local Query = 'SELECT ' .. self.Entity.Lookup .. ' FROM ' .. self.Entity.Name .. ' WHERE'
        
        for k, v in pairs(Filter) do
            if #Values == 0 then
                Query = Query .. " `" .. k .. '` = ?'
            else
                Query = Query .. " AND `"  .. k .. '` = ?'
            end

            Values[#Values+1] = v
        end

        if self.Entity.SoftDeletes then
            Query = Query .. " AND `deleted_at` IS NULL"
        end

        if Callback == nil then
            return MySQL.query.await(Query, Values)
        else
            MySQL.query(Query, Values, function(Result)
                if Callback then
                    if Result[1] ~= nil then
                        Callback(Result)
                    else
                        Callback({})
                    end
                end
            end)
        end 
    end

    function Repository:FindOne(Value, Callback)
        local Query = 'SELECT ' .. self.Entity.Lookup .. ' FROM ' .. self.Entity.Name .. ' WHERE `' .. self.PrimaryKey .. '` = ?'
        
        if self.Entity.SoftDeletes then
            Query = Query .. " AND `deleted_at` IS NULL"
        end

        if Callback == nil then
            return FormatObject(MySQL.single.await(Query, { Value }))
        else
            MySQL.single(Query, { Value }, function(Result)
                if Callback then
                    if Result ~= nil then
                        Callback(FormatObject(Result))
                    else
                        Callback({})
                    end
                end
            end)
        end
    end

    function Repository:FindOneBy(Filter, Value, Callback)     
        local Values = {}

        if type(Filter) ~= 'table' then
            Filter = {[Filter] = Value}
        elseif not Callback then
            Callback = Value
        end

        local Query = 'SELECT ' .. self.Entity.Lookup .. ' FROM ' .. self.Entity.Name .. ' WHERE'
        
        for k, v in pairs(Filter) do
            if #Values == 0 then
                Query = Query .. " `" .. k .. '` = ?'
            else
                Query = Query .. " AND `"  .. k .. '` = ?'
            end

            Values[#Values+1] = v
        end

        if self.Entity.SoftDeletes then
            Query = Query .. " AND `deleted_at` IS NULL"
        end

        if Callback == nil then
            return FormatObject(MySQL.single.await(Query, Values))
        else
            MySQL.single(Query, Values, function(Result)
                if Callback then
                    Callback(FormatObject(Result))
                end
            end)
        end
    end

    function Repository:SortBy(Column, Order)
        self.QueryBuilder.SortBy = "ORDER BY " .. Column .. " " .. Order
        return self
    end

    function Repository:Limit(MaxLimit)
        self.QueryBuilder.Limit = MaxLimit
        return self
    end

    function Repository:GroupBy(Group)
        self.QueryBuilder.GroupBy = Group
        return self
    end

    function Repository:Where(Column, Value, Operator)
        if not Operator then
            Operator = "="
        end

        self.QueryBuilder.WhereBy[#self.QueryBuilder.WhereBy+1] = {[1] = Column, [2] = Operator, [3] = Value}
        
        return self
    end

    function Repository:OrWhere(Column, Value, Operator)
        if not Operator then
            Operator = "="
        end

        self.QueryBuilder.OrWhereBy[#self.QueryBuilder.OrWhereBy+1] = {[1] = Column, [2] = Operator, [3] = Value}
        
        return self
    end

    function Repository:Columns(Columns)
        self.QueryBuilder.Columns = Columns
        
        return self
    end

    function Repository:FindAll(Callback)        
        local Query = 'SELECT ' .. self.Entity.Lookup .. ' FROM ' .. self.Entity.Name
        local Values = {}

        if self.QueryBuilder.Columns then
            Query = 'SELECT '
            
            for k, v in ipairs(self.QueryBuilder.Columns) do
                if k ~= 1 then
                    Query = Query .. ", `" .. v .. "`"
                else
                    Query = Query .. "`" .. v .. "`"
                end
            end

            Query = Query .. ' FROM ' .. self.Entity.Name
        end

        if #self.QueryBuilder.WhereBy > 0 then
            if #Values == 0 then
                Query = Query .. " WHERE "
            end

            for k, v in ipairs(self.QueryBuilder.WhereBy) do
                if #Values == 0 then
                    Query = Query .. "`" ..  v[1] .. "` " .. v[2] .. " ?"
                else
                    Query = Query .. "AND `" ..  v[1] .. "` " .. v[2] .. " ?"
                end

                Values[#Values+1] = v[3]
            end
        end

        if #self.QueryBuilder.OrWhereBy > 0 then
            for k, v in ipairs(self.QueryBuilder.OrWhereBy) do
                Query = Query .. " OR `" ..  v[1] .. "` " .. v[2] .. " ?"

                Values[#Values+1] = v[3]
            end
        end

        if self.Entity.SoftDeletes then
            Query = Query .. " AND `deleted_at` IS NULL"
        end

        if self.QueryBuilder.SortBy ~= nil then
            Query = Query .. " " .. self.QueryBuilder.SortBy
        end

        if self.QueryBuilder.GroupBy then
            Query = Query .. " GROUP BY `" .. self.QueryBuilder.GroupBy .. "`"
        end

        if self.QueryBuilder.Limit ~= nil then
            Query = Query .. " LIMIT " .. self.QueryBuilder.Limit
        end

        self:Reset()
        
        if CallBack == nil then
            return MySQL.query.await(Query, Values)
        else
            MySQL.query(Query, Values, function(Result)
                if Callback then
                    if Result[1] ~= nil then
                        Callback(Result)
                    else
                        Callback({})
                    end
                end
            end)
        end
    end

    return Repository
end

exports('CreateRepositoryObject', CreateRepositoryObject)