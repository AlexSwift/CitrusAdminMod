--[[
Name: "sh_parseini.lua".
Product: "Citrus (Server Management)"
--]]

citrus.ParseINI = {}

-- Load.
function citrus.ParseINI:New(File)
	local Table = {}
	
	-- Set Meta Table.
	setmetatable(Table, self)
	
	-- Index.
	self.__index = self
	
	-- File.
	Table.File = file.Read("../"..File) or ""

	-- Return Table.
	return Table
end

-- Get Value.
function citrus.ParseINI:GetValue(Block, Key)
	local Results = self:Parse()
	
	-- For Loop.
	for K, V in pairs(Results) do
		if (K == Block) then
			for K2, V2 in pairs(V) do
				if (K2 == Key) then return V2 end
			end
		end
	end
	
	-- Return String.
	return ""
end

-- Get Block.
function citrus.ParseINI:GetBlock(Block)
	local Results = self:Parse()
	
	-- For Loop.
	for K, V in pairs(Results) do if (K == Block) then return V end end
	
	-- Return Table.
	return {}
end

-- Parse.
function citrus.ParseINI:Parse()
	if (self.Results) then return self.Results end
	
	-- Results.
	self.Results = {}
	
	-- Current.
	local Current = ""
	local Exploded = string.Explode("\n", self.File)
	
	-- For Loop.
	for K, V in pairs(Exploded) do
		if (string.sub(V, 1, 1) != "#") then
			local Line = string.Trim(V)
			
			-- Check Line.
			if (Line != "") then
				if (string.sub(Line, 1, 1) == "[") then
					local End = string.find(Line, "%]")
					
					-- Check End.
					if (End) then
						local Block = string.sub(Line, 2, End - 1)
						
						-- Results.
						self.Results[Block] = self.Results[Block] or {}
						
						-- Current.
						Current = Block
					end
				else
					self.Results[Current] = self.Results[Current] or {}
					
					-- Check Current.
					if (Current != "") then
						Line = string.Explode("=", Line)
						
						-- Check Count.
						if (table.Count(Line) == 2) then
							local Key = string.Trim(Line[1])
							local Value = string.Trim(Line[2])
							
							-- Value.
							Value = citrus.Utilities.GetStringValue(Value)
							
							-- Key.
							self.Results[Current][Key] = Value
						elseif (table.Count(Line) == 1) then
							local Value = string.Trim(Line[1])
							
							-- Value.
							Value = citrus.Utilities.GetStringValue(Value)
							
							-- Current.
							self.Results[Current][#self.Results[Current] + 1] = Value
						end
					end
				end
			end
		end
	end
	
	-- Return Results.
	return self.Results
end