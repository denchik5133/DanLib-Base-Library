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
 *   sh_loader.lua
 *   This file is used to control the loading of Lua files in the DanLib project.
 *
 *   It includes features for:
 *   - Removing prefixes (sv_, cl_, sh_) from file names.
 *   - Logging of the file upload process with time.
 *   - Includes individual files depending on their prefix and current area (server, client or shared).
 *   - Recursively include files from a directory.
 *   - Specifies the download colour and registration of the download completion.
 *
 *   The file provides a convenient interface for loading and managing Lua scripts in a project.
 */



-- Global table for the DanLib library.
-- It is loaded automatically at startup (in autorun).
-- Used to store library functions and methods.


-- @module DanLib
-- @field loader: A table for the loader containing functions and methods for loading resources.
DanLib = DanLib or {} -- Create or use an existing DanLib global table
DanLib.loader = DanLib.loader or {} -- Create or use an existing loader table in DanLib


--- Removes the realm prefix from a file name. The returned string will be unchanged if there is no prefix found.
-- @param name: The file name from which to strip the realm prefix.
-- @return: The file name without the realm prefix.
function DanLib.loader.StripRealmPrefix(name)
    local prefix = name:sub(1, 3)

    return (prefix == 'sh_' or prefix == 'sv_' or prefix == 'cl_') and name:sub(4) or name
end


--- Returns the current time in the format "HH:MM:SS".
-- @return: The formatted current time as a string.
local function printTime()
    -- get the current time in the form of a table
    local tbl = os.date('*t')
    -- format the time into a string
    -- display the time in the console
    return string.format('%02d:%02d:%02d', tbl.hour, tbl.min, tbl.sec)
end


--- LOADER class definition
-- @class LOADER
-- @field m_name: Loader name (string).
-- @field m_loadDirectory: The directory from which resources are loaded (string).
-- @field m_color: The colour associated with the loader (colour).
local LOADER = {}
LOADER.__index = LOADER

--- Function for accessing the loader name
-- @param self: Reference to the current object
-- @return string: Loader name
AccessorFunc(LOADER, 'm_name', 'Name')

--- Function for accessing the download directory
-- @param self: Reference to the current object
-- @return string: Download directory
AccessorFunc(LOADER, 'm_loadDirectory', 'LoadDirectory')

--- Function to access the colour of the loader
-- @param self: Reference to the current object
-- @return color: Loader colour
AccessorFunc(LOADER, 'm_color', 'Color')


--- Returns the loading color for the loader.
-- @return: The color assigned to the loader.
function LOADER:GetLoadColor()
    return self:GetColor()
end


--- Logs a message indicating that loading has started.
-- This function prints a message to the console with the loader's name and the current time.
function LOADER:SetStartsLoading()
    local col = Color(30, 144, 255)
    MsgC(col, '\n[', color_white, self:GetName(), col, '] ', Color(225, 177, 44), 'Starts loading ', Color(48, 213, 200), printTime() .. '\n')
end


--- Logs a message indicating that a file has been loaded.
-- @param path: The path of the file that has been loaded.
function LOADER:GetLoadMessage(path)
    local col = Color(30, 144, 255)
    MsgC(col, '[', color_white, self:GetName(), col, ']', Color(225, 177, 44), '[', Color(0, 255, 0), 'Loaded', Color(225, 177, 44), '] ', color_white, path .. '\n')
end


--- Includes a Lua file by automatically determining its type based on the file's prefix.
-- This function will call `include` and `AddCSLuaFile` as needed, depending on whether the file is server, client, or shared.
-- The function checks the file name for specific prefixes ('sv_', 'cl_', 'sh_') to determine the appropriate action.
-- @param fileName: The name of the file to include.
function LOADER:Include(fileName, realm)
    if (not fileName) then
        error('No file name specified for including.')
    end

    -- Only include server-side if we're on the server.
    if ((realm == 'server' or fileName:find('sv_')) and SERVER) then
        return include(fileName)
    -- Shared is included by both server and client.
    elseif (realm == 'shared' or fileName:find('shared.lua') or fileName:find('sh_')) then
        if (SERVER) then
            -- Send the file to the client if shared so they can run it.
            AddCSLuaFile(fileName)
        end
        return include(fileName)
    -- File is sent to client, included on client.
    elseif (realm == 'client' or fileName:find('cl_')) then
        if (SERVER) then
            AddCSLuaFile(fileName)
        else
            return include(fileName)
        end
    end
end


--- Includes multiple Lua files from a specified directory by automatically determining their type based on file prefixes.
-- This function can recursively include files from subdirectories, skipping any files specified in the ignore list.
-- @param directory: The directory from which to include files.
-- @param recursive: A boolean indicating whether to include files in subdirectories.
-- @param ignoreFiles: A table of files to ignore during inclusion.
function LOADER:IncludeDir(directory, recursive, ignoreFiles)
    ignoreFiles = ignoreFiles or {}
    local path = self:GetLoadDirectory()
    local indent = '   ' -- Initial indent value

    -- Function for adding a slash to the end of a line
    local function ensureTrailingSlash(str)
        return str .. (string.EndsWith(str, '/') and '' or '/')
    end

    path = ensureTrailingSlash(path)
    directory = ensureTrailingSlash(directory)

    -- Checking the existence of a directory
    if (not file.IsDir(path .. directory, 'LUA')) then
        print(indent .. '>> DanLib << Directory does not exist: ' .. directory)
        return
    end

    local files, folders = file.Find(path .. directory .. '*', 'LUA')
    if (not files) then
        print(indent .. '>> DanLib << No files found in directory: ' .. directory)
        return
    end
    
    -- Displaying the directory name
    local lastFolder = #folders > 0 and folders[#folders] or nil
    print(indent .. '┗ ' .. directory)

    -- Recursive loading of subdirectories
    for i, folder in ipairs(folders) do
        local isLast = (folder == lastFolder)
        local newIndent = indent .. (isLast and '    ' or '┃    ')
        print(newIndent .. '┃    ' .. folder .. '/') -- Print the current directory with an indentation
        self:IncludeDir(directory .. folder, true, ignoreFiles, newIndent) -- Recursive call for subdirectories
    end

    -- Uploading files in the current directory
    for i, file in ipairs(files) do
        if (ignoreFiles[file] ~= true) then
            local filePath = directory .. file -- Remove the prefix .../core/
            self:Include(path .. filePath) -- Upload file with full path
            
            -- Печатаем имя файла с правильным отступом
            if (i == #files and #folders == 0) then
                print(indent .. '┃   ┗ ' .. file) -- If this is the last file in the last directory, use ┗
            else
                print(indent .. '┃   ┣ ' .. file) -- Otherwise, use ┣ with ┃
            end
        end
    end
end


--- Logs a message indicating that the loading process has finished.
-- This function prints the total loading time to the console.
function LOADER:Register()
    local time = math.Round(SysTime() - self.start, 4) .. 's'
    local col = Color(30, 144, 255)

    MsgC(col, '[', color_white, self:GetName(), col, ']', Color(225, 177, 44), ' finished downloading. Loading time ', Color(48, 213, 200), time .. '\n')
end


--- Creates a new loader instance.
-- This function copies the LOADER table and initializes the start time for loading.
-- @return: A new loader instance.
function DanLib.Func.CreateLoader()
    local tbl = table.Copy(LOADER)
    tbl.start = SysTime()

    return tbl
end
