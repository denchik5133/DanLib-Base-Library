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
 *   cl_avatar.lua
 *   This file is responsible for creating and managing avatars in the client side of the DanLib project.
 *
 *   It includes the following functions:
 *   - Creating a circular avatar that displays the player's image.
 *   - Manage avatar properties such as size and position.
 *   - Computing a polygon for avatar masking using a stentile.
 *   - Drawing an avatar based on its properties and position on the screen.
 *
 *   The file provides a convenient interface for working with avatars in the project.
 */
 


--- GLua's library for drawing 2D objects.
-- @type table
local draw = draw  -- Library for drawing 2D objects.
--- GLua's library for rendering objects.
-- @type table
local render = render  -- Library for controlling rendering (rendering) of objects.
--- GLua's library for surface manipulation.
-- @type table
local surface = surface  -- Library for working with surfaces and their properties.
--- A function reference that disables textures for drawing.
-- @type function
local no_texture = draw.NoTexture  -- A feature that disables textures for painting.
--- A function reference for setting the draw color.
-- @type function
local draw_color = surface.SetDrawColor  -- Function for setting the drawing colour.

local utils = DanLib.Utils


--- Creates a panel with a circular avatar.
-- @param pParent: The parent panel to which this panel will be attached.
-- @return PANEL: Returns the created panel with a circular avatar.
function DanLib.Func:CreateCircleAvatar(pParent)
    local PANEL = DanLib.CustomUtils.Create(pParent)

    PANEL.Avatar = DanLib.CustomUtils.Create(PANEL, 'AvatarImage')
    PANEL.Avatar:SetPaintedManually(true)

    --- Performs the layout of the panel elements.
    -- Sets the avatar size and position, and calculates the polygon.
    function PANEL:PerformLayout()
        self.Avatar:SetSize(self:GetWide(), self:GetTall())
    end

    --- Sets the player for the avatar.
    -- @param pPlayer: The player whose avatar will be displayed.
    -- @param Size: Avatar size.
    function PANEL:SetPlayer(pPlayer, Size)
        self.Avatar:SetPlayer(pPlayer, Size)
    end

    --- Sets the Steam ID for the avatar.
    -- @param SteamID64: Steam Player ID.
    -- @param Size: Avatar size.
    function PANEL:SetSteamID(SteamID64, Size)
        self.Avatar:SetSteamID(SteamID64, Size)
    end

    function PANEL:SetRounded(cornerRadius)
        self.cornerRadius = cornerRadius or 6
    end

    function PANEL:SetCircleAvatar(value)
        self.cornerRadius = nil
        self.circleAvatar = value
    end

    --- Draws a panel using a stentile.
    -- Creates a stentil mask and draws an avatar.
    -- @param w: Panel width.
    -- @param h: Panel height.
    function PANEL:Paint(w, h)
        if (self.cornerRadius) then
            utils:DrawRoundedMask(self.cornerRadius, 0, 0, w, h, function()
                utils:DrawRoundedBox(0, 0, w, h, DanLib.Func:Theme('background'))
                self.Avatar:PaintManual()
                -- DanLib.startPanel(self)
                --     DanLib.Outline:Draw(self.cornerRadius - 2, 0, 0, w, h, DanLib.Func:Theme('frame'), nil, 1)
                -- DanLib.endPanel()
            end)
        elseif (self.circleAvatar) then
            render.ClearStencil()
            render.SetStencilEnable(true)
        
            render.SetStencilWriteMask(1)
            render.SetStencilTestMask(1)
        
            render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
            render.SetStencilPassOperation(STENCILOPERATION_ZERO)
            render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
            render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
            render.SetStencilReferenceValue(1)
        
            no_texture()
            draw_color(Color(0, 0, 0, 255))
            utils:DrawCircle(w / 2, h / 2, h / 2, w / 2)
        
            render.SetStencilFailOperation(STENCILOPERATION_ZERO)
            render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
            render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
            render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
            render.SetStencilReferenceValue(1)
        
            self.Avatar:PaintManual()
        
            render.SetStencilEnable(false)
            render.ClearStencil()
        end
    end

    return PANEL
end
