surface.CreateFont( "anus_AnnouncementTitle",
{
	font = "Verdana",
	size = 48,
} )

function anus_AnnouncementPanel( message )
	local TimeToFade = 3
	local BaseAlpha = 255
	local AlphaCalc = BaseAlpha
	local StartFading = false
	local StartFadeTime = 4
	
	timer.Create( "anusAnnounceHUDFade", StartFadeTime, 1, function()
		StartFading = true
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
		if StartFading then
			AlphaCalc = math.Approach( AlphaCalc, 0, ( BaseAlpha / TimeToFade ) * FrameTime() )
		end
		
		draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255, AlphaCalc ) )
		
		if AlphaCalc == 0 and IsValid( VGUI_announceBackground ) then		
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
		local Col = Color( 231, 230, 237, 255 )
		Col.a = AlphaCalc  
		draw.RoundedBox( 0, 0, 0, w, h, Col )
	end
	
	local AnnounceTitle = string.upper( "Announcement" )
	
	surface.SetFont( "anus_AnnouncementTitle" )
	local AnnounceSizeW, AnnounceSizeH = surface.GetTextSize( AnnounceTitle )
	
	VGUI_announceTitle.Title = VGUI_announceTitle:Add( "DLabel" )
	VGUI_announceTitle.Title:SetText( AnnounceTitle )
	VGUI_announceTitle.Title:SetPos( 0, VGUI_announceTitle:GetTall() / 2 - AnnounceSizeH / 2 )
	VGUI_announceTitle.Title:SetFont( "anus_AnnouncementTitle" )
	VGUI_announceTitle.Title:SetTextColor( Color( 140, 140, 140, 255 ) )
	VGUI_announceTitle.Title:SizeToContents()
	VGUI_announceTitle.Title:MoveTo( VGUI_announceTitle:GetWide() - AnnounceSizeW, VGUI_announceTitle:GetTall() / 2 - AnnounceSizeH / 2, 8, 0, nil, function( anim, pnl )
		pnl:MoveTo( 0 + AnnounceSizeW, VGUI_announceTitle:GetTall() / 2 - AnnounceSizeH / 2, 8, 0, nil )
	end )
	VGUI_announceTitle.Title.Think = function( self )
		local Col = self:GetTextColor()
		Col.a = AlphaCalc
	
		self:SetTextColor( Col )
	end
	
	surface.SetFont( "anus_SmallText" )
	local MessageSizeW, MessageSizeH = surface.GetTextSize( message or "" )
	
	VGUI_announceBackground.Content = VGUI_announceBackground:Add( "DLabel" )
	VGUI_announceBackground.Content:SetText( message or "" )
	VGUI_announceBackground.Content:SetPos( VGUI_announceBackground:GetWide() / 2 - MessageSizeW / 2, VGUI_announceTitle:GetTall() + MessageSizeH - 5 )
	VGUI_announceBackground.Content:SetFont( "anus_SmallText" )
	VGUI_announceBackground.Content:SetTextColor( Color( 140, 140, 140, 255 ) )
	VGUI_announceBackground.Content:SetMultiline( true )
	VGUI_announceBackground.Content:SizeToContents()
	VGUI_announceBackground.Content.Think = function( self )
		local Col = self:GetTextColor()
		Col.a = AlphaCalc
		
		self:SetTextColor( Col )
	end
end

net.Receive( "anus_announcepanel", function()
	local Txt = net.ReadString()
	
	anus_AnnouncementPanel( Txt )
end )