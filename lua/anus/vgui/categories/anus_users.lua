local CATEGORY = {}

CATEGORY.pluginid = "addgroup"
CATEGORY.CategoryName = "Player Ranks"

function CATEGORY:Initialize( parent )
	parent.panel = parent:Add( "anus_contentpanel" )
	parent.panel:SetTitle( "Edit Ranks" )
	parent.panel:Dock( FILL )
	
	parent.panel.listview = parent.panel:Add( "DListView" )
	parent.panel.listview:SetMultiSelect( false )
	parent.panel.listview:AddColumn( "Name" )
	parent.panel.listview:AddColumn( "SteamID" )
	parent.panel.listview:AddColumn( "Rank" )
	parent.panel.listview:Dock( FILL )
	
	for k,v in next, anus.Users do
		for a,b in next, v do
			parent.panel.listview:AddLine( b.name, a, anus.Groups[ k ].name )
		end
	end

	parent.panel.listview:SortByColumn( 1, false )
	parent.panel.listview.OnRowSelected = function( pnl, index, pnlRow )
		--DisableClipping( true )
		local posx, posy = gui.MousePos() 
		local menu = vgui.Create( "DMenu" )
		menu:SetPos( posx, posy )
		menu:AddOption( "Change group" )
		menu:AddSpacer()
		menu:AddOption( "Close" )
		--DisableClipping( false )
	end
end

anus.RegisterCategory( CATEGORY )

