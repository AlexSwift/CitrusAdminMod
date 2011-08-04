--[[
Name: "cl_plugin.lua".
Product: "Citrus (Server Management)".
--]]

local PLUGIN = citrus.Plugin:New("Information Bar")

-- Hostname.
PLUGIN.Hostname = "Garry's Mod"

-- Usermessage Hook.
PLUGIN:UsermessageHook("Hostname", function(Message)
	PLUGIN.Hostname = Message:ReadString()
end)

-- On Draw.
function PLUGIN.OnDraw()
	local BackgroundColor = citrus.Themes.GetColor("Background")
	local CornerSize = citrus.Themes.GetSize("Corner")
	local TitleColor = citrus.Themes.GetColor("Title")
	local TextColor = citrus.Themes.GetColor("Text")
	local String = "<color="..TitleColor.r..","..TitleColor.g..","..TitleColor.b..","..TitleColor.a..">"
	
	-- Hostname.
	local Hostname = citrus.NetworkVariables.Get("Information Bar", "Hostname") or PLUGIN.Hostname
	local Text = markup.Parse("<font=citrus_LargeText>"..String..Hostname.."</color></font>")
	
	-- Width.
	local Width, Height = Text:GetWidth(), 80
	local TextWidth = surface.GetTextSize("F4: Information")
	
	-- Set Font.
	surface.SetFont("citrus_MainText")
	
	-- Check Text Width.
	if (TextWidth > Width) then Width = TextWidth end
	
	-- Width.
	Width = Width + 64
	
	-- X.
	local X = (ScrW() / 2) - (Width / 2)
	local Y = -(Height / 2)
	
	-- Announcements.
	local Announcements = citrus.Plugins.Get("Announcements")
	
	-- Check Announcements.
	if (Announcements) then
		local IsLoaded = Announcements:IsLoaded()
		
		-- Check Is Loaded.
		if (IsLoaded) then
			if (Announcements.Announcement) then
				if (Announcements.X + Announcements.Width > X) then
					X = (Announcements.X + Announcements.Width) + 8
				end
			end
		end
	end
	
	-- Rounded Box.
	draw.RoundedBox(CornerSize, X, Y, Width, Height, BackgroundColor)
	
	-- Draw.
	Text:Draw(X + (Width / 2), 2, 1, 0)
	
	-- Draw Text.
	draw.SimpleText("F4: Information", "citrus_MainText", X + (Width / 2), 20, TextColor, 1, 0)
end