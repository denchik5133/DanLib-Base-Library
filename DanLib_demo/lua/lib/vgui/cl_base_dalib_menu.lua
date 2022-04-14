local menuMat = Material('mvp/menu.png', 'smooth mips')
local blur = Material('pp/blurscreen')
local CheckProducts = CheckProducts or {}

function LIB.AddonKaydi(name, requirements)
    CheckProducts[name] = requirements

    return true
end

net.Receive('lib_menu_base', function(pPlayer)

    if not LIB.Config.versionsCache then
        http.Fetch('https://raw.githubusercontent.com/denchik5133/Basic-Script-Library/main/version.txt', function(data)
            LIB.Config.versionsCache = util.JSONToTable(data)
        end)
    end

    local cButton = 1
    local sizeButton = 35
    local navOptions = {}
    navOptions[1] = {name = 'Addition', icon = LIB.Config.Materials.Addition , ButtonDistance = 2}
    navOptions[2] = {name = 'Modules', icon = LIB.Config.Materials.Modules , ButtonDistance = 2}
    navOptions[3] = {name = 'Settings', icon = LIB.Config.Materials.BaseSettings , ButtonDistance = 560}
    navOptions[4] = {name = 'About the author', icon = LIB.Config.Materials.AboutAuthor , ButtonDistance = 2}


    if IsValid(frame) then frame:Remove() end

    local frame = vgui.Create('LIB.Frame', frame)
    frame:SetTitle('Main Danlib menu')
    frame:SetSize(ScrW() * .6, ScrW() * .4)
    frame:MakePopup() 
    frame:Center()
    frame:Show() 
    frame:ShowSettingsButton(false)

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
            :Text('Information about available add-ons', 'font_sans_25', COLOR_WHITE)

        local scroll = vgui.Create('LIB.ScrollPanel', page)
        scroll:Dock(FILL)

        for k, v in pairs(CheckProducts) do
            for p, g in ipairs(v) do
                local valueInput = TDLib('DPanel', page)
                    :ClearPaint()
                    :Background(Color(49, 49, 49))
                    :Text('', 'font_sans_21', color_white)
                    :Stick(TOP, 5)
                    :On('Paint', function(s, w, h)
                        surface.SetMaterial(LIB.Config.Materials.NewAdditions)
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
                    :CircleClick(LIB.Config.Theme.AlphaWhite)
                    :Text('Check the version', 'font_sans_18', c'Text')
                    :On('DoClick', function()
                
                    end)
                gCheck:SetSize(150, 30)
                gCheck:SetPos(ScrW()/2 - 10, 20)

                function gCheck:DoClick()
                local ix, iy = gCheck:LocalToScreen(50, self:GetTall() + 20)

                local pnlOver = vgui.Create('EditablePanel')
                pnlOver:SetSize(ScrW(), ScrH())
                pnlOver:MakePopup()
                function pnlOver:OnMousePressed()
                    self:Remove()
                end

                local pnlBack = vgui.Create('DPanel', pnlOver)
                pnlBack:SetPos(ix, iy)
                pnlBack:SetSize(ScrH() * 0.3, ScrH() * 0.3)
                function pnlBack:Paint(iW, iH)
                    --draw.RoundedBox(8, 0, 0, iW, iH, Color(255, 255, 255))
                    draw.RoundedBox(8, 1, 1, iW - 2, iH - 2, LIB.Config.Theme.Background)
                end

                end

            end
        end

        local gCheck = vgui.Create('DButton', page)
        gCheck:SetTall(35)
        gCheck:TDLib()
            :Stick(TOP, 5)
            :ClearPaint()
            :Background(Color(49, 49, 49))
            :FadeHover()
            :CircleClick(LIB.Config.Theme.AlphaWhite)
            :Text('Check for add-ons', 'font_sans_21', c'Text')
            :On('DoClick', function()
                timer.Simple(1.0, function()
                    --netstream.Start(pPlayer, 'LIB::ScreenNotify', 'Updated successfully!', 'Confirm', 6)
                    LIB:ScreenNotify(nil, QUERY_MAT_SUCCESS, LIB.Config.Theme.Green, 'Updated successfully!')
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
            :Text('Information about available modules', 'font_sans_25', COLOR_WHITE)

        local scroll = vgui.Create('LIB.ScrollPanel', page)
        scroll:Dock(FILL)
    end

    --
    pages[3] = function()
        page:Clear()

        local disclaimer = TDLib('DPanel', page)
            :ClearPaint()
            --:Background(Color(49, 49, 49))
            :Stick(TOP, 5)
            :Text('Basic configuration and features DanLib Menu', 'font_sans_25', COLOR_WHITE)

        local scroll = vgui.Create('LIB.ScrollPanel', page)
        scroll:Dock(FILL)


        local p = scroll:Add('DCollapsibleCategory')
        p:SetLabel('')
        p:SetHeight(12)
        p.Header:SetTall(30)
        p:DockMargin(6, 6, 6, 5)
        p:TDLib()
            :ClearPaint()
            :Background(Color(52, 52, 57, 255))
            :Stick(TOP)
            :On('Paint', function(s, w, h)
                surface.SetMaterial(LIB.Config.Materials.Configuration)
                surface.SetDrawColor(p:GetExpanded() and LIB.Config.Theme.Accent or Color(0, 255, 0)) -- LIB.Config.Theme.Accent
                surface.DrawTexturedRect(w/2-130, 3, 24, 24)

                draw.SimpleText('Configuration', 'font_sans_26', w/2 - 100, 15, c'Text', TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end)

        List = vgui.Create('DPanelList', p)
        List:GetSpacing()
        List:GetItems()
        List:InvalidateLayout(true)
        List:SetSpacing(15)
        p:SetContents(List)
        p.list = List

        local s = vgui.Create('DPanel', p.list)
        s:TDLib()
            :Stick(TOP)
            :ClearPaint()
            :FadeHover()
            :Background(Color(49, 49, 49))
            :On('Paint', function(s, w, h)
                surface.SetMaterial(LIB.Config.Materials.ChatCommand)
                surface.SetDrawColor(LIB.Config.Theme.Accent)
                surface.DrawTexturedRect(4, 3, 44, 44)

                draw.SimpleText('ChatCommand', 'font_sans_22', 50, 15, c'Text', TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText('Chat command to be used to open the LIB Configuration Menu', 'font_sans_18', 50, 35, c'Text', TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end)

        s:SetTall(50)
        s:DockMargin(5, 4, 5, 0)
        p.list:AddItem(s)

        local g = vgui.Create('DPanel', p.list)
        g:TDLib()
            :Stick(TOP, 5)
            :ClearPaint()
            :FadeHover()
            :Background(Color(49, 49, 49))
            :On('Paint', function(s, w, h)
                surface.SetMaterial(LIB.Config.Materials.Language)
                surface.SetDrawColor(LIB.Config.Theme.Accent)
                surface.DrawTexturedRect(5, 5, 38, 38)

                draw.SimpleText('Language', 'font_sans_22', 50, 15, c'Text', TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText('The language to be selected as the main one', 'font_sans_18', 50, 35, c'Text', TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end)

        g:SetTall(50)
        g:DockMargin(5, 4, 5, 0)
        p.list:AddItem(g)

        local cl = vgui.Create('DPanel', p.list)
        cl:TDLib()
            :Stick(TOP, 5)
            :ClearPaint()
            :FadeHover()
            :Background(Color(49, 49, 49))
            :On('Paint', function(s, w, h)
                surface.SetMaterial(LIB.Config.Materials.Interface)
                surface.SetDrawColor(LIB.Config.Theme.Accent)
                surface.DrawTexturedRect(5, 5, 38, 38)

                draw.SimpleText('Interface theme', 'font_sans_22', 50, 15, c'Text', TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText('The interface that will be used as the basis', 'font_sans_18', 50, 35, c'Text', TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end)

        cl:SetTall(50)
        cl:DockMargin(5, 4, 5, 0)
        p.list:AddItem(cl)


    end

    pages[4] = function(id, configEntry)
        page:Clear()
        local versionsCache = LIB.Config.versionsCache or {}

        local disclaimer = TDLib('DPanel', page)
            :ClearPaint()
            --:Background(Color(49, 49, 49))
            :Stick(TOP, 5)
            :Text('Information about the author and available updates', 'font_sans_25', COLOR_WHITE)

        local scroll = vgui.Create('LIB.ScrollPanel', page)
        scroll:Dock(FILL)

        local infpanelaut = TDLib('DPanel', page)
            :ClearPaint()
            :Background(Color(49, 49, 49))
            :Stick(TOP, 5)
            :Text('', 'font_sans_25', COLOR_WHITE)
            :On('Paint', function(s, w, h)
                draw.SimpleText('Name of the basis: '..LIB.NameBasis, 'font_sans_21', 80, h * .2, c'Text', TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText('Autor: '..LIB.Autor, 'font_sans_21', 80, h * .5, c'Text', TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

                if LIB.Config.versionsCache == nil then
                    draw.SimpleText('Checking for updates...', 'font_sans_18', 80, h * .8, Color(255, 215, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    return
                end

                local isUpToDate = version == versionsCache[LIB.Version]
                local color = Color(0, 255, 0)
                local text = 'No information available!'

                if versionsCache[LIB.Version] then
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
            :CircleClick(LIB.Config.Theme.AlphaWhite)
            :Text('Check for updates', 'font_sans_21', c'Text')
            :On('DoClick', function(pPlayer, pActor)
                LIB.Config.versionsCache = nil
                http.Fetch("https://raw.githubusercontent.com/denchik5133/Basic-Script-Library/main/version.txt", function(actualVer)
                    LIB.Config.versionsCache = util.JSONToTable(actualVer)
                    if actualVer ~= LIB.Version then
                        print('A new version of the Base DanLib addon has been released! Current version '..LIB.Version)
                        --LIB:ScreenNotify(nil, QUERY_MAT_WARNING, c'Yellow', string.format('A new version of the Base DanLib addon has been released! Current version "%s"', LIB.Version))
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


    local sideblock = TDLib('EditablePanel', frame)
        :ClearPaint()
        :Background(Color(49, 49, 49))
        :Stick(LEFT)

    sideblock:SetWide(32)
    sideblock.opened = false

    local scroll = vgui.Create('DScrollPanel', sideblock)
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
            surface.SetMaterial(LIB.Config.Materials.MenuToggle)
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
            :CircleClick(LIB.Config.Theme.AlphaWhite)

        Button:DockMargin(0, v.ButtonDistance, 0, 0)
        scroll:AddItem(Button)
    end


    return frame
end)

concommand.Add( 'lib_menu_base', LibMenuBase )
