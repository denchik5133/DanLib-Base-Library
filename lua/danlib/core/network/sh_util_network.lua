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
 *   sh_util_network.lua
 *   This file provides utilities for networking in the DanLib project.
 *
 *   It includes functionalities for managing network strings and
 *   various utility functions from the util module.
 *
 *   Functions included:
 *   - Adding network strings (AddNetworkString).
 *   - Converting JSON to table (JSONToTable).
 *   - Converting table to JSON (TableToJSON).
 *   - Checking if a model is valid (IsValidModel).
 *   - Intersecting a ray with a plane (IntersectRayWithPlane).
 *   - Other utility functions as needed.
 */



--- Shared online library for DanLib
DanLib.NetworkUtil = DanLib.NetworkUtil or {}
local NetworkUtil = DanLib.NetworkUtil


--- Networking
-- The networking library allows you to create and manage network strings,
-- facilitating communication between the server and clients.

--- Table for tracking added network strings
DanLib.NetworkStrings = {}


--- Adds a network string for communication.
-- @param networkName: The name of the network string to be added.
function NetworkUtil:AddString(networkName)
    -- Check if this network string has been added already
    if (not DanLib.NetworkStrings[networkName]) then
        -- Add a network string
        util.AddNetworkString(networkName)
        -- Mark the row as added
        DanLib.NetworkStrings[networkName] = true
    end
end


--- Converts a JSON string to a Lua table.
-- @param jsonString: The JSON string to be converted.
-- @param ignoreLimits: Ignore the depth and breadth limits, use at your own risk!.
-- @param ignoreConversions: Ignore string to number conversions for table keys.
-- @return: The converted Lua table.
function NetworkUtil:JSONToTable(jsonString, ignoreLimits, ignoreConversions)
    assert(type(jsonString) == 'string', 'Expected a string for jsonString in JSONToTable.')
    return util.JSONToTable(jsonString)
end


--- Converts a Lua table to a JSON string.
-- @param luaTable: The Lua table to be converted.
-- @param prettyPrint: Format and indent the JSON.
-- @return: The converted JSON string.
function NetworkUtil:TableToJSON(luaTable, prettyPrint)
    assert(type(luaTable) == 'table', 'Expected a table for luaTable in TableToJSON.')
    return util.TableToJSON(luaTable, prettyPrint)
end


--- Checks if the given model is valid.
-- @param model: The model path to check.
-- @return: True if the model is valid, false otherwise.
function NetworkUtil:IsValidModel(model)
    assert(type(model) == 'string', 'Expected a string for model in IsValidModel.')
    return util.IsValidModel(model)
end


--- Intersects a ray with a plane using the built-in util function.
-- @param rayOrigin: The origin of the ray (Vector).
-- @param rayDirection: The direction of the ray (Vector).
-- @param planePosition: A point on the plane (Vector).
-- @param planeNormal: The normal of the plane (Vector).
-- @return: The intersection point (Vector) if it exists, nil otherwise.
function NetworkUtil:IntersectRayWithPlane(rayOrigin, rayDirection, planePosition, planeNormal)
    assert(isvector(rayOrigin), 'Expected a vector for rayOrigin in IntersectRayWithPlane.')
    assert(isvector(rayDirection), 'Expected a vector for rayDirection in IntersectRayWithPlane.')
    assert(isvector(planePosition), 'Expected a vector for planePosition in IntersectRayWithPlane.')
    assert(isvector(planeNormal), 'Expected a vector for planeNormal in IntersectRayWithPlane.')

    local intersection = util.IntersectRayWithPlane(rayOrigin, rayDirection, planePosition, planeNormal)

    if intersection then
        return intersection -- Return the intersection point
    else
        return nil -- No intersection
    end
end
