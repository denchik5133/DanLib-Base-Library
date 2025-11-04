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
local DNetwork = DanLib.Network
local RANK, _ = DanLib.UiPanel()
local DMaterial = DanLib.Config.Materials
local DCustomUtils = DanLib.CustomUtils.Create


--- Checks the user's access to edit ranks.
-- @return boolean: true if access is denied, otherwise false.
function RANK:CheckAccess()
    if DBase.HasPermission(LocalPlayer(), 'EditRanks') then
        return
    end
    DBase:QueriesPopup('WARNING', "You can't edit ranks as you don't have access to them!", nil, nil, nil, nil, true)
    return true
end

--- Gets the current rank value.
-- @return table: rank values.
function RANK:GetRanksValues()
    return DBase:RetrieveUpdatedVariable('BASE', 'Ranks') or DanLib.ConfigMeta.BASE:GetValue('Ranks')
end

--- Adds a new rank.
function RANK:add_new()
    if self:CheckAccess() then
        return
    end

    local values = self:GetRanksValues()
    if (table.Count(values) >= DanLib.BaseConfig.RanksMax) then
        DBase:QueriesPopup('ERROR', DBase:L('#rank.limit', { limit = DanLib.BaseConfig.RanksMax }), nil, nil, nil, nil, true)
        return
    end

    DBase:RequestTextPopup('ADD NEW', DBase:L('#rank.new'), 'New rank', nil, function(roleName)
        -- Remove extra spaces in the role name
        roleName = string.Trim(roleName) -- Remove spaces at the beginning and end of the role name

        -- Check for invalid characters in role name
        if (not roleName:match('^[%w%s]+$')) then
            DBase:QueriesPopup('WARNING', 'Role name can only contain letters, numbers, and spaces!', nil, nil, nil, nil, true)
            return
        end

        -- Replace spaces with underscores for ID only
        local roleID = 'rank_' .. string.lower(string.gsub(roleName, '%s+', '_')) -- Replace spaces with '_'

        -- ID uniqueness check
        for k, v in pairs(values) do
            if (k == roleID) then
                DBase:QueriesPopup('WARNING', 'A role with this ID already exists!', nil, nil, nil, nil, true)
                return
            end
        end

        -- Creating a new role
        local newRole = {
            Name = roleName,
            Order = table.Count(values) + 1,
            Color = Color(255, 255, 255),
            Time = os.time(),
            Permission = {}
        }

        values[roleID] = newRole
        DBase:SetConfigVariable('BASE', 'Ranks', values)
        self:Refresh()
    end)
end

--- Checks if the player can edit the specified rank.
-- @param actor Player: The player who is trying to edit the rank.
-- @param targetRankKey string: The key of the rank the player is trying to edit.
-- @return boolean: true if access is denied, otherwise false.
function RANK:CanEditRank(targetRankKey)
    local values = self:GetRanksValues()
    local actorRankKey = LocalPlayer():get_danlib_rank() -- Getting a player's rank
    local actorRankOrder = values[actorRankKey].Order -- Player rank level
    local targetRankOrder = values[targetRankKey].Order -- Editable rank level

    -- If a player's rank is greater than or equal to the rank they are trying to edit, access is denied
    if (actorRankOrder > targetRankOrder) then
        DBase:QueriesPopup('WARNING', "You can't edit this rank!", nil, nil, nil, nil, true)
        return true
    end

    return false
end

--- Fills the panel with the required interface components.
function RANK:FillPanel()
    local width = ui:ClampScaleW(self, 700, 750)
    local height = ui:ClampScaleH(self, 500, 500)

    self:SetHeader('Rank')
    self:SetPopupWide(width)
    self:SetExtraHeight(height)
    self:SetSettingsFunc(true, 'Update', nil, function()
        if self:CheckAccess() then
            return
        end

        DNetwork:Start('DanLib.RequestRankData')
        DNetwork:SendToServer()
    end)

    local mainNavPanel = DCustomUtils(self)
    mainNavPanel:Pin(FILL, 16)

    self.tabs = mainNavPanel:Add('DanLib.UI.Tabs')

    local grid = DBase.CreateGridPanel(self.tabs)
    grid:Pin(FILL, 6)
    grid:SetColumns(2)
    grid:SetHorizontalMargin(12)
    grid:SetVerticalMargin(12)
    self.grid = grid
    self.tabs:AddTab(grid, 'Ranks')

    self:UsersList()
    self:Refresh() -- Interface update
end

--- Updates the interface with the current rank values.
function RANK:Refresh()
    self.grid:Clear()
    local values = self:GetRanksValues()

    -- Sorting ranks in order
    local sorted = {}
    for k, v in pairs(values) do
        DTable:Add(sorted, { v.Order, k })
    end
    DTable:SortByMember(sorted, 1, false)

    local panelH = 60
    for k, v in ipairs(sorted) do
        local Key = v[2]
        local rolePanel = DCustomUtils()
        rolePanel:SetTall(panelH)
        self.grid:AddCell(rolePanel, nil, false)

        self:CreateRankPanel(rolePanel, values, Key, sorted, panelH, k)
    end

    self:CreateAddRankButton()
end

--- Creates a panel for a specific rank.
-- @param rolePanel Panel: The panel on which the rank will be displayed.
-- @param values table: Current rank values.
-- @param Key string: The key of the rank.
-- @param RankColor Color: The colour of the rank.
-- @param name string: The name of the rank.
-- @param panelH number: Height of the panel.
-- @param k number: Rank index.
function RANK:CreateRankPanel(rolePanel, values, Key, sorted, panelH, k)
    local RankColor = values[Key].Color or DBase:Theme('title')
    local name = values[Key].Name or 'unknown'
    local id = Key or 'unknown'

    local orderNum = DCustomUtils(rolePanel)
    orderNum:PinMargin(LEFT, nil, nil, 8)
    orderNum:SetWide(26)
    orderNum:ApplyBackground(Color(35, 46, 62), 6)
    orderNum:ApplyText(values[Key].Order, 'danlib_font_18', nil, nil, Color(255, 255, 255, 50), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    local function createMoveButton(icon, direction)
        local moveButton = DBase.CreateUIButton(orderNum, {
            background = { nil },
            hover = { nil },
            tall = panelH / 2 - 8,
            wide = size,
            paint = function(sl, w, h)
                self:DrawMoveButtonEffect(sl, h, icon, direction)
            end,
            click = function(sl)
                self:MoveRank(sl, direction, k, sorted, values, Key)
            end
        })
        return moveButton
    end

    createMoveButton(DMaterial['Up-Arrow'], 'up'):Pin(TOP)
    createMoveButton(DMaterial['Arrow'], 'down'):Dock(BOTTOM)

    local Panel = DCustomUtils(rolePanel)
    Panel:Pin()
    Panel:ApplyBackground(DBase:Theme('secondary_dark'), 6)
    Panel:ApplyEvent(nil, function(sl, w, h)
        DUtils:DrawRoundedMask(6, 0, 0, w, h, function()
            DUtils:DrawRect(0, 0, 4, h, RankColor)
        end)
        DUtils:DrawDualText(13, h / 2 - 10, name, 'danlib_font_18', RankColor, 'Added ' .. DBase:FormatHammerTime(values[Key].Time) or '', 'danlib_font_16', DBase:Theme('text'), TEXT_ALIGN_LEFT, nil, w - 50)
        draw.SimpleText('ID: ' .. Key or nil, 'danlib_font_16', 13, h / 2 + 16, DBase:Theme('text'), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end)

    self:CreateRankActionButton(Panel, Key, values, RankColor, name)
end

--- Draws an effect on the move button.
-- @param sl Panel: The panel of the button.
-- @param h number: Height of the button.
-- @param direction string: The direction of movement.
function RANK:DrawMoveButtonEffect(sl, h, icon, direction)
    local lastClicked = sl.lastClicked or 0
    local clickPercent = math.Clamp((CurTime() - lastClicked) / 0.3, 0, 1)

    if (CurTime() < lastClicked + 0.3) then
        local w = sl:GetWide()
        local boxH = h * clickPercent
        DUtils:DrawRoundedMask(6, 0, 0, w, h, function()
            DUtils:DrawRect(0, direction == 'up' and h - boxH or 0, w, boxH, ColorAlpha(DanLib.Config.Theme['Red'], 100))
        end)
    end

    local iconSize = 14 * clickPercent
    DUtils:DrawIcon(sl:GetWide() / 2 - iconSize / 2, h / 2 - iconSize / 2, iconSize, iconSize, icon, Color(238, 238, 238, 50))
end

--- Moves the rank up or down.
-- @param sl Panel: The panel of the button.
-- @param direction string: Direction of movement.
-- @param k number: Index of the current rank.
-- @param sorted table: Sorted list of ranks.
-- @param values table: Current rank values.
-- @param key string: Rank key.
function RANK:MoveRank(sl, direction, k, sorted, values, Key)
    sl.lastClicked = CurTime()

    -- Получаем текущий ранг игрока
    local actor = LocalPlayer()
    local actorRankKey = actor:get_danlib_rank() -- Get the player's rank key

    -- Check if the player can edit the target rank
    -- If the player cannot edit, exit the function
    if self:CanEditRank(Key) then
        return
    end

    if (direction == 'up' and k > 1) then
        local aboveKey = sorted[k - 1][2]
        -- Checking if a player can move up a rank
        -- If the player's rank is higher, we disallow movement
        if self:CanEditRank(aboveKey) then return end
        -- Moving rank
        values[aboveKey].Order, values[Key].Order = values[Key].Order, values[aboveKey].Order
        DBase:SetConfigVariable('BASE', 'Ranks', values)
        self:Refresh()
    elseif (direction == 'down' and k < #sorted) then
        local belowKey = sorted[k + 1][2]
        -- Check if a player can move a rank lower
        -- If the player's rank is lower, disallow the move
        if self:CanEditRank(belowKey) then return end
        -- Moving rank
        values[belowKey].Order, values[Key].Order = values[Key].Order, values[belowKey].Order
        DBase:SetConfigVariable('BASE', 'Ranks', values)
        self:Refresh()
    end
end

--- Creates a button for rank actions.
-- @param Panel Panel: Panel for the button.
-- @param Key string: The key of the rank.
-- @param values table: Current rank values.
-- @param RankColor Color: The colour of the rank.
-- @param name string: The name of the rank.
function RANK:CreateRankActionButton(Panel, Key, values, RankColor, name)
    local size = 30
    local topMargin = (60 - size) / 2

    local buttons = {
        { Name = 'Edit name', Icon = DMaterial['Edit'], Col = DanLib.Config.Theme['Blue'], Func = function() 
            if self:CanEditRank(Key) then return end
            self:EditRankName(Key, values, name) 
        end },
        { Name = 'Permission', Icon = 'cPzyO3T', Func = function() 
            if self:CanEditRank(Key) then return end
            self:editPopup(Key, values) 
        end },
        { Name = 'Color', Icon = 'PHLbyno', Func = function() 
            if self:CanEditRank(Key) then return end
            self:ChangeRankColor(Key, values) 
        end },
        { Name = DBase:L('#delete'), Icon = DMaterial['Delete'], Col = DanLib.Config.Theme['Red'],
        hide = (Key == 'rank_owner'), -- Hide the button if it is the owner's rank
        Func = function() 
            if self:CanEditRank(Key) then return end
            self:DeleteRank(Key, values) 
        end }
    }

    local button = DBase.CreateUIButton(Panel, {
        dock_indent = { RIGHT, nil, topMargin, topMargin, topMargin },
        wide = size,
        icon = { DMaterial['Edit'] },
        tooltip = { DBase:L('#edit'), nil, nil, TOP },
        click = function(sl)
            if self:CheckAccess() then
                return
            end

            local menu = DBase:UIContextMenu(self)
            for _, v in ipairs(buttons) do
                if (not v.hide) then
                    menu:Option(v.Name, v.Col or nil, v.Icon, v.Func)
                end
            end

            local mouse_x = gui.MouseX()
            local mouse_y = gui.MouseY()
            menu:Open(mouse_x + 30, mouse_y - 24, sl)
        end
    })
end

--- Edits the rank name.
-- @param Key string: The key of the rank.
-- @param values table: Current rank values.
-- @param name string: Rank name.
function RANK:EditRankName(Key, values, name)
    DBase:RequestTextPopup('RANK NAME', DBase:L('#rank.name'), name, nil, function(newName)
        if values[newName] then
            DBase:QueriesPopup('WARNING', DBase:L('#rank.name.exists'), nil, nil, nil, nil, true)
            return
        end

        -- Saving old data
        local rankData = values[Key]
        values[newName] = rankData
        values[newName].Time = os.time() -- Updating time

        -- Deleting an old rank
        values[Key] = nil

        DBase:SetConfigVariable('BASE', 'Ranks', values)
        self:Refresh()
    end)
end

--- Deletes the rank.
-- @param Key string: Rank key.
-- @param values table: Current rank values.
function RANK:DeleteRank(Key, values)
    if (table.Count(values) <= 1) then
        DBase:QueriesPopup('WARNING', "You can't delete this rank, at least one rank must remain!", nil, nil, nil, nil, true)
        return
    end

    DBase:QueriesPopup('DELETION', DBase:L('#deletion.description'), nil, function()
        values[Key] = nil
        DBase:SetConfigVariable('BASE', 'Ranks', values)
        self:Refresh()
    end)
end

--- Changes the colour of the rank.
-- @param Key string: Rank key.
-- @param values table: Current rank values.
function RANK:ChangeRankColor(Key, values)
    local RankColor = values[Key].Color
    DBase:RequestColorChangesPopup('COLOR', RankColor, nil, function(value)
        values[Key].Color = value
        DBase:SetConfigVariable('BASE', 'Ranks', values)
        self:Refresh()
    end)
end

--- Creates a button to add a new rank.
function RANK:CreateAddRankButton()
    local createNew = DBase.CreateUIButton(nil, {
        dock_indent = { RIGHT, nil, 7, 6, 7 },
        tall = 30,
        text = { 'Add a new rank', nil, nil, nil, DBase:Theme('text', 200) },
        click = function() self:add_new() end
    })

    self.grid:AddCell(createNew, nil, false)
end

--- Opens a window for editing rank permissions.
-- @param Key string: Rank key.
-- @param values table: Current rank values.
function RANK:editPopup(Key, values)
    if IsValid(Container) then
        return
    end

    Container = vgui.Create('DanLib.UI.PopupBasis')
    Container:SetHeader('Permission - ' .. Key)
    local x, y = 650, 400
    Container:SetPopupWide(x)
    Container:SetExtraHeight(y)
    
    local fieldsBack = DCustomUtils(Container, 'DanLib.UI.Scroll')
    fieldsBack:Pin(FILL, 6)
    fieldsBack:ToggleScrollBar()

    -- Get the permissions of the current rank of the player
    local playerPermissions = LocalPlayer():get_danlib_rank_permissions()

    local sorted = {}
    for k, v in pairs(DanLib.BaseConfig.Permissions) do
        DTable:Add(sorted, { k, k })
    end
    DTable:SortByMember(sorted, 1, true)

    for k, v in pairs(sorted) do
        local mKey = v[2]
        local title = DanLib.BaseConfig.Permissions[mKey]
        local size = 26
        local panel = DCustomUtils(fieldsBack)
        panel:PinMargin(TOP, 8, 8, 6)
        panel:ApplyShadow(10, false, 8)
        panel:ApplyBackground(DBase:Theme('secondary_dark'), 6)
        panel:SetTall(46)
        panel:ApplyEvent(nil, function(sl, w, h)
            DUtils:DrawDualText(8, h / 2 - 1, mKey, 'danlib_font_20', DBase:Theme('decor'), title, 'danlib_font_18', DBase:Theme('text'), TEXT_ALIGN_LEFT, nil, w - size - 4)
        end)

        local margin = (panel:GetTall() - size) * 0.5

        local CheckBox = DBase.CreateCheckbox(panel)
        CheckBox:PinMargin(RIGHT, nil, margin, 10, margin)
        CheckBox:SetWide(size)
        CheckBox:SetValue(values[Key].Permission[mKey] or false)
        CheckBox:DisableShadows(10)

        -- Check if the player has the right to edit this permission
        if (not playerPermissions[mKey] and not playerPermissions.all_access) then
            CheckBox:SetDisabled(true) -- Disable the checkbox if the player does not have the permission
        end

        function CheckBox:OnChange(value)
            values[Key] = values[Key] or {}
            values[Key].Permission[mKey] = values[Key].Permission[mKey] or {}
            values[Key].Permission[mKey] = value

            DBase:SetConfigVariable('BASE', 'Ranks', values)
        end
    end
end

function RANK:UsersList()
    local userPanel = DCustomUtils(self.tabs)
    self.tabs:AddTab(userPanel, 'Users')

    local scroll = DCustomUtils(userPanel, 'DanLib.UI.Scroll')
    scroll:Pin(FILL)

    -- Create an empty list for users
    self.userList = {}

    -- Handler to get user data
    DNetwork:Receive('DanLib.SendRankData', function()
        local allRankData = DNetwork:ReadTable() -- Retrieve table with data
        self:UpdateUserList(scroll, allRankData) -- Update the list of users
    end)

    -- Call a request to the server to get the data
    DNetwork:Start('DanLib.RequestRankData')
    DNetwork:SendToServer()
end

function RANK:UpdateUserList(scroll, allRankData)
    -- Clearing previous items in the list
    for _, user in ipairs(self.userList) do
        user:Remove()
    end
    self.userList = {}

    -- Updating the list of users
    for steamID64, data in pairs(allRankData) do
        local avatarBackSize = 40
        local text_w = avatarBackSize + 24
        local name = steamworks.GetPlayerName(steamID64) or '' -- Get name, or empty string
        local pPlayer = player.GetBySteamID64(steamID64)
        
        local rankName = pPlayer and pPlayer:get_danlib_rank_name() or 'Member'
        local rankColor = pPlayer and pPlayer:get_danlib_rank_color() or Color(0, 151, 230, 255)

        -- Set default value for name if it is empty or equal to nil
        -- Or 'Unknown', depending on your preference
        name = (name and name ~= '') and name or 'BOT'

        local user = DCustomUtils(scroll)
        user:PinMargin(TOP, 4, nil, 6, 8)
        user:SetTall(60)
        user:ApplyBackground(DBase:Theme('secondary_dark'), 6)
        user:ApplyEvent(nil, function(sl, w, h)
            DUtils:DrawDualText(text_w, h / 2 - 9, name, 'danlib_font_16', DBase:Theme('decor'), 'ID: ' .. steamID64, 'danlib_font_16', DBase:Theme('text'), TEXT_ALIGN_LEFT, nil, w - 40)
            draw.SimpleText(rankName, 'danlib_font_16', text_w, h - 15, rankColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end)

        local avatar = DCustomUtils(user)
        avatar:ApplyAvatar()
        avatar:SetSteamID(steamID64, 64)
        avatar:SetSize(avatarBackSize, avatarBackSize)
        avatar:SetPos(12, user:GetTall() / 2 - avatarBackSize / 2)

        local size = 32
        local margin = (user:GetTall() - size) * 0.5
        local ranks = DanLib.ConfigMeta.BASE:GetValue('Ranks') or {}

        DBase.CreateUIButton(user, {
            dock_indent = { RIGHT, nil, margin, 10, margin },
            wide = size,
            icon = { DMaterial['Edit'] },
            tooltip = { DBase:L('#edit'), nil, nil, TOP },
            click = function(sl)
                if self:CheckAccess() then
                    return
                end

                local menu = DBase:UIContextMenu(self)
                menu:Option(DBase:L('#rank.copy.name'), nil, nil, function() DBase:ClipboardText(rankName) end)
                menu:Option(DBase:L('#copy_id'), nil, nil, function() DBase:ClipboardText(steamID64) end)
                menu:Option(DBase:L('#rank.copy.id'), nil, nil, function() DBase:ClipboardText(steamID64) end)
                menu:Option(DBase:L('#edit.rank'), nil, nil, function()
                    local options = {}
                    local function d()
                        for k, v in pairs(ranks or {}) do
                            options[k] = v.Name
                        end
                        return options
                    end
                    d()

                    DBase:ComboRequestPopup(DBase:L('#rank.list'), DBase:L('#select.assign.rank'), options, rankName, nil, function(value, data)
                        if self:CanEditRank(data) then
                            return
                        end
                        
                        DNetwork:Start('DanLib.NetSetRank')
                        DNetwork:WriteEntity(pPlayer)
                        DNetwork:WriteString(data)
                        DNetwork:SendToServer()
                    end)
                end)
                menu:Open()
            end
        })

        DTable:Add(self.userList, user) -- Save the link to the user
    end
end

RANK:SetBase('DanLib.UI.PopupBasis')
RANK:Register('DanLib.UI.Ranks')
