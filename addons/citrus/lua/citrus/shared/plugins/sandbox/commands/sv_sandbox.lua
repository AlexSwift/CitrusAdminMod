--[[
Name: "sv_sandbox.lua".
Product: "Citrus (Server Management)"
--]]

local COMMAND = citrus.Command:New("sandbox", "M")

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Sandbox")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- Callback.
function COMMAND.Callback(Player, Arguments)
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Sandbox")
	Menu:SetIcon("gui/silkicons/wrench")
	Menu:SetReference(COMMAND.Callback)
	
	-- Button Add.
	Menu:ButtonAdd("Entity Limits", function() COMMAND.EntityLimits(Player) end)
	
	-- Check Box Add.
	Menu:CheckBoxAdd("PvP Damage", function(Player, Value)
		if (Value) then Value = 1 else Value = 0 end
		
		-- Console Command.
		game.ConsoleCommand("sbox_plpldamage "..Value.."\n")
	end, (GetConVarNumber("sbox_plpldamage") == 1))
	Menu:CheckBoxAdd("God Mode", function(Player, Value)
		if (Value) then Value = 1 else Value = 0 end
		
		-- Console Command.
		game.ConsoleCommand("sbox_godmode "..Value.."\n")
	end, (GetConVarNumber("sbox_godmode") == 1))
	Menu:CheckBoxAdd("NoClip", function(Player, Value)
		if (Value) then Value = 1 else Value = 0 end
		
		-- Console Command.
		game.ConsoleCommand("sbox_noclip "..Value.."\n")
	end, (GetConVarNumber("sbox_noclip") == 1))
	
	-- Send.
	Menu:Send()
end

-- Entity Limits.
function COMMAND.EntityLimits(Player)
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Entity Limits")
	Menu:SetIcon("gui/silkicons/wrench")
	Menu:SetReference(COMMAND.EntityLimits)
	
	-- Table.
	local Table = {
		{"Props", "sbox_maxprops"},
		{"Ragdolls", "sbox_maxragdolls"},
		{"Vehicles", "sbox_maxvehicles"},
		{"Effects", "sbox_maxeffects"},
		{"Balloons", "sbox_maxballoons"},
		{"NPCs", "sbox_maxnpcs"},
		{"SENTs", "sbox_maxsents"},
		{"Dynamite", "sbox_maxdynamite"},
		{"Lamps", "sbox_maxlamps"},
		{"Wheels", "sbox_maxwheels"},
		{"Thrusters", "sbox_maxthrusters"},
		{"Hoverballs", "sbox_maxhoverballs"},
		{"Buttons", "sbox_maxbuttons"},
		{"Emitters", "sbox_maxemitters"},
		{"Spawners", "sbox_maxspawners"},
		{"Turrets", "sbox_maxturrets"}
	}
	
	-- For Loop.
	for K, V in pairs(Table) do
		Menu:SliderAdd(V[1], function(Player, Value) game.ConsoleCommand(V[2].." "..Value.."\n") end, 0, 250, {Value = GetConVarNumber(V[2])})
	end
	
	-- Send.
	Menu:Send()
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Plugin Configuration", "Sandbox")

-- Create.
COMMAND:Create()