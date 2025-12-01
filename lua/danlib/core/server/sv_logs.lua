/***
 *   @addon         DanLib
 *   @version       2.0.0
 *   @release_date  01/12/2025
 *   @author        denchik
 *   
 *   @description   Enhanced Discord logging system with queue, batch, and retry mechanisms
 *
 *   @changelog     - Added queue system (no logs lost on rate limit)
 *                  - Added batch sending (up to 10 logs per message)
 *                  - Added retry mechanism (3 attempts)
 *                  - Added console commands for debugging
 *                  - Added webhook username override
 *   @license       MIT License
 */



local DBase = DanLib.Func
local DTable = DanLib.Table

local _IsValid = IsValid
local _ostime = os.time
local _osdate = os.date
local _ipairs = ipairs
local _stringSub = string.sub
local _tonumber = tonumber
local _tostring = tostring
local _mathFloor = math.floor

-- Determine the operating system and architecture
local IsWindows = system.IsWindows()
local IsLinux = system.IsLinux()
local arch = jit.arch

local module_filename = 'gmsv_chttp_' .. (IsWindows and (arch == 'x64' and 'win64' or 'win32') or IsLinux and (arch == 'x64' and 'linux64' or 'linux'))

if (IsWindows or IsLinux) and not CHTTP then
    if file.Exists('bin/' .. module_filename .. '.dll', 'LUA') then
        local success, err = pcall(require, 'chttp')
        if (not success) then
            print '\n'
            DBase:PrintType('Logs', 'Could not load gmsv_chttp!')
            if err and err:lower():find("couldn't load module library!") then
                DBase:PrintType('Logs', "There are some missing libraries from your server's operating system.")
                DBase:PrintType('Logs', 'This is not the fault of DanLib!!')
            else
                DBase:Print("\'" .. _tostring(err) .. "\'")
            end
            DBase:Print('You may want to report this here: https://github.com/timschumi/gmod-chttp/issues')
        end
    else
        print '\n'
        DBase:PrintType('Logs', 'Could not find garrysmod/lua/bin/' .. module_filename .. ' on your server! Discord webhooks cannot be dispatched.')
        DBase:PrintType('Logs', 'Please read this article: https://discord.com/channels/849615817355558932/1129356041314914314/1129357663189340172')
        DBase:PrintType('Logs', 'If you do not need Discord webhooks, you can safely ignore this error.')
    end
end

local Red = Color(255, 0, 0)
local Yellow = Color(255, 255, 0)

DanLib.Discord = DanLib.Discord or {}
DanLib.Discord.Queue = DanLib.Discord.Queue or {}
DanLib.Discord.RateLimitUntil = 0
DanLib.Discord.MaxQueueSize = 100
DanLib.Discord.RetryInterval = 5

--- Adds a failed log to the retry queue with priority management
-- @param url (string): Discord webhook URL
-- @param payload (table): Discord webhook payload (embeds, username, etc.)
-- @param priority (number|nil): Log priority (1=critical, 2=high, 3=normal, 4=low), defaults to 3
-- @return void
-- @example _queueLog('https://discord.com/api/webhooks/...', { embeds = {...} }, 2)
local function _queueLog(url, payload, priority)
    if (#DanLib.Discord.Queue >= DanLib.Discord.MaxQueueSize) then
        local lowestPriority = 0
        local lowestIndex = 1
        
        for i, log in _ipairs(DanLib.Discord.Queue) do
            local logPriority = log.priority or 3
            if (logPriority > lowestPriority) then
                lowestPriority = logPriority
                lowestIndex = i
            end
        end
        
        DTable:Remove(DanLib.Discord.Queue, lowestIndex)
        DBase:PrintType('Logs', Red, ' Queue is full! Removing log with priority ', color_white, lowestPriority)
    end
    
    DTable:Add(DanLib.Discord.Queue, {
        url = url,
        payload = payload,
        timestamp = _ostime(),
        retries = 0,
        maxRetries = 3,
        priority = priority or 3
    })
end

--- Processes the retry queue, attempting to resend failed logs
-- Automatically called every 5 seconds by timer
-- @return void
local function _processQueue()
    if (#DanLib.Discord.Queue == 0) then
        return
    end
    
    if (_ostime() < DanLib.Discord.RateLimitUntil) then
        return
    end
    
    local logData = DanLib.Discord.Queue[1]
    
    DBase:PostWebhook(logData.url, logData.payload, function(headers, code)
        DTable:Remove(DanLib.Discord.Queue, 1)
    end, function(error)
        logData.retries = logData.retries + 1
        if (logData.retries >= logData.maxRetries) then
            DTable:Remove(DanLib.Discord.Queue, 1)
            DBase:PrintType('Logs', Red, ' Log dropped after ', color_white, logData.maxRetries, ' retries.')
        else
            local retryLog = DTable:Remove(DanLib.Discord.Queue, 1)
            DTable:Add(DanLib.Discord.Queue, retryLog)
        end
    end)
end

timer.Create('DanLib.Discord.ProcessQueue', DanLib.Discord.RetryInterval, 0, _processQueue)


DanLib.Discord.BatchQueue = {}
DanLib.Discord.BatchInterval = 2
DanLib.Discord.MaxBatchSize = 10

--- Truncates text to fit Discord's message limits with console warning
-- @param text (string|nil): Text to truncate
-- @param maxLength (number|nil): Maximum length (default: 4000)
-- @param fieldName (string|nil): Field name for warning message
-- @return string Truncated text with warning if exceeded
-- @example local truncated = _truncateText('Very long text...', 100, 'description')
local function _truncateText(text, maxLength, fieldName)
    maxLength = maxLength or 4000
    fieldName = fieldName or 'text'
    
    if (not text or text == '') then
        return ''
    end
    
    if (#text <= maxLength) then
        return text
    end
    
    local truncated = _stringSub(text, 1, maxLength - 100)
    truncated = truncated .. '\n\n**Text truncated** (' .. #text .. ' chars)'
    
    return truncated
end

--- Calculates the actual size of an embed
-- @param embed (table): Discord embed object
-- @return number Size in characters
local function _calculateEmbedSize(embed)
    local size = #(embed.description or '') + #(embed.title or '')
    
    if embed.fields then
        for _, field in _ipairs(embed.fields) do
            size = size + #field.name + #field.value
        end
    end
    
    if embed.footer and embed.footer.text then
        size = size + #embed.footer.text
    end
    
    return size
end

--- Flushes the batch queue, sending all accumulated logs for a webhook
-- Automatically splits large text into multiple embeds
-- @param webhookURL (string): Discord webhook URL to flush
-- @return void
local function _flushBatch(webhookURL)
    local batch = DanLib.Discord.BatchQueue[webhookURL]
    if (not batch or #batch == 0) then
        return
    end
    
    local currentEmbeds = {}
    local currentSize = 0
    local maxEmbedsPerMessage = 10
    local maxSizePerMessage = 5500
    local webhookUsername = nil
    
    for _, log in _ipairs(batch) do
        local footer = GetHostName() .. ' ➞ ' .. DBase:GetAddress() .. '  ●  ' .. _osdate('%H:%M:%S', log.timestamp)
        
        local color = log.color or Color(23, 100, 200)
        local col = 0
        
        if (type(color) == 'table' and color.r and color.g and color.b) then
            col = _mathFloor(color.b + (color.g * 256) + (color.r * 65536))
        else
            col = 6591667
        end
        
        -- We cut off the description if it is too long.
        local description = _truncateText(log.description, 4000, 'description')
        
        -- Processing fields (not creating an empty table)
        local truncatedFields = nil
        if (log.fields and #log.fields > 0) then
            truncatedFields = {}
            for _, field in _ipairs(log.fields) do
                truncatedFields[#truncatedFields + 1] = {
                    name = _truncateText(field.name, 256, 'field.name'),
                    value = _truncateText(field.value, 1024, 'field.value'),
                    inline = field.inline
                }
            end
        end
        
        local embed = {
            title = log.title,
            fields = truncatedFields,
            description = description,
            color = col,
            footer = { text = footer },
            timestamp = _osdate('!%Y-%m-%dT%H:%M:%S', log.timestamp)
        }
        
        -- Accurate calculation of embed size
        local embedSize = _calculateEmbedSize(embed)
        
        -- Checking if the current batch needs to be sent
        if (#currentEmbeds >= maxEmbedsPerMessage or currentSize + embedSize > maxSizePerMessage) then
            local payload = {
                username = webhookUsername,
                embeds = currentEmbeds
            }
            
            DBase:PostWebhook(webhookURL, payload)
            currentEmbeds = {}
            currentSize = 0
        end
        
        -- Direct insertion
        currentEmbeds[#currentEmbeds + 1] = embed
        currentSize = currentSize + embedSize
        
        if (log.webhookName and not webhookUsername) then
            webhookUsername = log.webhookName
        end
    end
    
    if (#currentEmbeds > 0) then
        local payload = {
            username = webhookUsername,
            embeds = currentEmbeds
        }
        
        DBase:PostWebhook(webhookURL, payload)
    end
    
    DanLib.Discord.BatchQueue[webhookURL] = {}
end

timer.Create('DanLib.Discord.FlushBatch', DanLib.Discord.BatchInterval, 0, function()
    for webhookURL, _ in pairs(DanLib.Discord.BatchQueue) do
        _flushBatch(webhookURL)
    end
end)

--- Adds a log to the batch queue for efficient bulk sending
-- @param webhookURL (string): Discord webhook URL
-- @param webhookName (string): Display name for the webhook
-- @param title (string): Embed title (format: "Addon ➞ Module")
-- @param description (string): Embed description/content
-- @param fields (table|nil): Array of embed fields {name, value, inline}
-- @param color (Color|nil): Embed color (GMod Color object)
-- @param priority (number|nil): Log priority (1-4), defaults to 3
-- @return void
-- @example _addToBatch('https://...', 'MyWebhook', 'DanLib ➞ Config', 'Player changed config', { { name='Player', value='John' } }, Color(255,0,0), 2)
local function _addToBatch(webhookURL, webhookName, title, description, fields, color, priority)
    DanLib.Discord.BatchQueue[webhookURL] = DanLib.Discord.BatchQueue[webhookURL] or {}
    
    DTable:Add(DanLib.Discord.BatchQueue[webhookURL], {
        webhookName = webhookName,
        title = title,
        description = description,
        fields = fields,
        color = color,
        priority = priority or 3,
        timestamp = _ostime()
    })
    
    if (#DanLib.Discord.BatchQueue[webhookURL] >= DanLib.Discord.MaxBatchSize) then
        _flushBatch(webhookURL)
    end
end

--- Sends a Discord webhook with automatic retry and rate limit handling
-- @param url (string): Discord webhook URL
-- @param payload (table): Webhook payload (embeds, username, content, etc.)
-- @param onSuccess (function|nil): Callback on success (headers, code)
-- @param onFailed (function|nil): Callback on failure (error)
-- @return void
function DBase:PostWebhook(url, payload, onSuccess, onFailed)
    if (not url or url == '') then
        DBase:PrintType('Logs', Red, ' No webhook URL provided!')
        return
    end
    
    local isRateLimited = _ostime() < DanLib.Discord.RateLimitUntil
    if isRateLimited then
        _queueLog(url, payload)
        return
    end
    
    if (not CHTTP) then
        DBase:PrintType('Logs', 'Cannot dispatch Discord webhook. READ THIS FOR THE FIX: https://docs-ddi.site/dicord/error')
        return
    end
    
    -- Валидация размера payload
    local jsonBody = DanLib.NetworkUtil:TableToJSON(payload)
    local bodySize = #jsonBody
    
    if (bodySize > 8000) then
        DBase:PrintType('Logs', Red, ' Payload too large! ', color_white, bodySize, ' bytes (max 8000)')
        DBase:PrintType('Logs', Red, ' Log will be queued and may need splitting')
        return
    end
    
    CHTTP({
        method = 'POST',
        type = 'application/json',
        headers = {
            ['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            ['Content-Type'] = 'application/json'
        },
        url = url,
        body = jsonBody,
        failed = function(Error)
            DBase:PrintType('Logs', Red, ' Discord API HTTP Error: ', color_white, _tostring(Error))
            _queueLog(url, payload)
            
            if onFailed then
                onFailed(Error)
            end
        end,
        success = function(code, Body, headers)
            if (code == 429) then
                local retryAfter = _tonumber(headers['Retry-After']) or 60
                DanLib.Discord.RateLimitUntil = _ostime() + retryAfter + 1
                DBase:PrintType('Logs', Red, ' Rate limited! Retry after ', color_white, retryAfter, ' second(s)')
                _queueLog(url, payload)
            elseif (code >= 200 and code < 300) then
                if onSuccess then
                    onSuccess(headers, code)
                end
            else
                -- Safe handling of any type of Body
                local bodyStr = ''
                if (type(Body) == 'table') then
                    -- If Body is a table, convert it to JSON
                    local success, json = pcall(util.TableToJSON, Body)
                    if success then
                        bodyStr = json
                    else
                        bodyStr = '[Table - cannot serialize]'
                    end
                elseif (type(Body) == 'string') then
                    bodyStr = Body
                else
                    bodyStr = _tostring(Body)
                end
                
                DBase:PrintType('Logs', Red, ' Discord returned HTTP: ', color_white, _tostring(code))
                
                -- We limit the output length (no more than 500 characters)
                if (#bodyStr > 500) then
                    bodyStr = _stringSub(bodyStr, 1, 500) .. '... (truncated)'
                end
                
                _queueLog(url, payload)
                
                if onFailed then
                    onFailed('HTTP ' .. _tostring(code) .. ': ' .. bodyStr)
                end
            end
        end,
        failure = function(reason)
            DBase:PrintType('Logs', Red, ' Request failed: ', color_white, _tostring(reason))
            _queueLog(url, payload)
            
            if onFailed then
                onFailed(reason)
            end
        end
    })
end

--- Retrieves configured Discord webhooks from DanLib configuration
-- @return table Webhooks configuration table
-- @private
local function _getWebhooks()
    local values = DanLib.ConfigMeta.BASE:GetValue('Logs') or {}
    local webhooks = {}

    for i in pairs(values) do
        webhooks = { i, values }
    end

    return webhooks
end

--- Sends a Discord log using the batch system (recommended method)
-- @param logObject (table): Log configuration object (from CreateLogs)
-- @param description (string): Log description/message
-- @param fields (table|nil): Array of embed fields {name, value, inline}
-- @param colorOverride (Color|nil): Override the default log color
-- @return void
-- @example DBase:SendDiscordLog(CONFIG, 'Player changed config', { { name='Player', value='John' } }, Color(255,0,0))
function DBase:SendDiscordLog(logObject, description, fields, colorOverride)
    if (not logObject or not logObject.ID) then
        DBase:PrintType('Logs', Red, ' Invalid log object!')
        return
    end
    
    local webhooks = _getWebhooks()[2]
    if (not webhooks) then
        return
    end
    
    local moduleID = logObject.ID
    local addonName = logObject.Addon or 'Unknown'
    local priority = logObject.Priority or 3
    local color = colorOverride or logObject.Color or Color(23, 100, 200)
    local title = addonName .. ' ➞ ' .. moduleID
    
    for key, config in pairs(webhooks) do
        local webhookURL = config.Webhook
        local webhookName = config.Name or 'Webhook'
        local isModuleEnabled = config.Modules[moduleID]
        
        if (webhookURL and webhookURL ~= '' and isModuleEnabled) then
            _addToBatch(webhookURL, webhookName, title, description or '', fields or {}, color, priority)
        end
    end
end

--- Legacy method for sending Discord logs (backward compatibility)
-- @param moduleID (string): Module identifier
-- @param description (string): Log description
-- @param fields (table|nil): Array of embed fields
-- @param color (Color|nil): Embed color
-- @return void
-- @deprecated Use SendDiscordLog or logObject:Send() instead
-- @example DBase:GetDiscordLogs('Configuration', 'Config changed', { { name='User', value='Admin' } })
function DBase:GetDiscordLogs(moduleID, description, fields, color)
    local logObject = DanLib.ModulesMetaLogs[moduleID]
    if logObject then
        self:SendDiscordLog(logObject, description, fields, color)
    else
        DBase:PrintType('Logs', Red, ' Unknown module: ', color_white, moduleID)
    end
end
