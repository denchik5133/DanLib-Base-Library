/***
 *   @addon         DanLib
 *   @version       1.0.0
 *   @release_date  15/12/2025
 *   @author        denchik
 *   @contact       Discord: denchik_gm
 *                  Steam: https://steamcommunity.com/profiles/76561198405398290/
 *                  GitHub: https://github.com/denchik5133
 *   
 *   @description   Server Debug Hooks & Commands
 *   @license       MIT License
 */



local DEBUG = DanLib.DEBUG
local _IsValid = IsValid
local _osDate = os.date
local _ipairs = ipairs
local _playerGetAll = player.GetAll
local _stringFormat = string.format

-- Lua execution error
hook.Add('OnLuaError', 'DanLib.Debug.ServerError', function(err, realm, stack, name, id)
    if (realm ~= 'server') then
        return
    end
    
    if (not DEBUG:IsEnabled()) then
        return
    end
    
    local fullError = err
    if (name and name ~= '') then
        fullError = _stringFormat('%s (in %s)', err, name)
    end
    
    if DEBUG:ShouldCatchError(fullError) then
        -- Adding it to the server logs
        DEBUG:CatchError(fullError, stack)
        
        -- Sending to clients
        local errorEntry = {
            error = fullError,
            stack = stack or '',
            timestamp = _osDate('%H:%M:%S'),
            realm = 'SERVER',
            type = 'RUNTIME'
        }
        
        for _, ply in _ipairs(_playerGetAll()) do
            if DEBUG:CanPlayerDebug(ply) then
                net.Start('DanLib.Debug.ServerError')
                net.WriteTable(errorEntry)
                net.Send(ply)
            end
        end
    end
end)

--- Exporting logs
concommand.Add('danlib_debug_export', function(pPlayer, cmd, args)
    if (_IsValid(pPlayer) and not DEBUG:CanPlayerDebug(pPlayer)) then
        pPlayer:ChatPrint('[DanLib Debug] Access denied.')
        return
    end
    
    -- Parameters: [1] = filename, [2] = format
    local filename = args[1] -- nil = automatic name
    local format = args[2] or 'txt' -- txt or json
    
    DEBUG:ExportLogs(filename, true, format)
    
    local actualFilename = filename or _stringFormat('server_debug_%s.%s', os.date('%Y%m%d_%H%M%S'), format)
    local msg = _stringFormat('[DanLib Debug] Logs exported to: data/%s', actualFilename)
    
    if _IsValid(pPlayer) then
        pPlayer:ChatPrint(msg)
    else
        print(msg)
    end
end)
