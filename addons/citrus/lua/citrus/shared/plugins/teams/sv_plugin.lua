--[[
Name: "sv_plugin.lua".
Product: "Citrus (Server Management)".
--]]

local PLUGIN = citrus.Plugin:New("Teams")

-- Game Support.
PLUGIN.Settings.GameSupport = false
PLUGIN.Settings.Description = "Configured groups can have their own team"
PLUGIN.Settings.Gamemode = {"Sandbox", false}
PLUGIN.Settings.Author = "Conna"

-- Configuration.
PLUGIN.Configuration = citrus.ParseINI:New("lua/"..PLUGIN.FilePath.."/sv_configuration.ini"):Parse()["Teams"]

-- On Load.
function PLUGIN:OnLoad()
	local Configuration = citrus.Utilities.TableLoad("plugins/teams.txt") or {}
	
	-- Merge.
	table.Merge(PLUGIN.Configuration, Configuration)
	
	-- Check Initialized.
	if (!PLUGIN.Initialized) then
		for K, V in pairs(citrus.Groups.Stored) do
			if (PLUGIN.Configuration[V.Name]) then
				PLUGIN.SetUp(V, PLUGIN.Configuration[V.Name], true)
			end
		end
		
		-- Initialized.
		PLUGIN.Initialized = true
	end
end

-- On Save Variables.
function PLUGIN.OnSaveVariables()
	citrus.Utilities.TableSave("plugins/teams.txt", PLUGIN.Configuration)
end

-- On Player Set Variables.
function PLUGIN.OnPlayerSetVariables(Player)
	citrus.PlayerCookies.New(Player, "Downloaded Teams", {})
end

-- Set Up.
function PLUGIN.SetUp(Group, Color, Respawn)
	Group:SetSetting("Team", {Index = 10000 + Group:GetSetting("Rank")})
	
	-- Check type.
	if (type(Color) == "string") then
		Group:GetSetting("Team").Color = citrus.Utilities.GetColor(Color)
	else
		Group:GetSetting("Team").Color = Color
	end
	
	-- Name.
	PLUGIN.Configuration[Group.Name] = Color
	
	-- Set Up.
	team.SetUp(Group:GetSetting("Team").Index, Group.Name, Group:GetSetting("Team").Color)
	
	-- Usermessage Call.
	PLUGIN:UsermessageCall("SetUp", nil, function()
		umsg.String(Group.Name)
		umsg.Short(Group:GetSetting("Team").Index)
		umsg.Short(Group:GetSetting("Team").Color.r)
		umsg.Short(Group:GetSetting("Team").Color.g)
		umsg.Short(Group:GetSetting("Team").Color.b)
		umsg.Short(Group:GetSetting("Team").Color.a)
	end)
	
	-- Check Respawn.
	if (Respawn) then
		local Players = player.GetAll()
		
		-- For Loop.
		for K, V in pairs(Players) do
			if (citrus.Player.GetGroup(V) == Group) then
				V:Spawn()
			end
		end
	end
end

-- On Player Initial Spawn.
function PLUGIN.OnPlayerInitialSpawn(Player)
	for K, V in pairs(citrus.Groups.Stored) do
		if (!citrus.PlayerCookies.Get(Player, "Downloaded Teams")[V.Name]) then
			if (V:GetSetting("Team")) then
				PLUGIN:UsermessageCall("SetUp", Player, function()
					umsg.String(V.Name)
					umsg.Short(V:GetSetting("Team").Index)
					umsg.Short(V:GetSetting("Team").Color.r)
					umsg.Short(V:GetSetting("Team").Color.g)
					umsg.Short(V:GetSetting("Team").Color.b)
					umsg.Short(V:GetSetting("Team").Color.a)
				end)
				
				-- Get.
				citrus.PlayerCookies.Get(Player, "Downloaded Teams")[V.Name] = true
			end
		end
	end
end

-- On Player Spawn.
function PLUGIN.OnPlayerSpawn(Player)
	if (citrus.Player.GetGroup(Player):GetSetting("Team")) then
		Player:SetTeam(citrus.Player.GetGroup(Player):GetSetting("Team").Index)
	end
end

-- On Player Load.
function PLUGIN:OnPlayerLoad(Player) PLUGIN.OnPlayerSpawn(Player) end

-- On Player Unload.
function PLUGIN:OnPlayerUnload(Player) Player:SetTeam(TEAM_UNASSIGNED) end

-- Include Directory.
citrus.Utilities.IncludeDirectory(PLUGIN.FilePath.."/commands/", "sv_", ".lua")