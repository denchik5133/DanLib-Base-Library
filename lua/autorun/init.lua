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
 


DanLib_AddonsName, DanLib_Version, DanLib_Author, DanLib_Key = 'DanLib Basic Library', '3.0.0', '76561198405398290', '' 

-- Create a Variables/Tables workspace table.
DanLib = DanLib or {}
DanLib = {
    AddonsName = DanLib_AddonsName,
    Author = DanLib_Author,
    Version = DanLib_Version,
    Key = DanLib_Key,
    Config = {
        Style = {},
        Theme = {},
        Description = {},
        Different = {}
    },
    Panels = {},
    Utils = {},
    Modules = {},
    Func = {},
    BaseConfig = {},
    Temp = {},
    Permissions = {},
    Logs = {},
    FileUtil = {},
    NetworkUtil = {}
}
DanLibUI = DanLibUI or {}

DDI = DDI or {}
DDI = {
    Func = {},
    Config = {},
    Utils = {},
    Temp = {}
}


--- Defines the available data types for the configuration.
-- @table DanLib.Type: A table containing the main data types used in the project.
-- @field Int: Data type for integers.
-- @field String: Data type for strings.
-- @field Bool: Data type for logical values (true/false).
-- @field Table: Data type for tables.
-- @field Key: Data type for keys (strings).
DanLib.Type = {
    Int = 'Int',
    String = 'String',
    Bool = 'Bool',
    Table = 'Table',
    Key = 'Key'
}


local function loadingFunctionType()
    --- Defines functions for working with data types.
    -- @table DanLib.FunctionType: A table containing functions for writing and reading different data types.
    -- @field Int: Functions for working with integers.
    -- @field String: Functions for working with strings.
    -- @field Bool: Functions for working with logical values.
    -- @field Key: Functions for working with keys.
    -- @field Table: Functions for working with tables.
    DanLib.FunctionType = {
        Int = {
            NetWrite = function(value) DanLib.Network:WriteInt(value, 32) end,
            NetRead = function() return DanLib.Network:ReadInt(32) end
        },
        String = {
            NetWrite = function(value) DanLib.Network:WriteString(value) end,
            NetRead = function() return DanLib.Network:ReadString() end
        },
        Bool = {
            NetWrite = function(value) DanLib.Network:WriteBool(value) end,
            NetRead = function() return DanLib.Network:ReadBool() end
        },
        Key = {
            NetWrite = function(value) DanLib.Network:WriteString(value) end,
            NetRead = function() return DanLib.Network:ReadString() end,
            CopyFunc = function(value) return value end
        },
        Table = {
            NetWrite = function(value) DanLib.Network:WriteString(DanLib.NetworkUtil:TableToJSON(value)) end,
            NetRead = function() return DanLib.NetworkUtil:JSONToTable(DanLib.Network:ReadString()) end,
            CopyFunc = function(value) return table.Copy(value) end
        }
    }
end


AddCSLuaFile()

if (CLIENT) then
    include('danlib/core/sh_loader.lua')
    include('danlib/cl_init.lua')
elseif (SERVER) then
    include('danlib/core/sh_loader.lua')
    AddCSLuaFile('danlib/core/sh_loader.lua')

    AddCSLuaFile('danlib/cl_init.lua')
    AddCSLuaFile('danlib/sh_init.lua')
    AddCSLuaFile('danlib/sv_init.lua') 
    include('danlib/sv_init.lua')

    -- Resources
    resource.AddFile('resource/fonts/montserrat-medium.ttf')
    resource.AddFile('resource/fonts/montserrat-regular.ttf')
    
    -- UI Sounds
    resource.AddFile('sound/ddi/button-click.wav')
    resource.AddFile('sound/ddi/button-hover.wav')
    resource.AddFile('sound/ddi/error.mp3')
    resource.AddFile('sound/ddi/notifications.wav')
end

include('danlib/sh_init.lua')


local function FancyPrint()
    local fancy = [[
       /\_/\  
      ( o.o ) 
       > ^ <
    [*] Version: ]] .. DanLib.Version .. '\n'

    MsgC(Color(255, 165, 0), fancy)
end

-- print(file.IsDir('danlib/core/sqlite', 'LUA'))

local function Start()
    local BASE = DanLib.Func.CreateLoader()
    BASE:SetName('DanLib')
    BASE:SetStartsLoading()
    BASE:SetLoadDirectory('danlib')
    -- Loading a network library (new catalogue)
    BASE:IncludeDir('core/network') -- Uploading all files in the network directory
    loadingFunctionType()
    BASE:IncludeDir('core/ui_components')
    -- Configuration download
    BASE:IncludeDir('core/config') -- Load all files in the config directory
    -- Uploading metadata
    BASE:IncludeDir('core/meta') -- Upload all files in the meta directory
    -- Downloading files from netstream with some files ignored
    -- BASE:IncludeDir('core/netstream', true, {
    --    ['sh_pon.lua'] = false,        -- Ignore this file (will not be downloaded)
    --    ['sh_nw.lua'] = false,          -- Enable this file (will be downloaded)
    --    ['sh_netstream.lua'] = false,   -- Enable this file (will be downloaded)
    --})
    -- Upload all files from the shared directory
    BASE:IncludeDir('shared') -- Upload all files in the shared directory
    -- Downloading utilities
    BASE:IncludeDir('core/utils') -- Load all files in the utilities directory
    -- Loading auxiliary functions and elements
    BASE:IncludeDir('core/shared') -- Upload all files in the shared directory
    -- Downloading the language files
    DanLib.Func.LoadLanguages()
    -- Downloading themes for the interface
    DanLib.Func.LoadThemes()
    -- Uploading gamemodes
    DanLib.Func.LoadGamemodes()
    -- Uploading chat commands
    DanLib.Func.LoadCommands()
    -- Uploading client files
    BASE:IncludeDir('core/client') -- Upload all files in the client file directories
    -- Loading the main menu pages
    BASE:IncludeDir('core/pages') -- Upload all files to the menu page directories
    -- Loading the main hud
    BASE:IncludeDir('core/hud_elements') -- Upload all files to the hud directories
    -- Loading user interface elements
    BASE:IncludeDir('vgui') -- Download all files in the vgui directory
    -- Uploading server files
    if SERVER then
        BASE:IncludeDir('core/server') -- Upload all files to the server file directories
        -- Downloading SQLite
        BASE:IncludeDir('core/sqlite') -- Upload all files in the mysqlite directory
    end
    -- Downloading the logs
    DanLib.Func.LoadLogs()
    FancyPrint()
    -- Finish downloading and registering all modules
    BASE:Register()
end
Start()

DanLib.Loading = DanLib.Loading or {}
DanLib.Loading.Start = Start



local WORKSHOP_VERSION = CreateConVar('danlib_version_warnings', '1', FCVAR_ARCHIVE, 'Should we warn users if Base is outdated')
local workshop_id = '2418668622'
local is_workshop = nil
local colors = {
    [1] = Color(255, 140, 0),
    [2] = Color(0, 255, 0),
    [3] = color_white
}

function DanLib.Func:VersionWorkshopCheck()
    if (is_workshop ~= nil) then return is_workshop end

    for _, v in ipairs(engine.GetAddons()) do
        if (v.wsid == workshop_id) then
            is_workshop = true
            return true
        end
    end

    is_workshop = false
    return false
end

local function NewVersion()
    if (not WORKSHOP_VERSION:GetBool()) then return end

    DanLib.Func:TimerSimple(5, function()
        if DanLib.Func:VersionWorkshopCheck() then
            DanLib.Func:Print('Running workshop version')
            return
        end

        DanLib.HTTP:Fetch('https://raw.githubusercontent.com/denchik5133/DDI-Other-Informations/main/DDI/update.json', function(body)
            local data = DanLib.NetworkUtil:JSONToTable(body)[DanLib_AddonsName]
            if (data ~= DanLib_Version) then
                if CLIENT then
                    chat.AddText(colors[1], '< ', colors[3], 'DanLib', colors[1], ' > ', colors[3], 'Current version: ', colors[1], DanLib_Version, colors[3], '. Need to upgrade to ', colors[2], data, colors[3], ' version. \n','See DanLib menu for details. In the help section.')
                else
                    MsgC(colors[1], '< ', colors[3], 'DanLib', colors[1], ' > ', colors[3], 'Current version: ', colors[1],  DanLib_Version, colors[3], '. Need to upgrade to ', colors[2], data, colors[3], ' version. \n','See DanLib menu for details. In the help section.')
                end
            end
        end)
    end)
end
NewVersion()


-- Downloading materials from Steam.
local function AddContent(WorkshopID)
    if SERVER then
        resource.AddWorkshop(WorkshopID)
    end
end

-- Base Content
AddContent('2418668622') -- danlib base content
