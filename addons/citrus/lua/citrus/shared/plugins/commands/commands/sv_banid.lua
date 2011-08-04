--[[
Name: "sv_banid.lua".
Product: "Citrus (Server Management)".
--]]

local COMMAND = citrus.Command:New("banid", "A", {{"Steam ID", "string"}, {"Duration", "number"}, {"Name", "string", true}, {"Reason", "string", true}})

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Commands")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- Ban.
function COMMAND.Ban(SteamID, Duration, Name, Reason, Player, Console)
	Name = Name or SteamID
	
	-- Duration.
	Duration = Duration * 60
	SteamID = string.upper(SteamID)
	
	-- Banned.
	local Banned = false
	local Players = player.GetAll()
	
	-- For Loop.
	for K, V in pairs(Players) do
		if (V:SteamID() == SteamID) then
			citrus.Bans.Add(V, Name, Duration, Reason, true)
			
			-- Name.
			Name = V:Name()
			
			-- Banned.
			Banned = true
		end
	end
	
	-- Check Banned.
	if (!Banned) then citrus.Bans.OfflineAdd(SteamID, Name, Player, Duration, Reason) end
	
	-- Check Duration.
	if (Duration == 0) then
		citrus.Player.NotifyByAccess("M", Name.." is banned permanantly ("..Player..").", 0)
		citrus.Player.NotifyByAccess("!M", Name.." is banned permanantly.", 0)
		
		-- Check Console.
		if (Console) then print(Name.." is banned permanantly ("..Player..").") end
	else
		Duration = citrus.Utilities.GetFormattedTime(Duration, "%hh %mm %ss")
		
		-- Notify By Access.
		citrus.Player.NotifyByAccess("M", Name.." is banned for "..Duration.." ("..Player..").", 0)
		citrus.Player.NotifyByAccess("!M", Name.." is banned for "..Duration..".", 0)
		
		-- Check Console.
		if (Console) then print(Name.." is banned for "..Duration.." ("..Player..").") end
	end
end

-- RCon Callback.
function COMMAND.RConCallback(Arguments)
	Arguments[1] = string.upper(Arguments[1])
	
	-- Check Find.
	if (!string.find(Arguments[1], "STEAM_")) then
		print("Unable to ban corrupt Steam ID!")
		
		-- Return.
		return
	end
	
	-- Ban.
	COMMAND.Ban(Arguments[1], Arguments[2], Arguments[3], Arguments[4], "Console", true)
end

-- Callback.
function COMMAND.Callback(Player, Arguments)
	Arguments[1] = string.upper(Arguments[1])
	
	-- Check Find.
	if (!string.find(Arguments[1], "STEAM_")) then
		citrus.Player.Notify(Player, "Unable to ban corrupt Steam ID!", 1)
		
		-- Return.
		return
	end
	
	-- For Loop.
	for K, V in pairs(citrus.Groups.Players) do
		if (V.SteamID == Arguments[1]) then
			local Group = citrus.Groups.Get(V.Group)
			
			-- Check Group.
			if (Group) then
				if (citrus.Player.GetGroup(Player):GetSetting("Rank") > Group:GetSetting("Rank")) then
					citrus.Player.Notify(Player, "Unable to ban higher ranked player!", 1)
					
					-- Return.
					return
				end
			end
			
			-- Break.
			break
		end
	end
	
	-- Ban.
	COMMAND.Ban(Arguments[1], Arguments[2], Arguments[3], Arguments[4], Player:Name())
end

-- Get Duration.
function COMMAND.GetDuration(Player, Menu, Argument)
	Menu:SliderAdd("Duration", function(Player, Value)
		citrus.QuickMenu.SetArgument(Player, Argument, Value)
	end, 0, 250)
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Player Administration", "Ban ID", {{"Steam ID", citrus.QuickMenu.GetText}, {"Duration", COMMAND.GetDuration}, {"Name", citrus.QuickMenu.GetText}, {"Reason", citrus.QuickMenu.GetText}}, "gui/silkicons/exclamation")

-- Create.
COMMAND:Create()