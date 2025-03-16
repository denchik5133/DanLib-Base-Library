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


/***
 *   sh_table.lua
 *   This file is responsible for managing table operations in the DanLib project.
 *
 *   It includes the following functions:
 *   - Adding values from one table to another (Add).
 *   - Clearing keys and creating a new sequential table (ClearKeys).
 *   - Collapsing a key-value structure table (CollapseKeyValue).
 *   - Concatenating table contents into a string (Concat).
 *   - Creating a deep copy of a table (DeepCopy).
 *   - Merging values from one table into another (CopyFromTo).
 *   - Checking the number of keys in a table (Count).
 *   - DeSanitizing a table (DeSanitise).
 *   - Emptying a table (Empty).
 *   - Finding the next value in a table (FindNext).
 *   - Finding the previous value in a table (FindPrev).
 *   - Flipping key-value pairs in a table (Flip).
 *   - Forcing insertion of a value into a table (ForceInsert).
 *   - Iterating over key-value pairs in a table (Foreach).
 *   - Retrieving all keys from a table (GetKeys).
 *   - Getting the first key and value from a table (GetFirst).
 *   - Getting the last key and value from a table (GetLast).
 *   - Checking if a table has a specific value (HasValue).
 *   - Inheriting values from one table to another (Inherit).
 *   - Inserting a value into a table at a specific index (InsertAt).
 *   - Checking if a table is empty (IsEmpty).
 *   - Checking if a table's keys are sequential (IsSequential).
 *   - Getting a key from a table based on the value (KeyFromValue).
 *   - Getting all keys from a table based on a value (KeysFromValue).
 *   - Lowercasing all string keys in a table (LowerKeyNames).
 *   - Finding the highest numerical key in a table (maxn).
 *   - Merging two tables recursively (Merge).
 *   - Moving elements within a table (Move).
 *   - Packing multiple items into a table (Pack).
 *   - Getting a random value from a table (Random).
 *   - Removing a value from a table by key (Remove).
 *   - Removing a value by its first instance (RemoveByValue).
 *   - Reversing a table (Reverse).
 *   - Sanitizing a table for key-value conversion (Sanitise).
 *   - Shuffling a table randomly (Shuffle).
 *   - Sorting a table (Sort).
 *   - Sorting keys based on their values (SortByKey).
 *   - Sorting a table by a specific member (SortByMember).
 *   - Sorting a table in descending order (SortDesc).
 *   - Converting a table to a string (ToString).
 *
 *   The file provides a comprehensive interface for handling table operations in the project,
 *   ensuring efficient data management and manipulation.
 */



--- Shared online library for DanLib
DanLib = DanLib or {}
DanLib.Table = DanLib.Table or {}
local Table = DanLib.Table


--- Function to check if the argument is a table
-- @param arg: The argument to check.
-- @param funcName: The name of the function for error reporting.
-- @return: true if the argument is a table, false otherwise.
local function checkTable(arg, funcName)
    if (type(arg) ~= 'table') then
        print('Error in ' .. funcName .. ': Argument must be a table.')
        return false
    end

    return true
end


--- Function to add a single value to the target table
-- @param target: The target table to which the value will be added.
-- @param tbl: The value to be added to the target table.
function Table:Add(target, tbl)
    if (not checkTable(target, 'Add')) then return end

    table.insert(target, tbl)
    return target
end


--- Function to add multiple values from the source table into the target table
-- @param target: The target table to which values will be added.
-- @param source: The source table from which values will be taken.
-- @return: The target table with added values.
function Table:AddMultiple(target, source)
    if (not checkTable(target, 'AddMultiple') or not checkTable(source, 'AddMultiple')) then return end

    for _, value in ipairs(source) do
        self:Add(target, value)
    end

    return target
end


--- Function to get the first or last key/value from a table
function Table:GetElement(tbl, isFirst, isKey)
    if (not checkTable(tbl, 'GetElement')) then return nil end

    if isFirst then
        for key, value in pairs(tbl) do
            return isKey and key or value
        end
    else
        local lastKey, lastValue
        for key, value in pairs(tbl) do
            lastKey, lastValue = key, value
        end

        return isKey and lastKey or lastValue
    end
end


--- Function to collapse a key-value structure table
-- @param input: The table to be collapsed.
-- @return: A collapsed version of the input table.
function Table:CollapseKeyValue(input)
    if (not checkTable(input, 'CollapseKeyValue')) then return {} end

    local collapsed = {}
    for key, value in pairs(input) do
        if (type(value) == 'table') then
            for subKey, subValue in pairs(value) do
                collapsed[subKey] = subValue
            end
        else
            collapsed[key] = value
        end
    end

    return collapsed
end


--- Function to concatenate the contents of a table into a string
-- @param tbl: The table to concatenate.
-- @param concatenator: The string used to concatenate values (default is '').
-- @param startPos: The starting position for concatenation (default is 1).
-- @param endPos: The ending position for concatenation (default is #tbl).
-- @return: A concatenated string of table contents.
function Table:Concat(tbl, concatenator, startPos, endPos)
    if (not checkTable(tbl, 'Concat')) then return '' end

    return table.concat(tbl, concatenator, startPos or 1, endPos or #tbl)
end


--- Function to create a deep copy of a table
-- @param originalTable: The table to be copied.
-- @return: A deep copy of the original table.
function Table:Copy(originalTable)
    if (not checkTable(originalTable, 'Copy')) then return {} end

    local copy = {}
    for key, value in pairs(originalTable) do
        if (type(value) == 'table') then
            copy[key] = self:Copy(value)
        else
            copy[key] = value
        end
    end

    return copy
end


--- Function to merge values from the source table into the target table
-- @param source: The source table from which values will be merged.
-- @param target: The target table to which values will be merged.
-- @return: The target table with merged values.
function Table:CopyFromTo(source, target)
	if (not checkTable(source, 'CopyFromTo') or not checkTable(target, 'CopyFromTo')) then return target end

    self:Empty(target) -- Empty the target table first
    for key, value in pairs(source) do
        target[key] = value
    end

    return target
end


--- Function to count the number of keys in a table
-- @param tbl: The table to count keys.
-- @return: The number of keys in the table.
function Table:Count(tbl)
	if (not checkTable(tbl, 'Count')) then return 0 end

    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end

    return count
end


--- Function to de-sanitize a table
-- @param tbl: The sanitized table to convert back.
-- @return: The original form of the table.
function Table:DeSanitise(tbl)
    if (not checkTable(tbl, 'DeSanitise')) then return {} end

    -- Example implementation, customize as needed
    return tbl
end


--- Function to empty a table
-- @param tbl: The table to be emptied.
function Table:Empty(tbl)
	if (not checkTable(tbl, 'Empty')) then return end

    for k in pairs(tbl) do
        tbl[k] = nil
    end
end


--- Function to flip key-value pairs in a table
-- @param input: The table to flip.
-- @return: A new table with flipped key-value pairs.
function Table:Flip(input)
    if (not checkTable(input, 'Flip')) then return {} end

    local flipped = {}
    for key, value in pairs(input) do
        -- Prevent data loss when duplicate values are present
        if (flipped[value] == nil) then
            flipped[value] = key
        else
            print('Warning: Duplicate value found for key "' .. key .. '"; data loss may occur.')
        end
    end

    return flipped
end


--- Function to force insert a value into a table
-- @param tab: The table to insert into (default is an empty table).
-- @param value: The value to insert.
function Table:ForceInsert(tab, value)
	if (not checkTable(tab, 'ForceInsert')) then return {} end

    tab = tab or {}
    self:Add(tab, { value })-- Wrap value in a table
    return tab
end


--- Function to iterate over key-value pairs in a table
-- @param tbl: The table to iterate over.
-- @param callback: The function to call for each key-value pair.
function Table:Foreach(tbl, callback)
    if (not checkTable(tbl, 'Foreach')) then return end

    for key, value in pairs(tbl) do
        callback(key, value)
    end
end


--- Function to retrieve all keys from a table
-- @param tabl: The table to get keys from.
-- @return: A table of keys.
function Table:GetKeys(tabl)
    if (not checkTable(tabl, 'GetKeys')) then return {} end

    local keys = {}
    for key in pairs(tabl) do
        self:Add(keys, key)
    end

    return keys
end


--- Function to find a key with the highest value in a table
-- @param inputTable: The table to search.
-- @return: A key with the highest number value.
function Table:GetWinningKey(inputTable)
    if (not checkTable(inputTable, 'GetWinningKey')) then return nil end

    local winningKey
    local highestValue = -math.huge

    for key, value in pairs(inputTable) do
        if (value > highestValue) then
            highestValue = value
            winningKey = key
        end
    end

    return winningKey
end


--- Function to check if a table has a specific value
-- @param tbl: The table to check.
-- @param value: The value to search for.
-- @return: true if the value is found, otherwise false.
function Table:HasValue(tbl, value)
    if (not checkTable(tbl, 'HasValue')) then return false end

    for _, v in pairs(tbl) do
        if (v == value) then
            return true
        end
    end

    return false
end


--- Function to inherit values from one table to another
-- @param target: The target table to inherit values into.
-- @param base: The base table from which to inherit values.
-- @return: The target table with inherited values.
function Table:Inherit(target, base)
    if (not checkTable(target, 'Inherit') or not checkTable(base, 'Inherit')) then return target end

    for key, value in pairs(base) do
        if (target[key] == nil) then
            target[key] = value
        end
    end

    target.BaseClass = base
    return target
end


--- Function to insert a value into a table at a specific position
-- @param tab: The table to insert into.
-- @param value: The value to insert.
-- @param position: The position at which to insert the value.
function Table:InsertAt(tab, value, position)
    if (not checkTable(tab, 'InsertAt')) then return end

    tab = tab or {}
    self:Add(tab, position or #tab + 1, value)
    return tab
end


--- Function to merge two tables
-- @param tbl1: The first table.
-- @param tbl2: The second table to merge into the first.
-- @return: A new table containing merged values from both tables.
function Table:Merge(tbl1, tbl2)
    if (not checkTable(tbl1, 'Merge') or not checkTable(tbl2, 'Merge')) then return {} end

    local merged = {}
    for k, v in pairs(tbl1) do
        merged[k] = v
    end

    for k, v in pairs(tbl2) do
        merged[k] = v
    end

    return merged
end


--- Function to move elements within a table
-- @param tbl: The table to move elements in.
-- @param fromIndex: The index to move from.
-- @param toIndex: The index to move to.
function Table:Move(tbl, fromIndex, toIndex)
    if (not checkTable(tbl, 'Move')) then return end

    if (fromIndex < 1 or fromIndex > #tbl or toIndex < 1 or toIndex > #tbl) then
        print('Error in Move: Indexes must be within the bounds of the table.')
        return
    end

    local value = tbl[fromIndex]
    self:Remove(tbl, fromIndex)
    self:Add(tbl, toIndex, value)
end


--- Function to pack multiple items into a table
-- @param ...: The items to pack.
-- @return: A table containing the packed items.
function Table:Pack(...)
    local packed = {}

    for _, value in ipairs({...}) do
        self:Add(packed, value)
    end

    return packed
end


--- Function to shuffle a table randomly
-- @param tbl: The table to shuffle.
function Table:Shuffle(tbl)
    if (not checkTable(tbl, 'Shuffle')) then return end

    local n = #tbl
    for i = n, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
end


--- Function to sort a table
-- @param tbl: The table to sort.
-- @param comparator: Optional comparator function for sorting.
function Table:Sort(tbl, comparator)
    if (not checkTable(tbl, 'Sort')) then return end

    table.sort(tbl, comparator)
end


--- Function to sort keys based on their values
-- @param tbl: The table to be sorted.
-- @return: A new table with keys sorted by their values.
function Table:SortByKey(tbl)
    if (not checkTable(tbl, 'SortByKey')) then return {} end

    local sortedKeys = self:GetKeys(tbl)
    self:Sort(sortedKeys, function(a, b) return tbl[a] < tbl[b] end)

    local sortedTable = {}
    for _, key in ipairs(sortedKeys) do
        sortedTable[key] = tbl[key]
    end

    return sortedTable
end


--- Function to sort a table by a specific member
-- @param tbl: The table to sort.
-- @param member: The member to sort by.
-- @param descending: If true, sort in descending order; otherwise, sort in ascending order.
function Table:SortByMember(tbl, member, descending)
    if (not checkTable(tbl, 'SortByMember')) then return end

    -- Checking for the presence of a member in each element
    for _, item in ipairs(tbl) do
        if (item[member] == nil) then
            error('Member "' .. member .. '" does not exist in one of the table elements.')
        end
    end

    -- Define the comparison function depending on the sorting order
    local compareFunction
    if descending then
        compareFunction = function(a, b) return a[member] < b[member] end
    else
        compareFunction = function(a, b) return a[member] > b[member] end
    end

    self:Sort(tbl, compareFunction)
    
    return tbl -- Return the sorted table (if necessary)
end



--- Function to sort a table in descending order
-- @param tbl: The table to sort.
-- @param comparator: Optional comparator function for sorting.
function Table:SortDesc(tbl, comparator)
    if (not checkTable(tbl, 'SortDesc')) then return end

    self:Sort(tbl, function(a, b) return not comparator(a, b) end)
end


--- Function to convert a table to a string
-- @param tbl: The table to convert.
-- @return: A string representation of the table.
function Table:ToString(tbl)
    if (not checkTable(tbl, 'ToString')) then return '{}' end

    local str = '{'
    for k, v in pairs(tbl) do
        str = str .. tostring(k) .. ': ' .. tostring(v) .. ', '
    end

    if (#str > 1) then
        str = str:sub(1, -3) -- Remove last comma and space
    end

    str = str .. '}'
    return str
end


--- Function to deep copy a table
-- @param orig: The table to deep copy.
-- @return: A new table that is a deep copy of the original.
function Table:DeepCopy(orig)
    if (not checkTable(orig, 'DeepCopy')) then return {} end

    local orig_type = type(orig)
    local copy
    if (orig_type == 'table') then
        copy = {}

        for orig_key, orig_value in next, orig, nil do
            copy[self:DeepCopy(orig_key)] = self:DeepCopy(orig_value)
        end

        setmetatable(copy, self:DeepCopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end

    return copy
end


--- Function to get the values of a table as an array
-- @param tbl: The table to convert.
-- @return: An array of values.
function Table:GetValues(tbl)
    if (not checkTable(tbl, 'GetValues')) then return {} end

    local values = {}
    for _, v in pairs(tbl) do
        self:Add(values, v)
    end

    return values
end


--- Function to remove a key-value pair from a table
-- @param tbl: The table to modify.
-- @param key: The key to remove.
function Table:Remove(tbl, key)
    if (not checkTable(tbl, 'Remove')) then return end
    table.remove(tbl, key)
end


--- Function to merge multiple tables
-- @param ...: The tables to merge.
-- @return: A new table containing merged values from all tables.
function Table:MergeMultiple(...)
    local merged = {}

    for _, tbl in ipairs({...}) do
        if (type(tbl) == 'table') then
            merged = self:Merge(merged, tbl)
        else
            print('Warning: Ignoring non-table argument during merge.')
        end
    end

    return merged
end


--- Function to remove a value from a table by its value
-- @param tbl: The table to remove from.
-- @param value: The value to remove.
function Table:RemoveByValue(tbl, value)
    for key, v in pairs(tbl) do
        if (v == value) then
            tbl[key] = nil
            break
        end
    end
end


--- Function to print the contents of a table
-- @param tbl: The table to print.
-- @param indent: Optional indentation level for nested tables.
function Table:Print(tbl, indent)
    indent = indent or 0
    for key, value in pairs(tbl) do
        local prefix = string.rep('  ', indent) .. tostring(key) .. ': '

        if (type(value) == 'table') then
            print(prefix)
            self:Print(value, indent + 1)
        else
            print(prefix .. tostring(value))
        end
    end
end


--- Function to get a deep count of all values in a nested table
-- @param tbl: The table to count.
-- @return: Total count of values in the table.
function Table:DeepCount(tbl)
    if (not checkTable(tbl, 'DeepCount')) then return 0 end

    local count = 0
    local function countValues(t)
        for _, value in pairs(t) do
            if (type(value) == 'table') then
                countValues(value)
            else
                count = count + 1
            end
        end
    end

    countValues(tbl)
    return count
end


--- Function to create a new table with a specified size
-- @param size: The desired size of the new table.
-- @return: A new table with the specified size.
function Table:CreateWithSize(size)
	if type(size) ~= 'number' or size < 0 then
        print('Error in CreateWithSize: Size must be a non-negative number.')
        return {}
    end

    local newTable = {}
    for i = 1, size do
        newTable[i] = nil
    end

    return newTable
end


--- Function to get a random key from a table
-- @param tbl: The table to get a random key from.
-- @return: A random key from the table.
function Table:GetRandomKey(tbl)
	if (not checkTable(tbl, 'GetRandomKey')) then return nil end

    local keys = self:GetKeys(tbl)
    if (#keys == 0) then
    	return nil
    end

    return keys[math.random(#keys)]
end


--- Function to get a random value from a table
-- @param tbl: The table to get a random value from.
-- @return: A random value from the table.
function Table:GetRandomValue(tbl)
	if (not checkTable(tbl, 'GetRandomValue')) then return nil end

    local randomIndex = math.random(1, #tbl)
    return tbl[randomIndex] -- Возвращаем случайный элемент из таблицы
end
