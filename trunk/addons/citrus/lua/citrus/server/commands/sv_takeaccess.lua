--[[
Name: "sv_takeaccess.lua".
Product: "Citrus (Server Management)"
--]]

local COMMAND = citrus.Command:New("takeaccess", "S", {{"Player", "player"}, {"Access|Command", "string"}, {"Reset", "boolean", true}})

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- RCon Callback.
function COMMAND.RConCallback(Arguments)
	local Access = Arguments[2]
	
	-- Check Access.
	if (citrus.Commands.Stored[Access]) then
		if (Arguments[3]) then
			citrus.PlayerVariables.Get(Arguments[1], "Access").Command[Access] = nil
			
			-- Print.
			print(Arguments[1]:Name().." had '"..Arguments[2].."' access reset (Console).")
			
			-- Notify By Access.
			citrus.Player.NotifyByAccess("M", Arguments[1]:Name().." had '"..Arguments[2].."' access reset (Console).")
			citrus.Player.NotifyByAccess("!M", Arguments[1]:Name().." had '"..Arguments[2].."' access reset.")
		else
			if (citrus.PlayerVariables.Get(Arguments[1], "Access").Command[Access]) then
				citrus.PlayerVariables.Get(Arguments[1], "Access").Command[Access] = false
				
				-- Print.
				print(Arguments[1]:Name().." had '"..Arguments[2].."' access taken (Console).")
				
				-- Notify By Access.
				citrus.Player.NotifyByAccess("M", Arguments[1]:Name().." had '"..Arguments[2].."' access taken (Console).")
				citrus.Player.NotifyByAccess("!M", Arguments[1]:Name().." had '"..Arguments[2].."' access taken.")
			else
				print(Arguments[1]:Name().." does not have '"..Access.."' access!")
			end
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
	local Success, Error = citrus.Access.Take(Arguments[1], Arguments[2])
	
	-- Check Success.
	if (Success) then
		print(Arguments[1]:Name().." had '"..Arguments[2].."' access taken (Console).")
		
		-- Notify By Access.
		citrus.Player.NotifyByAccess("M", Arguments[1]:Name().." had '"..Arguments[2].."' access taken (Console).")
		citrus.Player.NotifyByAccess("!M", Arguments[1]:Name().." had '"..Arguments[2].."' access taken.")
	else
		print(Error)
	end
end

-- Callback.
function COMMAND.Callback(Player, Arguments)
	local Access = Arguments[2]
	
	-- Check Access.
	if (citrus.Commands.Stored[Access]) then
		if (Arguments[3]) then
			citrus.PlayerVariables.Get(Arguments[1], "Access").Command[Access] = nil
			
			-- Notify By Access.
			citrus.Player.NotifyByAccess("M", Arguments[1]:Name().." had '"..Arguments[2].."' access reset (Console).")
			citrus.Player.NotifyByAccess("!M", Arguments[1]:Name().." had '"..Arguments[2].."' access reset.")
		else
			if (citrus.PlayerVariables.Get(Arguments[1], "Access").Command[Access]) then
				citrus.PlayerVariables.Get(Arguments[1], "Access").Command[Access] = false
				
				-- Notify By Access.
				citrus.Player.NotifyByAccess("M", Arguments[1]:Name().." had '"..Arguments[2].."' access taken (Console).")
				citrus.Player.NotifyByAccess("!M", Arguments[1]:Name().." had '"..Arguments[2].."' access taken.")
			else
				citrus.Player.Notify(Player, Arguments[1]:Name().." does not have '"..Access.."' access!", 1)
			end
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
	local Success, Error = citrus.Access.Take(Arguments[1], Arguments[2])
	
	-- Check Success.
	if (Success) then
		citrus.Player.NotifyByAccess("M", Arguments[1]:Name().." had '"..Arguments[2].."' access taken ("..Player:Name()..").")
		citrus.Player.NotifyByAccess("!M", Arguments[1]:Name().." had '"..Arguments[2].."' access taken.")
	else
		citrus.Player.Notify(Player, Error, 1)
	end
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Player Management", "Take Access", {{"Player", citrus.QuickMenu.GetPlayer}, {"Access|Command", citrus.QuickMenu.GetText}, {"Reset", citrus.QuickMenu.GetBoolean}}, "gui/silkicons/user")


-- Create.
COMMAND:Create()