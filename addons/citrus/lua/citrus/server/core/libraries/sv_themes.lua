--[[
Name: "sv_themes.lua".
Product: "Citrus (Server Management)".
--]]

citrus.Themes = {}
citrus.Themes.Stored = {}

-- Add.
function citrus.Themes.Add(Theme, Table) citrus.Themes.Stored[Theme] = Table end

-- Get.
function citrus.Themes.Get(Theme)
	if (citrus.Themes.Stored[Theme]) then
		return citrus.Themes.Stored[Theme]
	else
		return false, "Unable to locate '"..Theme.."'!"
	end
end

-- Send.
function citrus.Themes.Send(Player, Theme)
	if (citrus.Themes.Stored[Theme]) then
		if (!citrus.PlayerCookies.Get(Player, "Downloaded Themes")[Theme]) then
			local Settings = citrus.Themes.Stored[Theme].Settings
			local Colors = citrus.Themes.Stored[Theme].Colors
			local Sizes = citrus.Themes.Stored[Theme].Sizes
			
			-- Start.
			umsg.Start("citrus.Themes.New", Player)
				umsg.String(Theme)
			umsg.End()
			
			-- For Loop.
			for K, V in pairs(Settings) do
				umsg.Start("citrus.Themes.Setting", Player)
					umsg.String(K)
					umsg.String(V)
				umsg.End()
			end
			
			-- For Loop.
			for K, V in pairs(Colors) do
				umsg.Start("citrus.Themes.Color", Player)
					umsg.String(K)
					umsg.Short(V.r)
					umsg.Short(V.g)
					umsg.Short(V.b)
					umsg.Short(V.a)
				umsg.End()
			end
			
			-- For Loop.
			for K, V in pairs(Sizes) do
				umsg.Start("citrus.Themes.Size", Player)
					umsg.String(K)
					umsg.Short(V)
				umsg.End()
			end
			
			-- Start.
			umsg.Start("citrus.Themes.Add", Player)
			umsg.End()
			
			-- Get.
			citrus.PlayerCookies.Get(Player, "Downloaded Themes")[Theme] = true
		end
	end
end

-- Set.
function citrus.Themes.Set(Theme)
	for K, V in pairs(citrus.Themes.Stored) do
		if (string.lower(K) == string.lower(Theme)) then
			local Players = player.GetAll()
			
			-- For Loop.
			for K2, V2 in pairs(Players) do citrus.Themes.Send(V2, K) end
			
			-- Start.
			umsg.Start("citrus.Themes.Set") umsg.String(K) umsg.End()
			
			-- Set.
			citrus.ServerVariables.Set("Theme", Theme)
			
			-- Return True.
			return true
		end
	end
	
	-- Return False.
	return false
end

-- On Load Variables.
function citrus.Themes.OnLoadVariables()
	citrus.ServerVariables.New("Theme", "Citrus")
	
	-- Theme.
	local Theme = citrus.ServerVariables.Get("Theme")
	
	-- Check Get.
	if (!citrus.Themes.Get(Theme)) then
		for K, V in pairs(citrus.Themes.Stored) do
			citrus.Themes.Set(K)
			
			-- Return.
			return
		end
	end
end

-- Add.
citrus.Hooks.Add("OnLoadVariables", citrus.Themes.OnLoadVariables)

-- On Player Set Variables.
function citrus.Themes.OnPlayerSetVariables(Player) citrus.PlayerCookies.New(Player, "Downloaded Themes", {}) end

-- Add.
citrus.Hooks.Add("OnPlayerSetVariables", citrus.Themes.OnPlayerSetVariables)

-- On Player Initial Spawn.
function citrus.Themes.OnPlayerInitialSpawn(Player)
	local Theme = citrus.ServerVariables.Get("Theme")
	
	-- Send.
	citrus.Themes.Send(Player, Theme)
	
	-- Start.
	umsg.Start("citrus.Themes.Set", Player)
		umsg.String(Theme)
	umsg.End()
end

-- Add.
citrus.Hooks.Add("OnPlayerInitialSpawn", citrus.Themes.OnPlayerInitialSpawn)