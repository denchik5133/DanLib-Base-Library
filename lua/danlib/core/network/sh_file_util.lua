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
 *   sh_file_util.lua
 *   This file contains a set of utility functions for managing file operations within the DanLib project.
 *
 *   The following functions are included:
 *   - Exists: Checks if a specified file or directory exists.
 *   - CreateDir: Creates a directory if it does not already exist.
 *   - Find: Searches for files matching a given pattern and returns a list of found files.
 *   - Read: Reads the contents of a specified file and returns it as a string.
 *   - Write: Writes data to a specified file.
 *
 *   The file is designed to facilitate file management tasks, ensuring ease of use and reliability
 *   when interacting with the file system in the game environment.
 *
 *   Usage example:
 *   - To check if a file exists: DanLib.FileUtil.Exists("path/to/file.txt")
 *   - To create a directory: DanLib.FileUtil.CreateDir("path/to/directory")
 *   - To find files: DanLib.FileUtil.Find("path/to/*.txt")
 *   - To read a file: DanLib.FileUtil.Read("path/to/file.txt")
 *   - To write to a file: DanLib.FileUtil.Write("path/to/file.txt", "Hello, World!")
 *
 *   Note: Ensure that all file paths are correctly specified relative to the game's data directory.
 */



--- Functions for working with the file system
DanLib.FileUtil = DanLib.FileUtil or {}


--- Checks if a file or directory exists
-- @param path: Path to the file or directory
-- @return: true if the file or directory exists, otherwise false
function DanLib.FileUtil.Exists(path)
    assert(type(path) == 'string', 'Expected a string for path in Exists.')
    return file.Exists(path, 'DATA')
end


--- Creates a directory
-- @param dir: Path to the directory to be created
-- @return: true if the directory was created, false if it already exists
function DanLib.FileUtil.CreateDir(dir)
    assert(type(dir) == 'string', 'Expected a string for dir in CreateDir.')
    
    if (not file.Exists(dir, 'DATA')) then
        file.CreateDir(dir)
        return true  -- Directory created successfully
    end

    return false  -- Directory already exists
end


--- Finds files by pattern
-- @param pattern: Search pattern
-- @return: Table of found files
function DanLib.FileUtil.Find(pattern)
    assert(type(pattern) == 'string', 'Expected a string for pattern in Find.')
    return file.Find(pattern, 'DATA')
end


--- Reads the contents of a file
-- @param filename: The name of the file to read
-- @return: The contents of the file or nil if the file is not found
-- @return: error (string) if a reading error occurred
function DanLib.FileUtil.Read(filename)
    assert(type(filename) == 'string', 'Expected a string for filename in Read.')

    local content, err = file.Read(filename, "DATA")
    if (not content) then
        return nil, err  -- Return nil and an error if the file is not found
    end

    return content
end


--- Writes data to a file
-- @param filename: The name of the file to write to
-- @param data: The data to write to the file
-- @return: true if the write was successful, false otherwise
function DanLib.FileUtil.Write(filename, data)
    assert(type(filename) == 'string', 'Expected a string for filename in Write.')
    assert(type(data) == 'string', 'Expected a string for data in Write.')
    
    local success, err = file.Write(filename, data, 'DATA')
    if (not success) then
        return false, err  -- Return false and an error if the write failed
    end

    return true  -- Write successful
end
