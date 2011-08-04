--[[
Name: "sv_themes.lua".
Product: "Citrus (Server Management)"
--]]

local COMMAND = citrus.Command:New("themes", "M")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- RCon Callback.
function COMMAND.RConCallback()
	print("Themes")
	
	-- For Loop.
	for K, V in pairs(citrus.Themes.Stored) do
		print("\t"..K.." ("..V.Settings.Description..")")
	end
end

-- Theme.
function COMMAND.Theme(Player, Theme)
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Theme ("..Theme.Name..")")
	Menu:SetIcon("gui/silkicons/palette")
	Menu:SetReference(COMMAND.Theme, Theme)
	
	-- Text Add.
	Menu:TextAdd("Author: "..Theme.Settings.Author..".")
	Menu:TextAdd("Description: "..Theme.Settings.Description..".")
	
	-- Button Add.
	Menu:ButtonAdd("Set", function()
		citrus.Themes.Set(Theme.Name)
		
		-- Notify By Access.
		citrus.Player.NotifyByAccess("M", "Theme is set to "..Theme.Name.." ("..Player:Name()..").", 0)
		citrus.Player.NotifyByAccess("!M", "Theme is set to "..Theme.Name..".", 0)
	end)
	
	-- Send.
	Menu:Send()
end

-- Callback.
function COMMAND.Callback(Player, Arguments)
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Themes")
	Menu:SetIcon("gui/silkicons/palette")
	Menu:SetReference(COMMAND.Callback)
	
	-- For Loop.
	for K, V in pairs(citrus.Themes.Stored) do
		Menu:ButtonAdd(K, function() COMMAND.Theme(Player, V) end)
	end
	
	-- Send.
	Menu:Send()
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Server Management", "Themes")

-- Create.
COMMAND:Create()