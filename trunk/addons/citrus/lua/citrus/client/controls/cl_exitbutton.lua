--[[
Name: "cl_exitbutton.lua".
Product: "Citrus (Server Management)".
--]]

local CONTROL = citrus.Control:New("Exit Button", "Button")

-- On Create.
function CONTROL:OnCreate()
	self.Text = "X"
	self.Command = function(Control) Control.Menu:Remove() end
	self.ForegroundColor = Color(255, 50, 50, 150)
	self.CustomSize = true
	self.Width = 16
	self.Height = 16
end

-- On Set Position.
function CONTROL:OnSetPosition()
	self.X = (self.Menu.X + self.Menu.Width) - 24
	self.Y = self.Menu.Y + 8
end

-- Create.
CONTROL:Create()