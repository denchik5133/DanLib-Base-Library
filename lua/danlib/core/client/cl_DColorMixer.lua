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
 *	@todo Find time to finish it.
 *
 *	@notes
 */



local formatHandlers = {
    RGB = function(input)
        return DanLib.Utils:ParseColor(input, 'RGB')
    end,
    HEX = function(input)
        return DanLib.Utils:ParseColor(input, 'HEX')
    end,
    CMYK = function(input)
        local c, m, y, k = DanLib.Utils:ParseColor(input, 'CMYK')
        return DanLib.Utils:CMYKtoRGB(c, m, y, k), 255
    end,
    HSV = function(input)
        local h, s, v = DanLib.Utils:ParseColor(input, 'HSV')
        return DanLib.Utils:HSVtoRGB(h, s, v), 255
    end,
    HSL = function(input)
        local h, s, l = DanLib.Utils:ParseColor(input, 'HSL')
        return DanLib.Utils:HSLtoRGB(h, s, l), 255
    end
}


local math = math
local clamp = math.Clamp
local floor = math.floor
local string = string
local format = string.format

--- https://github.com/Facepunch/garrysmod/blob/master/garrysmod/lua/vgui/dcolormixer.lua

local MIXER, Constructor = DanLib.UiPanel()

AccessorFunc(MIXER, 'm_bPalette', 'Palette', FORCE_BOOL)
AccessorFunc(MIXER, 'm_bAlpha', 'AlphaBar', FORCE_BOOL)
AccessorFunc(MIXER, 'm_bWangsPanel', 'Wangs', FORCE_BOOL)
AccessorFunc(MIXER, 'm_Color', 'Color')

function MIXER:Init()
	local conteiner = DanLib.CustomUtils.Create(self):Pin(nil, 6)
	local scroll = DanLib.CustomUtils.Create(conteiner, 'DanLib.UI.Scroll')
	scroll:PinMargin(BOTTOM, nil, 8)
	scroll:SetTall(60)
	scroll:ToggleScrollBar()

	-- The number stuff
	self.WangsPanel = DanLib.CustomUtils.Create(conteiner)
	self.WangsPanel:PinMargin(BOTTOM, nil, 10, nil, 4)
	self.WangsPanel:SetTall(26)
	self:SetWangs(true)

	self.combo = DanLib.Func.CreateUIComboBox(self.WangsPanel)
	self.combo:PinMargin(RIGHT, 4)
	self.combo:SetWide(80)
	self.combo:SetValue('RGB')
	self.combo:SetDirection(true)

	local colorFormat = 'RGB' -- Initially set the format to RGB
	local options = { 'RGB', 'HEX', 'CMYK', 'HSV', 'HSL' }
	for k, v in pairs(options) do
        self.combo:AddChoice(v, k)
    end

    self.combo:ApplyEvent('OnSelect', function(_, index, value, data)
    	colorFormat = value
    	paletteRefresh()
	    self:UpdateColor(self:GetColor(), value) -- Colour update when a new format is selected
	end)

    function paletteRefresh()
		self.Palette = DanLib.CustomUtils.Create(scroll, 'DanLib.UI.ColorPalette')
		self.Palette:Pin()
		self.Palette:SetFormatRGB(colorFormat)
		self.Palette:SetButtonSize(24)
		self.Palette:Reset()
		self.Palette:ApplyEvent('DoClick', function(ctrl, color, btn)
			self:SetColor(DanLib.Utils:UiColor(color.r, color.g, color.b, self:GetAlphaBar() and color.a or 255))
		end)
		self:SetPalette(true)
	end
	paletteRefresh()

	self.input = DanLib.Func.CreateTextEntry(self.WangsPanel)
	self.input:Pin()
	self.input:SetValue('255, 0, 0, 255')
	self.input.textEntry:ApplyEvent('OnTextChanged', function()
	    local inputValue = self.input:GetValue()
	    -- print(colorFormat)
	    local r, g, b, a = formatHandlers[colorFormat](inputValue)

	    -- Check nil
	    if (r == nil or g == nil or b == nil or a == nil) then return end

	    -- Limit values from 0 to 255
	    r = math.Clamp(r, 0, 255)
	    g = math.Clamp(g, 0, 255)
	    b = math.Clamp(b, 0, 255)
	    a = math.Clamp(a, 0, 255)

	    -- Colour update
	    local color = self:GetColor()
	    color.r = r
	    color.g = g
	    color.b = b
	    color.a = a

	    -- Colour update in Alpha bar
	    self.Alpha:SetBarColor(ColorAlpha(color, 255))
	    self.Alpha:SetValue(color.a / 255)

	    -- Color update in HSV
	    self.HSV:SetColor(color)

	    -- Colour Update
	    self:UpdateColor(color)
	end)


	-- The colouring stuff
	self.HSV = DanLib.CustomUtils.Create(conteiner, 'DanLib.UI.ColorCube')
	self.HSV:Pin()
	self.HSV:ApplyEvent('OnUserChanged', function(ctrl, color)
		color.a = self:GetColor().a
		self:UpdateColor(color)
	end)

	self.Alpha = DanLib.CustomUtils.Create(self, 'DanLib.UI.AlphaBar')
	self.Alpha:PinMargin(RIGHT, 4, 4)
	self.Alpha:SetWidth(14)
	self.Alpha:ApplyEvent('OnChange', function(ctrl, fAlpha)
		self:GetColor().a = floor(fAlpha * 255)
		self:UpdateColor(self:GetColor())
	end)
	self:SetAlphaBar(true)

	self.RGB = DanLib.CustomUtils.Create(self, 'DanLib.UI.RGBPicker')
	self.RGB:PinMargin(LEFT, nil, 4, 4)
	self.RGB:SetWidth(14)
	self.RGB:ApplyEvent('OnChange', function(ctrl, color)
		self:SetBaseColor(color)
	end)

	-- Layout
	self:SetColor(DanLib.Utils:UiColor(255, 0, 0, 255))
	self:SetSize(256, 230)
	self:InvalidateLayout()
end

function MIXER:SetPalette(bEnabled)
	self.m_bPalette = bEnabled
	-- self.Palette:SetVisible(bEnabled)
	self:InvalidateLayout()
end

function MIXER:SetAlphaBar(bEnabled)
	self.m_bAlpha = bEnabled
	self.Alpha:SetVisible(bEnabled)
	-- self.txtA:SetVisible(bEnabled)
	self:InvalidateLayout()
end

function MIXER:SetWangs(bEnabled)
	self.m_bWangsPanel = bEnabled
	self.WangsPanel:SetVisible(bEnabled)
	self:InvalidateLayout()
end

-- function MIXER:PerformLayout(w, h)
-- 	local hue, s, v = ColorToHSV(self.HSV:GetBaseRGB())
-- 	self.RGB.LastY = (1 - hue / 360) * self.RGB:GetTall()
-- end

function MIXER:SetColor(color)
	local hue, s, v = ColorToHSV(color)
	self.RGB.LastY = (1 - hue / 360) * self.RGB:GetTall()
	self.HSV:SetColor(color)
	self:UpdateColor(color)
end

function MIXER:SetVector(vec)
	self:SetColor(DanLib.Utils:UiColor(vec.x * 255, vec.y * 255, vec.z * 255, 255))
end

function MIXER:SetBaseColor(color)
	self.HSV:SetBaseRGB(color)
	self.HSV:TranslateValues()
end

function MIXER:UpdateColor(color, type)
	self.Alpha:SetBarColor(ColorAlpha(color, 255))
	self.Alpha:SetValue(color.a / 255)

	self.input:SetValue(format('%d, %d, %d, %d', color.r, color.g, color.b, color.a))

    -- Updating the text field depending on the format
    -- if (type == 'RGB') then
    --     self.input:SetValue(format('%d, %d, %d, %d', color.r, color.g, color.b, color.a))
    -- elseif (type == 'HEX') then
    --     local hex = format('##%02X%02X%02X', color.r, color.g, color.b)
    --     self.input:SetValue(hex)
    -- elseif (type == 'CMYK') then
    --     local c, m, y, k = DanLib.Utils:RGBtoCMYK(color.r, color.g, color.b)
    --     self.input:SetValue(format('%d, %d, %d, %d', c, m, y, k))
    -- elseif (type == 'HSV') then
    --     local h, s, v = ColorToHSV(color)
    --     self.input:SetValue(format('%d, %d, %d, %d', h, s, v, color.a))
    -- elseif (type == 'HSL') then
    --     local h, s, l = DanLib.Utils:RGBtoHSL(color.r, color.g, color.b)
    --     self.input:SetValue(format('%d, %d, %d, %d', h, s, l, color.a))
    -- end

	self:ValueChanged(color)
	self.m_Color = color
end

function MIXER:ValueChanged(color)
	-- Override
end

function MIXER:GetColor()
	self.m_Color.a = 255
	if self.Alpha:IsVisible() then self.m_Color.a = floor(self.Alpha:GetValue() * 255) end
	return self.m_Color
end

function MIXER:GetVector()
	local col = self:GetColor()
	return Vector(col.r / 255, col.g / 255, col.b / 255)
end

MIXER:Register('DanLib.UI.ColorMixer')













-- DanLib.Func:RequestColorChangesPopup('COLOR MIXER', color_white, nil, function(value) end)


if IsValid(FrameS) then FrameS:Remove() end
local function testColorMixer()
	if IsValid(FrameS) then FrameS:Remove() end

	local Frame = DanLib.Func.CreateUIFrame()
	FrameS = Frame
	FrameS:SetTitle('Color Picker')
	Frame:SetSize(300, 350)
	Frame:Center()
	Frame:MakePopup()

	local Picker = DanLib.CustomUtils.Create(Frame, 'DanLib.UI.ColorMixer')
	Picker:Pin(FILL, 10)
	Picker:SetPalette(true)
	Picker:SetAlphaBar(true)
	Picker:SetWangs(true)
	Picker:SetColor(Color(30,100,160))

	-- local Button = DanLib.Func.CreateUIButton(Frame, {
    --     background = {nil},
    --     dock_indent = {BOTTOM, 10, nil, 10, 10},
    --     tall = 30,
    --     hover = {Color(106, 178, 242, 50), nil, 6},
    --     text = {DanLib.Func:L('confirm'), 'danlib_font_20', nil, nil, Color(106, 178, 242)},
    --     click = function()
    --         local val = Picker:GetColor()
    --         -- print(format('R: %d\nG: %d\nB: %d\nA: %d', val.r, val.g, val.b, val.a))
    --         print(val)
    --     end
    -- })
end
-- testColorMixer()
