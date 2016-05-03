local category = {}

	-- Optional: Player must be able to run this command to view this category
category.pluginid = "ban"
category.parent = "altcheck"
category.CategoryName = "Manage Alts"

function category:Initialize( parent )
	
	parent.panel = parent:Add( "anus_contentpanel" )
	parent.panel:SetTitle( "Manage Alt Accounts" )
	parent.panel:Dock( FILL )
	
	parent.panel.listview = parent.panel:Add( "anus_listview" )
	parent.panel.listview:SetMultiSelect( false )
	parent.panel.listview:AddColumn( "Name" )
	parent.panel.listview:AddColumn( "SteamID" )
	parent.panel.listview:AddColumn( "Online" )
	parent.panel.listview:AddColumn( "Parent Account" )
	parent.panel.listview:AddColumn( "Banned" )
	parent.panel.listview:Dock( FILL )
	parent.panel.listview.Columns[ 3 ]:SetFixedWidth( 115 )
	parent.panel.listview.Columns[ 5 ]:SetFixedWidth( 115 )
	
	parent.panel.bottomPanel = parent.panel:Add( "DPanel" )
	parent.panel.bottomPanel:SetTall( 20 )
	parent.panel.bottomPanel.Paint = function() end
	parent.panel.bottomPanel:Dock( BOTTOM )
	
	parent.panel.bottomPanel.totalalts = parent.panel.bottomPanel:Add( "DLabel" )
	parent.panel.bottomPanel.totalalts:SetText( "Total alts: " .. #parent.panel.listview:GetLines() )
	parent.panel.bottomPanel.totalalts:SetTextColor( Color( 140, 140, 140, 255) )
	parent.panel.bottomPanel.totalalts:SetFont( "anus_SmallText" )
	parent.panel.bottomPanel.totalalts:SizeToContents()
	parent.panel.bottomPanel.totalalts:Dock( LEFT )
	
end


anus.RegisterCategory( category )


