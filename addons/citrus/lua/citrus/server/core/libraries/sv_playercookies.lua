--[[
Name: "sv_playercookies.lua".
Product: "Citrus (Server Management)".
--]]

citrus.PlayerCookies = {}
citrus.PlayerCookies.Stored = {}

-- New.
function citrus.PlayerCookies.New(Player, Key, Value)
	local UniqueID = citrus.Player.GetUniqueID(Player)
	
	-- Key.
	citrus.PlayerCookies.Stored[UniqueID][Key] = citrus.PlayerCookies.Stored[UniqueID][Key] or Value
	
	-- Check type.
	if (type(citrus.PlayerCookies.Stored[UniqueID][Key]) != type(Value)) then
		citrus.PlayerCookies.Stored[UniqueID][Key] = Value
	end
	
	-- Check type.
	if (type(Value) == "table") then
		citrus.Utilities.CopyMissingKeyValues(citrus.PlayerCookies.Stored[UniqueID][Key], Value)
	end
end

-- Create.
function citrus.PlayerCookies.Create(Player)
	local UniqueID = citrus.Player.GetUniqueID(Player)
	
	-- Unique ID.
	citrus.PlayerCookies.Stored[UniqueID] = {}
end

-- Get.
function citrus.PlayerCookies.Get(Player, Key)
	local UniqueID = citrus.Player.GetUniqueID(Player)
	
	-- Return List.
	return citrus.PlayerCookies.Stored[UniqueID][Key]
end

-- Set.
function citrus.PlayerCookies.Set(Player, Key, Value)
	local UniqueID = citrus.Player.GetUniqueID(Player)
	
	-- Stored.
	citrus.PlayerCookies.Stored[UniqueID][Key] = Value
end

-- Get All.
function citrus.PlayerCookies.GetAll(Player)
	local UniqueID = citrus.Player.GetUniqueID(Player)
	
	-- Return Unique ID.
	return citrus.PlayerCookies.Stored[UniqueID]
end

-- Add.
hook.Add("PlayerDisconnected", "citrus.PlayerCookies.PlayerDisconnected", function(Player)
	local UniqueID = citrus.Player.GetUniqueID(Player)
	
	-- Unique ID.
	citrus.PlayerCookies.Stored[UniqueID] = nil
end)