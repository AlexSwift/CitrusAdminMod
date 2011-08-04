--[[
Name: "cl_plugin.lua".
Product: "Citrus (Server Management)"
--]]

local PLUGIN = citrus.Plugin:New("Points")

-- On Load.
function PLUGIN:OnLoad() citrus.PlayerInformation.KeyAdd("Public", "Points") end

-- On Unload.
function PLUGIN:OnUnload() citrus.PlayerInformation.KeyRemove("Public", "Points") end