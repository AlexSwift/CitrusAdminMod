--[[
Name: "sv_giveaccess.lua".
Product: "Citrus (Server Management)"
--]]

local COMMAND = citrus.Command:New("giveaccess", "S", {{"Player", "player"}, {"Access|Command", "string"}})

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- RCon Callback.
function COMMAND.RConCallback(Arguments)
	local Access = Arguments[2]
	
	-- Check Access.
	if (citrus.Commands.Stored[Access]) then
		if (!citrus.PlayerVariables.Get(Arguments[1], "Access").Command[Access]) then
			print(Arguments[1]:Name().." is given '"..Arguments[2].."' access (Console).")
			
			-- Access.
			citrus.PlayerVariables.Get(Arguments[1], "Access").Command[Access] = true
			
			-- Notify By Access.
			citrus.Player.NotifyByAccess("M", Arguments[1]:Name().." is given '"..Arguments[2].."' access (Console).")
			citrus.Player.NotifyByAccess("!M", Arguments[1]:Name().." is given '"..Arguments[2].."' access.")
		else
			print(Arguments[1]:Name().." already has '"..Arguments[2].."' access!")
		end
		
		-- Return.
		return
	end
	
	-- For Loop.
	for I = 1, string.len(Arguments[2]) do
		local Character = string.sub(Arguments[2], I, I)
		
		-- Check Exists.
		if (!citrus.Access.Exists(Character)) then
			print("Unable to locate '"..Character.."'!")
			
			-- Return.
			return
		end
	end
	
	-- Success.
	local Success, Error = citrus.Access.Give(Arguments[1], Arguments[2])
	
	-- Check Success.
	if (Success) then
		print(Arguments[1]:Name().." is given '"..Arguments[2].."' access (Console).")
		
		-- Notify By Access.
		citrus.Player.NotifyByAccess("M", Arguments[1]:Name().." is given '"..Arguments[2].."' access (Console).")
		citrus.Player.NotifyByAccess("!M", Arguments[1]:Name().." is given '"..Arguments[2].."' access.")
	else
		print(Error)
	end
end

-- Callback.
function COMMAND.Callback(Player, Arguments)
	local Access = Arguments[2]
	
	-- Check Access.
	if (citrus.Commands.Stored[Access]) then
		if (!citrus.PlayerVariables.Get(Arguments[1], "Access").Command[Access]) then
			citrus.PlayerVariables.Get(Arguments[1], "Access").Command[Access] = true
			
			-- Notify By Access.
			citrus.Player.NotifyByAccess("M", Arguments[1]:Name().." is given '"..Arguments[2].."' access (Console).")
			citrus.Player.NotifyByAccess("!M", Arguments[1]:Name().." is given '"..Arguments[2].."' access.")
		else
			citrus.Player.Notify(Player, Arguments[1]:Name().." already has '"..Arguments[2].."' access!", 1)
		end
		
		-- Return.
		return
	end
	
	-- For Loop.
	for I = 1, string.len(Arguments[2]) do
		local Character = string.sub(Arguments[2], I, I)
		
		-- Check Exists.
		if (!citrus.Access.Exists(Character)) then
			citrus.Player.Notify(Player, "Unable to locate '"..Character.."'!", 1)
			
			-- Return.
			return
		end
	end
	
	-- Success.
	local Success, Error = citrus.Access.Give(Arguments[1], Arguments[2])
	
	-- Check Success.
	if (Success) then
		citrus.Player.NotifyByAccess("M", Arguments[1]:Name().." is given '"..Arguments[2].."' access ("..Player:Name()..").")
		citrus.Player.NotifyByAccess("!M", Arguments[1]:Name().." is given '"..Arguments[2].."' access.")
	else
		citrus.Player.Notify(Player, Error, 1)
	end
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Player Management", "Give Access", {{"Player", citrus.QuickMenu.GetPlayer}, {"Access|Command", citrus.QuickMenu.GetText}}, "gui/silkicons/user")

-- Create.
COMMAND:Create()