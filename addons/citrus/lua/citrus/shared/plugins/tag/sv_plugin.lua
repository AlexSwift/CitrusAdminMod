--[[
Name: "sv_plugin.lua".
Product: "Citrus (Server Management)".
--]]

local PLUGIN = citrus.Plugin:New("Tag")

-- Description.
PLUGIN.Settings.Description = "A simple clone of the children's game"
PLUGIN.Settings.Gamemode = {"Sandbox", false}
PLUGIN.Settings.Author = "Conna"
PLUGIN.Settings.Game = true

-- On Load.
function PLUGIN:OnLoad()
	citrus.NetworkVariables.Set("Tag", "Tagged", "N/A")
	
	-- Allow.
	citrus.PlayerEvents.Allow(false, "Tag", citrus.PlayerEvent.SpawnObject, false)
	citrus.PlayerEvents.Allow(false, "Tag", citrus.PlayerEvent.TakeDamage, false)
	citrus.PlayerEvents.Allow(false, "Tag", citrus.PlayerEvent.EnterVehicle, false)
	citrus.PlayerEvents.Allow(false, "Tag", citrus.PlayerEvent.Suicide, false)
	citrus.PlayerEvents.Allow(false, "Tag", citrus.PlayerEvent.UsePhysicsGun, false)
	citrus.PlayerEvents.Allow(false, "Tag", citrus.PlayerEvent.UseGravityGun, false)
	citrus.PlayerEvents.Allow(false, "Tag", citrus.PlayerEvent.UseTool, false)
	citrus.PlayerEvents.Allow(false, "Tag", citrus.PlayerEvent.NoClip, false)
end

-- On Unload.
function PLUGIN:OnUnload()
	citrus.NetworkVariables.Set("Tag", "Tagged", "N/A")
	
	-- Allow All.
	citrus.PlayerEvents.AllowAll(false, "Tag", true)
end

-- On Player Load.
function PLUGIN:OnPlayerLoad(Player) PLUGIN.ResetPlayer(Player) end

-- On Player Unload.
function PLUGIN:OnPlayerUnload(Player) PLUGIN.ResetPlayer(Player) end

-- Reset Player.
function PLUGIN.ResetPlayer(Player)
	citrus.PlayerCookies.Get(Player, "Tag").Tagged = false
	
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
	Menu:TextAdd("At the start of the game a player is randomly tagged and must")
	Menu:TextAdd("tag another player by attacking them. This process is repeated.")
	
	-- Send.
	Menu:Send()
	
	-- Return False.
	return false
end

-- Hook Add.
PLUGIN:HookAdd("ShowHelp", PLUGIN.ShowHelp)

-- On Second.
function PLUGIN.OnSecond()
	if (PLUGIN.Tagged) then
		local IsValid = PLUGIN.Tagged:IsValid()
		
		-- Check Is Valid.
		if (IsValid) then
			citrus.NetworkVariables.Set("Tag", "Tagged", PLUGIN.Tagged:Name())
		else
			PLUGIN.Tagged = false
		end
	end
	
	-- Check Tagged.
	if (!PLUGIN.Tagged) then PLUGIN.TagRandomPlayer() end
end

-- Tag Random Player.
function PLUGIN.TagRandomPlayer()
	local Players = player.GetAll()
	local Player = citrus.Utilities.GetRandomValue(Players)
	
	-- Check Player.
	if (Player) then
		PLUGIN.Tagged = Player
		
		-- Notify.
		citrus.Player.NotifyAll(Player:Name().." is tagged at random.", 0)
	end
end

-- On Player Set Variables.
function PLUGIN.OnPlayerSetVariables(Player)
	citrus.PlayerCookies.New(Player, "Tag", {Tagged = false})
end

-- Player Loadout.
function PLUGIN.PlayerLoadout(Player)
	PLUGIN:TimerCreate(false, FrameTime() * 0.5, 1, function()
		Player:StripWeapons()
		Player:ShouldDropWeapon(false)
	end)
end

-- Hook Add.
PLUGIN:HookAdd("PlayerLoadout", PLUGIN.PlayerLoadout)

-- Key Press.
function PLUGIN.KeyPress(Player, Key)
	if (Key == IN_ATTACK) then
		if (PLUGIN.Tagged == Player) then
			local Trace = citrus.Utilities.PlayerTrace(Player)
			
			-- Check Entity.
			if (Trace.Entity) then
				local IsPlayer = Trace.Entity:IsPlayer()
				
				-- Check Is Player.
				if (IsPlayer) then
					local Position = Player:GetPos()
					
					-- Check Distance.
					if (Trace.Entity:GetPos():Distance(Position) < 256) then
						PLUGIN.Tagged = Trace.Entity
						
						-- Effect.
						local Effect = EffectData()
							Effect:SetStart(Position)
							Effect:SetOrigin(Position)
						util.Effect("Explosion", Effect)
						
						-- Notify.
						citrus.Player.Notify(Player, "You have tagged "..Trace.Entity:Name()..".")
						citrus.Player.Notify(Trace.Entity, "You have been tagged by "..Player:Name().."!", 1)
					end
				end
			end
		end
	end
end

-- Hook Add.
PLUGIN:HookAdd("KeyPress", PLUGIN.KeyPress)