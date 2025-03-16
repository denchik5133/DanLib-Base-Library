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



include('shared.lua')


--- Entity Initialisation.
function ENT:Initialize()
	self.Distance = 0
end


local dist = 250 * 250


--- Updating the state of the entity.
-- Checks the distance to the player and updates the head rotation parameters.
function ENT:Think()
	local pPlayer = LocalPlayer()
	if pPlayer:GetPos():DistToSqr(self:GetPos()) > (dist) then 
		if (self.Distance != 0) then 
			self.Distance = 0 
		end
		return
	end 

	local pPos = pPlayer:EyePos()
	local ang = (pPos - self:EyePos()):Angle()
	local yaw = math.NormalizeAngle(ang.y - self:GetAngles().y)
	local get_yaw = self:GetPoseParameter('head_yaw', yaw)

	if (yaw < 0 and get_yaw > yaw) or (yaw > 0 and get_yaw < yaw) then 
		self.Distance = math.Approach(self.Distance, yaw, 1.25)
	end 

	self:SetPoseParameter('head_yaw', yaw)
	self:SetEyeTarget(pPos)
end


--- Entity Drawing.
-- The name of the NPC displayed in the tooltip. If not specified, the default value is used.
function ENT:Draw()
	self:DrawModel()

	local config = ((DanLib.CONFIG.BASE.NPCs or {})[(self:GetNPCKeyVar() or 0)] or {})
	local Name = config.Name or self.PrintName
	local animation = config.Animation or ''

	self:SetCreateEntityToolTip(Name, false, nil, 'BGCpqAF') -- 'BGCpqAF'

	local anim = self:LookupSequence(animation)
	if (anim > 0) then self:ResetSequence(anim) end
	-- self:AddGestureSequence(Anim)
end