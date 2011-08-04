--[[
Name: "sv_plugin.lua".
Product: "Citrus (Server Management)".
--]]

local PLUGIN = citrus.Plugin:New("Points")

-- Gamemode.
PLUGIN.Settings.Description = "Players gain points and can spend them on purchases"
PLUGIN.Settings.Author = "Conna"
PLUGIN.Settings.Gamemode = {"Sandbox", true}

-- Configuration.
PLUGIN.Configuration = citrus.ParseINI:New("lua/"..PLUGIN.FilePath.."/sv_configuration.ini"):Parse()["Points"]

-- On Load.
function PLUGIN:OnLoad()
	local Configuration = citrus.Utilities.TableLoad("plugins/points.txt") or {}
	
	-- Merge.
	table.Merge(PLUGIN.Configuration, Configuration)

	-- Check Purchases.
	if (!PLUGIN.Purchases) then
		PLUGIN.Purchases = {}
		
		-- Include Directory.
		citrus.Utilities.IncludeDirectory(PLUGIN.FilePath.."/purchases/", "sv_", ".lua")
	end
end

-- On Save Variables.
function PLUGIN.OnSaveVariables()
	citrus.Utilities.TableSave("plugins/points.txt", PLUGIN.Configuration)
end

-- Give.
function PLUGIN.Give(Player, Amount)
	local Points = citrus.PlayerVariables.Get(Player, "Points")
	
	-- Points.
	Points.Points = Points.Points + Amount
end

-- Take.
function PLUGIN.Take(Player, Amount)
	local Points = citrus.PlayerVariables.Get(Player, "Points")
	
	-- Points.
	Points.Points = math.max(Points.Points - Amount, 0)
end

-- Has.
function PLUGIN.Has(Player, Amount)
	local Points = citrus.PlayerVariables.Get(Player, "Points")
	
	-- Check Points.
	if (Points.Points >= Amount) then return true end
	
	-- Return False.
	return false
end

-- On Player Minute.
function PLUGIN.OnPlayerMinute(Player)
	local Points = citrus.PlayerVariables.Get(Player, "Points")
	
	-- Timer.
	Points.Timer = Points.Timer + 1
	
	-- Check Timer.
	if (Points.Timer >= PLUGIN.Configuration["Interval"]) then
		Points.Timer = 0
		
		-- Give.
		PLUGIN.Give(Player, 1)
		
		-- Notify.
		citrus.Player.Notify(Player, "You have gained "..PLUGIN.Configuration["Increment"].." point(s).")
	end
end

-- On Hook Called.
function PLUGIN.OnHookCalled(Hook, ...)
	for K, V in pairs(PLUGIN.Purchases) do
		if (V[Hook]) then
			local Success, Error = pcall(V[Hook], unpack(arg))
			
			-- Check Success.
			if (!Success) then print(Error) end
		end
	end
end

-- On Player Second.
function PLUGIN.OnPlayerSecond(Player)
	local Points = citrus.PlayerVariables.Get(Player, "Points")
	
	-- Set.
	citrus.PlayerInformation.Set(Player, "Public", "Points", Points.Points)
end

-- On Player Set Variables.
function PLUGIN.OnPlayerSetVariables(Player)
	citrus.PlayerVariables.New(Player, "Points", {Points = PLUGIN.Configuration["Default"], Timer = 0, Purchases = {}})
end

-- Include Directory.
citrus.Utilities.IncludeDirectory(PLUGIN.FilePath.."/commands/", "sv_", ".lua")