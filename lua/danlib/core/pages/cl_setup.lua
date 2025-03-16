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
local utils = DanLib.Utils
local Table = DanLib.Table
local network = DanLib.Network
local customUtils = DanLib.CustomUtils

local string = string
local table = table
local count = table.Count

local SETUP = base.CreatePage(base:L('#settings'))
SETUP:SetOrder(5)
SETUP:SetIcon(DanLib.Config.Materials['Settings'])
SETUP:SetKeyboardInput(true)


--- Checks if the player has access to the administration pages.
-- @param pPlayer Player|nil The player for whom access is being checked. If nil, LocalPlayer() is used.
-- @return boolean Returns true if the player has access, otherwise false.
function SETUP:AccessСheck(pPlayer)
    return base.HasPermission(pPlayer or LocalPlayer(), 'AdminPages')
end


--- Creates a settings panel.
-- @param parent Panel The parent panel to which the settings panel will be added.
function SETUP:Create(parent)
    base:TutorialSequence(4, 4)
    local settings = parent:Add('DanLib.UI.Setup')
    settings:Dock(FILL)
end 


local ui = DanLib.UI
local SETUP, _ = DanLib.UiPanel()


--- Initializes the setup panel
function SETUP:Init()
    self:TopHeader() -- Creating a top header
    self.pages = {} -- Table for page storage
    self.categoryButtons = {} -- Table for category buttons
    self.modulesToPages = {}
    self.pageIndexCounter = 0 -- Counter for unique page indexes
    self.defaultFont = 'danlib_font_18' -- Default font

    self.tabs = self:Add('DanLib.UI.Tabs')
    self.tabs:DockMargin(0, 8, 0, 0)
    self.tabs.TabID = {}

    self:PopulatePages() -- Filling pages
    self:Refresh() -- Interface update
    self:CheckForUnsavedChanges()
end

--- Creates the top header of the panel
function SETUP:TopHeader()
    self.header = customUtils.Create(self)
    self.header:PinMargin(TOP, nil, nil, nil, 12)
    self.header:SetTall(46)
    self.header:ApplyShadow(10, false)
    self.header.icon = 24
    self.header.iconMargin = 14
    self.header:ApplyEvent(nil, function(sl, w, h)
        utils:DrawRoundedBox(0, 0, w, h, base:Theme('secondary_dark'))
        utils:DrawIcon(sl.iconMargin, h * .5 - sl.icon * 0.5, sl.icon, sl.icon, DanLib.Config.Materials['Settings'], base:Theme('mat', 150))
        utils:DrawDualText(sl.iconMargin * 3.5, h / 2 - 2, base:L('#settings'), 'danlib_font_20', base:Theme('decor'), base:L('#settings.description'), self.defaultFont, base:Theme('text'), TEXT_ALIGN_LEFT, nil, w - 300)
    end)

    -- Defining the buttons for saving and cancelling
    self.cancelButton = self:CreateButton(base:L('cancel'), Color(209, 53, 62), function()
        DanLib.ChangedConfig = nil
        self:Refresh()
    end)
    self.saveButton = self:CreateButton(base:L('save'), Color(67, 156, 242), function()
        self:HandleSave()
    end)
end


--- Creates a button in the header
-- @param name: string The name of the button
-- @param color: Color The color of the button
-- @param onClick: function The function to call when the button is clicked
-- @return DButton: The created button
function SETUP:CreateButton(name, color, onClick)
    local buttonSize = utils:TextSize(name, self.defaultFont).w
    local Button = base.CreateUIButton(self.header, {
        background = { nil },
        dock_indent = { RIGHT, nil, 7, 6, 7 },
        wide = 14 + buttonSize,
        hover = { ColorAlpha(color, 60), nil, 6 },
        text = { name, nil, nil, nil, color },
        click = onClick
    })
    Button:SetEnabled(false)
    return Button
end


--- Gets a sorted configuration
-- @return table: A sorted table of configuration items
function SETUP:GetSortedConfig()
    local sortedConfig = {}
    for k, v in pairs(DanLib.ConfigMeta) do
        Table:Add(sortedConfig, { v.SortOrder, k })
    end
    Table:SortByMember(sortedConfig, 1, true) -- Sort by order
    return sortedConfig
end


function SETUP:GetReset(moduleKey, key)
    -- Retrieve module by key
    local module = DanLib.ConfigMeta[moduleKey]
    
    -- Check if the module exists
    if (not module) then
        base:PrintError('Module not found: ' .. moduleKey)
        return
    end

    -- Get values by key
    local defaultValues = module:GetDefaultValue(key)

    -- Check the type of the returned value
    if (type(defaultValues) == 'table') then
        -- If it's a table, copy it
        defaultValues = table.Copy(defaultValues)
    elseif (type(defaultValues) == 'string') then
        -- If it's a string, leave it unchanged
        defaultValues = defaultValues
    elseif (type(defaultValues) == 'boolean') then
        -- If it's a boolean, leave it unchanged
        defaultValues = defaultValues
    else
        -- If it is not a table, string, or boolean, we print an error message
        base:PrintError('A table, string, or boolean was expected but received: ' .. type(defaultValues))
        return
    end

    -- Call the function to change the configuration
    base:SetConfigVariable(moduleKey, key, defaultValues)
end


--- Fills the pages with content
function SETUP:PopulatePages()
    local sortedConfig = self:GetSortedConfig()
    for k, config in pairs(sortedConfig) do
        local moduleKey = config[2]
        local module = DanLib.ConfigMeta[moduleKey]
        local page = customUtils.Create(self.tabs)
        local scrollPanel = customUtils.Create(page, 'DanLib.UI.Scroll')
        scrollPanel:Pin(FILL)
        page.scrollPanel = scrollPanel

        -- Increase the page index count
        self.pageIndexCounter = self.pageIndexCounter + 1
        self.modulesToPages[moduleKey] = self.pageIndexCounter -- Assign a unique index

        -- Refreshing a page
        page:ApplyEvent('Refresh', function(sl)
            scrollPanel:Clear()
            local hasVariables = false
            sl.variablePanels = {}

            for key, val in pairs(module:GetSorted()) do
                -- Set flag if variables are found
                hasVariables = true
                self:CreateVariablePanel(scrollPanel, val, moduleKey, module, sl)
            end

            -- Check if there are variables
            if (not hasVariables) then
                -- Create a panel with a message
                local emptyMessagePanel = customUtils.Create(page)
                emptyMessagePanel:Pin(FILL)
                emptyMessagePanel:ApplyText("There's nothing here", 'danlib_font_26', nil, nil, base:Theme('text'))
            end
        end)
        self:AddPageModule(page, k, module, moduleKey) -- Adding a page to the public list
    end

    DanLib.Hook:Add('DanLib:HooksConfigUpdated', 'HooksConfigUpdated', function() self:Refresh() end)
end


--- Creates a variable panel in the scrollable area
-- @param pages: The scroll panel to add the variable to
-- @param val table: The variable configuration
-- @param moduleKey string: The key for the module
-- @param module table: The module object
-- @param sl table: Reference to the current setup object
function SETUP:CreateVariablePanel(pages, val, moduleKey, module, sl)
    local headerH = 50
    local customElement = val.Type == DanLib.Type.Table and val.VguiElement
    local variablePanel = customUtils.Create(pages)
    variablePanel:PinMargin(TOP, nil, nil, 4, 8)
    variablePanel:SetTall(headerH)
    variablePanel:ApplyEvent(nil, function(sl, w, h)
        utils:DrawRoundedBox(0, 0, w, h, base:Theme('secondary', 150))
        sl:ApplyAlpha(false, 0, 0.5, false, sl.undercolor, 255, 0.5)
        utils:DrawRoundedBox(0, 0, w, h, Color(46, 62, 82, sl.alpha))
        utils:DrawDualText(10, headerH / 2 - 2, val.Name or nil, self.defaultFont, base:Theme('decor'), val.Description or nil, self.defaultFont, base:Theme('text'), TEXT_ALIGN_LEFT, nil, w - 210)
    end)

    -- Adding functionality depending on the type of variable
    self:AddVariableFunctionality(variablePanel, customElement, val, moduleKey, module, sl)
end


--- Adds functionality to a variable panel based on its type
-- @param variablePanel Panel: The variable panel to add functionality to
-- @param customElement string: The custom element type (if any)
-- @param val table: The variable configuration
-- @param moduleKey string: The key for the module
-- @param module table: The module object
-- @param sl table: Reference to the current setup object
function SETUP:AddVariableFunctionality(variablePanel, customElement, val, moduleKey, module, sl)
    local wide, margiMoveToRight, margin = 200, 15, (variablePanel:GetTall() - 30) * 0.5 -- indentation
    sl.variablePanels[val.Key] = variablePanel

    self:CreateResetButton(variablePanel, moduleKey, val.Key)

    -- Processing different types of variables
    if (customElement or val.GetOptions) then
        if val.GetOptions then
            local options = val.GetOptions()
            local comboSelect = base.CreateUIComboBox(variablePanel)
            comboSelect:CustomUtils()
            comboSelect:Dock(RIGHT)
            comboSelect:DockMargin(0, margin, margiMoveToRight, margin)
            comboSelect:SetWide(wide)
            comboSelect:SetValue(module:GetValue(val.Key))
            local currentValue = module:GetValue(val.Key)
            for k, v in pairs(options) do
                comboSelect:AddChoice(v, k, currentValue == k)
            end
            comboSelect:ApplyEvent('OnSelect', function(_, index, value, data)
                print(moduleKey, val.Key, data)
                base:SetConfigVariable(moduleKey, val.Key, data)
            end)
        else
            local button = base.CreateUIButton(variablePanel, {
                dock_indent = { RIGHT, nil, margin, margiMoveToRight, margin },
                wide = 32,
                icon = { DanLib.Config.Materials['Edit'] },
                tooltip = { base:L('#edit'), nil, nil, TOP },
                click = function(sl)
                    if ui:valid(sl.con) then sl.con:Remove() return end
                    local Container = customUtils.Create(nil, val.VguiElement)
                    sl.con = Container
                    Container:FillPanel()
                end
            })
        end
    elseif (val.Type == DanLib.Type.Int) then
        local numberWang = base.CreateNumberWang(variablePanel)
        numberWang:PinMargin(RIGHT, nil, margin, margiMoveToRight, margin)
        numberWang:SetWide(wide)
        numberWang:SetHighlightColor(base:Theme('secondary', 50))
        numberWang:SetValue(module:GetValue(val.Key))
        numberWang:DisableShadows()
        numberWang:ApplyEvent('OnChange', function()
            base:SetConfigVariable(moduleKey, val.Key, numberWang:GetValue())
        end)
    elseif (val.Type == DanLib.Type.String) then
        local textEntry = base.CreateTextEntry(variablePanel)
        textEntry:PinMargin(RIGHT, nil, margin, margiMoveToRight, margin)
        textEntry:SetWide(wide)
        textEntry:SetHighlightColor(base:Theme('secondary', 50))
        textEntry:SetValue(module:GetValue(val.Key) or '')
        textEntry:DisableShadows()
        textEntry:ApplyEvent('OnChange', function()
            base:SetConfigVariable(moduleKey, val.Key, textEntry:GetValue())
        end)
    elseif (val.Type == DanLib.Type.Bool) then
        local CheckBox = base.CreateCheckbox(variablePanel)
        CheckBox:PinMargin(RIGHT, nil, margin, margiMoveToRight, margin)
        CheckBox:SetWide(32)
        CheckBox:SetValue(module:GetValue(val.Key))
        CheckBox:DisableShadows()
        CheckBox:ApplyEvent('OnChange', function(_, value)
            base:SetConfigVariable(moduleKey, val.Key, value)
        end)
    end

    -- Checking if there is an action
    if val.Action then
        self:CreateActionButton(variablePanel, val)
    end
end


--- Creates an action button for a variable panel
-- @param variablePanel Panel: The variable panel to add the action button to
-- @param val table: The variable configuration
function SETUP:CreateActionButton(variablePanel, val)
    local button = base.CreateUIButton(variablePanel, {
        dock_indent = { RIGHT, nil, 10, 15 - 4, 10 },
        wide = 32,
        icon = { DanLib.Config.Materials['Info'] },
        tooltip = {'Read More', nil, nil, TOP },
        click = function()
            if (type(val.Action) == 'function') then
                val.Action()  -- If it is a function, call it
            elseif (type(val.Action) == 'string') then
                customUtils.Create(nil, val.Action)  -- Register an item with vgui
            end
        end
    })
end


function SETUP:CreateResetButton(variablePanel, moduleKey, Key)
    local button = base.CreateUIButton(variablePanel, {
        dock_indent = { RIGHT, nil, 10, 15 - 4, 10 },
        wide = 32,
        icon = { DanLib.Config.Materials['Reset'] },
        tooltip = { base:L('#resetting.changes'), nil, nil, TOP },
        click = function()
            self:GetReset(moduleKey, Key)
        end
    })
end


--- Updates the interface by refreshing all pages
function SETUP:Refresh()
    for _, page in pairs(self.pages) do
        page:Refresh()
    end
end


--- Adds a page to the setup
-- @param panel Panel: The panel to add as a page
-- @param id string: The ID of the page
-- @param configMeta table: The metadata for the configuration
function SETUP:AddPageModule(panel, id, configMeta, moduleKey)
    panel.ID = id

    local key = #self.pages + 1
    self.pages[key] = panel

    local tab = self.tabs
    local text_wrap = utils:TextWrap(configMeta.Description, nil, 200)
    local c = tab:AddTab(panel, configMeta.Title, text_wrap, nil, configMeta.Color)
    tab.TabID[id] = c
end


--- Gets the page index and page name by module key.
-- The function looks for the page index in the modulesToPages table by the passed module key and returns the page name and index.
-- If no index is found, returns nil.
-- @param moduleKey string The module key of the module for which you want to get the page index.
-- @return string|nil Page name if index is found, otherwise nil.
-- @return number|nil The page index if the index is found, otherwise nil.
function SETUP:GetModuleAndPageIndex(moduleKey)
    -- Get page index by module key
    local pageIndex = self.modulesToPages[moduleKey]
    local pageName = (pageIndex and self.pages[pageIndex]) and self.pages[pageIndex].ID or nil -- Get the page name if the index is found
    return pageName, pageIndex
end


--- Opens a page by its ID
-- @param id string: The ID of the page to open
-- @return Panel|nil The opened page or nil if not found
function SETUP:ScrollPageByID(id)
    for k, v in ipairs(self.pages) do
        if ((v.ID or '') == id) then
            self.tabs:SetActive(k)
            return v
        end
    end
end


--- Go to the page with the change
-- @param index number: Page index for the transition
-- @param key string: Change key for selection
function SETUP:GotoOnPage(index, key)
    local page = self:ScrollPageByID(index)
    if (not ui:valid(page)) then return end

    local variablePanel = page.variablePanels[key]
    if (not ui:valid(variablePanel)) then return end

    base:TimerSimple(nil, function() 
        page.scrollPanel:ScrollToChild(variablePanel) 
    end)

    base:TimerSimple(1.2, function()
        if (not ui:valid(variablePanel)) then return end
        variablePanel.undercolor = true

        base:TimerSimple(1, function()
            if (not ui:valid(variablePanel)) then return end
            variablePanel.undercolor = false
        end)
    end)
end


--- Handles saving the configuration changes
function SETUP:HandleSave()
    if (not DanLib.ChangedConfig or Table:Count(DanLib.ChangedConfig) <= 0) then return end

    network:Start('DanLib:RequestSaveConfigChanges')
    network:WriteUInt(Table:Count(DanLib.ChangedConfig), 5)

    for k, v in pairs(DanLib.ChangedConfig) do
        network:WriteString(k)
        network:WriteUInt(Table:Count(v), 5)

        for key, val in pairs(v) do
            network:WriteString(key)
            local variableType = base.GetConfigType(k, key)
            base.ProcessTypeValue(variableType, val, true)
        end
    end

    network:SendToServer()
    DanLib.ChangedConfig = nil
    self:Refresh()
    base:TutorialSequence(5, 1)
end


--- Checks for unsaved changes and navigates to the appropriate page.
-- If there are unsaved changes, the function retrieves the first change key and determines which page to jump to.
-- @return nil
function SETUP:CheckForUnsavedChanges()
    -- Checking for unsaved changes
    local hasChanges = DanLib.ChangedConfig and Table:Count(DanLib.ChangedConfig) > 0
    if hasChanges then
        -- Get the first unsaved setting
        local firstKey, firstChange = next(DanLib.ChangedConfig)
        local variableKey = next(firstChange) -- Get the change key
        local pageName, pageIndex = self:GetModuleAndPageIndex(firstKey)

        -- Check if the page index is found
        if pageIndex then
            self:GotoOnPage(pageIndex, variableKey) -- Go to the page with the change
        end
    end
end


--- Think function to check for changes and update button states
function SETUP:Think()
    -- Check for changes and update the state of the buttons
    local hasChanges = DanLib.ChangedConfig and Table:Count(DanLib.ChangedConfig) > 0
    self.cancelButton:SetEnabled(hasChanges)
    self.saveButton:SetEnabled(hasChanges)

    -- Change the cursor depending on the state of the buttons
    if (not hasChanges) then
        self.cancelButton:SetCursor('no') -- Set the cursor to "deny"
        self.saveButton:SetCursor('no') -- Set the cursor to "deny"
    else
        self.cancelButton:SetCursor('hand') -- Set normal cursor
        self.saveButton:SetCursor('hand') -- Set normal cursor
    end
end

SETUP:Register('DanLib.UI.Setup')
