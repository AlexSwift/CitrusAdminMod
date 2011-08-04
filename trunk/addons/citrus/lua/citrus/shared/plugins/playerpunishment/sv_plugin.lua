--[[
Name: "sv_plugin.lua".
Product: "Citrus (Server Management)"
--]]

local PLUGIN = citrus.Plugin:New("Player Punishment")

-- Description.
PLUGIN.Settings.Description = "Provides useful commands for punishing players"
PLUGIN.Settings.Author = "Conna"

-- Do Player Death.
function PLUGIN.DoPlayerDeath(Player) Player:Extinguish() end

-- Hook Add.
PLUGIN:HookAdd("DoPlayerDeath", PLUGIN.DoPlayerDeath)

-- Include Directory.
citrus.Utilities.IncludeDirectory(PLUGIN.FilePath.."/commands/", "sv_", ".lua")