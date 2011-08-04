--[[
Name: "sv_teachlanguage.lua".
Product: "Citrus (Server Management)".
--]]

local COMMAND = citrus.Command:New("teachlanguage", false, {{"Player", "player"}, {"Language", "string"}})

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Languages")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- RCon Callback.
function COMMAND.RConCallback(Arguments)
	local Language = Arguments[2]
	
	-- Languages.
	local Languages = citrus.PlayerVariables.Get(Arguments[1], "Languages")
	
	-- Check Language.
	if (Languages.Known[Language]) then
		print(Arguments[1]:Name().." already knows "..Language.."!")
	else
		if (!PLUGIN.Languages[Language]) then
			print("Unable to locate the language "..Language.."!")
		else
			Languages.Known[Language] = Language
			
			-- Notify.
			citrus.Player.Notify(Arguments[1], "Console has taught you the language "..Language..".")
			
			-- Print.
			print("You have taught "..Arguments[1]:Name().." '"..Language.."'.")
		end
	end
end

-- Callback.
function COMMAND.Callback(Player, Arguments)
	local Language = Arguments[2]
	
	-- Languages.
	local Languages = citrus.PlayerVariables.Get(Player, "Languages")
	
	-- Check Language.
	if (Languages.Known[Language] or citrus.Access.Has(Player, "S")) then
		local Languages = citrus.PlayerVariables.Get(Arguments[1], "Languages")
		
		-- Check Language.
		if (Languages.Known[Language]) then
			citrus.Player.Notify(Player, Arguments[1]:Name().." already knows "..Language.."!", 1)
		else
			if (!PLUGIN.Languages[Language]) then
				citrus.Player.Notify(Player, "Unable to locate the language "..Language.."!", 1)
			else
				Languages.Known[Language] = Language
				
				-- Check Player.
				if (Player == Arguments[1]) then
					citrus.Player.Notify(Player, "You have taught yourself "..Language..".")
				else
					citrus.Player.Notify(Arguments[1], Player:Name().." taught you the language '"..Language.."'.")
					citrus.Player.Notify(Player, "You have taught "..Arguments[1]:Name().." '"..Language.."'.")
				end
			end
		end
	else
		citrus.Player.Notify(Player, "You do not know "..Language..".", 1)
	end
end

-- Get Languages.
function COMMAND.GetLanguages(Player, Menu, Argument)
	local Success = false
	
	-- Languages.
	local Languages = citrus.PlayerVariables.Get(Player, "Languages")
	
	-- For Loop.
	for K, V in pairs(Languages.Known) do
		Menu:ButtonAdd(K, function()
			citrus.QuickMenu.SetArgument(Player, Argument, K)
		end)
		
		-- Success.
		Success = true
	end
	
	-- Check Success.
	if (!Success) then Menu:TextAdd("Unable to locate languages!") end
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Standalone Commands", "Teach Language", {{"Player", citrus.QuickMenu.GetPlayer}, {"Language", COMMAND.GetLanguages}})

-- Create.
COMMAND:Create()