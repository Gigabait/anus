local CATEGORY = {}

CATEGORY.CategoryName = "Players"

function CATEGORY:Initialize( parent )

	parent.panel = parent:Add( "anus_contentpanel" )
	parent.panel:SetTitle( "Manage Players" )
	parent.panel:Dock( FILL )
	
	local sortable = {}

	parent.panel.listview = parent.panel:Add( "anus_listview" )
	parent.panel.listview:SetMultiSelect( false )
	parent.panel.listview:AddColumn( "ID" )
	local columnName = parent.panel.listview:AddColumn( "Name" )
	columnName.RightClickEntries = 
	{
		[ "Name" ] = function() 
			columnName:SetName( "Name" ) 
			--[[for k,v in next, columnName:GetParent().Lines  do 
				v:SetColumnText( columnName:GetColumnID(), 
			end ]]
			columnName:GetParent():Clear()
			for k,v in next, player.GetAll() do
				local line = parent.panel.listview:AddLine( v:UserID(), v:Nick(), v:SteamID(), anus.Groups[ v:GetUserGroup() ].name )
				line:SetLineColor( 4, anus.Groups[ v:GetUserGroup() ].color )
			
				sortable[ line ] = v:GetUserGroup()
			end
		end,
		[ "Steam Name" ] = function() 
			columnName:SetName( "Steam Name" )
			columnName:GetParent():Clear()
			for k,v in next, player.GetAll() do
				local line = parent.panel.listview:AddLine( v:UserID(), v:SteamName(), v:SteamID(), anus.Groups[ v:GetUserGroup() ].name )
				line:SetLineColor( 4, anus.Groups[ v:GetUserGroup() ].color )
			
				sortable[ line ] = v:GetUserGroup()
			end
		end,
	}
	parent.panel.listview:AddColumn( "SteamID" )
	parent.panel.listview:AddColumn( "Group" )
	parent.panel.listview:Dock( FILL )
	parent.panel.listview.Columns[ 1 ]:SetFixedWidth( 45 )
	
	for k,v in next, player.GetAll() do
		local line = parent.panel.listview:AddLine( v:UserID(), v:Nick(), v:SteamID(), anus.Groups[ v:GetUserGroup() ].name )
		line:SetLineColor( 4, anus.Groups[ v:GetUserGroup() ].color )
		
		sortable[ line ] = v:GetUserGroup()
	end
	--	parent.panel.listview.OnRowRightClick = function( pnl, index, pnlRow )
	parent.panel.listview.OnRowLeftClick = function( pnl, index, pnlRow )
		local posx, posy = gui.MousePos()
		local height = 0
		--local sort = {}
		
		local menu = vgui.Create( "DMenu" )
		menu:SetPos( posx, posy )
		--[[menu.AddOption = function( pnl2, strText, funcFunction )
			local pnl3 = vgui.Create( "DMenuOption", pnl2 )
			pnl3:SetMenu( self )
			pnl3:SetText( strText )
			if ( funcFunction ) then pnl3.DoClick = funcFunction end
						
			sort[ #sort + 1 ] = { txt = strText, pnl = pnl3 }
			
			pnl2:AddPanel( pnl3 )
			
			return pnl3
		end]]
		--[[menu.AddSubMenu = function( pnl2, strText, funcFunction )
			local pnl3 = vgui.Create( "DMenuOption", pnl2 )
			local SubMenu = pnl3:AddSubMenu( strText, funcFunction )

			pnl3:SetText( strText )
			if ( funcFunction ) then pnl3.DoClick = funcFunction end

			--sort[ #sort + 1 ] = { txt = strText, pnl = pnl3, submenu = SubMenu }
			
			pnl2:AddPanel( pnl3 )

			return SubMenu, pnl3
		end]]
		
		local sort = {}
		menu.AddOption = function( pnl2, strText, funcFunction, bNoSort )
			if not bNoSort then
				sort[ #sort + 1 ] = { txt = strText, parent = menu, func = funcFunction }
			else
				local pnl3 = vgui.Create( "DMenuOption", pnl2 )
				pnl3:SetMenu( pnl2 )
				pnl3:SetText( strText )
				if ( funcFunction ) then pnl3.DoClick = funcFunction end
				
				pnl2:AddPanel( pnl3 )
				
				return pnl3
			end
		end
			-- this whole function is hacky as hell
			-- save it for another day
			
		/*local holder = {}
		menu.AddSubMenu = function( pnl2, strText, funcFunction, bNoSort )
			if not bNoSort then
				sort[ #sort + 1 ] = { txt = strText, submenu = true, parent = menu }
				
					-- most hacky
				local pnl3 = vgui.Create( "DMenuOption", pnl2 )
				--local holder = {}
				--[[function pnl3:AddOption( strText2, funcFunction2 )
					holder[ #holder + 1 ] = { txt = strText2, func = funcFunction2 }
				end]]
				function pnl3:AddFakeSubMenu()
					local SubMenu = DermaMenu( self )
					SubMenu:SetVisible( false )
					SubMenu:SetParent( self )

					self:SetSubMenu( SubMenu )
					
					function SubMenu:AddOption( strText2, funcFunction2 )
						holder[ #holder + 1 ] = { parentTxt = strText, txt = strText2, func = funcFunction2 }
					end
					
					return SubMenu
				end
				local SubMenu = pnl3:AddFakeSubMenu()
				
				return SubMenu, nil
				
			else
				local pnl3 = vgui.Create( "DMenuOption", pnl2 )
				local SubMenu = pnl3:AddSubMenu() --strText, funcFunction )

				pnl3:SetText( strText )
				if ( funcFunction ) then pnl3.DoClick = funcFunction end

				pnl2:AddPanel( pnl3 )

				return SubMenu, pnl3
			end
		end*/
	
		
		for k,v in next, anus.GetPlugins() do
			if not v.SelectFromMenu then continue end
			if not LocalPlayer():HasAccess( k ) then continue end
			if v.disabled then continue end
			
			v:SelectFromMenu( LocalPlayer(), menu, Player( parent.panel.listview:GetLine( parent.panel.listview:GetSelectedLine() ):GetColumnText( 1 ) ), parent.panel.listview:GetLine( parent.panel.listview:GetSelectedLine() ) )
		end

		menu.Think = function( pnl2 )
			if not IsValid( pnl ) then
				menu:Remove()
			end
		end
		
		table.SortByMember( sort, "txt", true )
		
		for k,v in next, sort do
			if not v.submenu then
				menu:AddOption( v.txt, v.func, true )
			else
				menu:AddSubMenu( v.txt, nil, true )
			end
		end
						
		--[[local sort = {}
		--PrintTable( menu:GetCanvas():GetChildren() )
		for k,v in next, menu:GetCanvas():GetChildren() do
			local posx, posy = v:GetPos()
			print( k, v, v:GetText(), posx, posy )
			sort[ #sort + 1 ] = { txt = v:GetText(), men = menu, pnl = v }
		end]]
		
		--[[table.SortByMember( sort, "txt", true )
		
		PrintTable( sort )
		
		menu:GetCanvas():Clear()
		
		local asd = nil
		for k,v in next, sort do
			if v.txt == "Health" then
				PrintTable( v.pnl:GetTable() )
			end
		end
		
		for k,v in next, sort do
			
			local pnl = vgui.Create( "DMenuOption", menu )
			pnl:SetMenu( menu )
			pnl:SetText( v.txt )
			
			if v.pnl.DoClick then
				pnl.DoClick = v.pnl.DoClick
			end
			if v.pnl.SubMenu then
				print( v.txt )
				local sub = v.pnl.SubMenu --v.txt, v.pnl.DoClick )
				PrintTable( sub:GetCanvas():GetChildren() )
				for a,b in next, sub:GetCanvas():GetChildren() do
					sub:AddPanel( b )
				end
			end
			
			menu:AddPanel( pnl )
		end]]
		
		
		for k,v in next, menu:GetCanvas():GetChildren() do
			height = height + v:GetTall()
		end
		
		if height + posy > ScrH() then
			menu:SetPos( posx, posy - ( (height + posy) - ScrH() ) )			
			menu:Open( posx, posy - ( (height + posy) - ScrH() ), true, pnl )
		else
			menu:Open( posx, posy, true, pnl )
		end
		
	end
	
	parent.panel.listview.OnRowRightClick = function( pnl, index, pnlRow )
		local posx, posy = gui.MousePos()
		local height = 0
		--local sort = {}
		
		local menu = vgui.Create( "DMenu" )
		menu:SetPos( posx, posy )
		menu:AddOption( "Visit Profile", function()
			gui.OpenURL( "http://steamcommunity.com/profiles/" .. util.SteamIDTo64( parent.panel.listview:GetLine( parent.panel.listview:GetSelectedLine() ):GetColumnText( 3 ) ) )
		end )
		if LocalPlayer():HasAccess( "adduser" ) then
			menu:AddSpacer()
			local groupchange = menu:AddSubMenu( "Change Group" )
			for k,v in next, anus.Groups do
				groupchange:AddOption( v.name, function()
					LocalPlayer():ConCommand( "anus adduser " .. parent.panel.listview:GetLine( parent.panel.listview:GetSelectedLine() ):GetColumnText( 3 ) .. " " .. k )
					pnl:RequestFocus()
				end )
			end
		end
		menu.Think = function( pnl2 )
			if not IsValid( pnl ) then
				menu:Remove()
			end
		end
		menu:Open( posx, posy, true, pnl )
	end
	
	
	for k,v in next, sortable do
		k:SetSortValue( 4,
			table.Count( anus.Groups[ v ].Permissions )
		)
	end
	

	parent.panel.listview:SortByColumn( 1, false )
	
end

anus.RegisterCategory( CATEGORY )


