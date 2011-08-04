--[[
Name: "sv_bans.lua".
Product: "Citrus (Server Management)"
--]]

local COMMAND = citrus.Command:New("bans", "A")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- RCon Callback.
function COMMAND.RConCallback(Arguments)
	print("Bans")
	
	-- Bans.
	local Bans = citrus.Bans.GetAll()
	
	-- For Loop.
	for K, V in pairs(Bans) do
		if (V.Name == K) then
			print("\t"..K)
		else
			print("\t"..K.." ("..V.Name..")")
		end
	end
	
	-- Check Count.
	if (table.Count(Bans) == 0) then print("\tUnable to locate bans!") end
end

-- Callback.
function COMMAND.Callback(Player, Arguments)
	local Menu = citrus.Menu:New()
	
	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Bans")
	Menu:SetIcon("gui/silkicons/exclamation")
	Menu:SetUpdate(COMMAND.Callback)
	Menu:SetReference(COMMAND.Callback)
	
	-- Bans.
	local Bans = citrus.Bans.GetAll()
	
	-- For Loop.
	for K, V in pairs(Bans) do
		Menu:ButtonAdd(V.Name, function() COMMAND.Ban(Player, K, V) end)
	end
	
	-- Check Count.
	if (table.Count(Bans) == 0) then Menu:TextAdd("Unable to locate bans!") end
	
	-- Send.
	Menu:Send()
end

-- Ban.
function COMMAND.Ban(Player, ID, Ban)
	local Menu = citrus.Menu:New()
	
	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Ban ("..Ban.Name..")")
	Menu:SetReference(COMMAND.Ban, ID, Ban)
	Menu:SetIcon("gui/silkicons/exclamation")
	
	-- Text Add.
	Menu:TextAdd("Steam ID: "..Ban.SteamID..".")
	Menu:TextAdd("IP Address: "..Ban.IPAddress..".")
	Menu:TextAdd("Enforcer: "..Ban.Enforcer..".")
	
	-- Check Duration.
	if (Ban.Duration == 0) then
		Menu:TextAdd("Duration: Permanant.")
	else
		Menu:TextAdd("Duration: "..citrus.Utilities.GetFormattedTime(Ban.Duration, "%hh %mm %ss")..".")
		
		-- Remaining.
		local Remaining = citrus.Bans.GetRemaining(Ban)
		
		-- Check Remaining.
		if (Remaining > 0) then
			Menu:TextAdd("Remaining: "..citrus.Utilities.GetFormattedTime(Remaining, "%hh %mm %ss")..".")
		end
	end
	
	-- Text Add.
	Menu:TextAdd("Reason: "..Ban.Reason..".")
	Menu:TextAdd("Group: "..Ban.Group..".")
	
	-- Button Add.
	Menu:ButtonAdd("Unban", function()
		citrus.Bans.Remove(ID)
		
		-- Update.
		citrus.Menus.Update(nil, COMMAND.Callback)
		
		-- Notify By Access.
		citrus.Player.NotifyByAccess("M", Ban.Name.." is unbanned ("..Player:Name()..").")
		citrus.Player.NotifyByAccess("!M", Ban.Name.." is unbanned.")
	end, {Discontinue = true})
	
	-- Send.
	Menu:Send()
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Server Management", "Bans")

-- Create.
COMMAND:Create()