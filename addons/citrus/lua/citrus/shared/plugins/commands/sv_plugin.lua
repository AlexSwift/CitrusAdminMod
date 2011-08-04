--[[
Name: "sv_plugin.lua".
Product: "Citrus (Server Management)"
--]]

local PLUGIN = citrus.Plugin:New("Commands")

-- Description.
PLUGIN.Settings.Description = "Provides basic commands for managing a server"
PLUGIN.Settings.Author = "Conna"

-- Include Directory.
citrus.Utilities.IncludeDirectory(PLUGIN.FilePath.."/commands/", "sv_", ".lua")