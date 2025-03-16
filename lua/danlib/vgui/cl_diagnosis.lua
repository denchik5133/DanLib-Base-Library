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
local DiagnosisPanel, _ = DanLib.UiPanel()
local utils = DanLib.Utils
local Table = DanLib.Table
local customUtils = DanLib.CustomUtils


--- Calculates the current FPS.
-- @param shouldRound (boolean): If true, the FPS will be rounded to the nearest integer.
-- @return (string): The current FPS as a string.
local function CalculateFPS(shouldRound)
    local currentFPS = 1 / RealFrameTime()
    currentFPS = shouldRound and math.Round(currentFPS) or currentFPS
    return tostring(currentFPS)
end


--- Safely updates a function and returns its result.
-- @param func (function): The function to be called safely.
-- @return (string): The result of the function call or 'N/A' if an error occurs.
local function safeUpdate(func)
    local success, result = pcall(func)
    return success and result or 'N/A' -- Returns "N/A" in case of an error
end


--- Gets the number of hooks on the server.
-- @return (number): The total count of hooks on the server.
local function GetHookCount()
    local hooks = hook.GetTable()
    local count = 0

    -- Counting all hooks
    for _, hookTable in pairs(hooks) do
        count = count + table.Count(hookTable)
    end

    return count
end


--- Declares variables used in the DiagnosisPanel.
function DiagnosisPanel:DeclareVariables()
    -- general
    self.serverName = GetHostName()
    self.serverIP = base:GetAddress()

    -- colors
    self.graphLineColor = Color(255, 255, 255, 50)
    self.graphPlotColor = Color(0, 151, 230)
    self.segmentBoxColor = Color(36, 47, 61)
    self.segmentTextColor = Color(255, 165, 0)
    self.segmentValueColor = Color(255, 255, 255, 255)

    -- fonts
    self.defaultFont16 = 'danlib_font_16'
    self.defaultFont18 = 'danlib_font_18'
    self.defaultFont20 = 'danlib_font_20'
    self.defaultFont22 = 'danlib_font_22'

    -- graph values
    self.graphShouldCalibrate = false
    self.graphCalibrateIndex = 100
    self.graphFPSCheck = 5
    self.graphValueMin = 0
    self.graphValueMax = 350
    self.graphLabelWidth = 35
    self.graphMarginOffset = 16
    self.graphMarginTop = 8
    self.graphMultiplier = 2
    self.graphPlots = {}
    self.graphLegendIndex = 7
    self.graphOffset = 5
    self.graphFPS = 0

    -- think
    self.nextUpdateTime_fps = 0
    self.nextUpdateTime_curtime = 0
    self.nextUpdateTime_hooks = 0
    self.nextUpdateTime_players = 0
    self.nextUpdateTime_entities = 0
    self.nextUpdateTime_ping = 0

    -- data
    self.currentValue_curtime = 0
    self.currentValue_hooks = 0
    self.currentValue_players = 0
    self.currentValue_entities = 0
    self.currentValue_ping = 0

    -- sizing
    self.minWidth = 1
    self.headerHeight = 45
    self.headerTopMargin = 5
    self.segmentHeight = 76
    self.segmentWidth = 95
    self.iconSpacing = 5
    self.graphHeight = 230
    self.graphTopMargin = 34

    self.panelWidth = 320
    self.panelHeight = self.headerHeight + self.headerTopMargin + (self.segmentHeight * 2) + (self.iconSpacing * 2) + self.graphTopMargin + self.graphHeight + 20
end


--- Initializes the DiagnosisPanel.
function DiagnosisPanel:Init()
    self:DeclareVariables()
    -- Sets the size of the panel.
    self:SetSize(self.panelWidth, self.panelHeight)
    -- Sets the minimum width the DFrame can be resized to by the user.
    -- Sets the minimum height the DFrame can be resized to by the user.
    self:SetMinWMinH(self.panelWidth * self.minWidth, self.panelHeight * self.minWidth) -- minHeight
    -- Focuses the panel and enables it to receive input.
    -- self:MakePopup()
    -- Makes the panel render in front of all others, including the spawn menu and main menu.
    -- Priority is given based on the last call, so of two panels that call this method, the second will draw in front of the first.
    self:SetDrawOnTop(true)
    -- Sets the title of the frame.
    self:SetTitle('Diagnosis')
    self:ApplyAppear(9)
    -- self:EnableUserResize()
    self:Transparency()

    -- Subpanel creation
    self.subPanel = customUtils.Create(self)
    self.subPanel:Pin(nil, 8)

    -- Header creation
    self.headerPanel = customUtils.Create(self.subPanel)
    self.headerPanel:PinMargin(TOP, nil, nil, nil, self.headerTopMargin)
    self.headerPanel:SetTall(self.headerHeight)
    self.headerPanel:ApplyBackground(self.segmentBoxColor, 6)

    -- Header fill
    self.headerFillPanel = customUtils.Create(self.headerPanel)
    self.headerFillPanel:Pin()
    self.headerFillPanel:ApplyEvent(nil, function(sl, w, h)
        utils:DrawDualText(10, h / 2, self.serverName, self.defaultFont18, base:Theme('decor'), self.serverIP, self.defaultFont18, base:Theme('text'), TEXT_ALIGN_LEFT, nil, w - 100)
        draw.SimpleText(string.format('%i x %i', ScrW(), ScrH()), self.defaultFont18, w - 10, h / 2, base:Theme('text'), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end)

    -- Body creation
    self.bodyPanel = customUtils.Create(self.subPanel)
    self.bodyPanel:PinMargin(nil, nil, 4)

    -- Commands icon layout
    self.grid = base.CreateGridPanel(self.bodyPanel)
    self.grid:PinMargin(nil, 4)
    self.grid:SetColumns(3)
    self.grid:SetHorizontalMargin(8)
    self.grid:SetVerticalMargin(8)

    -- Helper function to create a segment
    local function CreateSegment(name, label, updateFunc)
        local segment = customUtils.Create()
        segment:SetSize(self.segmentWidth, self.segmentHeight)
        segment:ApplyEvent('Think', function(sl)
            if (self['nextUpdateTime_' .. name] > CurTime()) then return end
            self['currentValue_' .. name] = safeUpdate(updateFunc)
            self['nextUpdateTime_' .. name] = CurTime() + (name == 'fps' and 0.5 or 5)
        end)
        segment:ApplyEvent(nil, function(sl, w, h)
            utils:DrawRoundedBox(0, 0, w, h, self.segmentBoxColor)
            draw.SimpleText(label, self.defaultFont16, w / 2, h / 2 - 13, self.segmentTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText(self['currentValue_' .. name], self.defaultFont20, w / 2, h / 2 + 10, self.segmentValueColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end)
        self.grid:AddCell(segment, nil, false)

        return segment
    end

    -- Create segments for FPS, Players, Current Time, CPU Load, Active Entities, and Ping
    CreateSegment('fps', 'FPS', function() return CalculateFPS(true) end)
    CreateSegment('hooks', 'Total Hooks', GetHookCount)
    CreateSegment('entities', 'Active Entities', function() return tostring(#ents.GetAll()) end)
    CreateSegment('curtime', 'Curtime', function() return math.Round(CurTime()) end)
    CreateSegment('players', 'Players', function() return player.GetCount() end)
    CreateSegment('ping', 'Ping', function() return LocalPlayer():Ping() end)

    -- Graph container setup
    self.graphContainer = customUtils.Create(self.bodyPanel)
    self.graphContainer:Pin(BOTTOM)
    self.graphContainer:SetTall(self.graphHeight)
    self.graphContainer:ApplyBackground(self.segmentBoxColor, 6)

    self:GenerateGraph()
    self:SetTall(self.panelHeight)
end


--- Gets the rounded value or returns 'Bad Data'.
-- @param value (number): The value to be rounded.
-- @return (string): The rounded value or 'Bad Data' if the input is invalid.
function DiagnosisPanel:GetValue(value)
    if (not value or value ~= value or value == math.huge) then  return 'Bad Data' end
    return math.Round(value)
end


-- Get FPS and store it for graph plotting
function DiagnosisPanel:RetrieveFPS()
    self.graphPlots = self.graphPlots or {}
    if (not istable(self.graphPlots)) then return end

    local point = self.graphShouldCalibrate and self.graphCalibrateIndex or CalculateFPS(true)
    self.graphFPS = point

    Table:Add(self.graphPlots, point)
    self.graphFPSCheck  = CurTime() + (self.refreshRateConVarValue or 0.5)
end


--- Plots the graph based on coordinates.
-- @param coords (table): The coordinates to plot on the graph.
-- @param x (number): The x position for plotting.
-- @param y (number): The y position for plotting.
-- @param height (number): The height of the graph area.
-- @param offset (number): The offset to adjust the plotted points.
function DiagnosisPanel:RenderGraph(coords, x, y, height, offset)
    if (not istable(coords)) then return end

    x = x or 0
    y = y or 0
    height = height or 0
    offset = offset or 0

    local yPosition = y - 1
    local heightDiff = height - offset

    for i, v in ipairs(coords) do
        local a, b = coords[i], coords[i + 1]
        if (i == #coords) then b = v end

        -- double lines > thicc
        local aX, bX = a[1], b[1]
        local aY = a[2] + yPosition
        aY = math.Clamp(aY, 0, heightDiff)

        local bY = b[2] + yPosition
        bY = math.Clamp(bY, 0, heightDiff)

        utils:DrawLine(aX, aY, bX, bY, self.graphPlotColor)
        utils:DrawLine(aX, aY + 1, bX, bY + 1, self.graphPlotColor)
    end
end


--- Generates the graph and its labels.
function DiagnosisPanel:GenerateGraph()
    local labels = { self.graphValueMin }
    for i = 2, self.graphLegendIndex do
        labels[i] = math.Round(Lerp(i / self.graphLegendIndex, self.graphValueMin, self.graphValueMax))
    end

    labels = table.Reverse(labels)

    -- left-side labels
    self.graphLabels = customUtils.Create(self.graphContainer)
    self.graphLabels:Pin()
    self.graphLabels:ApplyEvent(nil, function(_, _, height)
        local y = self.graphMarginTop + self.graphMarginOffset
        local labelCount = #labels or 0
        height = self.graphPlotsContainer:GetTall()

        -- draw graph labels
        for _, value in ipairs(labels) do
            local labelValue = self:GetValue(value) or 9
            draw.SimpleText(labelValue, self.defaultFont16, self.graphLabelWidth / 2, y, self.textLabelColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            y = y + ((1 / labelCount) * height)
        end
    end)

    -- Graph plots
    self.graphPlotsContainer = customUtils.Create(self.graphLabels)
    self.graphPlotsContainer:PinMargin(nil, self.graphLabelWidth, self.graphMarginOffset, 6)
    self.graphPlotsContainer:ApplyEvent('Think', function(sl, w, h)
        self.coords = {}
        for i, v in ipairs(self.graphPlots) do
            local difference = self.graphValueMax - self.graphValueMin
            local x = (1 + ((i + 1) * self.graphMultiplier)) - 1
            local y	= ((self.graphValueMin == self.graphValueMax) and (1 - 1) * self.graphPlotsContainer:GetTall()) or ((( 1 - ((v - self.graphValueMin) / difference)) * self.graphPlotsContainer:GetTall()) + self.graphOffset) or 0

            -- remove hold history if points exceed pnl width
            if (x >= self.graphPlotsContainer:GetWide()) then table.remove(self.graphPlots, 1) end
            Table:Add(self.coords, { x, y })
        end

        if (self.graphFPSCheck > CurTime()) then return end
        self:RetrieveFPS()
    end)

    self.graphPlotsContainer:ApplyEvent(nil, function(_, width, height)
        local size = #labels or 0
        local y = self.graphMarginTop

        for i, _ in ipairs(labels) do
            utils:DrawLine(0, y, width, y, self.graphLineColor)
            y = y + ((1 / size) * height)
        end

        y = self.graphMarginTop
        self:RenderGraph(self.coords, 0, y, height, 0)
    end)
end

function DiagnosisPanel:Think()
    self.BaseClass.Think(self)
    local clampedRefreshRate = math.Clamp(0, 0.05, 1)
    self.refreshRateConVarValue = clampedRefreshRate
end

DiagnosisPanel:SetBase('DanLib.UI.Frame')
DiagnosisPanel:Register('DanLib.UI.Diagnosis')




if IsValid(DanLib.Diagnosis) then DanLib.Diagnosis:Remove() end
local function diagnosis(pPlayer)
    if (pPlayer:SteamID64() ~= DanLib.Author and pPlayer:SteamID64() ~= '76561199493672657') then
        return
    end

	if IsValid(DanLib.Diagnosis) then DanLib.Diagnosis:Remove() end
	local Frame = customUtils.Create(nil, 'DanLib.UI.Diagnosis')
	DanLib.Diagnosis = Frame
end
concommand.Add('ddi_diagnosis', diagnosis)