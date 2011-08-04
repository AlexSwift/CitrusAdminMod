--[[
Name: "sv_vote.lua".
Product: "Citrus (Server Management)"
--]]

local COMMAND = citrus.Command:New("vote", "M", {{"Title", "string"}, {"Option", "string"}, {"...", "string", true}})

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Commands")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- Callback.
function COMMAND.Callback(Player, Arguments)
	local Vote = citrus.Vote:New(Arguments[1])
	
	-- Set Time.
	Vote:SetTime(30)
	
	-- Remove.
	table.remove(Arguments, 1)
	
	-- For Loop.
	for K, V in pairs(Arguments) do Vote:OptionAdd(V) end
	
	-- Send.
	Vote:Send()
	
	-- Notify By Access.
	citrus.Player.NotifyByAccess("M", "A vote is started ("..Player:Name()..").", 0)
	citrus.Player.NotifyByAccess("!M", "A vote is started.", 0)
end

-- Create.
COMMAND:Create()