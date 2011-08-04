--[[
Name: "sv_plugin.lua".
Product: "Citrus (Server Management)".
--]]

local PLUGIN = citrus.Plugin:New("Attributes")

-- Game Support.
PLUGIN.Settings.GameSupport = false
PLUGIN.Settings.Description = "Configured groups can give players different attributes"
PLUGIN.Settings.Gamemode = {"Sandbox", false}
PLUGIN.Settings.Author = "Conna"

-- Configuration.
PLUGIN.Configuration = citrus.ParseINI:New("lua/"..PLUGIN.FilePath.."/sv_configuration.ini"):Parse()

-- On Load.
function PLUGIN:OnLoad()
	local Configuration = citrus.Utilities.TableLoad("plugins/attributes.txt") or {}
	
	-- Merge.
	table.Merge(PLUGIN.Configuration, Configuration)
	
	-- Check Initialized.
	if (!PLUGIN.Initialized) then
		for K, V in pairs(citrus.Groups.Stored) do
			V:SetSetting("Attributes", {})
			
			-- Name.
			PLUGIN.Configuration[V.Name] = PLUGIN.Configuration[V.Name] or {}
			
			-- Check Name.
			if (PLUGIN.Configuration[V.Name]) then
				for K2, V2 in pairs(PLUGIN.Configuration[V.Name]) do
					if (K2 == "Weapons") then
						if (type(V2) == "string") then
							PLUGIN.Configuration[V.Name][K2] = citrus.Utilities.Explode(V2, ",")
						end
					end
					
					-- Get Setting.
					V:GetSetting("Attributes")[K2] = PLUGIN.Configuration[V.Name][K2]
				end
			end
		end
		
		-- Initialized.
		PLUGIN.Initialized = true
	end
end

-- On Save Variables.
function PLUGIN.OnSaveVariables()
	citrus.Utilities.TableSave("plugins/attributes.txt", PLUGIN.Configuration)
end

-- On Player Spawn.
function PLUGIN.OnPlayerSpawn(Player)
	local Group = citrus.Player.GetGroup(Player)
	local Attributes = Group:GetSetting("Attributes")
	
	-- Check Health.
	if (Attributes["Health"]) then
		Player:SetHealth(Attributes["Health"])
		Player:SetMaxHealth(Attributes["Health"])
	end
	if (Attributes["Armor"]) then Player:SetArmor(Attributes["Armor"]) end
end

-- Player Loadout.
function PLUGIN.PlayerLoadout(Player)
	local Group = citrus.Player.GetGroup(Player)
	local Attributes = Group:GetSetting("Attributes")

	-- Check Weapons.
	if (Attributes["Weapons"]) then
		local Weapons = Attributes["Weapons"]
		
		-- Count.
		if (table.Count(Weapons) == 0) then return end
		
		-- For Loop.
		for K, V in pairs(Weapons) do Player:Give(V) end
		
		-- Return True.
		return true
	end
end

-- Hook Add.
PLUGIN:HookAdd("PlayerLoadout", PLUGIN.PlayerLoadout)

-- Player Set Model.
function PLUGIN.PlayerSetModel(Player)
	local Group = citrus.Player.GetGroup(Player)
	local Attributes = Group:GetSetting("Attributes")
	
	-- Check Model.
	if (Attributes["Model"]) then
		if (Attributes["Model"] == "") then return end
		
		-- Set Model.
		Player:SetModel(Attributes["Model"])
		
		-- Return True.
		return true
	end
end

-- Hook Add.
PLUGIN:HookAdd("PlayerSetModel", PLUGIN.PlayerSetModel)

-- On Player Load.
function PLUGIN:OnPlayerLoad(Player) Player:Spawn() end

-- On Player Unload.
function PLUGIN:OnPlayerUnload(Player) Player:Spawn() end

-- Include Directory.
citrus.Utilities.IncludeDirectory(PLUGIN.FilePath.."/commands/", "sv_", ".lua")