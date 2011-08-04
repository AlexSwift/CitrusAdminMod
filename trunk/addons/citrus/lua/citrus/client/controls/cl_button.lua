--[[
Name: "cl_button.lua".
Product: "Citrus (Server Management)".
--]]

local CONTROL = citrus.Control:New("Button")

-- On Create.
function CONTROL:OnCreate()
	self.Text = ""
	self.Command = ""
	self.Width = 0
	self.Height = 0
end

-- On Draw.
function CONTROL:OnDraw()
	local ForegroundColor = citrus.Themes.GetColor("Foreground")
	local CornerSize = citrus.Themes.GetSize("Corner")
	local TextColor = citrus.Themes.GetColor("Text")
	
	-- Check Selected.
	if (self.Selected) then ForegroundColor = citrus.Themes.GetColor("Selected") end
	
	-- Set Font.
	surface.SetFont("citrus_MainText")
	
	-- Text Width.
	local TextWidth, TextHeight = surface.GetTextSize(self.Text)
	
	-- Check Custom Size.
	if (!self.CustomSize) then
		self.Width = TextWidth + 16
		self.Height = TextHeight + 8
		
		-- Check On Set Position.
		if (!self.OnSetPosition) then
			if (self.Menu.Width > self.Width + 16) then
				self.Width = self.Menu.Width - 16
			end
		end
	end
	
	-- Rounded Box.
	draw.RoundedBox(CornerSize, self.X, self.Y, self.Width, self.Height, self.ForegroundColor or ForegroundColor)
	draw.SimpleText(self.Text, "citrus_MainText", self.X + (self.Width / 2), self.Y + (self.Height / 2), TextColor, 1, 1)
end

-- On Mouse Pressed.
function CONTROL:OnMousePressed(Button)
	if (Button == MOUSE_LEFT) then
		if (gui.MouseX() > self.X and gui.MouseX() < (self.X + self.Width) and gui.MouseY() > self.Y and gui.MouseY() < (self.Y + self.Height)) then
			local Type = type(self.Command)
			
			-- Check Type.
			if (Type == "string") then
				LocalPlayer():ConCommand(self.Command.."\n")
			else
				self.Command(self)
			end
			
			-- Check Discontinue.
			if (self.Discontinue) then self.Menu:Remove() end
			
			-- Play Sound.
			surface.PlaySound("buttons/button24.wav")
			
			-- Return True.
			return true
		end
	end
end

-- On Think.
function CONTROL:OnThink()
	if (gui.MouseX() > self.X and gui.MouseX() < (self.X + self.Width) and gui.MouseY() > self.Y and gui.MouseY() < (self.Y + self.Height)) then
		if (!self.Selected) then surface.PlaySound("common/talk.wav") end
		
		-- Active.
		self.Selected = true
	else
		self.Selected = false
	end
end

-- Create.
CONTROL:Create()