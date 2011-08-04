--[[
Name: "sv_groups.lua".
Product: "Citrus (Server Management)".
--]]

local INI = citrus.ParseINI:New("lua/citrus/server/configuration/sv_groups.ini")

-- Results
local Results = INI:Parse()

-- For Loop.
for K, V in pairs(Results) do
	local Group = citrus.Group:New(K)
	
	-- For Loop.
	for K2, V2 in pairs(V) do
		if (K2 == "Rank") then
			Group:SetSetting("Rank", V2)
		elseif (K2 == "Access") then
			Group:SetSetting("Access", V2)
		elseif (K2 == "Default") then
			citrus.Groups.Default = Group
		elseif (K2 == "User Group") then
			Group:SetSetting("User Group", V2)
		end
	end
	
	-- Create.
	Group:Create()
end