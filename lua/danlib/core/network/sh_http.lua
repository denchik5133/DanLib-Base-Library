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
 *   sh_http.lua
 *   This file is responsible for managing HTTP requests in the DanLib project.
 *
 *   It includes the following functions:
 *   - Fetching data from a URL (Fetch).
 *   - Posting data to a URL (Post).
 *   - Handling success and failure callbacks, where failure callbacks are optional.
 *   - Utility functions to check if a variable has been provided and if a value is a string.
 *
 *   This file provides a simple and flexible interface for making HTTP requests in the project,
 *   ensuring easy communication with external APIs or servers. 
 *   Users can choose to handle errors by providing a failure callback or can opt for default logging.
 *
 *   Functions:
 *   - DanLib.HTTP:Fetch(url, successCallback, [failureCallback])
 *   - DanLib.HTTP:Post(url, data, successCallback, [failureCallback])
 *   - IsValueProvided(value): Checks if a variable has been provided.
 *   - IsString(value): Checks if the value is a string.
 */



--- Shared online library for DanLib
DanLib.HTTP = DanLib.HTTP or {}


--- Function to check if a variable has been entered
-- @param value: The value to be checked.
-- @return: true if the variable has been entered, otherwise false.
local function IsValueProvided(value)
    return value ~= nil
end


--- Function to check if the value is a string
-- @param value: The value to check.
-- @return: true if the value is a string, otherwise false.
local function IsString(value)
    return type(value) == 'string'
end


--- Function to fetch data from a URL
-- @param url: The URL to fetch data from.
-- @param successCallback: The function to call on a successful response.
-- @param failureCallback: The function to call on a failed response.
function DanLib.HTTP:Fetch(url, successCallback, failureCallback)
    assert(IsString(url), 'URL for Fetch is not provided or is not a string.')
    assert(IsValueProvided(successCallback), 'Success callback for Fetch is not provided.')

    http.Fetch(url,
        function(body, len, headers, code)
            -- Call the success callback with the response body and other details
            successCallback(body, len, headers, code)
        end,
        function(error)
            -- Call the failure callback if it was provided
            if failureCallback then
                failureCallback(error)
            else
                print('HTTP Post failed: ' .. error) -- Optional logging
            end
        end
    )
end


--- Function to post data to a URL
-- @param url: The URL to post data to.
-- @param data: A table containing the data to be sent.
-- @param successCallback: The function to call on a successful response.
-- @param failureCallback: The function to call on a failed response.
function DanLib.HTTP:Post(url, data, successCallback, failureCallback)
    assert(IsString(url), 'URL for Post is not provided or is not a string.')
    assert(IsValueProvided(data), 'Data for Post is not provided.')
    assert(IsValueProvided(successCallback), 'Success callback for Post is not provided.')

    http.Post(url, data,
        function(body, len, headers, code)
            -- Call the success callback with the response body and other details
            successCallback(body, len, headers, code)
        end,
        function(error)
            -- Call the failure callback if it was provided
            if failureCallback then
                failureCallback(error)
            else
                print('HTTP Fetch failed: ' .. error) -- Optional logging
            end
        end
    )
end
