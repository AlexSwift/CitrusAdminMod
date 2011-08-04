--[[
Name: "sv_servervariable.lua".
Product: "Citrus (Server Management)".
--]]

citrus.ServerVariables = {}

-- New.
function citrus.ServerVariables.New(Key, Value)
	citrus.ServerVariables.Stored[Key] = citrus.ServerVariables.Stored[Key] or Value
	
	-- Check type.
	if (type(citrus.ServerVariables.Stored[Key]) != type(Value)) then
		citrus.ServerVariables.Stored[Key] = Value
	end
	
	-- Check type.
	if (type(Value) == "table") then
		citrus.Utilities.CopyMissingKeyValues(citrus.ServerVariables.Stored[Key], Value)
	end
end

-- Get All.
function citrus.ServerVariables.GetAll()
	return citrus.ServerVariables.Stored
end

-- Get.
function citrus.ServerVariables.Get(Key) return citrus.ServerVariables.Stored[Key] end

-- Set.
function citrus.ServerVariables.Set(Key, Value) citrus.ServerVariables.Stored[Key] = Value end

-- Table Load.
function citrus.ServerVariables.TableLoad()
	local Table = citrus.Utilities.TableLoad("variables/server.txt")
	
	-- Return Table.
	return Table
end

-- Table Save.
function citrus.ServerVariables.TableSave()
	citrus.Utilities.TableSave("variables/server.txt", citrus.ServerVariables.Stored)
end

-- Load.
function citrus.ServerVariables.Load()
	citrus.ServerVariables.Stored = citrus.ServerVariables.TableLoad() or {}
	
	-- Call.
	citrus.Hooks.Call("OnLoadVariables")
end

-- Add.
hook.Add("Initialize", "citrus.ServerVariables.Load", citrus.ServerVariables.Load)

-- Save.
function citrus.ServerVariables.Save()
	citrus.Hooks.Call("OnSaveVariables")
	
	-- Table Save.
	citrus.ServerVariables.TableSave()
end

-- Add.
hook.Add("ShutDown", "citrus.ServerVariables.Save", citrus.ServerVariables.Save)

-- Add.
citrus.Hooks.Add("OnMinute", citrus.ServerVariables.Save)