local CATEGORY = {}

CATEGORY.pluginid = "adduser"
CATEGORY.CategoryName = "Player Groups"

function CATEGORY:Initialize( parent )
	self.panel = parent:Add( "anus_contentpanel" )
	self.panel:SetTitle( "Player Groups" )
	self.panel:Dock( FILL )

	self.panel.listview = self.panel:Add( "anus_listview" )
	self.panel.listview:SetMultiSelect( false )
	self.panel.listview:AddColumn( "Name" )
	self.panel.listview:AddColumn( "SteamID" )
	self.panel.listview:AddColumn( "Group" )
	self.panel.listview:AddColumn( "Permanent" )
	self.panel.listview.Columns[ 4 ]:SetFixedWidth( 135 ) 
	self.panel.listview:Dock( FILL )
	
	self:Refresh( parent )
	
	hook.Add( "anus_PlayerDataChanged", self.panel.listview, function()
		self:Refresh( parent )
	end )
end

function CATEGORY:Refresh( parent )
	if not self.panel.listview then return end

	self.panel.listview:Clear()
	hook.Call( "anus_StartMenuLoadingContent", nil )

	local sortable = {}
	local DelayedWait = 0.2--table.Count( anus.Users ) * 0.03 + 0.1
	local IncrementalWait = 0
	for k,v in next, anus.Users do
		for a,b in next, v do
			IncrementalWait = IncrementalWait + 1
			timer.Simple( 0.03 * IncrementalWait, function()
				if not IsValid( parent ) or not IsValid( self.panel ) then return end
				local line = self.panel.listview:AddLine( b.name, a, anus.Groups[ k ].name, anus.tempUsers[ a ] != nil and "icon16/cancel.png" or "icon16/accept.png" )
				line:SetLineColor( 3, anus.Groups[ k ].color )
				line:SetColumnIcon( 4 )

				sortable[ line ] = k
			end )
		end
	end

	--[[timer.Simple( DelayedWait, function()
		if not IsValid( parent ) or not IsValid( self.panel ) then return end
		
		for k,v in next, sortable do
			k:SetSortValue( 3,
				table.Count( anus.Groups[ v ].Permissions )
			)
		end
	end )]]

		-- ew
	timer.Simple( DelayedWait, function()
		timer.Simple( 0.03 * IncrementalWait, function()
			hook.Call( "anus_FinishMenuLoadingContent", nil )
		end )
	end )

	self.panel.listview:SortByColumn( 1, false )
	self.panel.listview.OnRowLeftClick = function( pnl, index, pnlRow )
		local rowSteamID = pnlRow:GetColumnText( 2 )

		local posx, posy = gui.MousePos()
		local menu = vgui.Create( "DMenu" )
		menu:SetPos( posx, posy )
		local groupchange = menu:AddSubMenu( "Change Group" )
		for k,v in next, anus.Groups do
			groupchange:AddOption( v.name, function()
				local foundPl = anus.findPlayer( rowSteamID, "steam" )
				local command = "adduser"
				if not foundPl then
					command = command .. "id"
				end
				LocalPlayer():ConCommand( "anus " .. command .. " " .. rowSteamID .. " " .. k )
				pnl:RequestFocus()
			end )
		end
		menu:AddOption( "Change Permissions", function() pnl:RequestFocus() end )
		menu:AddSpacer()
		menu:AddOption( "Visit Profile", function()
			gui.OpenURL( "http://steamcommunity.com/profiles/" .. util.SteamIDTo64( rowSteamID ) )
			pnl:RequestFocus()
		end )
		menu:AddOption( "Copy SteamID" ,function()
			SetClipboardText( pnlRow:GetColumnText( 2 ) )
		end )
		menu:AddOption( "Close", function()
			pnl:RequestFocus()
		end )
		menu.Think = function( pnl2 )
			if not IsValid( pnl ) or not anus_mainMenu or not anus_mainMenu:IsVisible() then
				menu:Remove()
			end
		end
		menu:Open( posx, posy, true, pnl )
	end
end

anus.registerCategory( CATEGORY )