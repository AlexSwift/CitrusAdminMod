--[[
Name: "sv_plugin.lua".
Product: "Citrus (Server Management)".
--]]

local PLUGIN = citrus.Plugin:New("Logs")

-- Include.
include("sv_mysql.lua")

-- Description.
PLUGIN.Settings.Description = "Various events are saved via MySQL"
PLUGIN.Settings.Author = "Conna"

-- Configuration.
PLUGIN.Configuration = citrus.ParseINI:New("lua/"..PLUGIN.FilePath.."/sv_configuration.ini"):Parse()["Logs"]

-- COLOR_BAN.
local COLOR_BAN = "#F48C53"
local COLOR_INITIALIZE = "#4D96E0"
local COLOR_KILL = "#EF48A6"
local COLOR_NOTIFY = "#B19CDC"
local COLOR_COMMAND = "#C34DE0"
local COLOR_CONNECT = "#F7F276"
local COLOR_SAY = "#89F464"

-- Log.
function PLUGIN.Log(Color, Text)
	local Log = {
		Color = Color,
		Text = Text,
		Date = os.date("%d-%m-%y"),
		Time = os.date("%X")
	}
	
	-- Insert.
	PLUGIN.MySQL.Insert(Log)
end

-- On Load.
function PLUGIN:OnLoad()
	if (!gdatabase) then
		self:Unload(true)
	else
		local Success = PLUGIN.MySQL.Connect()
		
		-- Check Success.
		if (!Success) then
			self:Unload(true)
		elseif (!self.Initialized) then
			local Map = game.GetMap()
			
			-- Log.
			PLUGIN.Log(COLOR_INITIALIZE, Map.." has initialized")
			
			-- Initialized.
			self.Initialized = true
		end
	end
end

-- On Unload.
function PLUGIN:OnUnload() PLUGIN.MySQL.Disconnect() end

-- Do Player Death.
function PLUGIN.DoPlayerDeath(Player, Killer, DamageInfo)
	local IsPlayer = Killer:IsPlayer()
	
	-- Check Is Player.
	if (IsPlayer) then
		local Inflictor = DamageInfo:GetInflictor()
		
		-- Check Valid Entity.
		if (ValidEntity(Inflictor) and Inflictor != Killer) then
			local Class = Inflictor:GetClass()
			
			-- Log.
			PLUGIN.Log(COLOR_KILL, Player:Name().." ("..Player:SteamID()..") is killed by "..Killer:Name().." ("..Killer:SteamID()..") with "..Class)
		else
			PLUGIN.Log(COLOR_KILL, Player:Name().." ("..Player:SteamID()..") is killed by "..Killer:Name().." ("..Killer:SteamID()..")")
		end
	else
		local Class = Killer:GetClass()
		
		-- Log.
		PLUGIN.Log(COLOR_KILL, Player:Name().." is killed by "..Class)
	end
end

-- Hook Add.
PLUGIN:HookAdd("DoPlayerDeath", PLUGIN.DoPlayerDeath)

-- On Player Use PLUGIN.
function PLUGIN.OnPlayerUseCommand(Player, Command, Arguments)
	local String = ""
	
	-- For Loop.
	for K, V in pairs(Arguments) do
		if (type(V) == "Player") then
			V = V:Name()
		else
			V = tostring(V)
		end
		
		-- String.
		String = String.." ".."\""..V.."\""
	end
	
	-- Log.
	PLUGIN.Log(COLOR_COMMAND, Player:Name().." ("..Player:SteamID()..") used "..citrus.Commands.Prefix..Command.Name.." "..String)
end

-- On Player Say.
function PLUGIN.OnPlayerSay(Player, Text, Public)
	if (Public) then
		PLUGIN.Log(COLOR_SAY, Player:Name().." ("..Player:SteamID().."): "..Text)
	else
		PLUGIN.Log(COLOR_SAY, "(Team) "..Player:Name().." ("..Player:SteamID().."): "..Text)
	end
end

-- On Player Initial Spawn.
function PLUGIN.OnPlayerInitialSpawn(Player)
	PLUGIN.Log(COLOR_CONNECT, Player:Name().." ("..Player:SteamID()..") has connected")
end

-- Shut Down.
function PLUGIN.ShutDown()
	local Map = game.GetMap()
	
	-- Log.
	PLUGIN.Log(COLOR_INITIALIZE, Map.." has shut down")
end

-- Hook Add.
PLUGIN:HookAdd("ShutDown", PLUGIN.ShutDown)

-- On Notify By Access.
function PLUGIN.OnNotifyByAccess(Access, Message, Type)
	if (string.sub(Access, 1, 1) != "!") then
		PLUGIN.Log(COLOR_NOTIFY, "("..citrus.Access.GetName(Access, "or")..") "..Message)
	end
end

-- On Notify All.
function PLUGIN.OnNotifyAll(Message, Type) PLUGIN.Log(COLOR_NOTIFY, "(All) "..Message) end

-- Player Disconnected.
function PLUGIN.PlayerDisconnected(Player)
	PLUGIN.Log(COLOR_CONNECT, Player:Name().." ("..Player:SteamID()..") has disconnected")
end

-- Hook Add.
PLUGIN:HookAdd("PlayerDisconnected", PLUGIN.PlayerDisconnected)

-- On Player Banned.
function PLUGIN.OnPlayerBanned(Player, Ban)
	if (Player) then
		if (Ban.Duration > 0) then
			PLUGIN.Log(COLOR_BAN, Player:Name().." ("..Player:SteamID()..") is banned for "..citrus.Utilities.GetFormattedTime(Ban.Duration, "%hh %mm %ss"))
		else
			PLUGIN.Log(COLOR_BAN, Player:Name().." ("..Player:SteamID()..") is banned permanantly")
		end
	else
		local Name = Ban.Name
		
		-- Check Name.
		if (Name != Ban.SteamID) then Name = Name.." ("..Ban.SteamID..")" end
		
		-- Check Duration.
		if (Ban.Duration > 0) then
			PLUGIN.Log(COLOR_BAN, Name.." is banned for "..citrus.Utilities.GetFormattedTime(Ban.Duration, "%hh %mm %ss"))
		else
			PLUGIN.Log(COLOR_BAN, Name.." is banned permanantly")
		end
	end
end

-- Banned.
function PLUGIN.OnPlayerUnbanned(Ban)
	if (Ban.Name == Ban.SteamID) then
		PLUGIN.Log(COLOR_BAN, Ban.Name.." is unbanned.")
	else
		PLUGIN.Log(COLOR_BAN, Ban.Name.." ("..Ban.SteamID..") is unbanned.")
	end
end