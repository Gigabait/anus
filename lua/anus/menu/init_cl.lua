anus_mainMenu = anus_mainMenu

CreateClientConVar( "anus_smallified", "0", true, true, "Show a miniaturized menu" )
local cvarsmall = GetConVar( "anus_smallified" )
function anus.universalWidth( number )
	return ( number / (cvarsmall:GetString() == "0" and 1440 or 1680 ) ) * ScrW()
end
function anus.universalHeight( number )
	return ( number / (cvarsmall:GetString() == "0" and 900 or 1050 ) ) * ScrH()
end

anus.menuCategories = {}

local Panel_MetaTable = FindMetaTable( "Panel" )

function anus.addCategory( tbl )
	anus.menuCategories[ tbl.CategoryName ] = {
	pluginid = tbl.pluginid,
	CategoryName = tbl.CategoryName,
	Initialize = tbl.Initialize,
	Refresh = tbl.Refresh
	}
	
	return tbl
end

if CLIENT then
	include( "anus/menu/base/anus_content.lua" )
	include( "anus/menu/base/anus_scrollbargrip.lua" )
	include( "anus/menu/base/anus_dvscrollbar.lua" )
	include( "anus/menu/base/anus_scrollpanel.lua" )
	include( "anus/menu/base/anus_button.lua" )
	include( "anus/menu/base/anus_listview_line.lua" )
	include( "anus/menu/base/anus_listview_column.lua" )
	include( "anus/menu/base/anus_listview.lua" )
	--include( "anus/anus_vgui_cl.lua" )
	include( "anus/menu/base/anus_main.lua" )
	--include( "anus/menu/base/anus_votepanel.lua" )
--include( "anus/menu/base/anus_groupeditor.lua" )
	--include( "anus/menu/base/anus_groupeditor_old.lua" )
	include( "anus/menu/base/anus_dcomboboxeditable.lua" )
	include( "anus/menu/base/anus_dlistboxdivider.lua" )
end

local Files, Dirs = file.Find( "anus/menu/categories/*.lua", "LUA" )
for k,v in next, Files do
	include( "anus/menu/categories/" .. v )
end

hook.Add( "OnPlayerChat", "anus_ToggleMenu", function( pl, txt )
	if pl == LocalPlayer() and txt == "!menu" then
		RunConsoleCommand( "anus_menu" )
	end
end )

hook.Add( "OnReloaded", "anus_closemenus", function()
	--[[if IsValid( anus_mainMenu ) then
		anus_mainMenu:Remove()
		anus_mainMenu = nil
	end]]
end )

local function CreateMainMenu( pl, cmd )
	if IsValid( anus_mainMenu ) then
		anus_mainMenu:ToggleVisible()
		--anus_mainMenu:Show()
		--[[anus_mainMenu:Remove()
		anus_mainMenu = nil
		
		if string.sub( cmd, 1, 1 ) != "+" then
			gui.EnableScreenClicker( false )
		end]]
	else
		anus_mainMenu = vgui.Create( "anus_mainmenu" )
	end
end
concommand.Add( "+anus_menu", CreateMainMenu )
concommand.Add( "-anus_menu", CreateMainMenu )
concommand.Add( "anus_menu", CreateMainMenu )

concommand.Add( "anus_menurefresh", function()
	if IsValid( anus_mainMenu ) then
		anus_mainMenu:Remove()
		anus_mainMenu = nil
	end
end )