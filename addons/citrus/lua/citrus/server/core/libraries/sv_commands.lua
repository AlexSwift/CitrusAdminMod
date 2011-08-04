--[[
Name: "sv_commands.lua".
Product: "Citrus (Server Management)".
--]]

citrus.Command = {}
citrus.Commands = {}
citrus.Commands.Stored = {}
citrus.Commands.Prefix = "/"

-- Get Syntax.
function citrus.Command:GetSyntax()
	local String = ""
	
	-- For Loop.
	for K, V in pairs(self.Settings.Arguments) do
		if (V[3]) then
			String = String.."[<"..V[2].." "..V[1]..">]"
		else
			String = String.."<"..V[2].." "..V[1]..">"
		end
		
		-- Check K.
		if (K != #self.Settings.Arguments) then String = String.." " end
	end
	
	-- Return String.
	return String
end

-- Get  Mandatory Arguments.
function citrus.Command:GetMandatoryArguments()
	local Arguments = {}
	
	-- For Loop.
	for K, V in pairs(self.Settings.Arguments) do
		if (!V[3]) then Arguments[#Arguments + 1] = V end
	end
	
	-- Return Arguments.
	return Arguments
end

-- Get Arguments Table.
function citrus.Command:GetArgumentsTable(Player, Arguments, RCon)
	if (Arguments != "") then	
		for K, V in pairs(Arguments) do
			if (self.Settings.Arguments[K]) then
				Arguments[K] = string.Trim(V)
				
				-- Check 2.
				if (self.Settings.Arguments[K][2] == "number") then
					Arguments[K] = tonumber(Arguments[K])
					
					-- Check K.
					if (!Arguments[K]) then
						if (RCon) then
							print(self:GetSyntax()..".")
						else
							citrus.Player.Notify(Player, Command:GetSyntax()..".")
						end
						
						-- Return False.
						return false
					end
				elseif (self.Settings.Arguments[K][2] == "boolean") then
					local Success = nil
					
					-- Success.
					Success, Arguments[K] = citrus.Utilities.ToBoolean(Arguments[K])
					
					-- Check Success.
					if (!Success) then
						if (RCon) then
							print(self:GetSyntax()..".")
						else
							citrus.Player.Notify(Player, Command:GetSyntax()..".")
						end
						
						-- Return False.
						return false
					end
				elseif (self.Settings.Arguments[K][2] == "player") then
					Arguments[K] = citrus.Player.Get(Arguments[K])
					
					-- Check K.
					if (!Arguments[K]) then
						if (RCon) then
							print(self:GetSyntax()..".")
						else
							citrus.Player.Notify(Player, Command:GetSyntax()..".")
						end
						
						-- Return False.
						return false
					end
				end
			end
		end
	else
		Arguments = {}
	end
	
	-- Return Arguments.
	return Arguments
end

-- New.
function citrus.Command:New(Name, Access, Arguments)
	local Table = {}
	
	-- Set Meta Table.
	setmetatable(Table, self)
	
	-- Index.
	self.__index = self
	
	-- Name.
	Table.Name = Name
	
	-- Settings.
	Table.Settings = {}
	Table.Settings.Usable = true
	Table.Settings.Access = Access or "B"
	Table.Settings.Arguments = Arguments or {}
	
	-- Return Table.
	return Table
end

-- Quick Menu Add.
function citrus.Command:QuickMenuAdd(Category, Name, Arguments, Icon)
	self.Settings.QuickMenu = citrus.QuickMenu.Add(Category, Name, "citrus "..self.Name, Arguments, self.Settings.Access, Icon)
end

-- Quick Menu Remove.
function citrus.Command:QuickMenuRemove()
	if (self.Settings.QuickMenu) then citrus.QuickMenu.Remove(self.Settings.QuickMenu) end
end

-- Set Chat Command.
function citrus.Command:SetChatCommand(Boolean)
	self.Settings.ChatCommand = Boolean
end

-- Set Usable.
function citrus.Command:SetUsable(Boolean)
	self.Settings.Usable = Boolean
end

-- Create.
function citrus.Command:Create()
	citrus.Commands.Stored[self.Name] = self
end

-- Get.
function citrus.Commands.Get(Command)
	for K, V in pairs(citrus.Commands.Stored) do
		if (K == Command) then return V end
	end
	
	-- Return False.
	return false, "Unable to locate '"..Command.."'!"
end

-- Run.
function citrus.Commands.Run(Player, Command, Arguments, RCon)
	local IsAllowed = true
	
	-- Check RCon.
	if (!RCon) then
		IsAllowed = citrus.PlayerEvents.IsAllowed(Player, citrus.PlayerEvent.UseCommand)
	end
	
	-- Check Is Allowed.
	if (IsAllowed) then
		local Access = true
		
		-- Check RCon.
		if (!RCon) then
			Access = citrus.PlayerVariables.Get(Player, "Access").Command[Command.Name]
			
			if (Access == nil) then Access = true end
		end
		
		-- Check Access.
		if (Access) then
			if (RCon or citrus.Access.Has(Player, Command.Settings.Access)) then
				Arguments = Command:GetArgumentsTable(Player, Arguments, RCon)
				
				-- Check Arguments.
				if (!Arguments) then return false end
				
				-- Mandatory Arguments.
				local MandatoryArguments = Command:GetMandatoryArguments()
				
				-- Check RCon.
				if (table.Count(Arguments) < #MandatoryArguments) then
					if (RCon) then
						print(Command:GetSyntax()..".")
					else
						if (table.Count(Arguments) == 0 and #MandatoryArguments > 0) then
							if (Command.Settings.QuickMenu) then
								citrus.QuickMenu.Start(Player, Command.Settings.QuickMenu)
								
								-- Return True.
								return true
							end
						end
						
						-- Notify.
						citrus.Player.Notify(Player, Command:GetSyntax()..".", 1)
					end
					
					-- Return False.
					return false
				end
				
				-- For Loop.
				for K, V in pairs(Command.Settings.Arguments) do
					if (!Arguments[K] and V[3]) then Arguments[K] = V[4] end
				end
				
				-- Check RCon.
				if (RCon) then
					PCallError(Command.RConCallback, Arguments)
				else
					PCallError(Command.Callback, Player, Arguments)
					
					-- Call.
					citrus.Hooks.Call("OnPlayerUseCommand", Player, Command, Arguments)
				end
			else
				citrus.Player.Notify(Player, citrus.Access.GetName(Command.Settings.Access, "or").." access required!", 1)
			end
		else
			citrus.Player.Notify(Player, "'"..Command.Name.."' access required!", 1)
		end
	end
	
	-- Return True.
	return true
end

-- Player Say.
function citrus.Commands.PlayerSay(Player, Text, Public)
	local Command = false
	local Arguments = ""
	
	-- Check Sub.
	if (string.sub(Text, 1, string.len(citrus.Commands.Prefix)) == citrus.Commands.Prefix) then
		local Exploded = string.Explode(" ", Text)
		
		-- Exploded.
		Exploded[1] = string.sub(Exploded[1], string.len(citrus.Commands.Prefix) + 1, string.len(Exploded[1]) + 1)
		
		-- For Loop.
		for K, V in pairs(citrus.Commands.Stored) do
			if (V.Settings.Usable and V.Settings.ChatCommand) then
				if (Exploded[1] == V.Name) then
					Command = V
					
					-- Check Exploded.
					if (Exploded[2]) then
						Arguments = table.concat(Exploded, " ", 2)
						
						-- Check Arguments.
						if (Arguments) then Arguments = string.Trim(Arguments) end
					end
				end
			end
		end
		
		-- Check Command.
		if (!Command) then
			citrus.Player.Notify(Player, "Unable to locate '"..Exploded[1].."'!", 1)
			
			-- Return String.
			return ""
		end
	end
	
	-- Check Command.
	if (Command) then
		citrus.Player.ConsoleCommand(Player, "citrus "..Command.Name.." "..Arguments)
		
		-- Return String.
		return ""
	end
	
	-- Call.
	citrus.Hooks.Call("OnPlayerSay", Player, Text, Public)
	
	-- Is Allowed.
	local IsAllowed = citrus.PlayerEvents.IsAllowed(Player, citrus.PlayerEvent.Say)
	
	-- Check Is Allowed.
	if (!IsAllowed) then return "" end
end

-- Add.
hook.Add("PlayerSay", "citrus.Commands.PlayerSay", citrus.Commands.PlayerSay)

-- Console Command.
function citrus.Commands.ConsoleCommand(Player, Command, Arguments)
	if (!Arguments) or (!Arguments[1]) then return end
	
	-- Is Player.
	local IsPlayer = Player:IsPlayer()
	
	-- For Loop.
	for K, V in pairs(citrus.Commands.Stored) do
		if (V.Settings.Usable and Arguments[1] == V.Name) then
			table.remove(Arguments, 1)
			
			-- Check Is Player.
			if (!IsPlayer and !V.RConCallback) then
				print("Unable to locate RCon support for "..V.Name.."!")
				
				-- Return.
				return
			end
			
			-- Run.
			citrus.Commands.Run(Player, V, Arguments, !IsPlayer)
			
			-- Return False.
			return false
		end
	end
	
	-- Check Is Player.
	if (!IsPlayer) then
		print("Unable to locate '"..Arguments[1].."'!")
		
		-- Return.
		return
	end
	
	-- Notify.
	citrus.Player.Notify(Player, "Unable to locate '"..Arguments[1].."'!", 1)
end

-- Add.
concommand.Add("citrus", citrus.Commands.ConsoleCommand)