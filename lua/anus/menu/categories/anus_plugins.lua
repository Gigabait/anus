local CATEGORY = {}

CATEGORY.pluginid = "pluginload"
CATEGORY.CategoryName = "Plugins"

function CATEGORY:Initialize( parent )

	self.panel = parent:Add( "anus_contentpanel" )
	self.panel:SetTitle( "Manage Plugins" )
	self.panel:Dock( FILL )

	self.panel.listview = self.panel:Add( "anus_listview" )
	self.panel.listview:SetMultiSelect( false )
	self.panel.listview:AddColumn( "Plugin" )
	self.panel.listview:AddColumn( "Type" )
	self.panel.listview:AddColumn( "Enabled" )
	self.panel.listview:Dock( FILL )

	hook.Call( "anus_StartMenuLoadingContent", nil )
	
	local count = 0
	for k,v in next, anus.getPlugins() do
		count = count + 1
		timer.Simple( 0.012 * count, function()
			if not parent or not self.panel then return end

			local line = self.panel.listview:AddLine( v.name, v.category, anus.unloadedPlugins[ k ] and "icon16/cancel.png" or "icon16/accept.png" )
			line.pluginid = k
				-- Registers the column to show this as an icon
			line:SetColumnIconButton( 3, function( lineid, line )
				if anus.unloadedPlugins[ line.pluginid ] then
					if line.pluginid == "lua" then return end
					LocalPlayer():ConCommand( "anus pluginload " .. line.pluginid )
					line:SetColumnText( 3, "icon16/accept.png" )
				else
					LocalPlayer():ConCommand( "anus pluginunload " .. line.pluginid )
					line:SetColumnText( 3, "icon16/cancel.png" )
				end
			end )
		end )
	end

	function self.panel.listview:DoDoubleClick( lineid, line )
		if line.LineClick then
			line.LineClickFunction( lineid, line )
		end
	end

	timer.Simple( table.Count( anus.getPlugins() ) * 0.012 + 0.03, function()
		if not parent or not self.panel then return end

		hook.Call( "anus_FinishMenuLoadingContent", nil )
		self.panel.listview:SortByColumn( 1, false )
	end )
end

anus.registerCategory( CATEGORY )