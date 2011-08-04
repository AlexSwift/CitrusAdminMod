--[[
Name: "sv_giveweapon.lua".
Product: "Citrus (Server Management)"
--]]

local COMMAND = citrus.Command:New("giveweapon", "M", {{"Player", "player"}, {"Weapon", "string"}})

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Player Management")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- RCon Callback.
function COMMAND.RConCallback(Arguments)
	Arguments[1]:Give(Arguments[2])
	
	-- Check Has Weapon.
	if (!Arguments[1]:HasWeapon(Arguments[2])) then
		print("Unable to locate '"..Arguments[2].."'!")
		
		-- Return.
		return
	end
	
	-- Print.
	print(Arguments[1]:Name().." is given weapon '"..Arguments[2].."' (Console).")
end

-- Callback.
function COMMAND.Callback(Player, Arguments)
	Arguments[1]:Give(Arguments[2])
	
	-- Check Has Weapon.
	if (!Arguments[1]:HasWeapon(Arguments[2])) then
		citrus.Player.Notify(Player, "Unable to locate '"..Arguments[2].."'!", 1)
		
		-- Return.
		return
	end
	
	-- Notify By Access.
	citrus.Player.NotifyByAccess("M", Arguments[1]:Name().." is given weapon '"..Arguments[2].."' ("..Player:Name()..").")
	citrus.Player.NotifyByAccess("!M", Arguments[1]:Name().." is given weapon '"..Arguments[2].."'.")
end

-- Get Weapons.
function COMMAND.GetWeapons(Player, Menu, Argument)
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
		{"RPG", "weapon_rpg"}
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
	
	-- For Loop.
	for K, V in pairs(Weapons) do
		Menu:ButtonAdd(V[1], function()
			citrus.QuickMenu.SetArgument(Player, Argument, V[2])
		end)
	end
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Player Management", "Give Weapon", {{"Player", citrus.QuickMenu.GetPlayer}, {"Weapon", COMMAND.GetWeapons}})

-- Create.
COMMAND:Create()