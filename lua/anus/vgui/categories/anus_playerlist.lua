local CATEGORY = {}

CATEGORY.CategoryName = "Players"

function CATEGORY:Initialize( parent )

	parent.panel = parent:Add( "anus_contentpanel" )
	parent.panel:SetTitle( "Manage Players" )
	parent.panel:Dock( FILL )

	parent.panel.listview = parent.panel:Add( "anus_listview" )
	parent.panel.listview:SetMultiSelect( false )
	parent.panel.listview:AddColumn( "ID" )
	parent.panel.listview:AddColumn( "Name" )
	parent.panel.listview:AddColumn( "SteamID" )
	parent.panel.listview:AddColumn( "Group" )
	parent.panel.listview:Dock( FILL )
	parent.panel.listview.Columns[ 1 ]:SetFixedWidth( 45 )
	
	local sortable = {}
	for k,v in next, player.GetAll() do
		local line = parent.panel.listview:AddLine( v:UserID(), v:Nick(), v:SteamID(), anus.Groups[ v:GetUserGroup() ].name )
		line:SetLineColor( 4, anus.Groups[ v:GetUserGroup() ].color )
		
		sortable[ line ] = v:GetUserGroup()
	end
	
	for k,v in next, sortable do
		k:SetSortValue( 4,
			table.Count( anus.Groups[ v ].Permissions )
		)
	end
	

	parent.panel.listview:SortByColumn( 1, false )
	
end

anus.RegisterCategory( CATEGORY )


