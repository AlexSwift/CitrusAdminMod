--[[
Name: "sv_redo.lua".
Product: "Citrus (Server Management)".
--]]

local COMMAND = citrus.Command:New("redo")

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Redo")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- Callback.
function COMMAND.Callback(Player, Arguments)
	local UniqueID = citrus.Player.GetUniqueID(Player)
	
	-- Index.
	local Index = 0
	
	-- For Loop.
	for K, V in ipairs(PLUGIN.Redos[UniqueID]) do Index = K end
	
	-- Redo.
	PLUGIN.Redo(Player, Index)
end

-- Create.
COMMAND:Create()