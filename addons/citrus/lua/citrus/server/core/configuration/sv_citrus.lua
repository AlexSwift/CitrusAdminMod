--[[
Name: "sv_citrus.lua".
Product: "Citrus (Server Management)".
--]]

local INI = citrus.ParseINI:New("lua/citrus/server/configuration/sv_citrus.ini")

-- Results
local Results = INI:Parse()

-- For Loop.
for K, V in pairs(Results) do
	for K2, V2 in pairs(V) do
		if (K2 == "Version") then citrus.Utilities.ConsoleCommand("sv_citrus_version", V2) end
	end
end