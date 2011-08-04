--[[
Name: "sv_profile.lua".
Product: "Citrus (Server Management)".
--]]

local COMMAND = citrus.Command:New("profile", false, {{"Player", "player"}})

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Commands")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- Callback.
function COMMAND.Callback(Player, Arguments)
	local Menu = citrus.Menu:New()
	
	-- Name.
	local Name = Arguments[1]:Name()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Profile ("..Name..")")
	Menu:SetIcon("gui/silkicons/user")
	Menu:SetReference(COMMAND.Callback, Arguments[1])

	-- Text Add.
	Menu:TextAdd("Steam ID: "..Arguments[1]:SteamID()..".")
	Menu:TextAdd("Unique ID: "..citrus.Player.GetUniqueID(Arguments[1])..".")
	
	-- Button Add.
	Menu:ButtonAdd("Information", function()
		citrus.PlayerInformation.Show(Player, Arguments[1])
	end)
	
	-- Send.
	Menu:Send()
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Standalone Commands", "Profile", {{"Player", citrus.QuickMenu.GetPlayer}}, "gui/silkicons/user")

-- Create.
COMMAND:Create()