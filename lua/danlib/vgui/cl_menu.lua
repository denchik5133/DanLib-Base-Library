/***
 *   @addon         DanLib
 *   @version       3.0.0
 *   @release_date  10/4/2023
 *   @author        denchik
 *   @contact       Discord: denchik_gm
 *                  Steam: https://steamcommunity.com/profiles/76561198405398290/
 *                  GitHub: https://github.com/denchik5133
 *                
 *   @description   Universal library for GMod Lua, combining all the necessary features to simplify script development. 
 *                  Avoid code duplication and speed up the creation process with this powerful and convenient library.
 *
 *   @usage         !danlibmenu (chat) | danlibmenu (console)
 *   @license       MIT License
 *   @notes         For feature requests or contributions, please open an issue on GitHub.
 */
 


local base = DanLib.Func
local CookieUtils = DanLib.CookieUtils
local CustomUtils = DanLib.CustomUtils
local Table = DanLib.Table

-- Constants for UI dimensions
local DEFAULT_WIDTH = base:GetSize(1000)
local DEFAULT_HEIGHT = base:GetSize(620)
local NEWS_SIZE = base:GetSize(300)
local ui = DanLib.UI
local utils = DanLib.Utils


-- Table to hold news articles
local News = {}
local AddNews = {}


-- Fetch news data from a remote source
DanLib.HTTP:Fetch('https://raw.githubusercontent.com/denchik5133/DDI-Other-Informations/main/DDI/DanLib/news.json', function(data)
    AddNews = DanLib.NetworkUtil:JSONToTable(data)
end)


--- Gets the list of news articles
-- @return table: List of news articles or an empty table
function News:Get() return AddNews or {} end


-- Update screen size when the screen size changes
local function ScreenSizeChanged()
    DEFAULT_WIDTH = base:GetSize(1000)
    DEFAULT_HEIGHT = base:GetSize(620)
    NEWS_SIZE = base:GetSize(300)
end
DanLib.Hook:Add('DDI.PostScreenSizeChanged', 'DDI.ScreenSizeChanged', ScreenSizeChanged)



DanLib = DanLib or {}
DanLib.BaseMenu = DanLib.BaseMenu or {}

-- Remove existing menu if valid
if ui:valid(DanLib.MainMenu) then DanLib.MainMenu:Remove() end


--- Creates the main menu UI
-- @return Panel: The created main menu
local function base_menu()
    if ui:valid(DanLib.MainMenu) then DanLib.MainMenu:Remove() end
    local pPlayer = LocalPlayer()

    -- Create main frame
    local MainMenu = CustomUtils.Create()
    DanLib.MainMenu = MainMenu
    MainMenu:SetPos(0, 0)
    MainMenu:SetSize(ui:ScrW(), ui:ScrH())
    MainMenu:MakePopup()
    MainMenu:SetAlpha(0)
    MainMenu:AlphaTo(255, 0.2, 0)

    -- Draw background and title
    MainMenu:ApplyEvent(nil, function(sl, w, h)
        utils:DrawBlur(sl, 2, 2)
        utils:DrawRect(0, 0, w, h, Color(14, 22, 33, 180))
        draw.SimpleText(DanLib.AddonsName, 'danlib_font_20', 10, 10, base:Theme('text'), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(base:L('#version', { version = DanLib.Version }), 'danlib_font_20', w - 10, 10, base:Theme('text'), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end)

    -- Seasonal effect
    if DanLib.USERCONFIG.BASE.ShowParticles then
        local currentMonth = os.date('!*t', os.time()).month
        if (currentMonth == 12 or currentMonth == 1 or currentMonth == 2) then
            base.CreateSnowPanel(MainMenu)
        else
            base.CreateLinePanel(MainMenu)
        end
    end

    --- Displays a pop-up for unsaved changes
    function MainMenu:SavePopout()
        local Size = 38
        local Margin = 2
        local type_icon = DanLib.TYPE['WARNING']
        local type_color = DanLib.TYPE_COLOR['WARNING']
        local text = base:L('PlsRememberSaveChanges')
        local text_w, text_h = utils:GetTextSize(text, 'danlib_font_18')
        local width = ui:ClampScaleW(self:GetWide(), 200, 300)
        local height = ui:ClampScaleH(self:GetTall(), 50, 80)

        self.Debug = CustomUtils.Create(MainMenu)

        local pos_x, pos_y = self.Debug:GetPosition('BOTTOM_LEFT', 80)
        pos_x = pos_x - 50
        local t = 0.2

        self.Debug:SetPos(pos_x, self:GetTall())
        self.Debug:SetSize(width, height)
        self.Debug:SetAlpha(0)
        self.Debug:AlphaTo(255, t, 0)
        self.Debug:MoveTo(pos_x, pos_y, t, 0, -10)
        self.Debug:SetDrawOnTop(true)
        self.Debug:ApplyEvent(nil, function(sl, w, h)
            utils:DrawRoundedBox(0, 0, w, h, base:Theme('primary_notifi'))
            utils:DrawOutlinedRoundedRect(6, 0, 0, w, h, 4, base:Theme('frame'))
            local squareSize = 64
            utils:DrawSquareWithIcon(8, (h - squareSize) / 2, base:Theme('secondary_dark'), squareSize, type_icon, 6)
            local text_x, text_y = squareSize + 24, h / 2
            utils:DrawDualTextWrap(text_x, text_y, 'WARNING', 'danlib_font_18', type_color, base:L('PlsRememberSaveChanges'), 'danlib_font_18', base:Theme('title'), TEXT_ALIGN_LEFT, nil, 200)
        end)

        -- Button to confirm navigation
        local button = base.CreateUIButton(self.Debug, {
            background = { nil },
            dock = { FILL },
            hover = { base:Theme('button_hovered', 50), nil, 8 },
            hoverClick = { nil },
            click = function()
                DanLib.BaseMenu:SetActive(5) -- Configuration page
                -- base:TutorialSequence(5, 1)
                -- DanLib.BaseMenu:ToggleMenuVisibility(false)
            end
        })
    end

    --- Closes the save pop-up
    function MainMenu:CloseSave()
        self.Debug.Closing = true

        local pos_x, pos_y = self.Debug:GetPosition('BOTTOM_LEFT', 80)
        pos_x = pos_x - 50
        local t = 0.2

        self.Debug:SetAlpha(255)
        self.Debug:AlphaTo(0, t, 0)
        self.Debug:MoveTo(pos_x, pos_y, t, nil, nil, function()
            self.Debug:Remove()
        end)
    end

    -- Monitor for configuration changes
    MainMenu:ApplyEvent('Think', function(self)
        if (DanLib.ChangedConfig and table.Count(DanLib.ChangedConfig) > 0) then
            if (not ui:valid(self.Debug)) then
                self:SavePopout()
            end
        elseif (ui:valid(self.Debug) and not self.Debug.Closing) then
            self:CloseSave()
        end
    end)

    if base.HasPermission(pPlayer, 'Tutorial') then
        if (CookieUtils:GetNumber('DanLib.TutorialCompleted', 0) < #DanLib.BaseConfig.Tutorials and not ui:valid(DANLIB_TUTORIAL)) then
            DANLIB_TUTORIAL = base.CreatePanelTutorial(MainMenu)
            DANLIB_TUTORIAL:SetPos(50, 100)
            DANLIB_TUTORIAL:SetTutorial(CookieUtils:GetNumber('DanLib.TutorialCompleted', 0) + 1)
        end
    end

    -- Create main container
    local Container = CustomUtils.Create(MainMenu)
    Container:SetSize(DEFAULT_WIDTH, DEFAULT_HEIGHT)
    Container:Center()
    Container:ApplyEvent(nil, function(sl, w, h)
        DanLib.DrawShadow:Begin()
        local x, y = sl:LocalToScreen(0, 0)
        utils:DrawRect(x, y, w, h, base:Theme('background'))
        DanLib.DrawShadow:End(1, 1, 1, 255, 0, 0, false)
    end)
    
    -- Create navigation panel
    local Navigation = CustomUtils.Create(Container, 'DanLib.UI.Sidenav')
    Navigation:Pin(LEFT)
    Navigation:SetWide(50)
    Navigation.MainMenu = MainMenu
    Navigation.Container = Container
    MainMenu.Navigation = Navigation

    -- Create the main content container
    local container = CustomUtils.Create(Container)
    container:Pin(FILL, 8)
    MainMenu.Container = container

    -- Populate pages
    local pages = {}
    for _, v in pairs(DanLib.Pages) do
        pages[#pages + 1] = v
    end

    -- Sort pages by order
    Table:Sort(pages, function(a, b)
        if (a:GetOrder() == b:GetOrder()) then return a:GetName() < b:GetName() end
        return a:GetOrder() < b:GetOrder()
    end)

    MainMenu.pages = pages
    local page_1st
    
    -- Create tabs for each page
    for i, page in ipairs(pages) do
        -- Access verification
        -- Skip this tab if the player does not have access
        if (page.AccessСheck and page:AccessСheck(pPlayer) == false) then continue end
        page.pnl = Navigation:AddTab(page:GetIcon() or 'error', page:GetName() or '???', function()
            if (page.OnClick and page:OnClick(MainMenu)) then return end
            if (MainMenu.activeTab == i) then return end
            MainMenu.activeTab = i

            -- Saving the selected page to a cookie
            CookieUtils:Set('DanLib.ActivePage', i)

            for _, child in ipairs(container:GetChildren()) do
                child:Remove()
            end

            MainMenu:SetKeyboardInputEnabled(page:GetKeyboardInput())
            if page.Create then page:Create(container) end

            -- Set the active tab
            Navigation.activeTab = page.pnl
            Navigation:UpdateActiveTab()
            MainMenu:MakePopup()
        end)

        page.pnl:SetVisible(page.AccessСheck == nil or page.AccessСheck(pPlayer) ~= false)
        page_1st = page_1st or page.pnl
    end

    -- Opening the last selected page
    local lastActivePage = CookieUtils:GetNumber('DanLib.ActivePage', 1) -- Defaults to the first page
    if (lastActivePage <= #pages) then
        DanLib.BaseMenu:SetActive(lastActivePage)
    else
        if page_1st:Valid() then
            page_1st:Click()
        end
    end

    return MainMenu
end


--- Sets the active page based on the specified index.
-- @param index: The index of the page to activate.
function DanLib.BaseMenu:SetActive(index)
    local menu = DanLib.MainMenu
    if (not ui:valid(menu)) then return end -- Check if the menu exists

    -- Check that the index is within the available pages
    if (index < 1 or index > #menu.pages) then return end

    -- Set the active tab
    menu.activeTab = index
    local Navigation = menu.Navigation

    -- Get a container for pages
    local container = menu.Container
    if (not container) then return end

    -- Clean the container of old elements
    for _, child in ipairs(container:GetChildren()) do
        -- Do not delete Navigation
        if (child ~= Navigation) then child:Remove() end
    end

    -- Create a new page
    if menu.pages[index].Create then
        menu.pages[index]:Create(container)
    end

    -- Update navigation
    Navigation.activeTab = menu.pages[index].pnl
    Navigation:UpdateActiveTab()
    menu:MakePopup() -- Ensure that the menu is active
end


--- Toggles the visibility of the base menu.
function DanLib.BaseMenu:Toggle()
    local menu = DanLib.MainMenu
    if (ui:valid(menu) == false) then
        menu = base_menu()
    end

    local pPlayer = LocalPlayer()
    for _, tab in ipairs(menu.pages) do
        -- tab.pnl:SetVisible(tab.CustomCheck == nil or tab.CustomCheck(pPlayer) ~= false)
    end
end


--- Toggles the visibility of the base menu with initial transparency.
-- @param show boolean: If true, shows the menu; if false, sets it to semi-transparent.
function DanLib.BaseMenu:ToggleMenuVisibility(show)
    local menu = DanLib.MainMenu
    if (not ui:valid(menu)) then return end -- Check if the menu exists

    local initialTransparency = 80 -- Transparency level on display
    if show then
        -- Show menu with initial transparency
        menu:SetVisible(true)
        menu:SetAlpha(initialTransparency) -- Set transparency level
        menu:AlphaTo(255, 0.2, 0) -- Return to full visibility
    else
        -- Set menu to semi-transparent state
        menu:AlphaTo(initialTransparency, 0.2, 0) -- Set transparency level
    end
end


-- Network handler for opening the base menu
DanLib.Network:Receive('DanLib:BaseMenu', function()
    -- DanLib.Protection:SafeExecute(function()
        DanLib.BaseMenu:Toggle()
        base:TutorialSequence(1, 1)
    -- end)
end)
