/***
 *   @addon         DanLib
 *   @component     NPCSpawnTool
 *   @version       1.6.0
 *   @release_date  29/11/2025
 *   @author        denchik
 *   @contact       Discord: denchik_gm
 *                  Steam: https://steamcommunity.com/profiles/76561198405398290/
 *                  GitHub: https://github.com/denchik5133
 *   
 *   @description   Advanced NPC spawning tool with support for:
 *                  - Smooth 60 FPS model preview with interpolation
 *                  - Distance-based spawn restrictions (max 500 units)
 *                  - Surface validation (floor-only spawning)
 *                  - Right-click NPC deletion with spawn data cleanup
 *                  - Real-time visual feedback (green/orange/red indicators)
 *   
 *   @performance   - LerpVector interpolation for smooth preview movement
 *                  - Localized global functions for reduced lookup time
 *                  - Color interpolation at 60 FPS (FrameTime() * 10)
 *                  - Cached NPC configuration data
 *                  - Optimized trace operations with distance limits
 *
 *   @compatibility DanLib 3.0.0+ | GMod 2024+
 *   @license       MIT License
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

local DBase = DanLib.Func
local DUtils = DanLib.Utils

local _IsValid = IsValid
local _CurTime = CurTime
local _mathMax = math.max
local _mathMin = math.min
local _Vector = Vector
local _Angle = Angle
local _Lerp = Lerp
local _LerpVector = LerpVector
local _FrameTime = FrameTime

local MAX_SPAWN_DISTANCE = 500

-- Check if the position is valid for spawning NPC
local function IsPositionValid(pos)
    -- Perform a trace from above the position to check if it's solid
    local tr = util.TraceLine({
        start = pos + _Vector(0, 0, 10), -- Checking from above
        endpos = pos,
        filter = function(ent)
        	return ent:GetClass() == 'worldspawn'
        end
    })
    
    -- Perform another trace to ensure there's no obstruction right at the position
    local trCheck = util.TraceHull({
        start = pos,
        endpos = pos,
        mins = _Vector(-16, -16, -16), -- Adjust the hull size as needed
        maxs = _Vector(16, 16, 16),
        filter = function(ent)
        	return ent:GetClass() == 'worldspawn'
        end
    })

    -- Check if the trace hit anything and ensure it's not a worldspawn or obstructing
    return not tr.Hit and not trCheck.Hit
end

--- Primary attack function for spawning NPCs.
function SWEP:PrimaryAttack()
    if (not IsFirstTimePredicted()) then
        return
    end
    self:SetNextPrimaryFire(_CurTime() + 1)

    local pPlayer = self.Owner
    local Pos = pPlayer:GetShootPos()
    local Aim = pPlayer:GetAimVector()
    
    local trace = util.TraceLine({
        start = Pos,
        endpos = Pos + Aim * MAX_SPAWN_DISTANCE,
        filter = pPlayer
    })

    if (not trace.HitPos or _IsValid(trace.Entity) and trace.Entity:IsPlayer()) then
        return false
    end

    if CLIENT then
        return
    end

    if (not DBase.HasPermission(pPlayer, 'SpawnNPC')) then
        DBase:SidePopupNotifi(pPlayer, 'You do not have permission to use this tool.', 'ERROR', 5)
        return
    end

    -- CHECKING THE DISTANCE
    local distance = pPlayer:GetPos():Distance(trace.HitPos)
    if (distance > MAX_SPAWN_DISTANCE) then
        DBase:SidePopupNotifi(pPlayer, 'Too far! Maximum spawn distance: ' .. MAX_SPAWN_DISTANCE .. ' units.', 'ERROR', 5)
        return
    end

    local hitPos = trace.HitPos
    local normal = trace.HitNormal
    local offset = 5

    -- Is it possible to spawn on this surface?
    if (normal.z <= 0.7) then
        DBase:SidePopupNotifi(pPlayer, 'Cannot spawn NPC on walls or ceiling. Use floor only.', 'ERROR', 5)
        return
    end

    -- We continue only if it is the floor
    hitPos = hitPos + _Vector(0, 0, offset)

    if IsPositionValid(hitPos) then
        DBase:SidePopupNotifi(pPlayer, 'Cannot spawn NPC here. Please choose a valid location.', 'WARNING', 5)
        return
    end

    local npcKey = pPlayer:GetNW2String('tool_npc_type', '')
    if (DanLib.CONFIG.BASE.NPCs[npcKey]) then
        local NPCEnt = ents.Create('danlib_npc_spawn')
        NPCEnt:SetPos(hitPos)

        local EntAngles = NPCEnt:GetAngles()
        local PlayerAngle = pPlayer:GetAngles()

        NPCEnt:SetAngles(_Angle(EntAngles.p, PlayerAngle.y + 180, EntAngles.r))
        NPCEnt:Spawn()
        NPCEnt:SetNPCKey(npcKey)
        
        DBase:AddNPCSpawn(NPCEnt)
        DBase:SidePopupNotifi(pPlayer, 'NPC spawned successfully!', 'CONFIRM', 5)
    else
        DBase:SidePopupNotifi(pPlayer, 'Incorrect NPC type, select from menu (R key).', 'WARNING', 5)
    end
end

--- Secondary attack function for removing NPCs.
function SWEP:SecondaryAttack()
    if (not IsFirstTimePredicted()) then
        return
    end
    self:SetNextPrimaryFire(_CurTime() + 1)

    local pPlayer = self.Owner
    local Pos = pPlayer:GetShootPos()
    local Aim = pPlayer:GetAimVector()
    
    local trace = util.TraceLine({
        start = Pos,
        endpos = Pos + Aim * MAX_SPAWN_DISTANCE,
        filter = pPlayer
    })

    if (not trace.HitPos) then
        return false
    end

    if CLIENT then
        return true
    end

    if (not DBase.HasPermission(pPlayer, 'SpawnNPC')) then
        DBase:SidePopupNotifi(pPlayer, 'You do not have permission to use this tool.', 'ERROR', 5)
        return
    end
    
    if (_IsValid(trace.Entity) and trace.Entity:GetClass() == 'danlib_npc_spawn') then
        local ent = trace.Entity
        
        -- DELETING THE SPAWNS FROM THE FILE
        if ent.SpawnID then
            DBase:RemoveNPCSpawn(ent.SpawnID)
        end
        
        -- Deleting the entity
        ent:Remove()
        DBase:SidePopupNotifi(pPlayer, 'NPC removed and deleted from data/danlib/npc_spawns.json', 'CONFIRM', 5)
    else
        DBase:SidePopupNotifi(pPlayer, 'Aim at NPC to delete it.', 'WARNING', 5)
        return false
    end
end

local cool = 0
--- Reload function for selecting NPC types.
function SWEP:Reload()
    if (not IsFirstTimePredicted()) then
    	return
    end

    if ((cool or 0) > _CurTime()) then
    	return
    end
    cool = _CurTime() + 1

    if CLIENT then
        local pPlayer = self:GetOwner()
        if (not DBase.HasPermission(pPlayer, 'SpawnNPC')) then
            return
        end

        -- Creating a mapping name -> key
        local options = {}
        local nameToKey = {}
        
        for k, v in pairs(DanLib.CONFIG.BASE.NPCs or {}) do
            options[k] = v.Name
            nameToKey[v.Name] = k
        end

        DBase:ComboRequestPopup('NPC list', 'Select one NPC from the list.', options, 'Type', nil, function(value, data)
            -- data = имя NPC ('New NPC 10')
            -- We find the key through mapping
            local npcKey = nameToKey[data]
            if npcKey then
                net.Start('DDI.SelectingNPCspawning')
                net.WriteString(npcKey)
                net.SendToServer()
            end
        end)
    end
end

if (CLIENT) then
    -- Create model
    function SWEP:CreateModel()
        self:RemoveModel()
        
        local pPlayer = self:GetOwner()
        if (not _IsValid(pPlayer)) then
            return
        end
        
        local npcKey = pPlayer:GetNW2String('tool_npc_type', '')
        local npcData = DanLib.CONFIG.BASE.NPCs[npcKey]
        local modelPath = (npcData and npcData.Model) or 'models/player/barney.mdl'
        
        self.model = ClientsideModel(modelPath)
        self.model:SetMaterial('models/wireframe')
        self.model.is_down = true
        self.model:SetRenderMode(RENDERMODE_TRANSALPHA)
        self.currentNPCKey = npcKey
        
        -- Variables for smooth interpolation
        self.targetPos = _Vector(0, 0, 0)
        self.currentPos = _Vector(0, 0, 0)
        self.targetAngles = _Angle(0, 0, 0)
        self.currentAngles = _Angle(0, 0, 0)
        self.targetColor = Color(0, 255, 0, 255)
        self.currentColor = Color(0, 255, 0, 255)
        
        -- Applying animation from the config
        if (npcData and npcData.Animation) then
            local animIndex = self.model:LookupSequence(npcData.Animation)
            if (animIndex and animIndex > 0) then
                self.model:ResetSequence(animIndex)
            end
        end
    end
    
    -- Remove model
    function SWEP:RemoveModel()
        if _IsValid(self.model) then
            self.model:Remove()
        end
    end
    
    -- Called when player has just switched to this weapon.
    function SWEP:Deploy()
        self.NextModelUpdate = 0
        self:CreateModel()
    end
    
    -- Called when weapon tries to holster.
    function SWEP:Holster()
        self:RemoveModel()
        return true
    end
    
    -- Called when the swep thinks.
    function SWEP:Think()
        local pPlayer = self:GetOwner()
        if (not _IsValid(pPlayer)) then
            return
        end
        
        -- Checking if the selected NPC has changed
        local npcKey = pPlayer:GetNW2String('tool_npc_type', '')
        if (npcKey ~= self.currentNPCKey) then
            self:CreateModel()
        end
        
        if (not _IsValid(self.model)) then 
            self:CreateModel()
            return 
        end
        
        local tr = pPlayer:GetEyeTrace()
    
        -- Checking if we are looking at an existing NPC
        local isLookingAtNPC = _IsValid(tr.Entity) and tr.Entity:GetClass() == 'danlib_npc_spawn'
        if isLookingAtNPC then
            if (self.model:GetNoDraw() == false) then
                self.model:SetNoDraw(true)
            end
            return
        else
            if (self.model:GetNoDraw() == true) then
                self.model:SetNoDraw(false)
            end
        end
        local hitPos = tr.HitPos
        local normal = tr.HitNormal
        local offset = 5

        -- CHECKING THE DISTANCE
	    local distance = pPlayer:GetPos():Distance(hitPos)
	    local isTooFar = distance > MAX_SPAWN_DISTANCE
	    if (normal.z > 0.7) then
	        self.targetPos = hitPos + _Vector(0, 0, offset)
	        
	        -- Red if too far away, green if normal
	        if isTooFar then
	            self.targetColor = Color(255, 128, 0, 255)  -- Orange = too far away
	        else
	            self.targetColor = Color(0, 255, 0, 255)  -- Green = can be spawned
	        end
	    elseif (normal.z < -0.7) then
	        self.targetPos = hitPos - _Vector(0, 0, offset)
	        self.targetColor = Color(255, 0, 0, 255)  -- Red = ceiling
	    else
	        self.targetPos = hitPos + normal * offset
	        self.targetColor = Color(255, 0, 0, 255)  -- Red = wall
	    end
        

        self.targetAngles = _Angle(0, pPlayer:GetAngles().y + 180, 0)
	    self.currentPos = _LerpVector(_FrameTime() * 15, self.currentPos, self.targetPos)
	    self.model:SetPos(self.currentPos)
	    self.currentAngles.y = _Lerp(_FrameTime() * 10, self.currentAngles.y, self.targetAngles.y)
	    self.model:SetAngles(self.currentAngles)
	    self.currentColor.r = _Lerp(_FrameTime() * 10, self.currentColor.r, self.targetColor.r)
	    self.currentColor.g = _Lerp(_FrameTime() * 10, self.currentColor.g, self.targetColor.g)
	    self.currentColor.b = _Lerp(_FrameTime() * 10, self.currentColor.b, self.targetColor.b)
	    self.model:SetColor(self.currentColor)

	    if (not self.intNextSequence or _CurTime() > self.intNextSequence) then
	        if self.model.is_down then
	            self.model:ResetSequence(0)
	        else
	            self.model:ResetSequence(2)
	        end
	        self.model.is_down = not self.model.is_down
	        self.intNextSequence = _CurTime() + 5
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
        local w1, h1 = DUtils:GetTextSize(title, 'danlib_font_30')
        local w2, h2 = DUtils:GetTextSize(text, 'danlib_font_30')
        w2 = w2 + 34 + w1
        h2 = h2 + 16

        alpha = alpha or 255

        -- Set transparency
    	surface.SetAlphaMultiplier(alpha / 255)
        DUtils:DrawRoundedBox(x, y, w2, h2, DBase:Theme('secondary_dark'))
        DUtils:DrawRoundedBox(x, y, 2, h2, DBase:Theme('decor'))
        DUtils:DrawSomeText(text, 'danlib_font_30', DBase:Theme('decor'), title, 'danlib_font_30', DBase:Theme('title'), x + 14, y + h2 / 2 - 16, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        -- Reset alpha multiplier
    	surface.SetAlphaMultiplier(1)
    end

    -- Called after the view model has been drawn while the weapon in use.
    function SWEP:PostDrawViewModel(viewModel, wWeapon)
	    if (wWeapon:GetClass() == 'npc_spaw' and _IsValid(self)) then
	        local pPlayer = LocalPlayer()
	        local trEntity = pPlayer:GetEyeTrace().Entity
	        local trVendor = _IsValid(trEntity) and (trEntity:GetClass() == 'danlib_npc_spawn')

	        -- Update time
	        local currentTime = _CurTime()
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
	            alpha = _mathMin(255, alpha + (255 / fadeInTime * _FrameTime()))
	        else
	            alpha = _mathMax(0, alpha - (255 / fadeOutTime * _FrameTime()))
	        end

	        local npcKey = pPlayer:GetNW2String('tool_npc_type', '')
	        local Selected = DanLib.CONFIG.BASE.NPCs[npcKey]
	        
	        local indx = viewModel:LookupBone('ValveBiped.Bip01_R_Hand')
	        local pPos, aAngle = viewModel:GetBonePosition(indx)
	        pos = pPos + aAngle:Forward() * 4.9 + aAngle:Right() * 2 + aAngle:Up() * -9.5

	        _angle = aAngle
	        _angle:RotateAroundAxis(_angle:Right(), 190)
	        _angle:RotateAroundAxis(_angle:Up(), 90)
	        _angle:RotateAroundAxis(_angle:Forward(), 90)

	        cam.Start3D2D(pos, _angle, 0.0122)
	            drawTextBox('LeftClick', ' - Spawn where you look.', trVendor and 140 or 195)
	            drawTextBox('RightClick', ' - Spawn where you look.', trVendor and 140 or 195)
	            drawTextBox('R', '- Select one of the NPC types.', trVendor and 195 or 250)

	            if trVendor then
	            	drawTextBox('RightClick', ' - Remove.', 250, alpha)
	            end

	            drawTextBox('Favorites', ' - ' .. ((Selected and (Selected.Name or 'error')) or 'Nothing is selected'), 305)
	        cam.End3D2D()
	    end
	end
elseif (SERVER) then
    util.AddNetworkString('DDI.SelectingNPCspawning')
    net.Receive('DDI.SelectingNPCspawning', function(len, pPlayer)
        local npcKey = net.ReadString()
        pPlayer:SetNW2String('tool_npc_type', npcKey)
    end)
end
