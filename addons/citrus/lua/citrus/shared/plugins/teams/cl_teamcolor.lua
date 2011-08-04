--[[
Name: "cl_teamcolor.lua".
Product: "Citrus (Server Management)".
--]]

local CONTROL = citrus.Control:New("Team Color")

-- On Create.
function CONTROL:OnCreate()
	self.Colors = {{"Red", "r"}, {"Green", "g"}, {"Blue", "b"}, {"Alpha", "a"}}
	self.Text = "Team Color"
end

-- On Draw.
function CONTROL:OnDraw()
	local CornerSize = citrus.Themes.GetSize("Corner")
	local TextColor = citrus.Themes.GetColor("Text")
	local PreviewColor = Color(255, 255, 255, 255)
	
	-- Text Width.
	local TextWidth, TextHeight = surface.GetTextSize(self.Text)
	
	-- Width.
	self.Width = TextWidth + 16
	self.Height = TextHeight + 8
	
	-- Check On Set Position.
	if (!self.OnSetPosition) then
		if (self.Menu.Width > self.Width + 16) then
			self.Width = self.Menu.Width - 16
		end
	end
	
	-- Controls.
	local Controls = self.Menu:GetControls()
	
	-- For Loop.
	for K, V in pairs(self.Colors) do
		local Long = V[1]
		local Short = V[2]
		
		-- Check Long.
		if (self[Long]) then
			for K, V in pairs(Controls) do
				if (V.Index == self[Long]) then
					PreviewColor[Short] = V.Value or 255
				end
			end
		end
	end
	
	-- Rounded Box.
	draw.RoundedBox(CornerSize, self.X, self.Y, self.Width, self.Height, PreviewColor)
	draw.SimpleText(self.Text, "citrus_MainText", self.X + (self.Width / 2), self.Y + (self.Height / 2), TextColor, 1, 1)
end

-- Create.
CONTROL:Create()