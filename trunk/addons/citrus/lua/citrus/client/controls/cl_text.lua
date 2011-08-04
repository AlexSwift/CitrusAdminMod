--[[
Name: "cl_text.lua".
Product: "Citrus (Server Management)".
--]]

local CONTROL = citrus.Control:New("Text")

-- On Create.
function CONTROL:OnCreate()
	self.Text = ""
	self.Width = 0
	self.Height = 0
	self.Center = false
end

-- On Draw.
function CONTROL:OnDraw()
	local TextColor = citrus.Themes.GetColor("Text")
	
	-- Width.
	self.Width, self.Height = surface.GetTextSize(self.Text)
	
	-- Check Center.
	if (self.Center) then
		draw.SimpleText(self.Text, "citrus_MainText", self.X + (self.Width / 2), self.Y, TextColor, 1, 0)
	else
		draw.SimpleText(self.Text, "citrus_MainText", self.X, self.Y, TextColor)
	end
end

-- Create.
CONTROL:Create()