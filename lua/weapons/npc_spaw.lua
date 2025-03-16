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



AddCSLuaFile()

if CLIENT then
	SWEP.PrintName = 'NPC spawns'
	SWEP.Slot = 1
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = true
end

SWEP.Author = 'denchik'
SWEP.Instructions = 'Press [R] on the keyboard to open the selection menu.'
SWEP.Contact = 'https://discord.gg/CND6B5sH3j'
SWEP.Purpose = 'The tool is designed for Administrators.'
SWEP.Category = '[DDI] Tool'

SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.ViewModel = 'models/weapons/v_pistol.mdl'
SWEP.WorldModel = 'models/weapons/w_pistol.mdl'

SWEP.Spawnable = true
SWEP.AdminOnly = true

local base = DanLib.Func
local utils = DanLib.Utils


-- Check if the position is valid for spawning NPC
local function IsPositionValid(pos)
    -- Perform a trace from above the position to check if it's solid
    local tr = util.TraceLine({
        start = pos + Vector(0, 0, 10), -- Checking from above
        endpos = pos,
        filter = function(ent) return ent:GetClass() == 'worldspawn' end
    })
    
    -- Perform another trace to ensure there's no obstruction right at the position
    local trCheck = util.TraceHull({
        start = pos,
        endpos = pos,
        mins = Vector(-16, -16, -16), -- Adjust the hull size as needed
        maxs = Vector(16, 16, 16),
        filter = function(ent) return ent:GetClass() == 'worldspawn' end
    })

    -- Check if the trace hit anything and ensure it's not a worldspawn or obstructing
    return not tr.Hit and not trCheck.Hit
end


--- Primary attack function for spawning NPCs.
function SWEP:PrimaryAttack()
	if (not IsFirstTimePredicted()) then return end
    self:SetNextPrimaryFire(CurTime() + 1)

    local Pos = self.Owner:GetShootPos()
	local Aim = self.Owner:GetAimVector()
    local trace = util.TraceLine({ start = Pos, endpos = Pos + Aim * 500, filter = self.Owner })

	if (not trace.HitPos or IsValid(trace.Entity) && trace.Entity:IsPlayer()) then
		return false
	end

	if CLIENT then return end

	local pPlayer = self:GetOwner()
	if (not base.HasPermission(pPlayer, 'SpawnNPC')) then
		base:SidePopupNotifi(pPlayer, 'You do not have permission to use this tool.', 'ERROR', 5)
		return
	end

	-- Adjust hit position based on the normal of the surface
    local hitPos = trace.HitPos
    local normal = trace.HitNormal
    local offset = 5

    -- Adjust position based on normal
    if (normal.z > 0.7) then -- Floor
        hitPos = hitPos + Vector(0, 0, offset)
    elseif (normal.z < -0.7) then -- Ceiling
        hitPos = hitPos - Vector(0, 0, offset)
    else -- Wall
        hitPos = hitPos + normal * offset
    end

	-- Check if the position is valid for NPC spawning
    if IsPositionValid(hitPos) then
        base:SidePopupNotifi(pPlayer, 'Cannot spawn NPC here. Please choose a valid location.', 'WARNING', 5)
        return
    end

	if (DanLib.CONFIG.BASE.NPCs[pPlayer:GetNW2Int('tool_npc_type')]) then
		local NPCEnt = ents.Create('npc_spawn')
		NPCEnt:SetPos(trace.HitPos)

		local EntAngles = NPCEnt:GetAngles()
		local PlayerAngle = pPlayer:GetAngles()

		NPCEnt:SetAngles(Angle(EntAngles.p, PlayerAngle.y + 180, EntAngles.r))
		NPCEnt:Spawn()
		NPCEnt:SetNPCKey(pPlayer:GetNW2Int('tool_npc_type'))
		
		base:SidePopupNotifi(pPlayer, 'The NPC has been successfully placed and entered into config.', 'ADMIN', 5)
		pPlayer:ConCommand('ddi_save_npc')
	else
		base:SidePopupNotifi(pPlayer, 'Incorrect NPC type, select the correct type from the type selection menu by pressing the "R" key.', 'WARNING', 5)
	end
end


--- Secondary attack function for removing NPCs.
function SWEP:SecondaryAttack()
	if (not IsFirstTimePredicted()) then return end
    self:SetNextPrimaryFire(CurTime() + 1)

    local Pos = self.Owner:GetShootPos()
	local Aim = self.Owner:GetAimVector()
    local trace = util.TraceLine({ start = Pos, endpos = Pos + Aim * 500, filter = self.Owner })

	if (not trace.HitPos) then return false end
	if CLIENT then return true end

	local pPlayer = self:GetOwner()
	if (not base.HasPermission(pPlayer, 'SpawnNPC')) then
		base:SidePopupNotifi(pPlayer, 'You do not have permission to use this tool.', 'ERROR', 5)
		return
	end
	
	if (IsValid(trace.Entity) and trace.Entity:GetClass() == 'npc_spawn' or nil) then
		trace.Entity:Remove()
		base:SidePopupNotifi(pPlayer, 'The NPC has been successfully removed from config.', 'CONFIRM', 5)
		pPlayer:ConCommand('ddi_save_npc')
	else
		base:SidePopupNotifi(pPlayer, 'To use this tool, you need to look at the location where you want to place the NPC.', 'WARNING', 5)
		return false
	end
end


local cool = 0
--- Reload function for selecting NPC types.
function SWEP:Reload()
    if (not IsFirstTimePredicted()) then return end
    if ((cool or 0) > CurTime()) then return end
	cool = CurTime() + 1

    if CLIENT then
    	local pPlayer = self:GetOwner()
		if (not base.HasPermission(pPlayer, 'SpawnNPC')) then
			return
		end

    	local options = {}
    	local d = function()
    		for k, v in pairs(DanLib.CONFIG.BASE.NPCs or {}) do
	            options[k] = v.Name
	        end
	        return options
    	end
    	d()

        base:ComboRequestPopup('NPC list', 'Select one NPC from the list.', options, 'Type', nil, function(value, data)
        	net.Start('DDI.SelectingNPCspawning')
			net.WriteUInt(data, 8)
			net.SendToServer()
        end)
    end
end


if (CLIENT) then
    -- Create model
    function SWEP:CreateModel()
        self:RemoveModel()
        self.model = ClientsideModel('models/player/barney.mdl')
        self.model:SetMaterial('models/wireframe')
        self.model.is_down = true
        self.model:SetRenderMode(RENDERMODE_TRANSALPHA)
    end

    -- Remove model
    function SWEP:RemoveModel()
        if self.model then
        	self.model:Remove()
        end
    end

    -- Called when player has just switched to this weapon.
    function SWEP:Deploy()
        self:CreateModel()
    end

    -- Called when weapon tries to holster.
    function SWEP:Holster()
        self:RemoveModel()
    end

	-- Called when the swep thinks.
	function SWEP:Think()
	    if (not IsValid(self.model)) then 
	        self:CreateModel()
	        return 
	    end

	    local tr = self.Owner:GetEyeTrace()
	    local hitPos = tr.HitPos
	    local normal = tr.HitNormal

	    -- Use a small offset to ensure model appears above surfaces
	    local offset = 5

	    -- Adjust position based on normal
	    if (normal.z > 0.7) then -- Floor
	        hitPos = hitPos + Vector(0, 0, offset)
	    elseif (normal.z < -0.7) then -- Ceiling
	        hitPos = hitPos - Vector(0, 0, offset)
	    else -- Wall
	        hitPos = hitPos + normal * offset
	    end

	    -- Ensure position is valid
	    -- if (not IsPositionValid(hitPos)) then
	    --     return
	    -- end

	    -- Update model position and angle
	    self.model:SetPos(hitPos)
	    self.model:SetAngles(Angle(0, self.Owner:GetAngles().y + 180, 0))

	    -- Example color change based on surface
	    if (normal.z > 0.7) then
	        self.model:SetColor(Color(0, 255, 0, 255)) -- Green for floor
	    elseif (normal.z < -0.7) then
	        self.model:SetColor(Color(255, 0, 0, 255)) -- Red for ceiling
	    else
	        self.model:SetColor(Color(255, 0, 0, 255)) -- Red for walls
	    end

	    -- Sequence handling (no changes)
	    if (not self.intNextSequence or CurTime() > self.intNextSequence) then
	        if self.model.is_down then
	            self.model:ResetSequence(0)
	        else
	            self.model:ResetSequence(2)
	        end

	        self.model.is_down = not self.model.is_down
	        self.intNextSequence = CurTime() + 5
	    end
	end

	-- Add variables to control the animation
	local fadeInTime = 0.5 -- Appearance time
	local fadeOutTime = 0.5 -- Disappearance time
	local alpha = 0 -- Initial transparency
	local isVisible = false -- Visibility flag
	local lastUpdateTime = 0 -- To track the time of the last update

	-- Function to draw the text box for instructions.
    local function drawTextBox(text, title, y, alpha)
        local x = 34
        local w1, h1 = utils:GetTextSize(title, 'danlib_font_30')
        local w2, h2 = utils:GetTextSize(text, 'danlib_font_30')
        w2 = w2 + 34 + w1
        h2 = h2 + 16

        alpha = alpha or 255

        -- Set transparency
    	surface.SetAlphaMultiplier(alpha / 255)

        utils:DrawRoundedBox(x, y, w2, h2, base:Theme('secondary_dark'))
        utils:DrawRoundedBox(x, y, 2, h2, base:Theme('decor'))
        utils:DrawSomeText(text, 'danlib_font_30', base:Theme('decor'), title, 'danlib_font_30', base:Theme('title'), x + 14, y + h2 / 2 - 16, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        -- Reset alpha multiplier
    	surface.SetAlphaMultiplier(1)
    end

    -- Called after the view model has been drawn while the weapon in use.
    function SWEP:PostDrawViewModel(viewModel, wWeapon)
        if (wWeapon:GetClass() == 'npc_spaw' and IsValid(self)) then
            local pPlayer = LocalPlayer()
            local trEntity = pPlayer:GetEyeTrace().Entity
            local trVendor = IsValid(trEntity) and (trEntity:GetClass() == 'npc_spawn')

            -- Update time
	        local currentTime = CurTime()
	        if trVendor then
	            isVisible = true
	            lastUpdateTime = currentTime
	        else
	            if (currentTime - lastUpdateTime >= fadeInTime) then
	                isVisible = false
	            end
	        end

	        -- Update alpha based on time
	        if isVisible then
	            alpha = math.min(255, alpha + (255 / fadeInTime * FrameTime())) -- Increase alpha
	        else
	            alpha = math.max(0, alpha - (255 / fadeOutTime * FrameTime())) -- Decrease alpha
	        end

            local Selected = DanLib.CONFIG.BASE.NPCs[pPlayer:GetNW2Int('tool_npc_type', 0)]
            local indx = viewModel:LookupBone('ValveBiped.Bip01_R_Hand')
            local pPos, aAngle = viewModel:GetBonePosition(indx)
            pos = pPos + aAngle:Forward() * 4.9 + aAngle:Right() * 2 + aAngle:Up() * -9.5

            _angle = aAngle
            _angle:RotateAroundAxis(_angle:Right(), 190)
            _angle:RotateAroundAxis(_angle:Up(), 90)
            _angle:RotateAroundAxis(_angle:Forward(), 90)

            local w, h = 475, 180
            cam.Start3D2D(pos, _angle, 0.0122)
            	drawTextBox('LeftClick', ' - Spawn where you look.', trVendor and 140 or 195)
                drawTextBox('LeftClick', ' - Spawn where you look.', trVendor and 140 or 195)
                drawTextBox('R', '- Select one of the NPC types.', trVendor and 195 or 250)

                if trVendor then drawTextBox('RightClick', ' - Remove.', 250, alpha) end

                drawTextBox('Favorites', ' - ' .. ((Selected and (Selected.Name or 'error')) or 'Nothing is selected'), 305)
            cam.End3D2D()
        end
    end
elseif (SERVER) then
    util.AddNetworkString('DDI.SelectingNPCspawning')
    net.Receive('DDI.SelectingNPCspawning', function(len, pPlayer)
        pPlayer:SetNW2Int('tool_npc_type', net.ReadUInt(8))
    end)
end
