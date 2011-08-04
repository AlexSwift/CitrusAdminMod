--[[
Name: "cl_countdowns.lua".
Product: "Citrus (Server Management)".
--]]

citrus.Countdown = {}
citrus.Countdowns = {}
citrus.Countdowns.Stored = {}

-- New.
function citrus.Countdown:New(Name)
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
	Table.Settings.Time = 0
	
	-- Return Table.
	return Table
end

-- Set Time.
function citrus.Countdown:SetTime(Time) self.Settings.Time = CurTime() + Time  end

-- Set Title.
function citrus.Countdown:SetTitle(Title)
	if (string.len(Title) > 32) then
		Title = string.sub(Title, 1, 32).."-"
	end
	
	-- Title.
	self.Settings.Title = Title
end

-- Set Text Color.
function citrus.Countdown:SetTextColor(TextColor) self.Settings.TextColor = TextColor end

-- Create.
function citrus.Countdown:Create()
	for K, V in pairs(citrus.Countdowns.Stored) do
		if (V.Name == self.Name) then
			V.Settings = self.Settings
			
			-- Return.
			return
		end
	end
	
	-- Stored.
	citrus.Countdowns.Stored[#citrus.Countdowns.Stored + 1] = self
	
	-- Index.
	self.Index = #citrus.Countdowns.Stored
end

-- Remove.
function citrus.Countdown:Remove()
	citrus.Countdowns.Stored[self.Index] = nil
end

-- Get.
function citrus.Countdowns.Get(Name)
	for K, V in pairs(citrus.Countdowns.Stored) do
		if (V.Name == Name) then return V end
	end
	
	-- Return False.
	return false, "Unable to locate '"..Name.."'!"
end

-- HUD Draw Score Board.
function citrus.Countdowns.HUDDrawScoreBoard()
	local BackgroundColor = citrus.Themes.GetColor("Background")
	local CornerSize = citrus.Themes.GetSize("Corner")
	local TextColor = citrus.Themes.GetColor("Text")
	
	-- Cur Time.
	local CurTime = CurTime()
	local Position = 8
	
	-- For Loop.
	for K, V in pairs(citrus.Countdowns.Stored) do
		local function Callback(X, Y, Width, Height)
			Position = Position + Height + 8
			
			-- Return X.
			return X - Width, Y
		end
		
		-- Time.
		local Time = math.ceil(V.Settings.Time - CurTime)
		
		-- Check Time.
		if (Time <= 0) then
			V:Remove()
		else
			citrus.Draw.RoundedTextBox(V.Settings.Title..": "..citrus.Utilities.GetFormattedTime(Time, "%hh %mm %ss"), "citrus_MainText", V.Settings.TextColor or TextColor, ScrW() - 8, Position, CornerSize, BackgroundColor, false, false, false, false, Callback)
		end
	end
end

-- Add.
hook.Add("HUDDrawScoreBoard", "citrus.Countdowns.HUDDrawScoreBoard", citrus.Countdowns.HUDDrawScoreBoard)

-- Hook.
usermessage.Hook("citrus.Countdowns.Add", function(Message)
	local Name = Message:ReadString()
	local Title = Message:ReadString()
	local Time = Message:ReadLong()
	
	-- Cur Time.
	local CurTime = CurTime()
	
	-- Countdown.
	local Countdown = citrus.Countdown:New(Name)
	
	-- Set Time.
	Countdown:SetTime(math.ceil(Time - CurTime))
	Countdown:SetTitle(Title)
	Countdown:Create()
end)

-- Hook.
usermessage.Hook("citrus.Countdowns.Remove", function(Message)
	local Name = Message:ReadString()
	
	-- Countdown.
	local Countdown = citrus.Countdowns.Get(Name)
	
	-- Check Countdown.
	if (Countdown) then Countdown:Remove() end
end)