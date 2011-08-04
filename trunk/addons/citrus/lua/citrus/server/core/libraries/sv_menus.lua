--[[
Name: "sv_menus.lua".
Product: "Citrus (Server Management)".
--]]

citrus.Menu = {}
citrus.Menus = {}
citrus.Menus.Callbacks = {}

-- Add.
concommand.Add("sv_citrus_callback", function(Player, Command, Arguments)
	for K, V in pairs(citrus.Menus.Callbacks) do
		if (K == Arguments[1]) then
			table.remove(Arguments, 1)
			
			-- For Loop.
			for K2, V2 in pairs(Arguments) do
				Arguments[K2] = citrus.Utilities.GetStringValue(V2)
			end
			
			-- Check V.
			if (V) then V(Player, unpack(Arguments)) end
			
			-- Return False.
			return false
		end
	end
end)

-- Callback Add.
function citrus.Menus.CallbackAdd(Callback)
	local String = util.CRC(tostring(Callback))
	
	-- String.
	citrus.Menus.Callbacks[String] = Callback
	
	-- Return String.
	return "sv_citrus_callback "..String
end

-- Text Entry.
function citrus.Menus.TextEntry(Player, Title, Command, Discontinue)
	if (type(Command) == "function") then Command = citrus.Menus.CallbackAdd(Command) end
	
	-- Start.
	umsg.Start("citrus.Menus.TextEntry", Player)
		umsg.String(Title or "Untitled")
		umsg.String(Command or "")
		umsg.Bool(Discontinue or false)
	umsg.End()
end

-- Update.
function citrus.Menus.Update(Player, ...)
	local Reference = citrus.Menus.ReferenceAdd(unpack(arg))
	
	-- Start.
	umsg.Start("citrus.Menus.Update", Player)
		umsg.String(Reference)
	umsg.End()
end

-- Remove.
function citrus.Menus.Remove(Player, ...)
	local Reference = citrus.Menus.ReferenceAdd(unpack(arg))
	
	-- Start.
	umsg.Start("citrus.Menus.Remove", Player)
		umsg.String(Reference)
	umsg.End()
end

-- Reference Add.
function citrus.Menus.ReferenceAdd(...)
	local String = ""
	
	-- For Loop.
	for I = 1, #arg do String = String.."['"..tostring(arg[I]).."']" end
	
	-- Return CRC.
	return util.CRC(String)
end

-- New.
function citrus.Menu:New()
	local Table = {}
	
	-- Set Meta Table.
	setmetatable(Table, self)
	
	-- Index.
	self.__index = self
	
	-- Controls.
	Table.Controls = {}
	
	-- Settings.
	Table.Settings = {}
	Table.Settings.Icon = "gui/silkicons/user"
	Table.Settings.Title = "N/A"
	Table.Settings.Update = ""
	Table.Settings.Reference = ""
	
	-- Return Table.
	return Table
end

-- Set Title.
function citrus.Menu:SetTitle(Title) self.Settings.Title = Title end
function citrus.Menu:SetIcon(Icon) self.Settings.Icon = Icon end
function citrus.Menu:SetPlayer(Player) self.Settings.Player = Player end
function citrus.Menu:SetUpdate(Callback, ...)
	if (#arg > 0) then
		local Function = Callback
		
		-- Callback.
		Callback = function(Player) Function(Player, unpack(arg)) end
	end
	
	-- Update.
	self.Settings.Update = citrus.Menus.CallbackAdd(Callback)
end
function citrus.Menu:SetReference(...) self.Settings.Reference = citrus.Menus.ReferenceAdd(unpack(arg)) end

-- Control Add.
function citrus.Menu:ControlAdd(Name, Table)
	Table.Name = Name
	
	-- Controls.
	self.Controls[#self.Controls + 1] = Table
end

-- Markup Text Add.
function citrus.Menu:MarkupTextAdd(Text, Table)
	Table = Table or {}
	
	-- Merge.
	table.Merge(Table, {Text = Text})
	
	-- Control Add.
	self:ControlAdd("Markup Text", Table)
end

-- Text Add.
function citrus.Menu:TextAdd(Text, Table)
	if (string.find(Text, "\n")) then
		local Start, Finish = string.find(Text, "\n")
		
		-- One.
		local One = string.sub(Text, 1, Start - 1)
		local Two = string.sub(Text, Finish + 1)
		
		-- Text Add.
		self:TextAdd(One, Table)
		self:TextAdd(Two, Table)
	else
		Table = Table or {}
		
		-- Merge.
		table.Merge(Table, {Text = Text})
		
		-- Control Add.
		self:ControlAdd("Text", Table)
	end
end

-- Button Add.
function citrus.Menu:ButtonAdd(Text, Command, Table)
	if (type(Command) == "function") then Command = citrus.Menus.CallbackAdd(Command) end
	
	-- Table.
	Table = Table or {}
	
	-- Merge.
	table.Merge(Table, {Text = Text, Command = Command})
	
	-- Control Add.
	self:ControlAdd("Button", Table)
end

-- Slider Add.
function citrus.Menu:SliderAdd(Text, Command, Minimum, Maximum, Table)
	if (type(Command) == "function") then Command = citrus.Menus.CallbackAdd(Command) end
	
	-- Table.
	Table = Table or {}
	
	-- Merge.
	table.Merge(Table, {Text = Text, Command = Command, Minimum = Minimum, Maximum = Maximum})
	
	-- Control Add.
	self:ControlAdd("Slider", Table)
end

-- Check Box Add.
function citrus.Menu:CheckBoxAdd(Text, Command, Value, Table)
	if (type(Command) == "function") then Command = citrus.Menus.CallbackAdd(Command) end
	
	-- Table.
	Table = Table or {}
	
	-- Merge.
	table.Merge(Table, {Text = Text, Command = Command, Value = Value})
	
	-- Control Add.
	self:ControlAdd("Check Box", Table)
end

-- Send.
function citrus.Menu:Send()
	citrus.Hooks.Call("OnMenuSend", self)
	
	-- Start.
	umsg.Start("citrus.Menus.New", self.Settings.Player)
		umsg.String(self.Settings.Title)
		umsg.String(self.Settings.Icon)
		umsg.String(self.Settings.Update)
		umsg.String(self.Settings.Reference)
	umsg.End()
	
	-- For Loop.
	for K, V in pairs(self.Controls) do
		umsg.Start("citrus.Controls.New", self.Settings.Player) umsg.End()
		
		-- For Loop.
		for K2, V2 in pairs(V) do
			citrus.Utilities.KeyValueSend("citrus.Controls.KeyValueReceive", self.Settings.Player, K2, V2)
		end
		
		-- Start.
		umsg.Start("citrus.Controls.Add", self.Settings.Player) umsg.End()
	end
	
	-- Start.
	umsg.Start("citrus.Menus.Create", self.Settings.Player) umsg.End()
end