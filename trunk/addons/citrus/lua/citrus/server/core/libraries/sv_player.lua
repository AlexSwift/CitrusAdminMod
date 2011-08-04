--[[
Name: "sv_player.lua".
Product: "Citrus (Server Management)".
--]]

citrus.Player = {}

-- Player Spawn.
function citrus.Player.PlayerSpawn(Player)
	if (citrus.PlayerVariables.Exists(Player)) then citrus.Hooks.Call("OnPlayerSpawn", Player) end
end

-- Add.
hook.Add("PlayerSpawn", "citrus.Player.PlayerSpawn", citrus.Player.PlayerSpawn)

-- Is Immune.
function citrus.Player.IsImmune(Player, Target)
	if (citrus.Player.GetGroup(Player):GetSetting("Rank") <= citrus.Player.GetGroup(Target):GetSetting("Rank")) then
		return false
	else
		if (citrus.Access.Has(Target, "I")) then return Target:Name().." is immune!" end
		
		-- Return False.
		return false
	end
end

-- Console Command.
function citrus.Player.ConsoleCommand(Player, Command)
	umsg.Start("citrus.ConsoleCommand", Player)
		umsg.String(Command)
	umsg.End()
end

-- Player Initial Spawn.
function citrus.Player.PlayerInitialSpawn(Player)
	citrus.PlayerCookies.Create(Player)
	citrus.PlayerVariables.Load(Player)
	citrus.PlayerVariables.Create(Player)
	citrus.Player.SetVariables(Player)
end

-- Add.
hook.Add("PlayerInitialSpawn", "citrus.Player.PlayerInitialSpawn", citrus.Player.PlayerInitialSpawn)

-- Add.
concommand.Add("cl_citrus_initialize", function(Player, Command, Arguments)
	if (!citrus.PlayerCookies.Get(Player, "Initialized")) then
		citrus.Player.IncludePlugins(Player)
		
		-- Set.
		citrus.PlayerCookies.Set(Player, "Initialized", true)
		
		-- Call.
		citrus.Hooks.Call("OnPlayerInitialSpawn", Player)
	end
end)

-- Set Variables.
function citrus.Player.SetVariables(Player)
	citrus.PlayerVariables.New(Player, "Seconds Played", 0)
	citrus.PlayerVariables.New(Player, "Time Played", {Hours = 0, Minutes = 0, Seconds = 0})
	citrus.PlayerCookies.New(Player, "Initialized", false)
	
	-- Call.
	citrus.Hooks.Call("OnPlayerSetVariables", Player)
end

-- Get.
function citrus.Player.Get(Player)
	local Players = player.GetAll()
	
	-- For Loop.
	for K, V in pairs(Players) do
		local Identities = {V:Name(), V:SteamID(), citrus.Player.GetUniqueID(V), V:IPAddress()}
		
		-- For Loop.
		for K2, V2 in pairs(Identities) do
			if (string.find(string.lower(V2), string.lower(Player))) then return V end
		end
	end
	
	-- Return False.
	return false, "Unable to locate '"..Player.."'!"
end

-- Get Unique ID.
function citrus.Player.GetUniqueID(Player)
	local UniqueID = Player:UniqueID()
	
	-- Is Listen Server Host.
	local IsListenServerHost = Player:IsListenServerHost()
	local IsSinglePlayer = SinglePlayer()
	
	-- Check Is Listen Server Host.
	if (IsListenServerHost or IsSinglePlayer) then return util.CRC("Server Host") end
	
	-- Return Unique ID.
	return UniqueID
end

-- Get Group.
function citrus.Player.GetGroup(Player)
	local UniqueID = citrus.Player.GetUniqueID(Player)
	
	-- Check Unique ID.
	if (citrus.Groups.Players[UniqueID]) then
		return citrus.Groups.Get(citrus.Groups.Players[UniqueID].Group)
	else
		return citrus.Groups.Default
	end
end

-- Include Plugins.
function citrus.Player.IncludePlugins(Player)
	umsg.Start("citrus.Plugins.IncludeAll", Player) umsg.End()
	
	-- For Loop.
	for K, V in pairs(citrus.Plugins.Loaded) do V:ClientSideLoad(Player) end
end

-- Update Information.
function citrus.Player.UpdateInformation(Player)
	local SecondsPlayed = citrus.PlayerVariables.Get(Player, "Seconds Played")
	local Access = citrus.PlayerVariables.Get(Player, "Access")
	
	-- Time Played.
	local TimePlayed = citrus.Utilities.GetFormattedTime(SecondsPlayed, "%hh %mm %ss")
	
	-- Set.
	citrus.PlayerInformation.Set(Player, "Public", "Group", citrus.Player.GetGroup(Player).Name)
	citrus.PlayerInformation.Set(Player, "Public", "Time Played", TimePlayed)
	citrus.PlayerInformation.Set(Player, "Public", "Group Access", Access.Group)
	citrus.PlayerInformation.Set(Player, "Public", "Custom Access", Access.Custom)
	
	-- Time Played.
	TimePlayed = string.gsub(TimePlayed, "[hms]", "")
	
	-- Exploded.
	local Exploded = string.Explode(" ", TimePlayed)
	
	-- Set.
	citrus.PlayerVariables.Get(Player, "Time Played").Hours = tonumber(Exploded[1])
	citrus.PlayerVariables.Get(Player, "Time Played").Minutes = tonumber(Exploded[2])
	citrus.PlayerVariables.Get(Player, "Time Played").Seconds = tonumber(Exploded[3])
end

-- On Think.
function citrus.Player.OnThink()
	local Players = player.GetAll()
	
	-- For Loop.
	for K, V in pairs(Players) do
		if (ValidEntity(V)) then
			if (citrus.PlayerVariables.Exists(V)) then citrus.Hooks.Call("OnPlayerThink", V) end
		end
	end
end

-- Add.
citrus.Hooks.Add("OnThink", citrus.Player.OnThink)

-- On Second.
function citrus.Player.OnSecond()
	local Players = player.GetAll()
	
	-- For Loop.
	for K, V in pairs(Players) do
		if (ValidEntity(V)) then
			if (citrus.PlayerVariables.Exists(V)) then
				citrus.PlayerVariables.Set(V, "Seconds Played", citrus.PlayerVariables.Get(V, "Seconds Played") + 1)
				
				-- Call.
				citrus.Hooks.Call("OnPlayerSecond", V)
				
				-- Update Information.
				citrus.Player.UpdateInformation(V)
			end
		end
	end
end

-- Add.
citrus.Hooks.Add("OnSecond", citrus.Player.OnSecond)

-- On Minute.
function citrus.Player.OnMinute()
	local Players = player.GetAll()
	
	-- For Loop.
	for K, V in pairs(Players) do
		if (ValidEntity(V)) then
			if (citrus.PlayerVariables.Exists(V)) then citrus.Hooks.Call("OnPlayerMinute", V) end
		end
	end
end

-- Add.
citrus.Hooks.Add("OnMinute", citrus.Player.OnMinute)

-- Kick.
function citrus.Player.Kick(Player, Reason)
	citrus.Utilities.ConsoleCommand("kickid", Player:UserID(), Reason)
end

-- Notify By Access.
function citrus.Player.NotifyByAccess(Access, Message, Type)
	local Players = player.GetAll()
	
	-- For Loop.
	for K, V in pairs(Players) do
		if (citrus.Access.Has(V, Access)) then citrus.Player.Notify(V, Message, Type) end
	end
	
	-- Call.
	citrus.Hooks.Call("OnNotifyByAccess", Access, Message, Type)
end

-- Notify All.
function citrus.Player.NotifyAll(Message, Type)
	local Players = player.GetAll()
	
	-- For Loop.
	for K, V in pairs(Players) do citrus.Player.Notify(V, Message, Type) end
	
	-- Call.
	citrus.Hooks.Call("OnNotifyAll", Message, Type)
end

-- Notify.
function citrus.Player.Notify(Player, Message, Type)
	local Time = RealTime()
	
	-- Check Type.
	if (Type) then if (Type > 4 or Type < 0) then Type = false end end
	
	-- Check Len.
	if (string.len(Message) > 128) then Message = string.sub(Message, 1, 128).."-" end
	
	-- Check Type.
	if (!Type) then
		Player:PrintMessage(3, Message)
	else
		umsg.Start("citrus.Notices.Add", Player)
			umsg.Short(Type)
			umsg.String(Message)
		umsg.End()
		
		-- Print Message.
		Player:PrintMessage(2, Message)
	end
end

-- Countdown Add.
function citrus.Player.CountdownAdd(Player, Name, Title, Time)
	umsg.Start("citrus.Countdowns.Add", Player)
		umsg.String(Name)
		umsg.String(Title)
		umsg.Long(CurTime() + Time)
	umsg.End()
end

-- Countdown Remove.
function citrus.Player.CountdownRemove(Player, Name)
	umsg.Start("citrus.Countdowns.Remove", Player)
		umsg.String(Name)
	umsg.End()
end

-- Overlay Add.
function citrus.Player.OverlayAdd(Player, Name, Title, Text, Alpha)
	umsg.Start("citrus.Overlays.Add", Player)
		umsg.String(Name)
		umsg.String(Title)
		umsg.String(Text)
		umsg.Short(Alpha)
	umsg.End()
end

-- Overlay Remove.
function citrus.Player.OverlayRemove(Player, Name)
	umsg.Start("citrus.Overlays.Remove", Player)
		umsg.String(Name)
	umsg.End()
end