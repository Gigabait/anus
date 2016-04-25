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
	
	local count = 0
	for k,v in next, anus.GetPlugins() do
		count = count + 1
		timer.Simple( 0.01 * count, function()
			if not parent or not parent.panel then return end

			local line = parent.panel.listview:AddLine( v.name, v.category, anus.UnloadedPlugins[ k ] and "icon16/cross.png" or "icon16/accept.png" )
			line.pluginid = k
				-- Registers the column to show this as an icon
			line:SetLineIconButton( 3, function( lineid, line )
				if anus.UnloadedPlugins[ line.pluginid ] then
					LocalPlayer():ConCommand( "anus pluginload " .. line.pluginid )
					line:SetColumnText( 3, "icon16/accept.png" )
				else
					LocalPlayer():ConCommand( "anus pluginunload " .. line.pluginid )
					line:SetColumnText( 3, "icon16/cross.png" )
				end
				--[[local mpaneltxt = parent:GetParent().CategoryLastClicked:GetText()
				timer.Create( "anus_pluginpanel_refresh", 0.2, 1, function()
					parent:GetParent().CategoryList[ mpaneltxt ]:DoClick()
				end )]]
			end )
		end )
	end
	
	function parent.panel.listview:DoDoubleClick( lineid, line )
		if line.LineClick then
			line.LineClickFunction( lineid, line )
		end
	end
	
	timer.Simple( table.Count( anus.GetPlugins() ) * 0.01 + 0.03, function()
		if not parent or not parent.panel then return end

		parent.panel.listview:SortByColumn( 1, false )
	end )
end

anus.RegisterCategory( CATEGORY )


