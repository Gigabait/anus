local category = {}

	-- Optional: Player must be able to run this command to view this category
category.pluginid = "ban"
category.parent = "altcheck"
category.CategoryName = "Alt Handling"

function category:Initialize( parent )
	
	parent.panel = parent:Add( "anus_contentpanel" )
	parent.panel:SetTitle( "Alt Account Handling" )
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
	
	--[[local sortable = {}
	for k,v in next, anus.Bans do
		local time = v.time
		if time == 0 or time == "0" then
			time = "Never"
		else
			time = os.date( "%X - %d/%m/%Y", time )
		end
		
		local line = parent.panel.listview:AddLine( v.name, k, time, v.admin, v.reason )
		if time != "Never" then
			time = v.time
		end
		sortable[ line ] = time
	end]]
	
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
	
end


anus.RegisterCategory( category )


