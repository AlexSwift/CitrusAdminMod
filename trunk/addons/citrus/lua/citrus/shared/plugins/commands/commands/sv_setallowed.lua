--[[
Name: "sv_setallowed.lua".
Product: "Citrus (Server Management)"
--]]

local COMMAND = citrus.Command:New("setallowed", "M", {{"Player", "player"}, {"Event", "string"}, {"Allow", "boolean"}})

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Commands")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- Allow.
function COMMAND.Allow(Player, Event, Allow, Name, Console)
	if (Event == "All") then
		for K, V in pairs(citrus.PlayerEvent) do
			citrus.PlayerEvents.Allow(Player, "Default", citrus.PlayerEvent[K], Allow)
		end
	else
		citrus.PlayerEvents.Allow(Player, "Default", citrus.PlayerEvent[Event], Allow)
	end
	
	-- Event.
	Event = string.Trim(string.gsub(string.gsub(Event, "(%u)", " %1"), "  ", ""))
	
	-- Check Allow.
	if (Allow) then
		citrus.Player.NotifyByAccess("M", Player:Name().." is allowed to '"..Event.."' ("..Name..").")
		citrus.Player.NotifyByAccess("!M", Player:Name().." is allowed to '"..Event.."'.")
		
		-- Check Console.
		if (Console) then
			print(Player:Name().." is allowed to '"..Event.."' ("..Name..").")
		end
	else
		citrus.Player.NotifyByAccess("M", Player:Name().." is disallowed to '"..Event.."' ("..Name..").")
		citrus.Player.NotifyByAccess("!M", Player:Name().." is disallowed to '"..Event.."'.")
		
		-- Check Console.
		if (Console) then
			print(Player:Name().." is disallowed to '"..Event.."' ("..Name..").")
		end
	end
end

-- RCon Callback.
function COMMAND.RConCallback(Arguments)
	local Event = Arguments[2]
	
	-- Check Event.
	if (citrus.PlayerEvent[Event] or Event == "All") then
		COMMAND.Allow(Arguments[1], Event, Arguments[3], "Console", true)
	else
		print("Unable to locate '"..Event.."'!")
	end
end

-- Callback.
function COMMAND.Callback(Player, Arguments)
	local Error = citrus.Player.IsImmune(Player, Arguments[1])
	
	-- Check Error.
	if (Error and Player != Arguments[1] and !Arguments[3]) then citrus.Player.Notify(Player, Error, 1) return end
	
	-- Event.
	local Event = Arguments[2]
	
	-- Check Event.
	if (citrus.PlayerEvent[Event] or Event == "All") then
		COMMAND.Allow(Arguments[1], Event, Arguments[3], Player:Name())
	else
		citrus.Player.Notify(Player, "Unable to locate '"..Event.."'!", 1)
	end
end

-- Get Event.
function COMMAND.GetEvent(Player, Menu, Argument)
	Menu:ButtonAdd("All", function()
		citrus.QuickMenu.SetArgument(Player, Argument, "All")
	end)
	
	-- For Loop.
	for K, V in pairs(citrus.PlayerEvent) do
		local Text = string.Trim(string.gsub(string.gsub(K, "(%u)", " %1"), "  ", ""))
		
		-- Button Add.
		Menu:ButtonAdd(Text, function()
			citrus.QuickMenu.SetArgument(Player, Argument, K)
		end)
	end
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Player Administration", "Set Allowed", {{"Player", citrus.QuickMenu.GetPlayer}, {"Event", COMMAND.GetEvent}, {"Allow", citrus.QuickMenu.GetBoolean}}, "vgui/notices/error")

-- Create.
COMMAND:Create()