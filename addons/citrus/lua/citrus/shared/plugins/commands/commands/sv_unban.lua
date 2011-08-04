--[[
Name: "sv_unban.lua".
Product: "Citrus (Server Management)"
--]]

local COMMAND = citrus.Command:New("unban", "A", {{"ID", "string"}})

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Commands")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- RCon Callback.
function COMMAND.RConCallback(Arguments)
	local Bans = citrus.Bans.GetAll()
	
	-- For Loop.
	for K, V in pairs(Bans) do
		if (string.lower(K) == string.lower(Arguments[1])) then
			citrus.Bans.Remove(K)
			
			-- Notify By Access.
			citrus.Player.NotifyByAccess("M", V.Name.." is unbanned (Console).")
			citrus.Player.NotifyByAccess("!M", V.Name.." is unbanned.")
			
			-- Print.
			print(V.Name.." is unbanned (Console).")
			
			-- Return.
			return
		end
	end
	
	-- Print.
	print(Player, "Unable to locate '"..Arguments[1].."'!", 1)
end

-- Callback.
function COMMAND.Callback(Player, Arguments)
	local Bans = citrus.Bans.GetAll()
	
	-- For Loop.
	for K, V in pairs(Bans) do
		if (string.lower(K) == string.lower(Arguments[1])) then
			citrus.Bans.Remove(K)
			
			-- Notify By Access.
			citrus.Player.NotifyByAccess("M", V.Name.." is unbanned ("..Player:Name()..").")
			citrus.Player.NotifyByAccess("!M", V.Name.." is unbanned.")
			
			-- Return.
			return
		end
	end
	
	-- Notify.
	citrus.Player.Notify(Player, "Unable to locate '"..Arguments[1].."'!", 1)
end

-- Get Players.
function COMMAND.GetPlayer(Player, Menu, Argument)
	local Bans = citrus.Bans.GetAll()
	
	-- For Loop.
	for K, V in pairs(Bans) do
		Menu:ButtonAdd(V.Name, function()
			citrus.QuickMenu.SetArgument(Player, Argument, K)
		end)
	end
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Player Administration", "Unban", {{"Player", COMMAND.GetPlayer}}, "gui/silkicons/smile")

-- Create.
COMMAND:Create()