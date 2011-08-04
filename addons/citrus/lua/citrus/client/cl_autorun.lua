--[[
Name: "cl_autorun.lua".
Product: "Citrus (Server Management)".
--]]

citrus = {}

-- Include.
include("citrus/shared/sh_autorun.lua")
include("citrus/client/core/cl_core.lua")

-- Include Directory.
citrus.Utilities.IncludeDirectory("citrus/client/core/libraries/", "cl_", ".lua")

-- Include.
include("citrus/shared/core/sh_plugins.lua")

-- Add.
citrus.PlayerInformation.TypeAdd("Public")
citrus.PlayerInformation.KeyAdd("Public", "Group")
citrus.PlayerInformation.KeyAdd("Public", "Time Played")
citrus.PlayerInformation.KeyAdd("Public", "Group Access")
citrus.PlayerInformation.KeyAdd("Public", "Custom Access")

-- BF_READ.
local BF_READ = _R["bf_read"]

-- Original.
local Original = BF_READ.ReadString

-- Read String.
function BF_READ:ReadString()
	local String = Original(self)
	
	-- Check String.
	if (String == "#Player#") then String = "Player" end
	
	-- Return String.
	return String
end