--[[
Name: "sv_plugin.lua".
Product: "Citrus (Server Management)".
--]]

local PLUGIN = citrus.Plugin:New("Fun and Useful")

-- Description.
PLUGIN.Settings.Description = "Pack of useful and fun commands."
PLUGIN.Settings.Author = "Polly"
PLUGIN.Settings.Gamemode = {"Sandbox", false}

-- Include Directory.
citrus.Utilities.IncludeDirectory(PLUGIN.FilePath.."/commands/", "sv_", ".lua")