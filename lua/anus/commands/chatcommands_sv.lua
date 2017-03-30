local ChatCommands = {}
chatcommand = {}
function chatcommand.GetTable()
	return ChatCommands
end
function chatcommand.Add( name, func )
	ChatCommands[ name ] = func
end
function chatcommand.Remove( name )
	ChatCommands[ name ] = nil
end

hook.Add( "PlayerSay", "anus_ChatCommandsHandler", function( pl, txt, all )
	local Tab = string.Explode( " ", txt )
	local Func = ChatCommands[ Tab[ 1 ] ]

	if Func then
		local Cmd = Tab[ 1 ]
		table.remove( Tab, 1 )

		local ShowTxt = Func( pl, Cmd, Tab )
		if ShowTxt != nil and ShowTxt == true or ShowTxt == nil then
			return txt
		else
			return ""
		end
	end	
end )