local CATEGORY = {}

/*CATEGORY.pluginid = "watch"
CATEGORY.CategoryName = "Watch"
-- ignore this for now
function CATEGORY:Initialize( parent )

	parent.panel = parent:Add( "anus_contentpanel" )
	parent.panel:SetTitle( "Watch Players" )
	parent.panel:Dock( FILL )
	
	parent.panel.listview = parent.panel:Add( "DPanel" )
	parent.panel.listview:SetTall( 512 )
	parent.panel.listview:SetWide( 512 )
	parent.panel.listview:Dock( FILL )
	
	parent.panel.bottomPanel = parent.panel:Add( "DPanel" )
	parent.panel.bottomPanel:SetTall( 20 )
	parent.panel.bottomPanel.Paint = function() end
	parent.panel.bottomPanel:Dock( BOTTOM )
	
	parent.panel.bottomPanel.totalbanned = parent.panel.bottomPanel:Add( "DLabel" )
	parent.panel.bottomPanel.totalbanned:SetText( "Currently watching: " .. player.GetAll()[ math.random( 1, #player.GetAll() ) ]:Nick() )
	parent.panel.bottomPanel.totalbanned:SetTextColor( Color( 140, 140, 140, 255) )
	parent.panel.bottomPanel.totalbanned:SetFont( "anus_SmallText" )
	parent.panel.bottomPanel.totalbanned:SizeToContents()
	parent.panel.bottomPanel.totalbanned:Dock( LEFT )
	
	
	--[[if LocalPlayer():HasAccess( "ban" ) then
		parent.panel.bottomPanel.buttonAddban = parent.panel.bottomPanel:Add( "anus_button" )
		parent.panel.bottomPanel.buttonAddban:SetText( "Add ban" )
		parent.panel.bottomPanel.buttonAddban:SetTextColor( Color( 140, 140, 140, 255 ) )
		parent.panel.bottomPanel.buttonAddban:SetFont( "anus_SmallText" )
		parent.panel.bottomPanel.buttonAddban:SizeToContents()
		parent.panel.bottomPanel.buttonAddban:Dock( RIGHT )
		parent.panel.bottomPanel.buttonAddban:SetLeftOf( true )
		parent.panel.bottomPanel.buttonAddban.DoClick = function( pnl )
			if not parent.panel.listview:GetSelectedLine() then return end
			LocalPlayer():ConCommand( "anus unban " .. parent.panel.listview:GetLine( parent.panel.listview:GetSelectedLine() ):GetColumnText( 2 ) )
		end
	end]]
	
		-- instead of unban selected
		-- unban steamid. 
		-- if a line is highlighted copy that into the new menu that pops up
		-- for cases of where theres a large amount of steams to sift through
	parent.panel.bottomPanel.buttonUnban = parent.panel.bottomPanel:Add( "anus_button" )
	parent.panel.bottomPanel.buttonUnban:SetText( "Stop Watching" )
	parent.panel.bottomPanel.buttonUnban:SetTextColor( Color( 140, 140, 140, 255 ) )
	parent.panel.bottomPanel.buttonUnban:SetFont( "anus_SmallText" )
	parent.panel.bottomPanel.buttonUnban:SizeToContents()
	parent.panel.bottomPanel.buttonUnban:Dock( RIGHT )
	parent.panel.bottomPanel.buttonUnban:SetLeftOf( true )
	parent.panel.bottomPanel.buttonUnban.DoClick = function( pnl )
	end
	
end

anus.RegisterCategory( CATEGORY )
*/

