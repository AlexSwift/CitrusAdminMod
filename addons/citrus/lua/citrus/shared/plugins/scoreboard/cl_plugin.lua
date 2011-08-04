--[[
Name: "cl_plugin.lua".
Product: "Citrus (Server Management)".
--]]

local PLUGIN = citrus.Plugin:New("Scoreboard")

function PLUGIN:OnLoad()
	SuiScoreBoard = nil
		
	function GAMEMODE:CreateScoreboard()
	
		if ( ScoreBoard ) then
			ScoreBoard:Remove()
			ScoreBoard = nil
		end
		
		SuiScoreBoard = vgui.Create( "SuiScoreBoard" )
		
		return true
	end
	
	function GAMEMODE:ScoreboardShow()
	
		if not SuiScoreBoard then
			self:CreateScoreboard()
		end
		
		GAMEMODE.ShowScoreboard = true
		gui.EnableScreenClicker( true )
		SuiScoreBoard:SetVisible( true )
		SuiScoreBoard:UpdateScoreboard( true )
		
		return true
	end
	
	function GAMEMODE:ScoreboardHide()
	
		GAMEMODE.ShowScoreboard = false
		gui.EnableScreenClicker( false )
		SuiScoreBoard:SetVisible( false )
		
		return true
	end

end

citrus.Utilities.IncludeDirectory(PLUGIN.FilePath.."/scoreboard/", "cl_", ".lua")