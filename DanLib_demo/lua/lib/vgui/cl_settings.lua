local PANEL = {}

function PANEL:Init()
   self:GlobalPanel()
end

function PANEL:Paint()
end

function PANEL:GlobalPanel()
	self.scroll = vgui.Create('DanLibUI.ScrollPanel', self)
    self.scroll:Dock(FILL)
    self.dataModifiers = {}

	self.actionsButton = TDLib('DButton', self)
    	:ClearPaint()
        :Stick(BOTTOM, 5)
        :Background(Color(58, 58, 58))
        :FadeHover()
        :CircleClick(DanLib.Config.Theme.AlphaWhite)
        :Text('Save', 'font_sans_21', c'Text')
        :On('DoClick', function()

        end)
    self.actionsButton:SetTall(35)
end
vgui.Register('DanLibUI.Settings', PANEL, 'Panel')