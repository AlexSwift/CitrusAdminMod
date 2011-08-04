--[[
Name: "sv_plugins.lua".
Product: "Citrus (Server Management)".
--]]

local COMMAND = citrus.Command:New("plugins", "A")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Plugin.
function COMMAND.Plugin(Player, Plugin)
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Plugin ("..Plugin.Name..")")
	Menu:SetIcon("gui/silkicons/plugin")
	Menu:SetUpdate(COMMAND.Plugin, Plugin)
	Menu:SetReference(COMMAND.Plugin, Plugin)
	
	-- Is Loaded.
	local IsLoaded = Plugin:IsLoaded()
	
	-- Check Is loaded.
	if (!IsLoaded) then
		Menu:ButtonAdd("Load", function()
			local Success, Error = Plugin:Load()
			
			-- Update.
			citrus.Menus.Update(nil, COMMAND.Plugin, Plugin)
			
			-- Check Success.
			if (Success) then
				citrus.Player.NotifyByAccess("M", Plugin.Name.." is loaded ("..Player:Name()..").", 0)
				citrus.Player.NotifyByAccess("!A", Plugin.Name.." is loaded.", 0)
			else
				citrus.Player.Notify(Player, Error, 1)
			end
		end)
	else
		if (Plugin.Settings.Unloadable) then
			Menu:ButtonAdd("Unload", function()
				local Success, Error = Plugin:Unload()
				
				-- Update.
				citrus.Menus.Update(nil, COMMAND.Plugin, Plugin)
				
				-- Check Success.
				if (Success) then
					citrus.Player.NotifyByAccess("M", Plugin.Name.." is unloaded ("..Player:Name()..").", 0)
					citrus.Player.NotifyByAccess("!A", Plugin.Name.." is unloaded.", 0)
				else
					citrus.Player.Notify(Player, Error, 1)
				end
			end)
		end
	end
	
	-- Check Gamemode.
	if (Plugin.Settings.Gamemode) then
		Menu:TextAdd("Gamemode: "..Plugin.Settings.Gamemode[1]..".")
		Menu:TextAdd("Derivatives: "..tostring(Plugin.Settings.Gamemode[2])..".")
	end
	
	-- Check Unloadable.
	if (Plugin.Settings.Unloadable) then
		Menu:TextAdd("Unloadable: Yes.")
	else
		Menu:TextAdd("Unloadable: No.")
	end
	
	-- Text Add.
	Menu:TextAdd("Description: "..Plugin.Settings.Description..".")
	Menu:TextAdd("Author: "..Plugin.Settings.Author..".")
	
	-- Check Game Support.
	if (Plugin.Settings.GameSupport) then
		Menu:TextAdd("Game Support: Yes.")
	else
		Menu:TextAdd("Game Support: No.")
	end
	if (Plugin.Settings.Game) then
		Menu:TextAdd("Game: Yes.")
	else
		Menu:TextAdd("Game: No.")
	end
	
	-- Button Add.
	Menu:ButtonAdd("Files", function() COMMAND.Files(Player, Plugin, Plugin.FilePath.."/") end)
	Menu:ButtonAdd("Commands", function() COMMAND.Commands(Player, Plugin) end)
	
	-- Send.
	Menu:Send()
end

-- Commands.
function COMMAND.Commands(Player, Plugin)
	Msg( "\n\nPlugin:\n" )
	PrintTable( Plugin )
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Commands ("..Plugin.Name..")")
	Menu:SetIcon("gui/silkicons/plugin")
	Menu:SetReference(COMMAND.Commands, Plugin)
	
	-- Success.
	local Success = false
	local Commands = citrus.Commands.Get("commands")
	
	-- Check Commands.
	if (Commands) then
		for K, V in pairs(Plugin.Commands) do
			local Command = citrus.Commands.Get(K)
			
			-- Check Command.
			if (Command) then
				Menu:ButtonAdd(V.Name, function() Commands.Command(Player, V) end)
				
				-- Success.
				Success = true
			end
		end
	else
		for K, V in pairs(Plugin.Commands) do
			Menu:TextAdd(V.Name)
			
			-- Success.
			Success = true
		end
	end
	
	-- Check Success.
	if (!Success) then Menu:TextAdd("Unable to locate commands!") end
	
	-- Send.
	Menu:Send()
end

-- Files.
function COMMAND.Files(Player, Plugin, Directory)
	local Menu = citrus.Menu:New()
	
	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle(Plugin.Name.." Files ("..string.Replace(Directory, "citrus/shared/plugins/", "")..")")
	Menu:SetIcon("gui/silkicons/page")
	Menu:SetReference(COMMAND.Files, Plugin, Directory)
	
	-- Files.
	local Files = file.FindInLua(Directory.."*")
	
	-- Success.
	local Success = false
	
	-- For Loop.
	for K, V in pairs(Files) do
		if (V != "." and V != "..") then
			if (file.IsDir("../lua/"..Directory..V.."/")) then
				Menu:ButtonAdd(V, function() COMMAND.Files(Player, Plugin, Directory..V.."/") end)
				
				-- Success.
				Success = true
			end
		end
	end
	
	-- For Loop.
	for K, V in pairs(Files) do
		if (V != "." and V != "..") then
			if (!file.IsDir("../lua/"..Directory..V.."/")) then
				Menu:TextAdd(V)
				
				-- Success.
				Success = true
			end
		end
	end
	
	-- Check Success.
	if (!Success) then Menu:TextAdd("Unable to locate files!") end
	
	-- Send.
	Menu:Send()
end

-- Callback.
function COMMAND.Callback(Player, Arguments)
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Plugins")
	Menu:SetIcon("gui/silkicons/plugin")
	Menu:SetReference(COMMAND.Callback)
	
	-- Button Add.
	Menu:ButtonAdd("Load All", function()
		for K, V in pairs(citrus.Plugins.Stored) do
			local IsLoaded = V:IsLoaded()
			
			-- Check Game.
			if (!V.Settings.Game and !IsLoaded) then V:Load() end
		end
		
		-- Notify By Access.
		citrus.Player.NotifyByAccess("M", "All plugins are loaded ("..Player:Name()..").", 0)
		citrus.Player.NotifyByAccess("!A", "All plugins are loaded.", 0)
	end)
	
	-- Button Add.
	Menu:ButtonAdd("Unload All", function()
		for K, V in pairs(citrus.Plugins.Loaded) do
			if (!V.Settings.Game) then V:Unload() end
		end
		
		-- Notify By Access.
		citrus.Player.NotifyByAccess("M", "All plugins are unloaded ("..Player:Name()..").", 0)
		citrus.Player.NotifyByAccess("!A", "All plugins are unloaded.", 0)
	end)
	
	-- Success.
	local Success = false
	
	-- For Loop.
	for K, V in pairs(citrus.Plugins.Stored) do
		Success = true
		
		-- Button Add.
		Menu:ButtonAdd(K, function() COMMAND.Plugin(Player, V) end)
	end
	
	-- Check Success.
	if (!Success) then Menu:TextAdd("Unable to locate plugins!") end
	
	-- Send.
	Menu:Send()
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Server Management", "Plugins")

-- Create.
COMMAND:Create()