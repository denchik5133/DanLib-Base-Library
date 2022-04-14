
local PANEL = {}

function PANEL:Init()
    self:TDLib()
        :ClearPaint()
        :Background(Color(40, 40, 40)) --Color(55, 55, 55, 150)
        :FadeHover(Color(255, 255, 255, 50))
end

function PANEL:AddOption( strText, funcFunction )

    local pnl = vgui.Create( 'Dan.MenuOption', self )
    pnl:SetMenu( self )
    pnl:SetText( strText )
    if ( funcFunction ) then pnl.DoClick = funcFunction end

    self:AddPanel( pnl )

    return pnl

end

function PANEL:AddSubMenu( strText, funcFunction )

    local pnl = vgui.Create( 'Dan.MenuOption', self )
    local SubMenu = pnl:AddSubMenu( strText, funcFunction )

    pnl:SetText( strText )
    if ( funcFunction ) then pnl.DoClick = funcFunction end

    self:AddPanel( pnl )

    return SubMenu, pnl

end

vgui.Register('Dan.Menu', PANEL, 'DMenu')
