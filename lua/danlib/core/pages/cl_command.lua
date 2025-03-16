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
local utils = DanLib.Utils
local Table = DanLib.Table


local COMMAND = base.CreatePage(base:L('#chat.commands'))
COMMAND:SetOrder(3)
COMMAND:SetIcon('5Rr8I1N')

function COMMAND:Create(container)
	local PANEL = DanLib.CustomUtils.Create(container)
	PANEL:Pin()
	PANEL:ApplyEvent('FillPanel', function(self)
		local margin, wide = 30, 200
		local IconMargin = 12
		
	    local top = DanLib.CustomUtils.Create(self)
	    top:PinMargin(TOP, nil, nil, nil, 12)
	    top:SetTall(46)

	    local icon = 24
	    local iconMargin = 14
	    top:ApplyBackground(base:Theme('secondary_dark'), 6)
	    top:ApplyEvent(nil, function(sl, w, h)
	        utils:DrawIcon(iconMargin, h * .5 - icon * 0.5, icon, icon, '5Rr8I1N', base:Theme('mat', 150))
	        utils:DrawDualText(iconMargin * 3.5, h / 2 - 2, base:L('#chat.commands'), 'danlib_font_20', base:Theme('decor'), base:L('#chat.commands.description'), 'danlib_font_18', base:Theme('text'), TEXT_ALIGN_LEFT, nil, w - wide)
	    end)

		local dockMargin = (top:GetTall() - margin) * 0.5 
		self.textEntry = base.CreateTextEntry(top, DanLib.Config.Materials['Search'])
		self.textEntry:Pin(RIGHT, dockMargin)
		self.textEntry:SetWide(wide)
		self.textEntry:SetBackText(base:L('#search'))
		self.textEntry.OnChange = function() self:Refresh() end

		self.Scroll = DanLib.CustomUtils.Create(self, 'DanLib.UI.Scroll')
		self.Scroll:Pin(FILL)
		self:Refresh()
	end)
	PANEL:ApplyEvent('Refresh', function(self)
		self.Scroll:Clear()

	    for i, c in pairs(DanLib.Temp.Command) do
	        local cmd = DanLib.Temp.Command[i]
	        if (self.textEntry:GetValue() != '') and not string.find(string.lower(cmd.description), string.lower(self.textEntry:GetValue()), _, true) then continue end

	        -- Access verification
	        local pPlayer = LocalPlayer()
	        local steamID = pPlayer:SteamID()
            local steamID64 = pPlayer:SteamID64()
            local group = pPlayer:GetUserGroup()
            local rank = pPlayer:get_danlib_rank()

            local hasAccess = false
            if (type(cmd.access) == 'table') then
                hasAccess = Table:HasValue(cmd.access, steamID64) or Table:HasValue(cmd.access, steamID) or Table:HasValue(cmd.access, group) or Table:HasValue(cmd.access, rank)
            elseif (type(cmd.access) == 'string') then
                hasAccess = cmd.access == steamID64 or cmd.access == group
            end

	        -- Show the command if access is found or if access is not specified
        	if (hasAccess or not cmd.access) then
		        local answer = DanLib.CustomUtils.Create(self.Scroll)
		        answer:PinMargin(TOP, 4, nil, 2, 8)
		        answer:SetTall(50)
	    		answer:ApplyAttenuation(0.2)
		        answer:ApplyEvent(nil, function(sl, w, h)
		            utils:DrawRoundedBox(0, 0, w, h, base:Theme('secondary_dark'))
		            local text_w = utils:TextSize(i, 'danlib_font_20').w
		            draw.RoundedBox(6, 9, h * 0.5 - 18, text_w + 10, 17, Color(39, 174, 96))
		            draw.SimpleText(i, 'danlib_font_20', 14, h * 0.5 - 22, base:Theme('title'), TEXT_ALIGN_BOTTOM)
		            utils:DrawParseText(cmd.description, 'danlib_font_18', 10, h * 0.5, base:Theme('text', 180), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		        end)

		        local tall = 46
		        local margin = (answer:GetTall() - tall) * 0.5

		        local Copy = base:CreateButton(answer)
	            Copy:PinMargin(RIGHT, nil, margin + 8, 15, margin + 8)
	            Copy:SetWide(base:Scale(45))
	            Copy:icon('C1bpjkc')
	            Copy:SetHoverTum(true)
	            Copy:ApplyTooltip(base:L('#copy'), nil, nil, RIGHT)
	    		Copy:SetBackgroundColor(Color(0, 0, 0, 0))
	    		Copy:ApplyEvent('DoClick', function()
	            	base:ClipboardText(i)
	            	base:TutorialSequence(3, 1)
	            end)
	        end
    	end
	end)
	PANEL:FillPanel()
	base:TutorialSequence(2, 1)
end
