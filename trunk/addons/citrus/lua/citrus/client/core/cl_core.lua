--[[
Name: "cl_core.lua".
Product: "Citrus (Server Management)".
--]]

surface.CreateFont("CoolVetica", 70, 250, true, false, "citrus_HugeTitle")
surface.CreateFont("Tahoma", 13, 600, true, false, "citrus_TinyText")
surface.CreateFont("Tahoma", 14, 600, true, false, "citrus_MainText")
surface.CreateFont("Tahoma", 18, 600, true, false, "citrus_LargeText")

-- Add.
hook.Add("OnEntityCreated", "citrus.OnEntityCreated", function(Entity)
	if (LocalPlayer() == Entity) then LocalPlayer():ConCommand("cl_citrus_initialize\n") end
end)

-- Hook.
usermessage.Hook("citrus.ConsoleCommand", function(Message)
	LocalPlayer():ConCommand(Message:ReadString().."\n")
end)

-- HUD Draw Scoreboard.
function citrus.HUDDrawScoreBoard()
	local Player = LocalPlayer()
	local Trace = citrus.Utilities.PlayerTrace(Player)
	
	-- Players.
	local Players = player.GetAll()
	
	-- For Loop.
	for K, V in pairs(Players) do
		local Alive = V:Alive()
		
		-- Check Alive.
		if (Alive) then
			if (V != LocalPlayer()) then
				citrus.Hooks.Call("OnDrawPlayer", V)
				
				-- Check Entity.
				if (Trace.Entity == V) then citrus.Hooks.Call("OnDrawTarget", V) end
			end
		end
	end
	
	-- Call.
	citrus.Hooks.Call("OnDraw")
end

-- Add.
hook.Add("HUDDrawScoreBoard", "citrus.HUDDrawScoreBoard", citrus.HUDDrawScoreBoard)