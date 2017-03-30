local aids = true
if aids then return end

-- made by shinycow, 2016
-- trying to have format as close to original made by Lexi (http://lex.me.uk/modules/sourcebans.lua)
--[[
    ~ Sourcebans 2 GLua Module ~

    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
    associated documentation files (the "Software"), to deal in the Software without restriction,
    including without limitation the rights to use, copy, modify, merge, publish, distribute,
    sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all copies or
    substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
    NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
    WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

    WARNING:
    Do *NOT* run with sourcemod active. It will have unpredictable effects!
--]]

require( "mysqloo" )

CreateConVar("sb_version", "2.00", bit.bor(FCVAR_SPONLY, FCVAR_REPLICATED, FCVAR_NOTIFY), "The current version of the SourceBans.lua module");

module( "sourcebans2", package.seeall )

local sbAdmins, sbAdminGroups
local function cleanIP( ip )
	return string.sub( ip, 1, #ip - 6 )
end

local function getAdminDetails( admin )
	if admin and IsValid( admin ) then
		local data = sbAdmins[ admin:SteamID() ]
		if data then
			return data.aid, cleanIP( admin:IPAddress() )
		end
	end
	
	return 0, cleanIP( game.GetIPAddress() )
end