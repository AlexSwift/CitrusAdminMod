--[[
Name: "sv_redo.lua".
Product: "Citrus (Server Management)".
--]]

local COMMAND = citrus.Command:New("parent", "M", {{"Player", "player"}})

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Fun and Useful")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

function COMMAND.Parent( Player, Target, Entity )
	Entity:SetParent( Target )
	
	local function Function(Undo, Entity)
		local Valid = citrus.Utilities.IsValidEnt(Entity)
		
		if (Valid) then
			Entity:SetParent()
		end
	end
	
	// Undo
	
	undo.Create("Parent")
		undo.SetPlayer(Player)
		undo.AddFunction(Function, Entity)
	undo.Finish()
end

-- Callback.
function COMMAND.Callback(Player, Arguments)
	local Trace = citrus.Utilities.PlayerTrace( Player )
	
	if not Trace or not Trace.Entity or Trace.Entity:IsWorld() then
		citrus.Player.Notify( Player, "You must target a valid entity" )
		return
	end
	
	COMMAND.Parent( Player, Arguments[1], Trace.Entity )
end

COMMAND:QuickMenuAdd("Player Management", "Parent", {{"Player", citrus.QuickMenu.GetPlayer}})

-- Create.
COMMAND:Create()