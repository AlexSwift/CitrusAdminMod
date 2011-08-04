--[[
Name: "cl_color.lua".
Product: "Citrus (Server Management)".
--]]

local PLUGIN = citrus.Plugins.Get("Message Area")

-- TAG.
local TAG = {}

-- Name.
TAG.Name = "c"
TAG.Arguments = {"number", "number", "number"}
TAG.Seperator = ","

-- Callback.
function TAG.Callback(Text, X, Y, TextColor, TextAlpha, Arguments)
	local Width = surface.GetTextSize(Text)
	
	-- Draw.
	draw.SimpleText(Text, "citrus_MainText", X + 1, Y + 1, Color(0, 0, 0, TextAlpha), 0, 0)
	draw.SimpleText(Text, "citrus_MainText", X, Y, Color(Arguments[1], Arguments[2], Arguments[3], TextAlpha), 0, 0)
	
	-- Return Width.
	return Width
end

-- Name.
PLUGIN.Tags[TAG.Name] = TAG