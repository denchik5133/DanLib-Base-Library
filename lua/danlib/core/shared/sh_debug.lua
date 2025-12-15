/***
 *   @addon         DanLib
 *   @version       1.0.0
 *   @release_date  15/12/2025
 *   @author        denchik
 *   @contact       Discord: denchik_gm
 *                  Steam: https://steamcommunity.com/profiles/76561198405398290/
 *                  GitHub: https://github.com/denchik5133
 *   
 *   @description   Unified Debug System for DanLib (Client & Server)
 *   @license       MIT License
 */


local _IsValid = IsValid
local _Color = Color
local _MsgC = MsgC
local _pairs = pairs
local _ipairs = ipairs
local _osDate = os.date
local _CurTime = CurTime
local _SysTime = SysTime
local _fileWrite = file.Write
local _mathFloor = math.floor
local _timerCreate = timer.Create
local _timerRemove = timer.Remove
local _timerExists = timer.Exists
local _ErrorNoHalt = ErrorNoHalt
local _tableInsert = table.insert
local _tableRemove = table.remove
local _tableConcat = table.concat
local _tableCount = table.Count
local _tableHasValue = table.HasValue
local _stringFormat = string.format
local _stringLower = string.lower
local _stringFind = string.find
local _stringSub = string.sub
local _stringRep = string.rep
local _hookAdd = hook.Add
local _timerSimple = timer.Simple
local _entsGetAll = ents.GetAll
local _CompileString = CompileString
local _collectgarbage = collectgarbage
local _engineTickInterval = engine.TickInterval
local _playerGetCount = player.GetCount
local _playerGetAll = player.GetAll
local _debugTraceback = debug.traceback
local _utilTableToJSON = util.TableToJSON
local _AddNetworkString = util.AddNetworkString

-- UNIFIED DEBUG SYSTEM
DanLib.DEBUG = {
    -- Data (client and server)
    metrics = {},
    logs = {},
    timers = {},
    errors = {},
    queries = {}, -- server only
    
    -- Settings
    maxLogs = SERVER and 100 or 50,
    maxErrors = SERVER and 50 or 20,
    maxQueries = 50,
    
    -- UI settings (client only)
    panel = nil,
    
    -- Monitoring (server only)
    metricsTimer = nil
}

local DEBUG = DanLib.DEBUG

-- LOG LEVELS
DEBUG.LOG_LEVELS = {
    INFO = {
        name = 'INFO',
        priority = 1,
        color = _Color(200, 200, 200),
    },
    WARN = {
        name = 'WARN',
        priority = 2,
        color = _Color(255, 200, 100),
    },
    ERROR = {
        name = 'ERROR',
        priority = 3,
        color = _Color(255, 100, 100),
    },
    SUCCESS = {
        name = 'SUCCESS',
        priority = 1,
        color = _Color(100, 255, 100),
    },
    DEBUG = {
        name = 'DEBUG',
        priority = 0,
        color = _Color(150, 150, 255),
    },
    SQL = {
        name = 'SQL',
        priority = 2,
        color = _Color(255, 150, 255),
    },
    NETWORK = {
        name = 'NETWORK',
        priority = 1,
        color = _Color(100, 200, 255),
    },
    PERFORMANCE = {
        name = 'PERFORMANCE',
        priority = 2,
        color = _Color(255, 255, 100),
    }
}

-- ERROR FILTERING
DEBUG.ERROR_FILTERS = {
    mode = 'whitelist', -- 'whitelist' or 'blacklist'
    
    whitelist = {
        'danlib',
        'ddi',
        'addons/danlib/',
        'addons/ddi/',
        'lua/danlib/',
        'lua/ddi/',
        'DanLib.',
        'DDI.',
        'MenuBuilder:',
        'NewsSystem:',
        'DEBUG:'
    },
    
    blacklist = {
        'workshop',
        'steam',
        'entities/',
        'gamemodes/sandbox',
        'gamemodes/darkrp'
    }
}

-- PERFORMANCE THRESHOLDS
DEBUG.PERFORMANCE_THRESHOLDS = {
    SERVER = {
        SLOW = 100, -- ms - slow operation
        CRITICAL = 200 -- ms - is critically slow
    },

    CLIENT = {
        SLOW = 50, -- ms
        CRITICAL = 100 -- ms
    }
}

--- Checking the Debug mode activity
-- @return boolean
function DEBUG:IsEnabled()
    if (DanLib.CONFIG and DanLib.CONFIG.BASE) then
        return DanLib.CONFIG.BASE.Debugg
    end
    return false
end

--- Enabling/disabling Debug mode
-- @param state (boolean)
function DEBUG:SetEnabled(state)
    if (DanLib.CONFIG and DanLib.CONFIG.BASE) then
        DanLib.CONFIG.BASE.Debugg = state
    end
    
    if state then
        self:Log('Debug mode ENABLED', 'SUCCESS', 'SYSTEM')
        if SERVER then
            self:StartMetricsMonitoring()
        else
            self:OptimizeForDebug(true)
        end
    else
        self:Log('Debug mode DISABLED', 'INFO', 'SYSTEM')
        if SERVER then
            self:StopMetricsMonitoring()
        else
            self:OptimizeForDebug(false)
            if _IsValid(self.panel) then
                self.panel:Remove()
                self.panel = nil
            end
        end
    end
end

--- Error checking through filters
-- @param err (string)
-- @return boolean
function DEBUG:ShouldCatchError(err)
    if (not self:IsEnabled()) then
        return false
    end
    
    if (not err) then
        return false
    end
    
    local errLower = _stringLower(err)
    
    if (self.ERROR_FILTERS.mode == 'whitelist') then
        for _, filter in _ipairs(self.ERROR_FILTERS.whitelist) do
            if _stringFind(errLower, _stringLower(filter), 1, true) then
                return true
            end
        end
        return false
        
    elseif (self.ERROR_FILTERS.mode == 'blacklist') then
        for _, filter in _ipairs(self.ERROR_FILTERS.blacklist) do
            if _stringFind(errLower, _stringLower(filter), 1, true) then
                return false
            end
        end
        return true
    end
    
    return false
end

--- Formatting the log
-- @param text (string)
-- @param level (string)
-- @param tag (string)
-- @return table
function DEBUG:FormatLog(text, level, tag)
    level = level or 'INFO'
    tag = tag or (SERVER and 'SERVER' or 'CLIENT')
    
    return {
        text = text,
        level = level,
        tag = tag,
        time = _CurTime(),
        timestamp = _osDate('%H:%M:%S'),
        date = _osDate('%Y-%m-%d'),
        realm = SERVER and 'SERVER' or 'CLIENT'
    }
end

--- Adding a log
-- @param text (string)
-- @param level (string)
-- @param tag (string)
function DEBUG:Log(text, level, tag)
    if (not self:IsEnabled()) then
        return
    end
    
    local logEntry = self:FormatLog(text, level, tag)
    _tableInsert(self.logs, logEntry)
    
    -- Log size limit
    if (#self.logs > self.maxLogs) then
        _tableRemove(self.logs, 1)
    end
    
    -- Printing to the console
    local color = self:GetLogColor(logEntry.level)
    _MsgC(color, _stringFormat('[%s] [%s] %s\n', logEntry.level, logEntry.tag, logEntry.text))
    
    -- Updating the UI (only on the client)
    if (CLIENT and self.RefreshLogs) then
        self:RefreshLogs()
    end
end

--- Adding a metric
-- @param name (string)
-- @param value (any)
-- @param format (string)
function DEBUG:AddMetric(name, value, format)
    if (not self:IsEnabled()) then
        return
    end
    
    self.metrics[name] = {
        value = value,
        format = format or '%s',
        updated = _CurTime()
    }
end

--- Deleting a metric
-- @param name (string)
function DEBUG:RemoveMetric(name)
    self.metrics[name] = nil
end

--- Timer start
-- @param name string
function DEBUG:StartTimer(name)
    if (not self:IsEnabled()) then
        return
    end
    
    self.timers[name] = {
        start = _SysTime(),
        running = true
    }
end

--- Timer stop
-- @param name (string)
-- @return number
function DEBUG:StopTimer(name)
    if (not self:IsEnabled()) then
        return 0
    end

    if (not self.timers[name]) then
        return 0
    end
    
    local timerData = self.timers[name]
    if (not timerData.running) then
        return timerData.elapsed or 0
    end
    
    local elapsed = (_SysTime() - timerData.start) * 1000
    timerData.elapsed = elapsed
    timerData.running = false
    
    local realm = SERVER and 'SERVER' or 'CLIENT'
    local thresholds = self.PERFORMANCE_THRESHOLDS[realm]
    
    if (elapsed > thresholds.CRITICAL) then
        self:Log(_stringFormat('%s took %.2fms (CRITICAL!)', name, elapsed), 'ERROR', 'PERFORMANCE')
    elseif (elapsed > thresholds.SLOW) then
        self:Log(_stringFormat('%s took %.2fms (SLOW)', name, elapsed), 'WARN', 'PERFORMANCE')
    end
    
    _timerSimple(5, function()
        self.timers[name] = nil
    end)
    
    return elapsed
end

--- Error interception
-- @param err (string)
-- @param stack (string)
function DEBUG:CatchError(err, stack)
    if (not self:IsEnabled()) then
        return
    end
    
    local errorEntry = {
        error = err,
        stack = stack or _debugTraceback(),
        time = _CurTime(),
        timestamp = _osDate('%H:%M:%S'),
        realm = SERVER and 'SERVER' or 'CLIENT'
    }
    
    _tableInsert(self.errors, errorEntry)
    
    if (#self.errors > self.maxErrors) then
        _tableRemove(self.errors, 1)
    end
    
    self:Log(err, 'ERROR', 'RUNTIME')
    
    if SERVER then
        self:BroadcastError(errorEntry)
    end
end

--- Safe execution
-- @param func (function)
-- @param name (string)
-- @return boolean, any
function DEBUG:SafeCall(func, name)
    name = name or 'Anonymous'
    
    local success, result = pcall(func)
    if (not success) then
        self:CatchError(_stringFormat('[%s] %s', name, result))
    end
    
    return success, result
end

--- Profiling
-- @param func (function)
-- @param name (string)
-- @return any
function DEBUG:Profile(func, name)
    if (not self:IsEnabled()) then
        return func()
    end
    
    self:StartTimer(name)
    local result = func()
    self:StopTimer(name)
    
    return result
end

--- Data cleanup
function DEBUG:Clear()
    self.metrics = {}
    self.logs = {}
    self.timers = {}
    self.errors = {}

    if SERVER then
        self.queries = {}
    end
    
    self:Log('Debug data cleared', 'INFO', 'SYSTEM')
end

--- Universal filter management function filter
-- @param filter (string): filter
-- @param action (string): 'add', 'remove', 'toggle', 'check'
-- @param mode (string): 'whitelist' or 'blacklist'
-- @return (boolean|DEBUG): the result or self for the chain
function DEBUG:ErrorFilter(filter, action, mode)
    if (not filter) then 
        return false 
    end
    
    mode = mode or self.ERROR_FILTERS.mode
    action = action or 'add'
    
    local list = mode == 'whitelist' and self.ERROR_FILTERS.whitelist or self.ERROR_FILTERS.blacklist
    local exists = _tableHasValue(list, filter)
    
    -- ADD
    if (action == 'add') then
        if exists then
            self:Log(_stringFormat('Filter already exists: "%s"', filter), 'WARN', 'SYSTEM')
            return false
        end
        _tableInsert(list, filter)
        self:Log(_stringFormat('Filter added: "%s" to %s', filter, mode), 'SUCCESS', 'SYSTEM')
        return true
    
    -- REMOVE
    elseif (action == 'remove') then
        if (not exists) then
            self:Log(_stringFormat('Filter not found: "%s"', filter), 'WARN', 'SYSTEM')
            return false
        end

        for i, f in _ipairs(list) do
            if (f == filter) then
                _tableRemove(list, i)
                self:Log(_stringFormat('Filter removed: "%s" from %s', filter, mode), 'INFO', 'SYSTEM')
                return true
            end
        end
        return false
    
    -- TOGGLE (switch)
    elseif (action == 'toggle') then
        if exists then
            return self:ErrorFilter(filter, 'remove', mode)
        else
            return self:ErrorFilter(filter, 'add', mode)
        end
    
    -- CHECK (check for availability)
    elseif (action == 'check') then
        return exists
    
    -- CLEAR (clear all filters)
    elseif (action == 'clear') then
        if (mode == 'whitelist') then
            self.ERROR_FILTERS.whitelist = {}
        elseif (mode == 'blacklist') then
            self.ERROR_FILTERS.blacklist = {}
        else
            -- Clear both
            self.ERROR_FILTERS.whitelist = {}
            self.ERROR_FILTERS.blacklist = {}
        end
        self:Log(_stringFormat('Filters cleared: %s', mode or 'all'), 'INFO', 'SYSTEM')
        return true
    end
    
    return false
end

--- Add to the whitelist
-- @param filter (string)
-- @return boolean
function DEBUG:AddToWhitelist(filter)
    return self:ErrorFilter(filter, 'add', 'whitelist')
end

--- Add to Blacklist
-- @param filter (string)
-- @return boolean
function DEBUG:AddToBlacklist(filter)
    return self:ErrorFilter(filter, 'add', 'blacklist')
end

--- Remove from the whitelist
-- @param filter (string)
-- @return boolean
function DEBUG:RemoveFromWhitelist(filter)
    return self:ErrorFilter(filter, 'remove', 'whitelist')
end

--- Remove from blacklist
-- @param filter (string)
-- @return boolean
function DEBUG:RemoveFromBlacklist(filter)
    return self:ErrorFilter(filter, 'remove', 'blacklist')
end

--- Check for availability in the whitelist
-- @param filter (string)
-- @return boolean
function DEBUG:IsInWhitelist(filter)
    return self:ErrorFilter(filter, 'check', 'whitelist')
end

--- Check for blacklisted
-- @param filter (string)
-- @return boolean
function DEBUG:IsInBlacklist(filter)
    return self:ErrorFilter(filter, 'check', 'blacklist')
end

--- Getting the log color
-- @param level (string)
-- @return Color
function DEBUG:GetLogColor(level)
    local levelData = self.LOG_LEVELS[level]
    return levelData and levelData.color or _Color(255, 255, 255)
end

--- Formatting memory
-- @param kb (number)
-- @return string
function DEBUG:FormatMemory(kb)
    if (kb < 1024) then
        return _stringFormat('%d KB', _mathFloor(kb))
    elseif (kb < 1024 * 1024) then
        return _stringFormat('%.2f MB', kb / 1024)
    else
        return _stringFormat('%.2f GB', kb / 1024 / 1024)
    end
end

--- Text reduction
-- @param text (string)
-- @param maxLen (number)
-- @return string
function DEBUG:TruncateText(text, maxLen)
    maxLen = maxLen or 50
    
    if (#text <= maxLen) then
        return text
    end
    
    return _stringSub(text, 1, maxLen - 3) .. '...'
end

--- Checking the rights to view the Debug console
-- @param pPlayer (Player)
-- @return boolean
function DEBUG:CanPlayerDebug(pPlayer)
    if (not _IsValid(pPlayer)) then
        return false
    end

    -- We use the unified rights system DanLib
    if (DanLib and DanLib.Func and DanLib.Func.HasPermission) then
        return DanLib.Func.HasPermission(pPlayer, 'Debug')
    end
    
    -- Fallback in case the rights system is not loaded
    return pPlayer:IsSuperAdmin()
end

-- SERVER-ONLY FUNCTIONS
if SERVER then
    -- SQL query logging
    function DEBUG:LogQuery(query, time)
        if (not self:IsEnabled()) then
            return
        end
        
        local queryEntry = {
            query = query,
            time = time or 0,
            timestamp = _osDate('%H:%M:%S')
        }
        
        _tableInsert(self.queries, queryEntry)
        
        if (#self.queries > self.maxQueries) then
            _tableRemove(self.queries, 1)
        end
        
        if (time and time > 50) then
            self:Log(_stringFormat('SLOW QUERY (%.2fms): %s', time, self:TruncateText(query, 100)), 'WARN', 'SQL')
        end
    end
    
    -- Metric monitoring
    function DEBUG:StartMetricsMonitoring()
        if self.metricsTimer then
            return
        end
        
        self.metricsTimer = _timerCreate('DanLib.Debug.Metrics', 1, 0, function()
            if (not self:IsEnabled()) then
                return
            end
            
            self:AddMetric('Players', _playerGetCount(), '%d')
            self:AddMetric('Entities', #_entsGetAll(), '%d')
            self:AddMetric('Tickrate', _mathFloor(1 / _engineTickInterval()), '%d')
            self:AddMetric('Memory', _mathFloor(_collectgarbage('count')), '%d KB')
        end)
    end
    
    function DEBUG:StopMetricsMonitoring()
        if _timerExists('DanLib.Debug.Metrics') then
            _timerRemove('DanLib.Debug.Metrics')
        end
        self.metricsTimer = nil
    end
    
    -- Sending to the client
    function DEBUG:BroadcastLog(logEntry)
        for _, ply in _ipairs(_playerGetAll()) do
            if self:CanPlayerDebug(ply) then
                net.Start('DanLib.Debug.ServerLog')
                net.WriteTable(logEntry)
                net.Send(ply)
            end
        end
    end
    
    function DEBUG:BroadcastError(errorEntry)
        for _, ply in _ipairs(_playerGetAll()) do
            if self:CanPlayerDebug(ply) then
                net.Start('DanLib.Debug.ServerError')
                net.WriteTable(errorEntry)
                net.Send(ply)
            end
        end
    end
    
    -- Network strings
    _AddNetworkString('DanLib.Debug.ServerLog')
    _AddNetworkString('DanLib.Debug.ServerError')
    _AddNetworkString('DanLib.Debug.RequestData')
    _AddNetworkString('DanLib.Debug.SendData')
    
    -- SQL hooking
    if sql then
        local oldQuery = sql.Query
        function sql.Query(query)
            local startTime = _SysTime()
            local result = oldQuery(query)
            local elapsed = (_SysTime() - startTime) * 1000
            
            if DEBUG:IsEnabled() then
                DEBUG:LogQuery(query, elapsed)
            end
            
            return result
        end
    end
end

-- ERROR INTERCEPTION (SHARED)
local oldErrorNoHalt = _ErrorNoHalt
function ErrorNoHalt(...)
    local args = { ... }
    local err = _tableConcat(args, ' ')
    
    if DEBUG:ShouldCatchError(err) then
        DEBUG:CatchError(err)
    end
    
    oldErrorNoHalt(...)
end

-- CLIENT ERROR MONITORING
if CLIENT then
    -- Optimization for Debug
    function DEBUG:OptimizeForDebug(enabled)
        if enabled then
            if (DanLib.USERCONFIG and DanLib.USERCONFIG.BASE) then
                self._originalParticles = DanLib.USERCONFIG.BASE.ShowParticles
                DanLib.USERCONFIG.BASE.ShowParticles = false
            end
        else
            if (DanLib.USERCONFIG and DanLib.USERCONFIG.BASE and self._originalParticles ~= nil) then
                DanLib.USERCONFIG.BASE.ShowParticles = self._originalParticles
            end
        end
    end

    --- Global Lua Error Interceptor
    _timerSimple(1, function()
        if (not DEBUG:IsEnabled()) then
            return
        end
        
        _hookAdd('OnLuaError', 'DanLib.Debug.GlobalError', function(err, realm, stack, name, id)
            -- Forming a message
            local fullError = err
            if (name and name ~= '') then
                fullError = _stringFormat('%s (in %s)', err, name)
            end
            
            -- Checking the filters
            if DEBUG:ShouldCatchError(fullError) then
                -- Adding it to the log with the [PARSE] tag
                local errorType = _stringFind(err, 'expected') and 'PARSE' or 'RUNTIME'
                DEBUG:Log(_stringFormat('[%s] %s', errorType, fullError), 'ERROR', 'LUA')
                -- Adding to errors
                _tableInsert(DEBUG.errors, {
                    error = fullError,
                    stack = stack or '',
                    time = _CurTime(),
                    timestamp = _osDate('%H:%M:%S'),
                    type = errorType
                })
            end
        end)
    end)
end

-- LUA COMPILATION HOOK (SERVER)
if SERVER then
    --- Catching compilation errors
    local oldCompileString = _CompileString
    function CompileString(code, identifier, handleError)
        local func, err = oldCompileString(code, identifier, handleError)
        if (not func and err) then
            -- Compilation error
            if DEBUG:IsEnabled() and DEBUG:ShouldCatchError(err) then
                DEBUG:Log(_stringFormat('Compile error in %s: %s', identifier or 'unknown', err), 'ERROR', 'COMPILE')
            end
        end
        
        return func, err
    end
end

--- Exporting logs to a file file
-- @param filepath (string): path (optional)
-- @param includeErrors (boolean): include errors in the export
-- @param format (string): 'txt' or 'json'
-- @return (boolean): operation success
function DEBUG:ExportLogs(filepath, includeErrors, format)
    if (not self:IsEnabled()) then
        return false
    end
    format = format or 'txt'
    includeErrors = includeErrors ~= false
    
    -- Automatic prefix by realm
    if (not filepath) then
        local timestamp = _osDate('%Y%m%d_%H%M%S')
        local prefix = SERVER and 'server' or 'client'
        filepath = _stringFormat('%s_debug_%s.%s', prefix, timestamp, format)
    end
    
    local content
    
    -- TXT FORMAT
    if (format == 'txt') then
        local lines = {}
        local separator = _stringRep('=', 80)
        
        -- Заголовок
        _tableInsert(lines, separator)
        _tableInsert(lines, _stringFormat('DanLib Debug Export - %s', _osDate('%Y-%m-%d %H:%M:%S')))
        _tableInsert(lines, _stringFormat('Realm: %s', SERVER and 'SERVER' or 'CLIENT'))
        _tableInsert(lines, separator)
        _tableInsert(lines, '')
        
        -- Logs
        _tableInsert(lines, _stringFormat('--- LOGS (%d) ---', #self.logs))
        for i, log in _ipairs(self.logs) do
            _tableInsert(lines, _stringFormat('[%s] [%s] [%s] %s', 
                log.timestamp or '--:--:--',
                log.level or 'INFO',
                log.tag or 'UNKNOWN',
                log.text or ''
            ))
        end
        
        -- Mistakes
        if includeErrors and #self.errors > 0 then
            _tableInsert(lines, '')
            _tableInsert(lines, _stringFormat('--- ERRORS (%d) ---', #self.errors))
            for i, err in _ipairs(self.errors) do
                _tableInsert(lines, _stringFormat('[%s] %s', 
                    err.timestamp or '--:--:--',
                    err.error or 'Unknown error'
                ))
                if err.stack and err.stack ~= '' then
                    _tableInsert(lines, 'Stack trace:')
                    _tableInsert(lines, err.stack)
                    _tableInsert(lines, '')
                end
            end
        end
        
        -- Metrics
        if _tableCount(self.metrics) > 0 then
            _tableInsert(lines, '')
            _tableInsert(lines, '--- METRICS ---')
            for name, metric in _pairs(self.metrics) do
                _tableInsert(lines, _stringFormat('%s: %s', name, _stringFormat(metric.format, metric.value)))
            end
        end
        
        _tableInsert(lines, '')
        _tableInsert(lines, separator)
        content = _tableConcat(lines, '\n')
    -- JSON FORMAT
    elseif (format == 'json') then
        local data = {
            export_time = _osDate('%Y-%m-%d %H:%M:%S'),
            realm = SERVER and 'SERVER' or 'CLIENT',
            logs = self.logs,
            errors = includeErrors and self.errors or nil,
            metrics = self.metrics,
            queries = SERVER and self.queries or nil
        }
        
        content = _utilTableToJSON(data, true) -- Pretty print
    else
        self:Log(_stringFormat('Unknown export format: %s', format), 'ERROR', 'SYSTEM')
        return false
    end
    
    -- Conservation
    _fileWrite(filepath, content)
    self:Log(_stringFormat('Logs exported to: data/%s', filepath), 'SUCCESS', 'SYSTEM')
    return true
end

-- INITIALIZATION
_timerSimple(0.1, function()
    if (DanLib.CONFIG and DanLib.CONFIG.BASE and DanLib.CONFIG.BASE.Debugg) then
        DEBUG:SetEnabled(true)
    end
end)
