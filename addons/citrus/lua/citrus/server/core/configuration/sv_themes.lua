--[[
Name: "sv_themes.lua".
Product: "Citrus (Server Management)".
--]]

local Files = file.Find("../lua/citrus/server/themes/*.ini")

-- For Loop.
for K, V in pairs(Files) do
	local INI = citrus.ParseINI:New("lua/citrus/server/themes/"..V)
	
	-- Results
	local Results = INI:Parse()
	local Table = {}
	
	-- Name.
	Table.Name = Results.Settings.Name
	
	-- Settings.
	Table.Settings = Results.Settings
	Table.Settings.Name = nil
	
	-- Colors.
	Table.Colors = {}
	Table.Sizes = Results.Sizes
	
	-- For Loop.
	for K2, V2 in pairs(Results.Colors) do
		Table.Colors[K2] = citrus.Utilities.GetColor(V2)
	end
	
	-- Add.
	citrus.Themes.Add(Table.Name, Table)
end