local CATEGORY = {}

CATEGORY.pluginid = "autopromote"
CATEGORY.CategoryName = "Auto Promote"

function CATEGORY:Initialize( parent )

	parent.panel = parent:Add( "anus_contentpanel" )
	parent.panel:SetTitle( "Auto Promote" )
	parent.panel:Dock( FILL )

	parent.panel.listview = parent.panel:Add( "anus_listview" )
	parent.panel.listview:SetMultiSelect( false )
	parent.panel.listview:AddColumn( "Group" )
	parent.panel.listview:AddColumn( "Time (h)" )
	parent.panel.listview:AddColumn( "Enabled" )
	parent.panel.listview:Dock( FILL )
	
	local count = 0
	for k,v in next, anus_autopromote or {} do
		count = count + 1
		timer.Simple( 0.0125 * count, function()
			if not parent or not parent.panel then return end

			local line = parent.panel.listview:AddLine( k, v, v == -1 and "icon16/cross.png" or "icon16/accept.png" )
			line.pluginid = k
				-- Registers the column to show this as an icon
			line:SetLineIcon( 3 )
		end )
	end
	
	function parent.panel.listview:DoDoubleClick( lineid, line )
		if line.LineClick then
			line.LineClickFunction( lineid, line )
		end
	end
	
	timer.Simple( table.Count( anus.Groups ) * 0.01 + 0.03, function()
		if not parent or not parent.panel then return end

		parent.panel.listview:SortByColumn( 1, false )
	end )
		
	parent.panel.listview.OnRowRightClick = function( pnl, index, pnlRow )
		local posx, posy = gui.MousePos() 
		local menu = vgui.Create( "DMenu" )
		menu:SetPos( posx, posy )
		menu:AddOption( "Change Time Required", function()
			local column = parent.panel.listview:GetLine( parent.panel.listview:GetSelectedLine() )
			
			Derma_StringRequest( 
				column:GetColumnText( 1 ), 
				"Change auto promotion time (hours)",
				column:GetColumnText( 2 ),
				function( txt )
					if not tonumber( txt ) then return end
					
					net.Start( "anus_autopromotesv" )
						net.WriteFloat( math.Round( tonumber( txt ), 2 ) )
						net.WriteString( column:GetColumnText( 1 ) )
					net.SendToServer()
					--LocalPlayer():ConCommand( "anus banid " .. column:GetColumnText( 2 ) .. " " .. time .. " " .. txt )
				end,
				function( txt ) 
				end
			)
			
		end )
		menu:AddSpacer()
		menu:AddOption( "Close" )
		menu.Think = function( pnl2 )
			if not IsValid( pnl ) then
				menu:Remove()
			end
		end
		menu:Open( posx, posy, true, pnl )
	end
	
	--[[parent.panel.bottomPanel = parent.panel:Add( "DPanel" )
	parent.panel.bottomPanel:SetTall( 20 )
	parent.panel.bottomPanel.Paint = function() end
	parent.panel.bottomPanel:Dock( BOTTOM )

	parent.panel.bottomPanel.buttonUnban = parent.panel.bottomPanel:Add( "anus_button" )
	parent.panel.bottomPanel.buttonUnban:SetText( "Save Changes" )
	parent.panel.bottomPanel.buttonUnban:SetTextColor( Color( 140, 140, 140, 255 ) )
	parent.panel.bottomPanel.buttonUnban:SetFont( "anus_SmallText" )
	parent.panel.bottomPanel.buttonUnban:SizeToContents()
	parent.panel.bottomPanel.buttonUnban:Dock( RIGHT )
	parent.panel.bottomPanel.buttonUnban.DoClick = function( pnl )
	end]]
	
end

anus.RegisterCategory( CATEGORY )