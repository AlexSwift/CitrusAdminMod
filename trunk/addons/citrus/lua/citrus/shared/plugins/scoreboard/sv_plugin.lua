--[[
Name: "sv_plugin.lua".
Product: "Citrus (Server Management)".
--]]

local PLUGIN = citrus.Plugin:New("Scoreboard")

-- Description.
PLUGIN.Settings.Description = "sui_scoreboard edited for Citrus plugin."
PLUGIN.Settings.Author = "Polly"
PLUGIN.Settings.Gamemode = {"Sandbox", true}

-- Include Directory.
citrus.Utilities.IncludeDirectory(PLUGIN.FilePath.."/commands/", "sv_", ".lua")
citrus.Utilities.IncludeDirectory(PLUGIN.FilePath.."/scoreboard/", "sv_", ".lua")
citrus.Utilities.AddCSLuaDirectory(PLUGIN.FilePath.."/scoreboard/", "cl_", ".lua")