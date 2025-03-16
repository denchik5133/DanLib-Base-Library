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
 


function DanLib.Func.CreateSidebar(parent)
	local PANEL = DanLib.CustomUtils.Create(parent)

	PANEL:Pin(LEFT)
	PANEL:SetWide(50)

	PANEL.selectedBtn = nil
	PANEL.selectedPanel = nil

	PANEL.tabCount = 0
	PANEL.fadeSpeed = 0.1

	PANEL.loadedPanels = {}
	PANEL.pags = {}

	PANEL.accentColor = nil

	PANEL.SetAccentColor = function(self, color)
		self.accentColor = color
	end

	PANEL.SetFadeSpeed = function(self, speed)
		self.fadeSpeed = speed
	end

	PANEL.SetBackground = function(self, color)
		self.background = color
	end 

	PANEL.SwitchTab = function(self, tab, panel)
		if (!self.loadedPanels[panel]) then
			local pStr = panel

			panel = self:GetParent():Add(panel)
			panel:Stick(FILL, 8)
			panel:FillPanel()

			self.loadedPanels[pStr] = panel
		else
			panel = self.loadedPanels[panel]
		end

		self.selectedBtn = tab

		if (self.selectedPanel == panel) then 
			return 
		end

		if (self.tabCount == 0) then
			panel:SetVisible(true)
		else
			local prevPanel = self.selectedPanel

			if (IsValid(prevPanel)) then
				prevPanel:ApplyFadeOutPanel(self.fadeSpeed, function()
					panel:ApplyFadeInPanel(self.fadeSpeed)
				end)
			end
		end

		self.selectedPanel = panel
	end

	PANEL.AddPage = function(self, text, icon, panel, sAlign)
		local Button = DanLib.Func:CreateButton(self)
		Button:Pin(sAlign and BOTTOM or TOP)
		Button:SetTall(44)

		if (self.tabCount == 0) then
			self:SwitchTab(Button, panel)
		end

		local Margin = 2
		Button.Enabled = true
		Button:ApplyTooltip(text, nil, nil, LEFT)
		Button.s = 24
		Button:ApplyEvent(nil, function(sl, w, h)
			if (sl:GetParent().selectedBtn == sl) then
				DanLib.Utils:DrawRect(0, 0, w, h, sl:GetParent().accentColor or DanLib.Func:Theme('button_hovered', 150))
				DanLib.Utils:DrawRect(0, 0, Margin, h, sl:GetParent().accentColor or DanLib.Func:Theme('decor2'))
			end

			local icons = icon
			if icons then
				if isstring(icons) then
					DanLib.Utils:DrawIcon(w / 2 + Margin / 2 - sl.s / 2, h / 2 - sl.s / 2, sl.s, sl.s, icons, DanLib.Func:Theme('mat', 150))
				else
					DanLib.Utils:DrawMaterial(w / 2 + Margin / 2 - sl.s / 2, h / 2 - sl.s / 2, sl.s, sl.s, DanLib.Func:Theme('mat', 150), icons)
				end
			end
		end)

		Button.SetActive = function(sl, bool)
			sl:SetEnabled(bool)
			sl:SetCursor(bool and 'none' or 'no')

			sl.Enabled = false
		end

		Button:doClick(function()
			self:SwitchTab(Button, panel)
		end)

		self.tabCount = self.tabCount + 1
		self.pags[Button] = panel

		return Button
	end

	PANEL.AddCloseButton = function(self, text, icon, func)
		text = text or DanLib.Func:L('#close')
		icon = icon or DanLib.Config.Materials['Close']

		local Button = DanLib.Func:CreateButton(self)
		Button:Pin(BOTTOM)
		Button:SetTall(40)
		Button:ApplyTooltip(text, nil, nil, LEFT)
		Button.s = 24
		Button:ApplyEvent(nil, function(sl, w, h)
			local icons = icon
			if icons then
				DanLib.Utils:DrawIconOrMaterial(w / 2 - sl.s / 2, h / 2 - sl.s / 2, sl.s, icons, DanLib.Func:Theme('mat', 150))
			end
		end)

		if (func) then
			Button:doClick(func)
		end

		return Button
	end

	PANEL.Paint = function(self, w, h)
		DanLib.Utils:DrawRect(0, 0, w, h, self.background or DanLib.Func:Theme('secondary_dark'))
	end
	PANEL:ApplyShadow(10, false)

	return PANEL
end