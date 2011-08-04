--[[
Name: "cl_slider.lua".
Product: "Citrus (Server Management)".
--]]

local CONTROL = citrus.Control:New("Slider")

-- On Create.
function CONTROL:OnCreate()
	self.Text = ""
	self.Command = ""
	self.Minimum = 0
	self.Maximum = 1
	self.Value = 0
	self.BarWidth = 0
	self.Width = 0
	self.Height = 0
	self.ButtonManual = {X = 0, Y = 0, Width = 0, Height = 0, Active = false}
end

-- Get Handle Position.
function CONTROL:GetHandlePosition()
	if (self.Dragging) then
		return {X = math.Clamp(gui.MouseX() + self.Dragging, self:GetX(), self:GetX() + self.BarWidth), Y = self.Y + 10}
	else
		return {X = math.min(self:GetX() + ((self.BarWidth / self.Maximum) * self.Value), self:GetX() + self.BarWidth), Y = self.Y + 10}
	end
end

-- Get X.
function CONTROL:GetX()
	return self.ButtonManual.X + self.ButtonManual.Width + 24
end

-- On Draw.
function CONTROL:OnDraw()
	local BackgroundColor = citrus.Themes.GetColor("Background")
	local ForegroundColor = citrus.Themes.GetColor("Foreground")
	local CornerSize = citrus.Themes.GetSize("Corner")
	local TextColor = citrus.Themes.GetColor("Text")
	
	-- Bar Width.
	self.BarWidth = math.Clamp(self.Maximum, 0, 250)
	self.Value = tonumber(self.Value) or self.Minimum
	
	-- Handle Color.
	local HandleColor = TextColor
	
	-- Check Dragging.
	if (self.Dragging) then HandleColor = citrus.Themes.GetColor("Selected") end
	
	-- Set Font.
	surface.SetFont("citrus_MainText")
	
	-- Width.
	local Width = self.BarWidth + 8
	local Text = self.Text
	
	-- Minimum Text Width.
	local MinimumTextWidth = surface.GetTextSize(tostring(self.Minimum))
	local MaximumTextWidth = surface.GetTextSize(tostring(self.Maximum))
	
	-- Width.
	Width = Width + MinimumTextWidth + MaximumTextWidth + 16
	
	-- Check Dragging.
	if (self.Dragging or self.ShowValue) then Text = tostring(self.Value) end
	
	-- Button Manual.
	self.ButtonManual.X = self.X
	self.ButtonManual.Y = self.Y + 9
	self.ButtonManual.Width = 48
	self.ButtonManual.Height = 16
	
	-- Width.
	self.Width = math.max(Width, surface.GetTextSize(Text) + 16)
	self.Height = 28
	
	-- Width.
	self.Width = self.Width + self.ButtonManual.Width + 8
	
	-- Handle Position.
	local HandlePosition = self:GetHandlePosition()
	
	-- Rounded Box.
	draw.RoundedBox(CornerSize, self:GetX(), self.Y + 16, self.BarWidth + 8, 4, ForegroundColor)
	draw.RoundedBox(CornerSize, HandlePosition.X, HandlePosition.Y, 8, 16, HandleColor)
	draw.SimpleText(Text, "citrus_MainText", self:GetX() + (self.BarWidth / 2), self.Y + 4, TextColor, 1, 1)
	draw.SimpleText(self.Minimum, "citrus_MainText", self:GetX() - MinimumTextWidth - 8, self.Y + 17, TextColor, 0, 1)
	draw.SimpleText(self.Maximum, "citrus_MainText", self:GetX() + self.BarWidth + 16, self.Y + 17, TextColor, 0, 1)
	
	-- Check Selected.
	if (self.ButtonManual.Selected) then ForegroundColor = citrus.Themes.GetColor("Selected") end
	
	-- Rounded Box.
	draw.RoundedBox(CornerSize, self.ButtonManual.X, self.ButtonManual.Y, self.ButtonManual.Width, self.ButtonManual.Height, ForegroundColor)
	draw.SimpleText("Manual", "citrus_MainText", self.ButtonManual.X + (self.ButtonManual.Width / 2), self.ButtonManual.Y + (self.ButtonManual.Height / 2), TextColor, 1, 1)
end

-- On Think.
function CONTROL:OnThink()
	local HandlePosition = self:GetHandlePosition()
	
	-- Check Dragging.
	if (self.Dragging) then
		local X = gui.MouseX() + self.Dragging
		
		-- Value.
		self.Value = math.Round((self.Maximum / self.BarWidth) * (HandlePosition.X - (self:GetX())))
	elseif (gui.MouseX() > HandlePosition.X and gui.MouseX() < (HandlePosition.X + 8) and gui.MouseY() > HandlePosition.Y and gui.MouseY() < (HandlePosition.Y + 16)) then
		self.ShowValue = true
	elseif (gui.MouseX() > self.ButtonManual.X and gui.MouseX() < self.ButtonManual.X + self.ButtonManual.Width and gui.MouseY() > self.ButtonManual.Y and gui.MouseY() < self.ButtonManual.Y + self.ButtonManual.Height) then
		if (!self.ButtonManual.Selected) then surface.PlaySound("common/talk.wav") end
		
		-- Active.
		self.ButtonManual.Selected = true
		
		-- Return True.
		return true
	else
		self.ButtonManual.Selected = false
		self.ShowValue = false
	end
end

-- On Mouse Pressed.
function CONTROL:OnMousePressed(Button)
	if (Button == MOUSE_LEFT) then
		local HandlePosition = self:GetHandlePosition()
		
		-- Mouse X.
		if (gui.MouseX() > HandlePosition.X and gui.MouseX() < (HandlePosition.X + 8) and gui.MouseY() > HandlePosition.Y and gui.MouseY() < (HandlePosition.Y + 16)) then
			self.Dragging = HandlePosition.X - gui.MouseX()
			
			-- Play Sound.
			surface.PlaySound("buttons/button24.wav")
			
			-- Return True.
			return true
		end
	end
end

-- Run Command.
function CONTROL:RunCommand()
	if (type(self.Command) == "string") then
		LocalPlayer():ConCommand(self.Command.." "..self.Value.."\n")
	else
		self.Command(self)
	end
	
	-- Dragging.
	self.Dragging = false
	
	-- Play Sound.
	surface.PlaySound("buttons/button24.wav")
	
	-- Check Discontinue.
	if (self.Discontinue) then self.Menu:Remove() end
end

-- On Mouse Released.
function CONTROL:OnMouseReleased(Button)
	if (Button == MOUSE_LEFT) then
		if (self.Dragging) then
			self:RunCommand()
		elseif (gui.MouseX() > self.ButtonManual.X and gui.MouseX() < self.ButtonManual.X + self.ButtonManual.Width and gui.MouseY() > self.ButtonManual.Y and gui.MouseY() < self.ButtonManual.Y + self.ButtonManual.Height) then
			local Frame, TextEntry = citrus.Menus.TextEntry(self.Text, function(Text)
				local Value = tonumber(Text)
				
				-- Check Value.
				if (Value) then
					self.Value = Value
					
					-- Run Command.
					self:RunCommand()
				end
			end, true)
		end
	end
end

-- Create.
CONTROL:Create()