--[[
Name: "sv_access.lua".
Product: "Citrus (Server Management)".
--]]

citrus.Access = {}
citrus.Access.Stored = {}

-- Add.
function citrus.Access.Add(Access, Name) citrus.Access.Stored[Access] = Name end

-- Remove.
function citrus.Access.Remove(Access) citrus.Access.Stored[Access] = nil end

-- Exists.
function citrus.Access.Exists(Access) return (citrus.Access.Stored[Access] != nil) end

-- Get Name.
function citrus.Access.GetName(Access, Seperator)
	if (string.len(Access) == 1) then
		return citrus.Access.Stored[Access] or "N/A"
	else
		local Names = {}
		
		-- For Loop.
		for I = 1, string.len(Access) do
			local Name = string.sub(Access, I, I)
			
			-- Names.
			Names[#Names + 1] = citrus.Access.Stored[Name] or "N/A"
		end
		
		-- String.
		local String = table.concat(Names, " "..(Seperator or ", "))
		
		-- Check String.
		if (String == "") then return "N/A" else return String end
	end
end

-- Has.
function citrus.Access.Has(Player, Access)
	if (Access == "") then return true end
	
	-- Check Sub.
	if (string.sub(Access, 1, 1) == "!") then
		return !citrus.Access.Has(Player, string.sub(Access, 2))
	end
	
	-- Check Len.
	if (string.len(Access) == 1) then
		if (!citrus.Access.Exists(Access)) then return false end
		
		-- Check Find.
		if (string.find(citrus.PlayerVariables.Get(Player, "Access").Custom, Access)
		or string.find(citrus.PlayerVariables.Get(Player, "Access").Group, Access)) then
			return true
		end
	else
		for I = 1, string.len(Access) do
			if (citrus.Access.Has(Player, string.sub(Access, I, I))) then return true end
		end
	end
	
	-- Return False.
	return false
end

-- Give.
function citrus.Access.Give(Player, Access)
	if (string.len(Access) > 1) then
		for I = 1, string.len(Access) do
			local Character = string.sub(Access, I, I)
			
			-- Success, Error.
			local Success, Error = citrus.Access.Give(Player, Character)
			
			-- Check Success.
			if (!Success) then return false, Error end
		end
		
		-- Return True.
		return true, ""
	end
	
	-- Check Exists.
	if (!citrus.Access.Exists(Access)) then return false, "Unable to locate access '"..Access.."'!" end
	if (citrus.Access.Has(Player, Access)) then return false, "Unable to give access twice!" end
	
	-- Custom.
	citrus.PlayerVariables.Get(Player, "Access").Custom = citrus.PlayerVariables.Get(Player, "Access").Custom..Access
	
	-- Call.
	citrus.Hooks.Call("OnPlayerAccessGiven", Player, Access)
	
	-- Return True.
	return true, ""
end

-- Take.
function citrus.Access.Take(Player, Access)
	if (string.len(Access) == 1) then	
		if (string.find(citrus.PlayerVariables.Get(Player, "Access").Custom, Access)) then
			citrus.PlayerVariables.Get(Player, "Access").Custom = string.Replace(citrus.PlayerVariables.Get(Player, "Access").Custom, Access, "")
			
			-- Call.
			citrus.Hooks.Call("OnPlayerAccessTaken", Player, Access)
			
			-- Return True.
			return true, ""
		else
			return false, "Unable to take access '"..Access.."'!"
		end
	else
		for I = 1, string.len(Access) do
			local Character = string.sub(Access, I, I)
			
			-- Success.
			local Success, Error = citrus.Access.Take(Player, Character)
			
			-- Check Success.
			if (!Success) then return false, Error end
		end
		
		-- Return True.
		return true, ""
	end
	
	-- Return False.
	return false, ""
end

-- On Player Set Group.
function citrus.Access.OnPlayerSetGroup(Player, Group)
	citrus.PlayerVariables.Get(Player, "Access").Group = Group:GetSetting("Access")
end

-- Add.
citrus.Hooks.Add("OnPlayerSetGroup", citrus.Access.OnPlayerSetGroup)

-- On Player Set Variables.
function citrus.Access.OnPlayerSetVariables(Player)
	citrus.PlayerVariables.New(Player, "Access", {Command = {}, Group = "", Custom = ""})
end

-- Add.
citrus.Hooks.Add("OnPlayerSetVariables", citrus.Access.OnPlayerSetVariables)