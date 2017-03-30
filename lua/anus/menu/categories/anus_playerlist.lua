local CATEGORY = {}

CATEGORY.CategoryName = "Players"


local function OpenDisconnectedPlayersMenu( parent )
	if parent.DCPanel and IsValid( parent.DCPanel ) then
		parent.DCPanel:MakePopup()
		return
	end

	parent.DCPanel = vgui.Create( "DFrame" )
	parent.DCPanel:SetTitle( "Disconnected Players" )
	parent.DCPanel:SetSize( 800, 600 )
	parent.DCPanel:Center()
	parent.DCPanel:MakePopup()
	
	parent.DCPanel.Content = parent.DCPanel:Add( "anus_contentpanel" )
	parent.DCPanel.Content:SetTitle( "Latest Disconnected" )
	parent.DCPanel.Content:Dock( FILL )
	
	parent.DCPanel.Content.listview = parent.DCPanel.Content:Add( "anus_listview" )
	parent.DCPanel.Content.listview:SetMultiSelect( false )
	parent.DCPanel.Content.listview:AddColumn( "Name" )
	parent.DCPanel.Content.listview:AddColumn( "SteamID" )
	parent.DCPanel.Content.listview:AddColumn( "Kills" )
	parent.DCPanel.Content.listview:AddColumn( "Deaths" )
	parent.DCPanel.Content.listview:AddColumn( "Leave Time" )
	parent.DCPanel.Content.listview:Dock( FILL )
	
	for k,v in ipairs( anus.playerDC or {} ) do
		parent.DCPanel.Content.listview:AddLine( v.name, v.steamid, v.kills, v.deaths, v.time )
	end
		
	parent.DCPanel.Content.listview.OnRowRightClick = function( pnl, index, pnlRow )
		local posx, posy = gui.MousePos() 
		local menu = vgui.Create( "DMenu" )
		menu:SetPos( posx, posy )
		
		menu:AddOption( "Copy Name", function()
			SetClipboardText( pnlRow:GetColumnText( 1 ) )
		end )
		menu:AddOption( "Copy SteamID", function()
			SetClipboardText( pnlRow:GetColumnText( 2 ) )
		end )
		menu:AddOption( "Copy Leave Time", function()
			SetClipboardText( pnlRow:GetColumnText( 5 ) )
		end )
		menu:AddSpacer()
		menu:AddOption( "Visit Profile", function()
			gui.OpenURL( "http://steamcommunity.com/profiles/" .. util.SteamIDTo64( pnlRow:GetColumnText( 2 ) ) )
		end )
		menu:AddOption( "Close" )
		menu.Think = function( pnl2 )
			if not IsValid( pnl ) or not anus_mainMenu or not anus_mainMenu:IsVisible() then
				menu:Remove()
			end
		end
		menu:Open( posx, posy, true, pnl )
	end
	

	parent.DCPanel.BottomPanel = parent.DCPanel.Content:Add( "DPanel" )
	parent.DCPanel.BottomPanel:Dock( BOTTOM )
	parent.DCPanel.BottomPanel.Paint = function() end
	
	parent.DCPanel.BottomPanel.RefreshButton = parent.DCPanel.BottomPanel:Add( "anus_button" )
	parent.DCPanel.BottomPanel.RefreshButton:SetText( "Refresh" )
	parent.DCPanel.BottomPanel.RefreshButton:Dock( RIGHT )
	parent.DCPanel.BottomPanel.RefreshButton.DoClick = function( pnl )
		net.Start( "anus_requestdc" )
		net.SendToServer()
	end
	
end

function CATEGORY:Initialize( parent )

	self.panel = parent:Add( "anus_contentpanel" )
	self.panel:SetTitle( "Manage Players" )
	self.panel:Dock( FILL )

	if LocalPlayer():hasAccess( "unban" ) then
		self.panel.topPanel = self.panel:Add( "DPanel" )
		self.panel.topPanel:SetTall( 20 )
		self.panel.topPanel.Paint = function() end
		self.panel.topPanel:Dock( TOP )
		
		self.panel.topPanel.disconnected = self.panel.topPanel:Add( "anus_button" )
		self.panel.topPanel.disconnected:SetText( "Disconnected Players" )
		self.panel.topPanel.disconnected:Dock( LEFT )
		self.panel.topPanel.disconnected:SizeToContents()
		self.panel.topPanel.disconnected.DoClick = function( pnl )
			OpenDisconnectedPlayersMenu( pnl )
		end
	end

	
	self.panel.Sortable = {}

	self.panel.listview = self.panel:Add( "anus_listview" )
	self.panel.listview:SetMultiSelect( false )
	self.panel.listview:AddColumn( "ID" )
	local ColumnName = self.panel.listview:AddColumn( "Name" )
	ColumnName.RightClickEntries =
	{
		[ "Name" ] = function()
			ColumnName:SetName( "Name" )
			ColumnName:GetParent():Clear()
			for k,v in ipairs( player.GetAll() ) do
				local Line = self.panel.listview:AddLine( v:UserID(), v:Nick(), v:SteamID(), anus.Groups[ v:GetUserGroup() ].name )
				Line:SetLineColor( 4, anus.Groups[ v:GetUserGroup() ].color )

				self.panel.Sortable[ Line ] = v:GetUserGroup()
			end
		end,
		[ "Steam Name" ] = function()
			ColumnName:SetName( "Steam Name" )
			ColumnName:GetParent():Clear()
			for k,v in ipairs( player.GetAll() ) do
				local Line = self.panel.listview:AddLine( v:UserID(), v:SteamName(), v:SteamID(), anus.Groups[ v:GetUserGroup() ].name )
				Line:SetLineColor( 4, anus.Groups[ v:GetUserGroup() ].color )

				self.panel.Sortable[ Line ] = v:GetUserGroup()
			end
		end,
	}
	self.panel.listview:AddColumn( "SteamID" )
	self.panel.listview:AddColumn( "Group" )
	self.panel.listview:Dock( FILL )
	self.panel.listview.Columns[ 1 ]:SetFixedWidth( 45 )
	
	self:Refresh( parent )
	
	hook.Add( "anus_PlayerDataChanged", self.panel.listview, function( _, steamid, group )
		local Target = player.GetBySteamID( steamid )
		if not Target then return end

		for k,v in next, self.panel.listview:GetLines() do
			if v:GetValue( 3 ) == steamid or v:GetValue( 1 ) == Target:UserID() then
				self:Refresh( parent )
				return
			end
		end

		local Line = self.panel.listview:AddLine( Target:UserID(), Target:Nick(), steamid, anus.Groups[ group ].name )
		Line:SetLineColor( 4, anus.Groups[ group ].color )
		self.panel.listview:SortByColumn( 1, false )
	end )
	
	hook.Add( "player_disconnect", self.panel.listview, function( _, data )
		local Target = Player( data.userid )
		
		for k,v in next, self.panel.listview:GetLines() do
			if not Target.SteamID then continue end

			if v:GetValue( 3 ) == Target:SteamID() then
				self.panel.listview:RemoveLine( k )
			end
		end
	end )
		

end

function CATEGORY:Refresh( parent )
	self.panel.listview:Clear()

	for k,v in ipairs( player.GetAll() ) do
		local Line = self.panel.listview:AddLine( v:UserID(), v:Nick(), v:SteamID(), anus.Groups[ v:GetUserGroup() ].name )
		Line:SetLineColor( 4, anus.Groups[ v:GetUserGroup() ].color )

		self.panel.Sortable[ Line ] = v:GetUserGroup()
		Line.OnCursorEntered = function()
			Line:SetCursor( "hand" )
		end
	end
	self.panel.listview.OnRowLeftClick = function( pnl, index, pnlRow )
		local PosX, PosY = gui.MousePos()
		local Height = 0

		local Menu = vgui.Create( "DMenu" )
		Menu:SetPos( PosX, PosY )

		local PluginSortable = {}
		for k,v in next, anus.getPlugins() do
			if not v.SelectFromMenu then continue end
			if not LocalPlayer():hasAccess( k ) then continue end
			if v.disabled then continue end
			
			PluginSortable[ #PluginSortable + 1 ] = v
		end
		
		table.SortByMember( PluginSortable, "name", true )

		for k,v in ipairs( PluginSortable ) do
			v:SelectFromMenu( LocalPlayer(), Menu, Player( pnlRow:GetColumnText( 1 ) ), pnlRow )
		end

		Menu.Think = function( pnl2 )
			if not IsValid( pnl ) or not IsValid( pnlRow ) then
				Menu:Remove()
			end
		end

		for k,v in next, Menu:GetCanvas():GetChildren() do
			Height = Height + v:GetTall()
		end

		if Height + PosY > ScrH() then
			Menu:SetPos( PosX, PosY - ( (Height + PosY) - ScrH() ) )
			Menu:Open( PosX, PosY - ( (Height + PosY) - ScrH() ), true, pnl )
		else
			Menu:Open( PosX, PosY, true, pnl )
		end

	end

	self.panel.listview.OnRowRightClick = function( pnl, index, pnlRow )
		local PosX, PosY = gui.MousePos()
		local Height = 0

		local Menu = vgui.Create( "DMenu" )
		Menu:SetPos( PosX, PosY )
		Menu:AddOption( "Visit Profile", function()
			gui.OpenURL( "http://steamcommunity.com/profiles/" .. util.SteamIDTo64( pnlRow:GetColumnText( 3 ) ) )
		end )
		Menu:AddOption( "Copy SteamID", function()
			SetClipboardText( pnlRow:GetColumnText( 3 ) )
		end )
		if LocalPlayer():hasAccess( "adduser" ) and not anus.isPluginDisabled( "adduser" ) then
			Menu:AddSpacer()
			local GroupChange = Menu:AddSubMenu( "Change Group" )
			for k,v in next, anus.Groups do
				GroupChange:AddOption( v.name, function() 
					LocalPlayer():ConCommand( "anus adduser " .. pnlRow:GetColumnText( 1 ) .. " " .. k )
					pnl:RequestFocus()
				end )
			end
		end
		Menu.Think = function( pnl2 )
			if not IsValid( pnl ) or not anus_mainMenu or not anus_mainMenu:IsVisible() then
				Menu:Remove()
			end
		end
		Menu:Open( PosX, PosY, true, pnl )
	end


	for k,v in next, self.panel.Sortable do
		if not k.SetSortValue then continue end

		k:SetSortValue( 4,
			table.Count( anus.Groups[ v ].Permissions )
		)
	end

	self.panel.listview:SortByColumn( 1, false )
end
	

anus.registerCategory( CATEGORY )