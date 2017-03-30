local panel = {}

function panel:Init()
		-- temporary
	self.group = "owner"
	
	self:SetSize( math.max( anus.universalWidth( 640 ), 640 ), math.max( anus.universalHeight( 760 ), 760 ) )
	self:Center()
	self:MakePopup()
	
	self.content = self:Add( "anus_contentpanel" )
	self.content:SetTitle( "Group Editor" )
	self.content:Dock( FILL )
	self.content.Think = function( pnl )
		for k,v in next, pnl:GetChildren() do
			v:DockMargin( 20, 40, 20, 0 )
		end
	end

	self.content.body = self.content:Add( "anus_contentpanel" )
	self.content.body:Dock( FILL )
	self.content.body.Think = function( pnl )
		for k,v in next, pnl:GetChildren() do
			v:DockMargin( 20, 0, 20, 0 )
		end
	end
	self.content.body.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 100, 0, 010, 255 ) )
	end
	
	local body = self.content.body
	
	body.ScrollPanel = body:Add( "anus_scrollpanel" )
	body.ScrollPanel:Dock( FILL ) --LEFT )
	--[[body.ScrollPanel.Paint = function( pnl, w, h )
		local new_h = h
		if self.resizeNum and self.resizeNum > new_h then
			new_h = h - self.resizeNum
		elseif self.resizeNum then
			new_h = self.resizeNum
		end
		draw.RoundedBox( 0, 0, 0, w, 0, color_white )
	end]]
	body.ScrollPanel.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255, 255 ) )
	end
	body.ScrollPanel.Creations = {}
	
	local bodycontent = body.ScrollPanel.Creations
	
	bodycontent.RankInfo = self:InstallRankInfo( body.ScrollPanel )
	bodycontent.RankColor = self:InstallRankColor( body.ScrollPanel )

	
	LocalPlayer().GroupEditors = LocalPlayer().GroupEditors or {}
	LocalPlayer().GroupEditors[ self ] = true
end

function panel:SetGroup( group )
	self.group = group
end

function panel:InstallRankInfo( parent )
	parent.RankInfo = parent:Add( "DPanel" )
	parent.RankInfo:Dock( TOP )
	timer.Simple( 0, function()
		parent.RankInfo:SetWide( parent:GetWide() )
		parent.RankInfo:SetTall( 90  )  
		parent.RankInfo:doInstallation()
	end)
 
	local rankinfo =
	{
		{ "Group ID", self.group, "DTextEntry" },
		{ "Group Name", anus.Groups[ self.group ].name , "DTextEntry" },
		{ "Inheritance", anus.Groups[ self.group ].Inheritance or "NONE", "DComboBox", function()
			if anus.Groups[ self.group ].hardcoded then return {} end
	
			local results = {}
			for a,b in next, anus.Groups do 
				results[ #results + 1 ] = a
			end
			return results
		end
		},
	}
	
	function parent.RankInfo:doInstallation()		
		parent.RankInfo.Contents = {}
		for k,v in next, rankinfo do
			print( k )
			for a,b in next, v do
				print( a, b )
			end
			surface.SetFont( "anus_SmallText" )
			local headerSizeW, headerSizeH = surface.GetTextSize( v[ 1 ] )

			parent.RankInfo.Contents[ k ] = parent.RankInfo:Add( "DPanel" )
			parent.RankInfo.Contents[ k ]:Dock( LEFT )
			parent.RankInfo.Contents[ k ].Header = parent.RankInfo.Contents[ k ]:Add( "DLabel" )
			parent.RankInfo.Contents[ k ].Header:Dock( TOP )
			parent.RankInfo.Contents[ k ].Header:SetFont( "anus_SmallText" )
			parent.RankInfo.Contents[ k ].Header:SetText( v[ 1 ] )
			parent.RankInfo.Contents[ k ].Header:SetTextColor( Color( 82, 82, 82, 255 ) )
			parent.RankInfo.Contents[ k ]:SetWide( parent.RankInfo:GetWide() / 3 )   
			parent.RankInfo.Contents[ k ].Header:SetTextInset( parent.RankInfo.Contents[ k ]:GetWide() / 2 - headerSizeW / 2, 0 )
			parent.RankInfo.Contents[ k ].Header:SizeToContents()
			
			parent.RankInfo.Contents[ k ].Content = parent.RankInfo.Contents[ k ]:Add( v[ 3 ] )
			parent.RankInfo.Contents[ k ].Content:SetText( v[ 2 ] )
			parent.RankInfo.Contents[ k ].Content:Dock( BOTTOM )
		end
		
		return parent.RankInfo
	end
end

function panel:InstallRankColor( parent )
	parent.RankColor = parent:Add( "DPanel" )
	parent.RankColor:Dock( TOP )
	timer.Simple( 0, function()
		parent.RankColor:SetWide( parent:GetWide() )
		parent.RankColor:SetTall( 45 )  
		parent.RankColor:doInstallation()
	end )
	
	function parent.RankColor:doInstallation()
		parent.RankColor.Header = parent.RankInfo:Add( "DLabel" )
		parent.RankColor.Header:SetText( "rank Color" )
		parent.RankColor.Header:SetTextColor( Color( 255, 255, 0, 255 ) )
		parent.RankColor.Header:SizeToContents()
		--SetAlphaBar( false )
		--	parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankColor.Contents[ "ColorPanel" ].RankColor:SetColor( v.color )
	end
end

function panel:InstallRankImage()
end

function panel:InstallRankAccess()
end

concommand.Add( "closegroupeditor", function()
	if not LocalPlayer().GroupEditors then return end
	for k,v in next, LocalPlayer().GroupEditors do
		k:Remove()
		LocalPlayer().GroupEditors[ k ] = nil
	end
end )

function panel:Paint( w, h )
	draw.RoundedBox( 0, 0, 0, w, h, Color( 140, 140, 140, 255 ) ) 
	draw.RoundedBox( 0, 1, 1, w - 2, h - 2, color_white )
end
	
vgui.Register( "anus_groupeditor", panel, "EditablePanel" )