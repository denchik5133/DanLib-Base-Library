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
local ui = DanLib.UI
local DTable = DanLib.Table
local DUtils = DanLib.Utils
local DCustomUtils = DanLib.CustomUtils.Create
local NPC = DanLib.UiPanel()

local _IsValid = IsValid
local _Vector = Vector
local _type = type
local draw = draw
local _drawSimpleText = draw.SimpleText
local string = string
local _strupper = string.upper
local os = os
local _ostime = os.time
local _ErrorNoHalt = ErrorNoHalt
local _ClientsideModel = ClientsideModel
local _SafeRemoveEntity = SafeRemoveEntity

--- Adds a new NPC to the list.
function NPC:addNew()
    local values = self:GetNPCValues()
    
    -- Caching os.time() (called 1 time instead of 2)
    local timestamp = _ostime()
    local newKey = 'npc_' .. timestamp .. '_' .. math.random(1000, 9999)
    
    values[newKey] = {
        Name = 'New NPC',
        FuncType = 'NPC',
        Model = 'models/breen.mdl',
        Animation = 'idle_all_scared',
        Time = timestamp  -- Using a cached value
    }

    DBase:TutorialSequence(4, 3)
    DBase:SetConfigVariable('BASE', 'NPCs', values)
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
    return DBase:RetrieveUpdatedVariable('BASE', 'NPCs') or DanLib.ConfigMeta.BASE:GetValue('NPCs')
end

--- Fills the panel with necessary UI components.
function NPC:FillPanel()
    local width = ui:ClampScaleW(self, 700, 800)
    local height = ui:ClampScaleH(self, 550, 550)

    self:SetHeader('NPC')
    self:SetPopupWide(width)
    self:SetExtraHeight(height)

    self.grid = DBase.CreateGridPanel(self)
    self.grid:Pin(FILL, 16)
    self.grid:SetColumns(4)
    self.grid:SetHorizontalMargin(10)
    self.grid:SetVerticalMargin(10)

    self:Refresh()
end

--- Populates the NPC list in the scroll panel.
-- @param values table: The current NPC values.
function NPC:PopulateNPCList(values)
    if (not values) then
        _ErrorNoHalt('[DanLib.NPC] PopulateNPCList: values is nil\n')
        self:CreateAddButton()
        return
    end
    
    -- Caching the current timestamp for migration
    local currentTime = _ostime()
    local needsSave = false
    
    -- Pre-allocate sorted table with approximate size
    local sorted = {}
    local sortedCount = 0
    
    -- IN ONE pass: validation + sorting
    for key, npc in pairs(values) do
        if (_type(key) == 'string' and _type(npc) == 'table') then
            -- Inline validation (without creating an intermediate validNPCs table)
            npc.Name = npc.Name or ('Unknown NPC ' .. key)
            npc.Model = npc.Model or 'models/breen.mdl'
            npc.FuncType = npc.FuncType or 'NPC'
            npc.Animation = npc.Animation or 'idle_all_scared'
            npc.Time = npc.Time or currentTime
            
            sortedCount = sortedCount + 1
            sorted[sortedCount] = key
            
        elseif (_type(key) == 'number') then
            -- Migration
            _ErrorNoHalt('[DanLib.NPC] Migrating numeric key ' .. key .. '\n')
            local newKey = 'npc_migrated_' .. currentTime .. '_' .. key
            
            if (_type(npc) == 'table') then
                npc.Name = npc.Name or ('Migrated NPC ' .. key)
                npc.Model = npc.Model or 'models/breen.mdl'
                npc.FuncType = npc.FuncType or 'NPC'
                npc.Animation = npc.Animation or 'idle_all_scared'
                npc.Time = npc.Time or currentTime
                
                values[newKey] = npc
                values[key] = nil -- Delete the old key
                
                sortedCount = sortedCount + 1
                sorted[sortedCount] = newKey
                needsSave = true
            end
        end
    end
    
    -- We save it ONLY if there have been changes.
    if needsSave then
        DBase:SetConfigVariable('BASE', 'NPCs', values)
        print('[DanLib.NPC] Migrated ' .. sortedCount .. ' NPCs')
    end
    
    -- Sorting
    DTable:Sort(sorted)

    -- Creating panels
    for i = 1, sortedCount do
        self:CreateNPCPanel(sorted[i], values[sorted[i]], 58)
    end

    self:CreateAddButton()
end

--- Creates a panel for a specific NPC.
-- @param key string: The key of the NPC.
-- @param ConfigNPC table: The configuration data for the NPC.
-- @param panelH number: The height of the panel.
function NPC:CreateNPCPanel(key, ConfigNPC, panelH)
    local BasePanel = DCustomUtils()
    BasePanel:SetTall(250)
    BasePanel:ApplyBackground(DBase:Theme('secondary_dark'), 6)
    BasePanel:ApplyEvent(nil, function(sl, w, h)
        self:DrawNPCDetails(ConfigNPC, key, h, DBase:Scale(6))
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
    if (not ConfigNPC) then
        _ErrorNoHalt('[DanLib.NPC] DrawNPCDetails: ConfigNPC is nil for key: ' .. tostring(key) .. '\n')
        return
    end
    
    -- We cache the formatted time in the Config object itself
    if (not ConfigNPC._cachedTime) then
        ConfigNPC._cachedTime = ConfigNPC.Time and DBase:FormatHammerTime(ConfigNPC.Time) or 'unknown'
    end
    
    -- Caching the combined string
    if (not ConfigNPC._cachedTitle) then
        local name = ConfigNPC.Name or 'Unnamed NPC'
        ConfigNPC._cachedTitle = name .. ' - ' .. tostring(key)
    end
    
    local funcType = ConfigNPC.FuncType or 'unknown'
    DUtils:DrawDualText(h + H,  h / 2 - 8, ConfigNPC._cachedTitle, 'danlib_font_20',  DBase:Theme('title'), funcType, 'danlib_font_16', DBase:Theme('text', 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    _drawSimpleText(ConfigNPC._cachedTime, 'danlib_font_16',  h + H,  h / 2 + 16,  DBase:Theme('text'),  TEXT_ALIGN_LEFT,  TEXT_ALIGN_CENTER)
end

--- Creates the model panel for the NPC.
-- @param parent Panel: The parent panel for the model.
-- @param ConfigNPC table: The configuration data for the NPC.
function NPC:CreateModelPanel(parent, ConfigNPC)
    local modelH = parent:GetTall() - (2 * DBase:Scale(10))
    local Panel = DBase:CreateModelPanel(parent)
    Panel:Pin(FILL, 5)
    Panel:SetCursor('pointer')
    Panel.ModelPanel:SetFOV(110)
    Panel.ModelPanel:SetModelNPC(ConfigNPC.Model)
end

--- Creates a button to add a new rank.
function NPC:CreateAddButton()
    local createNew = DBase.CreateUIButton(nil, {
        dock_indent = { RIGHT, nil, 7, 6, 7 },
        tall = 250,
        text = { 'Add a new NPC', nil, nil, nil, DBase:Theme('text', 200) },
        click = function()
            self:addNew()
        end
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
        { Name = DBase:L('#edit'), Icon = DanLib.Config.Materials['Edit'], Func = function() self:CreateConfigPopup(key, values) end },
        { Name = DBase:L('#delete'), Icon = DanLib.Config.Materials['Delete'], Func = function() self:ConfirmDelete(key, values) end }
    }

    for _, buttonInfo in ipairs(buttons) do
        DBase.CreateUIButton(parent, {
            dock = { BOTTOM, 4 },
            tall = 30,
            icon = { buttonInfo.Icon, 18 },
            tooltip = { buttonInfo.Name, nil, nil, TOP },
            click = buttonInfo.Func
        })
    end
end

--- Confirms deletion of an NPC.
-- @param key string: The key of the NPC to delete.
function NPC:ConfirmDelete(key, values)
    DBase:QueriesPopup('DELETION', 'Are you really sure you want to delete this?', nil, function()
        values[key] = nil
        DBase:SetConfigVariable('BASE', 'NPCs', values)
        self:Refresh()
    end)
end

--- Adds a header to the specified parent panel.
-- @param parent Panel: The parent panel.
-- @param text string: The header text.
-- @return Panel: The created header panel.
function NPC:AddHeader(parent, text)
    text = text or ''

    local headerPnl = DCustomUtils(parent)
    headerPnl:SetSize(260, 60)
    headerPnl:ApplyShadow(10, false, 8)
    headerPnl:ApplyBackground(DBase:Theme('secondary'), 6)
 
    local ptitle = DCustomUtils(headerPnl)
    ptitle:Pin(TOP)
    ptitle:SetTall(22)
    ptitle:ApplyBackground(DBase:Theme('secondary_dark'), 6, { true, true, false, false })
    ptitle:ApplyText(_strupper(text), 'danlib_font_16', 8, nil, DBase:Theme('decor'), TEXT_ALIGN_LEFT)

    return headerPnl
end

--- Creates a configuration popup for an NPC.
-- @param key string: The key of the NPC.
-- @param values table: The current NPC values.
function NPC:CreateConfigPopup(key, values)
    local Config = values[key]
    if (not Config) then
        _ErrorNoHalt('[DanLib.NPC] CreateConfigPopup: Config not found for key: ' .. key .. '\n')
        return
    end
    
    -- We keep the ORIGINAL values to check the changes.
    local originalConfig = {
        Name = Config.Name,
        Model = Config.Model,
        FuncType = Config.FuncType,
        Animation = Config.Animation
    }
    
    self.Config = Config
    local width = ui:ClampScaleW(self, 900, 900)
    local height = ui:ClampScaleH(self, 550, 550)
    Container = DCustomUtils(nil, 'DanLib.UI.PopupBasis')
    Container:SetHeader('NPC setup')
    Container:SetPopupWide(width)
    Container:SetExtraHeight(height)
    
    Container.OnClose = function()
        -- Stopping the model update timer
        if self.modelUpdateTimer then
            timer.Remove(self.modelUpdateTimer)
            self.modelUpdateTimer = nil
        end
        
        -- Reading the current values from the input fields
        if _IsValid(self.NameEntry) then
            Config.Name = self.NameEntry:GetValue()
        end
        
        if _IsValid(self.ModelEntry) then
            Config.Model = self.ModelEntry:GetValue()
        end
        
        -- Validation
        if (not Config.Name or Config.Name:Trim() == '') then
            Config.Name = 'Unnamed NPC'
        end
        
        if (not Config.Model or Config.Model:Trim() == '') then
            Config.Model = 'models/breen.mdl'
        end
        
        if (not Config.FuncType or Config.FuncType:Trim() == '') then
            Config.FuncType = 'NPC'
        end
        
        if (not Config.Animation or Config.Animation:Trim() == '') then
            Config.Animation = 'idle_all_scared'
        end
        
        -- CHECKING if there have been any changes
        local hasChanges = (Config.Name ~= originalConfig.Name or Config.Model ~= originalConfig.Model or Config.FuncType ~= originalConfig.FuncType or Config.Animation ~= originalConfig.Animation)
        -- We save it ONLY if there have been changes.
        if hasChanges then
            -- Clearing the cache to update the UI
            Config._cachedTime = nil
            Config._cachedTitle = nil
            
            DBase:SetConfigVariable('BASE', 'NPCs', values)
            self:Refresh()
        end
        
        -- We clear the links
        self.currentModel = nil
        self.modelPanel = nil
    end

    -- And create a model panel
    self.model = DBase:CreateModelPanel(Container)
    self.model:SetPos(305, 45)
    self.model:SetSize(Container:GetWide() / 3.3, Container:GetWide() / 3.65)
    self.model.ModelPanel:SetLookAt(_Vector(0, 0, 72 / 2))
    self.model.ModelPanel:SetCamPos(_Vector(64, -45, 72 / 2))
    self.model.ModelPanel:SetAmbientLight(Color(10, 15, 50))
    self.model.ModelPanel:SetDirectionalLight(BOX_TOP, Color(220, 190, 100))
    self.model.ModelPanel:SetFOV(58)
    self.modelPanel = self.model.ModelPanel
    
    -- Loading the model
    DBase:TimerSimple(0.05, function()
        if _IsValid(self.modelPanel) then
            self:UpdateModel()
        end
    end)

    -- Creating inputs (which will call UpdateModel when changing)
    self:SetupConfigInputs(Container, Config, function() end)
end

--- Sets up the input fields in the configuration popup.
-- @param container Panel: The container for the popup.
-- @param Config table: The configuration data for the NPC.
-- @param OnDataChange function: Callback when data changes.
function NPC:SetupConfigInputs(container, Config, OnDataChange)
    -- NPC name
    local Name = self:AddHeader(container, 'NPC name')
    Name:SetPos(16, 50)
    self.NameEntry = DBase.CreateTextEntry(Name)
    self.NameEntry:Pin(FILL, 4)
    self.NameEntry:SetBackText('Enter value')
    self.NameEntry:SetValue(Config.Name or '')
    self.NameEntry:SetFont('danlib_font_18')
    self.NameEntry:DisableShadows(10)

    -- NPC model
    local Model = self:AddHeader(container, 'NPC model')
    Model:SetPos(16, 125)
    self.ModelEntry = DBase.CreateTextEntry(Model)
    self.ModelEntry:Pin(FILL, 4)
    self.ModelEntry:SetBackText('Enter value')
    self.ModelEntry:SetValue(Config.Model or '')
    self.ModelEntry:SetFont('danlib_font_18')
    self.ModelEntry:DisableShadows(10)
    
    -- Tracking model changes with OPTIMIZED debounce
    self.ModelEntry.Think = function(sl)
        local newModel = sl:GetValue()
        
        if (newModel ~= sl.lastModelValue) then
            sl.lastModelValue = newModel
            Config.Model = newModel
            
            -- We use a NAMED timer with a unique ID.
            local timerID = 'DanLib_NPC_ModelUpdate_' .. tostring(self)
            
            if timer.Exists(timerID) then
                timer.Adjust(timerID, 0.3, 1) -- Adjust вместо Remove+Create
            else
                timer.Create(timerID, 0.3, 1, function()
                    if _IsValid(self.modelPanel) then
                        self:UpdateModel()
                        self:RefreshAnimationList(Config)
                    end
                end)
            end
        end
    end

    -- Function type
    local FunctionType = self:AddHeader(container, 'Function type')
    FunctionType:SetPos(16, 200)
    local comboSelect = DBase.CreateUIComboBox(FunctionType)
    comboSelect:Pin(FILL, 4)
    comboSelect:SetValue(Config.FuncType or 'NPC')
    comboSelect:DisableShadows(10)
    local options = {}
    for k, v in pairs(DanLib.BaseConfig.EntityTypesFunc) do
        options[k] = k
    end
    for k, v in pairs(options) do
        comboSelect:AddChoice(v, k)
    end
    comboSelect.OnSelect = function(s, index, value, data)
        Config.FuncType = value or 'NPC'
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
    self.animationListContainer = parent
    
    -- We create the list ASYNCHRONOUSLY so as not to lag
    DBase:TimerSimple(0.1, function()
        if _IsValid(parent) then
            self:RefreshAnimationList(Config)
        end
    end)
end

local MODEL_ANIMATION_CACHE = {}

--- Refreshes the animation list with animations from the current model.
-- @param Config table: The configuration data for the NPC.
function NPC:RefreshAnimationList(Config)
    if (not _IsValid(self.animationListContainer)) then
        return
    end
    
    if _IsValid(self.animList) then
        self.animList:Remove()
    end
    
    self.animList = DCustomUtils(self.animationListContainer, 'DanLib.UI.ListView')
    self.animList:Pin(nil, 6)
    self.animList:SetLineHeight(30)
    
    self.animList:AddColumn('Animations', {
        sortable = true,
        align = TEXT_ALIGN_LEFT,
        font = 'danlib_font_16'
    })
    
    local modelPath = Config.Model or 'models/breen.mdl'
    if MODEL_ANIMATION_CACHE[modelPath] then
        local animTable = MODEL_ANIMATION_CACHE[modelPath]
        
        for i = 1, #animTable do
            self.animList:AddLine(animTable[i])
        end
        
        self:SetupAnimationListHandler(Config)
        return
    end
    
    -- If it is not in the cache, download it.
    DBase:TimerSimple(0.05, function()
        local npcModel = _ClientsideModel(modelPath, RENDERGROUP_OPAQUE)
        if (not _IsValid(npcModel)) then
            npcModel = _ClientsideModel('models/breen.mdl', RENDERGROUP_OPAQUE)
        end
        
        if _IsValid(npcModel) then
            npcModel:SetNoDraw(true)
            local animTable = npcModel:GetSequenceList()
            MODEL_ANIMATION_CACHE[modelPath] = animTable
            
            local batchSize = 100
            local currentIndex = 1
            
            local function addBatch()
                if (not _IsValid(self.animList)) then
                    _SafeRemoveEntity(npcModel)
                    return
                end
                
                for i = currentIndex, math.min(currentIndex + batchSize - 1, #animTable) do
                    self.animList:AddLine(animTable[i])
                end
                
                currentIndex = currentIndex + batchSize
                
                if (currentIndex <= #animTable) then
                    DBase:TimerSimple(0.005, addBatch)
                else
                    _SafeRemoveEntity(npcModel)
                end
            end
            
            addBatch()
        end
    end)
    self:SetupAnimationListHandler(Config)
end

function NPC:SetupAnimationListHandler(Config)
    self.animList.OnRowSelected = function(listView, line, selected)
        if (not selected) then
            return
        end
        
        if (not _IsValid(self.modelPanel) or not _IsValid(self.modelPanel.Entity)) then
            return
        end
        
        local animName = line.Data[1]
        if (not animName) then
            return
        end
        
        local animIndex = self.modelPanel.Entity:LookupSequence(animName)
        if (animIndex and animIndex > 0) then
            self.modelPanel.Entity:ResetSequence(animIndex)
            Config.Animation = animName
        end
    end
end

--- Updates the model display in the configuration popup.
function NPC:UpdateModel()
    local Config = self.Config
    if (not Config) then
        return
    end
    
    local weaponModel = Config.Model
    if (not weaponModel or weaponModel:Trim() == '') then
        weaponModel = 'models/breen.mdl'
    end

    if (not _IsValid(self.modelPanel)) then
        return
    end

    -- Updating the model if it has changed
    if (weaponModel ~= self.currentModel) then
        self.modelPanel:SetModel(weaponModel)
        self.currentModel = weaponModel
        
        -- Applying animation after loading the model
        DBase:TimerSimple(0.2, function()
            if (not _IsValid(self.modelPanel) or not _IsValid(self.modelPanel.Entity)) then
                return
            end
            
            local animName = Config.Animation or 'idle'
            local animIndex = self.modelPanel.Entity:LookupSequence(animName)
            
            if (animIndex and animIndex > 0) then
                self.modelPanel.Entity:ResetSequence(animIndex)
            else
                local firstAnim = self.modelPanel.Entity:GetSequenceName(0)
                if firstAnim then
                    self.modelPanel.Entity:ResetSequence(0)
                    Config.Animation = firstAnim
                end
            end
        end)
    end
end

NPC:SetBase('DanLib.UI.PopupBasis')
NPC:Register('DDI.UI.ConfigNPC')
