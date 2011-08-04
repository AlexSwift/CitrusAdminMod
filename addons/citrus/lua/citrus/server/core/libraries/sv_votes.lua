--[[
Name: "sv_votes.lua".
Product: "Citrus (Server Management)"
--]]

citrus.Vote = {}
citrus.Votes = {}
citrus.Votes.Stored = {}

-- New.
function citrus.Vote:New(Title)
	local Table = {}
	
	-- Set Meta Table.
	setmetatable(Table, self)
	
	-- Index.
	self.__index = self
	
	-- Title.
	Table.Title = Title
	
	-- Settings.
	Table.Settings = {}
	Table.Settings.Time = 30
	Table.Settings.Text = {}
	Table.Settings.Votes = {}
	Table.Settings.Options = {}
	
	-- Return Table.
	return Table
end

-- Set Callback.
function citrus.Vote:SetCallback(Callback) self.Settings.Callback = Callback end

-- Set Time.
function citrus.Vote:SetTime(Time) self.Settings.Time = Time end

-- Text Add.
function citrus.Vote:TextAdd(Text) table.insert(self.Settings.Text, Text) end

-- Option Add.
function citrus.Vote:OptionAdd(Option) self.Settings.Options[Option] = 0 end

-- Register Vote.
function citrus.Vote:Register(Player, Vote)
	for K, V in pairs(self.Settings.Votes) do
		if (V.Player == Player) then
			citrus.Player.Notify(Player, "Unable to vote again!", 1)
			
			-- Return False.
			return false
		end
	end
	
	-- Check Vote.
	if (self.Settings.Options[Vote]) then
		self.Settings.Options[Vote] = self.Settings.Options[Vote] + 1
		
		-- Notify By Access.
		citrus.Player.NotifyByAccess("M", Player:Name().." has voted ("..Vote..").")
		citrus.Player.NotifyByAccess("!M", Player:Name().." has voted.")
		
		-- Votes.
		self.Settings.Votes[#self.Settings.Votes + 1] = {Player = Player, Vote = Vote}
	end
end

-- Finish.
function citrus.Vote:Finish()
	local Votes = 0
	local Winner = nil
	
	-- For Loop.
	for K, V in pairs(self.Settings.Options) do
		if (V > Votes) then
			Votes = V
			
			-- Winner.
			Winner = K
		end
	end
	
	-- Display.
	local Display = true
	
	-- Check Callback.
	if (self.Settings.Callback) then
		if (self.Settings.Callback(self, Winner, Votes)) then Display = false end
	end
	
	-- Check Display.
	if (Display) then
		local Menu = citrus.Menu:New()
		
		-- Set Player.
		Menu:SetPlayer(nil)
		Menu:SetTitle("Vote Results")
		Menu:SetIcon("gui/silkicons/page")
		
		-- Text Add.
		Menu:TextAdd("Title: "..self.Title..".")
		
		-- Check Winner.
		if (Winner) then
			Menu:TextAdd("Winner: "..Winner.." ("..math.ceil((100 / table.Count(self.Settings.Votes)) * Votes).."%).")
			Menu:TextAdd("Votes: "..Votes..".")
		else
			Menu:TextAdd("Unable to calculate winner.")
		end
		
		-- Send.
		Menu:Send()
	end
	
	-- Call.
	citrus.Hooks.Call("OnVoteFinish", self, Winner, Votes)
	
	-- Index.
	citrus.Votes.Stored[self.Index] = nil
end

-- Send.
function citrus.Vote:Send()
	citrus.Votes.Stored[#citrus.Votes.Stored + 1] = self
	
	-- Index.
	self.Index = #citrus.Votes.Stored
	
	-- Create.
	timer.Create(tostring(self), self.Settings.Time, 1, function() self:Finish() end)
	
	-- Menu.
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(nil)
	Menu:SetTitle(self.Title)
	Menu:SetIcon("gui/silkicons/page")
	
	-- Check Text.
	if (#self.Settings.Text > 0) then
		for K, V in pairs(self.Settings.Text) do Menu:TextAdd(V) end
	end
	
	-- For Loop.
	for K, V in pairs(self.Settings.Options) do
		Menu:ButtonAdd(K, function(Player)
			if (citrus.Votes.Stored[self.Index]) then
				self:Register(Player, K)
			else
				citrus.Player.Notify(Player, "Unable to register vote!", 1)
			end
		end, {Discontinue = true})
	end
	
	-- Send.
	Menu:Send()
	
	-- Call.
	citrus.Hooks.Call("OnVoteStart", self)
end

-- Finish All.
function citrus.Votes.FinishAll()
	for K, V in pairs(citrus.Votes.Stored) do V:Finish() end
end