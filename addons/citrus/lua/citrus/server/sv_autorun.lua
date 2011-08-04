--[[
Name: "sv_autorun.lua".
Product: "Citrus (Server Management)".
--]]

CreateConVar("sv_citrus_version", "1.0", {FCVAR_NOTIFY, FCVAR_ARCHIVE})
CreateConVar("sv_citrus_enabled", "1.0", {FCVAR_NOTIFY, FCVAR_ARCHIVE})

-- Check Get ConVar Number.
if (GetConVarNumber("sv_citrus_enabled") == 1) then
	citrus = {}

	-- Include.
	include("citrus/shared/sh_autorun.lua")

	-- Include Directory.
	citrus.Utilities.IncludeDirectory("citrus/server/core/libraries/", "sv_", ".lua")
	citrus.Utilities.IncludeDirectory("citrus/server/core/configuration/", "sv_", ".lua")

	-- Include.
	include("citrus/shared/core/sh_plugins.lua")

	-- Add CS Lua File.
	AddCSLuaFile("autorun/client/cl_citrus.lua")

	-- Add CS Lua Directory.
	citrus.Utilities.AddCSLuaDirectory("citrus/", "cl_", true)
	citrus.Utilities.AddCSLuaDirectory("citrus/", "sh_", true)
	
	-- Include Directory.
	citrus.Utilities.IncludeDirectory("citrus/server/commands/", "sv_", ".lua")

	-- Original.
	local Original = umsg.String

	-- String.
	function umsg.String(String)
		if (String == "Player") then String = "#Player#" end
		
		-- Original.
		Original(String)
	end
end