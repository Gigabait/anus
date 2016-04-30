local category = {}

	-- Optional: Player must be able to run this command to view this category
category.pluginid = "help"
category.CategoryName = "Help"

function category:Initialize( parent )
	
	parent.panel = parent:Add( "anus_contentpanel" )
	parent.panel:SetTitle( "Command Help" )
	parent.panel:Dock( FILL )
	
	parent.panel.listview = parent.panel:Add( "anus_listview" )
	parent.panel.listview:SetMultiSelect( false )
	parent.panel.listview:AddColumn( "Command" )
	parent.panel.listview:AddColumn( "Description" )
	parent.panel.listview:AddColumn( "Usage" )
	parent.panel.listview:AddColumn( "Example" )
	parent.panel.listview:Dock( FILL )
	parent.panel.listview.Columns[ 1 ]:SetFixedWidth( 100 )
	
	for k,v in next, anus.Plugins do
		local usage = ""
		for a,b in next, v.usageargs do
			usage = usage .. " " .. (b.optional and "[" or "<") .. b.desc .. (b.optional and "]" or ">")
		end
		parent.panel.listview:AddLine( k, v.help, usage, v.example )
	end
	parent.panel.listview:SortByColumn( 1, false )
	parent.panel.listview.OnClickLine = function( pnl, line, bClear ) end

end

anus.RegisterCategory( category )


