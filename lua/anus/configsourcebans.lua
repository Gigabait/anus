-- Hi, there's gonna be lots of debug messages here.
-- This is only partially supported. (I never sourcebans and am shit with SQL)
-- Edited original sourcebans module by lexi found here: http://lex.me.uk/modules/sourcebans.html
-- THIS IS FOR SOURCEBANS 2.0. SOURCEBANS 1.0 WON'T WORK.

	-- true/false
anus.enableSourceBans = false


if not anus.enableSourceBans then return end

require( "sourcebans" )

	-- configure below
	
sourcebans.SetConfig( "hostname", "" )
sourcebans.SetConfig( "username", "" )
sourcebans.SetConfig( "password", "" )
sourcebans.SetConfig( "database", "" )
sourcebans.SetConfig( "dbprefix", "sb" )
sourcebans.SetConfig( "portnumb", 3306 )
sourcebans.SetConfig( "serverid", 1 )

	-- ok now stop

sourcebans.Activate()