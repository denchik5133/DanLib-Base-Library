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


/***
 *   cl_modules.lua
 *   This file is responsible for creating and managing module panels in the DanLib project.
 *
 *   It includes the following functions:
 *   - Create and configure a panel that displays module information.
 *   - Refresh the module list and check for updates from a remote JSON source.
 *   - Handle user interactions for module details and updates.
 *   - Create a popup for detailed information about a selected module.
 *
 *   The file provides a user interface for managing and displaying modules effectively.
 */



local base = DanLib.Func
DanLib.UI = DanLib.UI or {}
local ui = DanLib.UI
local utils = DanLib.Utils
local Table = DanLib.Table
local customUtils = DanLib.CustomUtils


local MODULES = base.CreatePage(base:L('#modules'))
MODULES:SetOrder(4)
MODULES:SetIcon('oDR9aTn')
MODULES:SetKeyboardInput(true)


--- Checks if the player has access to the administration pages.
-- @param pPlayer Player|nil The player for whom access is being checked. If nil, LocalPlayer() is used.
-- @return boolean Returns true if the player has access, otherwise false.
function MODULES:AccessСheck(pPlayer)
    return base.HasPermission(pPlayer or LocalPlayer(), 'AdminPages')
end


--- Creates a settings panel.
-- @param parent Panel The parent panel to which the settings panel will be added.
function MODULES:Create(parent)
    base:TutorialSequence(3, 2)
    local m = base.CreatePanelModules(parent)
    m:Pin(FILL)
    m:FillPanel()
end 


--- URL for fetching module update information.
-- @type string
local updateLink = 'https://raw.githubusercontent.com/denchik5133/DDI-Other-Informations/main/DDI/update.json'

local defaultFont = 'danlib_font_20'
local defaultFont2 = 'danlib_font_18'


--- Creates a panel with common settings for module display.
-- @param parent: The parent panel to which this panel will be attached.
-- @param height: The height of the new panel.
-- @param topOffset: The offset from the top of the parent panel.
-- @return panel: Returns the created panel with specified settings.
local function CreatePanelWithSettings(parent, height, topOffset)
    local panel = customUtils.Create(parent)
    panel:PinMargin(TOP, nil, nil, nil, topOffset)
    panel:SetTall(height)
    panel:ApplyShadow(10, false)
    return panel
end


--- Creates a panel for displaying module information.
-- @param parent: The parent panel to which this module panel will be attached.
-- @return MODULE: Returns the created module panel.
function base.CreatePanelModules(parent)
    local MODULE = customUtils.Create(parent)
    local versionsCache = nil

    --- Fills the module panel with content.
    function MODULE:FillPanel()
        -- Create the title panel.
        self.header = CreatePanelWithSettings(self, 46, 12)
        self.header.icon = 24
        self.header.iconMargin = 14
        self.header:ApplyEvent(nil, function(sl, w, h)
            utils:DrawRoundedBox(0, 0, w, h, base:Theme('secondary_dark'))
            utils:DrawIcon(sl.iconMargin, h * .5 - sl.icon * 0.5, sl.icon, sl.icon, DanLib.Config.Materials['box'], base:Theme('mat', 150))
            utils:DrawDualText(
                sl.iconMargin * 3.5, h / 2 - 2,
                base:L('#modules'), 'danlib_font_20', base:Theme('decor'),
                base:L('#modules.description'), self.defaultFont, base:Theme('text'),
                TEXT_ALIGN_LEFT, nil, w - 300
            )
        end)

        -- Create a grid layout for modules.
        self.grid = base.CreateGridPanel(self)
        self.grid:PinMargin(FILL, 4, nil, 2)
        self.grid:SetColumns(3)
        self.grid:SetHorizontalMargin(12)
        self.grid:SetVerticalMargin(12)

        -- Refresh the panel to display module data.
        self:Refresh()
    end

    --- Refreshes the module list and updates the UI.
    function MODULE:Refresh()
        self.grid:Clear()

        -- Table to hold sorted module data.
        local sortedModules = {}
        for k, v in pairs(DanLib.ConfigMeta) do
            -- Insert module data for sorting.
            Table:Add(sortedModules, { v.SortOrder, k })
        end
        Table:SortByMember(sortedModules, 1, true)

        -- Fetch and cache version data.
        if (not versionsCache) then
            DanLib.HTTP:Fetch(updateLink, function(data)
                versionsCache = DanLib.NetworkUtil:JSONToTable(data)
            end)
        end

        -- Button to refresh module versions.
        local Check = base.CreateUIButton(self.header, {
            background = { nil },
            dock_indent = { RIGHT, nil, 7, 6, 7 },
            hover = { ColorAlpha(DanLib.Config.Theme['Yellow'], 60), nil, 6 },
            wide = 100,
            text = { 'Update', nil, nil, nil, DanLib.Config.Theme['Yellow'] },
            click = function(sl)
                versionsCache = nil
                DanLib.HTTP:Fetch(updateLink, function(data)
                    -- Fetch new version data.
                    versionsCache = DanLib.NetworkUtil:JSONToTable(data)
                end)
                -- Trigger tutorial sequence.
                base:TutorialSequence(4, 3)
            end
        })

        -- Loop through sorted modules to create UI elements.
        for _, v in pairs(sortedModules) do
            -- Get the module key.
            local Key = v[2]
            -- Retrieve module data.
            local module = DanLib.ConfigMeta[Key]
            -- Set the height for the module slot.
            local SlotTall = ui:ClampScaleH(self, 145, 145)

            -- Create a panel for the module.
            local modulesBack = customUtils.Create()
            modulesBack:SetTall(SlotTall)
            modulesBack.size = 70
            modulesBack:ApplyEvent(nil, function(sl, w, h)
                -- Draw the module background and outline.
                utils:DrawRoundedBox(0, 0, w, h, base:Theme('secondary_dark'))
                utils:DrawSquareWithIcon(w * 0.5 - sl.size * 0.5, 10, base:Theme('secondary'), sl.size, module.Icon or DanLib.Config.Materials['box'], 6)

                draw.SimpleText(module.Title, defaultFont, w * 0.5, h * 0.5 + 25, module.Color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText(base:L('#modules.version', { version = module.Version }), defaultFont2, 10, h - 14, base:Theme('text', 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end)

            -- Add the module panel to the grid.
            self.grid:AddCell(modulesBack, nil, true)

            -- Button for more information about the module.
            base.CreateUIButton(modulesBack, {
                background = { nil },
                dock = { FILL },
                hover = { base:Theme('button_hovered'), nil, 6 },
                wide = 100,
                paint = function(sl, w, h)
                    sl:ApplyAlpha(0.5, 220)
                    draw.DrawText('Click for more information', defaultFont, w / 2, h / 2, base:Theme('title', sl.alpha), TEXT_ALIGN_CENTER)
                end,
                click = function(sl)
                    -- Trigger tutorial sequence.
                    base:TutorialSequence(4, 1)
                    -- Show module info popup.
                    self:ModuleInfoPopup(modulesBack, module)
                end
            })
        end
    end

    --- Adds a header panel with text and title.
    -- @param panel: The panel to which the header will be added.
    -- @param text: The header text.
    -- @param textColor: The color of the header text.
    -- @param title: The title text.
    -- @param titleColor: The color of the title text.
    -- @param size: The height of the header panel.
    MODULE.AddPanelText = function(panel, text, title, titleColor, size)
        -- Create a button for the header.
        local headerPanel = base:CreateButton(panel)
        headerPanel:PinMargin(TOP, nil, nil, nil, 5)
        headerPanel:SetTall(size or 24)
        headerPanel:SetHoverTum(true)
        headerPanel:SetBackgroundColor(Color(0, 0, 0, 0))
        headerPanel:ApplyEvent(nil, function(sl, w, h)
            draw.DrawText(text, defaultFont2, 10, 2, base:Theme('title'), TEXT_ALIGN_LEFT)
            draw.DrawText(title, defaultFont2, w - 10, 2, titleColor, TEXT_ALIGN_RIGHT)
        end)
        headerPanel:ApplyEvent('DoClick', function(sl)
            -- Trigger tutorial sequence.
            base:TutorialSequence(4, 2)
            -- Copy title to clipboard.
            base:ClipboardText(title)
        end)
    end

    --- Displays a popup with detailed information about a module.
    -- @param self: The current module panel.
    -- @param modulesBack: The background panel of the module.
    -- @param module: The module data to be displayed.
    function MODULE:ModuleInfoPopup(modulesBack, module)
        -- Remove existing popup if valid.
        if ui:valid(self.pnlBack) then self.pnlBack:Remove() end

        -- Get mouse X position.
        local mouse_x = gui.MouseX()
        -- Get mouse Y position.
        local mouse_y = gui.MouseY()

        -- Create a new panel for the popup.
        self.pnlBack = customUtils.Create()
        self.pnlBack:SetSize(ScrW(), ScrH())
        self.pnlBack:MakePopup()
        self.pnlBack:ApplyAttenuation(0.3)
        self.pnlBack:ApplyEvent('OnMousePressed', function(sl)
            sl:SetAlpha(255)
            sl:AlphaTo(0, 0.1, 0, function() sl:Remove() end)
        end)

        local width = ui:ClampScaleW(self.pnlBack, 300, 300) -- Set popup width.
        local height = ui:ClampScaleH(self.pnlBack, 380, 380) -- Set popup height.

        -- Create a panel for the popup content.
        local pnl = customUtils.Create(self.pnlBack)
        pnl:SetPos(mouse_x + 5, mouse_y - 5)
        pnl:SetSize(width, height)
        pnl:ApplyEvent(nil, function(sl, w, h)
            local x, y = sl:LocalToScreen(0, 0)
            DanLib.DrawShadow:Begin()
            utils:DrawRoundedBox(x, y, w, h, base:Theme('primary_notifi'))
            DanLib.DrawShadow:End(1, 1, 1, 255, 0, 0, false)
            -- utils:DrawOutlinedRoundedRect(8, 0, 0, w, h, 4, base:Theme('frame'))
            DanLib.Outline:Draw(6, x, y, w, h, base:Theme('frame'), nil, 1)
        end)

        -- Create a base panel for the popup content.
        local main = customUtils.Create(pnl)
        main:Pin(TOP)
        main:SetHeight(140)

        -- Create a blur panel for the avatar.
        local blurBase = customUtils.Create(main)
        blurBase:Pin(TOP)
        blurBase:SetHeight(100)

        -- Get the module author ID.
        local ID = module.Author or nil
        -- Get the player's name.
        local playerName = steamworks.GetPlayerName(ID) or 'unknown'

        -- Create an avatar image.
        local avatarBaner = customUtils.Create(blurBase, 'AvatarImage')
        avatarBaner:SetPos(0, -75)
        avatarBaner:SetSize(310, 310)
        avatarBaner:SetSteamID(ID, 64)

        -- Create a panel for the blur effect.
        local blur = customUtils.Create(avatarBaner)
        blur:Pin(FILL)
        blur:ApplyEvent(nil, function(sl, w, h)
            -- Apply blur effect.
            utils:DrawBlur(sl, 1, 1)
            -- Draw a semi-transparent background.
            -- utils:DrawRect(0, 0, w, h, Color(0, 0, 0, 200))
            -- Draw a circle on the blur.
            -- utils:DrawCircle(w * 0.5, h * 0.5 + 15, 44, 32, base:Theme('primary_notifi'))
        end)

        local avatar = customUtils.Create(main)
        avatar:ApplyAvatar(false, 6)
        avatar:SetSteamID(ID, 124)
        avatar:SetPos(115, 54)
        avatar:SetSize(80, 80)

        -- Create a scrollable panel for module details.
        local scroll = customUtils.Create(pnl, 'DanLib.UI.Scroll')
        scroll:Dock(FILL)
        scroll:DockMargin(0, 5, 0, 5)
        scroll:ToggleScrollBar() -- Enable scrolling.

        -- Add module details to the scroll panel.
        self.AddPanelText(scroll, 'Author', 'By ' .. playerName, base:Theme('text', 180))
        self.AddPanelText(scroll, 'SteamID64', ID, base:Theme('text', 180))
        self.AddPanelText(scroll, 'Name', module.Title, module.Color)

        -- Get cached version data.
        local checkVersions = versionsCache or {}
        -- Check the version for the module.
        local checkVer = checkVersions[module.Title]
        -- Define color constants.
        local red, green, yellow = DanLib.Config.Theme['Red'], DanLib.Config.Theme['Green'], DanLib.Config.Theme['Yellow']
        -- Check if the module is up-to-date.
        local isUpToDate = (module.Version == checkVer)
        -- Default text and color.
        local text, color = base:L('#modules.no.inf'), red

        if checkVer then
            -- Set color based on version status.
            color = isUpToDate and green or yellow
            -- Set text based on version status.
            text = isUpToDate and base:L('#latest.version') or base:L('#update.needed') .. ' ' .. base:L('#new.version', {version = checkVer})
        end

        -- Wrap text for display.
        local wText = utils:TextWrap(text or 'none', defaultFont, scroll:GetWide() * 3)
        -- Get text size for layout.
        local text_x, text_y = utils:GetTextSize(wText, defaultFont)
        -- Add version text.
        self.AddPanelText(scroll, base:L('version'), wText, color, 10 + text_y)

        -- Wrap module description text.
        local wrappedText = utils:TextWrap(module.Description or 'none', defaultFont, scroll:GetWide() * 3)
        -- Get the size of the wrapped text.
        local title_x, title_y = utils:GetTextSize(wrappedText, defaultFont)
        -- Add description text.
        self.AddPanelText(scroll, base:L('description'), wrappedText, base:Theme('text', 180), title_y)
    end

    -- Return the created module panel.
    return MODULE
end
