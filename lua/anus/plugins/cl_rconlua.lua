local Category = {}

Category.pluginid = "lua"
Category.CategoryName = "Run Lua"

function Category:Initialize( parent )

	parent.panel = parent:Add( "anus_contentpanel" )
	parent.panel:SetTitle( "Run Lua" )
	parent.panel:Dock( FILL )

	parent.panel.textentry = parent.panel:Add( "DTextEntry" )
	parent.panel.textentry:SetMultiline( true )
	parent.panel.textentry:SetEditable( true )
	parent.panel.textentry:SetText( "" )
	parent.panel.textentry:Dock( FILL )
	parent.panel.textentry.GetAutoComplete = function( pnl, txt )
		local Output = LocalPlayer().anusStoredLuaAutoComplete or {}

		return Output
	end
		-- default autocomplete is broken.
		-- due to losing focus
	parent.panel.textentry.OpenAutoComplete = function( pnl, tab )

		if ( !tab ) then return end
		if ( #tab == 0 ) then return end

		pnl.Menu = DermaMenu()
		pnl.Menu:SetParent( pnl )

		for k, v in pairs( tab ) do

			pnl.Menu:AddOption( v, function() pnl:SetText( v ) pnl:SetCaretPos( v:len() ) pnl:RequestFocus() end )

		end

		local x, y = pnl:LocalToScreen( 0, pnl:GetTall() )
		pnl.Menu:SetMinimumWidth( pnl:GetWide() )
		pnl.Menu:Open( x, y, true, pnl ) 
		pnl.Menu:SetPos( x, y )
		pnl.Menu:SetMaxHeight( ( ScrH() - y ) - 10 )

	end
	
	parent.panel.runpanel = parent.panel:Add( "DPanel" )
	parent.panel.runpanel:Dock( BOTTOM )
	parent.panel.runpanel.Paint = function() end
	
	parent.panel.execute = parent.panel.runpanel:Add( "anus_button" )
	parent.panel.execute:SetText( "Execute Code" )
	parent.panel.execute:SetTextColor( Color( 140, 140, 140, 255 ) )
	parent.panel.execute:SetFont( "anus_SmallText" )
	parent.panel.execute:SizeToContents()
	parent.panel.execute:Dock( RIGHT )
	
	parent.panel.execute.DoClick = function()
		LocalPlayer().anusStoredLuaAutoComplete = LocalPlayer().anusStoredLuaAutoComplete or {}

		LocalPlayer().anusStoredLuaAutoComplete[ 5 ] = nil
		table.insert( LocalPlayer().anusStoredLuaAutoComplete, 1, parent.panel.textentry:GetText() )

		net.Start( "anus_CCPlugin_lua" )
			net.WriteString( parent.panel.textentry:GetText() )
		net.SendToServer()
	end
		
end

anus.registerCategory( Category )