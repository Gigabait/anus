local CATEGORY = {}

CATEGORY.pluginid = "addgroup"
CATEGORY.CategoryName = "Groups"

function CATEGORY:Initialize( parent )
	self.panel = parent:Add( "anus_contentpanel" )
	self.panel:SetTitle( "Change Groups" )
	self.panel:Dock( FILL )

	self.panel.topPanel = self.panel:Add( "DPanel" )
	self.panel.topPanel:SetTall( 20 )
	self.panel.topPanel.Paint = function() end
	self.panel.topPanel:Dock( TOP )

	self.panel.topPanel.button = self.panel.topPanel:Add( "anus_button" )
	self.panel.topPanel.button:SetText( "Create new group" )
	self.panel.topPanel.button:SetTextColor( Color( 140, 140, 140, 255 ) )
	self.panel.topPanel.button:SetFont( "anus_SmallText" )
	self.panel.topPanel.button:SizeToContents()
	self.panel.topPanel.button:Dock( LEFT )
	self.panel.topPanel.button.DoClick = function( pnl )
		self.panel.groupeditor = anusMainGroupEditor( self.panel )
	end

	self.panel.listview = self.panel:Add( "anus_listview" )
	self.panel.listview:SetMultiSelect( false )
	self.panel.listview:AddColumn( "Group" )
	self.panel.listview:AddColumn( "Name" )
	self.panel.listview:AddColumn( "Inheritance" )
	self.panel.listview:AddColumn( "Icon" )
	self.panel.listview:Dock( FILL )

	self.panel.listview.sortable = {}
	for k,v in next, anus.Groups do
		local line = self.panel.listview:AddLine( k, v.name, v.Inheritance or "", v.icon or "")
			-- Registers the column to show this as an icon
		line:SetColumnIcon( 4 )
		line:SetLineColor( 2, v.color or Color( 0, 0, 0, 255 ) )

		self.panel.listview.sortable[ line ] = k
	end

	for k,v in next, self.panel.listview.Lines do
		v:SetSortValue( 1,
			table.Count( anus.Groups[ v:GetColumnText( 1 ) ].Permissions ) 
		)

		v:SetSortValue( 3,
			table.Count( anus.Groups[ v:GetColumnText( 3 ) != "" and v:GetColumnText( 3 ) or "user" ].Permissions )
		)
	end

	for k,v in next, self.panel.listview.sortable do
		k:SetSortValue( 2,
			table.Count( anus.Groups[ v ].Permissions )
		)
	end


	self.panel.listview:SortByColumn( 1, false )
	local function runOnSelect( pnl, index, pnlRow )
			-- hacky fix, idk whats wrong
		for k,v in next, self.panel.listview.Lines do
			if v:IsSelected() and v != pnlRow then
				v:SetSelected( false )
			end
		end
	
		local posx, posy = gui.MousePos()
		local menu = vgui.Create( "DMenu" )
		menu:SetPos( posx, posy )
		menu:AddOption( "Configure group", function()
			self.panel.groupeditor = anusMainGroupEditor( self.panel, pnlRow:GetColumnText( 1 ) )
		end )
		if not anus.Groups[ pnlRow:GetColumnText( 1 ) ].hardcoded then
			menu:AddOption( "Remove group", function()
				Derma_Query( "Confirm removal of group " .. pnlRow:GetColumnText( 1 ), "Confirm", "Confirm", function()	
					LocalPlayer():ConCommand( "anus removegroup " .. pnlRow:GetColumnText( 1 ) )
				end,
				"Cancel", function() end
				)
			end )
		end
		menu:AddSpacer()
		menu:AddOption( "Close" )
		menu.Think = function( pnl2 )
			if not IsValid( pnl ) or not anus_mainMenu or not anus_mainMenu:IsVisible() then
				menu:Remove()
			end
		end
		menu:Open( posx, posy, true, pnl )
	end
	self.panel.listview.OnRowLeftClick = function( pnl, index, pnlRow )
		runOnSelect( pnl, index, pnlRow )
	end
	self.panel.listview.OnRowRightClick = function( pnl, index, pnlRow )
		runOnSelect( pnl, index, pnlRow )
	end
	
	
	hook.Add( "anus_GroupSettingsChanged", self.panel, function( prnt, group )
		for k,v in next, self.panel.listview.Lines do
			if v:GetColumnText( 1 ) == group then
				self.panel.listview:RemoveLine( k )
				break
			end
		end

		if anus.isValidGroup( group ) then		
			local line = self.panel.listview:AddLine( group, anus.Groups[ group ].name, anus.Groups[ group ].Inheritance or "", anus.Groups[ group ].icon or "")
				-- Registers the column to show this as an icon
			line:SetColumnIcon( 4 )
			line:SetLineColor( 2, anus.Groups[ group ].color or Color( 0, 0, 0, 255 ) )

			self.panel.listview.sortable[ line ] = group

			line:SetSortValue( 1,
				table.Count( anus.Groups[ line:GetColumnText( 1 ) ].Permissions ) 
			)

			line:SetSortValue( 3,
				table.Count( anus.Groups[ line:GetColumnText( 3 ) != "" and line:GetColumnText( 3 ) or "user" ].Permissions )
			)
			
			line:SetSortValue( 2,
				table.Count( anus.Groups[ group ].Permissions )
			)
		end
	end )
end

anus.registerCategory( CATEGORY )