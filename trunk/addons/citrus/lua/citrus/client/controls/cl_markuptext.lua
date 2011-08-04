--[[
Name: "cl_markuptext.lua".
Product: "Citrus (Server Management)".
--]]

local CONTROL = citrus.Control:New("Markup Text")

-- On Create.
function CONTROL:OnCreate()
	self.Text = ""
	self.Width = 0
	self.Height = 0
end

-- On Draw.
function CONTROL:OnDraw()
	local Text = markup.Parse(self.Text)
	
	-- Width.
	self.Width = Text:GetWidth()
	self.Height = Text:GetHeight()
	
	-- Draw.
	Text:Draw(self.X, self.Y)
end

-- Create.
CONTROL:Create()