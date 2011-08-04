--[[
Name: "cl_checkbox.lua".
Product: "Citrus (Server Management)".
--]]

local CONTROL = citrus.Control:New("Check Box")

-- On Create.
function CONTROL:OnCreate()
	self.Text = ""
	self.Command = ""
	self.Value = false
	self.Confirmation = false
	self.ButtonConfirm = {X = 0, Y = 0, Width = 0, Height = 0, Active = false}
	self.CheckBox = {X = 0, Y = 0, Width = 0, Height = 0}
	self.Width = 0
	self.Height = 0
end

-- On Draw.
function CONTROL:OnDraw()
	local ForegroundColor = citrus.Themes.GetColor("Foreground")
	local CornerSize = citrus.Themes.GetSize("Corner")
	local TextColor = citrus.Themes.GetColor("Text")
	
	-- Check Value.
	if (self.Value) then ForegroundColor = citrus.Themes.GetColor("Selected") end
	
	-- Set Font.
	surface.SetFont("citrus_MainText")
	
	-- Text Width.
	local TextWidth = surface.GetTextSize(self.Text)
	
	-- Width.
	self.Width = TextWidth + 80
	self.Height = 16
	
	-- X.
	self.CheckBox.X = self.X
	self.CheckBox.Y = self.Y
	self.CheckBox.Width = 16
	self.CheckBox.Height = 16
	
	-- Rounded Box.
	draw.RoundedBox(CornerSize, self.CheckBox.X, self.CheckBox.Y, self.CheckBox.Width, self.CheckBox.Height, ForegroundColor)
	
	-- Check Active.
	if (self.ButtonConfirm.Selected) then ForegroundColor = citrus.Themes.GetColor("Selected") end
	
	-- Button Save.
	self.ButtonConfirm.X = (self.CheckBox.X + self.CheckBox.Width) + 8
	self.ButtonConfirm.Y = self.Y
	self.ButtonConfirm.Width = 56
	self.ButtonConfirm.Height = 16
	
	-- Check Save Button.
	if (self.Confirmation) then
		draw.RoundedBox(CornerSize, self.ButtonConfirm.X, self.ButtonConfirm.Y, self.ButtonConfirm.Width, self.ButtonConfirm.Height, ForegroundColor)
		draw.SimpleText("Confirm", "citrus_MainText", self.ButtonConfirm.X + (self.ButtonConfirm.Width / 2), self.ButtonConfirm.Y + (self.ButtonConfirm.Height / 2), TextColor, 1, 1)
		draw.SimpleText(self.Text, "citrus_MainText", self.ButtonConfirm.X + self.ButtonConfirm.Width + 8, self.Y + 8, TextColor, 0, 1)
		
		-- Width.
		self.Width = self.Width + 8
	else
		self.Width = self.Width - self.ButtonConfirm.Width
		
		-- Draw.
		draw.SimpleText(self.Text, "citrus_MainText", self.ButtonConfirm.X, self.Y + 8, TextColor, 0, 1)
	end
	
	-- Check Value.
	if (self.Value) then
		draw.SimpleText("X", "citrus_MainText", self.CheckBox.X + 8, self.CheckBox.Y + 8, TextColor, 1, 1)
	end
end

-- On Think.
function CONTROL:OnThink()
	if (self.Confirmation) then
		if (gui.MouseX() > self.ButtonConfirm.X and gui.MouseX() < self.ButtonConfirm.X + self.ButtonConfirm.Width and gui.MouseY() > self.ButtonConfirm.Y and gui.MouseY() < self.ButtonConfirm.Y + self.ButtonConfirm.Height) then
			if (!self.ButtonConfirm.Selected) then surface.PlaySound("common/talk.wav") end
			
			-- Active.
			self.ButtonConfirm.Selected = true
			
			-- Return True.
			return true
		else
			self.ButtonConfirm.Selected = false
		end
	end
end

-- Run Command.
function CONTROL:RunCommand()
	if (type(self.Command) == "string") then
		if (ConVarExists(self.Command)) then
			local Value = 0
			
			-- Check Value.
			if (self.Value) then Value = 1 end
			
			-- Con Command.
			LocalPlayer():ConCommand(self.Command.." "..tostring(self.Value).."\n")
		else
			LocalPlayer():ConCommand(self.Command.." "..tostring(self.Value).."\n")
		end
	else
		self.Command(self, self.Value)
	end
	
	-- Check Discontinue.
	if (self.Discontinue) then self.Menu:Remove() end
end

-- On Mouse Pressed.
function CONTROL:OnMousePressed(Button)
	if (Button == MOUSE_LEFT) then
		if (gui.MouseX() > self.CheckBox.X and gui.MouseX() < self.CheckBox.X + self.CheckBox.Width and gui.MouseY() > self.CheckBox.Y and gui.MouseY() < self.CheckBox.Y + self.CheckBox.Height) then
			self.Value = !self.Value
			
			-- Check Confirmation.
			if (!self.Confirmation) then self:RunCommand() end
			
			-- Play Sound.
			surface.PlaySound("buttons/button24.wav")
			
			-- Return True.
			return true
		elseif (self.Confirmation and gui.MouseX() > self.ButtonConfirm.X and gui.MouseX() < self.ButtonConfirm.X + self.ButtonConfirm.Width and gui.MouseY() > self.ButtonConfirm.Y and gui.MouseY() < self.ButtonConfirm.Y + self.ButtonConfirm.Height) then
			self:RunCommand()
			
			-- Play Sound.
			surface.PlaySound("buttons/button24.wav")
			
			-- Return True.
			return true
		end
	end
end

-- Create.
CONTROL:Create()