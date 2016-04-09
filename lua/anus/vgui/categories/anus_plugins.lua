local CATEGORY = {}

CATEGORY.pluginid = "pluginload"
CATEGORY.CategoryName = "Plugins"

function CATEGORY:Initialize( parent )

	parent.panel = parent:Add( "anus_contentpanel" )
	parent.panel:SetTitle( "Manage Plugins" )
	parent.panel:Dock( FILL )

	parent.panel.listview = parent.panel:Add( "anus_listview" )
	parent.panel.listview:SetMultiSelect( false )
	parent.panel.listview:AddColumn( "Plugin" )
	parent.panel.listview:AddColumn( "Type" )
	parent.panel.listview:AddColumn( "Enabled" )
	parent.panel.listview:Dock( FILL )
	
	for k,v in next, anus.GetPlugins() do
		local line = parent.panel.listview:AddLine( v.name, v.category, anus.UnloadedPlugins[ k ] and "icon16/cross.png" or "icon16/accept.png" )
		line.pluginid = k
			-- Registers the column to show this as an icon
		line:SetLineIconButton( 3, function( lineid, line )
			if anus.UnloadedPlugins[ line.pluginid ] then
				LocalPlayer():ConCommand( "anus pluginload " .. line.pluginid )
			else
				LocalPlayer():ConCommand( "anus pluginunload " .. line.pluginid )
			end
			local mpaneltxt = parent:GetParent().CategoryLastClicked:GetText()
			--PrintTable( parent:GetParent().CategoryList )
			timer.Create( "anus_pluginpanel_refresh", 0.2, 1, function()
				parent:GetParent().CategoryList[ mpaneltxt ]:DoClick()
			end )
			
			--print( "test:", parent:GetParent().CategoryLastClicked:GetText() )
		end )
	end
	
	function parent.panel.listview:DoDoubleClick( lineid, line )
		if line.LineClick then
			line.LineClickFunction( lineid, line )
		end
	end
	

	parent.panel.listview:SortByColumn( 1, false )
end

anus.RegisterCategory( CATEGORY )


