--[[
Name: "cl_controls.lua".
Product: "Citrus (Server Management)".
--]]

citrus.Control = {}
citrus.Controls = {}
citrus.Controls.Stored = {}

-- New.
function citrus.Control:New(Name, Base)
	local Table = {}
	
	-- Set Meta Table.
	setmetatable(Table, self)
	
	-- Index.
	self.__index = self
	
	-- Name.
	Table.Controls = {}
	Table.Menu = false
	Table.Name = Name
	Table.Base = Base
	Table.Width = 0
	Table.Height = 0
	Table.X = 0
	Table.Y = 0
	
	-- Return Table.
	return Table
end

-- On Create.
function citrus.Control:OnCreate() end

-- On Mouse Pressed.
function citrus.Control:OnMousePressed(Button) end

-- On Mouse Released.
function citrus.Control:OnMouseReleased(Button) end

-- On Think.
function citrus.Control:OnThink() end

-- On Draw.
function citrus.Control:OnDraw() end

-- Create.
function citrus.Control:Create() citrus.Controls.Stored[self.Name] = self end

-- Create.
function citrus.Controls.Create(Menu, Name)
	local Control = table.Copy(citrus.Controls.Stored[Name])
	
	-- Merge Base.
	local function MergeBase(Control)
		if (Control.Base) then
			MergeBase(citrus.Controls.Stored[Control.Base])
			
			-- Merge.
			table.Merge(Control, citrus.Controls.Stored[Control.Base])
		end
	end
	
	-- Merge Base.
	MergeBase(Control)
	
	-- Merge.
	table.Merge(Control, citrus.Controls.Stored[Name])
	
	-- Menu.
	Control.Menu = Menu
	
	-- On Create.
	Control:OnCreate()
	
	-- Return Control.
	return Control
end

-- Include Directory.
citrus.Utilities.IncludeDirectory("citrus/client/controls/", "cl_", ".lua")