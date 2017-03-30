if SERVER then
	AddCSLuaFile( "anus/menu/base/anus_content.lua" )
	AddCSLuaFile( "anus/menu/base/anus_scrollbargrip.lua" )
	AddCSLuaFile( "anus/menu/base/anus_dvscrollbar.lua" )
	AddCSLuaFile( "anus/menu/base/anus_scrollpanel.lua" )
	AddCSLuaFile( "anus/menu/base/anus_button.lua" )
	AddCSLuaFile( "anus/menu/base/anus_listview_line.lua" )
	AddCSLuaFile( "anus/menu/base/anus_listview_column.lua" )
	AddCSLuaFile( "anus/menu/base/anus_listview.lua" )
	--AddCSLuaFile( "anus/anus_vgui_cl.lua" )
	AddCSLuaFile( "anus/menu/base/anus_main.lua" )
	--AddCSLuaFile( "anus/menu/base/anus_votepanel.lua" )
	--AddCSLuaFile( "anus/menu/base/anus_groupeditor.lua" )
	--AddCSLuaFile( "anus/menu/base/anus_groupeditor_old.lua" )
	AddCSLuaFile( "anus/menu/base/anus_dcomboboxeditable.lua" )
	AddCSLuaFile( "anus/menu/base/anus_dlistboxdivider.lua" )
end

local files, dirs = file.Find( "anus/menu/categories/*.lua", "LUA" ) 
for k,v in next, files do
	AddCSLuaFile( "anus/menu/categories/" .. v )
end