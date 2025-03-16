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
 *   cl_cookie_utils.lua
 *   This file defines the CookieUtils library, a collection of utility functions for managing cookies
 *   in Garry's Mod. These functions simplify the process of setting, getting, and deleting cookies,
 *   as well as providing additional functionality for cookie management.
 *
 *   The following methods are included:
 *   - Delete: Removes a cookie by its key.
 *   - GetNumber: Retrieves a cookie value as a number, with an optional default value.
 *   - GetString: Retrieves a cookie value as a string, with an optional default value.
 *   - Set: Sets a cookie value by its key.
 *   - Exists: Checks if a cookie exists by its key.
 *   - GetAll: Returns a table containing all cookies.
 *   - ClearAll: Deletes all cookies.
 *   - SetWithTTL: Sets a cookie with a specified time-to-live (TTL) after which it will be deleted.
 *
 *   The file is designed to facilitate cookie management in Garry's Mod, ensuring ease of use
 *   and flexibility in handling persistent data on the client side.
 *
 *   Usage example:
 *   - To set a cookie: DanLib.CookieUtils:Set('username', 'JohnDoe')
 *   - To get a cookie value: local username = DanLib.CookieUtils:GetString('username', 'Guest')
 *   - To check if a cookie exists: if DanLib.CookieUtils:Exists('username') then ... end
 *   - To delete a cookie: DanLib.CookieUtils:Delete('username')
 *   - To clear all cookies: DanLib.CookieUtils:ClearAll()
 *   - To set a cookie with TTL: DanLib.CookieUtils:SetWithTTL('session', 'abc123', 300)
 *
 *   Note: Ensure that all keys and values are of the correct type to avoid errors
 *   when managing cookies with this utility library.
 */



-- Global table for cookie functions
DanLib.CookieUtils = DanLib.CookieUtils or {}
DanLib.CookieUtils.keys = {} -- Table for storing cookie keys


-- Auxiliary function for type checking
local function validateKey(key)
    if (type(key) ~= 'string') then
        error('Cookie key must be a string.')
    end
end

local function validateValue(value)
    if (type(value) ~= 'string' and type(value) ~= 'number') then
        error('Cookie value must be a string or a number.')
    end
end


--- Deletes a cookie by key.
-- @param key string: The key of the cookie to delete.
function DanLib.CookieUtils:Delete(key)
    validateKey(key) -- Key verification
    cookie.Delete(key)
end


--- Gets the cookie value as a number with the option to specify a default value.
-- @param name: string The name of the cookie.
-- @param default any: Default value if cookie does not exist (defaults to nil).
-- @return number: The cookie value or default value.
function DanLib.CookieUtils:GetNumber(name, default)
    local value = cookie.GetNumber(name, default)
    return value
end


--- Gets the cookie value as a string with the option to specify a default value.
-- @param name: string The name of the cookie.
-- @param default: any Default value if cookie does not exist (defaults to nil).
-- @return string: The value of the cookie or the default value.
function DanLib.CookieUtils:GetString(name, default)
    local value = cookie.GetString(name, default)
    return value
end


--- Sets the value of the cookie.
-- @param key: string The key of the cookie.
-- @param value string: The value of the cookie.
function DanLib.CookieUtils:Set(key, value)
	validateKey(key) -- Key verification
    validateValue(value) -- Value check

    cookie.Set(key, value) -- Save the value as a string
    table.insert(DanLib.CookieUtils.keys, key) -- Add a key to the table
end


--- Checks if a cookie with the given key exists.
-- @param key string: Key of the cookie.
-- @return boolean true if cookie exists, otherwise false.
function DanLib.CookieUtils:Exists(key)
	validateKey(key) -- Key verification
    return cookie.GetString(key) ~= ''
end


--- Gets all cookies in the form of a table.
-- @return table: A table of all cookies.
function DanLib.CookieUtils:GetAll()
    local allCookies = {}
    for key in pairs(DanLib.CookieUtils.keys) do
        if self:Exists(key) then allCookies[key] = cookie.GetString(key) end
    end
    return allCookies
end


--- Clears all cookies.
function DanLib.CookieUtils:ClearAll()
    for _, key in ipairs(DanLib.CookieUtils.keys) do
        self:Delete(key)
    end
    DanLib.CookieUtils.keys = {} -- Clearing the key table
end


--- Sets a cookie with a lifetime value.
-- @param key string The key of the cookie.
-- @param value string Value of the cookie.
-- @param ttl number The lifetime of the cookie in seconds.
function DanLib.CookieUtils:SetWithTTL(key, value, ttl)
    validateKey(key) -- Key verification
    validateValue(value) -- Value check

    if (type(ttl) ~= 'number') then
        error('TTL must be a number.')
    end

    cookie.Set(key, tostring(value)) -- Save the value as a string
    timer.Simple(ttl, function()
        self:Delete(key)
    end)
end
