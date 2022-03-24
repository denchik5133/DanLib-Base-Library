local List = properties.List

local function AddToggleOption( data, menu, ent, ply, tr )

	if ( !menu.ToggleSpacer ) then
		menu.ToggleSpacer = menu:AddSpacer()
		menu.ToggleSpacer:SetZPos( 500 )
	end

	local option = menu:AddOption( data.MenuLabel, function() data:Action( ent, tr ) end )
	option:SetChecked( data:Checked( ent, ply ) )
	option:SetZPos( 501 )
	return option

end

local function AddOption( data, menu, ent, ply, tr )

	if ( data.Type == "toggle" ) then return AddToggleOption( data, menu, ent, ply, tr ) end

	if ( data.PrependSpacer ) then
		menu:AddSpacer()
	end

	local option = menu:AddOption( data.MenuLabel, function() data:Action( ent, tr ) end )

	if ( data.MenuIcon ) then
		option:SetImage( data.MenuIcon )
	end

	if ( data.MenuOpen ) then
		data.MenuOpen( data, option, ent, tr )
	end

	return option

end

local function BuildPropertiesMenu(ent, tr)
    local menu = vgui.Create('DanLib.Menu')

	for k, v in SortedPairsByMemberValue( List, "Order" ) do

		if ( !v.Filter ) then continue end
		if ( !v:Filter( ent, LocalPlayer() ) ) then continue end

		local option = AddOption( v, menu, ent, LocalPlayer(), tr )

		if ( v.OnCreate ) then v:OnCreate( menu, option ) end

	end

	menu:Open()
end

local oldProperties = properties.OpenEntityMenu
function properties.OpenEntityMenu(ent, tr)
	BuildPropertiesMenu(ent, tr)
end