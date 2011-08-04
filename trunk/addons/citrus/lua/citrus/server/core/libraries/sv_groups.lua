--[[
Name: "sv_groups.lua".
Product: "Citrus (Server Management)".
--]]

citrus.Group = {}
citrus.Groups = {}
citrus.Groups.Stored = {}

-- Users.
local Users = util.KeyValuesToTable(file.Read("../settings/users.txt")) 

-- New.
function citrus.Group:New(Name)
	local Table = {}
	
	-- Set Meta Table.
	setmetatable(Table, self)
	
	-- Index.
	self.__index = self
	
	-- Name.
	Table.Name = Name
	
	-- Settings.
	Table.Settings = {}
	Table.Settings["Access"] = ""
	Table.Settings["User Group"] = "user"
	
	-- Return Table.
	return Table
end

-- Set Setting.
function citrus.Group:SetSetting(Key, Value) self.Settings[Key] = Value end
function citrus.Group:GetSetting(Key) return self.Settings[Key] end

-- Create.
function citrus.Group:Create()
	citrus.Groups.Stored[self.Name] = self
end

-- Get.
function citrus.Groups.Get(Group)
	for K, V in pairs(citrus.Groups.Stored) do
		if (string.lower(V.Name) == string.lower(Group)) then return V end
	end
	
	-- Return False.
	return false, "Unable to locate '"..Group.."'!"
end

-- Get By Setting.
function citrus.Groups.GetBySetting(Setting, Value)
	for K, V in pairs(citrus.Groups.Stored) do
		if (V:GetSetting(Setting) == Value) then return V end
	end
	
	-- Return False.
	return false
end

-- On Player Initial Spawn.
function citrus.Groups.OnPlayerInitialSpawn(Player)
	local IsSinglePlayer = SinglePlayer()
	local IsListenServerHost = Player:IsListenServerHost()
	
	-- Check Is Single Player.
	if (IsSinglePlayer or IsListenServerHost) then
		local Group = citrus.Groups.GetBySetting("Rank", 1)
		
		-- Check Group.
		if (Group) then
			citrus.Groups.Set(Player, Group)
			
			-- Return.
			return
		end
	end
	
	-- Steam ID.
	local SteamID = Player:SteamID()
	local UserGroup = "user"
	
	-- For Loop.
	for K, V in pairs(Users) do
		for K2, V2 in pairs(V) do
			if (V2 == SteamID) then UserGroup = K end
		end
	end
	
	-- Check User Group.
	if (UserGroup != "user") then
		for K, V in pairs(citrus.Groups.Stored) do
			if (V:GetSetting("User Group") == UserGroup) then
				local Group = citrus.Player.GetGroup(Player)
				
				-- Check Group.
				if (!Group or Group:GetSetting("Rank") > V:GetSetting("Rank")) then
					citrus.Groups.Set(Player, V)
					
					-- Return.
					return
				end
			end
		end
	end
	
	-- Offline Players.
	local OfflinePlayers = citrus.ServerVariables.Get("Offline Players")
	
	-- Check Steam ID.
	if (OfflinePlayers[SteamID]) then
		local Group = citrus.Groups.Get(Group)
		
		-- Check Group.
		if (Group) then citrus.Groups.Set(Player, Group) end
		
		-- Steam ID.
		OfflinePlayers[SteamID] = nil
	end
	
	-- Group.
	local Group = citrus.Player.GetGroup(Player)
	
	-- Check Group.
	if (!Group) then
		citrus.Groups.Set(Player, citrus.Groups.Default)
	else
		citrus.Groups.Set(Player, Group)
	end
end

-- Add.
citrus.Hooks.Add("OnPlayerInitialSpawn", citrus.Groups.OnPlayerInitialSpawn)

-- Initialize.
function citrus.Groups.Initialize()
	citrus.Groups.Players = citrus.Utilities.TableLoad("players.txt") or {}
	
	-- For Loop.
	for K, V in pairs(citrus.Groups.Players) do
		if (!V.IPAddress) then V.IPAddress = "N/A" end
	end
end

-- Add.
hook.Add("Initialize", "citrus.Groups.Initialize", citrus.Groups.Initialize)

-- On Load Variables.
function citrus.Groups.OnLoadVariables()
	citrus.ServerVariables.New("Offline Players", {})
end

-- Add.
citrus.Hooks.Add("OnLoadVariables", citrus.Groups.OnLoadVariables)

-- On Save Variables.
function citrus.Groups.OnSaveVariables()
	citrus.Utilities.TableSave("players.txt", citrus.Groups.Players)
end

-- Add.
citrus.Hooks.Add("OnSaveVariables", citrus.Groups.OnSaveVariables)

-- Offline Set.
function citrus.Groups.OfflineSet(SteamID, Group)
	SteamID = string.upper(SteamID)
	
	-- Steam ID.
	citrus.ServerVariables.Get("Offline Players")[SteamID] = Group.Name
end

-- Set.
function citrus.Groups.Set(Player, Group)
	local UniqueID = citrus.Player.GetUniqueID(Player)
	
	-- UniqueID.
	if (Group == citrus.Groups.Default) then
		citrus.Groups.Players[UniqueID] = nil
	else
		citrus.Groups.Players[UniqueID] = {
			Name = Player:Name(),
			Group = Group.Name,
			SteamID = Player:SteamID(),
			IPAddress = Player:IPAddress()
		}
	end
	
	-- User Group.
	local UserGroup = Group:GetSetting("User Group")
	
	-- Check User Group.
	if (UserGroup == "user") then
		local SteamID = Player:SteamID()
		local Success = false
		
		-- For Loop.
		for K, V in pairs(Users) do
			for K2, V2 in pairs(V) do
				if (V2 == SteamID) then
					Player:SetUserGroup(K)
					
					-- Success.
					Success = true
				end
			end
		end
		
		-- Check Success.
		if (!Success) then Player:SetUserGroup("user") end
	else
		Player:SetUserGroup(UserGroup)
	end
	
	-- Call.
	citrus.Hooks.Call("OnPlayerSetGroup", Player, Group)
	
	-- Spawn.
	Player:Spawn()
end