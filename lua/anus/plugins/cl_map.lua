local category = {}

	-- Optional: Player must be able to run this command to view this category
category.pluginid = "map"
category.CategoryName = "Maps"

function category:Initialize( parent )
	
	parent.panel = parent:Add( "anus_contentpanel" )
	parent.panel:SetTitle( "Maps" )
	parent.panel:Dock( FILL )
	
	parent.panel.listview = parent.panel:Add( "anus_listview" )
	parent.panel.listview:SetMultiSelect( false )
	parent.panel.listview:AddColumn( "Name" )
	parent.panel.listview:AddColumn( "Popularity" )
	parent.panel.listview:Dock( FILL )
	parent.panel.listview:SetMultiSelect( true )
	
	for k,v in next, anus_maps or {} do
		parent.panel.listview:AddLine( k, v .. "%" )
	end

	if not LocalPlayer().RequestedMaps and anus_maps == nil then
		net.Start( "anus_requestmaps" )
		net.SendToServer()
		
		LocalPlayer().RequestedMaps = true
		
		local mpaneltxt = parent:GetParent().CategoryLastClicked:GetText()
		timer.Create( "anus_mappanel_refresh", 0.2, 1, function()
			parent:GetParent().CategoryList[ mpaneltxt ]:DoClick()
		end )
	end
	parent.panel.listview:SortByColumn( 2, true )

	parent.panel.bottomPanel = parent.panel:Add( "DPanel" )
	parent.panel.bottomPanel:SetTall( 20 )
	parent.panel.bottomPanel.Paint = function() end
	parent.panel.bottomPanel:Dock( BOTTOM )
	
	parent.panel.bottomPanel.totalbanned = parent.panel.bottomPanel:Add( "DLabel" )
	parent.panel.bottomPanel.totalbanned:SetText( "Total maps: " .. #parent.panel.listview:GetLines() )
	parent.panel.bottomPanel.totalbanned:SetTextColor( Color( 140, 140, 140, 255) )
	parent.panel.bottomPanel.totalbanned:SetFont( "anus_SmallText" )
	parent.panel.bottomPanel.totalbanned:SizeToContents()
	parent.panel.bottomPanel.totalbanned:Dock( LEFT )
	
	
	if LocalPlayer():HasAccess( "votemap" ) then
		parent.panel.bottomPanel.buttonVoteMap = parent.panel.bottomPanel:Add( "anus_button" )
		parent.panel.bottomPanel.buttonVoteMap:SetText( "Start Vote" )
		parent.panel.bottomPanel.buttonVoteMap:SetTextColor( Color( 140, 140, 140, 255 ) )
		parent.panel.bottomPanel.buttonVoteMap:SetFont( "anus_SmallText" )
		parent.panel.bottomPanel.buttonVoteMap:SizeToContents()
		parent.panel.bottomPanel.buttonVoteMap:Dock( RIGHT )
		parent.panel.bottomPanel.buttonVoteMap:SetLeftOf( true )
		parent.panel.bottomPanel.buttonVoteMap.DoClick = function( pnl )
			if not parent.panel.listview:GetSelectedLine() then return end
			--LocalPlayer():ConCommand( "anus unban " .. parent.panel.listview:GetLine( parent.panel.listview:GetSelectedLine() ):GetColumnText( 2 ) )
		end
	end

	parent.panel.bottomPanel.buttonChangeMap = parent.panel.bottomPanel:Add( "anus_button" )
	parent.panel.bottomPanel.buttonChangeMap:SetText( "Force Map Change" )
	parent.panel.bottomPanel.buttonChangeMap:SetTextColor( Color( 140, 140, 140, 255 ) )
	parent.panel.bottomPanel.buttonChangeMap:SetFont( "anus_SmallText" )
	parent.panel.bottomPanel.buttonChangeMap:SizeToContents()
	parent.panel.bottomPanel.buttonChangeMap:Dock( RIGHT )
	parent.panel.bottomPanel.buttonChangeMap:SetLeftOf( true )
	parent.panel.bottomPanel.buttonChangeMap.DoClick = function( pnl )
		if #parent.panel.listview:GetSelected() > 1 then
			LocalPlayer():ChatPrint( "Only one map can be forced to change!" )
			return
		end
		if not parent.panel.listview:GetSelectedLine() then return end
		LocalPlayer():ConCommand( "anus map " .. parent.panel.listview:GetLine( parent.panel.listview:GetSelectedLine() ):GetColumnText( 1 ) )
	end
	
	
end

anus.RegisterCategory( category )


