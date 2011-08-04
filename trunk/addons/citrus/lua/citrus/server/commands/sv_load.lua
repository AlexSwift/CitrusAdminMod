--[[
Name: "sv_load.lua".
Product: "Citrus (Server Management)".
--]]

local COMMAND = citrus.Command:New("load", "A", {{"Plugin", "string"}})

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- RCon Callback.
function COMMAND.RConCallback(Arguments)
	local Plugin, Error = citrus.Plugins.Get(Arguments[1])
	
	-- Check Plugin.
	if (Plugin) then
		local Success, Error = Plugin:Load()
		
		-- Check Success.
		if (Success) then
			citrus.Player.NotifyByAccess("M", Plugin.Name.." plugin is loaded (Console).", 0)
			citrus.Player.NotifyByAccess("!M", Plugin.Name.." plugin is loaded.", 0)
			
			-- Print.
			print(Plugin.Name.." plugin is loaded (Console).")
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
		local Success, Error = Plugin:Load()
		
		-- Check Success.
		if (Success) then
			citrus.Player.NotifyByAccess("M", Plugin.Name.." plugin is loaded ("..Player:Name()..").", 0)
			citrus.Player.NotifyByAccess("!M", Plugin.Name.." plugin is loaded.", 0)
		else
			citrus.Player.Notify(Player, Error, 1)
		end
	else
		citrus.Player.Notify(Player, Error, 1)
	end
end

-- Create.
COMMAND:Create()