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
 *   sh_commands.lua
 *   This file contains utility functions and structures for managing commands within the DanLib project.
 *
 *   The following functions and methods are included:
 *   - CreateCommand: Creates a new command object with a specified name.
 *   - Register: Registers the current command in the global commands table.
 *   - SetCommand: Sets the name of the command.
 *   - SetDescription: Sets the description of the command.
 *   - SetAccess: Sets the access level required to execute the command.
 *   - SetOnRunFunction: Sets the function that will be called when the command is executed.
 *   - Run: Executes the command with the provided player and command text.
 *   - OnRun: Calls the Run function and triggers a hook when the command is executed.
 *   - LoadCommands: Loads all command files from the specified directory.
 *
 *   This file is designed to facilitate command management tasks, allowing for easy
 *   definition and execution of commands within the game environment.
 *
 *   Usage example:
 *   - To create a new command:
 *     local myCommand = DanLib.Func.CreateCommand('my_custom_command')
 *     myCommand:SetDescription('This command does something special.')
 *     myCommand:SetAccess({admin}) -- Set access level
 *     myCommand:SetOnRunFunction(function(player, ...)
 *         print(player:GetName() .. ' executed the command with arguments: ', ...)
 *     end)
 *     myCommand:Register()
 *
 *   - To load all commands:
 *     DanLib.Func.LoadCommands()
 *
 *   @notes: Ensure that command names are unique to avoid conflicts. All command files should be
 *   placed in the specified commands directory for proper loading.
 */




DanLib.Temp.Command = {}

local CommandMeta = {
    --- Function to execute the command
    -- @param pPlayer: Player who executes the command
    -- @param sText: Command text
    Run = function(self, pPlayer, sText)
        -- To edit
    end,

    --- Function to be called when the command is run
    -- @param pPlayer: Player who executes the command
    -- @param ...: Command text
    OnRun = function(self, pPlayer, ...)
        self.Run(pPlayer, ...)
        hook.Run('DanLib:CommandRun', self.command, pPlayer, ...)
    end,

    --- 
    Register = function(self)
        DanLib.Temp.Command[self.command] = self
	end,

    --- Setting the command
    -- @param cmd: Command name
    SetCommand = function(self, cmd)
        self.command = cmd
    end,

    --- Setting the command description
    -- @param desc: Command description
    SetDescription = function(self, desc)
        self.description = desc
    end,

    --- Setting the access level
    -- @param access: Access level for executing the command
    SetAccess = function(self, access)
        self.access = access
    end,

    --- Setting the function that will be called when the command is run
    -- @param func: Function to be executed
    SetOnRunFunction = function(self, func)
        self.Run = func
    end
}

CommandMeta['__index'] = CommandMeta


--- Function to create a new command
-- @param cmd: Command name
-- @param get: Flag indicating whether to get the command (default is false)
-- @return: Command table or nil if no command is found
DanLib.Func.CreateCommand = function(cmd, get)
    Commands = Commands or {}
    get = get or false
    
    -- Checking the existence of the command
    for k, v in ipairs(Commands) do
        if (v.command == cmd) then  return Commands[k] end
    end

    if get then return nil end

    -- Creating a new command table
    local CommandTable = { command = cmd }

    setmetatable(CommandTable, CommandMeta)

    local i = table.insert(Commands, CommandTable)
    return Commands[i]
end


-- Path to command files
local path = 'danlib/commands/'

-- Function for loading commands from files
DanLib.Func.LoadCommands = function()
    local CommandFiles = file.Find(path .. '*', 'LUA')

    -- Uploading each command file
    for k, file in ipairs(CommandFiles) do
        AddCSLuaFile(path .. file)
        include(path .. file)
    end
end


-- print(#DanLib.Temp.Command)