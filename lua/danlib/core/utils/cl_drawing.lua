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


-- Link: https://gist.github.com/MysteryPancake/a31637af9fd531079236a2577145a754



DanLib.UI = DanLib.UI or {}
local base = DanLib.Func
local utils = DanLib.Utils
local dHook = DanLib.Hook
local Table = DanLib.Table
local ui = DanLib.UI

-- Shortening references to mathematical functions
local math, cam, render = math, cam, render
local sin, cos, rad, ceil, clamp = math.sin, math.cos, math.rad, math.ceil, math.Clamp
local cam_start2D, cam_end2D = cam.Start2D, cam.End2D

-- Shorten references to rendering functions
local push_render_target = render.PushRenderTarget
local override_alpha_writeEnable = render.OverrideAlphaWriteEnable
local clear = render.Clear
local copy_render_target_to_texture = render.CopyRenderTargetToTexture
local blur_render_target = render.BlurRenderTarget
local pop_render_target = render.PopRenderTarget
local set_material = render.SetMaterial
local draw_screen_quad_ex = render.DrawScreenQuadEx
local draw_screen_quad = render.DrawScreenQuad

do
	local SW = ScrW
	local SH = ScrH

	local function Load()
		-- Initialization of render tags
		local RenderTarget, RenderTarget2

		local function load_render_targets()
	        local w, h = SW(), SH()
	        RenderTarget = GetRenderTarget('ddi_shadows_original' .. w .. h, w, h)
	        RenderTarget2 = GetRenderTarget('ddi_shadows_shadow' .. w .. h, w, h)
	    end

		load_render_targets()
		dHook:Add('OnScreenSizeChanged', 'OnScreenSizeChanged', load_render_targets)

		-- The matarial to draw the render targets on
		local ShadowMaterial = CreateMaterial('bshadows', 'UnlitGeneric', {
			['$translucent'] = 1,
			['$vertexalpha'] = 1,
			['alpha'] = 1
		})

		-- When we copy the rendertarget it retains color, using this allows up to force any drawing to be black
		-- Then we can blur it to create the shadow effect
		local ShadowMaterialGrayscale = CreateMaterial('bshadows_grayscale', 'UnlitGeneric', {
			['$translucent'] = 1,
			['$vertexalpha'] = 1,
			['$alpha'] = 1,
			['$color'] = '0 0 0',
			['$color2'] = '0 0 0'
		})

		local set_texture = ShadowMaterial.SetTexture
		local SHADOWS = {}

		-- Call this to begin drawing a shadow
		function SHADOWS:Begin()
	        push_render_target(RenderTarget)
	        override_alpha_writeEnable(true, true)
	        clear(0, 0, 0, 0)
	        override_alpha_writeEnable(false, false)
	        cam_start2D()
	    end

		-- This will draw the shadow, and mirror any other draw calls the happened during drawing the shadow
		function SHADOWS:End(intensity, spread, blur, opacity, direction, distance, shadowOnly)
	        opacity = opacity or 255
	        direction = direction or 0
	        distance = distance or 0

	        copy_render_target_to_texture(RenderTarget2)

	        if (blur > 0) then
	            override_alpha_writeEnable(true, true)
	            blur_render_target(RenderTarget2, spread, spread, blur)
	            override_alpha_writeEnable(false, false)
	        end

	        pop_render_target()

	        set_material(ShadowMaterialGrayscale)
	        set_texture(ShadowMaterialGrayscale, '$basetexture', RenderTarget2)

	        local xOffset = sin(rad(direction)) * distance
	        local yOffset = cos(rad(direction)) * distance

	        for i = 1, ceil(intensity) do
	            draw_screen_quad_ex(xOffset, yOffset, SW(), SH())
	        end

	        if (not shadowOnly) then
	            set_material(ShadowMaterial)
	            set_texture(ShadowMaterial, '$basetexture', RenderTarget)
	            draw_screen_quad()
	        end

	        cam_end2D()
	    end

		DanLib.DrawShadow = SHADOWS

		local function startStencil()
	        render.ClearStencil()
	        render.SetStencilEnable(true)
	        render.SetStencilWriteMask(1)
	        render.SetStencilTestMask(1)
	        render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
	        render.SetStencilPassOperation(STENCILOPERATION_ZERO)
	        render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
	        render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
	        render.SetStencilReferenceValue(1)
	    end

		local function middleStencil()
	        render.SetStencilFailOperation(STENCILOPERATION_ZERO)
	        render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
	        render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
	        render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
	        render.SetStencilReferenceValue(1)
	    end

		local function endStencil()
	        render.SetStencilEnable(false)
	        render.ClearStencil()
	    end

	    -- Function for drawing a partially rounded rectangle
		function utils:DrawPartialRoundedBox(cornerRadius, x, y, w, h, color, roundedBoxW, roundedBoxH, roundedBoxX, roundedBoxY)
	        startStencil()
	        self:DrawRect(x, y, w, h, color_white)
	        middleStencil()
	        draw.RoundedBox(cornerRadius, roundedBoxX or x, roundedBoxY or y, roundedBoxW or w, roundedBoxH or h, color)
	        endStencil()
	    end

		-- Function for drawing a partially rounded rectangle with individual corners
	    function utils:DrawPartialRoundedBoxEx(cornerRadius, x, y, w, h, color, roundedBoxW, roundedBoxH, roundedBoxX, roundedBoxY, roundTopLeft, roundTopRight, roundBottomLeft, roundBottomRight)
	        startStencil()
	        self:DrawRect(x, y, w, h, color_white)
	        middleStencil()
	        draw.RoundedBoxEx(cornerRadius, roundedBoxX or x, roundedBoxY or y, roundedBoxW or w, roundedBoxH or h, color, roundTopLeft, roundTopRight, roundBottomLeft, roundBottomRight)
	        endStencil()
	    end
	end

	Load()

	dHook:Add('OnScreenSizeChanged', 'BShadows.ResolutionChange', function()
		SW, SH = ScrW(), ScrH()
		Load()
	end)
end




local MetaEntity = FindMetaTable('Entity')
local TIME = 0.66
-- Variables
local lastHp = 0
local lerp = 0
local apLerp = 0
local index = -1
local time = 0
local colour = 0

function MetaEntity.SetCreateEntityToolTip(self, title, bool, text, icon, color)
	if(not IsValid(self)) then return end
	if (not ENT_TABLE_TOOLTIP) then ENT_TABLE_TOOLTIP = {} end

	local textX, textY = 0, 0

	title = title or 'No title'
	text = text or 'No text'
	bool = bool or false
	color = color or base:Theme('title')
	icon = icon

	ENT_TABLE_TOOLTIP[self] = { title, bool, text, color, icon }
end

local function HUDPaintEntityTooltip()
	local pPlayer = LocalPlayer()
	local x, y = ScrW(), ScrH()
	local trace = pPlayer:GetEyeTrace()

	-- check whether we're looking at a player
	if (trace.Hit and trace.Entity:IsPlayer()) then
		time = CurTime() + TIME
		index = trace.Entity:EntIndex()
	end

	-- get entity
    local entity = ents.GetByIndex(index) or nil
	if (entity ~= nil) then
		local hitPos = trace.HitPos
		local alpha = 255
		local viewdist = 100
		local fadeInTime = 0.5 -- Time of appearance
        local fadeOutTime = 0.5 -- Disappearance time
        local maxAlpha = 255

		-- calculate alpha
		local max, min = viewdist, viewdist * 0.75
		local dist = pPlayer:EyePos():Distance(hitPos)

		local frac = utils:InverseLerp(dist, max, min)
		if (dist > min and dist < max) then
			alpha = maxAlpha * frac
		elseif (dist > max) then
			alpha = 0
		end

		-- Updating the alpha with a smooth transition
        if (alpha > 0) then
            alpha = math.min(maxAlpha, alpha + (maxAlpha / fadeInTime * FrameTime()))
        else
            alpha = math.max(0, alpha - (maxAlpha / fadeOutTime * FrameTime()))
        end

		local entTable = {}

		for k, v in pairs(ents.FindInSphere(hitPos, 25)) do
			if (IsValid(v) and ENT_TABLE_TOOLTIP and ENT_TABLE_TOOLTIP[v]) then
				Table:Add(entTable, { hitPos:DistToSqr(v:GetPos()), v })
			end
		end

		Table:Sort(entTable, function(a, b) 
			return a[1] < b[1] 
		end)

		local ent = (entTable[1] or {})[2]
		if (ent ~= nil) then
			local position = select(1, ent:GetBonePosition(ent:LookupBone('ValveBiped.Bip01_Spine') or -1)) or ent:LocalToWorld(ent:OBBCenter())
			position = position:ToScreen()

			local arrowX, arrowY = clamp(position.x, 0, x), clamp(position.y, 0, y)
			local title, bool, text, color, icon = ENT_TABLE_TOOLTIP[ent][1], ENT_TABLE_TOOLTIP[ent][2], ENT_TABLE_TOOLTIP[ent][3], ENT_TABLE_TOOLTIP[ent][4], ENT_TABLE_TOOLTIP[ent][5]

			local width2, height2 = 0, 0
			local width, height = utils:GetTextSize(title, 'danlib_font_18')

			if bool then
				width2, height2 = utils:GetTextSize(text, 'danlib_font_18')
			end

			local showW, showY = arrowX, arrowY
			local text_w, text_y = 0, 0
			local w = bool and (width / width2) - (arrowX / arrowX) + 70  or 50

			tbl = { width + w - 28, height + 16 + height2, text_w + arrowX + 10, text_y + showY }

	    	if icon then
	    		tbl = { width + w, height + 16 + height2, text_w + arrowX + 36, text_y + showY }
	    	end

			if (alpha > 0) then
				DanLib.DrawShadow:Begin()
				utils:DrawRect(showW, showY, tbl[1], tbl[2], base:Theme('primary_notifi', alpha))
				DanLib.DrawShadow:End(1, 1, 1, 255, 0, 0, false)

				utils:DrawRect(showW + tbl[1] - 6, showY - 1, 7, 2, base:Theme('decor', alpha))
				utils:DrawRect(showW + tbl[1] - 1, showY, 2, 6, base:Theme('decor', alpha))

				utils:DrawRect(showW - 1, showY + tbl[2] - 6, 2, 6, base:Theme('decor', alpha))
				utils:DrawRect(showW - 1, showY + tbl[2] - 1, 7, 2, base:Theme('decor', alpha))

				local size = 20
				if icon then
					utils:DrawIcon(arrowX + 10, tbl[4] + 7, size, size, icon, ColorAlpha(color, alpha))
					noIcon = showW + 36
				end

				draw.SimpleText(title, 'danlib_font_18', tbl[3], tbl[4] + 15, ColorAlpha(color, alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				draw.DrawText(bool and text or '', 'danlib_font_18', tbl[3], tbl[4] + 24, base:Theme('text', alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			end
		end
	end
end
dHook:Add('HUDPaint', 'DDI.HUDPaintEntityTooltip', HUDPaintEntityTooltip)

local function RemoveEntityTooltip(ent)
	if (ENT_TABLE_TOOLTIP and ENT_TABLE_TOOLTIP[ent]) then
		ENT_TABLE_TOOLTIP[ent] = nil
	end
end
dHook:Add('EntityRemoved', 'DDI.RemoveEntityToolTip', RemoveEntityTooltip)