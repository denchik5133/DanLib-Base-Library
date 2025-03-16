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



AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')


--- Entity Initialisation.
function ENT:Initialize()
	self:SetModel('models/breen.mdl')
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_BBOX)
	self:SetCollisionGroup(COLLISION_GROUP_PLAYER)
end


--- NPC Key Installation.
-- @param key (string): The NPC key used to retrieve the NPC configuration from the database.
function ENT:SetNPCKey(key)
	self:SetNPCKeyVar(key)

	local config = DanLib.CONFIG.BASE.NPCs[key]
	if (config and config.Model) then
		self:SetModel(config.Model)
	else
		self:SetModel('models/breen.mdl')
	end
end


--- Handling incoming interaction.
-- @param ply (Player): The player who is interacting with the entity.
-- @param caller (Entity): The entity calling the interaction.
function ENT:AcceptInput(ply, caller)
	if ((caller.timer or 0) > CurTime()) then return end
	caller.timer = CurTime() + 1

	if (not self:GetNPCKeyVar() or not DanLib.CONFIG.BASE.NPCs[self:GetNPCKeyVar()]) then return end
	local config = DanLib.CONFIG.BASE.NPCs[self:GetNPCKeyVar()]
	local typeTable = DanLib.BaseConfig.EntityTypesFunc[config.FuncType or '']
	if (typeTable and typeTable.UseFunc) then typeTable.UseFunc(caller, self, self:GetNPCKeyVar()) end
end


--- Damage Receipt Handling.
-- @param dmgInfo (damage): Information about the damage received by the entity.
-- @return number: Returns 0 to ignore damage.
function ENT:OnTakeDamage(dmgInfo)
	return 0
end