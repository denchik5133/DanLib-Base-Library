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
 *   cl_animations.lua
 *   This file contains utility functions for animating properties of panels within the DanLib UI framework.
 *
 *   The following functions and methods are included:
 *   - Ease: Applies an easing function to transition values smoothly over time.
 *   - LerpColor: Linearly interpolates between two colors over a specified duration.
 *   - LerpVector: Linearly interpolates between two vectors over a specified duration.
 *   - LerpAngle: Linearly interpolates between two angles over a specified duration.
 *   - EndAnimations: Ends all currently running animations and triggers their end callbacks.
 *   - Lerp: Linearly interpolates between two numerical values over a specified duration.
 *   - LerpMove: Moves a panel to a specified position (x, y) over a specified duration.
 *   - LerpMoveY: Moves a panel vertically to a specified y-coordinate over a specified duration.
 *   - LerpMoveX: Moves a panel horizontally to a specified x-coordinate over a specified duration.
 *   - LerpHeight: Changes the height of a panel over a specified duration.
 *   - LerpWidth: Changes the width of a panel over a specified duration.
 *   - LerpSize: Changes the size of a panel to specified width and height over a specified duration.
 *
 *   This file is designed to facilitate smooth animations for UI elements, allowing for
 *   visually appealing transitions and movements within the game interface.
 *
 *   Usage example:
 *   - To animate a panel's color:
 *     panel:LerpColor('backgroundColor', Color(255, 0, 0), 0.5, function(pnl)
 *         print(pnl:GetName() .. ' color animation completed.')
 *     end)
 *
 *   - To animate a panel's position:
 *     panel:LerpMove(100, 200, 0.5)
 *
 *   @notes: Ensure that animations are properly managed to avoid conflicting transitions.
 *   Each animation can have an optional callback function that executes upon completion.
 */



-- DanLib UI Module
DanLibUI = {}
local meta = DanLib.MetaPanel
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
function meta:LerpColor(var, to, duration, callback)
	duration = duration or TransitionTime
	local color = self[var]
	local anim = self:NewAnimation(duration)
	anim.Color = to
	anim.Think = function(anim, pnl, fract)
		local newFract = DanLibUI:Ease(fract, 0, 1, 1)
		if (not anim.StartColor) then anim.StartColor = color end
		self[var] = DanLib.Utils:LerpColor(newFract, anim.StartColor, anim.Color)
	end
	anim.OnEnd = function() if callback then callback(self) end end
end


--- Linearly interpolates the vector property of a panel over a duration.
-- @param var (string): The vector property to animate.
-- @param to (Vector): The target vector.
-- @param duration (number): The duration of the animation.
-- @param callback (function): Optional callback function called when the animation ends.
function meta:LerpVector(var, to, duration, callback)
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
function meta:LerpAngle(var, to, duration, callback)
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
function meta:EndAnimations()
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
function meta:Lerp(var, to, duration, callback)
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
function meta:LerpMove(x, y, duration, callback)
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
function meta:LerpMoveY(y, duration, callback)
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
function meta:LerpMoveX(x, duration, callback)
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
function meta:LerpHeight(height, duration, callback, easeFunc)
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
function meta:LerpWidth(width, duration, callback, easeFunc)
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
function meta:LerpSize(w, h, duration, callback)
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
