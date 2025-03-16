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
 *   sh_print.lua
 *   This module provides utility functions for formatted console output within the DanLib framework.
 *
 *   The following components are included:
 *   - DanLib.Utils.Print: A function that prints a message to the console with a specific format,
 *     including a prefix indicating the source of the message.
 *   - DanLib.Utils.PrintType: A function that prints a message with a specified type label (e.g., 
 *     'Info', 'Warning'), allowing for better categorization of log messages.
 *   - DanLib.Utils.Error: A function that prints an error message in red and halts execution 
 *     without terminating the script, providing a clear indication of issues.
 *
 *   This module is designed to enhance the logging and debugging capabilities of the DanLib framework,
 *   making it easier for developers to track messages and errors during development and runtime.
 *
 *   Usage example:
 *   - To print a standard message:
 *     DanLib.Func:Print('This is a standard message.')
 *
 *   - To print a message with a type:
 *     DanLib.Func:PrintType('Warning', 'This is a warning message.')
 *
 *   - To print an error message:
 *     DanLib.Func:PrintError('This is an error message.')
 *
 *   @notes 
 *        For more information, refer to the DanLib documentation.
 */



local base = DanLib.Func
local colorBlue = Color(30, 144, 255)
local colorError = Color(255, 0, 0)
local prefix = 'DanLib'
local logDir = 'danlib/logs/' -- Log directory


-- Get the current date and time in the format "YYYYY-MM-DD HH:MM:SS"
local function getCurrentTime()
    return os.date('%Y-%m-%d %H:%M:%S')
end


-- Check and create a directory for logs if it does not exist
local function ensureLogDirectoryExists()
    if (not file.Exists(logDir, 'DATA')) then
        file.CreateDir(logDir)
    end
end


-- Logging to a file with dynamic filename
local function logToFile(message, logType)
    ensureLogDirectoryExists() -- Let's make sure the directory exists

    local filename = logDir .. 'log.txt' -- Default main log file

    if (logType == 'Error') then
        filename = logDir .. 'error_log.txt' -- Log file for errors
    end

    file.Append(filename, message .. '\n') -- Use file.Append to append to the file
end


--- Prints a message to the console with a specific format.
-- @param ... any: The message content to print. Can accept multiple arguments.
function base:Print(message)
    MsgC(colorBlue, '[', color_white, prefix, colorBlue, '] ', color_white, message)
    MsgC('\n') -- Print a newline for better readability
end


--- Prints a message to the console with a specific type label.
-- @param type string: The type label to include in the message (e.g., 'Info', 'Warning').
-- @param ... any: The message content to print. Can accept multiple arguments.
function base:PrintType(type, message)
    MsgC(colorBlue, '[', color_white, prefix, colorBlue, ']', Color(255, 215, 0), '[', color_white, type, Color(255, 215, 0), '] ', color_white, message)
    MsgC('\n') -- Print a newline for better readability
    
    -- Write only if the type is 'Logs'
    if (type == 'Logs' or type == 'SQL') then
        logToFile(getCurrentTime() .. ' - ' .. type .. ': ' .. message) -- Add date and time
    end
end


--- Prints an error message to the console with a specific format.
-- @param ... any: The error message content to print. Can accept multiple arguments.
function base:PrintError(message)
    if (type(message) ~= 'string') then message = 'Unknown error' end
    print(message)
    self:Print(colorBlue, '[', color_white, prefix, colorBlue, ']', colorError, '[ ', color_white, 'Error', colorError, ' ] ', message)
    -- ErrorNoHalt('[DanLib] ', message) -- Halts the execution but does not terminate the script
    logToFile(getCurrentTime() .. ' - Error: ' .. message, 'Error') -- Write to the error file
end
