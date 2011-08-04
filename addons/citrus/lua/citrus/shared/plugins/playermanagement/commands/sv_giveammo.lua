--[[
Name: "sv_giveammo.lua".
Product: "Citrus (Server Management)"
--]]

local COMMAND = citrus.Command:New("giveammo", "M", {{"Player", "player"}, {"Ammo", "string"}, {"Amount", "number"}})

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Player Management")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- Ammo.
COMMAND.Ammo = {
	{"AR2", "AR2"},
	{"Alyx Gun", "AlyxGun"},
	{"Pistol", "Pistol"},
	{"SMG", "SMG1"},
	{"357", "357"},
	{"Crossbow Bolt", "XBowBolt"},
	{"Buckshot", "Buckshot"},
	{"RPG Round", "RPG_Round"},
	{"SMG Grenade", "SMG1_Grenade"},
	{"Sniper Round", "SniperRound"},
	{"Sniper Penetrated Round", "SniperPenetratedRound"},
	{"Grenade", "Grenade"},
	{"Thumper", "Thumper"},
	{"Gravity", "Gravity"},
	{"Battery", "Battery"},
	{"Gauss Energy", "GaussEnergy"},
	{"Combine Cannon", "CombineCannon"},
	{"Airboat Gun", "AirboatGun"},
	{"Strider Minigun", "StriderMinigun"},
	{"Helicopter Gun", "HelicopterGun"},
	{"AR2 Alternate Fire", "AR2AltFire"},
	{"SLAM", "slam"}
}

-- RCon Callback.
function COMMAND.RConCallback(Arguments)
	for K, V in pairs(COMMAND.Ammo) do
		if (string.lower(Arguments[2]) == string.lower(V[2])) then
			Arguments[1]:GiveAmmo(Arguments[3], Arguments[2])
			
			-- Print.
			print(Arguments[1]:Name().." is given "..Arguments[3].." "..Arguments[2].." ammo (Console).")
			
			-- Return.
			return
		end
	end
	
	-- Print.
	print("Unable to locate '"..Arguments[2].."'!")
end

-- Callback.
function COMMAND.Callback(Player, Arguments)
	for K, V in pairs(COMMAND.Ammo) do
		if (string.lower(Arguments[2]) == string.lower(V[2])) then
			Arguments[1]:GiveAmmo(Arguments[3], Arguments[2])
			
			-- Notify By Access.
			citrus.Player.NotifyByAccess("M", Arguments[1]:Name().." is given "..Arguments[3].." "..Arguments[2].." ammo ("..Player:Name()..").")
			citrus.Player.NotifyByAccess("!M", Arguments[1]:Name().." is given "..Arguments[3].." "..Arguments[2].." ammo.")
			
			-- Return.
			return
		end
	end
	
	-- Notify.
	citrus.Player.Notify(Player, "Unable to locate '"..Arguments[2].."'!", 1)
end

-- Get Ammo.
function COMMAND.GetAmmo(Player, Menu, Argument)
	for K, V in pairs(COMMAND.Ammo) do
		Menu:ButtonAdd(V[1], function()
			citrus.QuickMenu.SetArgument(Player, Argument, V[2])
		end)
	end
end

-- Get Amount.
function COMMAND.GetAmount(Player, Menu, Argument)
	Menu:SliderAdd("Amount", function(Player, Value)
		citrus.QuickMenu.SetArgument(Player, Argument, Value)
	end, 0, 250)
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Player Management", "Give Ammo", {{"Player", citrus.QuickMenu.GetPlayer}, {"Ammo", COMMAND.GetAmmo}, {"Amount", COMMAND.GetAmount}})

-- Create.
COMMAND:Create()