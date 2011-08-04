--[[
Name: "sv_stripweapons.lua".
Product: "Citrus (Server Management)"
--]]

local COMMAND = citrus.Command:New("stripweapons", "M", {{"Player", "player"}, {"Weapon", "string", true}})

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Player Punishment")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- Strip Weapons
function COMMAND.StripWeapons(Player, Weapon, Name)
	if (Weapon) then
		Player:StripWeapon(Weapon)
		
		-- Notify By Access.
		citrus.Player.NotifyByAccess("M", Player:Name().." is stripped of "..Weapon.." ("..Name..").")
		citrus.Player.NotifyByAccess("!M", Player:Name().." is stripped of "..Weapon..".")
	else	
		Player:StripWeapons()
		
		-- Notify By Access.
		citrus.Player.NotifyByAccess("M", Player:Name().." is stripped of their weapons ("..Name..").")
		citrus.Player.NotifyByAccess("!M", Player:Name().." is stripped of their weapons.")
	end
end

-- RCon Callback.
function COMMAND.RConCallback(Arguments)
	COMMAND.StripWeapons(Arguments[1], Arguments[2], "Console")
	
	-- Check 2.
	if (Arguments[2]) then
		print(Arguments[1]:Name().." is stripped of "..Arguments[2].." (Console).")
	else
		print(Arguments[1]:Name().." is stripped of their weapons (Console).")
	end
end

-- Callback.
function COMMAND.Callback(Player, Arguments)
	local Error = citrus.Player.IsImmune(Player, Arguments[1])
	
	-- Check Error.
	if (Error and Player != Arguments[1]) then citrus.Player.Notify(Player, Error, 1) return end
	
	-- Strip Weapons.
	COMMAND.StripWeapons(Arguments[1], Arguments[2], Player:Name())
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Player Punishment", "Strip Weapons", {{"Player", citrus.QuickMenu.GetPlayer}})

-- Create.
COMMAND:Create()