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
local ui = DanLib.UI
local DB, _ = DanLib.UiPanel()
local Table = DanLib.Table
local customUtils = DanLib.CustomUtils


--- Gets the current rank value.
-- @return table: rank values.
function DB:GetValues()
    return base:RetrieveUpdatedVariable('BASE', 'SQL') or DanLib.ConfigMeta.BASE:GetValue('SQL')
end


--- Fills the panel with the required interface components.
function DB:FillPanel()
    local width = ui:ClampScaleW(self, 500, 600)
    local height = ui:ClampScaleH(self, 400, 400)

    self:SetHeader('SQL')
    self:SetPopupWide(width)
    self:SetExtraHeight(height)

    self.fillPanel = customUtils.Create(self)
    self.fillPanel:Pin(FILL, 10)
    self:Refresh() -- Interface update

    self.t = customUtils.Create(self)
    self.t:Pin(BOTTOM)
    self.t:ApplyText('See the server console for details', 'danlib_font_16', nil, nil, DanLib.Config.Theme['Yellow'])
end


--- Updates the interface with the current rank values.
function DB:Refresh()
	self.fillPanel:Clear()
    local values = self:GetValues()

	local sorted = {}
    for k, v in pairs(values) do
        Table:Add(sorted, {k, k})
    end
    Table:SortByMember(sorted, 1, true)

    for k, v in ipairs(sorted) do
    	local key = v[2]
        local panel = customUtils.Create(self.fillPanel)
        panel:Pin(TOP, 5)
        panel:SetTall(50)
        panel:ApplyBackground(base:Theme('secondary_dark'))
        panel:ApplyText(key, nil, 10, nil, nil, TEXT_ALIGN_LEFT) -- string.upper(k)

        local wide, margiMoveToRight, margin = 200, 15, (panel:GetTall() - 30) * 0.5 -- indentation

        if (key == 'EnableSQL') then
        	local inputElement = base.CreateCheckbox(panel)
	        inputElement:PinMargin(RIGHT, nil, margin, margiMoveToRight, margin)
	        inputElement:SetWide(32)
	        inputElement:SetValue(values[key])
	        inputElement:DisableShadows()
	        inputElement.OnChange = function(_, value)
	        	values[key] = value
	            base:SetConfigVariable('BASE', 'SQL', values)
	        end
        elseif (key == 'DatabasePort') then
        	local inputElement = base.CreateNumberWang(panel)
	        inputElement:PinMargin(RIGHT, nil, margin, margiMoveToRight, margin)
	        inputElement:SetWide(wide)
	        inputElement:SetHighlightColor(base:Theme('secondary', 50))
	        inputElement:SetValue(values[key])
	        inputElement:DisableShadows()
	        inputElement.OnChange = function()
	        	values[key] = inputElement:GetValue()
	            base:SetConfigVariable('BASE', 'SQL', values)
	        end
	    else
	    	local inputElement = base.CreateTextEntry(panel)
	        inputElement:PinMargin(RIGHT, nil, margin, margiMoveToRight, margin)
	        inputElement:SetWide(wide)
	        inputElement:SetHighlightColor(base:Theme('secondary', 50))
	        inputElement:SetValue(values[key])
	        inputElement:DisableShadows()
	        inputElement.OnChange = function()
	        	values[key] = inputElement:GetValue()
	            base:SetConfigVariable('BASE', 'SQL', values)
	        end
        end
    end
end

DB:SetBase('DanLib.UI.PopupBasis')
DB:Register('DanLib.UI.SQL')
