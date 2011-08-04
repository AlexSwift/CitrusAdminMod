--[[
Name: "cl_blink.lua".
Product: "Citrus (Server Management)".
--]]

local PLUGIN = citrus.Plugins.Get("Message Area")

-- TAG.
local TAG = {}

-- Name.
TAG.Name = "b"

-- Callback.
function TAG.Callback(Text, X, Y, TextColor, TextAlpha, Arguments)
	local Width = surface.GetTextSize(Text)
	
	-- Check sin.
	if ((math.sin(CurTime() * 5) * 10) > 0) then
		draw.SimpleText(Text, "citrus_MainText", X + 1, Y + 1, Color(0, 0, 0, TextAlpha), 0, 0)
		draw.SimpleText(Text, "citrus_MainText", X, Y, TextColor, 0, 0)
	end
	
	-- Return Width.
	return Width
end

-- Name.
PLUGIN.Tags[TAG.Name] = TAG