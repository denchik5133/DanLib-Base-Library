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
 *   sh_logs.lua
 *   This file contains utility functions and structures for managing logs within the DanLib project.
 *
 *   The following functions and methods are included:
 *   - CreateLogs: Creates a new log object with a specified ID.
 *   - Register: Registers the current log in the global logs table.
 *   - SetTitle: Sets the title of the log.
 *   - SetDescription: Sets the description of the log.
 *   - SetColor: Sets the color of the log.
 *   - SetSort: Sets the sort order of the log.
 *   - SetSetup: Sets the setup function for the log.
 *   - LoadLogs: Loads all log files from the specified directory.
 *
 *   This file is designed to facilitate log management tasks, allowing for easy organization
 *   and tracking of events and information in the game environment.
 *
 *   Usage example:
 *   - To create a new log:
 *     local myLog = DanLib.Func.CreateLogs('my_custom_log')
 *     myLog:SetTitle('My Custom Log')
 *     myLog:SetDescription('This log tracks custom events in my game.')
 *     myLog:SetColor(Color(0, 255, 0)) -- Set log color to green
 *     myLog:SetSort(1) -- Set sort order
 *     myLog:Register()
 *
 *   - To load all logs:
 *     DanLib.Func.LoadLogs()
 *
 *   @notes: Ensure that log IDs are unique to avoid conflicts. All log files should be placed
 *   in the specified logs directory for proper loading.
 */

 


DanLib.ModulesMetaLogs = {}

local LogsMeta = {
	--- Registers the log by adding it to the global logs table
	-- This method also calls the setup function if defined.
	Register = function(self)
        DanLib.ModulesMetaLogs[self.ID] = self
        self.SetupFunc()
	end,

	--- Sets the title of the log
	-- @param title: The title to set for the log.
	-- @return: The log object for method chaining.
	SetTitle = function(self, title)
        self.Title = title
        return self
	end,

	--- Sets the description of the log
	-- @param description: The description to set for the log.
	-- @return: The log object for method chaining.
	SetDescription = function(self, description)
		self.Description = description
		return self
	end,

	--- Sets the color of the log
	-- @param color: The color to set for the log.
	-- @return: The log object for method chaining.
	SetColor =  function(self, color)
		self.Color = color
		return self
	end,

	--- Sets the sort order of the log
	-- @param sortOrder: The sort order to set for the log.
	-- @return: The log object for method chaining.
	SetSort = function(self, sortOrder)
        self.Sort = sortOrder
        return self
	end,

	--- Sets the setup function for the log
	-- @param func: The function to set as the setup function.
	-- @return: The log object for method chaining.
	SetSetup = function(self, func)
		self.SetupFunc = func
		return self
	end
}

LogsMeta['__index'] = LogsMeta


--- Creates a new log object with the given ID
-- @param id: The identifier for the new log.
-- @return: A new log object with the specified ID.
function DanLib.Func.CreateLogs(id)
	local Log = { ID = id, Option = {}, Sort = 0 }
	setmetatable(Log, LogsMeta)
	return Log
end


local LogsFile = 'danlib/logs/'

--- Loads log files from the specified directory
-- This function includes all Lua files found in the logs directory.
function DanLib.Func.LoadLogs()
	for k, file in ipairs(file.Find(LogsFile .. '*.lua', 'LUA')) do
		AddCSLuaFile(LogsFile .. file)
		include(LogsFile .. file)
	end
end