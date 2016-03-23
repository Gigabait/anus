local CATEGORY = {}

CATEGORY.pluginid = "toggleplugin"
CATEGORY.CategoryName = "Plugins"

function CATEGORY:Initialize( parent )

	parent.panel = parent:Add( "anus_contentpanel" )
	parent.panel:SetTitle( "Manage Plugins" )
	parent.panel:Dock( FILL )

	parent.panel.listview = parent.panel:Add( "anus_listview" )
	parent.panel.listview:SetMultiSelect( false )
	parent.panel.listview:AddColumn( "Plugin" )
	parent.panel.listview:AddColumn( "Enabled" )
	parent.panel.listview:Dock( FILL )
	
	for k,v in next, anus.GetPlugins() do
		local line = parent.panel.listview:AddLine( v.name, "icon16/accept.png" )
			-- Registers the column to show this as an icon
		line:SetLineIcon( 2 )--, v.icon )
	end
	

	parent.panel.listview:SortByColumn( 1, false )
end

anus.RegisterCategory( CATEGORY )


