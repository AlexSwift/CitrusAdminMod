--[[
Name: "sh_serialise.lua".
Product: "Citrus (Server Management)"
--]]

citrus.Serialise = {}

-- Serialise Value.
function citrus.Serialise.SerialiseValue(Value, SubTables, Index)
	local Type = type(Value)
	
	-- Type.
	Type = string.lower(Type)

	-- Check Type.
	if (Type == "number") then
		return "Number:"..Value
	elseif (Type == "string") then
		Value = string.Replace(Value, "{", "<"..Index.."1>")
		Value = string.Replace(Value, "}", "<"..Index.."2>")
		Value = string.Replace(Value, ";", "<"..Index.."3>")
		Value = string.Replace(Value, ":", "<"..Index.."4>")
		Value = string.Replace(Value, "=", "<"..Index.."5>")
		
		-- Return format.
		return string.format("String:%q", Value)
	elseif (Type == "boolean") then
		return "Boolean:"..tostring(Value)
	elseif (Type == "entity") then
		if (GetWorldEntity() == Value) then
			return "Entity:World"
		elseif (Value == NULL) then
			return "Entity:Null"
		else
			return "Entity:"..Value:EntIndex()
		end
	elseif (Type == "vector") then
		return string.format("Vector:%g,%g,%g", Value.x, Value.y, Value.z)
	elseif (Type == "angle") then
		return string.format("Angle:%g,%g,%g", Value.pitch, Value.yaw, Value.roll)
	elseif (Type == "player") then
		return "Player:"..citrus.Player.GetUniqueID(Value)
	elseif (Type == "table") then
		local Name = string.sub(tostring(Value), 8)
		
		-- Check Sub Tables.
		if (!SubTables[Name]) then
			SubTables[Name] = citrus.Serialise.SerialiseTableKeyValues(Value, SubTables, Name)
		end
		
		-- Return String.
		return "Table:"..Name
	end
end

-- Deserialise String.
function citrus.Serialise.DeserialiseString(String, SubTables, Index)
	local Type, Value = string.match(String, "(.-):(.+)")
	
	-- Check Type.
	if (Type == "Number") then
		return tonumber(Value)
	elseif (Type == "String") then
		Value = string.Replace(Value, "<"..Index.."1>", "{")
		Value = string.Replace(Value, "<"..Index.."2>", "}")
		Value = string.Replace(Value, "<"..Index.."3>", ";")
		Value = string.Replace(Value, "<"..Index.."4>", ":")
		Value = string.Replace(Value, "<"..Index.."5>", "=")
		Value = string.Replace(Value, "["..Index.."][!]", "{")
		Value = string.Replace(Value, "["..Index.."][#]", "}")
		Value = string.Replace(Value, "["..Index.."][%]", ";")
		Value = string.Replace(Value, "["..Index.."][&]", ":")
		Value = string.Replace(Value, "["..Index.."][$]", "=")
		
		-- Return sub.
		return string.sub(Value, 2, -2)
	elseif (Type == "Boolean") then
		return Value == "true"
	elseif (Type == "Entity") then
		if (Value == "World") then
			return GetWorldEntity()
		elseif (Value == "Null") then
			return NULL
		else
			return Entity(Value)
		end
	elseif (Type == "Vector") then
		local X, Y, Z = string.match(Value, "(.-),(.-),(.+)")
		
		-- Return Vector.
		return Vector(X, Y, Z)
	elseif (Type == "Angle") then
		local P, Y, R = string.match(Value, "(.-),(.-),(.+)")
		
		-- Return Angle.
		return Angle(P, Y, R)
	elseif (Type == "Player") then
		local Players = player.GetAll()
		
		-- For Loop.
		for K, V in pairs(Players) do
			if (citrus.Player.GetUniqueID(V) == Value) then
				return V
			end
		end
	elseif (Type == "Table") then 
		local Table = {}
		
		-- Check Value.
		if (!SubTables[Value]) then SubTables[Value] = {} end
		
		-- Value.
		SubTables[Value][#SubTables[Value] + 1] = Table
		
		-- Return Table.
		return Table
	end
end

-- Serialise Table Key Values.
function citrus.Serialise.SerialiseTableKeyValues(Table, SubTables, Index)
	local Temporary = {}
	
	-- Keys.
	local Keys = !table.IsSequential(Table)
	
	-- For Loop.
	for K, V in pairs(Table) do
		local String = citrus.Serialise.SerialiseValue(V, SubTables, Index)
		
		-- Check Keys.
		if (Keys and String) then String = citrus.Serialise.SerialiseValue(K, SubTables, Index).."="..String end
		
		-- Temporary.
		Temporary[#Temporary + 1] = String
	end

	-- Return Temporary.
	return Temporary
end

-- Serialise.
function citrus.Serialise.Serialise(Table)
	local SubTables = {}
	local String = ""

	-- Index.
	local Index = string.sub(tostring(Table), 8)
	local Head = citrus.Serialise.SerialiseTableKeyValues(Table, SubTables, Index)

	-- Index.
	SubTables[Index] = nil
	SubTables["Head:"..Index] = Head
	
	-- For Loop.
	for K, V in pairs(SubTables) do String = String..K.."{"..table.concat(V, ";")..";}" end

	-- Return String.
	return String
end

-- Deserialise.
function citrus.Serialise.Deserialise(String)
	local SubTables	= {}
	local Table = {}
	local Head = nil
	
	-- For Loop.
	for K, V in string.gmatch(String, "(.-){(.-)}") do
		if (string.sub(K, 1, 5) == "Head:") then
			K = string.sub(K, 6)
			
			-- Head.
			Head = K
		end
		
		-- Tables.
		Table[K] = {}
		
		-- For Loop.
		for K2, V2 in string.gmatch(V, "(.-);") do
			local K3, V3 = string.match(K2, "(.-)=(.+)")
			
			-- Check K3.
			if (!K3) then
				V3 = citrus.Serialise.DeserialiseString(K2, SubTables, K)
				
				-- K.
				Table[K][#Table[K] + 1] = V3
			else
				K3 = citrus.Serialise.DeserialiseString(K3, SubTables, K)
				V3 = citrus.Serialise.DeserialiseString(V3, SubTables, K)
				
				-- K3.
				Table[K][K3] = V3
			end
		end
	end

	-- For Loop.
	for K, V in pairs(SubTables) do
		for K2, V2 in pairs(V) do table.Merge(V2, Table[K]) end
	end

	-- Return Table.
	return Table[Head]
end