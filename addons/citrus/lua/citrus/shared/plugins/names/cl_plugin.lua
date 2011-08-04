--[[
Name: "cl_plugin.lua".
Product: "Citrus (Server Management)".
--]]

local PLUGIN = citrus.Plugin:New("Names")

-- Pixel Visible Handle.
PLUGIN.PixelVisibleHandle = util.GetPixelVisibleHandle()

-- On Draw Player.
function PLUGIN.OnDrawPlayer(Player)
	if (Player:Alive() and Player:GetMoveType() != MOVETYPE_OBSERVER) then
		if (util.PixelVisible(Player:GetPos(), 16, PLUGIN.PixelVisibleHandle)) then
			local Alpha = citrus.Utilities.GetAlphaFromDistance(Player, LocalPlayer(), 2048)
			
			-- Name.
			local Name = Player:Name()
			
			-- Position.
			local Position = Player:GetShootPos():ToScreen()
			local X, Y = Position.x, Position.y - 32
			
			-- Position.
			local Position = LocalPlayer():GetShootPos()
			
			-- Y (Thank you foszor).
			Y = Y + (32 * (Player:GetShootPos():Distance(Position) / 2048)) * 0.5
			
			-- Background Color.
			local BackgroundColor = citrus.Themes.GetColor("Background")
			local CornerSize = citrus.Themes.GetSize("Corner")
			local TeamColor = citrus.Utilities.GetTeamColor(Player)
			
			-- Background Color.
			BackgroundColor = Color(BackgroundColor.r, BackgroundColor.g, BackgroundColor.b, math.Clamp(Alpha, 0, BackgroundColor.a))
			TeamColor = Color(TeamColor.r, TeamColor.g, TeamColor.b, math.Clamp(Alpha, 0, TeamColor.a))
			
			-- Rounded Text Box.
			local tbl = Player:Name()
			local title = citrus.PlayerInformation.Get(Player, "Public", "Title")
			if title != nil and title != "" then
				tbl = {Player:Name(), title}
			end
			citrus.Draw.RoundedTextBox(tbl, "citrus_MainText", TeamColor, X, Y, CornerSize, BackgroundColor, false, false, true, true)
		end
	end
end