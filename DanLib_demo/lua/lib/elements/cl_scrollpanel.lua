local PANEL = {}

function PANEL:Init()    
    self.VBar:SetWide(12)
    self.VBar:SetHideButtons(true)

    self.VBar.Paint = function(pnl, w, h)
        draw.RoundedBox(2, 0, 0, w, h, ColorAlpha(DanLib.Config.Theme.DarkScroll, 150))
    end

    self.VBar.btnGrip.Paint = function(pnl, w, h)
        --draw.RoundedBox(8, 0, 0, w, h, DanLib.Config.Theme.Scroll)
        draw.RoundedBox( 8, w/2 - w/2, 0, w/2, h, DanLib.Config.Theme.Scroll )
    end

    function self.VBar:Paint( w, h )
        --draw.RoundedBox(8, 0, 0, w, h, ColorAlpha(DanLib.Config.Theme.DarkScroll, 150))
    end

    function self.VBar:Paint( w, h )
    end
end
 
vgui.Register('DanLibUI.ScrollPanel', PANEL, 'DScrollPanel')

