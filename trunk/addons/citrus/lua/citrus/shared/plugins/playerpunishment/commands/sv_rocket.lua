--[[
Name: "sv_rocket.lua".
Product: "Citrus (Server Management)"
--]]

local COMMAND = citrus.Command:New("rocket", "M", {{"Player", "player"}, {"Kill", "boolean", true}})

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Player Punishment")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- Rocket.
function COMMAND.Rocket(Player, Kill, Name)
	local Team = Player:Team()
	
	-- Trail.
	local Trail = util.SpriteTrail(Player, 0, team.GetColor(Team), false, 64, 64, 3, 0.5, "trails/smoke.vmt")
	
	-- Safe Remove Entity Delayed.
	SafeRemoveEntityDelayed(Trail, 3)
	
	-- Set Velocity.
	Player:SetVelocity(Vector(0, 0, 2048))
	
	-- Simple.
	timer.Simple(3, function()
		local Position = Player:GetPos()
		
		-- Effect.
		local Effect = EffectData()
		
		-- Effect Functions.
		Effect:SetOrigin(Position)
		Effect:SetStart(Position)
		Effect:SetMagnitude(512)
		Effect:SetScale(128)
		
		-- Effect.
		util.Effect("Explosion", Effect)
		
		-- Check Kill.
		if (Kill) then Player:Kill() end
	end)
	
	-- Notify By Access.
	citrus.Player.NotifyByAccess("M", Player:Name().." is rocketed ("..Name..").")
	citrus.Player.NotifyByAccess("!M", Player:Name().." is rocketed.")
end

-- RCon Callback.
function COMMAND.RConCallback(Arguments)
	COMMAND.Rocket(Arguments[1], Arguments[2], "Console")
	
	-- Print.
	print(Arguments[1]:Name().." is rocketed (Console).")
end

-- Callback.
function COMMAND.Callback(Player, Arguments)
	local Error = citrus.Player.IsImmune(Player, Arguments[1])
	
	-- Check Error.
	if (Error and Player != Arguments[1]) then citrus.Player.Notify(Player, Error, 1) return end
	
	-- Rocket.
	COMMAND.Rocket(Arguments[1], Arguments[2], Player:Name())
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Player Punishment", "Rocket", {{"Player", citrus.QuickMenu.GetPlayer}, {"Kill", citrus.QuickMenu.GetBoolean}})

-- Create.
COMMAND:Create()