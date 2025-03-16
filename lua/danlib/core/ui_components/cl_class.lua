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



local UI = {}

local math = math
local num = isnumber
local isValid = IsValid
local screenScale = ScreenScale
local type = type

local Clamp = math.Clamp

local SW = ScrW
local SH = ScrH


--- Returns the width of the screen, capped at 3840 pixels.
-- @return number: The width of the screen.
function UI:ScrW()
    local w = SW()
    if (w > 3840) then w = 3840 end
    return w
end


--- Returns the height of the screen, capped at 2160 pixels.
-- @return number: The height of the screen.
function UI:ScrH()
    local h = SH()
    if (h > 2160) then h = 2160 end
    return h
end


--- Scales width and height values based on the screen size.
-- @param w: The width value to be scaled.
-- @param h: The height value to be scaled (optional, defaults to w).
-- @return number, number: The scaled width and height.
function UI:ClampScale(w, h)
    h = num(h) and h or w
    return Clamp(1920, 0, SW() / w), Clamp(1080, 0, SH() / h)
end


--- Clamps a width value between specified minimum and maximum values.
-- @param w: The width value to be clamped.
-- @param min: The minimum width value (optional, defaults to 0).
-- @param max: The maximum width value (optional, defaults to the scaled value of w).
-- @return number: The clamped width.
function UI:ClampScaleW(w, min, max)
    w = num(w) and w or SW()
    return Clamp(screenScale(w), min or 0, max or screenScale(w))
end


--- Clamps a height value between specified minimum and maximum values.
-- @param h: The height value to be clamped.
-- @param min: The minimum height value (optional, defaults to 0).
-- @param max: The maximum height value (optional, defaults to the scaled value of h).
-- @return number: The clamped height.
function UI:ClampScaleH(h, min, max)
    h = num(h) and h or SH()
    return Clamp(screenScale(h), min or 0, max or screenScale(h))
end


--- Returns a scaled value based on the screen width.
-- @param s: The base scale value.
-- @param m: The medium scale value (optional, defaults to s).
-- @param l: The large scale value (optional, defaults to s).
-- @return number: The scaled value based on screen width.
function UI:bscale(s, m, l)
    if (not m) then
    	m = s
    end

    if (not l) then l = s end

    if (SW() <= 1280) then
        return screenScale(s)
    elseif (SW() >= 1281 and SW() <= 1600) then
        return screenScale(m)
    elseif (SW() >= 1601) then
        return screenScale(l)
    else
        return s
    end
end


--- Returns a simple scaled value based on the screen width.
-- @param s: The base scale value.
-- @param m: The medium scale value (optional, defaults to s).
-- @param l: The large scale value (optional, defaults to s).
-- @return number: The simple scaled value based on screen width.
function UI:SetScaleSimple(s, m, l)
    if (not m) then m = s end
    if (not l) then l = s end

    if (SW() <= 1280) then
        return s
    elseif (SW() >= 1281 and SW() <= 1600) then
        return m
    elseif (SW() >= 1601) then
        return l
    else
        return s
    end
end


--- Sets the scale for width and height based on the current screen resolution.
-- @param w: The desired width (optional, defaults to 300).
-- @param h: The desired height (optional, defaults to w).
-- @return number, number: The scaled width and height.
function UI:SetScale(w, h)
    w = num(w) and w or 300
    h = num(h) and h or w

    local sc_w, sc_h = self:SetScaleSimple(0.85, 0.85, 0.90), self:SetScaleSimple(0.85, 0.85, 0.90)
    local parent_w, parent_h = w, h
    local ui_w, ui_h = sc_w * parent_w, sc_h * parent_h

    return ui_w, ui_h
end


--- Checks if the given object is a valid panel.
-- @param parent: The object to check for validity.
-- @return boolean: True if the object is a valid panel, false otherwise.
function UI:valid(parent)
    if (not parent or type(parent) ~= 'Panel') then return false end
    if (not isValid(parent)) then return false end
    return true
end


DanLib.UI = UI





-- Meta Function to Register Classes
local ui = FindMetaTable('Panel')


--- Checks if the given object is a valid panel.
-- @return boolean: True if the object is a valid panel, false otherwise.
function ui:Valid()
    if (not self or type(self) ~= 'Panel') then return false end
    if (not isValid(self)) then return false end
    return true
end


--- Calculates the position (x, y) for a specified parent panel based on the desired position string or integer.
-- @param parent The parent panel for which the position is calculated.
-- @param pos: The desired position (string or number, e.g., 'TOP', 'CENTER', etc.).
-- @param pad: The padding value (optional, defaults to 0).
-- @return number, number:The calculated x and y coordinates.
function ui:GetPosition(pos, pad)
	-- check > valid parent
    if (not self:Valid()) then return 0, 0 end

	-- validate > vars
    pos = num(pos) and pos or isstring(pos) and pos or 5
    pad = num(pad) and pad or 0

    -- define > vars
    local parent_w, parent_h = self:GetSize()
    local x, y  = 0, 0

    if (pos == 'TOP' or pos == 8) then -- top
        x, y = SW() / 2 - parent_w / 2, pad
    elseif (pos == 'TOP_RIGHT' or pos == 9) then -- top-right
        x, y = SW() - parent_w - 20, pad
    elseif (pos == 'RIGHT' or pos == 6) then -- right
        x, y = SW() - parent_w - pad, ((SH() / 2) - (parent_h / 2))
    elseif (pos == 'BOTTOM_RIGHT' or pos == 3) then -- bottom-right
        x, y = SW() - parent_w - pad, SH() - parent_h - pad
    elseif (pos == 'BOTTOM' or pos == 2) then -- bottom
        x, y = SW() / 2 - parent_w / 2, SH() - parent_h - pad
    elseif(pos == 'BOTTOM_LEFT' or pos == 1) then -- bottom-left
        x, y = pad, SH() - parent_h - pad
    elseif (pos == 'LEFT' or pos == 4) then -- left
        x, y = pad, ((SH() / 2) - (parent_h / 2))
    elseif (pos == 'TOP_LEF' or pos == 7) then -- top-left
        x, y = pad, pad
    elseif (pos == 'CENTER' or pos == 5) then -- center
        x, y  = ((SW() / 2) - (parent_w / 2)), ((SH() / 2) - (parent_h / 2))
    end

    return x, y
end


--- Makes the parent panel appear on the screen with a fading effect.
-- @param pos: The desired position for the panel (string or number, optional, defaults to 'CENTER').
-- @param time: The duration of the fade effect (optional, defaults to 0.3 seconds).
-- @param func: The callback function to be executed after the fade effect completes (optional).
-- @return nil
function ui:ApplyAppear(pos, time, func)
    if (not self:Valid()) then return end

    local pad = 20
    pos = (isnumber(pos) and pos or isstring(pos) and pos) or 5
    time = (isnumber(time) and time) or 0.3

    -- default size
    local x, y = self:GetPosition(pos, pad)
    self:SetAlpha(0)
    self:SetPos(x, y)
    self:AlphaTo(255, time or 0, 0, function()
        if isfunction(func) then
            func()
        else
            return
        end
    end)
end
