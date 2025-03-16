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
 *   sh_network.lua
 *   This file is responsible for managing network communication in the DanLib project.
 *
 *   It includes the following functions:
 *   - Checking if a variable has been provided (IsValueProvided).
 *   - Validating if a value is a number (IsNumber).
 *   - Validating if a value is a string (IsString).
 *   - Starting a network message (Start).
 *   - Writing unsigned integers to a network message (WriteUInt).
 *   - Writing signed integers to a network message (WriteInt).
 *   - Writing strings to a network message (WriteString).
 *   - Writing entities to a network message (WriteEntity).
 *   - Reading entities from a network message (ReadEntity).
 *   - Writing booleans to a network message (WriteBool).
 *   - Reading booleans from a network message (ReadBool).
 *   - Writing tables to a network message (WriteTable).
 *   - Reading tables from a network message (ReadTable).
 *   - Broadcasting a network message to all clients (Broadcast).
 *   - Sending a network message to a specific player (SendToPlayer).
 *   - Sending a network message to the server (SendToServer).
 *   - Reading unsigned integers from a network message (ReadUInt).
 *   - Reading signed integers from a network message (ReadInt).
 *   - Receiving a network message (Receive).
 *
 *   The file provides a comprehensive interface for handling network operations in the project,
 *   ensuring robust communication between clients and the server.
 */


--- Shared online library for DanLib
DanLib.Network = DanLib.Network or {}


--- Function to check if a variable has been entered
-- @param value: The value to be checked.
-- @return: true if the variable has been entered, otherwise false.
function DanLib.Network:IsValueProvided(value)
    return value ~= nil
end


--- Function to check if the value is a number
-- @param value: The value to be checked.
-- @return: true if the value is a number, otherwise false.
function DanLib.Network:IsNumber(value)
    return type(value) == 'number'
end


--- Function to check if the value is a string
-- @param value: The value to check.
-- @return: true if the value is a string, otherwise false.
function DanLib.Network:IsString(value)
    return type(value) == 'string'
end


--- Function for starting a network message
-- @param name: The name of the network message to be sent.
function DanLib.Network:Start(name)
	assert(self:IsString(name), 'Name for Start is not provided or is not a string.')
    net.Start(name)
end


--- Function for writing an unsigned integer to a network message
-- @param value: The value of the unsigned integer to be written.
-- @param bits: The number of bits used to represent the value.
function DanLib.Network:WriteUInt(value, bits)
	assert(self:IsValueProvided(value), 'Value for WriteUInt is not provided.')
    assert(self:IsNumber(bits), 'Bits for WriteUInt is not provided or is not a number.')
    net.WriteUInt(value, bits)
end


--- Function for reading an unsigned integer from a network message
-- @param bits: The number of bits used to represent the value.
-- @return: The unsigned integer read from the network message.
function DanLib.Network:ReadUInt(bits)
    assert(self:IsNumber(bits), 'Bits for ReadUInt is not provided or is not a number.')
    return net.ReadUInt(bits)
end


--- Function for writing a signed integer to a network message
-- @param value: The value of the signed integer to be written.
-- @param bits: The number of bits used to represent the value.
function DanLib.Network:WriteInt(value, bits)
	assert(self:IsValueProvided(value), 'Value for WriteInt is not provided.')
    assert(self:IsNumber(bits), 'Bits for WriteInt is not provided or is not a number.')
    net.WriteInt(value, bits)
end


--- Function for reading a signed integer from a network message
-- @param bits: The number of bits used to represent the value.
-- @return: The signed integer read from the network message.
function DanLib.Network:ReadInt(bits)
    assert(self:IsNumber(bits), 'Bits for ReadInt is not provided or is not a number.')
    return net.ReadInt(bits)
end


--- Function for writing a string to a network message
-- @param value: String to be written to the network message.
function DanLib.Network:WriteString(value)
	assert(self:IsValueProvided(value), 'Value for WriteString is not provided.')
    net.WriteString(value)
end


--- Function for reading a string from a network message
-- @return: The string read from the network message.
function DanLib.Network:ReadString()
    return net.ReadString()
end


--- Function for writing an entity to a network message
-- @param entity: The entity to be written to the network message.
function DanLib.Network:WriteEntity(entity)
	assert(self:IsValueProvided(entity), 'Value for WriteEntity is not provided.')
    net.WriteEntity(entity)
end


--- Function for reading an entity from a network message
-- @return: The entity read from the network message.
function DanLib.Network:ReadEntity()
    return net.ReadEntity()
end


--- Function for writing a table to a network message
-- @param tbl: Table to be written to the network message.
function DanLib.Network:WriteTable(tbl)
	assert(self:IsValueProvided(tbl), 'Value for WriteTable is not provided.')
    net.WriteTable(tbl)
end


--- Function for reading a table from a network message
-- @return: The table read from the network message.
function DanLib.Network:ReadTable()
    return net.ReadTable()
end


--- Function for writing a boolean to a network message
-- @param value: The boolean value to be written.
function DanLib.Network:WriteBool(value)
    assert(self:IsValueProvided(value), 'Value for WriteBool is not provided.')
    assert(type(value) == 'boolean', 'Value for WriteBool is not a boolean.')
    net.WriteBool(value)
end


--- Function for reading a boolean from a network message
-- @return: The boolean read from the network message.
function DanLib.Network:ReadBool()
    return net.ReadBool()
end


--- Function for sending a network message to all clients
-- @param name: The name of the network message to be sent to all clients.
function DanLib.Network:Broadcast(name)
	assert(self:IsString(name), 'Name for Broadcast is not provided or is not a string.')
    net.Broadcast()
end


--- Function for sending a network message to a specific player
-- @param pPlayer: The player to whom the network message will be sent.
function DanLib.Network:SendToPlayer(pPlayer)
	assert(self:IsValueProvided(pPlayer), 'Player for SendToPlayer is not provided.')
    net.Send(pPlayer)
end


--- Function for sending a network message to the server
function DanLib.Network:SendToServer()
    net.SendToServer()
end


--- Function for receiving a network message
-- @param name: The name of the network message to be received.
-- @param func: The function to be called when the network message is received.
function DanLib.Network:Receive(name, func)
    assert(self:IsString(name), 'Name for Receive is not provided or is not a string.')
    assert(self:IsValueProvided(func), 'Function for Receive is not provided.')
    net.Receive(name, func)
end
