--[[
Name: "sv_plugin.lua".
Product: "Citrus (Server Management)"
--]]

local PLUGIN = citrus.Plugin:New("Player Management")

-- Description.
PLUGIN.Settings.Description = "Provides useful commands for managing players"
PLUGIN.Settings.Author = "Conna"

-- Include Directory.
citrus.Utilities.IncludeDirectory(PLUGIN.FilePath.."/commands/", "sv_", ".lua")