include( "cl_admin_buttons.lua" )
include( "cl_vote_button.lua" )

local PANEL = {}

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:Init()

	self.InfoLabels = {}
	self.InfoLabels[ 1 ] = {}
	self.InfoLabels[ 2 ] = {}
	self.InfoLabels[ 3 ] = {}
	
	self.btnKick = vgui.Create( "SuiPlayerKickButton", self )
	self.btnBan = vgui.Create( "SuiPlayerBanButton", self )
	self.btnPBan = vgui.Create( "SuiPlayerPermBanButton", self )
	
	self.VoteButtons = {}

	self.VoteButtons[5] = vgui.Create( "SuiSpawnMenuVoteButton", self )
	self.VoteButtons[5]:SetUp( "silkicons/wrench", "builder", "Good at building!" )

	self.VoteButtons[4] = vgui.Create( "SuiSpawnMenuVoteButton", self )
	self.VoteButtons[4]:SetUp( "silkicons/star", "gold_star", "Wow! Gold star for you!" )

	self.VoteButtons[3] = vgui.Create( "SuiSpawnMenuVoteButton", self )
	self.VoteButtons[3]:SetUp( "silkicons/palette", "artistic", "This player is artistic!" )

	self.VoteButtons[2] = vgui.Create( "SuiSpawnMenuVoteButton", self )
	self.VoteButtons[2]:SetUp( "silkicons/heart", "love", "I love this player!" )

	self.VoteButtons[1] = vgui.Create( "SuiSpawnMenuVoteButton", self )
	self.VoteButtons[1]:SetUp( "silkicons/emoticon_smile", "smile", "I like this player!" )


	self.VoteButtons[10] = vgui.Create( "SuiSpawnMenuVoteButton", self )
	self.VoteButtons[10]:SetUp( "corner16", "curvey", "This player is great with curves" )

	self.VoteButtons[9] = vgui.Create( "SuiSpawnMenuVoteButton", self )
	self.VoteButtons[9]:SetUp( "faceposer_indicator", "best_landvehicle", "This player is awesome with land vehicles" )

	self.VoteButtons[8] = vgui.Create( "SuiSpawnMenuVoteButton", self )
	self.VoteButtons[8]:SetUp( "arrow", "best_airvehicle", "This player is awesome with air vehicles" )

	self.VoteButtons[7] = vgui.Create( "SuiSpawnMenuVoteButton", self )
	self.VoteButtons[7]:SetUp( "inv_corner16", "stunter", "Wow! you can do amazing Stunts!" )	

	self.VoteButtons[6] = vgui.Create( "SuiSpawnMenuVoteButton", self )
	self.VoteButtons[6]:SetUp( "gmod_logo", "god", "You are my GOD!" )

	
	self.VoteButtons[15] = vgui.Create( "SuiSpawnMenuVoteButton", self )
	self.VoteButtons[15]:SetUp( "silkicons/emoticon_smile", "lol", "LOL! You are funny!" )

	self.VoteButtons[14] = vgui.Create( "SuiSpawnMenuVoteButton", self )
	self.VoteButtons[14]:SetUp( "info", "informative", "This player is very informative!" )
	
	self.VoteButtons[13] = vgui.Create( "SuiSpawnMenuVoteButton", self )
	self.VoteButtons[13]:SetUp( "silkicons/user", "friendly", "This player is very friendly!" )

	self.VoteButtons[12] = vgui.Create( "SuiSpawnMenuVoteButton", self )
	self.VoteButtons[12]:SetUp( "silkicons/exclamation", "naughty", "This player is naughty!" )
	
	self.VoteButtons[11] = vgui.Create( "SuiSpawnMenuVoteButton", self )
	self.VoteButtons[11]:SetUp( "gmod_logo", "gay", "This player is GAY!" )
	
end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:SetInfo( column, k, v )

	if ( !v || v == "" ) then v = "N/A" end

	if ( !self.InfoLabels[ column ][ k ] ) then
	
		self.InfoLabels[ column ][ k ] = {}
		self.InfoLabels[ column ][ k ].Key 	= vgui.Create( "Label", self )
		self.InfoLabels[ column ][ k ].Value 	= vgui.Create( "Label", self )
		self.InfoLabels[ column ][ k ].Key:SetText( k )
		self:InvalidateLayout()
	
	end
	
	self.InfoLabels[ column ][ k ].Value:SetText( v )
	return true

end


/*---------------------------------------------------------
   Name: UpdatePlayerData
---------------------------------------------------------*/
function PANEL:SetPlayer( ply )

	self.Player = ply
	self:UpdatePlayerData()

end

/*---------------------------------------------------------
   Name: UpdatePlayerData
---------------------------------------------------------*/
function PANEL:UpdatePlayerData()

	if (!self.Player) then return end
	if ( !self.Player:IsValid() ) then return end
	
	self:SetInfo( 1, "Website:", self.Player:GetWebsite() )
	self:SetInfo( 1, "Location:", self.Player:GetLocation() )
	self:SetInfo( 1, "Email:", self.Player:GetEmail() )
	self:SetInfo( 1, "GTalk:", self.Player:GetGTalk() )
	self:SetInfo( 1, "MSN:", self.Player:GetMSN() )
	self:SetInfo( 1, "AIM:", self.Player:GetAIM() )
	self:SetInfo( 1, "XFire:", self.Player:GetXFire() )
	
	self:SetInfo( 2, "Props:", self.Player:GetCount( "props" ) )
	self:SetInfo( 2, "HoverBalls:", self.Player:GetCount( "hoverballs" ) )
	self:SetInfo( 2, "Thrusters:", self.Player:GetCount( "thrusters" ) )
	self:SetInfo( 2, "Balloons:", self.Player:GetCount( "balloons" ) )
	self:SetInfo( 2, "Buttons:", self.Player:GetCount( "buttons" ) )
	self:SetInfo( 2, "Dynamite:", self.Player:GetCount( "dynamite" ) )
	self:SetInfo( 2, "SENTs:", self.Player:GetCount( "sents" ) )

	self:SetInfo( 3, "Ragdolls:", self.Player:GetCount( "ragdolls" ) )
	self:SetInfo( 3, "Effects:", self.Player:GetCount( "effects" ) )
	self:SetInfo( 3, "Vehicles:", self.Player:GetCount( "vehicles" ) )
	self:SetInfo( 3, "Npcs:", self.Player:GetCount( "npcs" ) )
	self:SetInfo( 3, "Emitters:", self.Player:GetCount( "emitters" ) )
	self:SetInfo( 3, "Lamps:", self.Player:GetCount( "lamps" ) )
	self:SetInfo( 3, "Spawners:", self.Player:GetCount( "spawners" ) )
	
	self:InvalidateLayout()

end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:ApplySchemeSettings()
	for _k, column in pairs( self.InfoLabels ) do
		for k, v in pairs( column ) do
				v.Key:SetFGColor( 50, 50, 50, 255 )
				v.Value:SetFGColor( 80, 80, 80, 255 )	
		end
	
	end

end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:Think()

	if ( self.PlayerUpdate && self.PlayerUpdate > CurTime() ) then return end
	self.PlayerUpdate = CurTime() + 0.25
	
	self:UpdatePlayerData()

end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()

	local x = 5

	for column, column in pairs( self.InfoLabels ) do
	
		local y = 0
		local RightMost = 0
	
		for k, v in pairs( column ) do
	
			v.Key:SetPos( x, y )
			v.Key:SizeToContents()
			
			v.Value:SetPos( x + 60 , y )
			v.Value:SizeToContents()
			
			y = y + v.Key:GetTall() + 2
			
			RightMost = math.max( RightMost, v.Value.x + v.Value:GetWide() )
		
		end
		
		//x = RightMost + 10
		if(x<100) then
		x = x + 205
		else
		x = x + 115
		end
	
	end
	
	if ( !self.Player  || !self.Player:IsAdmin() || !self.Player == !LocalPlayer() || !LocalPlayer():IsAdmin() ) then 
		self.btnKick:SetVisible( false )
		self.btnBan:SetVisible( false )
		self.btnPBan:SetVisible( false )
	
	else
	
		self.btnKick:SetVisible( true )
		self.btnBan:SetVisible( true )
		self.btnPBan:SetVisible( true )
	
		self.btnKick:SetPos( self:GetWide() - 175, 85 - (22 * 2) )
		self.btnKick:SetSize( 46, 20 )

		self.btnBan:SetPos( self:GetWide() - 175, 85 - (22 * 1) )
		self.btnBan:SetSize( 46, 20 )
		
		self.btnPBan:SetPos( self:GetWide() - 175, 85 - (22 * 0) )
		self.btnPBan:SetSize( 46, 20 )
	
	end
	
	for k, v in ipairs( self.VoteButtons ) do
	
		v:InvalidateLayout()
		if(k<6) then
			v:SetPos( self:GetWide() -  k * 25, 0 )
		elseif(k<11) then
			v:SetPos( self:GetWide() -  (k-5) * 25, 36 )
		else 
			v:SetPos( self:GetWide() -  (k-10) * 25, 72 )
		end
		v:SetSize( 20, 32 )
	
	end
	
end

function PANEL:Paint()
	return true
end


vgui.Register( "SuiScorePlayerInfoCard", PANEL, "Panel" )