local pMeta = FindMetaTable('Player')

function DanLib:SendMessage(ply, MSG_TYPE, ...)
    local args = {...}
    
    if SERVER then
        net.Start('DanLib.Msg')
            net.WriteInt(MSG_TYPE, 8)
            net.WriteTable(args)
        net.Send(ply)
    end
    
    if CLIENT then
        net.Start('DanLib.Msg')
            net.WriteEntity(ply)
            net.WriteInt(MSG_TYPE, 8)
            net.WriteTable(args)
        net.SendToServer()
    end
end 

function pMeta:SendMessage(MSG_TYPE, ...)
    DanLib:SendMessage(self, MSG_TYPE, ...)
end

function DanLib:SendMessageDist(ply, MSG_TYPE, dist, ...) 
    if !IsValid(ply) then return end

    local args = {...}

    if dist == 0 then
        for _, v in pairs( player.GetAll() ) do
            DanLib:SendMessage(v, MSG_TYPE, unpack(args))
        end
    else
        for _, v in ipairs(player.GetAll()) do
            if IsValid(v) and v:GetPos():Distance(ply:GetPos()) <= dist then
                DanLib:SendMessage(v, MSG_TYPE, unpack(args))
            end
        end
    end
end

if (SERVER) then
    function DanLib:SendConsoleMessage(...) 
        for _, v in pairs( player.GetAll() ) do
            DanLib:SendMessage(v, 0, Color(225, 0, 0), '[КОНСОЛЬ] ', Color(255, 255, 255), ...)
        end
    end
    
    function DanLib:SendServerMessage(...) 
        for _, v in pairs( player.GetAll() ) do
            DanLib:SendMessage(v, 0, Color(225, 0, 0), '[THR] ', Color(255, 255, 255), ...)
        end
    end

    function DanLib:SendGlobalMessage(...) 
        for _, v in pairs( player.GetAll() ) do
            DanLib:SendMessage(v, 0, Color(255, 255, 255), ...)
        end
    end

end

-- Functions for getting links/colors and not only, it's just more convenient
hook.Add('DanLib::ConfigLoaded', 'DanLib::ConfigRelatedStuff', function()
    function l(name)
        return DanLib.Config.Links[name]
    end
    
    function c(name)
        return DanLib.Config.Theme[name]
    end
end)