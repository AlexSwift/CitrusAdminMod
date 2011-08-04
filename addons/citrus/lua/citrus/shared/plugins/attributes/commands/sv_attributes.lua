--[[
Name: "sv_attributes.lua".
Product: "Citrus (Server Management)".
--]]

local COMMAND = citrus.Command:New("attributes", "S")

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Attributes")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- Models.
local Models = {
	["Kleiner"] = "models/player/Kleiner.mdl",
	["Mossman"] = "models/player/mossman.mdl",
	["Alyx"] = "models/player/alyx.mdl",
	["Barney"] = "models/player/barney.mdl",
	["Breen"] = "models/player/breen.mdl",
	["Odessa"] = "models/player/odessa.mdl",
	["Classic Zombie"] = "models/player/classic.mdl",
	["Charple 01"] = "models/player/charple01.mdl",
	["Combine Solder"] = "models/player/combine_soldier.mdl",
	["Prison Guard"] = "models/player/combine_soldier_prisonguard.mdl",
	["Super Soldier"] = "models/player/combine_super_soldier.mdl",
	["Police"] = "models/player/police.mdl",
	["GMan"] = "models/player/gman_high.mdl",
	["Stripped Soldier"] = "models/player/soldier_stripped.mdl",
	["Fast Zombie"] = "models/player/Zombiefast.mdl",
	["Female 1"] = "models/player/Group01/female_01.mdl",
	["Female 2"] = "models/player/Group01/female_02.mdl",
	["Female 3"] = "models/player/Group01/female_03.mdl",
	["Female 4"] = "models/player/Group01/female_04.mdl",
	["Female 5"] = "models/player/Group01/female_06.mdl",
	["Female 6"] = "models/player/Group01/female_07.mdl",
	["Female 7"] = "models/player/Group03/female_01.mdl",
	["Female 8"] = "models/player/Group03/female_02.mdl",
	["Female 9"] = "models/player/Group03/female_03.mdl",
	["Female 10"] = "models/player/Group03/female_04.mdl",
	["Female 11"] = "models/player/Group03/female_06.mdl",
	["Female 12"] = "models/player/Group03/female_07.mdl",
	["Male 1"] = "models/player/Group01/male_01.mdl",
	["Male 2"] = "models/player/Group01/male_02.mdl",
	["Male 3"] = "models/player/Group01/male_03.mdl",
	["Male 4"] = "models/player/Group01/male_04.mdl",
	["Male 5"] = "models/player/Group01/male_05.mdl",
	["Male 6"] = "models/player/Group01/male_06.mdl",
	["Male 7"] = "models/player/Group01/male_07.mdl",
	["Male 8"] = "models/player/Group01/male_08.mdl",
	["Male 9"] = "models/player/Group01/male_09.mdl",
	["Male 10"] = "models/player/Group03/male_01.mdl",
	["Male 11"] = "models/player/Group03/male_02.mdl",
	["Male 12"] = "models/player/Group03/male_03.mdl",
	["Male 13"] = "models/player/Group03/male_04.mdl",
	["Male 14"] = "models/player/Group03/male_05.mdl",
	["Male 15"] = "models/player/Group03/male_06.mdl",
	["Male 16"] = "models/player/Group03/male_07.mdl",
	["Male 17"] = "models/player/Group03/male_08.mdl",
	["Male 18"] = "models/player/Group03/male_09.mdl"
}

-- Callback.
function COMMAND.Callback(Player, Arguments)
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Attributes")
	Menu:SetIcon("gui/silkicons/group")
	Menu:SetReference(COMMAND.Callback)
	
	-- For Loop.
	for K, V in pairs(citrus.Groups.Stored) do
		Menu:ButtonAdd(V.Name, function() COMMAND.Group(Player, V) end)
	end
	
	-- Send.
	Menu:Send()
end

-- Set Attribute.
function COMMAND.SetAttribute(Player, Group, Attribute, Value)
	PLUGIN.Configuration[Group.Name][Attribute] = Value
	
	-- Check Type.
	if (type(PLUGIN.Configuration[Group.Name][Attribute]) == "table") then
		if (table.Count(PLUGIN.Configuration[Group.Name][Attribute]) == 0) then
			PLUGIN.Configuration[Group.Name][Attribute] = nil
		end
	elseif (type(PLUGIN.Configuration[Group.Name][Attribute]) == "string") then
		if (PLUGIN.Configuration[Group.Name][Attribute] == "") then
			PLUGIN.Configuration[Group.Name][Attribute] = nil
		end
	end
	
	-- Set Setting.
	Group:GetSetting("Attributes")[Attribute] = PLUGIN.Configuration[Group.Name][Attribute]
end

-- Set Model.
function COMMAND.SetModel(Player, Group)
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Set Model ("..Group.Name..")")
	Menu:SetIcon("gui/silkicons/wrench")
	Menu:SetReference(COMMAND.SetModel, Group)
	
	-- Button Add.
	Menu:ButtonAdd("Default", function()
		COMMAND.SetAttribute(Player, Group, "Model", "")
		
		-- Notify All.
		citrus.Player.NotifyAll("Model for "..Group.Name.." set to default.")
	end)
	
	-- For Loop.
	for K, V in pairs(Models) do
		Menu:ButtonAdd(K, function()
			COMMAND.SetAttribute(Player, Group, "Model", V)
			
			-- Notify All.
			citrus.Player.NotifyAll("Model for "..Group.Name.." set to "..K..".")
		end)
	end
	
	-- Send.
	Menu:Send()
end

-- Set Weapons.
function COMMAND.SetWeapons(Player, Group)
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Set Weapons ("..Group.Name..")")
	Menu:SetIcon("gui/silkicons/wrench")
	Menu:SetUpdate(COMMAND.SetWeapons, Group)
	Menu:SetReference(COMMAND.SetWeapons, Group)
	
	-- Weapons.
	local Weapons = {
		{"Pistol", "weapon_pistol"},
		{"357 Magnum", "weapon_357"},
		{"SMG", "weapon_smg1"},
		{"Frag Grenades", "weapon_frag"},
		{"Shotgun", "weapon_shotgun"},
		{"Bugbait", "weapon_bugbait"},
		{"AR2", "weapon_ar2"},
		{"Stunstick", "weapon_stunstick"},
		{"Crossbow", "weapon_crossbow"},
		{"Crowbar", "weapon_crowbar"},
		{"RPG", "weapon_rpg"},
		{"Physics Gun", "weapon_physgun"},
		{"Gravity Gun", "weapon_physcannon"},
		{"Tool Gun", "gmod_tool"},
		{"Camera", "gmod_camera"}
	}
	
	-- SWEPs.
	local SWEPs = weapons.GetList()
	
	-- For Loop.
	for K, V in pairs(SWEPs) do
		if (V.Spawnable or V.AdminSpawnable) then
			if (!V.PrintName or V.PrintName == "") then
				Weapons[#Weapons + 1] = {V.Classname, V.Classname}
			else
				Weapons[#Weapons + 1] = {V.PrintName, V.Classname}
			end
		end
	end
	
	-- Name.
	PLUGIN.Configuration[Group.Name]["Weapons"] = PLUGIN.Configuration[Group.Name]["Weapons"] or {}
	
	-- Button Add.
	Menu:ButtonAdd("Default", function()
		PLUGIN.Configuration[Group.Name]["Weapons"] = nil
		
		-- Get Setting.
		Group:GetSetting("Attributes")["Weapons"] = nil
		
		-- Update.
		citrus.Menus.Update(nil, COMMAND.SetWeapons, Group)
		
		-- Notify All.
		citrus.Player.NotifyAll("Weapons for "..Group.Name.." set to default.")
	end)
	
	-- For Loop.
	for K, V in pairs(Weapons) do
		local Value = table.HasValue(PLUGIN.Configuration[Group.Name]["Weapons"], V[2])
		
		-- Check Box Add.
		Menu:CheckBoxAdd(V[1], function(Player, Value)
			if (Value) then
				if (!table.HasValue(PLUGIN.Configuration[Group.Name]["Weapons"], V[2])) then
					PLUGIN.Configuration[Group.Name]["Weapons"][#PLUGIN.Configuration[Group.Name]["Weapons"] + 1] = V[2]
				end
			else
				for K2, V2 in pairs(PLUGIN.Configuration[Group.Name]["Weapons"]) do
					if (V2 == V[2]) then
						table.remove(PLUGIN.Configuration[Group.Name]["Weapons"], K2)
					end
				end
			end
			
			-- Set Setting.
			Group:GetSetting("Attributes")["Weapons"] = PLUGIN.Configuration[Group.Name]["Weapons"]
		end, Value)
	end
	
	-- Send.
	Menu:Send()
end

-- Group.
function COMMAND.Group(Player, Group)
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Attributes ("..Group.Name..")")
	Menu:SetIcon("gui/silkicons/wrench")
	Menu:SetReference(COMMAND.Group, Group)
	
	-- Health.
	local Health = 100
	local Armor = 0
	
	-- Check Name.
	if (PLUGIN.Configuration[Group.Name] and PLUGIN.Configuration[Group.Name]["Health"]) then
		Health = PLUGIN.Configuration[Group.Name]["Health"]
	end
	if (PLUGIN.Configuration[Group.Name] and PLUGIN.Configuration[Group.Name]["Armor"]) then
		Armor = PLUGIN.Configuration[Group.Name]["Armor"]
	end
	
	-- Button Add.
	Menu:ButtonAdd("Respawn", function()
		local Players = player.GetAll()
		
		-- For Loop.
		for K, V in pairs(Players) do
			if (citrus.Player.GetGroup(V) == Group) then
				V:Spawn()
				
				-- Notify All.
				citrus.Player.NotifyAll("All "..Group.Name.." players respawned.")
			end
		end
	end)
	
	-- Slider Add.
	Menu:SliderAdd("Health", function(Player, Value)
		COMMAND.SetAttribute(Player, Group, "Health", Value)
		
		-- Notify All.
		citrus.Player.NotifyAll("Health for "..Group.Name.." set to "..Value..".")
	end, 1, 250, {Value = Health})
	Menu:SliderAdd("Armor", function(Player, Value)
		COMMAND.SetAttribute(Player, Group, "Armor", Value)
		
		-- Notify All.
		citrus.Player.NotifyAll("Armor for "..Group.Name.." set to "..Value..".")
	end, 1, 250, {Value = Armor})
	
	-- Button Add.
	Menu:ButtonAdd("Model", function() COMMAND.SetModel(Player, Group) end)
	Menu:ButtonAdd("Weapons", function() COMMAND.SetWeapons(Player, Group) end)
	
	-- Send.
	Menu:Send()
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Plugin Configuration", "Attributes")

-- Create.
COMMAND:Create()