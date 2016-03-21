local CATEGORY = {}

CATEGORY.pluginid = "addgroup"
CATEGORY.CategoryName = "Groups"

function CATEGORY:Initialize( parent )
	parent:SetSkin( "ANUS" )

	parent.panel = parent:Add( "anus_contentpanel" )
	parent.panel:SetTitle( "Change Groups" )
	parent.panel:Dock( FILL )
	
	parent.panel.topPanel = parent.panel:Add( "DPanel" )
	parent.panel.topPanel:SetTall( 20 )
	parent.panel.topPanel.Paint = function() end
	parent.panel.topPanel:Dock( TOP )
	
	parent.panel.topPanel.button = parent.panel.topPanel:Add( "anus_button" )
	parent.panel.topPanel.button:SetText( "Create new group" )
	parent.panel.topPanel.button:SetTextColor( Color( 140, 140, 140, 255 ) )
	parent.panel.topPanel.button:SetFont( "anus_SmallText" )
	parent.panel.topPanel.button:SizeToContents()
	parent.panel.topPanel.button:Dock( LEFT )
	
	parent.panel.listview = parent.panel:Add( "anus_listview" )
	parent.panel.listview:SetMultiSelect( false )
	parent.panel.listview:AddColumn( "Group" )
	parent.panel.listview:AddColumn( "Name" )
	parent.panel.listview:AddColumn( "Inheritance" )
	parent.panel.listview:AddColumn( "Icon" )
	parent.panel.listview:Dock( FILL )
	
	for k,v in next, anus.Groups do
		local line = parent.panel.listview:AddLine( k, v.name, v.Inheritance or "", v.icon or "")
			-- Registers the column to show this as an icon
		--parent.panel.listview:SetLineIcon( 4, line, v.icon )
		line:SetLineIcon( 4 )--, v.icon )
	end

	for k,v in next, parent.panel.listview.Lines do
		v:SetSortValue( 1, 
			table.Count( anus.Groups[ v:GetColumnText( 1 ) ].Permissions ) 
		)
		
		v:SetSortValue( 3,
			table.Count( anus.Groups[ v:GetColumnText( 3 ) != "" and v:GetColumnText( 3 ) or "user" ].Permissions )
		)
	end
	

	parent.panel.listview:SortByColumn( 1, false )
	parent.panel.listview.OnRowSelected = function( pnl, index, pnlRow )
		--DisableClipping( true )
		local posx, posy = gui.MousePos() 
		local menu = vgui.Create( "DMenu" )
		menu:SetPos( posx, posy )
		menu:AddOption( "Change name" )
		menu:AddOption( "Change inheritance" )
		menu:AddOption( "Change permissions" )
		menu:AddOption( "Remove rank" )
		menu:AddSpacer()
		menu:AddOption( "Close" )
		menu.Think = function( pnl2 )
			if not IsValid( pnl ) then
				menu:Remove()
			end
		end
		--DisableClipping( false )
	end
end

anus.RegisterCategory( CATEGORY )


