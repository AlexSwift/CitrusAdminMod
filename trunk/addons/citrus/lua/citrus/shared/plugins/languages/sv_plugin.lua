--[[
Name: "sv_plugin.lua".
Product: "Citrus (Server Management)".
--]]

local PLUGIN = citrus.Plugin:New("Languages")

-- Gamemode.
PLUGIN.Settings.Description = "Players can create, learn, and speak in different languages"
PLUGIN.Settings.Author = "Conna"

-- Languages.
PLUGIN.Languages = citrus.Utilities.TableLoad("plugins/languages.txt") or {}

-- On Player Set Variables.
function PLUGIN.OnPlayerSetVariables(Player)
	citrus.PlayerVariables.New(Player, "Languages", {Known = {Common = "Common"}, Language = "Common"})
	
	-- Languages.
	local Languages = citrus.PlayerVariables.Get(Player, "Languages")
	
	-- For Loop.
	for K, V in pairs(Languages.Known) do
		if (!PLUGIN.Languages[K]) then
			Languages.Known[K] = nil
			
			-- Check Language.
			if (Languages.Langauge == K) then Languages.Language = "Common" end
		end
	end
end

-- On Player Say.
function PLUGIN.OnPlayerSay(Player, Text)
	local Languages = citrus.PlayerVariables.Get(Player, "Languages")
	
	-- Check Language.
	if (Languages.Language != "Common") then
		citrus.PlayerEvents.Allow(Player, "Languages", citrus.PlayerEvent.Say, false)
		
		-- Exploded.
		local Exploded = string.Explode(" ", Text)
		
		-- For Loop.
		for K2, V2 in pairs(Exploded) do
			local String = ""
			
			-- For Loop.
			for I = 1, string.len(V2) do
				local Character = string.sub(V2, I, I)
				
				-- Check Character.
				if (Character == "A" or Character == "a"
				or Character == "E" or Character == "e"
				or Character == "I" or Character == "i"
				or Character == "O" or Character == "o"
				or Character == "U" or Character == "u") then
					if (Character == "A") then String = String.."E" end
					if (Character == "a") then String = String.."e" end
					if (Character == "E") then String = String.."I" end
					if (Character == "e") then String = String.."i" end
					if (Character == "I") then String = String.."O" end
					if (Character == "i") then String = String.."o" end
					if (Character == "O") then String = String.."U" end
					if (Character == "o") then String = String.."u" end
					if (Character == "U") then String = String.."A" end
					if (Character == "u") then String = String.."a" end
				else
					if (string.byte(Character) >= 65 and string.byte(Character) <= 90) then
						String = String..string.char(math.random(65, 90))
					elseif (string.byte(Character) >= 97 and string.byte(Character) <= 122) then
						String = String..string.char(math.random(97, 122))
					else
						String = String..Character
					end
				end
			end
			
			-- K2.
			Exploded[K2] = String
		end
		
		-- Real Text.
		local RealText = Text
		local FakeText = table.concat(Exploded, " ")
		
		-- Players.
		local Players = player.GetAll()
		
		-- For Loop.
		for K, V in pairs(Players) do
			if (table.HasValue(citrus.PlayerVariables.Get(V, "Languages").Known, Languages.Language)) then
				citrus.Player.Notify(V, "("..Languages.Language..") "..Player:Name()..": "..RealText)
			else
				citrus.Player.Notify(V, "("..Languages.Language..") "..Player:Name()..": "..FakeText)
			end
		end
	else
		citrus.PlayerEvents.Allow(Player, "Languages", citrus.PlayerEvent.Say, true)
	end
end

-- Include Directory.
citrus.Utilities.IncludeDirectory(PLUGIN.FilePath.."/commands/", "sv_", ".lua")