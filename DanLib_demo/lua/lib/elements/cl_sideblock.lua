local PANEL = {}

function PANEL:Init()
    self:Dock(LEFT)
    self:DockMargin(0, 0, 5, 0)
    self:DockPadding(2, 2, 2, 2)

    self:SetWide(250)
end

function PANEL:Paint(w, h)
    draw.RoundedBoxEx(3, 0, 0, w, h, LIB.Config.Theme.Primary, false, false, true, false)
end

vgui.Register('LIB.Sideblock', PANEL, 'EditablePanel')
