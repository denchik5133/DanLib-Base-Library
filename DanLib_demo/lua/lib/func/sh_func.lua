local pMeta = FindMetaTable('Player')

function LIB:SendMessage(ply, MSG_TYPE, ...)
    local args = {...}
    
    if SERVER then
        net.Start('Dan.Lib.Msg')
            net.WriteInt(MSG_TYPE, 8)
            net.WriteTable(args)
        net.Send(ply)
    end
    
    if CLIENT then
        net.Start('Dan.Lib.Msg')
            net.WriteEntity(ply)
            net.WriteInt(MSG_TYPE, 8)
            net.WriteTable(args)
        net.SendToServer()
    end
end 

function pMeta:SendMessage(MSG_TYPE, ...)
    LIB:SendMessage(self, MSG_TYPE, ...)
end

function LIB:SendMessageDist(ply, MSG_TYPE, dist, ...) 
    if !IsValid(ply) then return end

    local args = {...}

    if dist == 0 then
        for _, v in pairs( player.GetAll() ) do
            LIB:SendMessage(v, MSG_TYPE, unpack(args))
        end
    else
        for _, v in ipairs(player.GetAll()) do
            if IsValid(v) and v:GetPos():Distance(ply:GetPos()) <= dist then
                LIB:SendMessage(v, MSG_TYPE, unpack(args))
            end
        end
    end
end

if (SERVER) then
    function LIB:SendConsoleMessage(...) 
        for _, v in pairs( player.GetAll() ) do
            LIB:SendMessage(v, 0, Color(225, 0, 0), '[КОНСОЛЬ] ', Color(255, 255, 255), ...)
        end
    end
    
    function LIB:SendServerMessage(...) 
        for _, v in pairs( player.GetAll() ) do
            LIB:SendMessage(v, 0, Color(225, 0, 0), '[THR] ', Color(255, 255, 255), ...)
        end
    end

    function LIB:SendGlobalMessage(...) 
        for _, v in pairs( player.GetAll() ) do
            LIB:SendMessage(v, 0, Color(255, 255, 255), ...)
        end
    end

end

-- Functions for getting links/colors and not only, it's just more convenient
hook.Add('LIB::ConfigLoaded', 'LIB::ConfigRelatedStuff', function()
    function l(name)
        return LIB.Config.Links[name]
    end
    
    function c(name)
        return LIB.Config.Theme[name]
    end
end)