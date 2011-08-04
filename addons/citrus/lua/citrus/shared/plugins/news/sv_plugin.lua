--[[
Name: "sv_plugin.lua".
Product: "Citrus (Server Management)"
--]]

require("http")

-- PLUGIN.
local PLUGIN = citrus.Plugin:New("News")

-- Description.
PLUGIN.Settings.Description = "Citrus news is displayed to administrators"
PLUGIN.Settings.Author = "Conna"

-- On Player Initial Spawn.
function PLUGIN.OnPlayerInitialSpawn(Player)
	if (citrus.Access.Has(Player, "A")) then
		local Callback = citrus.Menus.CallbackAdd(PLUGIN.Display)
		
		-- Usermessage Call.
		PLUGIN:UsermessageCall("Display", Player, function() umsg.String(Callback) end)
	end
end

-- Display
function PLUGIN.Display(Player)
	http.Get("http://kudomiku.com/citrus/news.txt", "", function(Contents, Size)
		if (Contents and Contents != "") then
			local Menu = citrus.Menu:New()
			
			-- Set Player.
			Menu:SetPlayer(Player)
			Menu:SetTitle("News")
			Menu:SetIcon("gui/silkicons/page")
			Menu:SetReference(PLUGIN.Display)
			
			-- Contents.
			Contents = string.gsub(Contents, "%#(.-)%#", function(String) return math.Round(GetConVarNumber(String)) end)
			Contents = string.gsub(Contents, "%%(.-)%%", function(String) return GetConVarString(String) end)
			Contents = string.gsub(Contents, "%{(.-)%}", function(String)
				return tostring(citrus.Utilities.GetVariable(String))
			end)
			
			-- Control Add.
			Menu:ControlAdd("Markup Text", {Text = "<font=citrus_MainText>"..Contents.."</font>"})
			Menu:ControlAdd("Check Box", {Text = "Display News", Command = "cl_citrus_news", Value = (Player:GetInfoNum("cl_citrus_news", 1) == 1)})
			
			-- Send.
			Menu:Send()
		end
	end)
end