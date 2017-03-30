local Category = {}

	-- Optional: Player must be able to run this command to view this Category
Category.pluginid = "help"
Category.CategoryName = "Help"

function Category:Initialize( parent )
	
	self.panel = parent:Add( "anus_contentpanel" )
	self.panel:SetTitle( "Command Help" )
	self.panel:Dock( FILL )
	
	self.panel.listview = self.panel:Add( "anus_listview" )
	self.panel.listview:SetMultiSelect( false )
	self.panel.listview:AddColumn( "Command" )
	self.panel.listview:AddColumn( "Description" )
	self.panel.listview:AddColumn( "Usage" )
	self.panel.listview:AddColumn( "Example" )
	self.panel.listview:Dock( FILL )
	self.panel.listview.Columns[ 1 ]:SetFixedWidth( 100 )
	
	for k,v in next, anus.getPlugins() do
		if not LocalPlayer():hasAccess( k ) then continue end
		self.panel.listview:AddLine( k, v.description, v.argsAsString, v.example )
	end
	self.panel.listview:SortByColumn( 1, false )
	self.panel.listview.OnClickLine = function( pnl, line, bClear ) end

end

anus.registerCategory( Category )


