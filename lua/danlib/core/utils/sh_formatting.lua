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

local sql = sql

local math = math
local floor = math.floor
local abs = math.abs
local round = math.Round
local max = math.max

local tostring = tostring

local string = string
local find = string.find
local format = string.format
local comma = string.Comma

local os = os
local time = os.time
local date = os.date

local table = table
local Table = DanLib.Table

local bit = bit
local band = bit.band
local rshift = bit.rshift
local bor = bit.bor
local lshift = bit.lshift

local util = util
local CRC = util.CRC
local steam_id_64 = util.SteamIDTo64
local steam_id_from_64 = util.SteamIDFrom64

local steamworks = steamworks
local get_player_name = steamworks.GetPlayerName


do
    --- Formats the number as a monetary amount.
    -- @param number The number to format.
    -- @param tg A logical value indicating whether to add a currency symbol.
    -- @return Formatted string with a monetary amount.
    function base:FormatMoney(number, tg)
        -- Adds a currency character to the string, if necessary
        local function addCurrency(str)
            return tg and (DanLib.CONFIG.BASE.CurrencySymbol .. str) or str
        end

        -- If no number is given, return 0
        if (not number) then
            return addCurrency('0')
        end

        -- Rounding off the number
        number = floor(number + 0.5) -- Rounding to the nearest integer

        -- If the number is too large or too small, we simply return it
        if (number >= 1e14) then
            return addCurrency(tostring(number))
        elseif (number <= -1e14) then
            return '-' .. addCurrency(tostring(abs(number)))
        end

        -- Determine if the number is negative
        local negative = number < 0
        number = tostring(abs(number))

        -- Find the position of the decimal point
        local dp = find(number, '%.') or #number + 1

        -- Formatting a number with commas
        for i = dp - 4, 1, -3 do
            number = number:sub(1, i) .. ',' .. number:sub(i + 1)
        end

        -- Add a zero after the decimal point if necessary
        if number:sub(-1) == '.' then
            number = number .. '0'
        end

        -- Return the formatted number including the sign
        return (negative and '-' or '') .. addCurrency(number)
    end
end


do
    --- Formats the unit of time into a string including singular and plural.
    -- @param value: The numeric value of the time.
    -- @param singular: Format for singular.
    -- @param plural: Format for plural.
    -- @param short: A logical value indicating whether to use the short format.
    -- @return: Formatted string.
    local function formatUnit(value, singular, plural, short)
        return value .. (short and (value > 1 and 's' or '') or (value > 1 and plural or singular))
    end


    --- Returns the current time in UTC format as the number of seconds since the beginning of the epoch (Unix time).
    -- @return: Current time in seconds (Unix time).
    function base:UTCTime() 
        return time(date('!*t'))
    end


    -- Returns the current date and time in the format "day.month.year hours:minutes:seconds".
    -- @return: A formatted string with the current date and time.
    function base:DateStamp()
        local t = date('*t')
        return format('%s.%s.%s  %02i:%02i:%02i', t.day, t.month, t.year, t.hour, t.min, t.sec)
    end


    --- Formats the time in seconds into a more readable form.
    -- @param time: Time in seconds.
    -- @return: Formatted string with time as days, hours, minutes and seconds.
    function base:FormatTime(time)
        if (not time) then return end

        local seconds = time % 60
        time = floor(time / 60)

        local minutes = time % 60
        time = floor(time / 60)

        local hours = time % 24
        time = floor(time / 24)

        local days = time % 7
        local weeks = floor(time / 7)

        if (weeks > 0) then
            return format('%iw %id %ih %im %is', weeks, days, hours, minutes, seconds)
        elseif (days > 0) then
            return format('%id %ih %im %is', days, hours, minutes, seconds)
        elseif (hours > 0) then
            return format('%ih %im %is', hours, minutes, seconds)
        end

        return format('%im %is', minutes, seconds)
    end


    --- Converts seconds to a more convenient unit of time.
    -- @param d: The number of seconds.
    -- @param short: A logical value indicating whether to use the short format.
    -- @return: A formatted string with units of time.
    function base:SecondsTo(d, short)
        short = short or false
        d = max(0, floor(d))

        local tbl = {}

        local periods = {
            {31556926, 'year', 'years'},
            {2678400, 'month', 'months'},
            {86400, 'day', 'days'},
            {3600, 'hour', 'hours'},
            {60, 'minute', 'minutes'},
            {1, 'second', 'seconds'}
        }

        for _, period in ipairs(periods) do
            local value = floor(d / period[1])
            if (value > 0) then
                Table:Add(tbl, formatUnit(value, period[2], period[3], short))
                d = d % period[1]
            end
        end

        return Table:Concat(tbl, ', ')
    end


    --- Determines how much time has elapsed since the specified timestamp.
    -- @param timestamp: Timestamp in seconds.
    -- @return: A formatted string indicating how much time has elapsed since the specified timestamp.
    function base:FormatHammerTime(timestamp)
        local diff = time() - tonumber(timestamp)
        local periods = {
            {60, 'second', 'seconds'},
            {60, 'minute', 'minutes'},
            {24, 'hour', 'hours'},
            {30, 'day', 'days'},
            {12, 'month', 'months'},
            {math.huge, 'year', 'years'}
        }

        for i, period in ipairs(periods) do
            if (diff < period[1]) then
                local count = floor(diff)
                return format('%d %s ago', count, count == 1 and period[2] or period[3])
            end
            diff = diff / period[1]
        end

        return 'a few years ago'
    end
end


--- Encodes a string for use in the URL.
-- @param str: String to encode.
-- @return: Encoded string.
function base:UrlEncode(str)
    if str then
        return str:gsub('([^%w])', function(c)
            return format('%%%02X', string.byte(c))
        end)
    else
        return str
    end
end


-- Helper function to create a deep copy of a table
function base:FullCopy(tab)
    if not tab then return nil end
    local res = {}
    for k, v in pairs(tab) do
        if (type(v) == 'table') then
            res[k] = table.FullCopy(v)
        elseif (type(v) == 'Vector') then
            res[k] = Vector(v.x, v.y, v.z)
        elseif (type(v) == 'Angle') then
            res[k] = Angle(v.p, v.y, v.r)
        else
            res[k] = v
        end
    end
    return res
end


--- Removes spaces at the beginning and end of the string.
-- @param str string: Input string from which to remove spaces.
-- @return string: String with no spaces at the beginning and end.
function base:TrimWhitespace(str)
    return str:match('^%s*(.-)%s*$')
end


--- Gets the translated string via the Google Translate API.
-- @param lang: The language code for the target translation (default is 'en').
-- @param inputString: String to translate (defaults to an empty string).
-- @param callback: Function to be called with the translation result.
--                  It will receive either a translated string or an error message.
function base:GetTranslatedString(lang, inputString, callback)
    -- Set default values for the parameters
    lang = lang or 'en'
    inputString = inputString or ''

    -- Immediately return the original string if the language is English or the input string is empty
    if (lang == 'en' or inputString == '') then
        callback(inputString)
        return
    end

    -- Prepare URL for API request
    -- Use URL encoding for the input string
    local urlFetch = format('https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=%s&dt=t&q=%s', lang, self:UrlEncode(inputString))

    -- Getting a transfer from the API
    DanLib.HTTP:Fetch(urlFetch, function(responseBody, responseLen, headers, successCode)
            -- Парсим JSON-ответ
            local jsonTable = DanLib.NetworkUtil:JSONToTable(responseBody)

            -- Check if the answer contains valid translation data
            if jsonTable and jsonTable[1] and jsonTable[1][1] and jsonTable[1][1][1] then
                callback(jsonTable[1][1][1]) -- Callback with translated string
            else
                callback(false, 'INVALID TABLE') -- Return an error if the answer is invalid
            end
        end,
        function(errorMsg)
            callback(false, errorMsg) -- Return an error message if the request failed
        end
    )
end


--- Creates a simple timer that calls the given function after the specified time.
-- @param time number: The time in seconds after which the function will be called. The default is 0.
-- @param func function: The function that will be called after the time has elapsed. Must be a function.
-- @return void
-- @throws error If time is not a valid number or func is not a function.
function base:TimerSimple(time, func)
    -- Convert time to a number, if possible
    time = tonumber(time) or 0 -- Convert to a number or set the default to 0

    -- Checking the type of func argument
    if (type(func) ~= 'function') then
        error('The "func" argument must be a function.')
    end

    timer.Simple(time, func) -- Creating a timer
end


do
    --- Checks if the provided SteamID64 is valid.
    -- @param id64 The SteamID64 to check.
    -- @return true if valid, false otherwise.
    function base:IsValidSteamID64(id64)
        -- Check if id64 is a number and has 17 digits
        return type(id64) == 'number' and id64 >= 76561197960265728 and id64 <= 76561197960265728 + 9999999999999999
    end


    --- Finds a player by their name.
    -- @param name The name of the player to search for.
    -- @return The player object if found, otherwise false.
    function base:FindPlayer(name)
        if (not name) then return false end

        for k, player in pairs(player.GetAll()) do
            if find(player:Name(), name, 1, true) then
                return player
            end
        end

        return false
    end

    
    local pPlayerAvatar = {}

    --- Fetches the Steam avatar for a given player ID.
    -- @param id The Steam ID of the player.
    -- @param sCback The callback function to handle the avatar URL.
    function base:SteamAvatar(id, sCback)
        if pPlayerAvatar[id] then return sCback(pPlayerAvatar[id]) end
        DanLib.HTTP:Fetch('https://steamcommunity.com/profiles/' .. id .. '/?xml=1', function(xml)
            pPlayerAvatar[id] = xml:match('<avatarFull><%!%[CDATA%[(.-)%]%]></avatarFull>')
            sCback(pPlayerAvatar[id])
        end)
    end


    --- Retrieves the Steam name for a given Steam ID.
    -- @param id The Steam ID to look up.
    -- @return The player's name or 'unknown' if not found.
    function base:SteamName(id)
        if (not id) then return 'unknown' end

        local id64 = steam_id_64(id)
        if (not id64) then return 'unknown' end

        local name = get_player_name(id64)
        return name or 'unknown'
    end


    --- Checks if a given Steam ID is valid.
    -- @param id The Steam ID to validate.
    -- @return True if the Steam ID is valid, otherwise false.
    function base:IsValidSteamID(id)
        id = id:Trim():upper()
        if id:find('STEAM_') then
            return steam_id_from_64(steam_id_64(id)) == id
        else
            return steam_id_64(steam_id_from_64(id)) == id
        end
    end


    --- Gets the Steam ID64 of a player.
    -- @param pPlayer The player object.
    -- @return The player's Steam ID64 or their name if they are a bot. 
    function base:SteamID64(pPlayer)
        if pPlayer:IsBot() then 
            return pPlayer:GetName()
        else
            return pPlayer:SteamID64()
        end
    end
end


-- Gets the server address in "IP:port" format.
-- @return: A string representing the server address in "IP:port" format.
function base:GetAddress()
    -- Get the IP and port string from the settings
    local hostIP = GetConVarString('hostip')
    local hostPort = GetConVarString('hostport')
    
    -- Convert the IP string to a number
    local address = tonumber(hostIP)

    -- If no address is specified, return the default local address
    if (not address) then
        return '127.0.0.1:' .. hostPort
    end

    -- Break the address into octets
    local ip = {
        rshift(band(address, 0xFF000000), 24),
        rshift(band(address, 0x00FF0000), 16),
        rshift(band(address, 0x0000FF00), 8),
        band(address, 0x000000FF)
    }

    -- Combine the octets into a string and add the port
    return Table:Concat(ip, '.') .. ':' .. hostPort
end


--- Converts a boolean value to an integer.
-- @param bol (boolean): The boolean value to convert.
-- @return (number): 1 if true; 0 if false.
function base:BoolToInt(bol)
    return bol and 1 or 0
end


--- Converts an integer to a boolean value.
-- @param it (number): The integer to convert (1 for true, 0 for false).
-- @return (boolean): true if 1; false if 0.
function base:IntToBool(it)
    return it == 1
end


--- Handles argument errors and sends a message to the player.
-- @param pPlayer (Player): The player to whom the message will be sent.
-- @param t (any): Argument to check.
function base:ArgError(pPlayer, t)
    local message = not t and self:L('#wrong.arg') or self:L('#access.ver')
    self:SendMessage(pPlayer, DANLIB_TYPE_ERROR, message)
end


--- Formats a number with commas.
-- @param nemer (number): The number to format.
-- @return (string): Formatted number string.
function base:MoneyFormat(nemer)
    return comma(nemer)
end


do
    --- Escapes a string for use in JSON.
    -- @param str (string): String to be escaped.
    -- @return (string): The escaped string.
    function base:JSON(str)
        return (str:gsub('\\', '\\\\'):gsub('"', '\\"'))
    end


    -- function to retrieve JSON content from a URL
    -- @param url (string): URL to retrieve the data
    -- @param callback (function): Callback function to be called with the result
    function base:FetchApiContent(url, callback)
        local result = {}  -- Table for storing the result

        -- Use pcall for error handling
        local success, err = pcall(function()
            -- Use Fetch with callback
            DanLib.HTTP:Fetch(url, function(response, length, headers, code)
                if (code ~= 200) then return end

                if response then
                    result = DanLib.NetworkUtil:JSONToTable(response)
                    if callback then callback(result) end -- Calling a callback with a result
                else
                    self:PrintError('Data not received.')
                    if callback then callback({}) end -- Calling a callback with an empty table
                end
            end)
        end)

        if (not success) then
            self:PrintError('On receipt of data:', tostring(err))
            if callback then callback({}) end -- Calling a callback with an empty table
        end
    end
end


--- Finds a player by his Steam ID.
-- @param ID (string): Steam ID of the player.
-- @return (Player|nil): Player with the specified Steam ID or nil if not found.
function base:AllPlayer(ID)
    for _, player in pairs(player.GetAll()) do
        if (player:SteamID() == ID) then return player end
    end
    return nil -- Explicitly return nil if no player is found
end


if SERVER then
    -- Stores timers for players
    function base:GetTimer(pPlayer, sWep)
        -- Initialising the timer table if it does not already exist
        self.Timers = self.Timers or {}
        local timers = self.Timers
        
        -- Initialise the timer for a player if it does not already exist
        local playerID = pPlayer:SteamID()
        timers[playerID] = timers[playerID] or {}

        -- Returns the value of the timer or 0 if no timer is set
        return timers[playerID][sWep] or 0
    end

    --- Sets the timer for the player and weapon
    -- @param pPlayer: The player for whom the timer is set
    -- @param sWep: Name of the weapon for which the timer is set
    -- @param nTime: Time in seconds for which the timer is set
    function base:SetTimer(pPlayer, sWep, nTime)
        self.Timers = self.Timers or {}
        local timers = self.Timers
        
        -- Initialise the timer for a player if it does not already exist
        local playerID = pPlayer:SteamID()
        timers[playerID] = timers[playerID] or {}

        -- Sets the timer
        timers[playerID][sWep] = time() + nTime
    end
end


--- Converts a number into a human-readable format with 'k' for thousands.
-- @param num (number): The number to convert.
-- @return (string): The formatted string representing the number in 'k' format.
function base:SimpleSum(num)
    local k = 0

    -- Reduce the number by a factor of 1000 until it's less than 1
    while num * 0.001 >= 1 do
        k = k + 1
        num = num * 0.001
    end

    -- Return the formatted number with 'k' suffix
    return sub(num, 1, 3) .. rep('k', k)
end


--- Formats a number into a human-readable string with appropriate suffixes.
-- @param num (number): The number to format.
-- @return (string): The formatted string with 'k' for thousands and 'm' for millions.
function base:FormatNumber(num)
    if (num >= 1000000) then
        return format('%.1fм', num / 1000000) -- Format for millions
    elseif (num >= 1000) then
        return format('%.1fк', num / 1000) -- Format for thousands
    else
        return tostring(num) -- Return as string if less than 1000
    end
end


-- Function for processing bindings input
-- @param input (string|number): The key input, either as a string (key name) or a number (index).
-- @param bannedKeys (table): A table containing keys that are banned from being used.
-- @return (string|number): Returns the key name if valid, the index as a string, or 'NONE' if invalid or banned.
function base:ProcessBind(input, bannedKeys)
    -- Validate input types
    if (type(input) ~= 'string' and type(input) ~= 'number') then
        error('Invalid input type: expected string or number')
    end

    if (bannedKeys and type(bannedKeys) ~= 'table') then
        error('Invalid bannedKeys type: expected table')
    end

    -- Check if input is a number
    local index = tonumber(input)
    
    if index then
        -- If input is a number, check that the index is correct
        if (index >= 0 and index < #DanLib.KEY_BINDS) then
            local keyName = DanLib.KEY_BINDS[index] -- Get the key name (indexes start from 0)
            if (bannedKeys and Table:HasValue(bannedKeys, keyName)) then
                return 'NONE' -- Return 'NONE' if the key is banned
            end
            return keyName
        else
            return 'NONE' -- Return 'NONE' if the index is out of bounds
        end
    else
        -- If input is a string (key name), look for an exact match
        for i, key in ipairs(DanLib.KEY_BINDS) do
            if (key == input) then
                if (bannedKeys and Table:HasValue(bannedKeys, key)) then
                    return 'NONE' -- Return 'NONE' if the key is banned
                end
                return tostring(i) -- Return key number (indexes start from 0)
            end
        end
        return 'NONE' -- Return 'NONE' if no match found
    end
end




do
    -- -- Define the colourTagHandler before use
    -- local function colorTagHandler(colorCode)
    --     local r, g, b, a = colorCode:match("(%d+),%s*(%d+),%s*(%d+),?%s*(%d*)")
    --     if r and g and b then
    --         return Color(tonumber(r), tonumber(g), tonumber(b), tonumber(a) or 255)
    --     else
    --         return nil
    --     end
    -- end

    -- Outputs the string
    -- function base.ParseColorTags(inputText)
    --     -- Default colour
    --     local defaultColor = 'Color(255, 255, 255, 255)'
    --     local segments = {}
    --     local index = 1

    --     while index <= #inputText do
    --         -- Find a colour tag
    --         local startColor, endColor = inputText:find('{color:%s*(%d+),%s*(%d+),%s*(%d+)}', index)

    --         if startColor then
    --             -- Add text before the colour tag, if there is one
    --             if index < startColor then
    --                 local textBeforeColor = inputText:sub(index, startColor - 1)
    --                 Table:Add(segments, string.format("'%s'", textBeforeColor:match('^%s*(.-)%s*$'))) -- Trim the gaps
    --             end
                
    --             -- Extract RGB values
    --             local r, g, b = inputText:match('{color:%s*(%d+),%s*(%d+),%s*(%d+)}', startColor)
    --             local currentColor = string.format('Color(%s, %s, %s)', r, g, b)
    --             -- Add colour tag
    --             Table:Add(segments, currentColor)

    --             -- Move index after colour tag
    --             index = endColor + 1
                
    --             -- Find the closing tag
    --             local endText = inputText:find('{/color:}', index)
    --             if endText then
    --                 -- Add text between the colour tag and the closing tag
    --                 local textBetween = inputText:sub(index, endText - 1)
    --                 Table:Add(segments, string.format("' %s '", textBetween:match('^%s*(.-)%s*$'))) -- Trim the gaps
    --                 index = endText + 9 -- Skip the closing tag
                    
    --                 -- Add the default colour after the closing tag
    --                 Table:Add(segments, defaultColor)
    --             else
    --                 -- If no closing tag is found, add the remaining text
    --                 local remainingText = inputText:sub(index)
    --                 Table:Add(segments, string.format("'%s'", remainingText:match('^%s*(.-)%s*$'))) -- Trim the gaps
    --                 break -- End the loop
    --             end
    --         else
    --             -- If no colour tag is found, add the remaining text
    --             local remainingText = inputText:sub(index)
    --             if (remainingText ~= '') then
    --                 Table:Add(segments, string.format("'%s'", remainingText:match('^%s*(.-)%s*$'))) -- Trim the gaps
    --             end
    --             break -- End the loop
    --         end
    --     end

    --     -- Combine segments into a single comma-delimited string
    --     local result = Table:Concat(segments, ', ')
    --     return result
    -- end

    -- -- Example of use
    -- local inputText = 'This is a {color: 255, 0, 0}red{/color:} text and this is {color: 0, 255, 0}green{/color:} text.'
    -- local formattedText = base.ParseColorTags(inputText)
    -- -- Print result
    -- print('Formatted text:', formattedText)


    -- Outputs a table
    -- function base.ParseColorTags(inputText)
    --     -- Default colour
    --     local defaultColor = 'Color(255, 255, 255, 255)'
    --     local segments = {}
    --     local index = 1

    --     -- Check if the text starts with a colour tag
    --     if inputText:find('{color:') then -- not inputText:find('{color:')
    --         -- If not, add default text at the beginning
    --         Table:Add(segments, defaultColor)
    --     end

    --     while index <= #inputText do
    --         -- Find a colour tag
    --         local startColor, endColor = inputText:find('{color:%s*(%d+),%s*(%d+),%s*(%d+)}', index)

    --         if startColor then
    --             -- Add text before the colour tag, if there is one
    --             if (index < startColor) then
    --                 local textBeforeColor = inputText:sub(index, startColor - 1)
    --                 Table:Add(segments, string.format("'%s'", textBeforeColor:match('^%s*(.-)%s*$'))) -- Delete extra spaces
    --             end
                
    --             -- Extract RGB values
    --             local r, g, b = inputText:match('{color:%s*(%d+),%s*(%d+),%s*(%d+)}', startColor)
    --             local currentColor = string.format('Color(%s, %s, %s)', r, g, b)
    --             -- Add colour tag
    --             Table:Add(segments, currentColor)

    --             -- Move index after colour tag
    --             index = endColor + 1
                
    --             -- Find closing tag
    --             local endText = inputText:find('{/color:}', index)
    --             if endText then
    --                 -- Add text between the colour tag and the closing tag
    --                 local textBetween = inputText:sub(index, endText - 1)
    --                 Table:Add(segments, string.format("' %s '", textBetween:match('^%s*(.-)%s*$'))) -- Delete extra spaces
    --                 index = endText + 9 -- Skip closing tag
                    
    --                 -- Add default colour after closing tag
    --                 Table:Add(segments, defaultColor)
    --             else
    --                 -- If no closing tag is found, add the remaining text
    --                 local remainingText = inputText:sub(index)
    --                 if (#remainingText > 0) then
    --                     Table:Add(segments, string.format("'%s'", remainingText:match('^%s*(.-)%s*$'))) -- Delete extra spaces
    --                 end
    --                 break -- End loop
    --             end
    --         else
    --             -- If no colour tag is found, add the remaining text
    --             local remainingText = inputText:sub(index)
    --             if (#remainingText > 0) then
    --                 Table:Add(segments, string.format("'%s'", remainingText:match('^%s*(.-)%s*$'))) -- Delete extra spaces
    --             end
    --             break -- End loop
    --         end
    --     end

    --     -- Add commas between segments
    --     for i = 1, #segments - 1 do
    --         segments[i] = segments[i] .. ', '
    --     end

    --     -- Return segment table
    --     return segments
    -- end


    -- local inputText = "This is a {color: 255, 0, 0}red{/color:} text and this is {color: 0, 255, 0}green{/color:} text."
    -- local formattedText = base.ParseColorTags(inputText)
    -- print(unpack(formattedText))

end
