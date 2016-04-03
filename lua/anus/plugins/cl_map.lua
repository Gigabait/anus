local category = {}

	-- Optional: Player must be able to run this command to view this category
category.pluginid = "map"
category.CategoryName = "Maps"

function category:Initialize( parent )
	
	--[[parent.panel = parent:Add( "anus_contentpanel" )
	parent.panel:SetTitle( "Command Help" )
	parent.panel:Dock( FILL )]]

end

anus.RegisterCategory( category )


