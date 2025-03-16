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



local math = math
local clamp = math.Clamp
local base = DanLib.Func
local utils = DanLib.Utils

function base.CreateCheckbox(parent)
	local Checkbox = DanLib.CustomUtils.Create(parent, 'DButton')
    Checkbox:SetText('')
	Checkbox:SetTall(base:Scale(30))

	function Checkbox:SetValue(val)
	    self.value = val
	    
		if self.OnChange then
			self:OnChange(val)
		end
	end

	function Checkbox:GetValue()
	    return self.value
	end

	function Checkbox:DoClick()
		self:SetValue(not self.value)
	end

	function Checkbox:DisableShadows(distance, noClip, iteration)
	    self:ApplyShadow(distance or 10, noClip or false, iteration or 5)
	    return self
	end

	function Checkbox:Paint(w, h)
        self:ApplyAlpha(0.2, 150)

        local hoverChange = self.value and 3 or -3
        self.hoverPercent = clamp((self.hoverPercent or 0) + hoverChange, 0, 100)
        local hoverPercent = self.hoverPercent / 100

        utils:DrawRect(0, 0, w, h, base:Theme('secondary', self.alpha))
        utils:DrawRect(0, 0, w, h, base:Theme('button'))
        utils:OutlinedRect(0, 0, w, h, Color(37, 56, 79))
        utils:OutlinedRect(0, 0, w, h, base:Theme('decor', hoverPercent * 100))

        local IconSize = base:Scale(24)
        local mat = self.value and DanLib.Config.Materials['Ok'] or DanLib.Config.Materials['#close']

        if self.value then
            utils:DrawIcon(w * 0.5 - IconSize * 0.5, h * 0.5 - IconSize * 0.5, IconSize, IconSize, mat, base:Theme('mat', 200))
        end
    end

	return Checkbox
end