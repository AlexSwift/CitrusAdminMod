--[[
Name: "sv_plugin.lua".
Product: "Citrus (Server Management)".
--]]

local PLUGIN = citrus.Plugin:New("Titles")

-- Description.
PLUGIN.Settings.Description = "Players can set their own titles."
PLUGIN.Settings.Author = "Polly"
PLUGIN.Settings.Gamemode = {"Sandbox", false}

-- Include Directory.
citrus.Utilities.IncludeDirectory(PLUGIN.FilePath.."/commands/", "sv_", ".lua")