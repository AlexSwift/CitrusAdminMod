--[[
Name: "cl_plugin.lua".
Product: "Citrus (Server Management)".
--]]

local PLUGIN = citrus.Plugin:New("Announcements")

-- Announcement.
PLUGIN.Announcement = false

-- On Draw.
function PLUGIN.OnDraw()
	if (PLUGIN.Announcement) then
		local BackgroundColor = citrus.Themes.GetColor("Background")
		local CornerSize = citrus.Themes.GetSize("Corner")
		local TextColor = citrus.Themes.GetColor("Text")
		
		-- Time.
		local Time = RealTime()
		local Alpha = 0
		
		-- Check Time (Thanks Mahalis).
		if (Time < PLUGIN.StartTime + PLUGIN.FadeInTime) then
			Alpha = math.sin(0.5 * (Time - PLUGIN.StartTime) * math.pi)
		elseif (Time < PLUGIN.StartTime + PLUGIN.FadeInTime + PLUGIN.PauseTime) then
			Alpha = 1
		else
			Alpha = math.cos(0.5 * (Time - (PLUGIN.StartTime + PLUGIN.FadeInTime + PLUGIN.PauseTime)) * math.pi)
			
			-- Check floor,
			if (math.floor(Alpha) == 0) then
				PLUGIN.Announcement = false
				
				-- Return.
				return
			end
		end
		
		-- Alpha.
		Alpha = math.Clamp(Alpha * 255, 0, 255)
		
		-- Background Color.
		BackgroundColor.a = math.Clamp(Alpha, 0, BackgroundColor.a)
		TextColor.a = math.Clamp(Alpha, 0, TextColor.a)
		
		-- Text.
		local Text = markup.Parse(PLUGIN.Announcement)
		
		-- Width.
		PLUGIN.Width, PLUGIN.Height = Text:GetWidth() + 16, Text:GetHeight() + 16
		
		-- Rounded Box.
		draw.RoundedBox(CornerSize, PLUGIN.X, PLUGIN.Y, PLUGIN.Width, PLUGIN.Height, BackgroundColor)
		
		-- Draw.
		Text:Draw(PLUGIN.X + 8, PLUGIN.Y + 8, 0, 0, TextColor.a)
	end
end

-- Usermessage Hook.
PLUGIN:UsermessageHook("Announcement", function(Message)
	local Text = Message:ReadString()
	
	-- Announcement.
	PLUGIN.Announcement = "<font=citrus_MainText>"..Text.."</font>"
	PLUGIN.StartTime = RealTime()
	PLUGIN.FadeInTime = 1
	PLUGIN.PauseTime = 10
	PLUGIN.X = 8
	PLUGIN.Y = 8
	PLUGIN.Width = 0
	PLUGIN.Height = 0
end)