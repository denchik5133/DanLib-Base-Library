local PANEL = {}

function PANEL:Init()    
    self:SetSize(64, 64)
    self:SetIcon('grenade_helicopter')

    self.Alpha = 100
end

function PANEL:SetIcon(str)
    self.Icon = Material('entities/'..str..'.png', 'smooth noclamp')
end

function PANEL:Paint(w, h)

    surface.SetDrawColor(LIB.Config.Theme.Scroll)
    draw.NoTexture()
    draw.Circle( w * .5, h * .5, w * .5 + 2, 6 )

    surface.SetMaterial(self.Icon)
    surface.SetDrawColor(255, 255, 255, 255)
    draw.Circle( w * .5, h * .5, w * .5, 6 )
end

vgui.Register('LIB.EntityIcon', PANEL, 'EditablePanel')