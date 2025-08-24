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



local DBase = DanLib.Func
local DUtils = DanLib.Utils
local DTable = DanLib.Table
local DNetwork = DanLib.Network
local DCustomUtils = DanLib.CustomUtils.Create
local DMaterials = DanLib.Config.Materials

local string = string
local table = table
local count = table.Count

local SETUP = DBase.CreatePage('User')
SETUP:SetOrder(2)
SETUP:SetIcon('bQldJcj')
SETUP:SetKeyboardInput(true)


--- Creates a settings panel.
-- @param parent Panel The parent panel to which the settings panel will be added.
function SETUP:Create(parent)
    DanLib.LoadUserConfig()
    local settings = parent:Add('DanLib.UI.UserSetup')
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


    self.scroll = DCustomUtils(self, 'DanLib.UI.Scroll')
    self.scroll:Pin()

    self:Refresh() -- Interface update
end


--- Creates the top header of the panel
function SETUP:TopHeader()
    self.header = DCustomUtils(self)
    self.header:Pin(TOP)
    self.header:DockMargin(0, 0, 0, 12)
    self.header:SetTall(46)
    self.header:ApplyShadow(10, false)
    self.header.icon = 24
    self.header.iconMargin = 14
    self.header:ApplyEvent(nil, function(sl, w, h)
        DUtils:DrawRoundedBox(0, 0, w, h, DBase:Theme('secondary_dark'))
        DUtils:DrawIcon(sl.iconMargin, h * .5 - sl.icon * 0.5, sl.icon, sl.icon, 'bQldJcj', DBase:Theme('mat', 150))
        DUtils:DrawDualText(sl.iconMargin * 3.5, h / 2 - 2, DBase:L('#settings'), 'danlib_font_20', DBase:Theme('decor'), DBase:L('#settings.description'), self.defaultFont, DBase:Theme('text'), TEXT_ALIGN_LEFT, nil, w - 300)
    end)

    -- Defining the buttons for saving and cancelling
    self.resetAllButton = self:CreateButton('Reset All', function()
        self:ResetAll()
    end)
end


--- Resets all settings for the current module
function SETUP:ResetAll()
    for _, module in pairs(DanLib.UserModules) do
        module:ResetAll()
    end
    self:Refresh()
end


--- Creates a button in the header
-- @param name: string The name of the button
-- @param color: Color The color of the button
-- @param onClick: function The function to call when the button is clicked
-- @return DButton: The created button
function SETUP:CreateButton(name, onClick)
    local buttonSize = DUtils:TextSize(name, self.defaultFont).w
    local Button = DBase.CreateUIButton(self.header, {
        background = { nil },
        dock_indent = { RIGHT, nil, 7, 6, 7 },
        wide = 14 + buttonSize,
        hover = { ColorAlpha(DanLib.Config.Theme['Yellow'], 60), nil, 6 },
        text = { name, nil, nil, nil, DanLib.Config.Theme['Yellow'] },
        click = onClick
    })
    return Button
end


--- Gets a sorted configuration
-- @return table: A sorted table of configuration items
function SETUP:GetSortedConfig()
    local sortedConfig = {}
    for k, v in pairs(DanLib.UserModules) do
        DTable:Add(sortedConfig, { v.SortOrder, k })
    end
    DTable:SortByMember(sortedConfig, 1, true) -- Sort by order
    return sortedConfig
end


function SETUP:Refresh()
	self.scroll:Clear()

    local sortedConfig = self:GetSortedConfig()

    -- Add categories and their settings
    for _, config in pairs(sortedConfig) do
        local moduleKey = config[2]
        local module = DanLib.UserModules[moduleKey]

    	local iconSize, borderW, borderH, Margin15 = 18, DBase:Scale(4), 35, DBase:Scale(10)
    	local colorExpanded = module.Color or color_white

        local category = DCustomUtils(self.scroll, 'DCollapsibleCategory')
        category:SetLabel('')
        category:PinMargin(TOP, nil, nil, nil, 10)
        category:ApplyClearPaint()
        category:SetHeaderHeight(borderH)
        category:SetExpanded(true)
        category.Header:CustomUtils()
        category.Header:ApplyEvent(nil, function(sl, w, h)
        	local Expanded = category:GetExpanded()
        	local tomColor = Expanded and colorExpanded or ColorAlpha(colorExpanded, 100)
        	sl.deg = Lerp(FrameTime() * 15, sl.deg or 0, Expanded and 0 or 180)

            DUtils:DrawRoundedBox(0, 0, w, h, DBase:Theme('secondary'))
            DUtils:DrawRoundedMask(6, 0, 0, w, h, function()
            	DUtils:DrawRoundedBox(0, 0, 3, h, tomColor)
            end)

            DUtils:DrawIconRotated(w - 20, h / 2, iconSize, iconSize, sl.deg, DMaterials['Arrow'], tomColor)
            draw.SimpleText(module.Title or 'Untitled', 'danlib_font_18', 14, h / 2, tomColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end)

        local categoryContent = vgui.Create('DPanel')
        categoryContent:SetPaintBackground(false)
        category:SetContents(categoryContent)
        
        for _, val in ipairs(module:GetSorted()) do
            self:CreateSettingRow(categoryContent, module, val, val.Key, function(newValue)
                DanLib.USERCONFIG[module.ID][val.Key] = newValue
                DanLib.SaveUserConfig()
            end, function()
                DanLib.USERCONFIG[module.ID][val.Key] = val.Default
                DanLib.SaveUserConfig()
            end)
        end
    end
end


-- Setting row component
function SETUP:CreateSettingRow(parent, module, val, Key, onChange, onReset)
    local headerH = 50
    local customElement = val.Type == DanLib.Type.Table and val.VguiElement

    local variablePanel = DCustomUtils(parent)
    variablePanel:Pin(TOP)
    variablePanel:SetTall(headerH)
    variablePanel:PinMargin(TOP, 2, 8, 4)
    variablePanel:ApplyEvent(nil, function(sl, w, h)
        DUtils:DrawRoundedBox(0, 0, w, h, DBase:Theme('secondary', 150))

        -- The size of the input element by type
        local inputWidth = 300
        if (val.Type == DanLib.Type.Int or val.Type == DanLib.Type.String) then
            inputWidth = 270
        elseif (val.Type == DanLib.Type.Bool) then
            inputWidth = 105
        end

        -- Size of the action button (if any)
        local actionButtonWidth = 0
        if val.Action then
            actionButtonWidth = 32 + 10 -- 32px button + 10px indentation
        end

        -- The total width of the text is subtracted from the total width of the input field, the button, and the margins.
        local margin = w - inputWidth - actionButtonWidth
        DUtils:DrawDualText(10, headerH / 2 - 2, val.Name or nil, self.defaultFont, DBase:Theme('decor'), val.Description or nil, self.defaultFont, DBase:Theme('text'), TEXT_ALIGN_LEFT, nil, margin)
    end)

    -- Add help text tooltip functionality if HelpText is provided
    if val.HelpText then
        local x = DUtils:TextSize(val.Name, self.defaultFont).w
        local HelpPanel = DCustomUtils(variablePanel)
        HelpPanel:SetPos(x + 14, 6)
        HelpPanel:SetSize(14, 14)
        HelpPanel:ApplyTooltip(val.HelpText, nil, nil, TOP)
        HelpPanel:ApplyEvent(nil, function(sl, w, h)
            DUtils:DrawIcon(0, 0, w, h, DMaterials['Help'] or DMaterials['Info'], DBase:Theme('mat', 100))
        end)
    end

    self:CreateResetButton(variablePanel, onReset)
    local wide, margiMoveToRight, margin = 200, 15, (variablePanel:GetTall() - 30) * 0.5 -- indentation

    -- Processing different types of variables
    if (customElement or val.GetOptions) then
        if val.GetOptions then
            local options = val.GetOptions()
            local comboSelect = DBase.CreateUIComboBox(variablePanel)
            comboSelect:PinMargin(RIGHT, nil, margin, margiMoveToRight, margin)
            comboSelect:SetWide(wide)
            comboSelect:SetValue(module:GetValue(val.Key))
            comboSelect:DisableShadows()
            local currentValue = module:GetValue(val.Key)
            for k, v in pairs(options) do
                comboSelect:AddChoice(v, k, currentValue == k)
            end
            comboSelect:ApplyEvent('OnSelect', function(_, index, value, data)
                onChange(value)
            end)
        else
            local button = DBase.CreateUIButton(variablePanel, {
                dock_indent = { RIGHT, nil, margin, margiMoveToRight, margin },
                wide = 32,
                icon = { DMaterials['Edit'] },
                tooltip = { DBase:L('#edit'), nil, nil, TOP },
                click = function(sl)
                    if ui:valid(sl.con) then
                        sl.con:Remove()
                        return
                    end
                    local Container = DCustomUtils(nil, val.VguiElement)
                    sl.con = Container
                    Container:FillPanel()
                end
            })
        end
    elseif (val.Type == DanLib.Type.Int) then
        local numberWang = DBase.CreateNumberWang(variablePanel)
        numberWang:PinMargin(RIGHT, nil, margin, margiMoveToRight, margin)
        numberWang:SetWide(wide)
        numberWang:SetHighlightColor(DBase:Theme('secondary', 50))
        numberWang:SetValue(module:GetValue(val.Key))
        numberWang:DisableShadows()

        -- Set the minimum and maximum values, if specified
        if (val.Min ~= nil and val.Max ~= nil) then
            numberWang:SetMinMax(val.Min, val.Max)
        end

        numberWang:ApplyEvent('OnValueChanged', function(sl)
            onChange(sl:GetValue())
        end)
    elseif (val.Type == DanLib.Type.String) then
        local textEntry = DBase.CreateTextEntry(variablePanel)
        textEntry:PinMargin(RIGHT, nil, margin, margiMoveToRight, margin)
        textEntry:SetWide(wide)
        textEntry:SetHighlightColor(DBase:Theme('secondary', 50))
        textEntry:SetValue(module:GetValue(val.Key) or '')
        textEntry:DisableShadows()
        textEntry:ApplyEvent('OnChange', function(sl)
            onChange(sl:GetValue())
        end)
    elseif (val.Type == DanLib.Type.Bool) then
        local CheckBox = DBase.CreateCheckbox(variablePanel)
        CheckBox:PinMargin(RIGHT, nil, margin, margiMoveToRight, margin)
        CheckBox:SetWide(32)
        CheckBox:SetValue(module:GetValue(val.Key))
        CheckBox:DisableShadows()
        CheckBox:ApplyEvent('OnChange', function(_, value)
            onChange(value)
        end)
    elseif (val.Type == DanLib.Type.Key) then
        local binder = DBase.CreateUIBinder(variablePanel)
        binder:PinMargin(RIGHT, nil, margin, margiMoveToRight, margin)
        binder:Help()
        binder:SetWide(wide)
        binder:DisableShadows()
        local dbanedBind = val.bannedKeys or {}
        local gvalBind = DBase:ProcessBind(module:GetValue(val.Key), dbanedBind)
        binder:SetValue(gvalBind)
        function binder:OnChange(value)
            local valBind = DBase:ProcessBind(value, dbanedBind)
            if (valBind == 'NONE') then
                DBase:ScreenNotification(DBase:L('#key.bind.forbidden'), DBase:L('#key.bind.binding'), 'ERROR')
                binder:SetValue(gvalBind) -- Return the previous value if the new value is invalid
            else
                onChange(valBind) -- If binding is allowed, call onChange
            end
        end
    end

    -- Checking if there is an action
    if val.Action then
        self:CreateActionButton(variablePanel, val)
    end

    return variablePanel
end


--- Creates an action button for a variable panel
-- @param variablePanel Panel: The variable panel to add the action button to
-- @param val table: The variable configuration
function SETUP:CreateActionButton(variablePanel, val)
    local button = DBase.CreateUIButton(variablePanel, {
        dock_indent = { RIGHT, nil, 10, 15 - 4, 10 },
        wide = 32,
        icon = { DMaterials['Info'] },
        tooltip = {'Read More', nil, nil, TOP },
        click = function()
            if (type(val.Action) == 'function') then
                val.Action()  -- If it is a function, call it
            elseif (type(val.Action) == 'string') then
                DCustomUtils(nil, val.Action)  -- Register an item with vgui
            end
        end
    })
end


function SETUP:CreateResetButton(variablePanel, onReset)
    local button = DBase.CreateUIButton(variablePanel, {
        dock_indent = { RIGHT, nil, 10, 15 - 4, 10 },
        wide = 32,
        icon = { DMaterials['Reset'] },
        tooltip = { DBase:L('#resetting.changes'), nil, nil, TOP },
        click = function()
            onReset()
            self:Refresh()
        end
    })
end


SETUP:Register('DanLib.UI.UserSetup')
