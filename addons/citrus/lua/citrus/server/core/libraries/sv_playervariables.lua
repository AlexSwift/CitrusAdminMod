--[[
Name: "sv_playervariables.lua".
Product: "Citrus (Server Management)".
--]]

citrus.PlayerVariables = {}
citrus.PlayerVariables.Stored = {}

-- New.
function citrus.PlayerVariables.New(Player, Key, Value)
	local UniqueID = citrus.Player.GetUniqueID(Player)
	
	-- Check Exists.
	if (!citrus.PlayerVariables.Exists(Player)) then return false end
	
	-- List.
	citrus.PlayerVariables.Stored[UniqueID][Key] = citrus.PlayerVariables.Stored[UniqueID][Key] or Value
	
	-- Check Type.
	if (type(citrus.PlayerVariables.Stored[UniqueID][Key]) != type(Value)) then
		citrus.PlayerVariables.Stored[UniqueID][Key] = Value
	end
	
	-- Check type.
	if (type(Value) == "table") then
		citrus.Utilities.CopyMissingKeyValues(citrus.PlayerVariables.Stored[UniqueID][Key], Value)
	end
end

-- Exists.
function citrus.PlayerVariables.Exists(Player)
	local UniqueID = citrus.Player.GetUniqueID(Player)
	
	-- Check List.
	return (citrus.PlayerVariables.Stored[UniqueID] != nil)
end

-- Create.
function citrus.PlayerVariables.Create(Player)
	local UniqueID = citrus.Player.GetUniqueID(Player)
	
	-- List.
	citrus.PlayerVariables.Stored[UniqueID] = citrus.PlayerVariables.Stored[UniqueID] or {}
end

-- Get.
function citrus.PlayerVariables.Get(Player, Key)
	local UniqueID = citrus.Player.GetUniqueID(Player)
	
	-- Check Exists.
	if (!citrus.PlayerVariables.Exists(Player)) then return false end

	-- Return List.
	return citrus.PlayerVariables.Stored[UniqueID][Key]
end

-- Set.
function citrus.PlayerVariables.Set(Player, Key, Value)
	local UniqueID = citrus.Player.GetUniqueID(Player)
	
	-- Check Exists.
	if (!citrus.PlayerVariables.Exists(Player)) then return false end
	
	-- Key.
	citrus.PlayerVariables.Stored[UniqueID][Key] = Value
end

-- Save.
function citrus.PlayerVariables.Save(Player)
	local UniqueID = citrus.Player.GetUniqueID(Player)
	
	-- Table Save.
	citrus.PlayerVariables.TableSave(UniqueID)
end

-- Add.
citrus.Hooks.Add("OnPlayerMinute", citrus.PlayerVariables.Save)

-- Table Load.
function citrus.PlayerVariables.TableLoad(UniqueID)
	local Table = citrus.Utilities.TableLoad("variables/player/"..UniqueID..".txt")
	
	-- Return Table.
	return Table
end

-- Table Save.
function citrus.PlayerVariables.TableSave(UniqueID)
	citrus.Utilities.TableSave("variables/player/"..UniqueID..".txt", citrus.PlayerVariables.Stored[UniqueID])
end

-- Load.
function citrus.PlayerVariables.Load(Player)
	local UniqueID = citrus.Player.GetUniqueID(Player)
	
	-- Table.
	local Table = citrus.PlayerVariables.TableLoad(UniqueID)
	
	-- Check Table.
	if (Table) then citrus.PlayerVariables.Stored[UniqueID] = Table end
end

-- Get All.
function citrus.PlayerVariables.GetAll(Player)
	local UniqueID = citrus.Player.GetUniqueID(Player)
	
	-- Return Unique ID.
	return citrus.PlayerVariables.Stored[UniqueID]
end

-- Add.
hook.Add("PlayerDisconnected", "citrus.PlayerVariables.PlayerDisconnected", function(Player)
	citrus.PlayerVariables.Save(Player)
	
	-- Unique ID.
	local UniqueID = citrus.Player.GetUniqueID(Player)
	
	-- Unique ID.
	citrus.PlayerVariables.Stored[UniqueID] = nil
end)

-- Add.
hook.Add("ShutDown", "citrus.PlayerVariables.ShutDown", function()
	local Players = player.GetAll()
	
	-- For Loop.
	for K, V in pairs(Players) do citrus.PlayerVariables.Save(V) end
end)