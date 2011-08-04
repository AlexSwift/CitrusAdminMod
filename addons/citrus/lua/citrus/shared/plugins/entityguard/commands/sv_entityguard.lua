--[[
Name: "sv_entityguard.lua".
Product: "Citrus (Server Management)".
--]]

local COMMAND = citrus.Command:New("entityguard")

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Entity Guard")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- Callback.
function COMMAND.Callback(Player, Arguments)
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Entity Guard")
	Menu:SetIcon("gui/silkicons/shield")
	Menu:SetReference(COMMAND.Callback)
	
	-- Check Has.
	if (citrus.Access.Has(Player, PLUGIN.Configuration["Access"]) or citrus.Access.Has(Player, "S")) then
		Menu:ButtonAdd("Administration", function() COMMAND.Administration(Player) end)
	end
	
	-- Button Add.
	Menu:ButtonAdd("Remove Entities", function() COMMAND.RemoveEntities(Player, "Player") end)
	Menu:ButtonAdd("Share Entity", COMMAND.ShareEntity)
	Menu:ButtonAdd("Friends", COMMAND.Friends)

	-- Send.
	Menu:Send()
end

-- Administration.
function COMMAND.Administration(Player)
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Entity Guard (Administration)")
	Menu:SetIcon("gui/silkicons/shield")
	Menu:SetReference(COMMAND.Administration)
	
	-- Check Has.
	if (citrus.Access.Has(Player, "S")) then
		Menu:ButtonAdd("Configuration", COMMAND.Configuration)
	end
	
	-- Check Has.
	if (citrus.Access.Has(Player, PLUGIN.Configuration["Access"])) then
		Menu:ButtonAdd("Remove Owned Entities", function() COMMAND.RemoveEntities(Player, "Owned") end)
		Menu:ButtonAdd("Remove Unowned Entities", function() COMMAND.RemoveEntities(Player, "Unowned") end)
		Menu:ButtonAdd("Remove Shared Entities", function() COMMAND.RemoveEntities(Player, "Shared") end)
		Menu:ButtonAdd("Remove Abandoned Entities", function() COMMAND.RemoveEntities(Player, "Abandoned") end)
		Menu:ButtonAdd("Remove All Entities", function() COMMAND.RemoveEntities(Player, "All") end)
	end
	
	-- Send.
	Menu:Send()
end

-- Check Box Add.
function COMMAND.CheckBoxAdd(Player, Menu, Key, Message)
	Menu:CheckBoxAdd(Key, function(Player, Value)
		if (Value == PLUGIN.Configuration[Key]) then return end
		
		-- Key.
		PLUGIN.Configuration[Key] = Value
		
		-- Check Message.
		if (Message) then citrus.Player.NotifyAll(Key.." for Entity Guard set to "..tostring(Value)..".") end
	end, PLUGIN.Configuration[Key])
end

-- Access.
function COMMAND.Access(Player)
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Entity Guard (Access)")
	Menu:SetIcon("gui/silkicons/wrench")
	Menu:SetReference(COMMAND.Access)
	
	-- Callback.
	local function Callback(Access, Value)
		if (string.find(PLUGIN.Configuration["Access"], Access)) then
			if (!Value) then
				PLUGIN.Configuration["Access"] = string.gsub(PLUGIN.Configuration["Access"], Access, "")
			end
		else
			if (Value) then
				PLUGIN.Configuration["Access"] = PLUGIN.Configuration["Access"]..Access
			end
		end
	end
	
	-- For Loop.
	for K, V in pairs(citrus.Access.Stored) do
		Menu:CheckBoxAdd(K.." ("..V..")", function(Player, Value)
			Callback(K, Value)
		end, string.find(PLUGIN.Configuration["Access"], K) != nil)
	end
	
	-- Send.
	Menu:Send()
end

-- Configuration.
function COMMAND.Configuration(Player)
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Entity Guard (Configuration)")
	Menu:SetIcon("gui/silkicons/wrench")
	Menu:SetReference(COMMAND.Configuration)
	
	-- Button Add.
	Menu:ButtonAdd("Access", COMMAND.Access)
	
	-- Check Box Add.
	COMMAND.CheckBoxAdd(Player, Menu, "Display Owner", true)
	COMMAND.CheckBoxAdd(Player, Menu, "Display Class", true)
	COMMAND.CheckBoxAdd(Player, Menu, "Automatic Cleanup", true)
	COMMAND.CheckBoxAdd(Player, Menu, "Tool Protection", true)
	COMMAND.CheckBoxAdd(Player, Menu, "Physgun Protection", true)
	COMMAND.CheckBoxAdd(Player, Menu, "Gravgun Protection", true)
	COMMAND.CheckBoxAdd(Player, Menu, "Unfreeze Protection", true)
	COMMAND.CheckBoxAdd(Player, Menu, "Vehicle Protection", true)
	COMMAND.CheckBoxAdd(Player, Menu, "Damage Protection", true)
	COMMAND.CheckBoxAdd(Player, Menu, "Use Protection", true)
	
	-- Send.
	Menu:Send()
end

-- Remove Entities.
function COMMAND.RemoveEntities(Player, Type)
	if (Type == "Owned") then
		local Menu = citrus.Menu:New()
		
		-- Set Player.
		Menu:SetPlayer(Player)
		Menu:SetTitle("Remove Owned Entities")
		Menu:SetIcon("vgui/notices/error")
		Menu:SetReference(COMMAND.RemoveEntities, Type)
		
		-- Players.
		local Players = player.GetAll()
		
		-- For Loop.
		for K, V in pairs(Players) do
			Menu:ButtonAdd(V:Name(), function()
				local Success, Error = citrus.Player.IsImmune(Player, V)
				
				-- Check Success.
				if (Success) then
					local Entities = ents.GetAll()
					
					-- For Loop.
					for K2, V2 in pairs(Entities) do
						local IsPlayer = V2:IsPlayer()
						local IsWorld = V2:IsWorld()
						
						-- Check Is Player.
						if (!IsPlayer and !IsWorld and !PLUGIN.IsWorlds(V2)) then
							if (PLUGIN.GetOwner(V2) == V) then
								local Remove = true
								
								-- Parent.
								local Parent = V2:GetParent()
								
								-- Check Valid Entity.
								if (ValidEntity(Parent)) then
									local IsPlayer = Parent:IsPlayer()
									
									-- Check Is Player.
									if (IsPlayer) then Remove = false end
								end
								
								-- Check Remove.
								if (Remove) then V2:Remove() end
							end
						end
					end
					
					-- Notify By Access.
					citrus.Player.NotifyByAccess("M", V:Name().."'s entities have been removed ("..Player:Name()..").", 0)
					citrus.Player.NotifyByAccess("!M", V:Name().."'s entities have been removed.", 0)
				else
					citrus.Player.Notify(Player, Error, 1)
				end
			end)
		end
		
		-- Send.
		Menu:Send()
		
		-- Return.
		return
	end
	
	-- Entities.
	local Entities = ents.GetAll()
	
	-- For Loop.
	for K, V in pairs(Entities) do
		local IsPlayer = V:IsPlayer()
		local IsWorld = V:IsWorld()
		
		-- Check Is Player.
		if (!IsPlayer and !IsWorld and !PLUGIN.IsWorlds(V)) then
			local Remove = true
			
			-- Parent.
			local Parent = V:GetParent()
			
			-- Check Valid Entity.
			if (ValidEntity(Parent)) then
				local IsPlayer = Parent:IsPlayer()
				
				-- Check Is Player.
				if (IsPlayer) then Remove = false end
			end
			
			-- Check Remove.
			if (Remove) then
				if (Type == "Abandoned") then
					if (PLUGIN.IsAbandoned(V)) then V:Remove() end
				elseif (Type == "Unowned") then
					if (!PLUGIN.HasOwner(V)) then V:Remove() end
				elseif (Type == "Player") then
					if (PLUGIN.GetOwner(V) == Player) then V:Remove() end
				elseif (Type == "Shared") then
					if (PLUGIN.IsShared(V)) then V:Remove() end
				elseif (Type == "All") then V:Remove() end
			end
		end
	end
	
	-- Check Type.
	if (Type == "Abandoned") then
		citrus.Player.NotifyByAccess("M", "Abandoned entities have been removed ("..Player:Name()..").", 0)
		citrus.Player.NotifyByAccess("!M", "Abandoned entities have been removed.", 0)
	elseif (Type == "Unowned") then
		citrus.Player.NotifyByAccess("M", "Unowned entities have been removed ("..Player:Name()..").", 0)
		citrus.Player.NotifyByAccess("!M", "Unowned entities have been removed.", 0)
	elseif (Type == "Shared") then
		citrus.Player.NotifyByAccess("M", "Shared entities have been removed ("..Player:Name()..").", 0)
		citrus.Player.NotifyByAccess("!M", "Shared entities have been removed.", 0)
	elseif (Type == "Player") then			
		citrus.Player.Notify(Player, "You have removed all of your entities.")
	elseif (Type == "All") then
		PLUGIN:UsermessageCall("Remove Entities")
		
		-- Notify By Access.
		citrus.Player.NotifyByAccess("M", "All entities have been removed ("..Player:Name()..").", 0)
		citrus.Player.NotifyByAccess("!M", "All entities have been removed.", 0)
	end
end

-- Share Entity.
function COMMAND.ShareEntity(Player)
	local Trace = citrus.Utilities.PlayerTrace(Player)
	
	-- Check Valid Entity.
	if (ValidEntity(Trace.Entity)) then
		if (PLUGIN.CanManage(Player, Trace.Entity)) then
			PLUGIN.SetShared(Trace.Entity)
			
			-- Notify.
			citrus.Player.Notify(Player, "Targeted entity is now shared.")
		else
			citrus.Player.Notify(Player, "Unable to manage unowned entity!", 1)
		end
	else
		citrus.Player.Notify(Player, "Target a valid entity to share it!", 1)
	end
end

-- Friends.
function COMMAND.Friends(Player)
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Entity Guard Friends")
	Menu:SetIcon("gui/silkicons/group")
	Menu:SetUpdate(COMMAND.Friends)
	Menu:SetReference(COMMAND.Friends)
	
	-- Players.
	local Players = player.GetAll()
	
	-- Add.
	local Add = false
	local Remove = false
	
	-- Entity Guard.
	local EntityGuard = citrus.PlayerCookies.Get(Player, "Entity Guard")
	
	-- For Loop.
	for K, V in pairs(Players) do
		if (Player != V) then
			local UniqueID = citrus.Player.GetUniqueID(V)
			
			-- Check Unique ID.
			if (EntityGuard.Friends[UniqueID]) then
				Remove = true
			else
				Add = true
			end
		end
	end
	
	-- Check Add.
	if (Add) then Menu:ButtonAdd("Add", COMMAND.Add) end
	if (Remove) then Menu:ButtonAdd("Remove", COMMAND.Remove) end
	
	-- Check Add.
	if (!Add and !Remove) then Menu:TextAdd("Unable to locate players!") end
	
	-- Send.
	Menu:Send()
end

-- Add.
function COMMAND.Add(Player)
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Add Friend")
	Menu:SetIcon("gui/silkicons/add")
	Menu:SetUpdate(COMMAND.Add)
	Menu:SetReference(COMMAND.Add)
	
	-- Players.
	local Players = player.GetAll()
	local Success = false
	
	-- For Loop.
	for K, V in pairs(Players) do
		if (Player != V) then
			local UniqueID = citrus.Player.GetUniqueID(V)
			
			-- Entity Guard.
			local EntityGuard = citrus.PlayerCookies.Get(Player, "Entity Guard")
			
			-- Check Unique ID.
			if (!EntityGuard.Friends[UniqueID]) then
				Menu:ButtonAdd(V:Name(), function()
					EntityGuard.Friends[UniqueID] = true
					
					-- Update.
					citrus.Menus.Update(nil, COMMAND.Add)
					citrus.Menus.Update(nil, COMMAND.ManageFriends)
					
					-- Notify.
					citrus.Player.Notify(Player, "You added "..V:Name().." to your Entity Guard friends.")
					citrus.Player.Notify(V, Player:Name().." added you to their Entity Guard friends.")
				end)
				
				-- Success.
				Success = true
			end
		end
	end
	
	-- Check Success.
	if (!Success) then
		Menu:TextAdd("Unable to locate players!")
	end
	
	-- Send.
	Menu:Send()
end

-- Remove.
function COMMAND.Remove(Player)
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Remove Friend")
	Menu:SetIcon("gui/silkicons/exclamation")
	Menu:SetUpdate(COMMAND.Remove)
	Menu:SetReference(COMMAND.Remove)
	
	-- Players.
	local Players = player.GetAll()
	local Success = false
	
	-- For Loop.
	for K, V in pairs(Players) do
		if (Player != V) then
			local UniqueID = citrus.Player.GetUniqueID(V)
			
			-- Entity Guard.
			local EntityGuard = citrus.PlayerCookies.Get(Player, "Entity Guard")
			
			-- Check Unique ID.
			if (EntityGuard.Friends[UniqueID]) then
				Menu:ButtonAdd(V:Name(), function()
					EntityGuard.Friends[UniqueID] = false
					
					-- Update.
					citrus.Menus.Update(nil, COMMAND.Remove)
					citrus.Menus.Update(nil, COMMAND.ManageFriends)
					
					-- Notify.
					citrus.Player.Notify(Player, "You removed "..V:Name().." from your Entity Guard friends.")
					citrus.Player.Notify(V, Player:Name().." removed you from their Entity Guard friends.")
				end)
				
				-- Success.
				Success = true
			end
		end
	end
	
	-- Check Success.
	if (!Success) then
		Menu:TextAdd("Unable to locate friends!")
	end
	
	-- Send.
	Menu:Send()
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Plugin Configuration", "Entity Guard")

-- Create.
COMMAND:Create()