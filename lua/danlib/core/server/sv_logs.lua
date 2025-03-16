/***
 *   @addon         DanLib
 *   @version       3.0.0
 *   @release_date  10/4/2023
 *   @author        denchik
 *   @contact       Discord: denchik_gm
 *                  Steam: https://steamcommunity.com/profiles/76561198405398290/
 *                  GitHub: https://github.com/denchik5133
 *                
 *
 *   @description   Universal library for GMod Lua, combining all the necessary features to simplify script development. 
 *                  Avoid code duplication and speed up the creation process with this powerful and convenient library.
 *
 *   @usage         !danlibmenu (chat) | danlibmenu (console)
 *   @license       MIT License
 *   @notes         For feature requests or contributions, please open an issue on GitHub.
 */



local base = DanLib.Func


-- Determine the operating system and architecture
local IsWindows = system.IsWindows()
local IsLinux = system.IsLinux()
local arch = jit.arch


-- Determine the appropriate module filename based on the OS and architecture
local module_filename = 'gmsv_chttp_' .. (IsWindows and (arch == 'x64' and 'win64' or 'win32') or IsLinux and (arch == 'x64' and 'linux64' or 'linux'))


-- Load the CHTTP module if the environment is suitable
if (IsWindows or IsLinux) and not CHTTP then
	if file.Exists('bin/' .. module_filename .. '.dll', 'LUA') then
		local success, err = pcall(require, 'chttp')

		if (not success) then
			print '\n'
			base:PrintType('Logs', 'Could not load gmsv_chttp!')

			if (err and err:lower():find("couldn't load module library!")) then
				base:PrintType('Logs', "There are some missing libraries from your server's operating system.")
				base:PrintType('Logs', 'This is not the fault of DanLib!!')
			else
				base:Print("\'" .. tostring(err) .. "\'")
			end

			base:Print('You may want to report this here: https://github.com/timschumi/gmod-chttp/issues')
		end
	else
		print '\n'
		base:PrintType('Logs', 'Could not find garrysmod/lua/bin/' .. module_filename .. ' on your server! Discord webhooks cannot be dispatched.')
		base:PrintType('Logs', 'Please read this article: https://discord.com/channels/849615817355558932/1129356041314914314/1129357663189340172')
		base:PrintType('Logs', 'If you do not need Discord webhooks, you can safely ignore this error.')
	end
end


-- Define a color for error messages
local Red = Color(255, 0, 0)


--- Sends a POST request to a Discord webhook.
-- @param url: The webhook URL.
-- @param payload: The data to send in the request.
-- @param onSuccess: Callback function for successful requests.
-- @param onFailed: Callback function for failed requests.
function base:PostWebhook(url, payload, onSuccess, onFailed)
    local allow_discord_send = url and (rateLimitedUntil == nil or os.time() >= rateLimitedUntil)
    if allow_discord_send then
        if CHTTP then
            CHTTP({
                method = 'POST',
                type = 'application/json',
                headers = {
                    ['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.113 Safari/537.36'
                },
                url = url,
                body = DanLib.NetworkUtil:TableToJSON(payload),
                failed = function(Error)
                    base:PrintType('Logs', Red, ' Discord API HTTP Error: ', color_white, Error)
                    if onFailed then onFailed(Error) end
                end,
                success = function(code, Body, headers)
                    if (code == 429) then
                        local retryAfter = headers['Retry-After']

        				if retryAfter then
        					base:PrintType('Logs', Red, " We're being rate limited! Discarding all webhooks in the next ", color_white, retryAfter, headers, ' second(s)')
                            rateLimitedUntil = os.time() + retryAfter + 1
        				else
        					base:PrintType('Logs', Red, " We're being rate limited! Discarding webhook.")
        				end
        			elseif (code > 299 or code < 200) then
        				if onSuccess then onSuccess(headers, code) end
        				base:PrintType('Logs', Red, ' Discord proxy returned HTTP: ', color_white, code, headers)
        				base:PrintType('Logs', Body)
        			end
                end,
                failure = function(reason)
                    base:PrintType('Logs', reason)
                end
            })
        else
            base:PrintType('Logs', 'Cannot dispatch Discord webhook. READ THIS FOR THE FIX: https://docs-ddi.site/dicord/error')
        end
    end
end


--- Retrieves webhooks configured in the DanLib configuration.
-- @return A table of webhooks.
local function getWebhooks()
    local values = DanLib.ConfigMeta.BASE:GetValue('Logs') or {}
    local webhooks = {}

    for i in pairs(values) do
        webhooks = {i, values}
    end

    return webhooks
end


--- Sends logs to Discord via a configured webhook.
-- @param module: The name of the module.
-- @param description: A description of the log.
-- @param fields: Additional fields to include in the log.
-- @param color: The color for the embed.
function base:GetDiscordLogs(module, description, fields, color)
    local footer = GetHostName() .. ' ➞ ' .. self:GetAddress() .. '  ●  ' .. os.date()

    if (not module) then
        error('No name module!')
        return
    end

    local l = getWebhooks()[2]

    for key, _ in pairs(l or {}) do
        local webhookURL = getWebhooks()[2][key].Webhook or nil
        local webhookName = getWebhooks()[2][key].Name or ''
        local isModuleEnabled = getWebhooks()[2][key].Modules[module] or nil

        color = color or Color(23, 100, 200)
        local col = math.floor(color.b + (color.g * 16 ^ 2) + (color.r * 16 ^ 4))

        local title = webhookName .. ' ➞ ' .. module
        description = description or ''
        fields = fields or {}

        if (webhookURL and isModuleEnabled) then
            self:PostWebhook(webhookURL, {
                embeds = {{
                    title = title,
                    fields = fields,
                    description = description,
                    color = col,
                    footer = {
                        text = footer
                    },
                }}
            })
            return
        end
    end
end
