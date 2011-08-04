--[[
Name: "cl_notices.lua".
Product: "Citrus (Server Management)".
--]]

-- Notices.
citrus.Notices = {}
citrus.Notices.Stored = {}
citrus.Notices.TextureIDs = {}
citrus.Notices.TextureIDs[0] = surface.GetTextureID("vgui/notices/generic")
citrus.Notices.TextureIDs[1] = surface.GetTextureID("vgui/notices/error")
citrus.Notices.TextureIDs[2] = surface.GetTextureID("vgui/notices/undo")
citrus.Notices.TextureIDs[3] = surface.GetTextureID("vgui/notices/hint")
citrus.Notices.TextureIDs[4] = surface.GetTextureID("vgui/notices/cleanup")

-- Add.
function citrus.Notices.Add(Text, Type, Time)
	local Table = {}
	
	-- Table.
	Table.Velocity = {X = -5, Y = 0}
	Table.Start = RealTime()
	Table.Type = Type
	Table.Time = Time
	Table.Text = Text
	Table.X = ScrW() + 200
	Table.Y = ScrH()
	
	-- Stored.
	citrus.Notices.Stored[#citrus.Notices.Stored + 1] = Table
	
	-- Sound.
	local Sound = "ambient/water/drip2.wav"
	
	-- Check Type.
	if (Type == 1) then
		Sound = "buttons/button10.wav"
	elseif (Type == 2) then
		Sound = "buttons/button17.wav"
	elseif (Type == 3) then
		Sound = "buttons/bell1.wav"
	elseif (Type == 4) then
		Sound = "buttons/button15.wav"
	end
	
	-- Play Sound.
	surface.PlaySound(Sound)
end

-- Draw.
function citrus.Notices.Draw(Table, Position)
	local Height = ScrH() / 1024
	local X = Table.X - 75 * Height
	local Y = Table.Y - 300 * Height
	
	-- Check Width.
	if (!Table.Width) then
		surface.SetFont("citrus_MainText")
		
		-- Width.
		Table.Width, Table.Height = surface.GetTextSize(Table.Text)
	end
	
	-- Width.
	local Width, Height = Table.Width + 16, Table.Height + 16
	
	-- Background Color.
	local BackgroundColor = citrus.Themes.GetColor("Background")
	local TextColor = citrus.Themes.GetColor("Text")
	local CornerSize = citrus.Themes.GetSize("Corner")
	
	-- Rounded Box.
	draw.RoundedBox(CornerSize, X - Width - Height + 8, Y - 8, Width + Height, Height, BackgroundColor)
	
	-- Set Draw Color.
	surface.SetDrawColor(0, 0, 0, 50)
	surface.SetTexture(citrus.Notices.TextureIDs[Table.Type])
	surface.DrawTexturedRect(X - Width - Height + 17, Y - 3, Height - 8, Height - 8)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetTexture(citrus.Notices.TextureIDs[Table.Type])
	surface.DrawTexturedRect(X - Width - Height + 16, Y - 4, Height - 8, Height - 8)
	
	-- Text.
	draw.SimpleText(Table.Text, "citrus_MainText", X, Y, TextColor, TEXT_ALIGN_RIGHT)
	
	-- Ideal X.
	local IdealX = ScrW()
	local IdealY = ScrH() - (#citrus.Notices.Stored - Position) * (Height + 8)
	
	-- Time Left.
	local TimeLeft = Table.Time - (RealTime() - Table.Start)
	
	-- Check Time Left.
	if (TimeLeft < 0.8) then IdealX = ScrW() - 50 end
	if (TimeLeft < 0.5) then IdealX = ScrW() + Width * 2 end
	
	-- Speed.
	local Speed = FrameTime() * 15
	
	-- X.
	Table.X = Table.X + Table.Velocity.X * Speed
	Table.Y = Table.Y + Table.Velocity.Y * Speed
	
	-- Distance.
	local Distance = IdealY - Table.Y
	
	-- Y.
	Table.Velocity.Y = Table.Velocity.Y + Distance * Speed * 1
	
	-- Check abs.
	if (math.abs(Distance) < 2 and math.abs(Table.Velocity.Y) < 0.1) then Table.Velocity.Y = 0 end
	
	-- Distance.
	local Distance = IdealX - Table.X
	
	-- X.
	Table.Velocity.X = Table.Velocity.X + Distance * Speed * 1
	
	-- Check abs.
	if (math.abs(Distance) < 2 and math.abs(Table.Velocity.X) < 0.1) then Table.Velocity.X = 0 end
	
	-- Velocity X.
	Table.Velocity.X = Table.Velocity.X * (0.95 - FrameTime() * 8)
	Table.Velocity.Y = Table.Velocity.Y * (0.95 - FrameTime() * 8)
end

-- HUD Draw Score Board.
function citrus.Notices.HUDDrawScoreBoard()
	for K, V in pairs(citrus.Notices.Stored) do citrus.Notices.Draw(V, K) end
	
	-- Time.
	local Time = RealTime()
	
	-- For Loop.
	for K, V in pairs(citrus.Notices.Stored) do
		if (V.Start + V.Time < Time) then table.remove(citrus.Notices.Stored, K) end
	end
end

-- Add.
hook.Add("HUDDrawScoreBoard", "citrus.Notices.HUDDrawScoreBoard", citrus.Notices.HUDDrawScoreBoard)

-- Usermessage Hook.
usermessage.Hook("citrus.Notices.Add", function(Message)
	local Type = Message:ReadShort()
	local Message = Message:ReadString()
	
	-- Add.
	citrus.Notices.Add(Message, Type, 10)
end)

-- Add.
hook.Add("Initialize", "citrus.Notices.Initialize", function()
	function GAMEMODE:AddNotify(Text, Type, Time) citrus.Notices.Add(Text, Type, Time) end

	-- Paint Notes.
	function GAMEMODE:PaintNotes() end
end)