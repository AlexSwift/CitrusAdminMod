--[[
Name: "sv_slap.lua".
Product: "Citrus (Server Management)"
--]]

local COMMAND = citrus.Command:New("slap", "M", {{"Player", "player"}, {"Slap(s)", "number"}, {"Damage", "number", true}})

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Player Punishment")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- Slap.
function COMMAND.Slap(Player, Slaps, Damage, Name)
	local function Slap(Player, Damage)
		if (ValidEntity(Player)) then
			local Alive = Player:Alive()
			
			-- Check Alive.
			if (!Alive) then return end
			
			-- Set Velocity.
			Player:SetVelocity(Vector(math.random(-500, 250), math.random(-500, 250), 500))
			
			-- Take Damage.
			Player:TakeDamage(Damage, Player)
		end
	end
	
	-- Check Slaps.
	if (Slaps > 1) then
		PLUGIN:TimerCreate(false, 1, Slaps - 1, Slap, Player, Damage or 0)
	end
	
	-- Slap.
	Slap(Player, Damage)
	
	-- Notify By Access.
	citrus.Player.NotifyByAccess("M", Player:Name().." is given "..Slaps.." slap(s) with "..(Damage or 0).." damage ("..Name..").")
	citrus.Player.NotifyByAccess("!M", Player:Name().." is given "..Slaps.." slap(s) with "..(Damage or 0).." damage.")
end

-- RCon Callback.
function COMMAND.RConCallback(Arguments)
	if (Arguments[3] and Arguments[3] < 0) then
		print("Unable to slap with negative damage!")
		
		-- Return False.
		return false
	end
	
	-- Check 2.
	if (Arguments[2] < 0) then
		print("Unable to give negative slap(s)!")
		
		-- Return False.
		return false
	end
	
	-- Slap.
	COMMAND.Slap(Arguments[1], Arguments[2], Arguments[3] or 0, "Console")
end

-- Callback.
function COMMAND.Callback(Player, Arguments)
	if (Arguments[3] and Arguments[3] < 0) then
		citrus.Player.Notify(Player, "Unable to slap with negative damage!", 1)
		
		-- Return False.
		return false
	end
	
	-- Check 2.
	if (Arguments[2] < 0) then
		citrus.Player.Notify(Player, "Unable to give negative slap(s)!", 1)
		
		-- Return False.
		return false
	end
	
	-- Error.
	local Error = citrus.Player.IsImmune(Player, Arguments[1])
	
	-- Check Error.
	if (Error and Player != Arguments[1]) then citrus.Player.Notify(Player, Error, 1) return end
	
	-- Slap.
	COMMAND.Slap(Arguments[1], Arguments[2], Arguments[3] or 0, Player:Name())
end

-- Get Slaps.
function COMMAND.GetSlaps(Player, Menu, Argument)
	Menu:SliderAdd("Slap(s)", function(Player, Value)
		citrus.QuickMenu.SetArgument(Player, Argument, Value)
	end, 0, 60)
end

-- Get Damage.
function COMMAND.GetDamage(Player, Menu, Argument)
	Menu:SliderAdd("Damage", function(Player, Value)
		citrus.QuickMenu.SetArgument(Player, Argument, Value)
	end, 0, 250)
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Player Punishment", "Slap", {{"Player", citrus.QuickMenu.GetPlayer}, {"Slaps", COMMAND.GetSlaps}, {"Damage", COMMAND.GetDamage}})

-- Create.
COMMAND:Create()