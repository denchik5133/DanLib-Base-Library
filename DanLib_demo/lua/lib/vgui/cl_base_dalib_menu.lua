local menuMat = Material('mvp/menu.png', 'smooth mips')
local blur = Material('pp/blurscreen')
local CheckProducts = CheckProducts or {}

function DanLib.AddonKaydi(name, requirements)
    CheckProducts[name] = requirements

    return true
end

net.Receive('danlib_menu_base', function(pPlayer)
    DanLib:RequestOptions()
    DanLib:RequestPunishments()
    DanLib:RequestPresets()
    --DanLib:RequestOwnWarnings()

    local cButton = 1
    local sizeButton = 35
    local navOptions = {}
    navOptions[1] = {name = 'Addition', icon = DanLib.Config.Materials.Addition , ButtonDistance = 2}
    navOptions[2] = {name = 'Modules', icon = DanLib.Config.Materials.Modules , ButtonDistance = 2}
    navOptions[3] = {name = 'Settings', icon = DanLib.Config.Materials.BaseSettings , ButtonDistance = 560}
    navOptions[4] = {name = 'About the author', icon = DanLib.Config.Materials.AboutAuthor , ButtonDistance = 2}


    if IsValid(frame) then frame:Remove() end

    local frame = vgui.Create('DanLibUI.Frame', frame)
    frame:SetTitle('The DanLib Base Library')
    frame:SetSize(ScrW() * .6, ScrW() * .4)
    frame:MakePopup() 
    frame:Center()
    frame:Show() 
    frame:ShowSettingsButton(false)

    local sideblock = TDLib('EditablePanel', frame)
        :ClearPaint()
        :Background(Color(49, 49, 49))
        :Stick(LEFT)

    sideblock:SetWide(32)
    sideblock.opened = false

    local scroll = vgui.Create('DanLibUI.ScrollPanel', sideblock)
    scroll:Dock(FILL)

    local vbar = scroll:GetVBar()

    vbar:SetWide(8)
    vbar:SetHideButtons(true)
    vbar:DockMargin(2, 0, 0, 0)
    function vbar:Paint(w, h)
        draw.RoundedBox(5, 0, 0, w, h, Color(51, 51, 51))
    end
    function vbar.btnGrip:Paint(w, h)
        draw.RoundedBox(5, 0, 0, w, h, (self:IsHovered() or self.Depressed) and Color(75, 75, 75) or Color(65, 65, 65))
    end


    local MenuToggle = vgui.Create('DButton')
    MenuToggle:SetTall(30)
    MenuToggle:TDLib()
        :Stick(TOP)
        :ClearPaint()
        :FadeHover()
        :Text('', 'font_sans_21', c'Text')
        :On('DoClick', function()
            if sideblock.opened then
                MenuToggle:CloseMenu()    
                return
            end

            MenuToggle:OpenMenu()
        end)
        :On('Paint', function(s, w, h)
            surface.SetMaterial(DanLib.Config.Materials.MenuToggle)
            surface.SetDrawColor(color_white)
            surface.DrawTexturedRect(32 * .5 - 12, h * .5 - 12, 24, 24)

            draw.SimpleText('Close', 'font_sans_21', 32, h * .5, c'Text', TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end)

    scroll:AddItem(MenuToggle)

    function MenuToggle:OpenMenu()
        sideblock:SizeTo(frame:GetWide() * .2, sideblock:GetTall(), .3, 0)
        
        frame.blur = vgui.Create('DPanel', frame)
        frame.blur:Dock(FILL)
        frame.blur:SetAlpha(0)
        frame.blur:AlphaTo(255, .3)

        function frame.blur:Paint(w, h)
            local x, y = self:LocalToScreen(0, 0)
            local scrW, scrH = ScrW(), ScrH()

            surface.SetDrawColor(Color(0, 0, 0, 150))
            surface.DrawRect(0, 0, w, h)

            surface.SetDrawColor(color_white)
            surface.SetMaterial(blur)

            for i = 1, 3 do
                blur:SetFloat('$blur', (i / 3) * 2)
                blur:Recompute()

                render.UpdateScreenEffectTexture()
                surface.DrawTexturedRect(x * -1, y * -1, scrW, scrH)
            end
        end

        sideblock.opened = true
    end

    function MenuToggle:CloseMenu()
        sideblock:SizeTo(vbar.Enabled and 40 or 32, sideblock:GetTall(), .3, 0, nil, function()
            sideblock.opened = false
        end)

        if IsValid(frame.blur) then
            frame.blur:AlphaTo(0, .3, nil, function(_, self)
                frame.blur:Remove()
            end)
        end
    end

    local page = TDLib('DPanel', frame)
        :ClearPaint()
        :Stick(FILL)

    local backgroundColor = Color(58, 58, 58)
    local pages = {}
    pages[1] = function()
        page:Clear()

        local disclaimer = TDLib('DPanel', page)
            :ClearPaint()
            --:Background(Color(49, 49, 49))
            :Stick(TOP, 5)
            :Text('Information about available add-ons ('..(table.maxn(CheckProducts) or 'N/A')..')', 'font_sans_25', COLOR_WHITE)

        local scroll = vgui.Create('DanLibUI.ScrollPanel', page)
        scroll:Dock(FILL)

        local Seq = table.IsSequential(CheckProducts)
        local Sort = Seq and ipairs or pairs

        for k, v in Sort(CheckProducts) do
            local valueInput = TDLib('DanLibUI.Combobox', page)
                :ClearPaint()
                :Background(Color(55, 55, 55))
                :Stick(TOP, 5)

            valueInput:SetTall(24)
            valueInput.validatorPassed = true
            valueInput:SetValue(k or '')

            for key, niceName in pairs(CheckProducts) do
                valueInput:AddChoice(niceName, key, key == curValue)
            end
        end

        --[[for k, v in pairs(CheckProducts) do
            for p, g in ipairs(v) do
                local valueInput = vgui.Create('DanLibUI.Combobox', page)

                valueInput:SetWide(250 - 24)
                valueInput:SetPos(0, 12)
                valueInput.validatorPassed = true

                valueInput:SetValue(k or '')

                for key, niceName in pairs(CheckProducts) do
                    valueInput:AddChoice(niceName, key, key == curValue)
                end
            end
        end]]


        --[[for k, v in pairs(CheckProducts) do
            for p, g in ipairs(v) do
                local valueInput = TDLib('DPanel', page)
                    :ClearPaint()
                    :Background(Color(49, 49, 49))
                    :Text('', 'font_sans_21', color_white)
                    :Stick(TOP, 5)
                    :On('Paint', function(s, w, h)
                        surface.SetMaterial(DanLib.Config.Materials.NewAdditions)
                        surface.SetDrawColor(Color(0, 255, 0)) -- LIB.Config.Theme.Accent
                        surface.DrawTexturedRect(10, 8, 64, 64)

                        draw.SimpleText(k, 'font_sans_21', 80, 15, Color(255, 140, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                        draw.SimpleText(g.Description, 'font_sans_18', 80, 30, c'Text', TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                        draw.SimpleText('Autor: '..g.Autor, 'font_sans_21', 80, 50, c'Text', TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                        draw.SimpleText('Version: '..g.Version, 'font_sans_21', 80, 65, c'Green', TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                        --draw.SimpleText(p, 'font_sans_21', 300, 65, c'Text', TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    end)

                valueInput:SetTall(80)

                local gCheck = vgui.Create('DButton', valueInput)
                gCheck:TDLib()
                    :ClearPaint()
                    :Background(Color(58, 58, 58))
                    :FadeHover()
                    :CircleClick(DanLib.Config.Theme.AlphaWhite)
                    :Text('Open Settings', 'font_sans_18', c'Text')
                    :On('DoClick', function()
                
                    end)
                gCheck:SetSize(150, 30)
                gCheck:SetPos(ScrW()/2 - 10, 20)
            end
        end]]

        local gCheck = vgui.Create('DButton', page)
        gCheck:SetTall(35)
        gCheck:TDLib()
            :Stick(TOP, 5)
            :ClearPaint()
            :Background(Color(49, 49, 49))
            :FadeHover()
            :CircleClick(DanLib.Config.Theme.AlphaWhite)
            :Text('Check for add-ons', 'font_sans_21', c'Text')
            :On('DoClick', function()
                timer.Simple(1.0, function()
                    --netstream.Start(pPlayer, 'DanLib::ScreenNotify', 'Updated successfully!', 'Confirm', 6)
                    DanLib:ScreenNotify(nil, QUERY_MAT_SUCCESS, DanLib.Config.Theme.Green, 'Updated successfully!')
                end)
            end)

    end
    pages[1]()

    -- 
    pages[2] = function()
        page:Clear()

        local disclaimer = TDLib('DPanel', page)
            :ClearPaint()
            --:Background(Color(49, 49, 49))
            :Stick(TOP, 5)
            --:Text(DanLib.Loc:GetTranslation('modulesmenu'), 'font_sans_25', COLOR_WHITE)
            :On('Paint', function(s, w, h)
                draw.SimpleText(DanLib.Loc:GetTranslation('modulesmenu'), 'font_sans_25', w/3 + 40, 12, c'Text', TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end)

        local scroll = vgui.Create('DanLibUI.ScrollPanel', page)
        scroll:Dock(FILL)
    end

    --
    pages[3] = function()
        page:Clear()

        local InfPanel = TDLib('DPanel', page)
            :ClearPaint()
            :Stick(TOP)
            :On('Paint', function(s, w, h)
                draw.SimpleText('Basic configuration', 'font_sans_25', w/3 + 40, 12, c'Text', TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end)

        local disclaimer = TDLib('DanLibUI.Settings', page)
        disclaimer:Dock(FILL)
        MenuToggle:CloseMenu()
    end

    pages[4] = function()
        page:Clear()
        local versionsCache = DanLib.Config.versionsCache or {}

        local disclaimer = TDLib('DPanel', page)
            :ClearPaint()
            --:Background(Color(49, 49, 49))
            :Stick(TOP, 5)
            :Text('Information about the author and available updates', 'font_sans_25', COLOR_WHITE)

        local scroll = vgui.Create('DanLibUI.ScrollPanel', page)
        scroll:Dock(FILL)

        local infpanelaut = TDLib('DPanel', page)
            :ClearPaint()
            :Background(Color(49, 49, 49))
            :Stick(TOP, 5)
            :Text('', 'font_sans_25', COLOR_WHITE)
            :On('Paint', function(s, w, h)
                draw.SimpleText('Name of the basis: '..DanLib.NameBasis, 'font_sans_21', 80, h * .2, c'Text', TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText('Autor: '..DanLib.Autor, 'font_sans_21', 80, h * .5, c'Text', TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

                if DanLib.Config.versionsCache == nil then
                    draw.SimpleText('Checking for updates...', 'font_sans_18', 80, h * .8, Color(255, 215, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    return
                end

                local isUpToDate = version == versionsCache[DanLib.Version]
                local color = Color(0, 255, 0)
                local text = 'No information available!'

                if versionsCache[DanLib.Version] then
                    color = isUpToDate and c'Green' or c'Yellow'
                    text = isUpToDate and 'Latest version!' or 'An update is needed!' .. Format('New version - %s', versionsCache[id])
                end

                draw.SimpleText(text, 'font_sans_18', 80, h * .8, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end)
        infpanelaut:SetTall(80)

        local headerAvatar = TDLib('DPanel', infpanelaut)
            :ClearPaint()
            :CircleAvatar()
            :Stick(LEFT, 5)
        headerAvatar:SetSteamID( '76561198405398290', 128 )

        local p = TDLib('DPanel', page)
        p:SetTall(80)
        p:TDLib()
            :ClearPaint()
            :Background(Color(49, 49, 49))
            :Stick(TOP, 5)

        local gCheck = vgui.Create('DButton', page)
        gCheck:SetTall(35)
        gCheck:TDLib()
            :Stick(TOP, 5)
            :ClearPaint()
            :FadeHover()
            :Background(Color(49, 49, 49))
            :CircleClick(DanLib.Config.Theme.AlphaWhite)
            :Text('Check for updates', 'font_sans_21', c'Text')
            :On('DoClick', function(pPlayer, pActor)
                DanLib.Config.versionsCache = nil
                http.Fetch("https://raw.githubusercontent.com/denchik5133/Basic-Script-Library/main/version.txt", function(actualVer)
                    DanLib.Config.versionsCache = util.JSONToTable(actualVer)
                    if actualVer ~= DanLib.Version then
                        print('A new version of the Base DanLib addon has been released! Current version '..DanLib.Version)
                        --DanLib:ScreenNotify(nil, QUERY_MAT_WARNING, c'Yellow', string.format('A new version of the Base DanLib addon has been released! Current version "%s"', LIB.Version))
                    end
                end)
            end)

        local gDiscord = vgui.Create('DImageButton', p)
        gDiscord:TDLib()
            :Stick(LEFT, 8)
            :ClearPaint()
            :On('DoClick', function()
                gui.OpenURL(l'Discord')
            end)
        gDiscord:SetImage('links/discord.png')

        local gSteam = vgui.Create('DImageButton', p)
        gSteam:TDLib()
            :Stick(LEFT, 8)
            :ClearPaint()
            :On('DoClick', function()
                gui.OpenURL(l'SteamProfile')
            end)
        gSteam:SetImage('links/steam.png')

        local gVk = vgui.Create('DImageButton', p)
        gVk:TDLib()
            :Stick(LEFT, 8)
            :ClearPaint()
            :On('DoClick', function()
                gui.OpenURL(l'VK')
            end)
        gVk:SetImage('links/vk.png')

        local gGitHub = vgui.Create('DImageButton', p)
        gGitHub:TDLib()
            :Stick(LEFT, 8)
            :ClearPaint()
            :On('DoClick', function()
                gui.OpenURL(l'GitHub')
            end)
        gGitHub:SetImage('links/github.png')

        local gYoutube = vgui.Create('DImageButton', p)
        gYoutube:TDLib()
            :Stick(LEFT, 8)
            :ClearPaint()
            :On('DoClick', function()
                gui.OpenURL(l'YouTube')
            end)
        gYoutube:SetImage('links/youtube.png')
    end

    --Навигационная панель
    for k, v in pairs(navOptions) do
        local Button = TDLib('DButton')
        Button:SetTall(sizeButton)
        Button:TDLib()
            :Stick(TOP)
            :ClearPaint()
            :FadeHover()
            :Text('', 'font_sans_21', c'Text')
            :On('DoClick', function()
                if v.click then v.click(pnl) end

                cButton = k
                pages[k]()
            end)
            :On('Paint', function(s, w, h)
                draw.SimpleText(v.name, 'font_sans_21', 32, h * .5, c'Text', TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

                surface.SetMaterial(v.icon)
                surface.SetDrawColor(c'Text')
                surface.DrawTexturedRect(32 * .5 - 12, h * .5 - 12, 24, 24)

                if(k == cButton) then
                
                end
            end)
            :CircleClick(DanLib.Config.Theme.AlphaWhite)

        Button:DockMargin(0, v.ButtonDistance, 0, 0)
        scroll:AddItem(Button)
    end


    return frame
end)

DanLib.Colors = DanLib.Colors or {
    COLOR_SELECTED = Color( 255, 0, 200, 160 ),
    COLOR_BUTTON_SELECTED = Color( 180, 40, 40, 40 ),
    COLOR_BUTTON = Color( 80, 80, 80, 0 ),
    COLOR_BUTTON_2 = Color( 180, 80, 80, 120 ),
    COLOR_BUTTON_2_HOVERED = Color( 180, 80, 80, 180 ),
    COLOR_BUTTON_HOVERED = Color( 80, 80, 80, 30 ),
    COLOR_BUTTON_DISABLED = Color( 120, 120, 120, 40 ),
    COLOR_BUTTON_TEXT = Color( 20, 20, 20, 180 ),
    COLOR_LABEL_TEXT = Color( 180, 80, 160, 255 ),
    COLOR_LABEL_VALUE_TEXT = Color( 220, 80, 220, 220 ),
    COLOR_THEME_PRIMARY = Color( 255, 230, 255, 250 ),
    COLOR_THEME_SECONDARY = Color( 255, 210, 255, 255 ),
    COLOR_THEME_PRIMARY_SHADOW = Color( 235, 216, 234, 250 ),
    COLOR_RED_BUTTON = Color(255,80,80,200),
    COLOR_RED_BUTTON_HOVERED = Color(255,80,80,255),
}

function DanLib:RequestOptions()
    net.Start( "danlib_networkoptions" )
    net.WriteString( "update" )
    net.SendToServer()
end

function DanLib:RequestPunishments()
    net.Start( "danlib_networkpunishments" )
    net.WriteString( "update" )
    net.SendToServer()
end

function DanLib:RequestPresets()
    net.Start( "danlib_networkpresets" )
    net.WriteString( "update" )
    net.SendToServer()
end

function DanLib:SendOptionUpdate( option, value )
    net.Start( "danlib_networkoptions" )
    net.WriteString( "write" )
    
    if DanLib.Options[ option ].type == "boolean" then
        net.WriteString( option )
        net.WriteBool( value )
    elseif DanLib.Options[ option ].type == "integer" then
        net.WriteString( option )
        net.WriteInt( value, 32 )
    elseif DanLib.Options[ option ].type == "string" then
        net.WriteString( option )
        net.WriteString( value )
    end
    
    net.SendToServer()
end

net.Receive( "danlib_networkoptions", function()
    local options = net.ReadTable()
    DanLib.Options = options
    
    if table.Count( DanLib.Options ) > 0 then
        DanLib:RefreshSettings()
    end
end )

net.Receive( "danlib_networkpunishments", function()
    local punishments = net.ReadTable()
    DanLib.Punishments = punishments
    DanLib:RefreshPunishments()
end )


net.Receive( "danlib_networkpresets", function()
    local presets = net.ReadTable()
    DanLib.Presets = presets
    DanLib:RefreshPresets()
end )