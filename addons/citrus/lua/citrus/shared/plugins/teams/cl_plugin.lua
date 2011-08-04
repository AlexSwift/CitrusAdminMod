--[[
Name: "cl_plugin.lua".
Product: "Citrus (Server Management)"
--]]

local PLUGIN = citrus.Plugin:New("Teams")

-- Include.
include("cl_teamcolor.lua")

-- Set Up.
function PLUGIN.SetUp(Message)
	local Group = Message:ReadString()
	local Index = Message:ReadShort()
	local R = Message:ReadShort()
	local G = Message:ReadShort()
	local B = Message:ReadShort()
	local A = Message:ReadShort()
	
	-- Set Up.
	team.SetUp(Index, Group, Color(R, G, B, A))
end

-- Usermessage Hook.
PLUGIN:UsermessageHook("SetUp", PLUGIN.SetUp)