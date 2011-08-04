--[[
Name: "sv_plugin.lua".
Product: "Citrus (Server Management)"
--]]

require("http")

-- PLUGIN.
local PLUGIN = citrus.Plugin:New("Announcements")

-- Description.
PLUGIN.Settings.Description = "Citrus announcements are displayed to players"
PLUGIN.Settings.Author = "Conna"

-- Last Announcement.
PLUGIN.LastAnnouncement = ""

-- Get Announcement.
function PLUGIN.GetAnnouncement(Contents)
	local Exploded = string.Explode("\n", Contents)
	
	-- Check Exploded.
	if (#Exploded == 0) then Exploded = {"Error."} end
	
	-- Announcement.
	local Announcement = citrus.Utilities.GetRandomValue(Exploded)
	
	-- Announcement.
	Announcement = string.gsub(Announcement, "%#(.-)%#", function(String) return math.Round(GetConVarNumber(String)) end)
	Announcement = string.gsub(Announcement, "%%(.-)%%", function(String) return GetConVarString(String) end)
	Announcement = string.gsub(Announcement, "%{(.-)}%", function(String)
		return tostring(citrus.Utilities.GetVariable(String))
	end)
	
	-- Check Last Announcement.
	if (PLUGIN.LastAnnouncement == Announcement) then
		return PLUGIN.GetAnnouncement(Contents)
	else
		PLUGIN.LastAnnouncement = Announcement
		
		-- Return Announcement.
		return Announcement
	end
end

-- Timer Create.
PLUGIN:TimerCreate("Announce", 60, 0, function()
	http.Get("http://kudomiku.com/citrus/announcements.txt", "", function(Contents, Size)
		if (Contents and Contents != "") then
			local Announcement = PLUGIN.GetAnnouncement(Contents)
			
			-- Usermessage Call.
			PLUGIN:UsermessageCall("Announcement", false, function() umsg.String(Announcement) end)
		end
	end)
end)