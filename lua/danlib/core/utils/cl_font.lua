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
 


local base = DanLib.Func
local dHook = DanLib.Hook

local SH = ScrH() / 1080
local SW = ScrW() / 1920
local Ratio = math.min(SH, SW)

function base:GetSize(number)
    return number * Ratio * (DDI.Scale or 1)
end

function base:CreateFont(name, size, font, weight, mergeTbl)
    local tbl = {
        font = font or 'Montserrat Regular', -- Montserrat Medium
        size = size or self:GetSize(18),
        weight = weight or 500,
        extended = true
    }

    if mergeTbl then
        table.Merge(tbl, mergeTbl)
    end

    surface.CreateFont(name, tbl)
end

function base:LoadedFonts()
    self:CreateFont('danlib_font_12', self:GetSize(12))
    self:CreateFont('danlib_font_14', self:GetSize(14))
    self:CreateFont('danlib_font_16', self:GetSize(16))
    self:CreateFont('danlib_font_18', self:GetSize(18))
    self:CreateFont('danlib_font_20', self:GetSize(20))
    self:CreateFont('danlib_font_22', self:GetSize(22))
    self:CreateFont('danlib_font_24', self:GetSize(24))
    self:CreateFont('danlib_font_26', self:GetSize(26))
    self:CreateFont('danlib_font_28', self:GetSize(28))
    self:CreateFont('danlib_font_30', self:GetSize(30))
    self:CreateFont('danlib_font_32', self:GetSize(32))
    self:CreateFont('danlib_font_34', self:GetSize(34))
    self:CreateFont('danlib_font_36', self:GetSize(36))
    self:CreateFont('danlib_font_38', self:GetSize(38))
    self:CreateFont('danlib_font_40', self:GetSize(40))
    self:CreateFont('danlib_font_42', self:GetSize(42))
    self:CreateFont('danlib_font_44', self:GetSize(44))
    self:CreateFont('danlib_font_46', self:GetSize(46))
    self:CreateFont('danlib_font_48', self:GetSize(48))
    self:CreateFont('danlib_font_50', self:GetSize(50))
    self:CreateFont('danlib_font_52', self:GetSize(52))
    self:CreateFont('danlib_font_54', self:GetSize(54))
    self:CreateFont('danlib_font_56', self:GetSize(56))
    self:CreateFont('danlib_font_58', self:GetSize(58))
    self:CreateFont('danlib_font_60', self:GetSize(60))
    self:CreateFont('danlib_font_62', self:GetSize(62))
    self:CreateFont('danlib_font_64', self:GetSize(64))
    self:CreateFont('danlib_font_66', self:GetSize(66))
    self:CreateFont('danlib_font_68', self:GetSize(68))
    self:CreateFont('danlib_font_70', self:GetSize(70))
    self:CreateFont('danlib_font_72', self:GetSize(72))
    self:CreateFont('danlib_font_74', self:GetSize(74))
    self:CreateFont('danlib_font_76', self:GetSize(76))
    self:CreateFont('danlib_font_78', self:GetSize(78))
    self:CreateFont('danlib_font_80', self:GetSize(80))
    self:CreateFont('danlib_font_82', self:GetSize(82))
    self:CreateFont('danlib_font_84', self:GetSize(84))
    self:CreateFont('danlib_font_86', self:GetSize(86))
    self:CreateFont('danlib_font_88', self:GetSize(88))
    self:CreateFont('danlib_font_90', self:GetSize(90))
    self:CreateFont('danlib_font_92', self:GetSize(92))
    self:CreateFont('danlib_font_94', self:GetSize(94))
    self:CreateFont('danlib_font_96', self:GetSize(96))
    self:CreateFont('danlib_font_98', self:GetSize(98))
    self:CreateFont('danlib_font_100', self:GetSize(100))
end
base:LoadedFonts()


local needsFontUpdate = true
local function ScreenSizeChanged(oldWidth, oldHeight, newWidth, newHeight)
    SW, SH = ScrW() / 1920, ScrH() / 1080

    local newRatio = math.min(SH, SW)
    if (newRatio ~= Ratio) then
        Ratio = newRatio
        needsFontUpdate = true
    end
end
dHook:Add('OnScreenSizeChanged', 'DanLib.ScreenSizeChanged', ScreenSizeChanged)

-- Call base:LoadedFonts() only if necessary
dHook:Add('PostRender', 'DanLib.UpdateFonts', function()
    if needsFontUpdate then
        base:LoadedFonts()
        needsFontUpdate = false
        dHook:ProtectedRun('DanLib.PostScreenSizeChanged')
    end
end)
