--[[
Name: "sv_setgroupid.lua".
Product: "Citrus (Server Management)"
--]]

local COMMAND = citrus.Command:New("setgroupid", "A", {{"Steam ID", "string"}, {"Group", "string"}})

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Commands")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- RCon Callback.
function COMMAND.RConCallback(Arguments)
	local Group, Error = citrus.Groups.Get(Arguments[2])
	
	-- Check Group.
	if (Group) then
		local Name = Arguments[1]
		
		-- For Loop.
		for K, V in pairs(citrus.Groups.Players) do
			if (V.SteamID == Arguments[1]) then
				Name = V.Name
				
				-- Break.
				break
			end
		end
		
		-- Set.
		local Set = false
		local Players = player.GetAll()
		
		-- For Loop.
		for K, V in pairs(Players) do
			if (V:SteamID() == SteamID) then
				citrus.Groups.Set(V, Group)
				
				-- Name.
				Name = V:Name()
				
				-- Set.
				Set = true
			end
		end
		
		-- Check Set.
		if (!Set) then citrus.Groups.OfflineSet(Arguments[1], Group) end
		
		-- Notify By Access.
		citrus.Player.NotifyByAccess("M", Name.."'s group is set to "..Group.Name.." (Console).")
		citrus.Player.NotifyByAccess("!M", Name.."'s group is set to "..Group.Name..".")
		
		-- Print.
		print(Name.."'s group is set to "..Group.Name.." (Console).")
	else
		print(Error)
	end
end

-- Callback.
function COMMAND.Callback(Player, Arguments)
	local Group, Error = citrus.Groups.Get(Arguments[2])
	
	-- Check Group.
	if (Group) then
		Arguments[1] = string.upper(Arguments[1])
		
		-- Check Steam ID.
		if (Player:SteamID() == Arguments[1]) then
			citrus.Player.Notify(Player, "Unable to set own group!", 1)
		elseif (citrus.Player.GetGroup(Player):GetSetting("Rank") > Group:GetSetting("Rank")) then
			citrus.Player.Notify(Player, "Unable to set player to higher ranked group!", 1)
		else
			local Name = Arguments[1]
			
			-- For Loop.
			for K, V in pairs(citrus.Groups.Players) do
				if (V.SteamID == Arguments[1]) then
					local Group = citrus.Groups.Get(V.Group)
					
					-- Check Group.
					if (Group) then
						if (citrus.Player.GetGroup(Player):GetSetting("Rank") > Group:GetSetting("Rank")) then
							citrus.Player.Notify(Player, "Unable to set group of higher ranked player!", 1)
							
							-- Return.
							return
						end
					end
					
					-- Name.
					Name = V.Name
					
					-- Break.
					break
				end
			end
			
			-- Set.
			local Set = false
			local Players = player.GetAll()
			
			-- For Loop.
			for K, V in pairs(Players) do
				if (V:SteamID() == SteamID) then
					citrus.Groups.Set(V, Group)
					
					-- Name.
					Name = V:Name()
					
					-- Set.
					Set = true
				end
			end
			
			-- Check Set.
			if (!Set) then citrus.Groups.OfflineSet(Arguments[1], Group) end
			
			-- Notify By Access.
			citrus.Player.NotifyByAccess("M", Name.."'s group is set to "..Group.Name.." ("..Player:Name()..").")
			citrus.Player.NotifyByAccess("!M", Name.."'s group is set to "..Group.Name..".")
		end
	else
		citrus.Player.Notify(Player, Error, 1)
	end
end

-- Get Group.
function COMMAND.GetGroup(Player, Menu, Argument)
	for K, V in pairs(citrus.Groups.Stored) do
		Menu:ButtonAdd(V.Name, function()
			citrus.QuickMenu.SetArgument(Player, Argument, V.Name)
		end)
	end
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Player Administration", "Set Group ID", {{"Steam ID", citrus.QuickMenu.GetText}, {"Group", COMMAND.GetGroup}}, "gui/silkicons/group")

-- Create.
COMMAND:Create()