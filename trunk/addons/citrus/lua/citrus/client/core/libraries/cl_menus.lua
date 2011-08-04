--[[
Name: "cl_menus.lua".
Product: "Citrus (Server Management)".
--]]

citrus.Menu = {}
citrus.Menus = {}
citrus.Menus.Stored = {}
citrus.Menus.Controls = {}

-- X.
citrus.Menus.X, citrus.Menus.Y = 8, 8

-- NEW_MENU.
local NEW_MENU = false
local NEW_CONTROL = false

-- HUD Draw Score Board.
function citrus.Menus.HUDDrawScoreBoard()
	if (#citrus.Menus.Stored > 0) then
		local BackgroundColor = citrus.Themes.GetColor("Background")
		local CornerSize = citrus.Themes.GetSize("Corner")
		local TextColor = citrus.Themes.GetColor("Text")
		
		-- Rounded Text Box.
		citrus.Draw.RoundedTextBox({"Left Click: Close All", "Right Click: Minimise All"}, "citrus_MainText", TextColor, ScrW() / 2, ScrH() / 2, CornerSize, BackgroundColor, false, false, true, true)
		
		-- For Loop.
		for K, V in pairs(citrus.Menus.Stored) do V:Draw() end
	end
end

-- Think.
function citrus.Menus.Think()
	if (#citrus.Menus.Stored > 0) then
		local MouseX = gui.MouseX()
		local MouseY = gui.MouseY()
		
		-- For Loop.
		for K, V in pairs(citrus.Menus.Stored) do
			local CursorVisible = vgui.CursorVisible()
			
			-- Check Cursor Visible.
			if (!CursorVisible) then gui.EnableScreenClicker(true) end
			
			-- Check Dragging.
			if (V.Dragging) then
				citrus.Menus.X, citrus.Menus.Y = gui.MouseX() + V.Dragging.X, gui.MouseY() + V.Dragging.Y
				
				-- X.
				V.X = citrus.Menus.X
				V.Y = citrus.Menus.Y
				
				-- Return False.
				return false
			end
			
			-- Check Mouse X.
			if (citrus.Menus.IsMenuColliding(V, MouseX, MouseY)) then
				if (!citrus.Menus.IsMenuBlocked(K, MouseX, MouseY)) then
					for K2, V2 in pairs(V.Pages[V.Page]) do
						if (V2:OnThink()) then return end
					end
				end
			end
		end
	end
end

-- Mouse Pressed.
function citrus.Menus.MousePressed(Button)
	if (#citrus.Menus.Stored > 0) then
		local MouseX = gui.MouseX()
		local MouseY = gui.MouseY()
		
		-- CloseAll.
		local CloseAll = true
		
		-- For Loop.
		for K, V in pairs(citrus.Menus.Stored) do
			if (citrus.Menus.IsMenuColliding(V, MouseX, MouseY)) then
				CloseAll = false
				
				-- Check Is Menu Blocked.
				if (!citrus.Menus.IsMenuBlocked(K, MouseX, MouseY)) then
					for K2, V2 in pairs(V.Pages[V.Page]) do
						if (V2:OnMousePressed(Button)) then return end
					end
					
					-- Check Mouse X.
					if (MouseX > V.X and MouseX < (V.X + V.Width)) and (MouseY > V.Y) and (MouseY < (V.Y + 24)) then
						V.Dragging = {X = V.X - MouseX, Y = V.Y - MouseY}
						
						-- Play Sound.
						surface.PlaySound("buttons/button24.wav")
						
						-- Return.
						return
					end
				end
			end
		end
		
		-- Check Close All.
		if (CloseAll) then
			if (Button == MOUSE_LEFT) then
				repeat
					for K, V in pairs(citrus.Menus.Stored) do V:Remove() end
				until (table.Count(citrus.Menus.Stored) == 0)
			elseif (Button == MOUSE_RIGHT) then
				citrus.Menus.SetMinimised()
			end
		end
	end
end

-- Mouse Released.
function citrus.Menus.MouseReleased(Button)
	if (#citrus.Menus.Stored > 0) then
		local MouseX = gui.MouseX()
		local MouseY = gui.MouseY()
		
		-- For Loop.
		for K, V in pairs(citrus.Menus.Stored) do
			if (citrus.Menus.IsMenuColliding(V, MouseX, MouseY)) then
				if (!citrus.Menus.IsMenuBlocked(K, MouseX, MouseY)) then
					for K2, V2 in pairs(V.Pages[V.Page]) do
						if (V2:OnMouseReleased(Button)) then return end
					end
				end
			end
			
			-- Dragging.
			V.Dragging = false
		end
	end
end

-- Hook.
usermessage.Hook("citrus.Controls.New", function(Message)
	NEW_CONTROL = {}
end)

-- Hook.
usermessage.Hook("citrus.Controls.KeyValueReceive", function(Message)
	citrus.Utilities.KeyValueReceive(Message, NEW_CONTROL)
end)

-- Hook.
usermessage.Hook("citrus.Controls.Add", function(Message)
	NEW_MENU:ControlAdd(NEW_CONTROL.Name, NEW_CONTROL)
end)

-- Hook.
usermessage.Hook("citrus.Menus.New", function(Message)
	local Title = Message:ReadString()
	local Icon = Message:ReadString()
	local Update = Message:ReadString()
	local Reference = Message:ReadString()
	
	-- Check Update.
	if (Update == "") then Update = false end
	if (Reference == "") then Reference = false end
	
	-- NEW_MENU.
	NEW_MENU = citrus.Menu:New()
	
	-- Set Title.
	NEW_MENU:SetTitle(Title)
	NEW_MENU:SetIcon(Icon)
	
	-- Update.
	NEW_MENU.Settings.Update = Update
	NEW_MENU.Settings.Reference = Reference
end)

-- Hook.
usermessage.Hook("citrus.Menus.TextEntry", function(Message)
	local Title = Message:ReadString()
	local Command = Message:ReadString()
	local Discontinue = Message:ReadBool()
	
	-- Text Entry.
	citrus.Menus.TextEntry(Title, Command, Discontinue)
end)

-- Hook.
usermessage.Hook("citrus.Menus.Create", function() NEW_MENU:Create() end)

-- Hook.
usermessage.Hook("citrus.Menus.Update", function(Message)
	local Reference = Message:ReadString()
	local Command = Message:ReadString()
	
	-- For Loop.
	for K, V in pairs(citrus.Menus.Stored) do
		if (V.Settings.Reference and V.Settings.Reference == Reference) then
			if (Command != "") then
				LocalPlayer():ConCommand(Command.."\n")
			else
				if (V.Settings.Update) then
					if (type(V.Settings.Update) == "function") then
						V.Settings.Update(V)
					else
						LocalPlayer():ConCommand(V.Settings.Update.."\n")
					end
				end
			end
		end
	end
end)

-- Hook.
usermessage.Hook("citrus.Menus.Remove", function(Message)
	local Reference = Message:ReadString()
	
	-- For Loop.
	for K, V in pairs(citrus.Menus.Stored) do
		if (V.Settings.Reference and V.Settings.Reference == Reference) then
			V:Remove()
			
			-- Return.
			return
		end
	end
end)

-- Render Screenspace Effects.
function citrus.Menus.RenderScreenspaceEffects()
	if (#citrus.Menus.Stored > 0) then
		local ColorModify = {}
		
		-- $pp_colour_addr.
		ColorModify["$pp_colour_addr"] = 0 
		ColorModify["$pp_colour_addg"] = 0 
		ColorModify["$pp_colour_addb"] = 0 
		ColorModify["$pp_colour_brightness"] = 0
		ColorModify["$pp_colour_contrast"] = 0.4
		ColorModify["$pp_colour_colour"] = 0
		ColorModify["$pp_colour_mulr"] = 0
		ColorModify["$pp_colour_mulg"] = 0
		ColorModify["$pp_colour_mulb"] = 0
		
		-- Draw Color Modify.
		DrawColorModify(ColorModify)
	end
end

-- HUDShouldDraw.
function citrus.Menus.HUDShouldDraw(Element)
	if (#citrus.Menus.Stored > 0) then
		if (Element == "CHudCrosshair") then return false end
	end
end

-- Player Bind Pressed.
function citrus.Menus.PlayerBindPress(Player, Bind, Pressed)
	if (#citrus.Menus.Stored > 0) then
		if (string.find(Bind, "+attack")) then return true end
	end
end

-- New.
function citrus.Menu:New()
	local Table = {}
	
	-- Set Meta Table.
	setmetatable(Table, self)
	
	-- Index.
	self.__index = self
	
	-- Dragging.
	Table.Dragging = false
	Table.Width = 0
	Table.Height = 0
	Table.X = math.min(citrus.Menus.X + 16, ScrW() - 16)
	Table.Y = math.min(citrus.Menus.Y + 16, ScrH() - 16)
	Table.Page = 1
	Table.Pages = {}
	Table.Pages[1] = {}
	
	-- X.
	citrus.Menus.X = Table.X
	citrus.Menus.Y = Table.Y
	
	-- Settings.
	Table.Settings = {}
	Table.Settings.Title = "N/A"
	Table.Settings.Icon = "gui/silkicons/user"
	Table.Settings.Update = false
	Table.Settings.Reference = false
	
	-- Return Table.
	return Table
end

-- Set Title.
function citrus.Menu:SetTitle(Title) self.Settings.Title = Title end
function citrus.Menu:SetIcon(Icon) self.Settings.Icon = Icon end
function citrus.Menu:SetUpdate(Update) self.Settings.Update = Update end
function citrus.Menu:SetReference(...) self.Settings.Reference = citrus.Menus.ReferenceAdd(unpack(arg)) end

-- Control Add.
function citrus.Menu:ControlAdd(Name, Table, Page)
	local Control = citrus.Controls.Create(self, Name)
	
	-- Check Table.
	if (Table) then table.Merge(Control, Table) end
	
	-- Check Page.
	if (Page) then
		if (self.Pages[Page]) then
			local Index = #self.Pages[Page] + 1
			
			-- Index.
			self.Pages[Page][Index] = Control
		end
		
		-- Return Control.
		return Control
	end
	
	-- Page.
	local Page = #self.Pages
	
	-- Check Page.
	if (#self.Pages[Page] >= 5 and !Control.OnSetPosition) then
		Page = Page + 1
		
		-- Page.
		self.Pages[Page] = self.Pages[Page] or {}
		
		-- Index.
		local Index = #self.Pages[Page] + 1
		
		-- Index.
		self.Pages[Page][Index] = Control
	else
		local Index = #self.Pages[Page] + 1
		
		-- Index.
		self.Pages[Page][Index] = Control
	end
	
	-- Return Control.
	return Control
end

-- Create Next Previous.
function citrus.Menu:CreateNextPrevious(Page)
	if (self.Pages[Page]) then
		if (self.Pages[Page - 1]) then
			self:ControlAdd("Button", {
				Text = "<- Previous Page",
				Command = function() self:PreviousPage() end
			}, Page)
		end
		
		-- Check Page.
		if (self.Pages[Page + 1]) then
			self:ControlAdd("Button", {
				Text = "Next Page ->",
				Command = function() self:NextPage() end
			}, Page)
		end
	end
end

-- Create.
function citrus.Menu:Create()
	for K, V in pairs(self.Pages) do
		self:ControlAdd("Exit Button", nil, K)
		self:CreateNextPrevious(K)
	end
	
	-- Stored.
	citrus.Menus.Stored[#citrus.Menus.Stored + 1] = self
	citrus.Menus.SetMaximised()
	
	-- Hide Tool.
	citrus.Menus.HideTool()
	
	-- Enable Screen Clicker.
	gui.EnableScreenClicker(true)
	
	-- For Loop.
	for K, V in pairs(citrus.Menus.Stored) do
		if (V != self) then
			if (V.Settings.Reference and V.Settings.Reference == self.Settings.Reference) then
				self.X = V.X
				self.Y = V.Y
				
				-- Remove.
				V:Remove()
				
				-- Break.
				break
			end
		end
	end
end

-- Next Page.
function citrus.Menu:NextPage()
	if (self.Pages[self.Page + 1]) then self.Page = self.Page + 1 end
end

-- Previous Page.
function citrus.Menu:PreviousPage()
	if (self.Pages[self.Page - 1]) then self.Page = self.Page - 1 end
end

-- Draw.
function citrus.Menu:Draw()
	local BackgroundColor = citrus.Themes.GetColor("Background")
	local ForegroundColor = citrus.Themes.GetColor("Foreground")
	local SelectedColor = citrus.Themes.GetColor("Selected")
	local CornerSize = citrus.Themes.GetSize("Corner")
	local TextColor = citrus.Themes.GetColor("Text")
	
	-- Width.
	self.Width, self.Height = self:SortControls()
	
	-- Set Positions.
	self:SetPositions()
	
	-- A.
	BackgroundColor.a = math.max(BackgroundColor.a, 200)
	SelectedColor.a = math.max(SelectedColor.a, 200)
	
	-- Check Dragging.
	if (self.Dragging) then
		draw.RoundedBox(CornerSize, self.X, self.Y, self.Width, self.Height, SelectedColor)
	else
		draw.RoundedBox(CornerSize, self.X, self.Y, self.Width, self.Height, BackgroundColor)
	end
	
	-- Rounded Box.
	draw.RoundedBox(CornerSize, self.X + 4, self.Y + 4, self.Width - 8, 24, ForegroundColor)
	
	-- Text.
	draw.SimpleText(self.Settings.Title, "citrus_MainText", self.X + (self.Width / 2), self.Y + 8, TextColor, 1)
	draw.RoundedBox(CornerSize, self.X + 6, self.Y + 6, 20, 20, ForegroundColor)
	citrus.Draw.Texture(surface.GetTextureID(self.Settings.Icon), self.X + 8, self.Y + 8, 16, 16)
	
	-- Draw Controls.
	self:DrawControls()
end

-- Get Controls.
function citrus.Menu:GetControls()
	local Controls = {}
	
	-- For Loop.
	for K, V in pairs(self.Pages) do table.Add(Controls, V) end
	
	-- Return Controls.
	return Controls
end

-- Sort Controls.
function citrus.Menu:SortControls()
	surface.SetFont("citrus_MainText")
	
	-- Width.
	local Width = surface.GetTextSize(self.Settings.Title) + 64
	local Height = 32
	
	-- For Loop.
	for K, V in pairs(self.Pages[self.Page]) do
		if (!V.OnSetPosition) then
			if (V.Height) then			
				Height = Height + V.Height + 8
			end
			
			-- Check Width.
			if (V.Width) then
				if (V.Width > Width) then Width = V.Width end
			end
		end
	end
	
	-- Return Width.
	return Width + 16, Height + 4
end

-- Remove.
function citrus.Menu:Remove()
	for K, V in pairs(citrus.Menus.Stored) do
		if (V == self) then
			table.remove(citrus.Menus.Stored, K)
			
			-- Break.
			break
		end
	end
	
	-- Enable Screen Clicker.
	if (#citrus.Menus.Stored == 0) then
		gui.EnableScreenClicker(false)
		
		-- Restore Tool.
		citrus.Menus.RestoreTool()
		
		-- X.
		citrus.Menus.X, citrus.Menus.Y = 32, 32
	end
end

-- Set Positions.
function citrus.Menu:SetPositions()
	local Y = 36
	
	-- For Loop.
	for K, V in pairs(self.Pages[self.Page]) do
		if (!V.OnSetPosition) then
			V.X = self.X + 8
			V.Y = self.Y + Y
			
			-- Y.
			Y = Y + V.Height + 8
		end
	end
end

-- Draw Controls.
function citrus.Menu:DrawControls()
	for K, V in pairs(self.Pages[self.Page]) do
		if (V.OnSetPosition) then V:OnSetPosition() end
		
		-- On Draw.
		V:OnDraw()
	end
end

-- Is Menu Colliding.
function citrus.Menus.IsMenuColliding(Menu, X, Y)
	if (X > Menu.X and X < (Menu.X + Menu.Width)) and (Y > Menu.Y) and (Y < (Menu.Y + Menu.Height)) then
		return true
	else
		return false
	end
end

-- Is Menu Blocked.
function citrus.Menus.IsMenuBlocked(Index, X, Y)
	for K, V in pairs(citrus.Menus.Stored) do
		if (K > Index) then
			if (V.X < X and (V.X + V.Width) > X) then
				if (V.Y < Y and (V.Y + V.Height) > Y) then return true end
			end
		end
	end
	
	-- Return False.
	return false
end

-- Restore Tool.
function citrus.Menus.RestoreTool()
	if (citrus.Menus.Tool) then
		LocalPlayer():ConCommand("gmod_toolmode "..citrus.Menus.Tool.."\n")
		
		-- Tool.
		citrus.Menus.Tool = nil
	end
end

-- Hide Tool.
function citrus.Menus.HideTool()
	if (!citrus.Menus.Tool) then
		citrus.Menus.Tool = GetConVarString("gmod_toolmode")
		
		-- Con Command.
		LocalPlayer():ConCommand("gmod_toolmode \"\"\n")
	end
end

-- Reference Add.
function citrus.Menus.ReferenceAdd(...)
	local String = ""
	
	-- For Loop.
	for I = 1, #arg do String = String.."['"..tostring(arg[I]).."']" end
	
	-- Return CRC.
	return util.CRC(String)
end

-- Update.
function citrus.Menus.Update(...)
	local Reference = citrus.Menus.ReferenceAdd(unpack(arg))
	
	-- For Loop.
	for K, V in pairs(citrus.Menus.Stored) do
		if (V.Settings.Reference and V.Settings.Reference == Reference) then
			if (V.Settings.Update) then
				if (type(V.Settings.Update) == "function") then
					V.Settings.Update(V)
				else
					LocalPlayer():ConCommand(V.Settings.Update.."\n")
				end
				
				-- Return True.
				return true
			end
		end
	end
	
	-- Return False.
	return false
end

-- Text Entry.
function citrus.Menus.TextEntry(Title, Command, Discontinue)
	local Frame = vgui.Create("DFrame")
	
	-- Set Sizable.
	Frame:SetSizable(false)
	Frame:SetDraggable(true)
	Frame:SetTitle(Title)
	Frame:SetDeleteOnClose(true)
	Frame:SetSize(300, 56)
	Frame:SetPos((ScrW() / 2) - (300 / 2), (ScrH() / 2) - (56 / 2))

	-- Text Entry.
	local TextEntry = vgui.Create("DTextEntry", Frame)

	-- Set Pos.
	TextEntry:SetPos(8, 32)
	TextEntry:SetSize(286, 16)
	TextEntry.OnEnter = function()
		local Text = TextEntry:GetValue()
		
		-- Check type.
		if (type(Command) == "string") then
			LocalPlayer():ConCommand(Command.." \""..Text.."\"\n")
		else
			Command(Text)
		end
		
		-- Check Discontinue.
		if (Discontinue) then Frame:Close() end
	end

	-- Make Popup.
	Frame:MakePopup()
	TextEntry:RequestFocus()
	
	-- Return Frame.
	return Frame, TextEntry
end

-- Set Maximised.
function citrus.Menus.SetMaximised()
	if (#citrus.Menus.Stored > 0) then
		hook.Add("Think", "citrus.Menus.Think", citrus.Menus.Think)
		hook.Add("HUDShouldDraw", "citrus.Menus.HUDShouldDraw", citrus.Menus.HUDShouldDraw)
		hook.Add("GUIMousePressed", "citrus.Menus.MousePressed", citrus.Menus.MousePressed)
		hook.Add("HUDDrawScoreBoard", "citrus.Menus.HUDDrawScoreBoard", citrus.Menus.HUDDrawScoreBoard)
		hook.Add("GUIMouseReleased", "citrus.Menus.MouseReleased", citrus.Menus.MouseReleased)
		hook.Add("PlayerBindPress", "citrus.Menus.PlayerBindPress", citrus.Menus.PlayerBindPress)
		hook.Add("RenderScreenspaceEffects", "citrus.Menus.RenderScreenspaceEffects", citrus.Menus.RenderScreenspaceEffects)
		
		-- Hide Tool.
		citrus.Menus.HideTool()
		
		-- Enable Screen Clicker.
		gui.EnableScreenClicker(true)
	end
end

-- Set Minimised.
function citrus.Menus.SetMinimised()
	if (#citrus.Menus.Stored > 0) then
		hook.Remove("Think", "citrus.Menus.Think")
		hook.Remove("HUDShouldDraw", "citrus.Menus.HUDShouldDraw")
		hook.Remove("GUIMousePressed", "citrus.Menus.MousePressed")
		hook.Remove("HUDDrawScoreBoard", "citrus.Menus.HUDDrawScoreBoard")
		hook.Remove("GUIMouseReleased", "citrus.Menus.MouseReleased")
		hook.Remove("PlayerBindPress", "citrus.Menus.PlayerBindPress")
		hook.Remove("RenderScreenspaceEffects", "citrus.Menus.RenderScreenspaceEffects")
		
		-- Restore Tool.
		citrus.Menus.RestoreTool()
		
		-- Enable Screen Clicker.
		gui.EnableScreenClicker(false)
	end
end

-- Set Maximised.
citrus.Menus.SetMaximised()