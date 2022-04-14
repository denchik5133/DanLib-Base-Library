local PANEL = {}

surface.CreateFont('LIB.Frame', {
    font = 'Open Sans',
    size = 24,
    weight = 500,
    extended = true
})

function PANEL:Init()
    self:DockPadding(0, 0, 0, 0)
    
    self.top = vgui.Create('Panel', self) 
    self.top:Dock(TOP)
    self.top:DockMargin(0, 0, 0, 0)
    self.top:DockPadding(0, 0, 0, 2)
    self.top.Paint = function(pnl, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(49, 49, 49), true, true, false, false)
    end

    self.title = vgui.Create('DLabel', self.top)
    self.title:Dock(LEFT)
    self.title:DockMargin( 10, 0, 0, 0 )
    self.title:SetFont('LIB.Frame')
    self.title:SetTextColor(color_white)

    self.closeBtn = vgui.Create('DButton', self.top)
    self.closeBtn:Dock(RIGHT)
    self.closeBtn:SetText('')
    self.closeBtn.CloseButton = Color(195, 195, 195)
    self.closeBtn.Alpha = 0
    self.closeBtn.DoClick = function(pnl)
        self:Remove()
    end
    self.closeBtn.Paint = function(pnl, w, h)
        draw.RoundedBox(0, 0, 0, w, h, ColorAlpha(LIB.Config.Theme.Red, pnl.Alpha), false, true, false, false)

        surface.SetDrawColor(pnl.CloseButton)
        surface.SetMaterial(LIB.Config.Materials.CloseButton)
        surface.DrawTexturedRect(6, 6, w - 12, h - 12)
    end
    self.closeBtn.OnCursorEntered = function(pnl)
        --pnl:Lerp('Alpha', 255)
        --pnl:LerpColor('CloseButton', Color(255, 255, 255))
    end
    self.closeBtn.OnCursorExited = function(pnl)
        --pnl:Lerp('Alpha', 0)
        --pnl:LerpColor('CloseButton', Color(195, 195, 195))
    end

    self.settingsBtn = vgui.Create('DButton', self.top)
    self.settingsBtn:Dock(RIGHT)
    self.settingsBtn:SetText('')
    self.settingsBtn.CloseButton = Color(195, 195, 195)
    self.settingsBtn.Alpha = 0
    self.settingsBtn.DoClick = function(pnl)
        
    end
    self.settingsBtn.Paint = function(pnl, w, h)
        draw.RoundedBox(0, 0, 0, w, h, ColorAlpha(LIB.Config.Theme.Accent, pnl.Alpha), false, false, false, false)

        surface.SetDrawColor(pnl.CloseButton)
        surface.SetMaterial(LIB.Config.Materials.SettingsButton)
        surface.DrawTexturedRect(6, 6, w - 12, h - 12)
    end
    self.settingsBtn.OnCursorEntered = function(pnl)
        --pnl:Lerp('Alpha', 255)
        --pnl:LerpColor('CloseButton', Color(255, 255, 255))
    end
    self.settingsBtn.OnCursorExited = function(pnl)
        --pnl:Lerp('Alpha', 0)
        --pnl:LerpColor('CloseButton', Color(195, 195, 195))
    end
end

function PANEL:SetTitle(str)
    self.title:SetText(str)
    self.title:SizeToContents()
end

function PANEL:PerformLayout(w, h)
    self.top:SetTall(30)

    self.closeBtn:SetWide(30)
    self.settingsBtn:SetWide(30)
end

function PANEL:Paint(w, h)
    draw.RoundedBox(0, 0, 0, w, h, Color(41, 41, 41))
end

function PANEL:ShowCloseButton(show)
    self.closeBtn:SetVisible(show)
end

function PANEL:SetSettingsFunc(func)
    self.settingsBtn.DoClick = func
end

function PANEL:ShowSettingsButton(show)
    self.settingsBtn:SetVisible(show)
end

vgui.Register('LIB.Frame', PANEL, 'EditablePanel')