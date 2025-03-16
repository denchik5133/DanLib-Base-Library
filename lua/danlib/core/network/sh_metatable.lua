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
 *   sh_findmetatable.lua
 *   This file is responsible for retrieving metatables for various GLua classes 
 *   in the DanLib project.
 *
 *   It includes the following functionalities:
 *   - Retrieving the metatable for a specified class (GetMetaTable).
 *   - Accessing metatables for common game entities such as Player, NPC, 
 *     Panel, Weapon, and Vehicle.
 *
 *   The file enhances the scripting capabilities by allowing developers to 
 *   extend the functionality of existing GLua classes through metatables.
 */



DanLib.Meta = DanLib.Meta or {}


--- A function to retrieve a metatable by class name.
-- @param className The name of the class for which to retrieve the metatable.
-- @return The metatable for the specified class.
-- @throws An error if the metatable for the class is not found.
local function GetMetaTable(className)
    local meta = FindMetaTable(className)
    if (not meta) then
        error('Metatable for the class "' .. className .. '" not found!')
    end
    return meta
end


-- We get meta tables for Player and Panel classes.

--- A metatable for creating and managing user interfaces.
-- Usage: Allows you to create graphical UI elements, manage their behaviour 
-- and interactions with players.
DanLib.MetaPanel = FindMetaTable('Panel')


--- Metatable for all game entities, including NPCs, items, and players.
-- Usage: Allows you to interact with entities, change their behaviour, 
-- properties and perform various actions.
DanLib.MetaEntity = GetMetaTable('Entity')


--- Metatable for all weapons in the game.
-- Usage: Provides methods for controlling weapon behaviour, characteristics 
-- and interactions with players and other objects.
DanLib.MetaWeapon = GetMetaTable('Weapon')


--- A metatable for non-player characters (NPCs).
-- Usage: Allows you to control the behaviour of NPCs, their animations 
-- and interactions with players and the environment.
DanLib.MetaNPC = GetMetaTable('NPC')


--- Metatable for vehicles in the game.
-- Usage: Allows you to control the behaviour of vehicles, such as speed, 
-- steering and interactions with players.
DanLib.MetaVehicle = GetMetaTable('Vehicle')


--- A metatable for players in the game.
-- Usage: Allows you to control the actions, states and interactions of 
-- players with the environment and other players.
DanLib.MetaPlayer = GetMetaTable('Player')
