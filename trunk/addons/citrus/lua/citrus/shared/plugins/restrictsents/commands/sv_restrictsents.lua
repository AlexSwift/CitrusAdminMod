--[[
Name: "sv_restrictsents.lua".
Product: "Citrus (Server Management)".
--]]

local COMMAND = citrus.Command:New("restrictsents", "S")

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Restrict SENTs")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- Callback.
function COMMAND.Callback(Player, Arguments)
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Restrict SENTs")
	Menu:SetIcon("gui/silkicons/shield")
	Menu:SetReference(COMMAND.Callback)
	
	-- Button Add.
	Menu:ButtonAdd("Access", function() COMMAND.RestrictSENTs("Access") end)
	Menu:ButtonAdd("Administrator Access", function() COMMAND.RestrictSENTs("Administrator Access") end)
	
	-- Send.
	Menu:Send()
end

-- Restrict SENTs.
function COMMAND.RestrictSENTs(Key)
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Restrict SENTs ("..Key..")")
	Menu:SetIcon("gui/silkicons/shield")
	Menu:SetReference(COMMAND.RestrictSENTs, Key)
	
	-- Callback.
	local function Callback(Access, Value)
		if (string.find(PLUGIN.Configuration[Key], Access)) then
			if (!Value) then
				PLUGIN.Configuration[Key] = string.gsub(PLUGIN.Configuration[Key], Access, "")
			end
		else
			if (Value) then
				PLUGIN.Configuration[Key] = PLUGIN.Configuration[Key]..Access
			end
		end
	end
	
	-- For Loop.
	for K, V in pairs(citrus.Access.Stored) do
		Menu:CheckBoxAdd(K.." ("..V..")", function(Player, Value)
			Callback(K, Value)
		end, string.find(PLUGIN.Configuration[Key], K) != nil)
	end
	
	-- Send.
	Menu:Send()
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Plugin Configuration", "Restrict SENTs")

-- Create.
COMMAND:Create()