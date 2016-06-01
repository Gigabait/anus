surface.CreateFont( "anus_AnnouncementTitle",
{
	font = "Verdana",
	size = 48,
} )

function anus_AnnouncementPanel( message )
	local timeToFade = 3
	local baseAlpha = 255
	local alphaCalc = baseAlpha
	local startFading = false
	local startFadeTime = 4
	
	timer.Create( "anusAnnounceHUDFade", startFadeTime, 1, function()
		startFading = true
	end )
	
	if IsValid( VGUI_announceBackground ) then
		VGUI_announceBackground:Remove()
		VGUI_announceBackground = nil
		
		VGUI_announceTitle:Remove()
		VGUI_announceTitle = nil
	end

	VGUI_announceBackground = vgui.Create( "DPanel" )
	VGUI_announceBackground:SetPos( 0, 0 )
	VGUI_announceBackground:SetSize( ScrW(), ScrH() * 0.11 )
	VGUI_announceBackground:SetKeyboardInputEnabled( true )
	VGUI_announceBackground:ParentToHUD()
	VGUI_announceBackground.Paint = function( self, w, h )
		if startFading then
			alphaCalc = math.Approach( alphaCalc, 0, ( baseAlpha / timeToFade) * FrameTime() )
		end
		
		draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255, alphaCalc ) )
		
		if alphaCalc == 0 and IsValid( VGUI_announceBackground ) then		
			VGUI_announceTitle:Remove()
			VGUI_announceTitle = nil
			
			VGUI_announceBackground:Remove()
			VGUI_announceBackground = nil
		end
	end
	
	VGUI_announceTitle = VGUI_announceBackground:Add( "DPanel" )
	VGUI_announceTitle:SetPos( 0, 0 )
	VGUI_announceTitle:SetSize( ScrW(), VGUI_announceTitle:GetParent():GetTall() * 0.6 )
	VGUI_announceTitle:SetKeyboardInputEnabled( true )
	VGUI_announceTitle:ParentToHUD()
	VGUI_announceTitle.Paint = function( self, w, h )
		local col = Color( 231, 230, 237, 255 )
		col.a = alphaCalc  
		draw.RoundedBox( 0, 0, 0, w, h, col )
	end
	
	local announceTitle = string.upper( "Announcement" )
	
	surface.SetFont( "anus_AnnouncementTitle" )
	local announcesizew, announcesizeh = surface.GetTextSize( announceTitle )
	
	VGUI_announceTitle.Title = VGUI_announceTitle:Add( "DLabel" )
	VGUI_announceTitle.Title:SetText( announceTitle )
	VGUI_announceTitle.Title:SetPos( 0, VGUI_announceTitle:GetTall() / 2 - announcesizeh / 2 )
	VGUI_announceTitle.Title:SetFont( "anus_AnnouncementTitle" )
	VGUI_announceTitle.Title:SetTextColor( Color( 140, 140, 140, 255 ) )
	VGUI_announceTitle.Title:SizeToContents()
	VGUI_announceTitle.Title:MoveTo( VGUI_announceTitle:GetWide() - announcesizew, VGUI_announceTitle:GetTall() / 2 - announcesizeh / 2, 8, 0, nil, function( anim, pnl )
		pnl:MoveTo( 0 + announcesizew, VGUI_announceTitle:GetTall() / 2 - announcesizeh / 2, 8, 0, nil )
	end )
	VGUI_announceTitle.Title.Think = function( self )
		local col = self:GetTextColor()
		col.a = alphaCalc
	
		self:SetTextColor( col )
	end
	
	surface.SetFont( "anus_SmallText" )
	local messagesizew, messagesizeh = surface.GetTextSize( message or "" )
	
	VGUI_announceBackground.Content = VGUI_announceBackground:Add( "DLabel" )
	VGUI_announceBackground.Content:SetText( message or "" )
	VGUI_announceBackground.Content:SetPos( VGUI_announceBackground:GetWide() / 2 - messagesizew / 2, VGUI_announceTitle:GetTall() + messagesizeh - 5 )
	VGUI_announceBackground.Content:SetFont( "anus_SmallText" )
	VGUI_announceBackground.Content:SetTextColor( Color( 140, 140, 140, 255 ) )
	VGUI_announceBackground.Content:SetMultiline( true )
	VGUI_announceBackground.Content:SizeToContents()
	VGUI_announceBackground.Content.Think = function( self )
		local col = self:GetTextColor()
		col.a = alphaCalc
		
		self:SetTextColor( col )
	end
end

net.Receive( "anus_announcepanel", function()
	local txt = net.ReadString()
	
	anus_AnnouncementPanel( txt )
end )