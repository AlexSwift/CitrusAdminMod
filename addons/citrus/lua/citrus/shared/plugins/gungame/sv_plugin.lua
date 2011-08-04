--[[
Name: "sv_plugin.lua".
Product: "Citrus (Server Management)".
--]]

local PLUGIN = citrus.Plugin:New("GunGame")

-- Description.
PLUGIN.Settings.Description = "A simple clone of the Counter-Strike gamemode"
PLUGIN.Settings.Gamemode = {"Sandbox", false}
PLUGIN.Settings.Author = "Conna"
PLUGIN.Settings.Game = true

-- Configuration.
PLUGIN.Configuration = citrus.ParseINI:New("lua/"..PLUGIN.FilePath.."/sv_configuration.ini"):Parse()["GunGame"]

-- On Load.
function PLUGIN:OnLoad()
	self.ResetServer()
	
	-- Player Damage.
	self.PlayerDamage = GetConVarNumber("sbox_plpldamage")
	
	-- Console Command.
	game.ConsoleCommand("sbox_plpldamage 0\n")
	
	-- Allow.
	citrus.PlayerEvents.Allow(false, "GunGame", citrus.PlayerEvent.SpawnObject, false)
	citrus.PlayerEvents.Allow(false, "GunGame", citrus.PlayerEvent.EnterVehicle, false)
	citrus.PlayerEvents.Allow(false, "GunGame", citrus.PlayerEvent.Suicide, false)
	citrus.PlayerEvents.Allow(false, "GunGame", citrus.PlayerEvent.UsePhysicsGun, false)
	citrus.PlayerEvents.Allow(false, "GunGame", citrus.PlayerEvent.UseGravityGun, false)
	citrus.PlayerEvents.Allow(false, "GunGame", citrus.PlayerEvent.NoClip, false)
	citrus.PlayerEvents.Allow(false, "GunGame", citrus.PlayerEvent.UseTool, false)
end

-- On Unload.
function PLUGIN:OnUnload()
	citrus.PlayerEvents.AllowAll(false, "GunGame", true)
	
	-- Console Command.
	game.ConsoleCommand("sbox_plpldamage "..self.PlayerDamage.."\n")
end

-- On Player Load.
function PLUGIN:OnPlayerLoad(Player) self.ResetPlayer(Player) end

-- On Player Unload.
function PLUGIN:OnPlayerUnload(Player) self.ResetPlayer(Player) end

-- Restart Game.
function PLUGIN.RestartGame()
	PLUGIN.ResetServer()
	
	-- Players.
	local Players = player.GetAll()
	
	-- For Loop.
	for K, V in pairs(Players) do PLUGIN.ResetPlayer(V) end
end

-- Reset Server.
function PLUGIN.ResetServer()
	citrus.NetworkVariables.Set("GunGame", "Leader", "N/A")
end

-- Reset Player.
function PLUGIN.ResetPlayer(Player)
	citrus.PlayerCookies.Get(Player, "GunGame").Level = 1
	
	-- Spawn.
	Player:Spawn()
end

-- Show Help.
function PLUGIN.ShowHelp(Player)
	local Menu = citrus.Menu:New()
	
	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Help")
	Menu:SetIcon("gui/silkicons/page")
	Menu:SetReference(PLUGIN.ShowHelp)
	
	-- Text Add.
	Menu:TextAdd("You begin the game with a "..PLUGIN.Configuration[1].." and you have to")
	Menu:TextAdd("kill another player with it to gain a new weapon. You must repeat")
	Menu:TextAdd("the process until you have won by killing another player with the")
	Menu:TextAdd("final weapon ("..PLUGIN.Configuration[table.Count(PLUGIN.Configuration)]..").")
	
	-- Send.
	Menu:Send()
	
	-- Return False.
	return false
end

-- Hook Add.
PLUGIN:HookAdd("ShowHelp", PLUGIN.ShowHelp)

-- On Second.
function PLUGIN.OnSecond()
	local Players = player.GetAll()
	
	-- Highest.
	local Highest = {false, 0}
	
	-- For Loop.
	for K, V in pairs(Players) do
		local Level = citrus.PlayerCookies.Get(V, "GunGame").Level
		
		-- Check Level.
		if (Level > Highest[2]) then
			Highest[1] = V:Name()
			Highest[2] = Level
		end
	end
	
	-- Set.
	citrus.NetworkVariables.Set("GunGame", "Leader", Highest[1].." ("..Highest[2].."/"..table.Count(PLUGIN.Configuration)..")")
end

-- Player Loadout.
function PLUGIN.PlayerLoadout(Player)
	PLUGIN:TimerCreate(false, FrameTime() * 0.5, 1, function()
		Player:StripWeapons()
		Player:ShouldDropWeapon(false)
		
		-- Give Weapon.
		PLUGIN.GiveWeapon(Player)
	end)
end

-- Hook Add.
PLUGIN:HookAdd("PlayerLoadout", PLUGIN.PlayerLoadout)

-- Give Weapon.
function PLUGIN.GiveWeapon(Player)
	local Level = citrus.PlayerCookies.Get(Player, "GunGame").Level
	
	-- Check Level.
	if (PLUGIN.Configuration[Level]) then
		Player:StripWeapons()
		Player:Give(PLUGIN.Configuration[Level])
		
		-- Select Weapon.
		Player:SelectWeapon(PLUGIN.Configuration[Level])
	end
end

-- On Player Set Variables.
function PLUGIN.OnPlayerSetVariables(Player)
	citrus.PlayerCookies.New(Player, "GunGame", {Level = 1})
end

-- On Player Second.
function PLUGIN.OnPlayerSecond(Player)
	local Level = citrus.PlayerCookies.Get(Player, "GunGame").Level
	
	-- Check Weapons.
	if (PLUGIN.Configuration[Level]) then
		citrus.PlayerInformation.Set(Player, "GunGame", "Level", Level.."/"..table.Count(PLUGIN.Configuration).." ("..PLUGIN.Configuration[Level]..")")
	end
end

-- Player Death.
function PLUGIN.PlayerDeath(Player, Killer)
	local IsPlayer = Killer:IsPlayer()
	
	-- Check Is Player.
	if (IsPlayer) then
		if (Player != Killer) then
			local Level = citrus.PlayerCookies.Get(Killer, "GunGame").Level
			
			-- Check Get Active Weapon.
			if (Killer:GetActiveWeapon() == Killer:GetWeapon(PLUGIN.Configuration[Level])) then
				Level = Level + 1
				
				-- Get.
				citrus.PlayerCookies.Get(Killer, "GunGame").Level = Level
				
				-- Check Level.
				if (Level > table.Count(PLUGIN.Configuration)) then
					citrus.Player.NotifyAll(Killer:Name().." has won the game at level "..table.Count(PLUGIN.Configuration)..".", 0)
					
					-- Restart Game.
					PLUGIN.RestartGame()
				else
					PLUGIN.GiveWeapon(Killer)
				end
			end
		end
	end
end

-- Hook Add.
PLUGIN:HookAdd("PlayerDeath", PLUGIN.PlayerDeath)