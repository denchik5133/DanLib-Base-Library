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
 *  NOTE  NOTE  NOTE  NOTE
 *  
 *  Not relevant! Not applicable at this time!
 *  Not relevant! Not applicable at this time!
 *  Not relevant! Not applicable at this time!
 *  
 *  NOTE  NOTE  NOTE  NOTE
 */



--- Module for managing access rights in DanLib.
DanLib.Permissions = DanLib.Permissions or {}
DanLib.Permissions.list = DanLib.Permissions.list or {}


--- Adds a permission to the list of permissions.
-- @param name string: The name of the permission.
-- @param default string: Minimum access level (default is ‘admin’).
-- @param description string: Description of the permission (default ‘This permission has no description’).
-- @throws error: If no permission name is specified.
function DanLib.Permissions:Add(name, default, description)
    if (not name) then
        error('No name specified for permission')
    end

    local privilege = {
        Name = name,
        Description = description or 'This permission has no description',
        MinAccess = default or 'admin'
    }

    DanLib.Permissions.list[name] = privilege
    DanLib.BaseConfig.Permissions[name] = privilege
end


--- Checks if the player has permission.
-- @param pPlayer Player: The player for whom the permission is being checked.
-- @param name string: The name of the permission.
-- @return boolean: true if the player has permission, otherwise false.
function DanLib.Permissions:Check(pPlayer, name)
    if (not pPlayer:IsPlayer()) then return false end
    return DanLib.Func.HasPermission(pPlayer, name)
end


--- Gets the permission by name.
-- @param name string: Permission name.
-- @return table: Table with permission data or nil if no permission is found.
function DanLib.Permissions:Get(name)
    return DanLib.Permissions.list[name]
end


--- Gets all the permissions.
-- @return table: Table with all permissions.
function DanLib.Permissions:GetAll()
    return DanLib.Permissions.list
end
