--[[
Name: "cl_plugin.lua".
Product: "Citrus (Server Management)".
--]]

local PLUGIN = citrus.Plugin:New("Tag")

-- On Draw.
function PLUGIN.OnDraw()
	local BackgroundColor = citrus.Themes.GetColor("Background")
	local CornerSize = citrus.Themes.GetSize("Corner")
	local TitleColor = citrus.Themes.GetColor("Title")
	local TextColor = citrus.Themes.GetColor("Text")
	
	-- X.
	local X, Y = 8, 8
	
	-- Announcements.
	local Announcements = citrus.Plugins.Get("Announcements")
	
	-- Check Announcements.
	if (Announcements) then
		local IsLoaded = Announcements:IsLoaded()
		
		-- Check Is Loaded.
		if (IsLoaded) then
			if (Announcements.Announcement) then Y = 48 end
		end
	end
	
	-- Tagged.
	local Tagged = citrus.NetworkVariables.Get("Tag", "Tagged")
	
	-- Check Tagged.
	if (Tagged) then
		citrus.Draw.RoundedTextBox({"Help: Press F1", "Tagged: "..Tagged}, "citrus_MainText", TextColor, X, Y, CornerSize, BackgroundColor, "Tag", TitleColor)
	end
end