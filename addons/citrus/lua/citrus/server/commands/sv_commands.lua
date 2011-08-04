--[[
Name: "sv_commands.lua".
Product: "Citrus (Server Management)"
--]]

local COMMAND = citrus.Command:New("commands")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- RCon Callback.
function COMMAND.RConCallback(Arguments)
	print("Commands")
	
	-- Success.
	local Success = false
	
	-- For Loop.
	for K, V in pairs(citrus.Commands.Stored) do
		if (V.RConCallback) then
			print("\t"..V.Name)
			
			-- Success.
			Success = true
		end
	end
	
	-- Check Success.
	if (!Success) then print("\tUnable to locate commands!") end
end

-- Callback.
function COMMAND.Callback(Player, Arguments)
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Commands")
	Menu:SetIcon("gui/silkicons/application")
	Menu:SetReference(COMMAND.Callback)
	
	-- Success.
	local Success = false
	
	-- For Loop.
	for K, V in pairs(citrus.Commands.Stored) do
		if (V.Settings.Usable and citrus.Access.Has(Player, V.Settings.Access)) then
			Menu:ButtonAdd(V.Name, function() COMMAND.Command(Player, V) end)
			
			-- Success.
			Success = true
		end
	end
	
	-- Check Success.
	if (!Success) then Menu:TextAdd("Unable to locate commands!") end
	
	-- Send.
	Menu:Send()
end

-- Command.
function COMMAND.Command(Player, Command)
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Command ("..Command.Name..")")
	Menu:SetIcon("gui/silkicons/application")
	Menu:SetReference(COMMAND.Command, Command)
	
	-- Check Quick Menu.
	if (Command.Settings.QuickMenu) then
		Menu:ButtonAdd("Quick Menu", function()
			citrus.QuickMenu.Start(Player, Command.Settings.QuickMenu)
		end)
	end
	
	-- Text Add.
	Menu:TextAdd("Access: "..Command.Settings.Access..".")
	
	-- Check Get Syntax.
	if (Command:GetSyntax() != "") then
		Menu:TextAdd("Syntax: "..Command:GetSyntax()..".")
	end
	
	-- Check Chat Command.
	if (Command.Settings.ChatCommand) then
		Menu:TextAdd("Chat Command: "..citrus.Commands.Prefix..Command.Name..".")
	end
	
	-- Text Add.
	Menu:TextAdd("Console Command: citrus "..Command.Name..".")
	
	-- Send.
	Menu:Send()
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Server Information", "Commands")

-- Create.
COMMAND:Create()