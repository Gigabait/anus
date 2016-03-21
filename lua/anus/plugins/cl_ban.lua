local CATEGORY = {}

	-- Optional: Player must be able to run this command to view this category
CATEGORY.pluginid = "unban"
CATEGORY.CategoryName = "Bans"

function CATEGORY:Initialize( parent )
	
	parent.panel = parent:Add( "anus_contentpanel" )
	parent.panel:SetTitle( "Manage Bans" )
	parent.panel:Dock( FILL )
	
	parent.panel.listview = parent.panel:Add( "anus_listview" )
	parent.panel.listview:SetMultiSelect( false )
	parent.panel.listview:AddColumn( "Name" )
	parent.panel.listview:AddColumn( "SteamID" )
	parent.panel.listview:AddColumn( "Unban Date" )
	parent.panel.listview:AddColumn( "Admin" )
	parent.panel.listview:AddColumn( "Reason" )
	parent.panel.listview:Dock( FILL )
	parent.panel.listview.Columns[ 1 ]:SetFixedWidth( 150 )
	
	for k,v in next, anus.Bans do
		local time = v.time
		if time == 0 or time == "0" then
			time = "Never"
		else
			time = os.date( "%X - %d/%m/%Y", time )
		end
		parent.panel.listview:AddLine( v.name, k, time, v.admin, v.reason )
	end
	parent.panel.listview:SortByColumn( 1, false )
	parent.panel.listview.OnRowSelected = function( pnl, index, pnlRow )
		--DisableClipping( true )
		local posx, posy = gui.MousePos() 
		local menu = vgui.Create( "DMenu" )
		menu:SetPos( posx, posy )
		menu:AddOption( "Edit Time" )
		menu:AddOption( "Edit Reason" )
		menu:AddOption( "View Details" )
		menu:AddSpacer()
		menu:AddOption( "Close" )
		menu.Think = function( pnl2 )
			if not IsValid( pnl ) then
				menu:Remove()
			end
		end
		--DisableClipping( false )
	end
	
	parent.panel.bottomPanel = parent.panel:Add( "DPanel" )
	parent.panel.bottomPanel:SetTall( 20 )
	parent.panel.bottomPanel.Paint = function() end
	parent.panel.bottomPanel:Dock( BOTTOM )
	
	parent.panel.bottomPanel.totalbanned = parent.panel.bottomPanel:Add( "DLabel" )
	parent.panel.bottomPanel.totalbanned:SetText( "Total banned: " .. #parent.panel.listview:GetLines() )
	parent.panel.bottomPanel.totalbanned:SetTextColor( Color( 140, 140, 140, 255) )
	parent.panel.bottomPanel.totalbanned:SetFont( "anus_SmallText" )
	parent.panel.bottomPanel.totalbanned:SizeToContents()
	parent.panel.bottomPanel.totalbanned:Dock( LEFT )
	
		-- instead of unban selected
		-- unban steamid. 
		-- if a line is highlighted copy that into the new menu that pops up
		-- for cases of where theres a large amount of steams to sift through
	parent.panel.bottomPanel.buttonUnban = parent.panel.bottomPanel:Add( "anus_button" )
	parent.panel.bottomPanel.buttonUnban:SetText( "Unban Selected" )
	parent.panel.bottomPanel.buttonUnban:SetTextColor( Color( 140, 140, 140, 255 ) )
	parent.panel.bottomPanel.buttonUnban:SetFont( "anus_SmallText" )
	parent.panel.bottomPanel.buttonUnban:SizeToContents()
	parent.panel.bottomPanel.buttonUnban:Dock( RIGHT )
	parent.panel.bottomPanel.buttonUnban.DoClick = function( pnl )
		if not parent.panel.listview:GetSelectedLine() then return end
		LocalPlayer():ConCommand( "anus unban " .. parent.panel.listview:GetLine( parent.panel.listview:GetSelectedLine() ):GetColumnText( 2 ) )
	end
	
end


anus.RegisterCategory( CATEGORY )


