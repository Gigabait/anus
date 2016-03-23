local CATEGORY = {}

CATEGORY.pluginid = "adduser"
CATEGORY.CategoryName = "Player Groups"

function CATEGORY:Initialize( parent )
	parent.panel = parent:Add( "anus_contentpanel" )
	parent.panel:SetTitle( "Player Groups" )
	parent.panel:Dock( FILL )
	
	parent.panel.listview = parent.panel:Add( "anus_listview" )
	parent.panel.listview:SetMultiSelect( false )
	parent.panel.listview:AddColumn( "Name" )
	parent.panel.listview:AddColumn( "SteamID" )
	parent.panel.listview:AddColumn( "Group" )
	parent.panel.listview:Dock( FILL )
	
	local sortable = {}
	for k,v in next, anus.Users do
		for a,b in next, v do
			local line = parent.panel.listview:AddLine( b.name, a, anus.Groups[ k ].name )
			line:SetLineColor( 3, anus.Groups[ k ].color )
			
			sortable[ line ] = k
		end
	end
	
	for k,v in next, sortable do
		k:SetSortValue( 3,
			table.Count( anus.Groups[ v ].Permissions )
		)
	end

	parent.panel.listview:SortByColumn( 1, false )
	parent.panel.listview.OnRowSelected = function( pnl, index, pnlRow )
		--DisableClipping( true )
		local posx, posy = gui.MousePos() 
		local menu = vgui.Create( "DMenu" )
		menu:SetPos( posx, posy )
		menu:AddOption( "Change group" )
		menu:AddOption( "Change Permissions" )
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


