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
 *   cl_effects.lua
 *   This file provides utility functions for creating and managing visual effects within the DanLib UI framework.
 *
 *   The following functions and methods are included:
 *   - CreateSnowPanel: Generates a panel that simulates falling snow particles, enhancing the visual experience.
 *   - GenerateParticle: Creates a single snow particle with customizable attributes such as size, color, and gravity.
 *   - UpdateParticles: Updates the positions and states of all active snow particles based on user interactions and time.
 *   - DrawParticles: Renders the snow particles on the screen, applying visual effects such as fading and movement.
 *   - HandleCursorControl: Manages the interaction between the cursor and snow particles, allowing for dynamic movement based on user input.
 *
 *   This file is designed to enrich the user interface with engaging visual effects, providing a more immersive experience for players.
 *
 *   Usage example:
 *   - To create a snow effect on a panel:
 *     local snowPanel = DanLib.Func.CreateSnowPanel(parentPanel)
 *
 *   - To customize snow particle behavior:
 *     snowPanel.Speed = 2  -- Adjusts the speed of falling snow
 *
 *   @notes: Ensure that the snow effect is properly integrated within the UI to maintain performance.
 *   Each particle can have unique attributes, allowing for diverse visual effects.
 */



local base = DanLib.Func
local utils = DanLib.Utils

local math = math
local random = math.random
local sqrt = math.sqrt

local Table = DanLib.Table

local input = input
local mouseDown = input.IsMouseDown

local frameTime = RealFrameTime
local fcolor = Color

local circleMaterial = 'n7dRpXB' -- 16x16  https://www.flaticon.com/free-icon/snowflakes_3887247?term=snowflake&page=1&position=25&origin=search&related_id=3887247

-- DEFAULT: true
local FPS_Suspension = true


-- Function for creating a snow panel
function base.CreateSnowPanel(parent)
    local panel = DanLib.CustomUtils.Create(parent)
    panel:SetSize(parent:GetWide(), parent:GetTall())

    panel.Speed = 1
    local particles = {}
    local particleConfig = {
        startSpeed = 0.05,
        size = { min = 3, max = 8 },
        gravity = { min = 12, max = 30 },
        acceleration = { min = -0.3, max = 0.3 },
        maxDistance = 100,
        inDecay = 0.01,
        inertiaDecay = 1,
        amount = { min = 10, max = 60 }
    }

    -- Single particle generation with possibility to override values
    local function generateParticle(override)
        local randCol = random(0, 45)
        local particle = {
            cursor_control = true,
            gravity = random(particleConfig.gravity.min, particleConfig.gravity.max),
            acceleration = random(particleConfig.acceleration.min, particleConfig.acceleration.max),
            size = random(particleConfig.size.min, particleConfig.size.max),
            color = fcolor(255 - randCol, 255 - randCol, 255, 255 - random(0, 200)),
            x = random(panel:GetWide()),
            y = random(panel:GetTall()),
            xT = 0,
            yT = 0,
            lifetime = nil,
            life = nil
        }

        if (override and type(override) == 'table') then
            for key, value in pairs(override) do
                particle[key] = value
            end
        end

        return particle
    end

    -- Particle initialisation
    for i = 1, particleConfig.amount.max do
        Table:Add(particles, generateParticle())
    end

    panel:ApplyEvent(nil, function(self, w, h)
        local suspension = frameTime() * 100

        -- Remove or add particles depending on FPS
        if FPS_Suspension then
            if (suspension > 1.6 and #particles > particleConfig.amount.min) then
                Table:Remove(particles)
            elseif (suspension < 0.6 and #particles <= particleConfig.amount.max) then
                Table:Add(particles, generateParticle())
            end
        end

        -- Update and draw particles
        for i, particle in ipairs(particles) do
            -- utils:DrawMaterial(particle.x, particle.y, particle.size, particle.size, particle.color, circleMaterial)
            utils:DrawIcon(particle.x, particle.y, particle.size, particle.size, circleMaterial, particle.color)

            -- Update particle positions
            particle.x = particle.x + (particle.acceleration * (self.Speed * suspension) or 1)
            particle.y = particle.y + (particleConfig.startSpeed * particle.gravity * (self.Speed * suspension) or 1)

            -- Handling out of bounds
            if (particle.x < 0) then 
                particle.x = w
            elseif (particle.x > w) then 
                particle.x = 0 
            end

            if (particle.y < 0) then 
                particle.y = h - 3
                particle.x = random(10, w - 10)
            elseif (particle.y > h) then 
                particle.y = 3
                particle.x = random(10, w - 10) 
            end

            -- Particle lifetime processing
            if particle.lifetime then
                if (not particle.life) then
                    particle.life = particle.lifetime
                else
                    if (particle.life > 0) then
                        particle.life = particle.life - 0.01
                    else
                        Table:Remove(particles, i)
                    end
                end
            end

            -- Controlling particles with the cursor
            if particle.cursor_control then
                local cursorX, cursorY = self:CursorPos()
                local distance = sqrt((cursorX - particle.x) ^ 2 + (cursorY - particle.y) ^ 2)

                if (distance < particleConfig.maxDistance) then
                    local modifier = particleConfig.inertiaDecay * suspension
                    if mouseDown(MOUSE_LEFT) then modifier = -modifier end

                    -- Renewing the inertia of particles
                    particle.xT = particle.xT + (particle.x - cursorX) / (particleConfig.maxDistance * 10) * modifier
                    particle.yT = particle.yT + (particle.y - cursorY) / (particleConfig.maxDistance * 10) * modifier

                    local lineColor = fcolor(255, 255, 255, 110 - distance)
                    utils:DrawLine(cursorX, cursorY, particle.x + particle.size * 0.5, particle.y + particle.size * 0.5, lineColor)
                end

                -- Update particle positions depending on their inertia
                particle.x = particle.x + particle.xT
                particle.y = particle.y + particle.yT

                -- Reduce particle inertia
                particle.xT = particle.xT + (particle.xT > 0 and -particleConfig.inDecay * suspension or particleConfig.inDecay * suspension)
                particle.yT = particle.yT + (particle.yT > 0 and -particleConfig.inDecay * suspension or particleConfig.inDecay * suspension)
            end
        end
    end)

    return panel
end


-- Function for creating a panel with lines
function base.CreateLinePanel(parent)
    local panel = DanLib.CustomUtils.Create(parent)
    panel:SetSize(parent:GetWide(), parent:GetTall())

    panel.Speed = 1
    local particles = {}
    local particleConfig = {
        startSpeed = 0.05,
        size = { min = 3, max = 3 },
        gravity = { min = -10, max = 10 },
        acceleration = { min = -0.3, max = 0.3 },
        maxDistance = 100,
        inDecay = 0.04,
        inertiaDecay = 3,
        amount = { min = 10, max = 60 }
    }

    -- Single particle generation with possibility to override values
    local function generateParticle(override)
        local particle = {
            cursor_control = true,
            gravity = random(particleConfig.gravity.min, particleConfig.gravity.max),
            acceleration = random(particleConfig.acceleration.min, particleConfig.acceleration.max),
            size = random(particleConfig.size.min, particleConfig.size.max),
            color = Color(255, 255, 255, 255),
            x = random(panel:GetWide()),
            y = random(panel:GetTall()),
            xT = 0,
            yT = 0
        }

        if override and type(override) == 'table' then
            for key, value in pairs(override) do
                particle[key] = value
            end
        end

        return particle
    end

    -- Particle initialisation
    for i = 1, particleConfig.amount.max do
        Table:Add(particles, generateParticle())
    end

    panel:ApplyEvent(nil, function(self, w, h)
        local suspension = frameTime() * 100

        -- Remove or add particles depending on FPS
        if FPS_Suspension then
            if (suspension > 1.4 and #particles > particleConfig.amount.min) then
                Table:Remove(particles)
            elseif (suspension < 0.7 and #particles <= particleConfig.amount.max) then
                local x = random(self:GetWide())
                local y = { 3, self:GetTall() - 3 }
                Table:Add(particles, generateParticle({ x = x, y = y[random(1, 2)] }))
            end
        end

        -- Update and draw particles
        for id, particle in ipairs(particles) do
            utils:DrawRect(particle.x, particle.y, particle.size, particle.size, particle.color)

            -- Update particle positions
            particle.x = particle.x + (particle.acceleration * (self.Speed * suspension) or 1)
            particle.y = particle.y + (particleConfig.startSpeed * particle.gravity * (self.Speed * suspension) or 1)

            -- Handling out of bounds
            if (particle.x < 0) then
                particle.x = w - 3
                particle.y = random(10, h - 10)
            elseif (particle.x > w) then
                particle.x = 3
                particle.y = random(10, h - 10)
            end

            if (particle.y < 0) then
                particle.y = h - 3
                particle.x = random(10, w - 10)
            elseif (particle.y > h) then
                particle.y = 3
                particle.x = random(10, w - 10)
            end

            -- Draw lines between particles
            for k, otherParticle in ipairs(particles) do
                if (id ~= k) then
                    local distance = sqrt((otherParticle.x - particle.x) ^ 2 + (otherParticle.y - particle.y) ^ 2)
                    if (distance < particleConfig.maxDistance) then
                        local color = fcolor(255, 255, 255, 110 - distance)
                        utils:DrawLine(particle.x + particle.size * 0.5, particle.y + particle.size * 0.5, otherParticle.x + otherParticle.size * 0.5, otherParticle.y + otherParticle.size * 0.5, color)
                    end
                end
            end

            -- Controlling particles with the cursor
            if particle.cursor_control then
                local cursorX, cursorY = self:CursorPos()
                local cursorDistance = sqrt((cursorX - particle.x) ^ 2 + (cursorY - particle.y) ^ 2)

                if cursorDistance < particleConfig.maxDistance then
                    local modifier = particleConfig.inertiaDecay * suspension
                    if mouseDown(MOUSE_LEFT) then modifier = -modifier end

                    particle.xT = particle.xT + (particle.x - cursorX) / (particleConfig.maxDistance * 10) * modifier
                    particle.yT = particle.yT + (particle.y - cursorY) / (particleConfig.maxDistance * 10) * modifier

                    local lineColor = fcolor(255, 255, 255, 110 - cursorDistance)
                    utils:DrawLine(cursorX, cursorY, particle.x + particle.size * 0.5, particle.y + particle.size * 0.5, lineColor)
                end

                -- Update the positions of the particles depending on their inertia
                particle.x = particle.x + particle.xT
                particle.y = particle.y + particle.yT

                if (particle.xT > 0) then
                    particle.xT = particle.xT - particleConfig.inDecay * suspension
                elseif (particle.xT < 0) then
                    particle.xT = particle.xT + particleConfig.inDecay * suspension
                end

                if (particle.yT > 0) then
                    particle.yT = particle.yT - particleConfig.inDecay * suspension
                elseif (particle.yT < 0) then
                    particle.yT = particle.yT + particleConfig.inDecay * suspension
                end
            end
        end
    end)

    return panel
end
