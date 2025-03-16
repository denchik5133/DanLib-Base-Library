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
 *   cl_image.lua
 *   This file is responsible for downloading and managing HTTP materials (images) in the client side of the DanLib project.
 *
 *   It includes the following functions:
 *   - Handling errors during material loading and setting an error texture.
 *   - Saving downloaded materials to a file and updating the material cache.
 *   - Downloading materials from the internet and managing download requests using a queue.
 *   - Retrieving materials based on their identifiers, checking local cache, and queuing downloads if necessary.
 *   - Drawing icons on the screen with optional rotation and color settings.
 *
 *   The file provides a convenient interface for working with images and materials in the project.
 */



--- Table for storing HTTP materials.
-- @type table
local httpMaterial = {}
httpMaterial.__index = httpMaterial

--- Queue for managing material download requests.
-- @type table
local queue = {}

local Table = DanLib.Table


--- Flag to determine whether to use a proxy for HTTP requests.
-- @type boolean
local useProxy = false

local surface = surface
local draw_material = surface.SetMaterial
local draw_color = surface.SetDrawColor
local draw_textured_rect_rotated = surface.DrawTexturedRectRotated
local draw_textured_rect = surface.DrawTexturedRect


--- Creates a directory for storing downloaded icons.
file.CreateDir('danlib/icon')


--- Handles errors during material loading.
-- Sets the material to an error texture and calls the callback function.
-- @param icon: The icon identifier.
-- @param cback: The callback function to call after handling the error.
local function handleError(icon, cback)
    httpMaterial[icon] = Material('error')
    cback(httpMaterial[icon])
end


--- Saves the downloaded material to a file and updates the material cache.
-- @param icon: The icon identifier.
-- @param raw: The raw image data downloaded.
-- @param matgs: Material settings to apply.
local function saveMaterial(icon, raw, matgs)
    file.Write('danlib/icon/' .. icon .. '.png', raw)
    httpMaterial[icon] = Material('../data/danlib/icon/' .. icon .. '.png', matgs or 'noclamp smooth mips')
end


--- Processes the result of the material load.
--  This function takes data about the uploaded content and performs appropriate actions depending on the size of the uploaded content.
--
-- If the size of the uploaded material exceeds 2 MB (2097152 bytes), the function calls an error handler,
-- setting the material to the error texture and invoking the callback.
-- Otherwise, the function saves the downloaded material to disc, updates the material cache
-- and calls the passed callback function with the loaded material.
--
-- @param icon: Icon identifier corresponding to the material being uploaded.
-- @param len: The length of the loaded content in bytes.
-- @param raw: Raw uploaded material (image).
-- @param matgs: The material settings that are applied when you save.
-- @param cback: A callback function that will be called after load processing is complete.
local function processDownload(icon, len, raw, matgs, cback)
    if (len > 2097152) then
        handleError(icon, cback)
    else
        saveMaterial(icon, raw, matgs)
        cback(httpMaterial[icon])
    end
end


--- Downloads a material from the internet.
-- Checks the queue for materials to download and processes them.
-- If the download fails and the proxy hasn't been used, it switches to proxy and retries.
local function downloadMaterial()
    if queue[1] then
        local icon, matgs, cback = unpack(queue[1])
        DanLib.HTTP:Fetch((useProxy and 'https://proxy.duckduckgo.com/iu/?u=https://i.imgur.com/' or 'https://i.imgur.com/') .. icon .. '.png', function(raw, len, _, code)
            processDownload(icon, len, raw, matgs, cback)
        end, function(error)
            if useProxy then
                httpMaterial[icon] = Material('error')
                cback(httpMaterial[icon])
            else
                useProxy = true
                downloadMaterial()
            end
        end)
    end
end


--- Retrieves a material based on the icon identifier.
-- Checks if the material is already loaded or saved locally; if not, it queues a download.
-- @param icon: The icon identifier.
-- @param cback: The callback function to call once the material is available.
-- @param _ : Unused parameter.
-- @param matgs: Material settings to apply.
function DanLib.Func:GetMaterial(icon, cback, _, matgs)
    if httpMaterial[icon] then
        cback(httpMaterial[icon])
    elseif file.Exists('danlib/icon/' .. icon .. '.png', 'DATA') then
        httpMaterial[icon] = Material('../data/danlib/icon/' .. icon .. '.png', matgs or 'noclamp smooth mips')
        cback(httpMaterial[icon])
    else
        Table:Add(queue, { icon, matgs, function(mat)
            cback(mat)
            Table:Remove(queue, 1)
            downloadMaterial()
        end })

        if (#queue == 1) then downloadMaterial() end
    end
end


--- Table for utility functions in DanLib.
-- @type table
DanLib.Utils = DanLib.Utils or {}


--- Table for caching materials for drawing.
-- @type table
local materials, gMaterials = {}, {}


--- Internal function for drawing an icon.
-- Handles loading the material if it is not already loaded, and draws it with optional rotation.
-- @param x: The x position to draw the icon.
-- @param y: The y position to draw the icon.
-- @param w: The width of the icon.
-- @param h: The height of the icon.
-- @param icon: The icon identifier.
-- @param color: The color to use when drawing the icon.
-- @param rotate: Optional rotation angle for the icon.
local function drawIconInternal(x, y, w, h, icon, color, rotate)
    color = color or Color(255, 255, 255, 255)

    if (not materials[icon]) then
        if gMaterials[icon] then return end

        gMaterials[icon] = true

        DanLib.Func:GetMaterial(icon, function(mat)
            materials[icon] = mat
            gMaterials[icon] = nil
        end)

        return
    end

    draw_material(materials[icon])
    draw_color(color.r, color.g, color.b, color.a)
    
    if rotate then
        draw_textured_rect_rotated(x, y, w, h, rotate)
    else
        draw_textured_rect(x, y, w, h)
    end
end


-- - Draws an icon at the specified position and size.
-- @param x: The x position to draw the icon.
-- @param y: The y position to draw the icon.
-- @param w: The width of the icon.
-- @param h: The height of the icon.
-- @param icon: The icon identifier.
-- @param color: The color to use when drawing the icon.
function DanLib.Utils:DrawIcon(x, y, w, h, icon, color)
    drawIconInternal(x, y, w, h, icon, color, false)
end


-- - Draws a rotated icon at the specified position and size.
-- @param x: The x position to draw the icon.
-- @param y: The y position to draw the icon.
-- @param w: The width of the icon.
-- @param h: The height of the icon.
-- @param r: The rotation angle for the icon.
-- @param icon: The icon identifier.
-- @param color: The color to use when drawing the icon.
function DanLib.Utils:DrawIconRotated(x, y, w, h, r, icon, color)
    drawIconInternal(x, y, w, h, icon, color, r)
end
