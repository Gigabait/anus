anus = anus or {}  

gameevent.Listen( "player_connect" )
gameevent.Listen( "player_disconnect" ) 

--[[ANUSAUTOREFRESH = ANUSAUTOREFRESH or {}
ANUSAUTOREFRESHNUMS = ANUSAUTOREFRESHNUMS or {}
local function smartReload( str, forceReload, reloadAll )
	local override = str 
		
	local exists = file.Exists( "anus/" .. str, "LUA" )
	if exists then
		override = "anus/" .. str
	end
	local size = file.Size( override, "LUA" )          
		
	if string.find( override, "anus" ) then     
		if (ANUSAUTOREFRESH[ str ] and ANUSAUTOREFRESH[ str ].size != size) or forceReload then
			print( "[ANUS] Smart Reload: " .. str .. " has a file difference; Reloading!" )
				 
			local fRead = file.Read( override, "LUA" )
			local fExplode = string.TrimRight( string.Explode( "\n", fRead )[ 1 ] )
				
				-- plz don't be over 64KB
			net.Start( "anus_FileReload" )
				net.WriteString( fRead )
			net.Broadcast()
			if string.sub( fExplode, 1, 15 ) == "ANUS_PARENTFILE" and not reloadAll then
				smartReload( string.sub( fExplode, 20, #fExplode - 1 ), true )
			elseif string.sub( fExplode, 1, 14 ) == "ANUS_RELOADALL" and not reloadAll then
				for k,v in ipairs( ANUSAUTOREFRESHNUMS ) do
					if v == "anus/init_cl.lua" then continue end
			    			
					smartReload( v, true, true )
				end
			end 
		end
		ANUSAUTOREFRESH[ str ] = { size = size, lastReload = CurTime() }
			
		local add = fals e
			
		if #ANUSAUTOREFRESHNUMS == 0 then
			add = true      
		else 
			for k,v in ipairs( ANUSAUTOREFRESHNUMS ) do
				if v == str then break end
				if k != #ANUSAUTOREFRESHNUMS then continue end
				
				add = true
			end
		end
			
		if add then
			ANUSAUTOREFRESHNUMS[ #ANUSAUTOREFRESHNUMS + 1 ] = str
		end 
	end
	oldacslf( str )
end

if not oldacslf then	
	oldacslf = AddCSLuaFile
	function AddCSLuaFile( str )
		if str then
			smartReload( str ) 
		else
			oldacslf( debug.getinfo( 2, "S" ).short_src )
		end
	end
end]]  
 

include( "anus/dependencies/von.lua" )               
include( "anus/configsql.lua" )
--include( "anus/dependencies/mysqlite.lua" )
include( "anus/init_sv.lua" )
	
AddCSLuaFile( "anus/init_cl.lua" )
	
	       
	         
	/*include( "anus/anus_init_sv.lua" )
	include( "anus/anus_init_sh.lua" )
	include( "anus/anus_bans_sv.lua" )
	AddCSLuaFile( "anus/anus_init_cl.lua" )
	AddCSLuaFile( "anus/anus_init_sh.lua" )
	include( "anus/anus_util_sv.lua" )
	include( "anus/anus_util_sh.lua" )
	AddCSLuaFile( "anus/anus_util_sh.lua" )
	AddCSLuaFile( "anus/anus_bans_c  l.lua" )
	include( "anus/anus_groups_sh.lua" )
	AddCSLuaFile( "anus/anus_groups_sh.lua" )
	include( "anus/anus_groups_sv.lua" )
	include( "anus/anus_player_sv.lua" )
	AddCSLuaFile( "anus/anus_player_cl.lua" )
	AddCSLuaFile( "anus/skins/anus.lua" )
	AddCSLuaFile( "anus/vgui/anus_content.lua" )
	AddCSLuaFile( "anus/vgui/anus_scrollbargrip.lua" )
	AddCSLuaFile( "anus/vgui/anus_dvscrollbar.lua" )
	AddCSLuaFile( "anus/vgui/anus_scrollpanel.lua" )
	AddCSLuaFile( "anus/vgui/anus_button.lua" )
	AddCSLuaFile( "anus/vgui/anus_listview_line.lua" )
	AddCSLuaFile( "anus/vgui/anus_listview_column.lua" )
	AddCSLuaFile( "anus/vgui/anus_listview.lua" )
	AddCSLuaFile( "anus/anus_vgui_cl.lua" )
	--[[include( "anus/anus_hooks_sh.lua" )
	AddCSLuaFile( "anus/anus_hooks_sh.lua" )
	include( "anus/anus_plugins_sh.lua" )
	AddCSLuaFile( "anus/anus_plugins_sh.lua" )]]
	AddCSLuaFile( "anus/vgui/anus_main.lua" )
	AddCSLuaFile( "anus/vgui/anus_votepanel.lua" )
	AddCSLuaFile( "anus/vgui/anus_groupeditor.lua" )
	AddCSLuaFile( "anus/vgui/anus_groupeditor_new.lua" )*/           