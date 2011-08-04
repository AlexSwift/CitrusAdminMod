--[[
Name: "cl_plugin.lua".
Product: "Citrus (Server Management)".
--]]

local PLUGIN = citrus.Plugin:New("News")

-- Create Client ConVar.
CreateClientConVar("cl_news_display", "1", true, true)

-- Usermessage Hook.
PLUGIN:UsermessageHook("Display", function(Message)
	local Callback = Message:ReadString()
	
	-- Check Get ConVar Number.
	if (GetConVarNumber("cl_news_display") == 1) then LocalPlayer():ConCommand(Callback.."\n") end
end)