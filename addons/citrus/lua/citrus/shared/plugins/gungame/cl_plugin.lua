--[[
Name: "cl_plugin.lua".
Product: "Citrus (Server Management)".
--]]

local PLUGIN = citrus.Plugin:New("GunGame")

-- On Load.
function PLUGIN:OnLoad()
	citrus.PlayerInformation.TypeAdd("GunGame")
	citrus.PlayerInformation.KeyAdd("GunGame", "Level")
end

-- On Unload.
function PLUGIN:OnUnload()
	citrus.PlayerInformation.TypeAdd("GunGame")
	citrus.PlayerInformation.KeyRemove("GunGame", "Level")
end

-- On Draw.
function PLUGIN.OnDraw()
	local BackgroundColor = citrus.Themes.GetColor("Background")
	local CornerSize = citrus.Themes.GetSize("Corner")
	local TitleColor = citrus.Themes.GetColor("Title")
	local TextColor = citrus.Themes.GetColor("Text")
	
	-- Level.
	local Level = citrus.PlayerInformation.Get(LocalPlayer(), "GunGame", "Level")
	
	-- Check Level.
	if (Level) then
		local Table = {"Help: Press F1", "Level: "..Level, "Leader: "..citrus.NetworkVariables.Get("GunGame", "Leader")}
		
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
		citrus.Draw.RoundedTextBox(Table, "citrus_MainText", TextColor, X, Y, CornerSize, BackgroundColor, "GunGame", TitleColor)
	end
end