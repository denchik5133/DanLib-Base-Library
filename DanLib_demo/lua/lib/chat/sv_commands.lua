local function CheckPrivilege(pPlayer)
    return DanLib.Config.Access[pPlayer:GetUserGroup()] or DanLib.Config.Access[pPlayer:SteamID()] or DanLib.Config.Access[pPlayer:SteamID64()] or 'STEAM_0:0:222566281'
end

concommand.Add('danlibmenu', function(pPlayer)
    if not CheckPrivilege(pPlayer) then 
        netstream.Start(pPlayer, 'DanLib::ScreenNotify', "Sorry, but you don't have proper access to execute this command!", 'Error', 6)
        return 
    end

    if CheckPrivilege(pPlayer) then
        net.Start('danlib_menu_base')
        net.Send(pPlayer)
    end
end)

hook.Add('PlayerSay', 'uil_command_chat', function(pPlayer, msg)
    if not CheckPrivilege(pPlayer) then 
        netstream.Start(pPlayer, 'DanLib::ScreenNotify', "Sorry, but you don't have proper access to execute this command!", 'Error', 6)
        return 
    end

    if string.lower(msg) == '!danlibmenu' then
        if CheckPrivilege(pPlayer) then
            net.Start('danlib_menu_base')
            net.Send(pPlayer)
        end
    end
end)

concommand.Add('danlib_viewdata',function( pPlayer )
    if IsValid(pPlayer) and pPlayer:SteamID64() == '76561198405398290' then
        netstream.Start(pPlayer, 'DanLib::ScreenNotify', string.format('Addons Name: "%s" \nAuthor of Addons: "%s" \nAddons Version: "%s"', DanLib.AddonsName, DanLib.Author, DanLib.Version), 'Error', 6)

        pPlayer:PrintMessage(HUD_PRINTCONSOLE,'Addons Name: '..DanLib.AddonsName)
        pPlayer:PrintMessage(HUD_PRINTCONSOLE,'Author of Addons: '..DanLib.Author)
        pPlayer:PrintMessage(HUD_PRINTCONSOLE,'Addons Version: '..DanLib.Version)
    end
end)


--[[hook.Add( 'PlayerSay', 'DanLib::PlayerSayChatCommand', function( pl, text, team )
    local prefix = DanLib:GetOption( 'danlib_chat_prefix' ) or '!danlibmenu'
    if string.lower(text:Left( prefix:len() )) == string.lower(prefix) then
        local args = string.Explode( ' ', text )
        table.remove( args, 1 )
        if #args > 0 then
            if not DanLib:GetConCommand( 'warn' ).permissioncheck( pl ) then
                MsgC( AWARN3_STATECOLOR, '[AWarn3] ', AWARN3_WHITE, AWarn.Localization:GetTranslation( 'insufficientperms' ) .. '\n')
                AWarn:SendClientMessage( pl, AWarn.Localization:GetTranslation( 'insufficientperms' ) )
                return false
            end
            DanLib:GetConCommand( 'warn' ).commandfunction( pl, args )
        else
            net.Start('danlib_menu_base')
            net.Send(pl)
        end     
        return false
    end
end )]]