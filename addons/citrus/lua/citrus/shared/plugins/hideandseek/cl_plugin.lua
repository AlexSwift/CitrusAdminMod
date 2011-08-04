--[[
Name: "cl_plugin.lua".
Product: "Citrus (Server Management)".
--]]

local PLUGIN = citrus.Plugin:New("Hide and Seek")

-- Overlay.
PLUGIN.Overlay = false

-- On Load.
function PLUGIN:OnLoad()
	citrus.PlayerInformation.TypeAdd("Hide and Seek")
	citrus.PlayerInformation.KeyAdd("Hide and Seek", "Seeker")
end

-- On Unload.
function PLUGIN:OnUnload()
	citrus.PlayerInformation.TypeRemove("Hide and Seek")
	citrus.PlayerInformation.KeyRemove("Hide and Seek", "Seeker")
end

-- On Draw.
function PLUGIN.OnDraw()
	local BackgroundColor = citrus.Themes.GetColor("Background")
	local CornerSize = citrus.Themes.GetSize("Corner")
	local TitleColor = citrus.Themes.GetColor("Title")
	local TextColor = citrus.Themes.GetColor("Text")
	
	-- Seeker.
	local Seeker = citrus.NetworkVariables.Get("Hide and Seek", "Seeker")
	
	-- Check Seeker.
	if (!Seeker) then return end
	
	-- Table.
	local Table = {"Help: Press F1", "Seeker: "..Seeker}
	
	-- X.
	local X, Y = 8, 8
	
	-- Announcements.
	local Announcements = citrus.Plugins.Get("Announcements")
	
	-- Check Announcements.
	if (Announcements) then
		local IsLoaded = Announcements:IsLoaded()
		
		-- Check Is Loaded.
		if (IsLoaded) then
			if (Announcements.Announcement) then
				Y = 48
			end
		end
	end
	
	-- Rounded Text Box.
	citrus.Draw.RoundedTextBox(Table, "citrus_MainText", TextColor, X, Y, CornerSize, BackgroundColor, "Hide and Seek", TitleColor)
end