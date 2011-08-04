--[[
Name: "sv_mysql.lua".
Product: "Citrus (Server Management)".
--]]

local PLUGIN = citrus.Plugins.Get("Bans")

-- MySQL.
PLUGIN.MySQL = {}

-- Connect.
function PLUGIN.MySQL.Connect()
	local Database = gdatabase.MakeConnection(
		PLUGIN.Configuration["Host"],
		PLUGIN.Configuration["Username"],
		PLUGIN.Configuration["Password"],
		PLUGIN.Configuration["Database"]
	)
	
	-- Connection.
	local Connection = gdatabase.CheckForConnection(Database)
	
	-- Check Connection.
	if (Connection) then PLUGIN.MySQL.Connection = Database end
	
	-- Return Connection.
	return Connection
end

-- Disconnect.
function PLUGIN.MySQL.Disconnect()
	gdatabase.KillConnection(PLUGIN.MySQL.Connection)
	
	-- Connection.
	PLUGIN.MySQL.Connection = nil
end

-- Query.
function PLUGIN.MySQL.Query(String, Callback)
	local Connection = true
	
	-- Check Connection.
	if (!PLUGIN.MySQL.Connection) then
		local Success = PLUGIN.MySQL.Connect()
		
		-- Check Success.
		if (!Success) then return end
		
		-- Connection.
		Connection = false
	end
	
	-- Callback.
	Callback = Callback or function() end
	
	-- Threaded Query.
	gdatabase.ThreadedQuery(String, PLUGIN.MySQL.Connection, Callback)
	
	-- Check Connection.
	if (!Connection) then PLUGIN.MySQL.Disconnect() end
end

-- Insert.
function PLUGIN.MySQL.Insert(Table)
	local Connection = true
	
	-- Check Connection.
	if (!PLUGIN.MySQL.Connection) then
		local Success = PLUGIN.MySQL.Connect()
		
		-- Check Success.
		if (!Success) then return end
		
		-- Connection.
		Connection = false
	end
	
	-- Arguments.
	local Arguments = ""
	local Values = ""
	local Count = table.Count(Table)
	local Key = 0
	
	-- For Loop.
	for K, V in pairs(Table) do
		Key = Key + 1
		
		-- K.
		K = gdatabase.CleanString(PLUGIN.MySQL.Connection, K)
		V = gdatabase.CleanString(PLUGIN.MySQL.Connection, V)
		
		-- Check Key.
		if (Key == Count) then
			Arguments = Arguments.."_"..K
			Values = Values.."'"..V.."'"
		else
			Arguments = Arguments.."_"..K..", "
			Values = Values.."'"..V.."', "
		end
	end
	
	-- Query.
	PLUGIN.MySQL.Query("INSERT INTO "..PLUGIN.Configuration["Table"].." ("..Arguments..") VALUES("..Values..")")
	
	-- Check Connection.
	if (!Connection) then PLUGIN.MySQL.Disconnect() end
end

-- Get Table Count.
function PLUGIN.MySQL.GetTableCount(Callback)
	PLUGIN.MySQL.Query("SELECT COUNT(_Key) FROM "..PLUGIN.Configuration["Table"], Callback)
end