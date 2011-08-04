--[[
Name: "sv_plugin.lua".
Product: "Citrus (Server Management)".
--]]

local PLUGIN = citrus.Plugin:New("Restrict Tools")

-- Description.
PLUGIN.Settings.Description = "Tools can be restricted from use"
PLUGIN.Settings.Gamemode = {"Sandbox", true}
PLUGIN.Settings.Author = "Conna"

-- Configuration.
PLUGIN.Configuration = citrus.ParseINI:New("lua/"..PLUGIN.FilePath.."/sv_configuration.ini"):Parse()["Restrict Tools"]
PLUGIN.Categories = {}
PLUGIN.Tools = {}

-- On Load.
function PLUGIN:OnLoad()
	local Configuration = citrus.Utilities.TableLoad("plugins/restricttools.txt") or {}
	
	-- Merge.
	table.Merge(PLUGIN.Configuration, Configuration)
	
	-- Check Initialized.
	if (!PLUGIN.Initialized) then
		PLUGIN.Initialized = true
		
		-- Tool.
		local Tool = weapons.GetStored("gmod_tool")
		
		-- Check Tool.
		if (!Tool or !Tool.Tool) then return false end
		
		-- For Loop.
		for K, V in pairs(Tool.Tool) do
			if (V.Name) then
				if (V.Category != "My Category") then
					local Tool = table.Copy(V)
					
					-- Key.
					Tool.Key = string.lower(K)
					Tool.Name = string.gsub(V.Name, "#", "")
					Tool.Name = string.gsub(Tool.Name, "(%u)", " %1")
					Tool.Name = string.gsub(Tool.Name, "  ", " ")
					Tool.Name = string.Trim(Tool.Name)
					
					-- Check Has Value.
					if (!table.HasValue(PLUGIN.Categories, V.Category)) then
						table.insert(PLUGIN.Categories, V.Category)
					end
					
					-- Insert.
					table.insert(PLUGIN.Tools, Tool)
				end
			end
		end
		
		-- Sort.
		table.sort(PLUGIN.Tools, function(A, B) return A.Name < B.Name end)
		table.sort(PLUGIN.Categories, function(A, B) return A < B end)
	end
end

-- On Save Variables.
function PLUGIN.OnSaveVariables()
	citrus.Utilities.TableSave("plugins/restricttools.txt", PLUGIN.Configuration)
end

-- On Player Second.
function PLUGIN.OnPlayerSecond(Player)
	local Tool = Player:GetInfo("gmod_toolmode")
	
	-- Check Tool.
	for K, V in pairs(PLUGIN.Configuration) do
		if (string.lower(Tool) == string.lower(K)) then
			if (!citrus.Access.Has(Player, V)) then
				citrus.Player.Notify(Player, citrus.Access.GetName(V, "or").." access required!", 1)
				
				-- Console Command.
				citrus.Player.ConsoleCommand(Player, "gmod_toolmode \"\"")
				
				-- Return False.
				return false
			end
		end
	end
end

-- Can Tool.
function PLUGIN.CanTool(Player, Trace, Tool)
	if (Tool) then
		for K, V in pairs(PLUGIN.Configuration) do
			if (string.lower(Tool) == string.lower(K)) then
				if (!citrus.Access.Has(Player, V)) then
					citrus.Player.Notify(Player, citrus.Access.GetName(V, "or").." access required!", 1)
					
					-- Return False.
					return false
				end
			end
		end
	end
end

-- Hook Add.
PLUGIN:HookAdd("CanTool", PLUGIN.CanTool)

-- Include Directory.
citrus.Utilities.IncludeDirectory(PLUGIN.FilePath.."/commands/", "sv_", ".lua")