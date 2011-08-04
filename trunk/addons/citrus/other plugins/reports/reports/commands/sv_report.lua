--[[
Name: "sv_report.lua".
Product: "Citrus (Server Management)".
--]]

local COMMAND = citrus.Command:New("report", false, {{"Text", "string"}})

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Reports")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- Callback.
function COMMAND.Callback(Player, Arguments)
	if (Arguments[1] == "") then
		citrus.Player.Notify(Player, "Unable to write report without text!", 1)
		
		-- Return.
		return
	end
	
	-- Report.
	local Report = {
		Name = Player:Name(),
		SteamID = Player:SteamID(),
		Text = Arguments[1],
		Date = os.date("%d-%m-%y"),
		Time = os.date("%X"),
		Status = "Active"
	}
	
	-- Insert.
	PLUGIN.MySQL.Insert(Report)
	
	-- Notify.
	citrus.Player.Notify(Player, "Report is written. Visit http://connacook.com/reports/.", 0)
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Standalone Commands", "Report", {{"Text", citrus.QuickMenu.GetText}})

-- Create.
COMMAND:Create()