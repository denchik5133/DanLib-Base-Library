/***
 *   @addon        	DanLib
 *   @version       3.0.0
 *   @release_date 	10/4/2023
 *   @author       	denchik
 *   @contact      	Discord: denchik_gm
 *                 	Steam: https://steamcommunity.com/profiles/76561198405398290/
 *                 	GitHub: https://github.com/denchik5133
 *				  
 *   @description  	Universal library for GMod Lua, combining all the necessary features to simplify script development. 
 * 					Avoid code duplication and speed up the creation process with this powerful and convenient library.
 *
 *   @usage 		!danlibmenu (chat) | danlibmenu (console)
 *   @license 		MIT License
 *   @credits      	Please credit the author (denchik) when using this code.
 *   @notes        	For feature requests or contributions, please open an issue on GitHub.
 */


/***
 *   sh_error_handling.lua
 *   This file is responsible for managing error logging and safe execution in the DanLib project.
 *
 *   It includes the following functions:
 *   - Logging errors to a file (LogError).
 *   - Safely executing a function with error handling (DanLib.Protection:SafeExecute).
 *   - Cleaning old log files (DanLib.Protection.CleanOldLogs).
 *
 *   Example of use:
 *       - Example of using DanLib.Protection:SafeExecute to execute code with DanLib
 *       - Replace this code with your own code
 *       DanLib.Protection:SafeExecute(function()
 *           -- Code that can cause an error
 *           error('This is an example of a mistake!') -- Artificial error for demonstration
 *       end)
 *
 *       - You can use DanLib.Protection:SafeExecute wherever you call DanLib functions
 *       DanLib.Protection:SafeExecute(function()
 *
 *       end)
 *
 *   - Example of using DanLib.Protection.CleanOldLogs:
 *       - You can call this function to clean up old log files.
 *       - It takes two optional parameters:
 *           - maxFiles: Maximum number of log files to keep (default: 10).
 *           - maxAgeDays: Maximum age of log files to keep in days (default: 4).
 *       - Example usage:
 *           DanLib.Protection.CleanOldLogs(10, 4) -- Keeps 10 log files and deletes files older than 4 days.
 *
 *   The file provides a comprehensive interface for handling error logging and 
 *   ensuring that functions can be executed safely without crashing the application.
 */



DanLib = DanLib or {}
DanLib.Protection = DanLib.Protection or {}


--- Directory for storing logs
local logDir = 'danlib/logs'


--- Make sure that a folder for logs exists
if (not file.Exists(logDir, 'DATA')) then
    file.CreateDir(logDir)
end


--- Function for error logging
-- @param message: The error message to be logged.
-- Writes the error message to a file with the current date.
local function LogError(message)
	-- Get the current date and time
    local date = os.date('%Y-%m-%d %H:%M:%S')

    -- Form the file name
    local fileName = string.format('%s/logs_%s.txt', logDir, os.date('%Y-%m-%d'))

    -- Format the message for the log
    local logMessage = string.format('[%s] ERROR: %s\n', date, message)

    -- Attempt to write the message to a file
    local success, err = pcall(function()
        file.Append(fileName, logMessage)
    end)

    -- Handle error if logging fails
    if (not success) then
        print('Failed to log error: ' .. err)
    end

    -- Print the error message to the console with a file path
    print('ERROR: ' .. message .. '\n - More details in ' .. fileName)
end


--- Function to catch errors
-- @param func: The function to be executed with error handling.
-- @return: The result of the function execution or nil in case of an error.
-- Executes the function and logs the error if it occurs.
function DanLib.Protection:SafeExecute(func)
    if (type(func) ~= 'function') then
        LogError('Provided parameter is not a function.')
        error('Execution halted: Provided parameter is not a function.')
    end

    -- Execute the function with error handling
    local success, result = pcall(func)

    -- Logging error and stack trace
    if (not success) then
        LogError(result .. '\n' .. debug.traceback())

        -- Notify that the code will not be executed further
        error('Execution halted due to error: ' .. result)
    end

    -- Return the result of the function execution
    return result
end


--- Function to clean old log files
-- @param maxFiles: Maximum number of log files to keep (default: 10).
-- @param maxAgeDays: Maximum age of log files to keep in days (default: 4).
function DanLib.Protection:CleanOldLogs(maxFiles, maxAgeDays)
    maxFiles = maxFiles or 10
    maxAgeDays = maxAgeDays or 4

    local files = file.Find(logDir .. '/*.txt', 'DATA')
    local currentTime = os.time()
    local filesToDelete = {}

    -- Calculate the threshold time for deletion
    local maxAgeSeconds = maxAgeDays * 24 * 60 * 60 -- Convert days to seconds

    -- Check each file for existence and collect files for deletion
    for _, fileName in ipairs(files) do
        local filePath = logDir .. '/' .. fileName
        
        if file.Exists(filePath, 'DATA') then
            -- Extract the date from the filename (assuming the format is something like "log_YYYYMMDD.txt")
            local year, month, day = fileName:match("logs_(%d%d%d%d)%-(%d%d)%-(%d%d)%.txt")
            
            if (year and month and day) then
                -- Create a timestamp from the extracted date
                local fileDate = os.time({
                    year = tonumber(year),
                    month = tonumber(month),
                    day = tonumber(day),
                    hour = 0,
                    min = 0,
                    sec = 0
                })

                -- Check if the file is older than the maxAgeDays
                if (currentTime - fileDate) > maxAgeSeconds then
                    table.insert(filesToDelete, filePath)
                end
            end
        else
            print("The file doesn't exist: " .. filePath)
        end
    end

    -- If the number of files exceeds the maximum, delete the old ones
    if (#files > maxFiles) then
        local filesToKeep = #files - maxFiles
        -- Sort files by name (or other criteria, if possible)
        table.sort(files, function(a, b)
            return a < b
        end)

        for i = 1, filesToKeep do
            table.insert(filesToDelete, logDir .. '/' .. files[i])
        end
    end

    -- Deleting collected files
    for _, fileToDelete in ipairs(filesToDelete) do
        file.Delete(fileToDelete)
        print('The log file has been deleted: ' .. fileToDelete) -- Successful deletion log
    end
end

--- Call the CleanOldLogs function when the addon loads
hook.Add('Initialize', 'DanLib.Protection.CleanOldLogs', function()
	-- Keep 10 log files, delete files older than 4 days
    DanLib.Protection.CleanOldLogs(10, 4)
end)
