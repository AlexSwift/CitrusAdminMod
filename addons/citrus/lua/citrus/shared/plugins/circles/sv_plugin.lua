--[[
Name: "sv_plugin.lua".
Product: "Citrus (Server Management)".
--]]

local PLUGIN = citrus.Plugin:New("Circles")

-- Game Support.
PLUGIN.Settings.GameSupport = false
PLUGIN.Settings.Description = "Players have team colored circles beneath them"
PLUGIN.Settings.Gamemode = {"Sandbox", true}
PLUGIN.Settings.Author = "Conna"

-- Add File.
resource.AddFile("materials/citrus/circle.vtf")
resource.AddFile("materials/citrus/circle.vmt")