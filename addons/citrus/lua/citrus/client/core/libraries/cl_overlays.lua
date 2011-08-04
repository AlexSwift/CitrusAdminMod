--[[
Name: "cl_overlays.lua".
Product: "Citrus (Server Management)".
--]]

citrus.Overlay = {}
citrus.Overlays = {}
citrus.Overlays.Stored = {}

-- New.
function citrus.Overlay:New(Name)
	local Table = {}
	
	-- Set Meta Table.
	setmetatable(Table, self)
	
	-- Index.
	self.__index = self
	
	-- Name.
	Table.Name = Name
	
	-- Settings.
	Table.Settings = {}
	Table.Settings.Title = "N/A"
	Table.Settings.Text = "N/A"
	Table.Settings.Alpha = 255
	
	-- Return Table.
	return Table
end

-- Set Title.
function citrus.Overlay:SetTitle(Title) self.Settings.Title = Title end

-- Set Title Color.
function citrus.Overlay:SetTitleColor(TitleColor) self.Settings.TitleColor = TitleColor end

-- Set Text.
function citrus.Overlay:SetText(Text) self.Settings.Text = Text end

-- Set Text Color.
function citrus.Overlay:SetTextColor(Text) self.Settings.TextColor = TextColor end

-- Set Alpha.
function citrus.Overlay:SetAlpha(Alpha) self.Settings.Alpha = Alpha end

-- Create.
function citrus.Overlay:Create()
	local Success = false
	
	-- For Loop.
	for K, V in pairs(citrus.Overlays.Stored) do
		if (V.Name == self.Name) then
			citrus.Overlays.Stored[K] = self
			citrus.Overlays.Stored[K].Index = K
			
			-- Success.
			Success = true
		end
	end
	
	-- Check Success.
	if (!Success) then
		citrus.Overlays.Stored[#citrus.Overlays.Stored + 1] = self
		
		-- Index.
		self.Index = #citrus.Overlays.Stored
	end
end

-- Remove.
function citrus.Overlay:Remove()
	citrus.Overlays.Stored[self.Index] = nil
end

-- Get.
function citrus.Overlays.Get(Name)
	for K, V in pairs(citrus.Overlays.Stored) do
		if (V.Name == Name) then
			return V
		end
	end
	
	-- Return False.
	return false, "Unable to locate '"..Name.."'!"
end

-- HUD Draw Score Board.
function citrus.Overlays.HUDDrawScoreBoard()
	local BackgroundColor = citrus.Themes.GetColor("Background")
	local TitleColor = citrus.Themes.GetColor("Title")
	local TextColor = citrus.Themes.GetColor("Text")
	
	-- Overlay.
	local Overlay = citrus.Overlays.Stored[#citrus.Overlays.Stored]
	
	-- Check Overlay.
	if (Overlay) then
		local Color = Color(BackgroundColor.r, BackgroundColor.g, BackgroundColor.b, Overlay.Settings.Alpha)
		
		-- Rounded Box.
		draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), Color)
		draw.SimpleText(Overlay.Settings.Title, "citrus_HugeTitle", ScrW() / 2, (ScrH() / 2) - 64, Overlay.Settings.TitleColor or TitleColor, 1, 1)
		
		-- Exploded.
		local Exploded = string.Explode("\n", Overlay.Settings.Text)
		local Y = ScrH() / 2
		
		-- For Loop.
		for K, V in pairs(Exploded) do
			draw.SimpleText(V, "citrus_MainText", ScrW() / 2, Y, Overlay.Settings.TextColor or TextColor, 1, 1)
			
			-- Y.
			Y = Y + 24
		end
	end
end

-- Add.
hook.Add("HUDDrawScoreBoard", "citrus.Overlays.HUDDrawScoreBoard", citrus.Overlays.HUDDrawScoreBoard)

-- Hook.
usermessage.Hook("citrus.Overlays.Add", function(Message)
	local Name = Message:ReadString()
	local Title = Message:ReadString()
	local Text = Message:ReadString()
	local Alpha = Message:ReadShort()
	
	-- Overlay.
	local Overlay = citrus.Overlay:New(Name)
	
	-- Set Title.
	Overlay:SetTitle(Title)
	Overlay:SetText(Text)
	Overlay:SetAlpha(Alpha)
	
	-- Create.
	Overlay:Create()
end)

-- Hook.
usermessage.Hook("citrus.Overlays.Remove", function(Message)
	local Name = Message:ReadString()
	
	-- Overlay.
	local Overlay = citrus.Overlays.Get(Name)
	
	-- Check Overlay.
	if (Overlay) then Overlay:Remove() end
end)