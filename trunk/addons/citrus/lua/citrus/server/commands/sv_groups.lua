--[[
Name: "sv_groups.lua".
Product: "Citrus (Server Management)".
--]]

local COMMAND = citrus.Command:New("groups", "A")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Callback.
function COMMAND.Callback(Player, Arguments)
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Groups")
	Menu:SetIcon("gui/silkicons/group")
	Menu:SetReference(COMMAND.Callback)
	
	-- Groups.
	local Groups = {}
	
	-- For Loop.
	for K, V in pairs(citrus.Groups.Stored) do
		local Rank = V:GetSetting("Rank")
		
		-- Rank.
		Groups[Rank] = V
	end
	
	-- For Loop.
	for K, V in pairs(Groups) do
		Menu:ButtonAdd(V.Name, function() COMMAND.Group(Player, V) end)
	end
	
	-- Send.
	Menu:Send()
end

-- Set Group.
function COMMAND.SetGroup(Player, UniqueID)
	local Menu = citrus.Menu:New()

	-- Table.
	local Table = citrus.Groups.Players[UniqueID]
	local Group = citrus.Groups.Get(Table.Group)
	
	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Set Group ("..Table.Name..")")
	Menu:SetIcon("gui/silkicons/group")
	Menu:SetReference(COMMAND.SetGroup, UniqueID)
	
	-- For Loop.
	for K, V in pairs(citrus.Groups.Stored) do
		Menu:ButtonAdd(V.Name, function()
			if (citrus.Player.GetUniqueID(Player) == UniqueID) then
				citrus.Player.Notify(Player, "Unable to set own group!", 1)
			elseif (citrus.Player.GetGroup(Player):GetSetting("Rank") > Group:GetSetting("Rank")) then
				citrus.Player.Notify(Player, "Unable to set player to higher ranked group!", 1)
			elseif (citrus.Player.GetGroup(Player):GetSetting("Rank") > V:GetSetting("Rank")) then
				citrus.Player.Notify(Player, "Unable to set group of higher ranked player!", 1)
			else
				local Players = player.GetAll()
				
				-- Success.
				local Success = false
				
				-- For Loop.
				for K2, V2 in pairs(Players) do
					if (citrus.Player.GetUniqueID(V2) == UniqueID) then
						citrus.Groups.Set(V2, V)
						
						-- Success.
						Success = true
					end
				end
				
				-- Check Success.
				if (!Success) then
					citrus.Groups.Players[UniqueID].Name = Table.Name
					citrus.Groups.Players[UniqueID].Group = V.Name
					citrus.Groups.Players[UniqueID].SteamID = Table.SteamID
					
					-- Check Default.
					if (citrus.Groups.Default == V) then citrus.Groups.Players[UniqueID] = nil end
				end
				
				-- Update.
				citrus.Menus.Update(nil, COMMAND.Callback)
				citrus.Menus.Update(nil, COMMAND.Players, Group)
				citrus.Menus.Update(nil, COMMAND.Players, V)
				citrus.Menus.Update(nil, COMMAND.Group, V)
				citrus.Menus.Update(nil, COMMAND.Group, Group)
				
				-- Check Unique ID.
				if (citrus.Groups.Players[UniqueID]) then
					citrus.Menus.Update(nil, COMMAND.Player, UniqueID)
				else
					citrus.Menus.Remove(Player, COMMAND.Player, UniqueID)
				end
				
				-- Notify By Access.
				citrus.Player.NotifyByAccess("M", Table.Name.."'s group is set to "..V.Name.." ("..Player:Name()..").")
				citrus.Player.NotifyByAccess("!M", Table.Name.."'s group is set to "..V.Name..".")
			end
		end, {Discontinue = true})
	end
	
	-- Send.
	Menu:Send()
end

-- Player.
function COMMAND.Player(Player, UniqueID)
	local Menu = citrus.Menu:New()
	
	-- Table.
	local Table = citrus.Groups.Players[UniqueID]

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Player ("..Table.Name..")")
	Menu:SetIcon("gui/silkicons/user")
	Menu:SetUpdate(COMMAND.Player, UniqueID)
	Menu:SetReference(COMMAND.Player, UniqueID)
	
	-- Text Add.
	Menu:TextAdd("Name: "..Table.Name..".")
	Menu:TextAdd("Group: "..Table.Group..".")
	Menu:TextAdd("Steam ID: "..Table.SteamID..".")
	
	-- Button Add.
	Menu:ButtonAdd("Set Group", function() COMMAND.SetGroup(Player, UniqueID) end)
	
	-- Send.
	Menu:Send()
end

-- Players.
function COMMAND.Players(Player, Group)
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Players ("..Group.Name..")")
	Menu:SetIcon("gui/silkicons/user")
	Menu:SetUpdate(COMMAND.Players, Group)
	Menu:SetReference(COMMAND.Players, Group)
	
	-- Success.
	local Success = false
	
	-- For Loop.
	for K, V in pairs(citrus.Groups.Players) do
		if (Group.Name == V.Group) then
			Menu:ButtonAdd(V.Name, function() COMMAND.Player(Player, K) end)
			
			-- Success.
			Success = true
		end
	end
	
	-- Check Success.
	if (!Success) then Menu:TextAdd("Unable to locate players!") end
	
	-- Send.
	Menu:Send()
end

-- Group.
function COMMAND.Group(Player, Group)
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Group ("..Group.Name..")")
	Menu:SetIcon("gui/silkicons/group")
	Menu:SetUpdate(COMMAND.Group, Group)
	Menu:SetReference(COMMAND.Group, Group)
	
	-- Success.
	local Success = false
	
	-- For Loop.
	for K, V in pairs(citrus.Groups.Players) do
		if (Group.Name == V.Group) then
			Menu:ButtonAdd("Players", function() COMMAND.Players(Player, Group) end)
			
			-- Success.
			Success = true
			
			-- Break.
			break
		end
	end
	
	-- Check Success.
	if (Success) then
		Menu:ButtonAdd("Settings", function()
			citrus.Utilities.TableAsMenu(Player, Group.Settings, "Setting ("..Group.Name..")", "gui/silkicons/group")
		end)
	else
		citrus.Utilities.TableAsControls(Menu, Group.Settings, true)
	end
	
	-- Send.
	Menu:Send()
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Server Management", "Groups")

-- Create.
COMMAND:Create()