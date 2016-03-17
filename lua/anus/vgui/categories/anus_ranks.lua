local CATEGORY = {}

CATEGORY.pluginid = "addgroup"
CATEGORY.CategoryName = "View Ranks"

function CATEGORY:Initialize( parent )
	parent.panel = parent:Add( "anus_contentpanel" )
	parent.panel:SetTitle( "Edit Ranks" )
	parent.panel:Dock( FILL )
	
	parent.panel.listview = parent.panel:Add( "DListView" )
	parent.panel.listview:SetMultiSelect( false )
	parent.panel.listview:AddColumn( "ID" )
	parent.panel.listview:AddColumn( "Rank" )
	parent.panel.listview:AddColumn( "Inheritance" )
	parent.panel.listview:Dock( FILL )
	
	for k,v in next, anus.Groups do
		parent.panel.listview:AddLine( k, v.name, v.Inheritance or "" )
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
		--DisableClipping( false )
	end
end

anus.RegisterCategory( CATEGORY )


