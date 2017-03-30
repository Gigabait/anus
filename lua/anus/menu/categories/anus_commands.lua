local CATEGORY = {}

CATEGORY.CategoryName = "Commands"

local function createArgs( contentpanel, usesecondpanel, plugin )
	local Args = anus.getPlugin( plugin ).arguments
	
	local Parent = usesecondpanel and contentpanel.SecondContent:Add( "DListLayout" ) or contentpanel.FirstContent:Add( "DListLayout" )
	contentpanel.ListLayout = Parent
	contentpanel.ListLayout:SetWide( contentpanel.SecondContent:GetWide() )

	if not Args then goto Finish end
	
	for i=1,#Args do
		local ArgType
		local ArgName
		local ArgValue = Args[ i ]
		for k,v in next, ArgValue do
			if not tonumber( k ) then
				ArgName = k
				ArgType = v
			end
		end
		
		if ArgType == "player" then continue end
		
		if ArgType == "number" then
			local SpawnSlider = contentpanel.ListLayout:Add( "DNumSlider" )
			--SpawnSlider:Dock( FILL )
			--SpawnSlider:DockMargin( 15, 0, 15, 0 )
			SpawnSlider.Label:SetText( ArgName )
			SpawnSlider.Label:SetTextColor( Color( 141, 141, 141, 255 ) )
			SpawnSlider:SetMin( min or 0 )
			SpawnSlider:SetMax( max or 255 )
			SpawnSlider:SetValue( 0 )
			SpawnSlider:SetDecimals( 0 )
		elseif ArgType == "boolean" then
			local CheckBox = contentpanel.ListLayout:Add( "DCheckBoxLabel" )
			CheckBox.Label:SetText( ArgName )
			CheckBox.Label:SetTextColor( Color( 141, 141, 141, 255 ) )
			CheckBox:SetValue( 0 )
		end
	end
	
	::Finish::
	
	local Button = contentpanel.ListLayout:Add( "anus_button" )
	Button:SetText( "anus " .. plugin )
	
	if anus.getPlugin( plugin ).description then
		local Help = contentpanel.ListLayout:Add( "DLabel" )
		Help:SetText( anus.getPlugin( plugin ).description )
		Help:SetTextColor( Color( 141, 141, 141, 255 ) )
		Help:SetWrap( true )
		Help:SizeToContents()
		Help:SetAutoStretchVertical( true )
	end
end
	


function CATEGORY:Initialize( parent )

	self.panel = parent:Add( "anus_contentpanel" )
	self.panel:SetTitle( "Commands" )
	self.panel:Dock( FILL )

	self.panel.contentbase = self.panel:Add( "anus_contentpanel" )
	self.panel.contentbase:Dock( FILL )
	self.panel.contentbase.Think = function( pnl )
		for k,v in next, pnl:GetChildren() do
			v:DockMargin( 20, 0, 20, 0 )
		end
	end
	
	local Content = self.panel.contentbase
	
	Content.Main = Content:Add( "DPanel" )	
	Content.Main:Dock( FILL )
	Content.Main.Paint = function() end
	Content.Main:InvalidateLayout( true )
	
	Content.Main.Sidebar = Content.Main:Add( "DScrollPanel" )
	Content.Main.Sidebar:SetWide( 160 )
	Content.Main.Sidebar:Dock( LEFT )
	Content.Main.Sidebar:SetVerticalScrollbarEnabled( true )
	Content.Main.Sidebar.VBar:SetWide( 10 ) -- not 15 !!
	
		-- Main panel won't invalidate until next frame.
		-- Do this so we can capture Content.Main's width
	timer.Simple( 0, function()
		Content.Main.FirstContent = Content.Main:Add( "DPanel" )
		Content.Main.FirstContent:SetWide( Content.Main:GetWide() * (17/24) - 160 ) 
		Content.Main.FirstContent:Dock( LEFT )
		Content.Main.FirstContent:DockMargin( 10, 0, 0, 0 )
		Content.Main.FirstContent.Paint = function() end
		
		Content.Main.SecondContent = Content.Main:Add( "DPanel" )
		Content.Main.SecondContent:Dock( FILL )
		Content.Main.SecondContent:DockMargin( 10, 0, 0, 0 )
	end )

	local SidebarHeaders = {}
	Content.Main.Sidebar.catOpened = nil
	
	local SortedPlugins = table.GetKeys( anus.getPlugins() )
	table.sort( SortedPlugins, function( a, b )
		return tostring( a ) < tostring( b )
	end )
	

	for i=1,#SortedPlugins do
		local k = SortedPlugins[ i ]
		local v = anus.getPlugin( k )

		if not LocalPlayer():hasAccess( k ) or v.notRunnable or v.noCmdMenu then continue end
		v.category = v.category or "Unknown"
		
		if not SidebarHeaders[ v.category ] then
			
			SidebarHeaders[ v.category ] = Content.Main.Sidebar:Add( "DCollapsibleCategory" )
			
			local Cat = SidebarHeaders[ v.category ]
			Cat:SetLabel( v.category )
			Cat:SetExpanded( false )
			Cat:Dock( TOP )
			Cat.Header.DoClick = function( pnl )
				pnl:GetParent():Toggle()
				
				if Cat:GetParent().catOpened then
					if Cat:GetParent().catOpened == pnl then
						Cat:GetParent().catOpened = nil
						return
					else
						Cat:GetParent().catOpened:GetParent():Toggle()
						Cat.ListPanel.ListView:ClearSelection()
					end
				end
				Cat:GetParent().catOpened = pnl
			end
			Cat.Paint = function( pnl, w, h )
				draw.RoundedBox( 0, 0, 0, w, h, Color( 140, 140, 140, ANUS_MENUALPHA ) )
				if pnl:GetExpanded() then
					draw.RoundedBox( 0, 1, 1, w - 2, h - 2, Color( 225, 225, 225, ANUS_MENUALPHA ) )
				else
					draw.RoundedBox( 0, 1, 1, w - 2, h - 2, Color( 255, 255, 255, ANUS_MENUALPHA ) )
				end
			end
			Cat.Header:SetSize( 30, 40 )
			Cat.Header:SetFont( "anus_SmallText" )
			Cat.Header:SetTextColor(Color( 140, 140, 140, 255 )  ) 
			
			Cat.ListPanel = Cat:Add( "DPanel" )
			Cat.ListPanel:Dock( TOP )
			
			Cat.ListPanel.ListView = Cat.ListPanel:Add( "DListView" )
			Cat.ListPanel.ListView:SetHeaderHeight( 1 ) 
			Cat.ListPanel.ListView:SetHideHeaders( true )
			Cat.ListPanel.ListView:SetMultiSelect( false )
			Cat.ListPanel.ListView:AddColumn( "Plugin" )
			Cat.ListPanel.ListView:SetTall( 34 )
			Cat.ListPanel.ListView:Dock( TOP )

			Cat.ListPanel.ListView.OnRowSelected = function( pnl, lineid, line )
				local Plugin = line:GetColumnText( 1 )
				local Args = anus.getPlugin( Plugin ).arguments
				
				Content.Main.FirstContent:Clear()
				Content.Main.SecondContent:Clear()
				if not Args then
					createArgs( Content.Main, false, Plugin )
					return
				end

				for k,v in pairs( Args[ 1 ] ) do
					if tonumber( k ) then continue end

					if v == "player" then
						local ListView = Content.Main.FirstContent:Add( "anus_listview" )
							-- SHINYCOW: Edit listview to add support for multi select on however amount is in [ 1 ]
						if Args[ 1 ][ 1 ] then
							ListView:SetMultiSelect( false )
						end
						ListView:AddColumn( "Name" )
						ListView:AddColumn( "Group" )
						ListView:Dock( FILL )
						
						for k,v in ipairs( player.GetAll() ) do
							ListView:AddLine( v:Nick(), v:GetUserGroup() )
						end
						
						ListView.OnRowSelected = function( listview, lineid, line )
							createArgs( Content.Main, true, Plugin )
						end
					else
						createArgs( Content.Main, false, Plugin )
						break
					end
				end
			end

			Cat.ListPanel.ListView:AddLine( k )
		else
			SidebarHeaders[ v.category ].ListPanel.ListView:AddLine( k )
			local Count = 17*#SidebarHeaders[ v.category ].ListPanel.ListView:GetLines() + 1
			SidebarHeaders[ v.category ].ListPanel:SetTall( Count )
			SidebarHeaders[ v.category ].ListPanel.ListView:SetTall( Count )
		end
	end
end

anus.registerCategory( CATEGORY )