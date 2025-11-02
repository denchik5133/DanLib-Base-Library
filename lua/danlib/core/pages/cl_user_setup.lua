/***
 *   @component     DanLib User Settings Panel
 *   @version       1.2.0
 *   @file          cl_user_setup.lua
 *   @author        denchik
 *   @contact       Discord: denchik_gm
 *                  Steam: https://steamcommunity.com/profiles/76561198405398290/
 *                  GitHub: https://github.com/denchik5133
 *                
 *   @description   Dynamic user configuration panel for DanLib framework with collapsible
 *                  categories, multiple input types (int, string, bool, key, custom), and
 *                  automatic saving. Provides visual interface for managing module settings
 *                  with real-time validation and tooltips.
 *
 *   @part_of       DanLib v3.0.0 and higher
 *                  https://github.com/denchik5133/danlib
 *
 *   @features      - Collapsible category system with smooth animations
 *                  - Multiple setting types (Int, String, Bool, Key, Table, Custom)
 *                  - Real-time auto-save on change
 *                  - Reset individual settings or entire module
 *                  - Help tooltips for complex settings
 *                  - Custom action buttons per setting
 *                  - Sorted module display by priority
 *                  - Key binding validation with banned keys
 *                  - ComboBox support for enum values
 *                  - Custom VGUI element integration
 *
 *   @dependencies  - DanLib.Func (DBase)
 *                  - DanLib.UI
 *                  - DanLib.Utils (DUtils)
 *                  - DanLib.Table (DTable)
 *                  - DanLib.Network
 *                  - DanLib.CustomUtils
 *                  - DanLib.Config.Materials
 *
 *   @performance   - Cached sorted configuration list
 *                  - Pre-calculated text sizes for buttons
 *                  - Cached theme colors globally
 *                  - Optimized draw calls in category headers
 *                  - Reduced closure allocations
 *                  - Direct input control updates without panel recreation
 *
 *   @license       MIT License
 *   @notes         Requires DanLib.UserModules to be populated with module configurations.
 *                  Settings are automatically persisted to data/danlib/userconfig.txt
 */

-- Cache DanLib modules
local DBase = DanLib.Func
local DUtils = DanLib.Utils
local DTable = DanLib.Table
local DCustomUtils = DanLib.CustomUtils.Create
local DMaterials = DanLib.Config.Materials
local DanLibType = DanLib.Type
local USERCONFIG = DanLib.USERCONFIG

-- Cache standard Lua functions
local _pairs, _ipairs = pairs, ipairs
local ColorAlpha = ColorAlpha
local SimpleText = draw.SimpleText
local color_white = color_white
local TEXT_ALIGN_LEFT = TEXT_ALIGN_LEFT
local TEXT_ALIGN_CENTER = TEXT_ALIGN_CENTER
local _Lerp = Lerp
local _FrameTime = FrameTime
local _IsValid = IsValid

-- Cache DanLib Config
local Theme = DanLib.Config.Theme

-- PAGE CONFIGURATION
local SETUP = DBase.CreatePage('User')
SETUP:SetOrder(2)
SETUP:SetIcon('bQldJcj')
SETUP:SetKeyboardInput(true)

function SETUP:Create(parent)
    DanLib.LoadUserConfig()
    local settings = parent:Add('DanLib.UI.UserSetup')
    settings:Dock(FILL)
end

-- MAIN SETUP PANEL
local ui = DanLib.UI
local SETUP_PANEL = DanLib.UiPanel()

function SETUP_PANEL:Init()
    self.sortedConfigCache = nil
    self.defaultFont = 'danlib_font_18'
    self.themeCache = {}
    
    self:CacheThemeColors()
    self:TopHeader()
    
    self.scroll = DCustomUtils(self, 'DanLib.UI.Scroll')
    self.scroll:Pin()
    
    self:Refresh()
end

-- Cache all theme colors once
function SETUP_PANEL:CacheThemeColors()
    self.themeCache = {
        secondary_dark = DBase:Theme('secondary_dark'),
        secondary = DBase:Theme('secondary'),
        secondary_150 = DBase:Theme('secondary', 150),
        secondary_50 = DBase:Theme('secondary', 50),
        mat_150 = DBase:Theme('mat', 150),
        mat_100 = DBase:Theme('mat', 100),
        decor = DBase:Theme('decor'),
        text = DBase:Theme('text'),
        yellow = Theme['Yellow'],
        yellow_60 = ColorAlpha(Theme['Yellow'], 60)
    }
end

function SETUP_PANEL:TopHeader()
    local cache = self.themeCache
    local settingsText = DBase:L('#settings')
    local settingsDesc = DBase:L('#settings.description')
    
    self.header = DCustomUtils(self)
    self.header:Pin(TOP)
    self.header:DockMargin(0, 0, 0, 12)
    self.header:SetTall(46)
    self.header:ApplyShadow(10, false)
    
    local icon = 24
    local iconMargin = 14
    
    self.header:ApplyEvent(nil, function(sl, w, h)
        DUtils:DrawRoundedBox(0, 0, w, h, cache.secondary_dark)
        DUtils:DrawIcon(iconMargin, h * .5 - icon * 0.5, icon, icon, 'bQldJcj', cache.mat_150)
        DUtils:DrawDualText(iconMargin * 3.5, h * 0.5 - 2, settingsText, 'danlib_font_20', cache.decor, settingsDesc, self.defaultFont, cache.text, TEXT_ALIGN_LEFT, nil, w - 300)
    end)

    self.resetAllButton = self:CreateButton('Reset All', function()
        self:ResetAll()
    end)
end

function SETUP_PANEL:ResetAll()
    for _, module in _pairs(DanLib.UserModules) do
        module:ResetAll()
    end
    self.sortedConfigCache = nil
    self:Refresh()
end

function SETUP_PANEL:CreateButton(name, onClick)
    local buttonSize = DUtils:TextSize(name, self.defaultFont).w
    return DBase.CreateUIButton(self.header, {
        background = { nil },
        dock_indent = { RIGHT, nil, 7, 6, 7 },
        wide = 14 + buttonSize,
        hover = { self.themeCache.yellow_60, nil, 6 },
        text = { name, nil, nil, nil, self.themeCache.yellow },
        click = onClick
    })
end

function SETUP_PANEL:GetSortedConfig()
    if not self.sortedConfigCache then
        self.sortedConfigCache = {}
        for k, v in _pairs(DanLib.UserModules) do
            DTable:Add(self.sortedConfigCache, { v.SortOrder, k })
        end
        DTable:SortByMember(self.sortedConfigCache, 1, false)
    end
    return self.sortedConfigCache
end

function SETUP_PANEL:Refresh()
    self.scroll:Clear()
    local sortedConfig = self:GetSortedConfig()
    local cache = self.themeCache
    
    local iconSize = 18
    local borderH = 35

    for _, config in _pairs(sortedConfig) do
        local moduleKey = config[2]
        local module = DanLib.UserModules[moduleKey]
        local colorExpanded = module.Color or color_white
        local colorExpanded100 = ColorAlpha(colorExpanded, 100)

        local category = DCustomUtils(self.scroll, 'DCollapsibleCategory')
        category:SetLabel('')
        category:PinMargin(TOP, nil, nil, 4, 10)
        category:ApplyClearPaint()
        category:SetHeaderHeight(borderH)
        category:SetExpanded(true)
        category.Header:CustomUtils()
        
        local moduleTitle = module.Title or 'Untitled'
        
        category.Header:ApplyEvent(nil, function(sl, w, h)
            local expanded = category:GetExpanded()
            local tomColor = expanded and colorExpanded or colorExpanded100
            
            sl.deg = _Lerp(_FrameTime() * 15, sl.deg or 0, expanded and 0 or 180)
            
            DUtils:DrawRoundedBox(0, 0, w, h, cache.secondary)
            DUtils:DrawRoundedMask(6, 0, 0, w, h, function()
                DUtils:DrawRoundedBox(0, 0, 3, h, tomColor)
            end)
            DUtils:DrawIconRotated(w - 20, h * 0.5, iconSize, iconSize, sl.deg, DMaterials['Arrow'], tomColor)
            SimpleText(moduleTitle, 'danlib_font_18', 14, h * 0.5, tomColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end)

        local categoryContent = DCustomUtils()
        category:SetContents(categoryContent)
        
        for _, val in _ipairs(module:GetSorted()) do
            self:CreateSettingRow(categoryContent, module, val)
        end
    end
end

function SETUP_PANEL:CreateSettingRow(parent, module, val)
    local headerH = 50
    local cache = self.themeCache
    local settingName = val.Name or 'Unnamed'
    local settingDesc = val.Description or ''
    
    local variablePanel = DCustomUtils(parent)
    variablePanel:Pin(TOP)
    variablePanel:SetTall(headerH)
    variablePanel:PinMargin(TOP, 2, 8, 4)
    
    -- Pre-calculate input width
    local inputWidth = 300
    if val.Type == DanLibType.Int or val.Type == DanLibType.String then
        inputWidth = 270
    elseif val.Type == DanLibType.Bool then
        inputWidth = 105
    end
    
    local actionButtonWidth = val.Action and 42 or 0
    
    variablePanel:ApplyEvent(nil, function(sl, w, h)
        DUtils:DrawRoundedBox(0, 0, w, h, cache.secondary_150)
        local margin = w - inputWidth - actionButtonWidth
        DUtils:DrawDualText(10, 25, settingName, self.defaultFont, cache.decor, settingDesc, self.defaultFont, cache.text, TEXT_ALIGN_LEFT, nil, margin)
    end)

    if val.HelpText then
        local x = DUtils:TextSize(settingName, self.defaultFont).w
        local helpPanel = DCustomUtils(variablePanel)
        helpPanel:SetPos(x + 14, 6)
        helpPanel:SetSize(14, 14)
        helpPanel:ApplyTooltip(val.HelpText, nil, nil, TOP)
        helpPanel:ApplyEvent(nil, function(sl, w, h)
            DUtils:DrawIcon(0, 0, w, h, DMaterials['Help'] or DMaterials['Info'], cache.mat_100)
        end)
    end

    local inputControl = nil
    local moduleID = module.ID
    local valKey = val.Key
    
    -- Reset callback
    self:CreateResetButton(variablePanel, function()
        USERCONFIG[moduleID][valKey] = val.Default
        DanLib.SaveUserConfig()
        
        if _IsValid(inputControl) then
            local defaultValue = val.Default
            
            if val.GetOptions then
                inputControl:SetValue(defaultValue)
            elseif (val.Type == DanLibType.Int) then
                inputControl:SetValue(defaultValue or 0)
            elseif (val.Type == DanLibType.String) then
                inputControl:SetValue(defaultValue or '')
            elseif (val.Type == DanLibType.Bool) then
                inputControl:SetValue(defaultValue or false)
            elseif (val.Type == DanLibType.Key) then
                local resetBind = DBase:ProcessBind(defaultValue, val.bannedKeys or {})
                inputControl:SetValue(resetBind or 'NONE')
            end
        end
    end)
    
    local wide = 200
    local margiMoveToRight = 15
    local margin = 10

    -- Optimized onChange callback
    local function onChangeCallback(newValue)
        USERCONFIG[moduleID][valKey] = newValue
        DanLib.SaveUserConfig()
    end

    if val.GetOptions then
        local options = val.GetOptions()
        local comboSelect = DBase.CreateUIComboBox(variablePanel)
        comboSelect:PinMargin(RIGHT, nil, margin, margiMoveToRight, margin)
        comboSelect:SetWide(wide)
        comboSelect:SetValue(module:GetValue(valKey))
        comboSelect:DisableShadows()
        
        inputControl = comboSelect
        
        local currentValue = module:GetValue(valKey)
        for k, v in _pairs(options) do
            comboSelect:AddChoice(v, k, currentValue == k)
        end
        
        comboSelect:ApplyEvent('OnSelect', function(_, index, value, data)
            onChangeCallback(data)
        end)
    elseif val.Type == DanLibType.Table and val.VguiElement then
        DBase.CreateUIButton(variablePanel, {
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
    elseif val.Type == DanLibType.Int then
        local numberWang = DBase.CreateNumberWang(variablePanel)
        numberWang:PinMargin(RIGHT, nil, margin, margiMoveToRight, margin)
        numberWang:SetWide(wide)
        numberWang:SetHighlightColor(cache.secondary_50)
        numberWang:SetValue(module:GetValue(valKey))
        numberWang:DisableShadows()
        
        inputControl = numberWang

        if (val.Min and val.Max) then
            numberWang:SetMinMax(val.Min, val.Max)
        end

        numberWang:ApplyEvent('OnValueChanged', function(sl)
            onChangeCallback(sl:GetValue())
        end)
    elseif val.Type == DanLibType.String then
        local textEntry = DBase.CreateTextEntry(variablePanel)
        textEntry:PinMargin(RIGHT, nil, margin, margiMoveToRight, margin)
        textEntry:SetWide(wide)
        textEntry:SetHighlightColor(cache.secondary_50)
        textEntry:SetValue(module:GetValue(valKey) or '')
        textEntry:DisableShadows()
        
        inputControl = textEntry
        
        textEntry:ApplyEvent('OnChange', function(sl)
            onChangeCallback(sl:GetValue())
        end)
    elseif val.Type == DanLibType.Bool then
        local checkBox = DBase.CreateCheckbox(variablePanel)
        checkBox:PinMargin(RIGHT, nil, margin, margiMoveToRight, margin)
        checkBox:SetWide(32)
        checkBox:SetValue(module:GetValue(valKey))
        checkBox:DisableShadows()
        
        inputControl = checkBox
        
        checkBox:ApplyEvent('OnChange', function(_, value)
            onChangeCallback(value)
        end)
    elseif val.Type == DanLibType.Key then
        local binder = DBase.CreateUIBinder(variablePanel)
        binder:PinMargin(RIGHT, nil, margin, margiMoveToRight, margin)
        binder:Help()
        binder:SetWide(wide)
        binder:DisableShadows()
        
        inputControl = binder
        
        local bannedBind = val.bannedKeys or {}
        local gvalBind = DBase:ProcessBind(module:GetValue(valKey), bannedBind)
        binder:SetValue(gvalBind)
        
        function binder:OnChange(value)
            local valBind = DBase:ProcessBind(value, bannedBind)
            if valBind == 'NONE' then
                DBase:ScreenNotification(DBase:L('#key.bind.forbidden'), DBase:L('#key.bind.binding'), 'ERROR')
                binder:SetValue(gvalBind)
            else
                gvalBind = valBind
                onChangeCallback(valBind)
            end
        end
    end

    if val.Action then
        self:CreateActionButton(variablePanel, val)
    end

    return variablePanel
end

function SETUP_PANEL:CreateResetButton(variablePanel, onReset)
    return DBase.CreateUIButton(variablePanel, {
        dock_indent = { RIGHT, nil, 10, 15 - 4, 10 },
        wide = 32,
        icon = { DMaterials['Reset'] },
        tooltip = { DBase:L('#resetting.changes'), nil, nil, TOP },
        click = onReset
    })
end

function SETUP_PANEL:CreateActionButton(variablePanel, val)
    DBase.CreateUIButton(variablePanel, {
        dock_indent = { RIGHT, nil, 10, 15 - 4, 10 },
        wide = 32,
        icon = { DMaterials['Action'] or DMaterials['Settings'] },
        tooltip = { val.ActionTooltip or 'Action', nil, nil, TOP },
        click = function()
            if val.Action then
                val.Action()
            end
        end
    })
end

SETUP_PANEL:Register('DanLib.UI.UserSetup')
