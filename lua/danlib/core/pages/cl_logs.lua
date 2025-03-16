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
local ui = DanLib.UI
local Table = DanLib.Table
local customUtils = DanLib.CustomUtils
local LOGS, _ = DanLib.UiPanel()
local defaultFont = 'danlib_font_20'
local utils = DanLib.Utils


--- Gets the log values from the configuration.
-- @return table: Log values.
function LOGS:GetLOGSValues()
    return base:RetrieveUpdatedVariable('BASE', 'Logs') or DanLib.ConfigMeta.BASE:GetValue('Logs')
end


--- Fills the panel with the required interface components.
function LOGS:FillPanel()
    local width = ui:ClampScaleW(self, 700, 800)
    local height = ui:ClampScaleH(self, 550, 550)

    self:SetHeader('Logs setup')
    self:SetPopupWide(width)
    self:SetExtraHeight(height)
    self:SetSettingsFunc(true, base:L('#help'), nil, function() gui.OpenURL('https://discord.com/channels/849615817355558932/1129356041314914314/1129357663189340172') end)

    self.grid = base.CreateGridPanel(self):CustomUtils()
    self.grid:Pin(FILL, 20)
    self.grid:SetColumns(3)
    self.grid:SetHorizontalMargin(12)
    self.grid:SetVerticalMargin(12)

    -- Updating a panel
    self:Refresh()
end


--- Adds a new log to the list.
function LOGS:AddNewLog()
    local values = self:GetLOGSValues()
    Table:Add(values, { Name = 'New Webhook', Webhook = '', Time = os.time(), Modules = {} })
    base:TutorialSequence(4, 5)
    base:SetConfigVariable('BASE', 'Logs', values)
    self:Refresh()
end


--- Refreshes the panel to show the current logs.
function LOGS:Refresh()
    self.grid:Clear()

    local values = self:GetLOGSValues()
    local sorted = {}

    -- Log sorting
    for k, v in pairs(values) do
        Table:Add(sorted, { k, k })
    end
    Table:SortByMember(sorted, 1, true)

    for _, v in ipairs(sorted) do
        local key = v[1]
        local Panel = self:CreateLogPanel(key, values)
        self.grid:AddCell(Panel, nil, false)
    end


    local addButton = base.CreateUIButton(nil, {
        tall = 45,
        text = {'Add new'},
        click = function(sl)
            self:AddNewLog()
        end
    })
    self.grid:AddCell(addButton, nil, false)
end


--- Creates a panel to display log information.
-- @param key string: Log key.
-- @param values table: Log data.
-- @return Panel: The panel created.
function LOGS:CreateLogPanel(key, values)
    local panel = customUtils.Create()
    panel:PinMargin(TOP, nil, nil, nil, self.Margin10)
    panel:SetTall(45)
    panel:ApplyEvent(nil, function(sl, w, h)
        utils:DrawRect(0, 0, w, h, base:Theme('secondary_dark'))
        utils:DrawDualText(12, h / 2 - 2, values[key].Name, 'danlib_font_18', base:Theme('title'), base:FormatHammerTime(values[key].Time) or '', 'danlib_font_16', base:Theme('text', 150), TEXT_ALIGN_LEFT, nil, w - 30)
    end)

    self:AddLogButtons(panel, key, values)
    return panel
end


--- Adds buttons to the log panel.
-- @param panel Panel: Log panel.
-- @param key string: Log key.
function LOGS:AddLogButtons(panel, key, values)
    local size = 30
    local topMargin = (panel:GetTall() - size) / 2

    local buttons = {
        { Name = base:L('#edit.name'), Icon = DanLib.Config.Materials['#edit'], Col = DanLib.Config.Theme['Blue'], Func = function() self:EditLogName(values, key) end },
        { Name = base:L('#modules'), Icon = DanLib.Config.Materials['Module'], Func = function() self:CreateConfigPopup(key, values) end },
        { Name = 'WebHook', Icon = DanLib.Config.Materials['Link'], Func = function() self:EditWebhook(values, key) end },
        { Name = base:L('#delete'), Icon = DanLib.Config.Materials['Delete'], Col = DanLib.Config.Theme['Red'], Func = function() self:DeleteLog(values, key) end }
    }

    local DButton = base.CreateUIButton(panel, {
        dock_indent = { RIGHT, nil, topMargin, topMargin, topMargin },
        wide = size,
        icon = { DanLib.Config.Materials['Edit'], 16 },
        tooltip = { base:L('#edit'), nil, nil, TOP },
        click = function(sl)
            local menu = base:UIContextMenu()
            for _, v in ipairs(buttons) do
                menu:Option(v.Name, v.Col or nil, v.Icon, v.Func)
            end

            local mouse_x = gui.MouseX()
            local mouse_y = gui.MouseY()
            menu:Open(mouse_x + 30, mouse_y - 24, button)
        end
    })
end


--- Edits the log name.
-- @param log table: Log data.
-- @param key string: Log key.
function LOGS:EditLogName(values, key)
    base:RequestTextPopup(base:L('#webhook.name'), base:L('#webhook.name.description'), values[key].Name, nil, function(name)
        values[key].Name = name
        base:TutorialSequence(4, 6)
        base:SetConfigVariable('BASE', 'Logs', values)
    end)
end


--- Removes the log from the list.
-- @param key string: Log key.
function LOGS:DeleteLog(values, key)
    base:QueriesPopup(base:L('#deletion'), base:L('#deletion.description'), nil, function()
        local values = self:GetLOGSValues()
        values[key] = nil
        base:TutorialSequence(4, 6)
        base:SetConfigVariable('BASE', 'Logs', values)
        self:Refresh()
    end)
end


local function isValidWebhook(url)
    return url:lower():gsub('discordapp%.com', 'discord%.com'):find('^https://discord%.com/api/webhooks/%d+/.-') ~= nil
end


--- Edits the webhook URL.
-- @param log table: Log data.
-- @param key string: Log key.
function LOGS:EditWebhook(values, key)
    base:RequestTextPopup(base:L('#webhook.url'), base:L('#webhook.url.Description'), values[key].Webhook, nil, function(webhook)
        values[key].Webhook = webhook
        base:TutorialSequence(4, 6)
        base:SetConfigVariable('BASE', 'Logs', values)
    end, nil, nil, isValidWebhook)
end


--- Creates a configuration popup for the module.
-- @param key string: Log key.
-- @param values table: Log data.
function LOGS:CreateConfigPopup(key, values)
    if ui:valid(Container) then return end
    local Changed = false

    Container = vgui.Create('DanLib.UI.PopupBasis')
    Container:SetHeader('Module Configuration')
    local x, y = 650, 400
    Container:SetPopupWide(x)
    Container:SetExtraHeight(y)
    Container.OnClose = function()
        if Changed then
            base:SetConfigVariable('BASE', 'Logs', values)
            self:Refresh()
        end
    end

    self:CreatePopupTitle(Container, '#SelectWebhook')

    local fieldsBack = customUtils.Create(Container, 'DanLib.UI.Scroll')
    fieldsBack:Pin(FILL, 5)
    fieldsBack:ToggleScrollBar()

    self:CreateModuleCheckboxes(fieldsBack, key, values)
end


--- Creates a title for the popup window.
-- @param parent Panel: Parent Panel.
-- @param titleKey string: Title key.
function LOGS:CreatePopupTitle(parent, titleKey)
    local title = utils:TextWrap(base:L(titleKey), defaultFont, 500)
    local title_w, title_y = utils:GetTextSize(title, defaultFont)

    local titlePanel = customUtils.Create(parent)
    titlePanel:Pin(TOP, 2)
    titlePanel:SetTall(title_y)
    titlePanel:ApplyEvent(nil, function(sl, w, h)
        draw.DrawText(title, defaultFont, w / 2, 4, base:Theme('text'), TEXT_ALIGN_CENTER)
    end)
end


--- Creates checkboxes for modules in the popup window.
-- @param parent Panel: Parent panel for the checkboxes.
-- @param key string: Log key.
-- @param values table: Log data.
function LOGS:CreateModuleCheckboxes(parent, key, values)
    local sortedConfig = {}
    for k, v in pairs(DanLib.ModulesMetaLogs) do
        Table:Add(sortedConfig, {v.Sort, k})
    end
    Table:SortByMember(sortedConfig, 1, true)

    for _, v in ipairs(sortedConfig) do
        local moduleKey = v[2]
        local moduleLog = DanLib.ModulesMetaLogs[moduleKey]

        local panel = customUtils.Create(parent)
        panel:PinMargin(TOP, 10, 10, 10)
        panel:ApplyShadow(10, false, 8)
        panel:SetTall(45)
        panel:ApplyEvent(nil, function(sl, w, h)
            local decor = moduleLog.Color or base:Theme('decor')
            utils:DrawRoundedBox(0, 0, w, h, base:Theme('secondary_dark'))
            utils:DrawRect(0, 0, 2, h, decor)
            utils:DrawDualText(10, h / 2 - 2, moduleKey, defaultFont, decor, moduleLog.Description, 'danlib_font_18', base:Theme('text', 100), TEXT_ALIGN_LEFT, nil, w - 60)
        end)

        local CheckBox = base.CreateCheckbox(panel)
        CheckBox:PinMargin(RIGHT, nil, 8, 10, 8)
        CheckBox:SetWide(30)
        CheckBox:SetValue(values[key].Modules[moduleKey] or false)
        CheckBox:DisableShadows(10)

        function CheckBox:OnChange(value)
            values[key] = values[key] or {}
            values[key].Modules[moduleKey] = value
            base:TutorialSequence(4, 6)
            base:SetConfigVariable('BASE', 'Logs', values)
        end
    end
end

LOGS:SetBase('DanLib.UI.PopupBasis')
LOGS:Register('DanLib.UI.Logs')





local function isValidWebhook(url)
    return url:lower():gsub('discordapp%.com', 'discord%.com'):find('^https://discord%.com/api/webhooks/%d+/.-') ~= nil
end

-- Examples of tests
local testUrls = {
    'https://discord.com/api/webhooks/1234567890/abcdefg', -- valid
    'https://discordapp.com/api/webhooks/1234567890/abcdefg', -- valid (old format)
    'https://example.com/api/webhooks/1234567890/abcdefg', -- invalid
    'https://discord.com/api/invalid/1234567890/abcdefg', -- invalid
    'https://discord.com/api/webhooks/1234567890', -- valid (but without token)
}

-- for _, url in ipairs(testUrls) do
--     print(url, '->', isValidWebhook(url))
-- end
