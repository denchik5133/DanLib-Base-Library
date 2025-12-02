/***
 *   @addon         DanLib
 *   @version       2.4.0
 *   @release_date  01/12/2024
 *   @author        denchik
 *   @contact       Discord: denchik_gm
 *                  Steam: https://steamcommunity.com/profiles/76561198405398290/
 *                  GitHub: https://github.com/denchik5133
 *                
 *   @description   Permission management system with automatic rank assignment
 *
 *   @changelog     2.4.0
 *                  - Implemented deferred permission auto-assignment via InitPostEntity hook
 *                  - Fixed SetConfigValue nil error by delaying rank modifications
 *                  - Added support for auto-assign to all ranks (AutoAssignAll flag)
 *                  - Added support for auto-assign to specific ranks (AutoAssignRanks list)
 *                  - Improved permission registration with validation and error handling
 *                  - Deprecated MinAccess parameter with console warning
 *                  - Centralized permission auto-assignment in single hook
 *                  - Added safety checks for ConfigMeta.BASE availability
 *
 *   @license       MIT License
 */



--- Module for managing access rights in DanLib.
DanLib.Permissions = DanLib.Permissions or {}
DanLib.Permissions.list = DanLib.Permissions.list or {}
DanLib.BaseConfig.Permissions = DanLib.BaseConfig.Permissions or {}

--- Registers a new permission with optional auto-assignment to specific ranks
-- @param name (string): The unique permission key (e.g., 'EditSettings')
-- @param description (string): Description of the permission
-- @param autoAssignRanks (string|table|boolean|nil): 
--   - string: Single rank ID to auto-assign (e.g., 'rank_owner')
--   - table: Multiple rank IDs to auto-assign (e.g., {'rank_owner', 'rank_staff'})
--   - boolean: true = auto-assign to all new ranks, false = no auto-assign
--   - nil: no auto-assign (default behavior)
-- @param minAccess (string): Minimum access level (DEPRECATED, kept for compatibility)
-- @usage 
--   DanLib.Permission:Register('EditSettings', 'Permission to edit config', 'rank_owner')
--   DanLib.Permission:Register('ViewHelp', 'View help pages', {'rank_owner', 'rank_staff', 'rank_member'})
--   DanLib.Permission:Register('AdminPages', 'View admin pages', true)
function DanLib.Permissions:Register(name, description, autoAssignRanks, minAccess)
    if (not name) then
        error('No name specified for permission')
    end
    local assignRanks = nil
    local assignToAll = false
    
    if (type(autoAssignRanks) == 'string') then
        assignRanks = { autoAssignRanks }
    elseif (type(autoAssignRanks) == 'table') then
        assignRanks = autoAssignRanks
    elseif (autoAssignRanks == true) then
        assignToAll = true
    end
    
    local permissionData = {
        Name = name,
        Description = description or 'This permission has no description',
        AutoAssignRanks = assignRanks,
        AutoAssignAll = assignToAll,
        MinAccess = minAccess or 'admin'
    }
    DanLib.Permissions.list[name] = permissionData
    DanLib.BaseConfig.Permissions[name] = permissionData
    
    if (minAccess and SERVER) then
        print('[DanLib] WARNING: MinAccess parameter is DEPRECATED in DanLib.Permissions:Register("' .. name .. '").')
    end
end

--- Checks if the player has permission.
-- @param pPlayer (Player): The player for whom the permission is being checked.
-- @param name (string): The name of the permission.
-- @return boolean: true if the player has permission, otherwise false.
function DanLib.Permissions:Check(pPlayer, name)
    if (not pPlayer:IsPlayer()) then
        return false
    end
    return DanLib.Func.HasPermission(pPlayer, name)
end

--- Gets the permission by name.
-- @param name (string): Permission name.
-- @return table: Table with permission data or nil if no permission is found.
function DanLib.Permissions:Get(name)
    return DanLib.Permissions.list[name]
end

--- Gets all the permissions.
-- @return table: Table with all permissions.
function DanLib.Permissions:GetAll()
    return DanLib.Permissions.list
end

--- Gets permission description (supports old and new format)
-- @param name (string): Permission name
-- @return string: Description of the permission
function DanLib.Permissions:GetDescription(name)
    local perm = DanLib.BaseConfig.Permissions[name]
    if (not perm) then
        return 'Unknown permission'
    end
    
    -- Новый format (table)
    if (type(perm) == 'table') then
        return perm.Description or 'No description'
    end
    
    -- Old format (string)
    return perm
end



DanLib.Permissions:Register('EditSettings', 'Permission to edit the configuration.', 'rank_owner')
DanLib.Permissions:Register('EditRanks', 'Permission to edit ranks.', 'rank_owner')
DanLib.Permissions:Register('AdminPages', 'Permission to view pages for administrators.', { 'rank_owner', 'rank_staff' })
DanLib.Permissions:Register('ViewHelp', 'Permissions to view the page and other help items.', true) -- All ranks
DanLib.Permissions:Register('Tutorial', 'Permission to view the textbook.', { 'rank_owner', 'rank_staff' })
DanLib.Permissions:Register('SpawnNPC', 'Permission to spawn NPCs.', { 'rank_owner', 'rank_staff' })
