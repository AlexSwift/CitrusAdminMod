--[[
Name: "sv_utilities.lua".
Product: "Citrus (Server Management)".
--]]

function citrus.Utilities.AddCSLuaDirectory(Directory, Prefix, Recursive)
	local Files = file.FindInLua(Directory.."*")
	
	-- Check Files.
	if (Files) then
		for K, V in pairs(Files) do
			if (V != "." and V != "..") then
				if (file.IsDir("../lua/"..Directory..V.."/") and Recursive) then
					citrus.Utilities.AddCSLuaDirectory(Directory..V.."/", Prefix, Recursive)
				else
					if (string.sub(V, -4) == ".lua") then
						if (!Prefix or string.sub(V, 1, string.len(Prefix)) == Prefix) then
							AddCSLuaFile(Directory..V)
						end
					end
				end
			end
		end
	end
end

-- Key Value Send.
function citrus.Utilities.KeyValueSend(Name, Player, Key, Value)
	if (type(Value) == "string") then
		if (string.len(Value) > 200) then
			citrus.Utilities.KeyValueSend(Name, Player, Key, string.sub(Value, 1, 199))
			citrus.Utilities.KeyValueSend(Name, Player, Key, string.sub(Value, 200))
			
			-- Return.
			return
		end
	end
	
	-- Start.
	umsg.Start(Name, Player)
		umsg.String(Key)
		
		-- Check type.
		if (type(Value) == "Player" or type(Value) == "Entity") then
			umsg.Char(1)
			umsg.Entity(Value)
		elseif (type(Value) == "string") then
			umsg.Char(2)
			umsg.String(Value)
		elseif (type(Value) == "number") then
			if (math.fmod(Value, 1 ) != 0) then
				umsg.Char(3)
				umsg.Float(Value)
			else
				if (Value <= 127 and Value >= -127) then
					umsg.Char(4)
					umsg.Char(Value)
				elseif (Value < 32767 and Value > -32768) then
					umsg.Char(5)
					umsg.Short(Value)
				else
					umsg.Char(6)
					umsg.Long(Value)
				end
			end
		elseif (type(Value) == "boolean") then
			umsg.Char(7)
			umsg.Bool(Value)
		elseif (type(Value) == "Vector") then
			umsg.Char(8)
			umsg.Vector(Value)
		elseif (type(Value) == "Angle") then
			umsg.Char(9)
			umsg.Angle(Value)
		end
	umsg.End()
end

-- Table As Controls.
function citrus.Utilities.TableAsControls(Menu, Table, Message)
	local Tables = {}
	
	-- Check Message.
	if (Message and table.Count(Table) == 0) then
		Menu:TextAdd("Unable to locate values!")
		
		-- Return.
		return
	end
	
	-- For Loop.
	for K, V in pairs(Table) do
		local Type = type(V)
		
		-- Check Type.
		if (Type == "table") then
			Tables[K] = V
		else
			V = tostring(V)
			
			-- Check V.
			if (V == "") then V = "N/A" end
			
			-- Check K.
			if (K == V) then Menu:TextAdd(K..".") else Menu:TextAdd(K..": "..V..".") end
		end
	end
	
	-- For Loop.
	for K, V in pairs(Tables) do
		Menu:ButtonAdd(K, function() citrus.Utilities.TableAsMenu(Menu.Settings.Player, V, K, Icon) end)
	end
end

-- Table As Menu.
function citrus.Utilities.TableAsMenu(Player, Table, Title, Icon)
	local Menu = citrus.Menu:New()

	-- Set Player.
	if (Player) then Menu:SetPlayer(Player) end
	if (Title) then Menu:SetTitle(Title) end
	if (Icon) then Menu:SetIcon(Icon) end
	
	-- Set Update.
	Menu:SetUpdate(Table, Title)
	Menu:SetReference(Table, Title)
	
	-- Title.
	Title = Title or "N/A"
	
	-- Check Count.
	if (table.Count(Table) == 0) then
		Menu:TextAdd("Unable to locate values!")
	else
		local Tables = {}
		
		-- For Loop.
		for K, V in pairs(Table) do
			local Type = type(V)
			
			-- Check Type.
			if (Type == "table") then
				Tables[K] = V
			else
				V = tostring(V)
				
				-- Check V.
				if (V == "") then V = "N/A" end
				
				-- Check K.
				if (K == V) then Menu:TextAdd(K..".") else Menu:TextAdd(K..": "..V..".") end
			end
		end
		
		-- For Loop.
		for K, V in pairs(Tables) do
			Menu:ButtonAdd(K, function() citrus.Utilities.TableAsMenu(Player, V, Title.." ("..K..")", Icon) end)
		end
	end
	
	-- Send.
	Menu:Send()
end

-- Console Command.
function citrus.Utilities.ConsoleCommand(Command, ...)
	local Table = {}
	
	-- For Loop.
	for I = 1, table.getn(arg) do Table[I] = arg[I] end
	
	-- Arguments.
	local Arguments = table.concat(Table, " ")
	
	-- Console Command.
	game.ConsoleCommand(Command.." "..Arguments.."\n")
end

-- Table Save.
function citrus.Utilities.TableSave(File, Table)
	local Contents = citrus.Serialise.Serialise(Table)
	
	-- Write.
	file.Write("citrus/"..File, citrus.Serialise.Serialise(Table))
end

-- Table Load.
function citrus.Utilities.TableLoad(File)
	if (file.Exists("citrus/"..File)) then
		return citrus.Serialise.Deserialise(file.Read("citrus/"..File))
	end
	
	-- Return False.
	return false
end

-- Duplicate Entity.
function citrus.Utilities.DuplicateEntity(Player, Entity)
	local Entities = duplicator.Paste(Player, {duplicator.CopyEntTable(Entity)}, {})
	
	-- For Loop.
	local _, Copy = next(Entities)
	
	-- Return Copy.
	return Copy
end
