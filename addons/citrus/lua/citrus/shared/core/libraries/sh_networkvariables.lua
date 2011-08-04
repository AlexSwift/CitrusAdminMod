--[[
Name: "sh_globalvariable.lua".
Product: "Citrus (Server Management)".
--]]

citrus.NetworkVariables = {}

-- Set.
function citrus.NetworkVariables.Set(Type, Key, Value)
	Key = util.CRC("citrus.NetworkVariables['"..Type.."']['"..Key.."']")
	
	-- Set Global Var.
	SetGlobalVar(Key, Value)
end

-- Get.
function citrus.NetworkVariables.Get(Type, Key)
	Key = util.CRC("citrus.NetworkVariables['"..Type.."']['"..Key.."']")
	
	-- Return Get Global Var.
	return GetGlobalVar(Key)
end