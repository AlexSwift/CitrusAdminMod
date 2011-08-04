--[[
Name: "sv_reports.lua".
Product: "Citrus (Server Management)".
--]]

local COMMAND = citrus.Command:New("reports", "M")

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Reports")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- Callback.
function COMMAND.Callback(Player, Arguments)
	PLUGIN.MySQL.Query("SELECT * FROM "..PLUGIN.Configuration["Table"].." WHERE _Status = 'Active' ORDER BY _Key DESC", function(Table)
		if (type(Table) == "table") then
			local Menu = citrus.Menu:New()
			
			-- Set Player.
			Menu:SetPlayer(Player)
			Menu:SetTitle("Reports")
			Menu:SetIcon("gui/silkicons/page")
			Menu:SetUpdate(COMMAND.Callback)
			Menu:SetReference(COMMAND.Callback)
			
			-- Check Table.
			if (#Table > 0) then
				for K, V in pairs(Table) do	
					Menu:ButtonAdd(V[7]..". "..V[4].." ("..V[5]..")", function() COMMAND.Report(Player, V) end)
				end
			else
				Menu:TextAdd("Unable to locate reports!")
			end
			
			-- Send.
			Menu:Send()
		else
			citrus.Player.Notify(Player, "Unable to connect to database!", 1)
		end
	end)
	
	-- Notify.
	citrus.Player.Notify(Player, "Now downloading reports from database.")
end

-- Report.
function COMMAND.Report(Player, Report)
	local Menu = citrus.Menu:New()
	
	-- Title.
	local Title = Report[7]..". "..Report[4].." ("..Report[5]..")"
	
	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Report ("..Title..")")
	Menu:SetIcon("gui/silkicons/page")
	Menu:SetReference(COMMAND.Report, Report[7])
	
	-- Text.
	local Text = citrus.Utilities.Split(Report[3], 50)
	
	-- Text Add.
	Menu:TextAdd("Name: "..Report[1]..".")
	Menu:TextAdd("Steam ID: "..Report[2]..".")
	Menu:TextAdd("Text: "..Text[1]..".")
	
	-- For Loop.
	for K, V in pairs(Text) do
		if (K > 1) then Menu:TextAdd(V) end
	end
	
	-- Button Add.
	Menu:ButtonAdd("Closed", function()
		PLUGIN.MySQL.Query("UPDATE Reports SET _Status = 'Closed' WHERE _Key = "..Report[7])
		
		-- Update.
		citrus.Menus.Update(nil, COMMAND.Callback)
		
		-- Notify.
		citrus.Player.Notify(Player, "Report '"..Title.."' closed.")
	end, {Discontinue = true})

	-- Button Add.
	Menu:ButtonAdd("Resolved", function()
		PLUGIN.MySQL.Query("UPDATE Reports SET _Status = 'Resolved' WHERE _Key = "..Report[7])
		
		-- Update.
		citrus.Menus.Update(nil, COMMAND.Callback)
		
		-- Notify.
		citrus.Player.Notify(Player, "Report '"..Title.."' resolved.")
	end, {Discontinue = true})
	
	-- Send.
	Menu:Send()
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Server Management", "Reports")

-- Create.
COMMAND:Create()