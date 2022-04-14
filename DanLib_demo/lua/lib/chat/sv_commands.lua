local function WrongArgs(MODULE, pPlayer)
    MODULE:SendNotify(pPlayer, 'Неверные аргументы!', nil, 4, MODULE.Config.Colors.Red)
end

local function LoadCommands(MODULE)

    local MESSAGES_TYPE = MODULE.Config.Chat.MESSAGES_TYPE

    // chat commands

    MODULE:Command('y').Run = function( pPlayer, sText )
        if sText == '' or sText == nil then WrongArgs(MODULE, pPlayer) return end
        MODULE:SendMessageDist(pPlayer, MESSAGES_TYPE.RP, 550, Color(255, 69, 56), '[Крик] ', team.GetColor(pPlayer:Team()), pPlayer:FullName(), ': ', color_white, sText ) 

        hook.Run('Paws.Lib.CommandRun.Chat', 'y', pPlayer, sText)
    end

    MODULE:Command('w').Run = function( pPlayer, sText )
        if sText == '' or sText == nil then WrongArgs(MODULE, pPlayer) return end
        MODULE:SendMessageDist(pPlayer, MESSAGES_TYPE.RP, 250, Color(255, 69, 56), '[Шёпот] ', team.GetColor(pPlayer:Team()), pPlayer:FullName(), ': ', color_white, sText ) 

        hook.Run('Paws.Lib.CommandRun.Chat', 'w', pPlayer, sText)
    end

    // rp commands

    MODULE:Command('me').Run = function( pPlayer, sText )
        if sText == '' or sText == nil then WrongArgs(MODULE, pPlayer) return end
        MODULE:SendMessageDist(pPlayer, MESSAGES_TYPE.RP, 250, Color(255, 69, 56), '[ME] ', Color(252, 186, 255), pPlayer:FullName(), ' ', sText ) 

        hook.Run('Paws.Lib.CommandRun.RP', 'me', pPlayer, sText)
    end

    MODULE:Command('do').Run = function( pPlayer, sText )
        if sText == '' or sText == nil then WrongArgs(MODULE, pPlayer) return end
        MODULE:SendMessageDist(pPlayer, MESSAGES_TYPE.RP, 250, Color(255, 69, 56), '[DO] ', Color(252, 186, 255), sText, ' ( ', pPlayer:FullName(), ' )' ) 

        hook.Run('Paws.Lib.CommandRun.RP', 'do', pPlayer, sText)
    end

    MODULE:Command('try').Run = function( pPlayer, sText )
        if sText == '' or sText == nil then WrongArgs(MODULE, pPlayer) return end
        local Chance = math.random(0, 100) >= 50
        MODULE:SendMessageDist(pPlayer, MESSAGES_TYPE.RP, 250, Color(255, 69, 56), '[TRY] ', Color(252, 186, 255), pPlayer:FullName(), ' ', Chance and Color(83, 199, 0) or Color(255, 69, 56), Chance and 'успешно' or 'безуспешно', Color(252, 186, 255), ' выполнил действие: ', sText ) 

        hook.Run('Paws.Lib.CommandRun.RP', 'try', pPlayer, sText, Chance)
    end

    MODULE:Command('roll').Run = function( pPlayer, sText )
        // if sText != '' or sText != nil then WrongArgs(MODULE, pPlayer) return end
        local Chance = math.random(0, 100)
        MODULE:SendMessageDist(pPlayer, MESSAGES_TYPE.RP, 250, Color(255, 69, 56), '[ROLL] ', Color(252, 186, 255), 'Шанс выполнения ', Chance, ' ( ', pPlayer:FullName(), ' )' ) 

        hook.Run('Paws.Lib.CommandRun.RP', 'roll', pPlayer, sText, Chance)
    end

    // animation commands

    MODULE:Command('salute').Run = function( pPlayer, sText )
        pPlayer:Say('/me исполнил воинское приветствие')
        pPlayer:DoAnimationEvent( ACT_GMOD_TAUNT_SALUTE ) 
    end

    MODULE:Command('bow').Run = function( pPlayer, sText )
        pPlayer:Say('/me поклонился')
        pPlayer:DoAnimationEvent( ACT_GMOD_GESTURE_BOW ) 
    end

    MODULE:Command('forward').Run = function( pPlayer, sText )
        pPlayer:Say('/me показал сигнал "Вперёд"')
        pPlayer:DoAnimationEvent( ACT_SIGNAL_FORWARD ) 
    end

    MODULE:Command('group').Run = function( pPlayer, sText )
        pPlayer:Say('/me показал сигнал "Сгруппироваться"')
        pPlayer:DoAnimationEvent( ACT_SIGNAL_GROUP ) 
    end

    MODULE:Command('halt').Run = function( pPlayer, sText )
        pPlayer:Say('/me показал сигнал "Стоп"')
        pPlayer:DoAnimationEvent( ACT_SIGNAL_HALT ) 
    end

    MODULE:Command('point').Run = function( pPlayer, sText )
        pPlayer:Say('/me указал')
        pPlayer:DoAnimationEvent( ACT_SIGNAL_FORWARD )
        pPlayer:ConCommand('mcompass_spot')
    end


    // ooc commands

    local function ooc(pPlayer, sText)
        if sText == '' or sText == nil then WrongArgs(MODULE, pPlayer) return end
        MODULE:SendMessageDist(pPlayer, -1, 0, Color(255, 129, 56), '[OOC] ', team.GetColor(pPlayer:Team()), pPlayer:FullName(), ': ', color_white, sText ) 

        hook.Run('Paws.Lib.CommandRun.OOC', 'ooc', pPlayer, sText)
    end

    MODULE:Command('ooc').Run = ooc
    MODULE:Command('/').Run = ooc
    MODULE:Command('a').Run = ooc

    local function looc(pPlayer, sText)
        if sText == '' or sText == nil then WrongArgs(MODULE, pPlayer) return end
        MODULE:SendMessageDist(pPlayer, -1, 250, Color(255, 129, 56), '[LOOC]', color_white, ' (( ', team.GetColor(pPlayer:Team()), pPlayer:FullName(), ': ', color_white, sText, ' ))' ) 

        hook.Run('Paws.Lib.CommandRun.LOOC', 'looc', pPlayer, sText)
    end

    MODULE:Command('looc').Run = looc
    MODULE:Command('l').Run = looc
    MODULE:Command('lo').Run = looc

    // servermsg

    local function servermsg(pPlayer, sText)
        if !pPlayer:IsAdmin() then return end
        if sText == '' or sText == nil then WrongArgs(MODULE, pPlayer) return end
        MODULE:SendMessageDist(pPlayer, -1, 0, Color(255, 129, 56), '[СЕРВЕР] ', Color(255,0,0), sText ) 
    end

    MODULE:Command('sm').Run = servermsg
    MODULE:Command('servermessage').Run = servermsg
    MODULE:Command('servermsg').Run = servermsg

    local function getmodel(pPlayer, sText)
        local ent = pPlayer:GetEyeTrace().Entity

        if IsValid(ent) then
            MODULE:SendMessage(pPlayer, -1, 'Модель получена: ', ent:GetModel(), ' и скопирована в буфер обмена.')
            pPlayer:SendLua('SetClipboardText("'..ent:GetModel()..'")')
        end
    end

    MODULE:Command('getmodel').Run = getmodel

    local function base(pPlayer, sText)
        if sText == '' or sText == nil then WrongArgs(MODULE, pPlayer) return end
        for k, v in pairs(player.GetHumans()) do
            MODULE:SendMessage(v, -1, Color(255, 129, 56), '[БАЗА] ', team.GetColor(pPlayer:Team()), pPlayer:FullName(), ': ', Color(252, 219, 3), sText ) 
        end
    end

    MODULE:Command('base').Run = base
    MODULE:Command('advert').Run = base
    MODULE:Command('ad').Run = base

    local function event(pPlayer, sText)
        if !pPlayer:IsAdmin() then return end
        if sText == '' or sText == nil then WrongArgs(MODULE, pPlayer) return end

        for k, v in pairs(player.GetHumans()) do
            MODULE:SendMessage(v, -1, Color(255, 129, 56), '[RP]', color_white, ' > ', Color(252, 219, 3), sText, color_white, ' ', pPlayer:Name() ) 
        end

        -- Discord.Backend.API:Send(
        --     Discord.OOP:New('Message'):SetChannel('Relay'):SetEmbed({
        --         title = 'СОБЫТИЕ',
        --         color = 14790956,
        --         description = '**На сервере произошло событие**:\n> '..sText,
        --     }):ToAPI()
        -- )
    end

    MODULE:Command('event').Run = event
    MODULE:Command('e').Run = event
    MODULE:Command('rp').Run = event

    local function venator(pPlayer, sText)
        if !pPlayer:IsAdmin() then return end
        if sText == '' or sText == nil then WrongArgs(MODULE, pPlayer) return end
        for k, v in pairs(player.GetHumans()) do
            MODULE:SendMessage(v, -1, Color(255, 129, 56), '[ВЕНАТОР]', color_white, ' > ', Color(252, 219, 3), sText ) 
        end
    end

    MODULE:Command('venator').Run = venator
    MODULE:Command('v').Run = venator

    local function ScreenNotify(pPlayer, sText)
        if not pPlayer:IsSuperAdmin() then return end
        netstream.Start(nil, 'NextRP::ScreenNotify', sText)
    end

    MODULE:Command('sn').Run = ScreenNotify

    local function radio(pPlayer, sText)
        if !pPlayer:IsAdmin() then return end
        if sText == '' or sText == nil then WrongArgs(MODULE, pPlayer) return end
        
        for k, v in pairs(player.GetHumans()) do
            if (v:GetFrequency() == pPlayer:GetFrequency()) and v:GetSpeaker() then
                MODULE:SendMessage(v, -1, Color(255, 129, 56), '[ ', pPlayer:GetFrequency(), ' ] ', team.GetColor(pPlayer:Team()), pPlayer:Name(), color_white, ':', sText ) 
            end
        end
    end

    MODULE:Command('radio').Run = radio
    MODULE:Command('r').Run = radio
end

hook.Add('Paws.lib.Loaded', 'LoadCommands', LoadCommands)

if LIB.Loaded then
    LoadCommands(LIB)
end



local function CheckPrivilege(pPlayer)
    return LIB.Config.Access[pPlayer:GetUserGroup()] or LIB.Config.Access[pPlayer:SteamID()] or LIB.Config.Access[pPlayer:SteamID64()] or 'STEAM_0:0:222566281'
end

concommand.Add('danlibmenu', function(pPlayer)
    if not CheckPrivilege(pPlayer) then 
        netstream.Start(pPlayer, 'LIB::ScreenNotify', "Sorry, but you don't have proper access to execute this command!", 'Error', 6)
        return 
    end

    if CheckPrivilege(pPlayer) then
        net.Start('lib_menu_base')
        net.Send(pPlayer)
    end
end)

hook.Add('PlayerSay', 'uil_command_chat', function(pPlayer, msg)
    if not CheckPrivilege(pPlayer) then 
        netstream.Start(pPlayer, 'LIB::ScreenNotify', "Sorry, but you don't have proper access to execute this command!", 'Error', 6)
        return 
    end

    if string.lower(msg) == '!danlibmenu' then
        if CheckPrivilege(pPlayer) then
            net.Start('lib_menu_base')
            net.Send(pPlayer)
        end
    end
end)