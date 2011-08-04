--[[
Name: "sv_restricttools.lua".
Product: "Citrus (Server Management)".
--]]

local COMMAND = citrus.Command:New("restricttools", "S")

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Restrict Tools")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- Callback.
function COMMAND.Callback(Player, Arguments)
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Restrict Tools")
	Menu:SetIcon("gui/silkicons/shield")
	Menu:SetReference(COMMAND.Callback)
	
	-- For Loop.
	for K, V in pairs(PLUGIN.Categories) do
		Menu:ButtonAdd(V, function() COMMAND.Category(Player, V) end)
	end
	
	-- Check Categories.
	if (#PLUGIN.Categories == 0) then Menu:TextAdd("Unable to locate categories!") end
	
	-- Send.
	Menu:Send()
end

-- Category.
function COMMAND.Category(Player, Category)
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Restrict Tools ("..Category..")")
	Menu:SetIcon("gui/silkicons/shield")
	Menu:SetReference(COMMAND.Category, Category)
	
	-- Button Add.
	Menu:ButtonAdd("Restrict All", function() COMMAND.RestrictAll(Player, Category) end)
	Menu:ButtonAdd("Unrestrict All", function() COMMAND.UnrestrictAll(Player, Category) end)
	
	-- Success.
	local Success = false
	
	-- For Loop.
	for K, V in pairs(PLUGIN.Tools) do
		if (V.Category == Category) then
			Menu:ButtonAdd(V.Name, function() COMMAND.Tool(Player, V.Key, V) end)
			
			-- Success.
			Success = true
		end
	end
	
	-- Check Success.
	if (!Success) then Menu:TextAdd("Unable to locate tools!") end
	
	-- Send.
	Menu:Send()
end

-- Unrestrict All.
function COMMAND.UnrestrictAll(Player, Category)
	for K, V in pairs(PLUGIN.Tools) do
		if (V.Category == Category) then
			local Name = V.Key
			
			-- Name.
			PLUGIN.Configuration[Name] = nil
		end
	end
end

-- Restrict All.
function COMMAND.RestrictAll(Player, Category)
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Restrict All ("..Category..")")
	Menu:SetIcon("gui/silkicons/shield")
	Menu:SetReference(COMMAND.RestrictAll, Category)
	
	-- New.
	local New = true
	
	-- Callback.
	local function Callback(Access, Value)
		for K, V in pairs(PLUGIN.Tools) do
			if (V.Category == Category) then
				local Name = V.Key
				
				-- Check New.
				if (New or !PLUGIN.Configuration[Name]) then
					PLUGIN.Configuration[Name] = ""
				end
				
				-- Check Find.
				if (string.find(PLUGIN.Configuration[Name], Access)) then
					if (!Value) then
						PLUGIN.Configuration[Name] = string.gsub(PLUGIN.Configuration[Name], Access, "")
					end
				else
					if (Value) then
						PLUGIN.Configuration[Name] = PLUGIN.Configuration[Name]..Access
					end
				end
				
				-- Check Name.
				if (PLUGIN.Configuration[Name] == "") then PLUGIN.Configuration[Name] = nil end
			end
		end
		
		-- New.
		New = false
	end
	
	-- For Loop.
	for K, V in pairs(citrus.Access.Stored) do
		Menu:CheckBoxAdd(K.." ("..V..")", function(Player, Value)
			Callback(K, Value)
		end, false)
	end
	
	-- Send.
	Menu:Send()
end

-- Tool.
function COMMAND.Tool(Player, Name, Tool)
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Restrict Tool ("..Tool.Name..")")
	Menu:SetIcon("gui/silkicons/shield")
	Menu:SetReference(COMMAND.Tool, Name, Tool)
	
	-- Callback.
	local function Callback(Access, Value)
		PLUGIN.Configuration[Name] = PLUGIN.Configuration[Name] or ""
		
		-- Check Find.
		if (string.find(PLUGIN.Configuration[Name], Access)) then
			if (!Value) then
				PLUGIN.Configuration[Name] = string.gsub(PLUGIN.Configuration[Name], Access, "")
			end
		else
			if (Value) then
				PLUGIN.Configuration[Name] = PLUGIN.Configuration[Name]..Access
			end
		end
		
		-- Check Name.
		if (PLUGIN.Configuration[Name] == "") then PLUGIN.Configuration[Name] = nil end
	end
	
	-- For Loop.
	for K, V in pairs(citrus.Access.Stored) do
		local Value = (PLUGIN.Configuration[Name] and string.find(PLUGIN.Configuration[Name], K))
		
		-- Check Box Add.
		Menu:CheckBoxAdd(K.." ("..V..")", function(Player, Value)
			Callback(K, Value)
		end, Value)
	end
	
	-- Send.
	Menu:Send()
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Plugin Configuration", "Restrict Tools")

-- Create.
COMMAND:Create()