
local PANEL = {}

function PANEL:Init()
    self:TDLib()
        :ClearPaint()
        :Background(Color(55, 55, 55, 150)) --Color(55, 55, 55, 150)
        :FadeHover(Color(255, 255, 255, 50))
        --:On('Paint', function(s, w, h)
        --    surface.SetDrawColor( color_white )
        --    surface.DrawOutlinedRect( 0, 0, w, h )
        --end)
end

function PANEL:AddOption( strText, funcFunction )

    local pnl = vgui.Create( 'DanLib.MenuOption', self )
    pnl:SetMenu( self )
    pnl:SetText( strText )
    if ( funcFunction ) then pnl.DoClick = funcFunction end

    self:AddPanel( pnl )

    return pnl

end

function PANEL:AddSubMenu( strText, funcFunction )

    local pnl = vgui.Create( 'DanLib.MenuOption', self )
    local SubMenu = pnl:AddSubMenu( strText, funcFunction )

    pnl:SetText( strText )
    if ( funcFunction ) then pnl.DoClick = funcFunction end

    self:AddPanel( pnl )

    return SubMenu, pnl

end

vgui.Register('DanLib.Menu', PANEL, 'DMenu')
