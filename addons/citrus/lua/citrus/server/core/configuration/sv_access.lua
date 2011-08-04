--[[
Name: "sv_access.lua".
Product: "Citrus (Server Management)"
--]]

local INI = citrus.ParseINI:New("lua/citrus/server/configuration/sv_access.ini")

-- Results
local Results = INI:Parse()

-- For Loop.
for K, V in pairs(Results) do
	for K2, V2 in pairs(V) do citrus.Access.Add(K2, V2) end
end