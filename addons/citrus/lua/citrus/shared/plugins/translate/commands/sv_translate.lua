--[[
Name: "sv_translate.lua".
Product: "Citrus (Server Management)".
--]]

local COMMAND = citrus.Command:New("translate", false, {{"Weld", "boolean", true}})

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Translate")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- Callback.
function COMMAND.Callback(Player, Arguments)
	local Trace = citrus.Utilities.PlayerTrace(Player)
	
	-- Check Entity.
	if (Trace.Entity and !Trace.Entity:IsWorld() and !Trace.Entity:IsPlayer() and !Trace.Entity:IsNPC()) then
		if (gamemode.Call("CanTool", Player, Trace)) then
			local Translate = citrus.PlayerCookies.Get(Player, "Translate")
			
			-- Check Active.
			if (Translate.Active) then
				for K, V in pairs(Translate.Entities) do
					if (V.Entity == Trace.Entity) then
						PLUGIN.FinishTranslating(Player, false, Trace.Entity)
						
						-- Return.
						return
					end
				end
				
				-- Check Has.
				if (citrus.Access.Has(Player, "M")) then
					PLUGIN.StartTranslating(Player, Trace.Entity, Arguments[1])
				else
					citrus.Player.Notify(Player, citrus.Access.GetName("M", "or").." access required!", 1)
				end
			else
				PLUGIN.StartTranslating(Player, Trace.Entity, Arguments[1])
			end
		end
	else
		citrus.Player.Notify(Player, "Unable to locate valid entity!", 1)
	end
end

-- Create.
COMMAND:Create()