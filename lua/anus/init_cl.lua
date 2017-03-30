anus.Groups = anus.Groups or {}
anus.pluginsTable = {}
anus.Bans = anus.Bans or {}
_R = debug.getregistry()

include( "init_sh.lua" )
include( "shortcuts/shortcuts_sh.lua" )
include( "extensions/string.lua" )
include( "utility/util_sh.lua" )
include( "commands/autocomplete_cl.lua" )
include( "commands/consolecommands_sh.lua" )
include( "base_cl.lua" )
include( "extensions/player_cl.lua" )
include( "networking/playerdata_cl.lua" )
include( "networking/playerdisconnects_sh.lua" )
include( "voting/voting_cl.lua" )
include( "networking/filereload_sh.lua" )
include( "menu/init_cl.lua" )

anus.loadPlugins()

MsgC( Color( 240, 25, 25, 255 ), "[ANUS] Prepared and ready to go.\n" ) 

--[[---------------------------------------------------------
	Clear the focus when we click away from us..
	
	Featuring a fixed autocomplete.
-----------------------------------------------------------]]
hook.Add( "InitPostEntity", "anus_FixTextEntryLoseFocus", function()
	function TextEntryLoseFocus( panel, mcode )

		local pnl = vgui.GetKeyboardFocus()
		if ( !pnl ) then return end
		if ( pnl == panel ) then return end
		if ( !pnl.m_bLoseFocusOnClickAway ) then return end
		if ( panel.ClassName and panel.ClassName == "DMenuOption" ) then return end
		--if ( panel.GetParent and panel:GetParent() ) and pnl == panel:GetParent() or pnl == panel:GetParent():GetParent() or ( pnl == panel:GetParent():GetParent():GetParent() ) then return end
		
		pnl:FocusNext()

	end
	hook.Add( "VGUIMousePressed", "TextEntryLoseFocus", TextEntryLoseFocus )
end )