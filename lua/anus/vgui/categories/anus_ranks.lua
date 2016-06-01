local CATEGORY = {}

CATEGORY.pluginid = "addgroup"
CATEGORY.CategoryName = "Groups"

function CATEGORY:Initialize( parent )
	parent:SetSkin( "ANUS" )

	parent.panel = parent:Add( "anus_contentpanel" )
	parent.panel:SetTitle( "Change Groups" )
	parent.panel:Dock( FILL )
	
	parent.panel.topPanel = parent.panel:Add( "DPanel" )
	parent.panel.topPanel:SetTall( 20 )
	parent.panel.topPanel.Paint = function() end
	parent.panel.topPanel:Dock( TOP )
	
	parent.panel.topPanel.button = parent.panel.topPanel:Add( "anus_button" )
	parent.panel.topPanel.button:SetText( "Create new group" )
	parent.panel.topPanel.button:SetTextColor( Color( 140, 140, 140, 255 ) )
	parent.panel.topPanel.button:SetFont( "anus_SmallText" )
	parent.panel.topPanel.button:SizeToContents()
	parent.panel.topPanel.button:Dock( LEFT )
	
	parent.panel.topPanel.button2 = parent.panel.topPanel:Add( "anus_button" )
	parent.panel.topPanel.button2:SetText( "Configure groups" )
	parent.panel.topPanel.button2:SetTextColor( Color( 140, 140, 140, 255 ) )
	parent.panel.topPanel.button2:SetFont( "anus_SmallText" )
	parent.panel.topPanel.button2:SizeToContents()
	parent.panel.topPanel.button2:SetLeftOf( true )
	parent.panel.topPanel.button2:Dock( LEFT )
	parent.panel.topPanel.button2.DoClick = function( pnl )
		parent.panel.groupeditor = vgui.Create( "anus_groupeditor" ) --parent:GetParent():Add( "anus_groupeditor" )
	end
	
	parent.panel.listview = parent.panel:Add( "anus_listview" )
	parent.panel.listview:SetMultiSelect( false )
	parent.panel.listview:AddColumn( "Group" )
	parent.panel.listview:AddColumn( "Name" )
	parent.panel.listview:AddColumn( "Inheritance" )
	parent.panel.listview:AddColumn( "Icon" )
	parent.panel.listview:Dock( FILL )
	
	local sortable = {}
	for k,v in next, anus.Groups do
		local line = parent.panel.listview:AddLine( k, v.name, v.Inheritance or "", v.icon or "")
			-- Registers the column to show this as an icon
		line:SetLineIcon( 4 )
		line:SetLineColor( 2, v.color or Color( 0, 0, 0, 255 ) )
		
		sortable[ line ] = k
	end

	for k,v in next, parent.panel.listview.Lines do
		v:SetSortValue( 1, 
			table.Count( anus.Groups[ v:GetColumnText( 1 ) ].Permissions ) 
		)
		
		v:SetSortValue( 3,
			table.Count( anus.Groups[ v:GetColumnText( 3 ) != "" and v:GetColumnText( 3 ) or "user" ].Permissions )
		)
	end
	
	for k,v in next, sortable do
		k:SetSortValue( 2, 
			table.Count( anus.Groups[ v ].Permissions )
		)
	end
	

	parent.panel.listview:SortByColumn( 1, false )
	local function runOnSelect( pnl, index, pnlRow )
		local posx, posy = gui.MousePos() 
		local menu = vgui.Create( "DMenu" )
		menu:SetPos( posx, posy )
		menu:AddOption( "Change ID", function()
			local column2 = parent.panel.listview:GetLine( parent.panel.listview:GetSelectedLine() ):GetColumnText( 1 )
			Derma_StringRequest(
				column2, 
				"Change group id",
				parent.panel.listview:GetLine( parent.panel.listview:GetSelectedLine() ):GetColumnText( 1 ),
				function( txt )
					net.Start( "anus_groups_editid" )
						net.WriteString( column2 )
						net.WriteString( txt )
					net.SendToServer()
				end,
				function( txt )
				end
			)
		end )
		menu:AddOption( "Change name", function()
			local column = parent.panel.listview:GetLine( parent.panel.listview:GetSelectedLine() )
			Derma_StringRequest(
				column:GetColumnText( 1 ), 
				"Change group name",
				column:GetColumnText( 2 ),
				function( txt )
					LocalPlayer():ConCommand( "anus renamegroup " .. column:GetColumnText( 1 ) .. " " .. txt )
				end,
				function( txt )
				end
			)
		end )
		menu:AddOption( "Configure group", function()
			parent.panel.groupeditor = vgui.Create( "anus_groupeditor" ) --parent:GetParent():Add( "anus_groupeditor" )
		end )
		menu:AddOption( "Remove group" )
		menu:AddSpacer()
		menu:AddOption( "Close" )
		menu.Think = function( pnl2 )
			if not IsValid( pnl ) then
				menu:Remove()
			end
		end
		menu:Open( posx, posy, true, pnl )
	end
	parent.panel.listview.OnRowLeftClick = function( pnl, index, pnlRow )
		runOnSelect( pnl, index, pnlRow )
	end
	parent.panel.listview.OnRowRightClick = function( pnl, index, pnlRow )
		runOnSelect( pnl, index, pnlRow )
	end
end

anus.RegisterCategory( CATEGORY )


