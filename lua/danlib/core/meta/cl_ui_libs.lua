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



local metaPanel = DanLib.MetaPanel
local DCustomUtils = DanLib.CustomUtils.Create
local DBase = DanLib.Func
local DUtils = DanLib.Utils
DanLib.UI = DanLib.UI or {}
local UI = DanLib.UI

local math = math
local round = math.Round
local max = math.max
local rad = math.rad
local min = math.min
local TimeFraction = math.TimeFraction
local clamp = math.Clamp


local surface = surface
local setMaterial = surface.SetMaterial
local setDrawColor = surface.SetDrawColor
local drawPoly = surface.DrawPoly
local drawTexturedRect = surface.DrawTexturedRect
local drawRect = surface.DrawRect
local SetFont = surface.SetFont
local getTextSize = surface.GetTextSize
local setTextColor = surface.SetTextColor
local find = string.find

local draw = draw
local SimpleText = draw.SimpleText
local NoTexture = draw.NoTexture

local render = render
local UpdateScreenEffectTexture = render.UpdateScreenEffectTexture
local drawTexturedRectRotated = surface.DrawTexturedRectRotated
local drawOutlinedRect = surface.DrawOutlinedRect

local SW = ScrW
local SH = ScrH

local defaultFont = 'danlib_font_18'


--- Smoothly displays the panel by increasing its alpha channel.
-- @param time (number): Animation time in seconds.
-- @param cb (function): A callback function to be called when the animation is complete.
function metaPanel:ApplyFadeInPanel(time, cb)
    self:SetVisible(true)
    self:SetAlpha(0)
    self:ApplyLerpFade(time, 0, 255, cb)
    return self
end


--- Smoothly hides the panel by reducing its alpha channel.
-- @param time (number): Animation time in seconds.
-- @param cb (function): A callback function to be called when the animation is complete.
function metaPanel:ApplyFadeOutPanel(time, cb)
    self:ApplyLerpFade(time, self:GetAlpha(), 0, cb)
    return self
end


--- Smoothly changes the panel's alpha channel to the specified value.
-- @param finalAlpha (number): Final alpha channel value (0-255).
function metaPanel:ApplyFadeTo(finalAlpha)
    self:ApplyLerpFade(0.5, nil, finalAlpha)
    return self
end


--- Performs linear interpolation (Lerp) to change the alpha channel of the panel.
-- @param time (number): Animation time in seconds.
-- @param currAlpha (number): Current alpha channel (defaults to the current value).
-- @param finalAlpha (number): Final alpha channel (default is 0).
-- @param sl (function): The callback function to be called when the animation is complete.
function metaPanel:ApplyLerpFade(time, currAlpha, finalAlpha, sl)
    local startTime = SysTime()
    local origAlpha = currAlpha or self:GetAlpha()
    local finalAlpha = finalAlpha or 0

    local anim = self:NewAnimation(time, 0, -1, function(_, pnl)
        if (sl) then sl() end
        if (origAlpha > finalAlpha) then pnl:SetVisible(false) end
    end)
    anim.Think = function(anim, pnl, fraction)
        local alpha = Lerp(fraction, origAlpha, finalAlpha)
        pnl:SetAlpha(alpha)
    end
    return self
end


--- Sets the cursor as an arrow for the panel.
function metaPanel:ArrowCursor()
	self:SetCursor('arrow')
	return self
end


--- Creates a shadow for the panel with the specified distance, number of iterations, and the option to disable clipping.
-- @param distance (number): The distance by which the shadow will be offset from the panel (default is 15).
-- @param noClip (boolean): If true, disables clipping for the shadow panel (defaults to false).
-- @param iteration (number): The number of iterations to render the shadow panel (defaults to 5).
function metaPanel:ApplyShadow(distance, noClip, iteration)
	distance = distance * 2 or 15 -- Set the default distance if not specified
	iteration = iteration or 5 -- Set the default number of iterations
	local color = Color(0, 0, 0) -- Shadow colour

	local panel = DCustomUtils(self:GetParent())
	panel:ApplyEvent('Think', function(sl, w, h)
		if (not UI:valid(self)) then
			sl:Remove() -- Delete a panel if the parent panel is invalid
			return
		end

        -- Update the position and size of the shadow panel
		local pos_x, pos_y = self:GetPos()
		panel:SetPos(pos_x - (distance / 2), pos_y - (distance / 2))
		panel:SetSize(self:GetWide() + distance, self:GetTall() + distance)
	end)

    -- Отрисовка тени
	panel:ApplyEvent(nil, function(sl, w, h)
		if (self:GetTall() == 0) then return end -- Abort if the panel height is 0
		for i = 0, iteration do
            local alpha = ColorAlpha(color, i * 5) -- Apply the alpha channel
			draw.RoundedBox(0, i * (distance / iteration) / 2, i * (distance / iteration) / 2, w - (distance / iteration) * i, h - (distance / iteration) * i, alpha)
		end
	end)

	if noClip then panel:NoClipping(true) end -- Disable trimming if specified
	panel:SetZPos(self:GetZPos() - 1) -- Set the Z-position of the shadow panel
end


--- Creates an alpha transparency effect for a hover and time sensitive panel.
-- @param hoverDuration (number): The time for which the panel will be completely opaque on hover.
-- @param hoverAlpha (number): The alpha value (transparency) of the panel when hovering (default 255).
-- @param decreaseDuration (number): The time for which the panel will decrease its transparency to the specified value.
-- @param decreaseAlpha (number): The alpha value of the panel after reduction (default is 0).
-- @param extraEnabled (boolean): Enables extra alpha transparency behaviour (default false).
-- @param extraAlpha (number): Alpha value for the extra state (default 255).
-- @param extraDuration (number): Time for which the extra state will be in effect (default 0.2).
function metaPanel:ApplyAlpha(hoverDuration, hoverAlpha, decreaseDuration, decreaseAlpha, extraEnabled, extraAlpha, extraDuration)
    hoverAlpha = hoverAlpha or 255
    decreaseAlpha = decreaseAlpha or 0
    extraAlpha = extraAlpha or 255
    hoverDuration = hoverDuration or (hoverAlpha / 255) * 0.2
    decreaseDuration = decreaseDuration or 0.2
    extraDuration = extraDuration or (extraAlpha / 255) * 0.2

    -- Initialising alpha if it is not set
    self.alpha = self.alpha or 0

    if extraEnabled then
        if (not self.extraEndTime) then
            self.hoverEndTime = nil
            self.decreaseEndTime = nil
            self.extraEndTime = CurTime() + extraDuration
        end

        self.alpha = clamp((extraDuration - (self.extraEndTime - CurTime())) / extraDuration, 0, 1) * extraAlpha
    elseif self:IsHovered() then
        if (not self.hoverEndTime) then
            self.extraEndTime = nil
            self.decreaseEndTime = nil
            self.hoverEndTime = CurTime() + hoverDuration
        end
        self.alpha = clamp((hoverDuration - (self.hoverEndTime - CurTime())) / hoverDuration, 0, 1 ) * hoverAlpha
    else
        if (not self.decreaseEndTime) then
            self.hoverEndTime = nil
            self.extraEndTime = nil
            self.decreaseEndTime = CurTime() + decreaseDuration
        end
        self.alpha = Lerp(clamp((decreaseDuration - (self.decreaseEndTime - CurTime())) / decreaseDuration, 0, 1), self.alpha, decreaseAlpha)
    end
end


-- Initialising the screen size
if (not DanLib.ScrW or not DanLib.ScrH) then
	DanLib.ScrW = SW()
	DanLib.ScrH = SH()
end

DanLib.Hook:Add('OnScreenSizeChanged', 'DanLib:OnScreenSizeChanged', function()
	DanLib.ScrW = SW()
	DanLib.ScrH = SH()
end)


--- Creates a tooltip for the panel.
-- @param text (string): The text of the tooltip.
-- @param strColor (Color): The colour of the tooltip text (defaults to the theme colour).
-- @param strIcon (string): Tooltip icon (default is nil).
-- @param align (number): The alignment of the tooltip (default is CENTER).
function metaPanel:ApplyTooltip(text, strColor, strIcon, align)
    align = align or CENTER
    strColor = strColor or DBase:Theme('text')
    local defaultFont = 'danlib_font_18'

    local function Tooltip(Panel, text)
        if (not UI:valid(Panel)) then
            return
        end

        local isMultiline = find(text, '\n') ~= nil
        local hasMarkup = find(text, '{') and find(text, '}')

        -- use safe dimensioning
        local w, h = DUtils:GetSafeTextSize(text, defaultFont)

        local padding = strIcon and 50 or 20
        local tooltipWidth = w + padding
        local tooltipHeight = h + 10

        local lbl = DCustomUtils(self)
        lbl:SetSize(tooltipWidth, tooltipHeight)
        lbl:SetMouseInputEnabled(false)
        lbl:SetAlpha(0)
        lbl:AlphaTo(255, 0.1)
        lbl:SetDrawOnTop(true)
        lbl:MakePopup()

        local SW, SH = DanLib.ScrW, DanLib.ScrH
        lbl:ApplyEvent('Think', function(sl)
            if (not UI:valid(Panel) or not Panel:IsVisible()) then
                sl:Remove()
                return
            end

            -- Getting cursor coordinates
            local mouse_x, mouse_y = gui.MouseX(), gui.MouseY()
            
            -- Check if the cursor is within the game window
            if (mouse_x < 0 or mouse_x > SW or mouse_y < 0 or mouse_y > SH) then
                sl:Remove() -- Remove the hint if the cursor is outside the game window area
                return
            end

            -- Get the position and dimensions of the parent element
            local pos_x, pos_y = Panel:LocalToScreen(0, 0)
            local PanelWide, PanelTall = Panel:GetWide(), Panel:GetTall()
            local x, y = 0, 0

            -- Checking that the parent's size is not equal to nil
            if (not PanelWide or not PanelTall or PanelWide <= 0 or PanelTall <= 0) then
                sl:Remove() -- Remove the hint if the parent's dimensions are incorrect
                return
            end

            -- Check if the cursor is within the parent panel
            if (mouse_x < pos_x or mouse_x > pos_x + PanelWide or mouse_y < pos_y or mouse_y > pos_y + PanelTall) then
                sl:Remove() -- Remove the hint if the cursor is outside the parent panel
                return
            end

            if (align == RIGHT) then
                x = pos_x + PanelWide + 10
                y = pos_y + PanelTall * 0.5 - tooltipHeight * 0.5
            elseif (align == LEFT) then
                x = pos_x - tooltipWidth - 10
                y = pos_y + PanelTall * 0.5 - tooltipHeight * 0.5
            elseif (align == TOP) then
                x = pos_x + PanelWide * 0.5 - tooltipWidth * 0.5
                y = pos_y - tooltipHeight - 10
            elseif (align == BOTTOM) then
                x = pos_x + PanelWide * 0.5 - tooltipWidth * 0.5
                y = pos_y + PanelTall + 10
            else
                x = mouse_x + 14
                y = mouse_y + 14
            end

            x = clamp(x, 0, SW - tooltipWidth)
            y = clamp(y, 0, SH - tooltipHeight)
            sl:SetPos(x, y)
        end)
        lbl:ApplyEvent(nil, function(sl, w, h)
			DanLib.DrawShadow:Begin()
			local x, y = sl:LocalToScreen(0, 0)
			DUtils:DrawRoundedBox(x, y, w, h, DBase:Theme('primary_notifi'))
			DanLib.DrawShadow:End(1, 1, 1, 255, 0, 0, false)

            -- Draw an icon, if any
            if strIcon then
                local iconY = h * 0.5 - 9 -- Centre the icon vertically
                DUtils:DrawIconOrMaterial(14, iconY, 18, strIcon, strColor)
            end

            local textX = strIcon and 38 or 10
            
            -- maximum available width for DrawParseText
            local availableWidth = w - textX - 5 -- reduced the indentation from 10 to 5
            
            if isMultiline then
                local lines = string.Explode('\n', text)
                local lineHeight = select(2, DUtils:TextSize('Test', defaultFont).h) or 16
                local startY = 5
                
                for i, line in ipairs(lines) do
                    local lineY = startY + (i - 1) * lineHeight
                    if hasMarkup and DUtils.DrawParseText then
                        DUtils:DrawParseText(line, defaultFont, textX, lineY, strColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, availableWidth, TEXT_ALIGN_LEFT)
                    else
                        draw.DrawText(line, defaultFont, textX, lineY, strColor, TEXT_ALIGN_LEFT)
                    end
                end
            else
                if hasMarkup and DUtils.DrawParseText then
                    local centerY = h * 0.5
                    -- Pass the maximum width to prevent carryover
                    DUtils:DrawParseText(text, defaultFont, textX, centerY, strColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, availableWidth, TEXT_ALIGN_LEFT)
                else
                    local centerY = h * 0.5 - 10
                    draw.DrawText(text, defaultFont, textX, centerY, strColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                end
            end
        end)

        return lbl
    end

    self:CustomUtils()
    self:ApplyEvent('OnCursorEntered', function(sl)
        if UI:valid(sl.tooltip) then sl.tooltip:Remove() end
        sl.tooltip = Tooltip(sl, text)
    end)

    self:ApplyEvent('OnCursorExited', function(sl)
        if UI:valid(sl.tooltip) then sl.tooltip:Remove() end
    end)

    return self
end



/***
 *   The following functions and methods are included:
 *   - Ease: Applies an easing function to transition values smoothly over time.
 *   - ApplyLerpColor: Linearly interpolates between two colors over a specified duration.
 *   - ApplyLerpVector: Linearly interpolates between two vectors over a specified duration.
 *   - ApplyLerpAngle: Linearly interpolates between two angles over a specified duration.
 *   - ApplyEndAnimations: Ends all currently running animations and triggers their end callbacks.
 *   - ApplyLerp: Linearly interpolates between two numerical values over a specified duration.
 *   - ApplyLerpMove: Moves a panel to a specified position (x, y) over a specified duration.
 *   - ApplyLerpMoveY: Moves a panel vertically to a specified y-coordinate over a specified duration.
 *   - ApplyLerpMoveX: Moves a panel horizontally to a specified x-coordinate over a specified duration.
 *   - ApplyLerpHeight: Changes the height of a panel over a specified duration.
 *   - ApplyLerpWidth: Changes the width of a panel over a specified duration.
 *   - ApplyLerpSize: Changes the size of a panel to specified width and height over a specified duration.
 *
 *   This file is designed to facilitate smooth animations for UI elements, allowing for
 *   visually appealing transitions and movements within the game interface.
 *
 *   Usage example:
 *   - To animate a panel's color:
 *     panel:ApplyLerpColor('backgroundColor', Color(255, 0, 0), 0.5, function(pnl)
 *         print(pnl:GetName() .. ' color animation completed.')
 *     end)
 *
 *   - To animate a panel's position:
 *     panel:ApplyLerpMove(100, 200, 0.5)
 *
 *   @notes: Ensure that animations are properly managed to avoid conflicting transitions.
 *   Each animation can have an optional callback function that executes upon completion.
 */



-- DanLib UI Module
DanLibUI = {}
local TransitionTime = 0.15


--- Eases a value over time using a cubic polynomial.
-- @param t (number): The current time.
-- @param b (number): The beginning value.
-- @param c (number): The change in value.
-- @param d (number): The duration.
-- @return (number): The eased value.
function DanLibUI:Ease(t, b, c, d)
    t = t / d
    local ts = t * t
    local tc = ts * t
    return b + c * (-2 * tc + 3 * ts)
end


--- Linearly interpolates the color property of a panel over a duration.
-- @param var (string): The color property to animate.
-- @param to (Color): The target color.
-- @param duration (number): The duration of the animation.
-- @param callback (function): Optional callback function called when the animation ends.
function metaPanel:ApplyLerpColor(var, to, duration, callback)
    duration = duration or TransitionTime
    local color = self[var]
    local anim = self:NewAnimation(duration)
    anim.Color = to
    anim.Think = function(anim, pnl, fract)
        local newFract = DanLibUI:Ease(fract, 0, 1, 1)
        if (not anim.StartColor) then anim.StartColor = color end
        self[var] = DUtils:LerpColor(newFract, anim.StartColor, anim.Color)
    end
    anim.OnEnd = function() if callback then callback(self) end end
end


--- Linearly interpolates the vector property of a panel over a duration.
-- @param var (string): The vector property to animate.
-- @param to (Vector): The target vector.
-- @param duration (number): The duration of the animation.
-- @param callback (function): Optional callback function called when the animation ends.
function metaPanel:ApplyLerpVector(var, to, duration, callback)
    duration = duration or TransitionTime
    local vector = self[var]
    local anim = self:NewAnimation(duration)
    anim.Vector = to
    anim.Think = function(anim, pnl, fract)
        local newFract = DanLibUI:Ease(fract, 0, 1, 1)
        if (not anim.StartVector) then anim.StartVector = vector end
        self[var] = DanLibUI:LerpVector(newFract, anim.StartVector, anim.Vector)
    end
    anim.OnEnd = function() if callback then callback(self) end end
end


--- Linearly interpolates the angle property of a panel over a duration.
-- @param var (string): The angle property to animate.
-- @param to (Angle): The target angle.
-- @param duration (number): The duration of the animation.
-- @param callback (function): Optional callback function called when the animation ends.
function metaPanel:ApplyLerpAngle(var, to, duration, callback)
    duration = duration or TransitionTime
    local angle = self[var]
    local anim = self:NewAnimation(duration)
    anim.Angle = to
    anim.Think = function(anim, pnl, fract)
        local newFract = DanLibUI:Ease(fract, 0, 1, 1)
        if (not anim.StartAngle) then anim.StartAngle = angle end
        self[var] = DanLibUI:LerpAngle(newFract, anim.StartAngle, anim.Angle)
    end
    anim.OnEnd = function() if callback then callback(self) end end
end


--- Ends all currently running animations for the panel.
function metaPanel:ApplyEndAnimations()
    for i, v in pairs(self.m_AnimList or {}) do
        if (v.OnEnd) then v:OnEnd(self) end
        self.m_AnimList[i] = nil
    end
end


--- Linearly interpolates a numerical property of a panel over a duration.
-- @param var (string): The property to animate.
-- @param to (number): The target value.
-- @param duration (number): The duration of the animation.
-- @param callback (function): Optional callback function called when the animation ends.
function metaPanel:ApplyLerp(var, to, duration, callback)
    duration = duration or TransitionTime
    local varStart = self[var]
    local anim = self:NewAnimation(duration)
    anim.Goal = to
    anim.Think = function(anim, pnl, fract)
        local newFract = DanLibUI:Ease(fract, 0, 1, 1)
        if (not anim.Start) then anim.Start = varStart end
        self[var] = Lerp(newFract, anim.Start, anim.Goal)
    end
    anim.OnEnd = function() if callback then callback(self) end end
end


--- Moves a panel to a specified position over a duration.
-- @param x (number): The target x-coordinate.
-- @param y (number): The target y-coordinate.
-- @param duration (number): The duration of the animation.
-- @param callback (function): Optional callback function called when the animation ends.
function metaPanel:ApplyLerpMove(x, y, duration, callback)
    duration = duration or TransitionTime
    local anim = self:NewAnimation(duration)
    anim.Pos = Vector(x, y)
    anim.Think = function(anim, pnl, fract)
        local newFract = DanLibUI:Ease(fract, 0, 1, 1)
        if (not anim.StartPos) then anim.StartPos = Vector(pnl.x, pnl.y, 0) end
        local new = LerpVector(newFract, anim.StartPos, anim.Pos)
        self:SetPos(new.x, new.y)
    end
    anim.OnEnd = function() if callback then callback(self) end end
end


--- Moves a panel vertically to a specified y-coordinate over a duration.
-- @param y (number): The target y-coordinate.
-- @param duration (number): The duration of the animation.
-- @param callback (function): Optional callback function called when the animation ends.
function metaPanel:ApplyLerpMoveY(y, duration, callback)
    duration = duration or TransitionTime
    local anim = self:NewAnimation(duration)
    anim.Pos = y
    anim.Think = function(anim, pnl, fract)
        local newFract = DanLibUI:Ease(fract, 0, 1, 1)
        if (not anim.StartPos) then anim.StartPos = pnl.y end
        local new = Lerp(newFract, anim.StartPos, anim.Pos)
        self:SetPos(pnl.x, new)
    end
    anim.OnEnd = function() if callback then callback(self) end end
end


--- Moves a panel horizontally to a specified x-coordinate over a duration.
-- @param x (number): The target x-coordinate.
-- @param duration (number): The duration of the animation.
-- @param callback (function): Optional callback function called when the animation ends.
function metaPanel:ApplyLerpMoveX(x, duration, callback)
    duration = duration or TransitionTime
    local anim = self:NewAnimation(duration)
    anim.Pos = x
    anim.Think = function(anim, pnl, fract)
        local newFract = DanLibUI:Ease(fract, 0, 1, 1)
        if (not anim.StartPos) then anim.StartPos = pnl.x end
        local new = Lerp(newFract, anim.StartPos, anim.Pos)
        self:SetPos(new, pnl.y)
    end
    anim.OnEnd = function() if callback then callback(self) end end
end


--- Changes the height of the panel over a duration.
-- @param height (number): The target height.
-- @param duration (number): The duration of the animation.
-- @param callback (function): Optional callback function called when the animation ends.
-- @param easeFunc (function): Optional custom easing function.
function metaPanel:ApplyLerpHeight(height, duration, callback, easeFunc)
    duration = duration or TransitionTime
    easeFunc = easeFunc or function(a, b, c, d) return DanLibUI:Ease(a, b, c, d) end

    local anim = self:NewAnimation(duration)
    anim.Height = height
    anim.Think = function(anim, pnl, fract)
        local newFract = easeFunc(fract, 0, 1, 1)
        if (not anim.StartHeight) then anim.StartHeight = pnl:GetTall() end
        self:SetTall(Lerp(newFract, anim.StartHeight, anim.Height))
    end
    anim.OnEnd = function() if callback then callback(self) end end
end


--- Changes the width of the panel over a duration.
-- @param width (number): The target width.
-- @param duration (number): The duration of the animation.
-- @param callback (function): Optional callback function called when the animation ends.
-- @param easeFunc (function): Optional custom easing function.
function metaPanel:ApplyLerpWidth(width, duration, callback, easeFunc)
    duration = duration or TransitionTime
    easeFunc = easeFunc or function(a, b, c, d) return DanLibUI:Ease(a, b, c, d) end

    local anim = self:NewAnimation(duration)
    anim.Width = width
    anim.Think = function(anim, pnl, fract)
        local newFract = easeFunc(fract, 0, 1, 1)
        if (not anim.StartWidth) then anim.StartWidth = pnl:GetWide() end
        self:SetWide(Lerp(newFract, anim.StartWidth, anim.Width))
    end
    anim.OnEnd = function() if callback then callback(self) end end
end


--- Changes the size of the panel to specified width and height over a duration.
-- @param w (number): The target width.
-- @param h (number): The target height.
-- @param duration (number): The duration of the animation.
-- @param callback (function): Optional callback function called when the animation ends.
function metaPanel:ApplyLerpSize(w, h, duration, callback)
    duration = duration or TransitionTime
    local anim = self:NewAnimation(duration)
    anim.Size = Vector(w, h)
    anim.Think = function(anim, pnl, fract)
        local newFract = DanLibUI:Ease(fract, 0, 1, 1)
        if (not anim.StartSize) then anim.StartSize = Vector(pnl:GetWide(), pnl:GetWide(), 0) end
        local new = LerpVector(newFract, anim.StartSize, anim.Size)
        self:SetSize(new.x, new.y)
    end
    anim.OnEnd = function() if callback then callback() end end
end
