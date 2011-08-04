--[[
Name: "sv_plugin.lua".
Product: "Citrus (Server Management)".
--]]

local PLUGIN = citrus.Plugin:New("Hide and Seek")

-- Description.
PLUGIN.Settings.Description = "A simple clone of the children's game"
PLUGIN.Settings.Gamemode = {"Sandbox", false}
PLUGIN.Settings.Author = "Conna"
PLUGIN.Settings.Game = true

-- Configuration.
PLUGIN.Configuration = citrus.ParseINI:New("lua/"..PLUGIN.FilePath.."/sv_configuration.ini"):Parse()["Hide and Seek"]

-- On Load.
function PLUGIN:OnLoad()
	PLUGIN.ResetServer()
	
	-- Configuration.
	local Configuration = citrus.Utilities.TableLoad("plugins/hideandseek.txt") or {}
	
	-- Merge.
	table.Merge(PLUGIN.Configuration, Configuration)
	
	-- Allow.
	citrus.PlayerEvents.Allow(false, "Hide and Seek", citrus.PlayerEvent.SpawnObject, false)
	citrus.PlayerEvents.Allow(false, "Hide and Seek", citrus.PlayerEvent.TakeDamage, false)
	citrus.PlayerEvents.Allow(false, "Hide and Seek", citrus.PlayerEvent.EnterVehicle, false)
	citrus.PlayerEvents.Allow(false, "Hide and Seek", citrus.PlayerEvent.Suicide, false)
	citrus.PlayerEvents.Allow(false, "Hide and Seek", citrus.PlayerEvent.UsePhysicsGun, false)
	citrus.PlayerEvents.Allow(false, "Hide and Seek", citrus.PlayerEvent.UseGravityGun, false)
	citrus.PlayerEvents.Allow(false, "Hide and Seek", citrus.PlayerEvent.UseTool, false)
	citrus.PlayerEvents.Allow(false, "Hide and Seek", citrus.PlayerEvent.NoClip, false)
end

-- On Unload.
function PLUGIN:OnUnload()
	citrus.PlayerEvents.AllowAll(false, "Hide and Seek", true)
	
	-- Reset Seeker.
	PLUGIN.ResetServer()
end

-- On Player Load.
function PLUGIN:OnPlayerLoad(Player) PLUGIN.ResetPlayer(Player) end

-- On Save Variables.
function PLUGIN.OnSaveVariables()
	citrus.Utilities.TableSave("plugins/hideandseek.txt", PLUGIN.Configuration)
end

-- On Player Unload.
function PLUGIN:OnPlayerUnload(Player) PLUGIN.ResetPlayer(Player) end

-- Reset Server.
function PLUGIN.ResetServer()
	citrus.NetworkVariables.Set("Hide and Seek", "Seeker", false)
end

-- Reset Player.
function PLUGIN.ResetPlayer(Player)
	citrus.PlayerCookies.Get(Player, "Hide and Seek").Caught = false
	
	-- Allow.
	citrus.PlayerEvents.Allow(Player, "Hide and Seek", citrus.PlayerEvent.Say, true)
	
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
	Menu:TextAdd("At the start of the game a player is randomly chosen to be the seeker.")
	Menu:TextAdd("They will be blind for 30 seconds and then must track down the other players.")
	Menu:TextAdd("The seeker catches a player by looking at them.")
	
	-- Send.
	Menu:Send()
	
	-- Return False.
	return false
end

-- Hook Add.
PLUGIN:HookAdd("ShowHelp", PLUGIN.ShowHelp)

-- On Player Second.
function PLUGIN.OnPlayerSecond(Player)
	citrus.PlayerInformation.Set(Player, "Hide and Seek", "Seeker", (PLUGIN.Seeker == Player))
end

-- On Second.
function PLUGIN.OnSecond()
	local Players = player.GetAll()
	
	-- Check Count.
	if (table.Count(Players) == 1) then
		for K, V in pairs(Players) do V:Spectate(OBS_MODE_ROAMING) end
		
		-- Return.
		return
	end
	
	-- Check Seeker.
	if (PLUGIN.Seeker) then
		local IsValid = PLUGIN.Seeker:IsValid()
		
		-- Check Is Valid.
		if (IsValid) then
			if (!PLUGIN.Started) then
				PLUGIN.Count = (PLUGIN.Count or PLUGIN.Configuration["Count"]) - 1
				
				-- Freeze.
				PLUGIN.Seeker:Freeze(true)
				
				-- Check Count.
				if (PLUGIN.Count == 0) then
					PLUGIN.Started = true
					
					-- Overlay Remove.
					citrus.Player.OverlayRemove(PLUGIN.Seeker, "Hide and Seek")
					
					-- Notify.
					citrus.Player.NotifyAll(PLUGIN.Seeker:Name().." has finished counting!", 0)
				else
					citrus.Player.OverlayAdd(PLUGIN.Seeker, "Hide and Seek", "You are the seeker!", "Count: "..PLUGIN.Count, 255)
				end
			else
				PLUGIN.Count = false
				
				-- Freeze.
				PLUGIN.Seeker:Freeze(false)
				
				-- Caught.
				local Caught = 0
				
				-- For Loop.
				for K, V in pairs(Players) do
					if (citrus.PlayerCookies.Get(V, "Hide and Seek").Caught) then Caught = Caught + 1 end
				end
				
				-- Check Caught.
				if (Caught == (table.Count(Players) - 1)) then
					citrus.Player.NotifyAll(PLUGIN.Seeker:Name().." has caught every player!")
					
					-- Last Seeker.
					PLUGIN.LastSeeker = PLUGIN.Seeker
					PLUGIN.Seeker = false
				end
			end
		else
			PLUGIN.Seeker = false
		end
	else
		for K, V in pairs(Players) do PLUGIN.ResetPlayer(V) end
		
		-- Started.
		PLUGIN.Started = false
		
		-- Get Random Seeker.
		PLUGIN.GetRandomSeeker()
		
		-- For Loop.
		for K, V in pairs(Players) do
			if (PLUGIN.Seeker != V) then
				citrus.Player.CountAdd(V, "Hide and Seek", "Hide", PLUGIN.Configuration["Count"])
			else
				citrus.Player.OverlayAdd(Player, "Hide and Seek", "You are the seeker!", "Count: "..PLUGIN.Configuration["Count"], 255)
			end
		end
	end
end

-- Get Random Seeker.
function PLUGIN.GetRandomSeeker()
	local Players = player.GetAll()
	local Player = citrus.Utilities.GetRandomValue(Players)
	
	-- Check Player.
	if (Player) then
		if (PLUGIN.LastSeeker == Player) then
			PLUGIN.GetRandomSeeker()
		else
			PLUGIN.Seeker = Player
			
			-- Name.
			local Name = PLUGIN.Seeker:Name()
			
			-- Set.
			citrus.NetworkVariables.Set("Hide and Seek", "Seeker", Name)
			
			-- Overlay Add.
			citrus.Player.OverlayAdd(Player, "Hide and Seek", "You are the seeker!", "Count: "..PLUGIN.Configuration["Count"], 255)
			
			-- Notify.
			citrus.Player.NotifyAll(Player:Name().." is randomly made the seeker.", 0)
		end
	end
end

-- On Player Set Variables.
function PLUGIN.OnPlayerSetVariables(Player)
	citrus.PlayerCookies.New(Player, "Hide and Seek", {Caught = false})
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

-- On Player Initial Spawn.
function PLUGIN.OnPlayerInitialSpawn(Player)
	if (PLUGIN.Started) then
		Player:StripWeapons()
		Player:Spectate(OBS_MODE_ROAMING)
		
		-- Notify.
		citrus.Player.Notify(Player, "Unable to play until round is over.")
	end
end

-- Player Say.
function PLUGIN.PlayerSay(Player)
	if (citrus.PlayerCookies.Get(Player, "Hide and Seek").Caught) then
		return false
	end
end

-- Hook Add.
PLUGIN:HookAdd("PlayerSay", PLUGIN.PlayerSay)

-- On Player Second.
function PLUGIN.OnPlayerSecond(Player)
	if (PLUGIN.Started) then
		if (PLUGIN.Seeker == Player) then
			local Trace = citrus.Utilities.PlayerTrace(Player)
			
			-- Check Valid Entity.
			if (ValidEntity(Trace.Entity)) then
				local IsPlayer = Trace.Entity:IsPlayer()
				
				-- Check Is Player,				
				if (IsPlayer) then
					local Position = Trace.Entity:GetPos()
					
					-- Check Distance.
					if (Player:GetPos():Distance(Position) < 1024) then
						local Effect = EffectData()
							Effect:SetStart(Position)
							Effect:SetOrigin(Position)
						util.Effect("Explosion", Effect)
						
						-- Get.
						citrus.PlayerCookies.Get(Trace.Entity, "Hide and Seek").Caught = true
						
						-- Allow.
						citrus.PlayerEvents.Allow(Trace.Entity, "Hide and Seek", citrus.PlayerEvent.Say, false)
						
						-- Specrate.
						Trace.Entity:Spectate(OBS_MODE_ROAMING)
						
						-- Notify All.
						citrus.Player.NotifyAll(Trace.Entity:Name().." is caught by "..Player:Name()..".", 0)
					end
				end
			end
		end
	end
end

-- Include Directory.
citrus.Utilities.IncludeDirectory(PLUGIN.FilePath.."/commands/", "sv_", ".lua")