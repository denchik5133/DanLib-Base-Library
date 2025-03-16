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
local utils = DanLib.Utils
local NPC, _ = DanLib.UiPanel()


--- Adds a new NPC to the list.
function NPC:addNew()
    local values = self:GetNPCValues()
    Table:Add(values, {
        Name = 'New NPC',
        FuncType = 'NPC',
        Model = 'models/breen.mdl',
        Animation = 'idle_all_scared',
        Time = os.time()
    })

    base:TutorialSequence(4, 3)
    base:SetConfigVariable('BASE', 'NPCs', values)
    self:Refresh()
end


--- Refreshes the panel, updating the displayed NPCs.
function NPC:Refresh()
    self.grid:Clear()

    local values = self:GetNPCValues()
    -- Create buttons and populate the NPC list
    self:PopulateNPCList(values)
end


--- Retrieves the current NPC values.
-- @return table: The current NPC values.
function NPC:GetNPCValues()
    return base:RetrieveUpdatedVariable('BASE', 'NPCs') or DanLib.ConfigMeta.BASE:GetValue('NPCs')
end


--- Fills the panel with necessary UI components.
function NPC:FillPanel()
    local width = ui:ClampScaleW(self, 700, 800)
    local height = ui:ClampScaleH(self, 550, 550)

    self:SetHeader('NPC')
    self:SetPopupWide(width)
    self:SetExtraHeight(height)

    self.grid = base.CreateGridPanel(self)
    self.grid:Pin(FILL, 16)
    self.grid:SetColumns(4)
    self.grid:SetHorizontalMargin(10)
    self.grid:SetVerticalMargin(10)

    self:Refresh()
end


--- Populates the NPC list in the scroll panel.
-- @param values table: The current NPC values.
function NPC:PopulateNPCList(values)
    -- Sort and iterate through NPC values
    local sorted = {}
    for k, v in pairs(values) do
        Table:Add(sorted, k)
    end
    Table:Sort(sorted)

    local panelH = 58
    for key, v in pairs(values) do
        self:CreateNPCPanel(key, v, panelH)
    end

    self:CreateAddButton()
end


--- Creates a panel for a specific NPC.
-- @param key string: The key of the NPC.
-- @param ConfigNPC table: The configuration data for the NPC.
-- @param panelH number: The height of the panel.
function NPC:CreateNPCPanel(key, ConfigNPC, panelH)
    local BasePanel = DanLib.CustomUtils.Create()
    BasePanel:SetTall(250)
    BasePanel:ApplyEvent(nil, function(sl, w, h)
        utils:DrawRect(0, 0, w, h, base:Theme('secondary_dark'))
        self:DrawNPCDetails(ConfigNPC, key, h, base:Scale(6))
    end)
    self.grid:AddCell(BasePanel, nil, false)
    -- Create model panel
    self:CreateModelPanel(BasePanel, ConfigNPC)
    -- Create action buttons for Edit and Delete
    self:CreateActionButtons(BasePanel, key, ConfigNPC)
end


--- Draws the details of the NPC in the panel.
-- @param ConfigNPC table: The configuration data for the NPC.
-- @param key string: The key of the NPC.
-- @param h number: The height of the panel.
-- @param H number: The height offset for text.
function NPC:DrawNPCDetails(ConfigNPC, key, h, H)
    utils:DrawDualText(h + H, h / 2 - 8, ConfigNPC.Name .. ' - ' .. key, 'danlib_font_20', base:Theme('title'), ConfigNPC.FuncType or 'unknown', 'danlib_font_16', base:Theme('text', 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText(base:FormatHammerTime(ConfigNPC.Time) or 'unknown', 'danlib_font_16', h + H, h / 2 + 16, base:Theme('text'), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end


--- Creates the model panel for the NPC.
-- @param parent Panel: The parent panel for the model.
-- @param ConfigNPC table: The configuration data for the NPC.
function NPC:CreateModelPanel(parent, ConfigNPC)
    local modelH = parent:GetTall() - (2 * base:Scale(10))
    local Panel = base:CreateModelPanel(parent)
    Panel:Pin(FILL, 5)
    Panel:SetCursor('pointer')
    Panel.ModelPanel:SetFOV(110)
    Panel.ModelPanel:SetModelNPC(ConfigNPC.Model)
end


--- Creates a button to add a new rank.
function NPC:CreateAddButton()
    local createNew = base.CreateUIButton(nil, {
        dock_indent = {RIGHT, nil, 7, 6, 7},
        tall = 250,
        text = {'Add a new NPC', nil, nil, nil, base:Theme('text', 200)},
        click = function() self:addNew() end
    })

    self.grid:AddCell(createNew, nil, false)
end


--- Creates action buttons for the NPC panel.
-- @param parent Panel: The parent panel for the buttons.
-- @param key string: The key of the NPC.
-- @param ConfigNPC table: The configuration data for the NPC.
function NPC:CreateActionButtons(parent, key, ConfigNPC)
    local values = self:GetNPCValues()
    local buttons = {
        { Name = base:L('#edit'), Icon = DanLib.Config.Materials['Edit'], Func = function() self:CreateConfigPopup(key, values) end },
        { Name = base:L('#delete'), Icon = DanLib.Config.Materials['Delete'], Func = function() self:ConfirmDelete(key, values) end }
    }

    for _, buttonInfo in ipairs(buttons) do
        local button = base:CreateButton(parent)
        button:Pin(BOTTOM, 4)
        button:SetTall(30)
        button:icon(buttonInfo.Icon, 18)
        button:ApplyTooltip(buttonInfo.Name, nil, nil, TOP)
        button.DoClick = buttonInfo.Func
    end
end


--- Confirms deletion of an NPC.
-- @param key string: The key of the NPC to delete.
function NPC:ConfirmDelete(key, values)
    base:QueriesPopup('DELETION', 'Are you really sure you want to delete this?', nil, function()
        values[key] = nil
        base:SetConfigVariable('BASE', 'NPCs', values)
        self:Refresh()
    end)
end


--- Adds a header to the specified parent panel.
-- @param parent Panel: The parent panel.
-- @param text string: The header text.
-- @return Panel: The created header panel.
function NPC:AddHeader(parent, text)
    text = text or ''

    local headerPnl = DanLib.CustomUtils.Create(parent)
    headerPnl:SetSize(260, 60)
    headerPnl:ApplyShadow(10, false, 8)
    headerPnl:ApplyBackground(base:Theme('panel_background'))
 
    local Ptitle = DanLib.CustomUtils.Create(headerPnl)
    Ptitle:Pin(TOP)
    Ptitle:SetTall(22)
    Ptitle:ApplyEvent(nil, function(sl, w, h)
        utils:DrawRect(0, 0, w, h, base:Theme('panel_line_up'))
        draw.SimpleText(string.upper(text), 'danlib_font_18', 8, h * 0.5, base:Theme('decor'), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end)

    return headerPnl
end


--- Creates a configuration popup for an NPC.
-- @param key string: The key of the NPC.
-- @param values table: The current NPC values.
function NPC:CreateConfigPopup(key, values)
    local Config = values[key]
    self.Config = Config
    local Changed = false

    local function Data(field, value)
        Changed = true
        Config[field] = value
    end

    local width = ui:ClampScaleW(self, 900, 900)
    local height = ui:ClampScaleH(self, 550, 550)

    Container = DanLib.CustomUtils.Create(nil, 'DanLib.UI.PopupBasis')
    Container:SetHeader('NPC setup')
    Container:SetPopupWide(width)
    Container:SetExtraHeight(height)
    Container.OnClose = function()
        if (not Changed) then return end
        base:SetConfigVariable('BASE', 'NPCs', values)
        self:Refresh()
    end

    --- Sets up the model panel in the configuration popup.
    self.model = base:CreateModelPanel(Container)
    self.model:SetPos(305, 45)
    self.model:SetSize(Container:GetWide() / 3.3, Container:GetWide() / 3.65)
    self.model.ModelPanel:SetLookAt(Vector(0, 0, 72 / 2))
    self.model.ModelPanel:SetCamPos(Vector(64, -45, 72 / 2))
    self.model.ModelPanel:SetAmbientLight(Color(10, 15, 50))
    self.model.ModelPanel:SetDirectionalLight(BOX_TOP, Color(220, 190, 100))
    self.model.ModelPanel:SetFOV(58)

    self.modelPanel = self.model.ModelPanel

    self:UpdateModel()
    self:SetupConfigInputs(Container, Config, Data)
end


--- Sets up the input fields in the configuration popup.
-- @param container Panel: The container for the popup.
-- @param Config table: The configuration data for the NPC.
-- @param Data function: The function to handle data changes.
function NPC:SetupConfigInputs(container, Config, Data)
    -- NPC name
    local Name = self:AddHeader(container, 'NPC name')
    Name:SetPos(16, 50)
    local NameEntry = base.CreateTextEntry(Name)
    NameEntry:Pin(FILL, 4)
    NameEntry:SetBackText('Enter value')
    NameEntry:SetValue(Config.Name)
    NameEntry:SetFont('danlib_font_18')
    -- NameEntry:SetHighlightColor(base:Theme('secondary', 50))
    NameEntry:DisableShadows(10)
    NameEntry.OnChange = function(sl, value)
        Config.Name = value
        Data('Name', value)
        self:UpdateModel()
    end

    -- NPC model
    local Model = self:AddHeader(container, 'NPC model')
    Model:SetPos(16, 125)
    local ModelEntry = base.CreateTextEntry(Model)
    ModelEntry:Pin(FILL, 4)
    ModelEntry:SetBackText('Enter value')
    ModelEntry:SetValue(Config.Model or '')
    ModelEntry:SetFont('danlib_font_18')
    ModelEntry:DisableShadows(10)
    ModelEntry.OnChange = function(sl, value)
        Config.Model = value
        Data('Model', value)
        self:UpdateModel()
    end

    -- Function type
    local FunctionType = self:AddHeader(container, 'Function type')
    FunctionType:SetPos(16, 200)
    local comboSelect = base.CreateUIComboBox(FunctionType)
    comboSelect:Pin(FILL, 4)
    -- comboSelect:SetHighlightColor(base:Theme('secondary', 50))
    comboSelect:SetValue(Config.FuncType)
    comboSelect:DisableShadows(10)

    local options = {}
    for k, v in pairs(DanLib.BaseConfig.EntityTypesFunc) do
        options[k] = k
    end

    for k, v in pairs(options) do
        comboSelect:AddChoice(v, k)
    end

    comboSelect.OnSelect = function(s, index, value, data)
        Config.FuncType = value
        Data('FuncType', value)
        self:UpdateModel()
    end

    -- NPC animation
    local Animation = self:AddHeader(container, 'NPC animation')
    Animation:SetPos(16, 280)
    Animation:SetSize(260, 280)
    self:SetupAnimationList(Animation, Config)
end


--- Sets up the animation list in the configuration popup.
-- @param parent Panel: The parent panel for the animation list.
-- @param Config table: The configuration data for the NPC.
function NPC:SetupAnimationList(parent, Config)
    local animList = DanLib.CustomUtils.Create(parent, 'DListView')
    animList:Pin(FILL, 6)
    animList:AddColumn('Animations')

    local npcModel = ClientsideModel(Config.Model or '', RENDERGROUP_OPAQUE)
    npcModel:SetNoDraw(true)

    local animTable = npcModel:GetSequenceList()
    for _, anim in pairs(animTable) do
        animList:AddLine(anim)
    end

    animList.OnRowSelected = function(sl, sIndex, row)
        local animName = sl:GetLine(sIndex):GetValue(1)
        local animIndex = self.modelPanel.Entity:LookupSequence(animName)

        if (animIndex > 0) then
            self.modelPanel.Entity:ResetSequence(animIndex)
            Config.Animation = animName
            self:UpdateModel()
        end
    end
end


--- Updates the model display in the configuration popup.
function NPC:UpdateModel()
    local Config = self.Config
    local weaponModel = Config.Model or ''

    -- ModelPanel validity check
    if (not IsValid(self.modelPanel)) then
        return
    end

    if (weaponModel ~= self.currentModel) then
        self.modelPanel:SetModel(weaponModel)
        local animIndex = self.modelPanel.Entity:LookupSequence(Config.Animation or 'idle')
        if (animIndex > 0) then
            self.modelPanel.Entity:ResetSequence(animIndex)
        end
    end

    self.currentModel = weaponModel
end

NPC:SetBase('DanLib.UI.PopupBasis')
NPC:Register('DDI.UI.ConfigNPC')
