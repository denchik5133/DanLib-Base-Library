/***
 *   @addon         DanLib
 *   @version       3.0.0
 *   @release_date  10/4/2023
 *   @author        denchik
 *   @contact       Discord: denchik_gm
 *                  Steam: https://steamcommunity.com/profiles/76561198405398290/
 *                  GitHub: https://github.com/denchik5133
 *                
 *   @description   Universal library for GMod Lua, combining all the necessary features to simplify script development. 
 *                  Avoid code duplication and speed up the creation process with this powerful and convenient library.
 *
 *   @usage         !danlibmenu (chat) | danlibmenu (console)
 *   @license       MIT License
 *   @notes         For feature requests or contributions, please open an issue on GitHub.
 */



local base = DanLib.Func
local Table = DanLib.Table
DanLib.SQL = DanLib.SQL or {}
local SQL = DanLib.SQL
-- Variable for storing the last error
SQL.lastError = nil


local function LoadSQLFiles()
    for k, v in pairs(file.Find('danlib/*.lua', 'LUA')) do
        if (not string.StartWith(v, 'sv_sql')) then continue end
        include('danlib/' .. v)
    end
end


local function fileExistsWithWildcard(path)
    -- Get the list of files in the directory
    local files = file.Find(path, 'LUA')
    -- Check if there are files matching the template
    for _, filename in ipairs(files) do
        if filename:match('^gmsv_mysqloo_.*%.dll$') then
            return true
        end
    end
    return false
end


local config = DanLib.ConfigMeta.BASE:GetValue('SQL') or {}
local isMySQL = config.EnableSQL
local CONNECTION

function SQL:Initialize()
    if isMySQL then
        -- Check if the module is available
        if (not fileExistsWithWildcard('bin/*')) then
            base:PrintType('SQL', 'ERROR: Could not find a suitable MySQL module.')
            return
        end

        require('mysqloo')

        -- Create a new connection
        CONNECTION = mysqloo.connect(config.Host, config.Username, config.Password, config.DatabaseName, config.DatabasePort)

        -- Handle connection events
        function CONNECTION:onConnected()
            base:PrintType('SQL', 'Successfully connected to MySQL database: ' .. config.DatabaseName)
            LoadSQLFiles()
            -- Here you can create the necessary tables
        end

        function CONNECTION:onConnectionFailed(err)
            base:PrintType('SQL', 'Failed to connect to MySQL database: ' .. err)
        end

        -- Connecting to the database
        CONNECTION:connect()
    else
        base:PrintType('SQL', 'MySQL is disabled. Initializing SQLite connection...')
    end
end
SQL:Initialize()


--- Executes an SQL query.
-- @param queryStr: Query string.
-- @param func: Callback function to process the result.
-- @param singleRow: If true, returns only one row.
-- @return: true if the query is successful, otherwise false and an error message.
function SQL:Query(queryStr, func, singleRow)
    local query

    -- Request logging
    base:PrintType('SQL', 'DEBUG ' .. queryStr)

    if isMySQL then
        -- Use MySQL query execution
        local mySQLQuery = CONNECTION:query(queryStr)

        function mySQLQuery:onSuccess(data)
            if func then return func(data) end
        end

        function mySQLQuery:onError(err)
            base:PrintType('SQL', 'ERROR ' .. err)
            SQL.lastError = err -- Save the error message
            return false, err
        end

        mySQLQuery:start()
    else
        -- Use SQLite query execution
        if (not singleRow) then
            query = sql.Query(queryStr)
        else
            query = sql.QueryRow(queryStr, 1)
        end

        -- Error handling
        if (query == false) then
            local errorMsg = sql.LastError()
            base:PrintType('SQL', 'ERROR' .. errorMsg)
            SQL.lastError = errorMsg -- Save the error message
            return false, errorMsg
        elseif func then
            return func(query)
        end
    end

    return true
end


--- Gets the last error message.
-- @return: The last error message or nil if no error occurred.
function SQL:GetLastError()
    return SQL.lastError
end


--- Creates a table if it does not exist.
-- @param tableName: The name of the table.
-- @param columns: A string describing the columns.
function SQL:CreateTableIfNotExists(tableName, columns)
    local queryStr = string.format('CREATE TABLE IF NOT EXISTS %s (%s);', tableName, columns)
    self:Query(queryStr)
end


--- Adds a column to an existing table.
-- @param tableName: The name of the table.
-- @param columnName: The name of the column to add.
-- @param columnType: The type of column (e.g. 'VARCHAR(255)', 'INT').
function SQL:AddColumn(tableName, columnName, columnType)
    local queryStr = string.format('ALTER TABLE %s ADD COLUMN %s %s;', tableName, columnName, columnType)
    return self:Query(queryStr)
end


--- Removes a column from an existing table.
-- @param tableName: The name of the table.
-- @param columnName: The name of the column to delete.
function SQL:DeleteColumn(tableName, columnName)
    local queryStr = string.format('ALTER TABLE %s DROP COLUMN %s;', tableName, columnName)
    return self:Query(queryStr)
end


--- Example function to insert data into a table.
-- @param tableName: Table name.
-- @param data: Table with data to be inserted.
function SQL:InsertIntoTable(tableName, data)
    local columns = {}
    local values = {}

    -- Collecting columns and values
    for key, value in pairs(data) do
        Table:Add(columns, key)
        Table:Add(values, sql.SQLStr(value))
    end

    local queryStr = string.format('INSERT INTO %s (%s) VALUES (%s);', tableName, Table:Concat(columns, ', '), Table:Concat(values, ', '))
    return self:Query(queryStr)
end



--- Example function to update data in a table.
-- @param tableName: Table name.
-- @param data: Table with data to be updated.
-- @param condition: Condition for updating.
function SQL:UpdateTable(tableName, data, condition)
    local updates = {}
    for key, value in pairs(data) do
        Table:Add(updates, string.format('%s = %s', sql.SQLStr(key), sql.SQLStr(value)))
    end

    local queryStr = string.format('UPDATE %s SET %s WHERE %s;', tableName, Table:Concat(updates, ', '), condition)
    return self:Query(queryStr)
end


--- Example function to delete data from a table.
-- @param tableName: Table name.
-- @param condition: Condition for deletion.
function SQL:DeleteFromTable(tableName, condition)
    local queryStr = string.format('DELETE FROM %s WHERE %s;', tableName, condition)
    return self:Query(queryStr)
end


--- Gets all records from a table.
-- @param tableName: Table name.
-- @param func: Callback function to process the results.
function SQL:GetAllRecords(tableName, func)
    local queryStr = string.format('SELECT * FROM %s;', tableName)
    return self:Query(queryStr, func)
end


--- Gets records from a table with a condition.
-- @param tableName: Table name.
-- @param condition: Condition for selection.
-- @param func: Callback function to process the results.
function SQL:GetRecordsWithCondition(tableName, condition, func)
    local queryStr = string.format('SELECT * FROM %s WHERE %s;', tableName, condition)
    return self:Query(queryStr, func)
end


--- Checks if a record exists in a table.
-- @param tableName: Table name.
-- @param condition: Condition for checking existence.
-- @return: true if exists, false otherwise.
function SQL:RecordExists(tableName, condition)
    local queryStr = string.format('SELECT COUNT(*) FROM %s WHERE %s;', tableName, condition)
    local result, errorMsg = self:Query(queryStr, nil, true)
    if (not result) then return false, errorMsg end
    return result[1] > 0
end


--- Gets the record by ID.
-- @param tableName: Table name.
-- @param id: Record ID.
-- @param func: Callback function to process the result.
function SQL:GetRecordByID(tableName, id, func)
    local queryStr = string.format('SELECT * FROM %s WHERE id = %d;', tableName, id)
    return self:Query(queryStr, func)
end


--- Gets the total number of records in the table.
-- @param tableName: Table name.
-- @return: Total number of records.
function SQL:GetRecordCount(tableName)
    local queryStr = string.format('SELECT COUNT(*) as count FROM %s;', tableName)
    local result, err = self:Query(queryStr, nil, true)
    if (not result) then return 0, err end
    return result.count
end


--- Gets records from a table with pagination support.
-- @param tableName: TableName.
-- @param offset: Offset (record number to start at).
-- @param limit: Maximum number of records to retrieve.
-- @param func: Callback function to process the results.
function SQL:GetRecordsWithPagination(tableName, offset, limit, func)
    local queryStr = string.format('SELECT * FROM %s LIMIT %d OFFSET %d;', tableName, limit, offset)
    return self:Query(queryStr, func)
end


--- Creates an index for a column in a table.
-- @param tableName: The name of the table.
-- @param columnName: The name of the column to index.
function SQL:CreateIndex(tableName, columnName)
    local queryStr = string.format('CREATE INDEX idx_%s ON %s(%s);', columnName, tableName, columnName)
    return self:Query(queryStr)
end


--- Gets a description of the table structure.
-- @param tableName: The name of the table.
-- @return: Description of the table.
function SQL:GetTableDescription(tableName)
    local queryStr = string.format('DESCRIBE %s;', tableName)
    return self:Query(queryStr)
end


--- Performs a join of two tables.
-- @param table1: First table.
-- @param table2: Second table.
-- @param onCondition: Condition for the merge.
-- @param func: Callback function to process the results.
function SQL:JoinTables(table1, table2, onCondition, func)
    local queryStr = string.format('SELECT * FROM %s JOIN %s ON %s;', table1, table2, onCondition)
    return self:Query(queryStr, func)
end


--- Clears all records from a table.
-- @param tableName: Table name.
function SQL:ClearTable(tableName)
    local queryStr = string.format('DELETE FROM %s;', tableName)
    return self:Query(queryStr)
end


--- Deletes the table.
-- @param tableName: The name of the table.
function SQL:DropTable(tableName)
    local queryStr = string.format('DROP TABLE IF EXISTS %s;', tableName)
    return self:Query(queryStr)
end


--- Copies the table.
-- @param sourceTable: Name of the source table.
-- @param newTable: Name of the new table.
function SQL:CloneTable(sourceTable, newTable)
    local queryStr = string.format('CREATE TABLE %s AS SELECT * FROM %s;', newTable, sourceTable)
    return self:Query(queryStr)
end


--- Exports data from a table to a CSV file.
-- @param tableName: Table name.
-- @param filePath: Path to the file to save.
function SQL:ExportToCSV(tableName, filePath)
    local queryStr = string.format('SELECT * FROM %s;', tableName)
    self:Query(queryStr, function(data)
        local file = file.Open(filePath, 'wb', 'DATA')
        if file then
            for _, row in ipairs(data) do
                local line = Table:Concat(row, ',') .. '\n'
                file:Write(line)
            end
            file:Close()
        end
    end)
end


--- Imports data from a CSV file into a table.
-- @param tableName: Table name.
-- @param filePath: The path to the CSV file.
function SQL:ImportFromCSV(tableName, filePath)
    local file = file.Open(filePath, 'rb', 'DATA')
    if file then
        local data = file:Read(file:Size())
        file:Close()
        
        for line in string.gmatch(data, '[^\r\n]+') do
            local values = {}
            for value in string.gmatch(line, '[^,]+') do
                Table:Add(values, value)
            end
            self:InsertIntoTable(tableName, values)
        end
    end
end


--- Begins a transaction.
function SQL:BeginTransaction()
    self:Query('BEGIN;')
end


--- Commits a transaction.
function SQL:CommitTransaction()
    self:Query('COMMIT;')
end


--- Rolls back a transaction.
function SQL:RollbackTransaction()
    self:Query('ROLLBACK;')
end





















-- Define table name and column descriptions
-- local tableName = 'users'
-- Create a table if it does not exist
-- local success = DanLib.SQL.CreateTableIfNotExists(tableName, 'id INT AUTO_INCREMENT PRIMARY KEY, email VARCHAR(100), age INT')

-- if success then
--     print('Table "' .. tableName .. '" has been successfully created or already exists.')
-- else
--     print('Error when creating a table "' .. tableName .. '".')
-- end



