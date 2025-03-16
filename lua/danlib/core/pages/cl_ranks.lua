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
local network = DanLib.Network
local RANK, _ = DanLib.UiPanel()
local customUtils = DanLib.CustomUtils


--- Checks the user's access to edit ranks.
-- @return boolean: true if access is denied, otherwise false.
function RANK:CheckAccess()
    if base.HasPermission(LocalPlayer(), 'EditRanks') then return end
    base:QueriesPopup('WARNING', "You can't edit ranks as you don't have access to them!", nil, nil, nil, nil, true)
    return true
end


--- Gets the current rank value.
-- @return table: rank values.
function RANK:GetRanksValues()
    return base:RetrieveUpdatedVariable('BASE', 'Ranks') or DanLib.ConfigMeta.BASE:GetValue('Ranks')
end


--- Adds a new rank.
function RANK:add_new()
    if self:CheckAccess() then return end

    local values = self:GetRanksValues()
    if (table.Count(values) >= DanLib.BaseConfig.RanksMax) then
        base:QueriesPopup('ERROR', base:L('#rank.limit', { limit = DanLib.BaseConfig.RanksMax }), nil, nil, nil, nil, true)
        return
    end

    base:RequestTextPopup('ADD NEW', base:L('#rank.new'), 'New rank', nil, function(roleName)
        -- Remove extra spaces in the role name
        roleName = string.Trim(roleName) -- Remove spaces at the beginning and end of the role name

        -- Check for invalid characters in role name
        if (not roleName:match('^[%w%s]+$')) then
            base:QueriesPopup('WARNING', 'Role name can only contain letters, numbers, and spaces!', nil, nil, nil, nil, true)
            return
        end

        -- Replace spaces with underscores for ID only
        local roleID = 'rank_' .. string.lower(string.gsub(roleName, '%s+', '_')) -- Replace spaces with '_'

        -- ID uniqueness check
        for k, v in pairs(values) do
            if (k == roleID) then
                base:QueriesPopup('WARNING', 'A role with this ID already exists!', nil, nil, nil, nil, true)
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
        base:SetConfigVariable('BASE', 'Ranks', values)
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
        base:QueriesPopup('WARNING', "You can't edit this rank!", nil, nil, nil, nil, true)
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
        if self:CheckAccess() then return end
        network:Start('DanLib.RequestRankData')
        network:SendToServer()
    end)

    local mainNavPanel = customUtils.Create(self)
    mainNavPanel:Pin(FILL, 16)

    self.tabs = mainNavPanel:Add('DanLib.UI.Tabs')

    local grid = base.CreateGridPanel(self.tabs)
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
        Table:Add(sorted, { v.Order, k })
    end
    Table:SortByMember(sorted, 1, true)

    local panelH = 60
    for k, v in ipairs(sorted) do
        local Key = v[2]
        local rolePanel = customUtils.Create()
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
    local RankColor = values[Key].Color or base:Theme('title')
    local name = values[Key].Name or 'unknown'
    local id = Key or 'unknown'

    local orderNum = customUtils.Create(rolePanel)
    orderNum:Pin(LEFT)
    orderNum:DockMargin(0, 0, 10, 0)
    orderNum:SetWide(26)
    orderNum:ApplyEvent(nil, function(sl, w, h)
        utils:DrawRect(0, 0, w, h, Color(68, 68, 68, 125))
        draw.SimpleText(values[Key].Order, 'danlib_font_18', w / 2, h / 2, Color(255, 255, 255, 50), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end)

    local function createMoveButton(icon, direction)
        local moveButton = base.CreateUIButton(orderNum, {
            background = { nil },
            hover = { nil },
            tall = panelH / 2 - 8,
            wide = size,
            paint = function(sl, w, h)
                sl:ApplyAlpha(0.2, 100)
                utils:DrawRect(0, 0, w, h, Color(57, 62, 70, sl.alpha))
                self:DrawMoveButtonEffect(sl, h, icon, direction)
            end,
            click = function(sl)
                self:MoveRank(sl, direction, k, sorted, values, Key)
            end
        })
        return moveButton
    end

    createMoveButton(DanLib.Config.Materials['Up-Arrow'], 'up'):Pin(TOP)
    createMoveButton(DanLib.Config.Materials['Arrow'], 'down'):Dock(BOTTOM)

    local Panel = customUtils.Create(rolePanel)
    Panel:Pin(FILL)
    Panel:ApplyEvent(nil, function(sl, w, h)
        utils:DrawRect(0, 0, w, h, base:Theme('secondary_dark'))
        utils:DrawRect(0, 0, 3, h, RankColor)
        utils:DrawDualText(13, h / 2 - 10, name, 'danlib_font_18', RankColor, 'Added ' .. base:FormatHammerTime(values[Key].Time) or '', 'danlib_font_16', base:Theme('text'), TEXT_ALIGN_LEFT, nil, w - 50)
        draw.SimpleText('ID: ' .. Key or nil, 'danlib_font_16', 13, h / 2 + 16, base:Theme('text'), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
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
        local boxH = h * clickPercent
        utils:DrawRect(0, direction == 'up' and h - boxH or 0, sl:GetWide(), boxH, ColorAlpha(DanLib.Config.Theme['Red'], 100))
    end

    local iconSize = 14 * clickPercent
    utils:DrawIcon(sl:GetWide() / 2 - iconSize / 2, h / 2 - iconSize / 2, iconSize, iconSize, icon, Color(238, 238, 238, 50))
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
    if self:CanEditRank(Key) then return end

    if (direction == 'up' and k > 1) then
        local aboveKey = sorted[k - 1][2]
        -- Checking if a player can move up a rank
        -- If the player's rank is higher, we disallow movement
        if self:CanEditRank(aboveKey) then return end
        -- Moving rank
        values[aboveKey].Order, values[Key].Order = values[Key].Order, values[aboveKey].Order
        base:SetConfigVariable('BASE', 'Ranks', values)
        self:Refresh()
    elseif (direction == 'down' and k < #sorted) then
        local belowKey = sorted[k + 1][2]
        -- Check if a player can move a rank lower
        -- If the player's rank is lower, disallow the move
        if self:CanEditRank(belowKey) then return end
        -- Moving rank
        values[belowKey].Order, values[Key].Order = values[Key].Order, values[belowKey].Order
        base:SetConfigVariable('BASE', 'Ranks', values)
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
        { Name = 'Edit name', Icon = DanLib.Config.Materials['Edit'], Col = DanLib.Config.Theme['Blue'], Func = function() 
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
        { Name = base:L('#delete'), Icon = DanLib.Config.Materials['Delete'], Col = DanLib.Config.Theme['Red'],
        hide = (Key == 'rank_owner'), -- Hide the button if it is the owner's rank
        Func = function() 
            if self:CanEditRank(Key) then return end
            self:DeleteRank(Key, values) 
        end }
    }

    local button = base.CreateUIButton(Panel, {
        dock_indent = {RIGHT, nil, topMargin, topMargin, topMargin},
        wide = size,
        icon = {DanLib.Config.Materials['Edit']},
        tooltip = {base:L('#edit'), nil, nil, TOP},
        click = function(sl)
            if self:CheckAccess() then return end
            local menu = base:UIContextMenu(self)
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
    base:RequestTextPopup('RANK NAME', base:L('#rank.name'), name, nil, function(newName)
        if values[newName] then
            base:QueriesPopup('WARNING', base:L('#rank.name.exists'), nil, nil, nil, nil, true)
            return
        end

        -- Saving old data
        local rankData = values[Key]
        values[newName] = rankData
        values[newName].Time = os.time() -- Updating time

        -- Deleting an old rank
        values[Key] = nil

        base:SetConfigVariable('BASE', 'Ranks', values)
        self:Refresh()
    end)
end


--- Deletes the rank.
-- @param Key string: Rank key.
-- @param values table: Current rank values.
function RANK:DeleteRank(Key, values)
    if (table.Count(values) <= 1) then
        base:QueriesPopup('WARNING', "You can't delete this rank, at least one rank must remain!", nil, nil, nil, nil, true)
        return
    end

    base:QueriesPopup('DELETION', base:L('#deletion.description'), nil, function()
        values[Key] = nil
        base:SetConfigVariable('BASE', 'Ranks', values)
        self:Refresh()
    end)
end


--- Changes the colour of the rank.
-- @param Key string: Rank key.
-- @param values table: Current rank values.
function RANK:ChangeRankColor(Key, values)
    local RankColor = values[Key].Color
    base:RequestColorChangesPopup('COLOR', RankColor, nil, function(value)
        values[Key].Color = value
        base:SetConfigVariable('BASE', 'Ranks', values)
        self:Refresh()
    end)
end


--- Creates a button to add a new rank.
function RANK:CreateAddRankButton()
    local createNew = base.CreateUIButton(nil, {
        dock_indent = {RIGHT, nil, 7, 6, 7},
        tall = 60,
        text = {'Add a new rank', nil, nil, nil, base:Theme('text', 200)},
        click = function() self:add_new() end
    })

    self.grid:AddCell(createNew, nil, false)
end


--- Opens a window for editing rank permissions.
-- @param Key string: Rank key.
-- @param values table: Current rank values.
function RANK:editPopup(Key, values)
    if IsValid(Container) then return end

    Container = vgui.Create('DanLib.UI.PopupBasis')
    Container:SetHeader('Permission - ' .. Key)
    local x, y = 650, 400
    Container:SetPopupWide(x)
    Container:SetExtraHeight(y)
    
    local fieldsBack = customUtils.Create(Container, 'DanLib.UI.Scroll')
    fieldsBack:Pin(FILL, 6)
    fieldsBack:ToggleScrollBar()

    -- Get the permissions of the current rank of the player
    local playerPermissions = LocalPlayer():get_danlib_rank_permissions()

    local sorted = {}
    for k, v in pairs(DanLib.BaseConfig.Permissions) do
        Table:Add(sorted, { k, k })
    end
    Table:SortByMember(sorted, 1, true)

    for k, v in pairs(sorted) do
        local mKey = v[2]
        local title = DanLib.BaseConfig.Permissions[mKey]
        local size = 26
        local panel = customUtils.Create(fieldsBack)
        panel:Pin(TOP)
        panel:DockMargin(8, 8, 4, 0)
        panel:ApplyShadow(10, false, 8)
        panel:SetTall(46)
        panel:ApplyEvent(nil, function(sl, w, h)
            utils:DrawRect(0, 0, w, h, base:Theme('secondary_dark'))
            utils:DrawDualText(8, h / 2 - 1, mKey, 'danlib_font_20', base:Theme('decor'), title, 'danlib_font_18', base:Theme('text'), TEXT_ALIGN_LEFT, nil, w - size - 4)
        end)

        local margin = (panel:GetTall() - size) * 0.5

        local CheckBox = base.CreateCheckbox(panel)
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

            base:SetConfigVariable('BASE', 'Ranks', values)
        end
    end
end


function RANK:UsersList()
    local userPanel = customUtils.Create(self.tabs)
    self.tabs:AddTab(userPanel, 'Users')

    local scroll = customUtils.Create(userPanel, 'DanLib.UI.Scroll')
    scroll:Pin(FILL)

    -- Create an empty list for users
    self.userList = {}

    -- Handler to get user data
    network:Receive('DanLib.SendRankData', function()
        local allRankData = network:ReadTable() -- Retrieve table with data
        self:UpdateUserList(scroll, allRankData) -- Update the list of users
    end)

    -- Call a request to the server to get the data
    network:Start('DanLib.RequestRankData')
    network:SendToServer()
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

        local user = customUtils.Create(scroll)
        user:Pin(TOP)
        user:DockMargin(4, 0, 0, 8)
        user:SetTall(60)
        user:ApplyEvent(nil, function(sl, w, h)
            utils:DrawRect(0, 0, w, h, base:Theme('secondary_dark'))
            utils:DrawDualText(text_w, h / 2 - 9, name, 'danlib_font_16', base:Theme('decor'), 'ID: ' .. steamID64, 'danlib_font_16', base:Theme('text'), TEXT_ALIGN_LEFT, nil, w - 40)
            draw.SimpleText(rankName, 'danlib_font_16', text_w, h - 15, rankColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end)

        local avatar = customUtils.Create(user)
        avatar:ApplyAvatar()
        avatar:SetSteamID(steamID64, 124)
        avatar:SetSize(avatarBackSize, avatarBackSize)
        avatar:SetPos(12, user:GetTall() / 2 - avatarBackSize / 2)

        local size = 32
        local margin = (user:GetTall() - size) * 0.5
        local ranks = DanLib.ConfigMeta.BASE:GetValue('Ranks') or {}

        local button = base.CreateUIButton(user, {
            dock_indent = {RIGHT, nil, margin, 10, margin},
            wide = size,
            icon = {DanLib.Config.Materials['Edit']},
            tooltip = {base:L('Edit'), nil, nil, TOP},
            click = function(sl)
                if self:CheckAccess() then return end
                local menu = base:UIContextMenu(self)

                menu:Option(base:L('#rank.copy.name'), nil, nil, function() base:ClipboardText(rankName) end)
                menu:Option(base:L('#copy_id'), nil, nil, function() base:ClipboardText(steamID64) end)
                menu:Option(base:L('#rank.copy.id'), nil, nil, function() base:ClipboardText(steamID64) end)
                menu:Option(base:L('#edit.rank'), nil, nil, function()
                    local options = {}
                    local function d()
                        for k, v in pairs(ranks or {}) do
                            options[k] = v.Name
                        end
                        return options
                    end
                    d()

                    base:ComboRequestPopup(base:L('#rank.list'), base:L('#select.assign.rank'), options, rankName, nil, function(value, data)
                        if self:CanEditRank(data) then return end
                        
                        network:Start('DanLib.NetSetRank')
                        network:WriteEntity(pPlayer)
                        network:WriteString(data)
                        network:SendToServer()
                    end)
                end)
                menu:Open()
            end
        })

        Table:Add(self.userList, user) -- Save the link to the user
    end
end

RANK:SetBase('DanLib.UI.PopupBasis')
RANK:Register('DanLib.UI.Ranks')
