--[[
Name: "sv_unload.lua".
Product: "Citrus (Server Management)".
--]]

local COMMAND = citrus.Command:New("unload", "A", {{"Plugin", "string"}})

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- RCon Callback.
function COMMAND.RConCallback(Arguments)
	local Plugin, Error = citrus.Plugins.Get(Arguments[1])
	
	-- Check Plugin.
	if (Plugin) then
		local Success, Error = Plugin:Unload()
		
		-- Check Success.
		if (Success) then
			citrus.Player.NotifyByAccess("M", Plugin.Name.." plugin is unloaded (Console).", 0)
			citrus.Player.NotifyByAccess("!A", Plugin.Name.." plugin is unloaded.", 0)
			
			-- Print.
			print(Plugin.Name.." plugin is unloaded (Console).")
		else
			print(Error)
		end
	else
		print(Error)
	end
end

-- Callback.
function COMMAND.Callback(Player, Arguments)
	local Plugin, Error = citrus.Plugins.Get(Arguments[1])
	
	-- Check Plugin.
	if (Plugin) then
		local Success, Error = Plugin:Unload()
		
		-- Check Success.
		if (Success) then
			citrus.Player.NotifyByAccess("M", Plugin.Name.." plugin is unloaded ("..Player:Name()..").", 0)
			citrus.Player.NotifyByAccess("!A", Plugin.Name.." plugin is unloaded.", 0)
		else
			citrus.Player.Notify(Player, Error, 1)
		end
	else
		citrus.Player.Notify(Player, Error, 1)
	end
end

-- Create.
COMMAND:Create()