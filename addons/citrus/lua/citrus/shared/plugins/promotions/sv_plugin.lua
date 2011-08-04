--[[
Name: "sv_plugin.lua".
Product: "Citrus (Server Management)".
--]]

local PLUGIN = citrus.Plugin:New("Promotions")

-- Description.
PLUGIN.Settings.Description = "Players are promoted to new groups after time"
PLUGIN.Settings.Author = "Conna"

-- Configuration.
PLUGIN.Configuration = citrus.ParseINI:New("lua/"..PLUGIN.FilePath.."/sv_configuration.ini"):Parse()["Promotions"]

-- On Load.
function PLUGIN:OnLoad()
	local Configuration = citrus.Utilities.TableLoad("plugins/promotions.txt") or {}
	
	-- Merge.
	table.Merge(PLUGIN.Configuration, Configuration)

	-- For Loop.
	for K, V in pairs(citrus.Groups.Stored) do
		if (PLUGIN.Configuration[V.Name]) then
			V:SetSetting("Promotion", PLUGIN.Configuration[V.Name].." Hour(s)")
		end
	end

	-- For Loop.
	for K, V in pairs(PLUGIN.Configuration) do
		if (!citrus.Groups.Get(K)) then PLUGIN.Configuration[K] = nil end
	end
end

-- On Save Variables.
function PLUGIN.OnSaveVariables()
	citrus.Utilities.TableSave("plugins/promotions.txt", PLUGIN.Configuration)
end

-- On Player Minute.
function PLUGIN.OnPlayerMinute(Player)
	local Group = false
	
	-- For Loop.
	for K, V in pairs(PLUGIN.Configuration) do
		if (citrus.Groups.Get(K)) then
			local TimePlayed = citrus.PlayerVariables.Get(Player, "Time Played")
			
			-- Check Hours.
			if (TimePlayed.Hours >= V) then
				if (citrus.Player.GetGroup(Player):GetSetting("Rank") > citrus.Groups.Get(K):GetSetting("Rank")) then
					if (!Group or V > Group[2]) then Group = {citrus.Groups.Get(K), V} end
				end
			end
		end
	end
	
	-- Check Group.
	if (Group) then
		citrus.Player.NotifyAll(Player:Name().." is promoted to "..Group[1].Name..".", 0)
		
		-- Set.
		citrus.Groups.Set(Player, Group[1])
	end
end

-- Include Directory.
citrus.Utilities.IncludeDirectory(PLUGIN.FilePath.."/commands/", "sv_", ".lua")