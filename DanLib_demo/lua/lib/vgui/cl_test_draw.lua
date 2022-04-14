local function Access(ply)
    local t = {
        ['superadmin'] = true,
    }

    return t[ply:GetUserGroup()] or false
end

function LibMenuSettings(pPlayer)
    if IsValid(MainFrame) then MainFrame:Remove() end

    local sizeButton = 35
    local navOptions = {}
	navOptions[1] = {name = 'Addition', icon = LIB.Config.Materials.Testing , ButtonDistance = 5}
	navOptions[2] = {name = 'Modules', icon = LIB.Config.Materials.Testing , ButtonDistance = 5}
	navOptions[3] = {name = 'Testing #3', icon = LIB.Config.Materials.Testing , ButtonDistance = 5}
	navOptions[4] = {name = 'Testing #4', icon = LIB.Config.Materials.Testing , ButtonDistance = 5}
	navOptions[5] = {name = 'Testing #5', icon = LIB.Config.Materials.Testing , ButtonDistance = 5}
	navOptions[6] = {name = 'Testing #6', icon = LIB.Config.Materials.Testing , ButtonDistance = 5, Access = Access}
	navOptions[7] = {name = 'Settings', icon = LIB.Config.Materials.Settings , ButtonDistance = 450}

    local cButton = 1
    MainFrame = vgui.Create('LIB.Frame')
    MainFrame:SetTitle('Settings Menu Dan Lib')
    MainFrame:SetSize(ScrW() * .6, ScrW() * .4)
    MainFrame:MakePopup() 
    MainFrame:Center() 
    MainFrame:ShowSettingsButton(pPlayer:IsSuperAdmin())

    MainFrame:SetSettingsFunc(function()
        local Menu = vgui.Create('Dan.Menu')
            Menu:AddOption('Сохранить', function()

            end):SetIcon('icon16/script_save.png')

            Menu:AddOption('Сбросить', function() 

            end):SetIcon('icon16/arrow_rotate_clockwise.png')
        Menu:Open()
    end)

    local sideblock = vgui.Create('LIB.Sideblock', MainFrame)

    local scroll = vgui.Create('LIB.ScrollPanel', sideblock)
    scroll:Dock(FILL)

    local page = TDLib('DPanel', MainFrame)
        :ClearPaint()
        :Background(LIB.Config.Theme.Primary)
        :Stick(FILL)

    page:SetTall(45)
    page:DockMargin(0, 5, 6, 5)

    -- Main
    local pages = {}
    pages[1] = function()
    	page:Clear()

        local gButton = vgui.Create('DButton', page)
        gButton:TDLib()
            :Stick(TOP, 3)
            :ClearPaint()
            :FadeHover()
            :Text('Testing Button #1', 'font_sans_21', LIB.Config.Theme.Text)
            :On('DoClick', function()
                LIB:QuerryText(QUERY_MAT_QUESTION, LIB.Config.Theme, 'Введите название точки', '', nil, function()
                end, nil, nil)
            end)
            :On('Paint', function(s, w, h)
                draw.RoundedBox(4, 1, 1, w-2, h-2, Color(50, 50, 50, 200))                                 -- Background
                draw.RoundedBoxEx(4, 1, 1, w-2, h-2, Color(52, 52, 57, 255), true, true, false, false)     -- Top bar with rounded corners.
            end)
        gButton:SetTall(35)
        gButton:DockMargin(5, 5, 5, 0)

        local g2 = vgui.Create('DButton', page)
        g2:TDLib()
            :Stick(TOP, 3)
            :ClearPaint()
            :FadeHover()
            :Text('Testing #2', 'font_sans_21', LIB.Config.Theme.Text)
            :On('DoClick', function()
                LIB:QuerryDonate('Дополнительный слот', nil, function()
                end)
            end)
            :On('Paint', function(s, w, h)
                draw.RoundedBox(4, 1, 1, w-2, h-2, Color(50, 50, 50, 200))                                 -- Background
                draw.RoundedBoxEx(4, 1, 1, w-2, h-2, Color(52, 52, 57, 255), true, true, false, false)     -- Top bar with rounded corners.
            end)
        g2:SetTall(35)
        g2:DockMargin(5, 4, 5, 0)

        local g3 = vgui.Create('DButton', page)
        g3:TDLib()
            :Stick(TOP, 3)
            :ClearPaint()
            :FadeHover()
            :Text('Testing #3', 'font_sans_21', LIB.Config.Theme.Text)
            :On('DoClick', function()
                LIB:QuerryInformation('Ты болбес!', nil, function()
                end)
            end)
            :On('Paint', function(s, w, h)
                draw.RoundedBox(4, 1, 1, w-2, h-2, Color(50, 50, 50, 200))                                 -- Background
                draw.RoundedBoxEx(4, 1, 1, w-2, h-2, Color(52, 52, 57, 255), true, true, false, false)     -- Top bar with rounded corners.
            end)
        g3:SetTall(35)
        g3:DockMargin(5, 4, 5, 0)

        local g4 = vgui.Create('DButton', page)
        g4:TDLib()
            :Stick(TOP, 3)
            :ClearPaint()
            :FadeHover()
            :Text('Testing #4', 'font_sans_21', LIB.Config.Theme.Text)
            :On('DoClick', function()
                LIB:QuerryText(QUERY_MAT_TEST, LIB.Config.Theme.Accent, 'Это просто тест! Здорово правда? :)', '', 'Подтвердить!', function(v)
                end, nil, 'Подтвердить', 'Отмена')
            end)
            :On('Paint', function(s, w, h)
                draw.RoundedBox(4, 1, 1, w-2, h-2, Color(50, 50, 50, 200))                                 -- Background
                draw.RoundedBoxEx(4, 1, 1, w-2, h-2, Color(52, 52, 57, 255), true, true, false, false)     -- Top bar with rounded corners.
            end)

        g4:SetTall(35)
        g4:DockMargin(5, 4, 5, 0)

        local g5 = vgui.Create('DButton', page)
        g5:TDLib()
            :Stick(TOP, 3)
            :ClearPaint()
            :FadeHover()
            :Text('Testing a pop-up notification', 'font_sans_21', LIB.Config.Theme.Text)
            :On('DoClick', function()
                LIB:ScreenNotify(nil, nil, LIB.Config.Theme.Text, 'Просто тест!')
            end)
            :On('Paint', function(s, w, h)
                draw.RoundedBox(4, 1, 1, w-2, h-2, Color(50, 50, 50, 200))                                 -- Background
                draw.RoundedBoxEx(4, 1, 1, w-2, h-2, Color(52, 52, 57, 255), true, true, false, false)     -- Top bar with rounded corners.
            end)
        g5:SetTall(35)
        g5:DockMargin(5, 4, 5, 0)

        local g6 = vgui.Create('DButton', page)
        g6:TDLib()
            :Stick(TOP, 3)
            :ClearPaint()
            :FadeHover()
            :Text('Testing the color window', 'font_sans_21', LIB.Config.Theme.Text)
            :On('Paint', function(s, w, h)
                draw.RoundedBox(4, 1, 1, w-2, h-2, Color(50, 50, 50, 200))                                 -- Background
                draw.RoundedBoxEx(4, 1, 1, w-2, h-2, Color(52, 52, 57, 255), true, true, false, false)     -- Top bar with rounded corners.
            end)

        g6:SetTall(35)
        g6:DockMargin(5, 4, 5, 0)

        function g6:DoClick()
            local iX, iY = g6:LocalToScreen(50, self:GetTall() + 20)

            local pnlOver = vgui.Create('EditablePanel')
            pnlOver:SetSize(ScrW(), ScrH())
            pnlOver:MakePopup()
            function pnlOver:OnMousePressed()
                self:Remove()
            end

            local pnlBack = vgui.Create('DPanel', pnlOver)
            pnlBack:SetPos(iX, iY)
            pnlBack:SetSize(ScrH() * 0.3, ScrH() * 0.3)
            function pnlBack:Paint(iW, iH)
                --draw.RoundedBox(8, 0, 0, iW, iH, Color(255, 255, 255))
                draw.RoundedBox(8, 1, 1, iW - 2, iH - 2, LIB.Config.Theme.Background)
            end

            local pnlColorCube = vgui.Create('DColorMixer', pnlBack)
            pnlColorCube:SetSize(pnlBack:GetWide() * 0.9, pnlBack:GetTall() * 0.9)
            pnlColorCube:SetPos(pnlBack:GetWide() * 0.05, pnlBack:GetTall() * 0.05)
            pnlColorCube:SetAlphaBar(true)
            pnlColorCube:SetPalette(true)
            pnlColorCube:SetWangs(true)
            pnlColorCube:SetColor(Color(255, 140, 0))
            function pnlColorCube:ValueChanged(cColor)
            end
        end
    end
    pages[1]()

    -- Оъновления
    pages[2] = function()
    	page:Clear()
    end

    -- LVL
    pages[3] = function()
    	page:Clear()
    end

    pages[4] = function()
    	page:Clear()
    end

    pages[5] = function()
    	page:Clear()

        local checkbox = TDLib( 'LIB.Checkbox', page ) -- Create the checkbox
        checkbox:SetPos( 25, 50 ) -- Set the position
        checkbox:SetSize(32, 15)
    end

    -- Руковоство
    pages[6] = function()
    	page:Clear()

        local scroll = vgui.Create('LIB.ScrollPanel', page)
        scroll:Dock(FILL)

        local FirstText = vgui.Create('LIB.TextEntry', scroll)
        FirstText:SetPos(20, 20)
        FirstText:SetSize(500, 100)
        FirstText:SetMultiline(true)
        FirstText:SetEnterAllowed( true )
        FirstText:SetPlaceholder('Начните писать текст сдесь...')
    end

    pages[7] = function()
    	page:Clear()

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
                surface.SetDrawColor(LIB.Config.Theme.Accent)
                surface.DrawTexturedRect(w/2-130, 3, 24, 24)

                draw.SimpleText('Configuration', 'font_sans_26', w/2 - 100, 15, LIB.Config.Theme.Text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
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
            :Background(LIB.Config.Theme.Background)
            :On('Paint', function(s, w, h)
                surface.SetMaterial(LIB.Config.Materials.ChatCommand)
                surface.SetDrawColor(LIB.Config.Theme.Accent)
                surface.DrawTexturedRect(4, 3, 44, 44)

                draw.SimpleText('ChatCommand', 'font_sans_22', 50, 15, LIB.Config.Theme.Text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText('Chat command to be used to open the LIB Configuration Menu', 'font_sans_18', 50, 35, LIB.Config.Theme.Text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end)

        s:SetTall(50)
        s:DockMargin(5, 4, 5, 0)
        p.list:AddItem(s)


        local te = TDLib('DTextEntry', s)
            :ReadyTextbox()
            --:BarHover()
            :Background(Color(55, 55, 55, 150))
            :Stick(RIGHT, 10)

        te:SetTextColor(color_white)
        te:SetCursorColor( Color(181, 181, 181) )
        te:SetFont('font_sans_21')
        te:SetUpdateOnType(true)
        te:SetPlaceholderText('ChatCommands...')
        te:SetWide(200)


        local g = vgui.Create('DPanel', p.list)
        g:TDLib()
            :Stick(TOP, 5)
            :ClearPaint()
            :FadeHover()
            :Background(LIB.Config.Theme.Background)
            :On('Paint', function(s, w, h)
                surface.SetMaterial(LIB.Config.Materials.Language)
                surface.SetDrawColor(LIB.Config.Theme.Accent)
                surface.DrawTexturedRect(5, 5, 38, 38)

                draw.SimpleText('Language', 'font_sans_22', 50, 15, LIB.Config.Theme.Text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText('The language to be selected as the main one', 'font_sans_18', 50, 35, LIB.Config.Theme.Text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end)

        g:SetTall(50)
        g:DockMargin(5, 4, 5, 0)
        p.list:AddItem(g)

        local lg = TDLib('LibUI.Combobox', g)
            :ReadyTextbox()
            :Stick(RIGHT, 10)

        lg:SetValue(LIB.SelectedLanguage or 'English')
        lg:SetWide(200)
        for k, v in pairs( LIB.Localization.Languages ) do
            lg:AddChoice( LIB.Localization.LangCodes[k], k )
        end 
        function lg:OnSelect( index, text, data )
            LIB.SelectedLanguage = data
            lg:SetValue( data )
            LocalPlayer():SetPData( "awarn3_lang", data )
        end

        local cl = vgui.Create('DPanel', p.list)
        cl:TDLib()
            :Stick(TOP, 5)
            :ClearPaint()
            :FadeHover()
            :Background(LIB.Config.Theme.Background)
            :On('Paint', function(s, w, h)
                surface.SetMaterial(LIB.Config.Materials.Interface)
                surface.SetDrawColor(LIB.Config.Theme.Accent)
                surface.DrawTexturedRect(5, 5, 38, 38)

                draw.SimpleText('Interface theme', 'font_sans_22', 50, 15, LIB.Config.Theme.Text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText('The interface that will be used as the basis', 'font_sans_18', 50, 35, LIB.Config.Theme.Text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end)

        cl:SetTall(50)
        cl:DockMargin(5, 4, 5, 0)
        p.list:AddItem(cl)

        local lg = TDLib('LibUI.Combobox', cl)
            :ReadyTextbox()
            :Stick(RIGHT, 10)

        lg:SetValue('Dark')
        lg:AddChoice( "Gray" )
        lg:AddChoice( "Dark" )
        lg:AddChoice( "Light" )
        lg:AddChoice( "Green" )
        lg:SetWide(200)

    end

    --Навигационная панель
	for k, v in pairs(navOptions) do

        if v.Access then
            if !v.Access(LocalPlayer()) then
                continue
            end
        end

        local Button = TDLib('DButton', scroll)
            Button:SetTall(sizeButton)
            Button:TDLib()
                :Stick(TOP, 2)
                :ClearPaint()
                :FadeHover()
                :Text('', 'font_sans_21', LIB.Config.Theme.Text)
                :On('DoClick', function()
                    if v.click then v.click(pnl) end

                    cButton = k
                    pages[k]()
                end)
                :On('Paint', function(s, w, h)
                    draw.RoundedBox(4, 1, 1, w-2, h-2, Color(50, 50, 50, 200))                                 -- Background
                    draw.RoundedBoxEx(4, 1, 1, w-2, h-2, Color(52, 52, 57, 255), true, true, false, false)     -- Top bar with rounded corners.

                    draw.SimpleText(v.name, 'font_sans_21', 40, 15, LIB.Config.Theme.Text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

                    surface.SetMaterial(v.icon)
                    surface.SetDrawColor(LIB.Config.Theme.Accent)
                    surface.DrawTexturedRect(2, 2, 32, 32)

                    if(k == cButton) then
                        --surface.SetMaterial(LIB.Config.Materials.Arrow)
                        --surface.SetDrawColor(LIB.Config.Theme.Accent)
                        --surface.DrawTexturedRect(0, 0, 16, 16)
                    end
                end)
                :CircleClick(LIB.Config.Theme.AlphaWhite)

        --Button:SetTall(sizeButton)
        Button:DockMargin(2, v.ButtonDistance, 2, 0)
        Button:SetWide(scroll:GetWide()/#navOptions)
	end
end

concommand.Add( 'lib_menu_settings', LibMenuSettings )
