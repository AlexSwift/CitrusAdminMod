--[[
Name: "cl_reverse.lua".
Product: "Citrus (Server Management)".
--]]

local PLUGIN = citrus.Plugins.Get("Message Area")

-- TAG.
local TAG = {}

-- Name.
TAG.Name = "r"

-- Callback.
function TAG.Callback(Text, X, Y, TextColor, TextAlpha, Arguments)
	Text = string.reverse(Text)
	
	-- Width.
	local Width = surface.GetTextSize(Text)
	
	-- Text.
	draw.SimpleText(Text, "citrus_MainText", X + 1, Y + 1, Color(0, 0, 0, TextAlpha), 0, 0)
	draw.SimpleText(Text, "citrus_MainText", X, Y, TextColor, 0, 0)
	
	-- Return Width.
	return Width
end

-- Name.
PLUGIN.Tags[TAG.Name] = TAG