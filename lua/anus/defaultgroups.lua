--[[
	This file will not be used unless there is no data/anus/groups.txt file
	
	This is purely for factory installations.
]]--

anus.Groups[ "user" ] =
{
		-- Name shown to all
	name = "Guest",
		-- Inherits from which group
	Inheritance = nil,
		-- Base allow for who this group can run commands on
		-- (Overridable by plugins)
	can_target = "#user",
		-- Commands they have access to
	Permissions = {	},
		-- Group color
	color = Color( 0, 161, 255, 255 ),
		-- Group color
	icon = "icon16/user.png",
		-- Can't delete group, change group id
	hardcoded = true,
}

anus.Groups[ "trusted" ] =
{
	name = "Trusted Player",
	Inheritance = "user",
	can_target = "!%admin",
	Permissions =
	{
		[ "kick" ] = true,
		[ "gag" ] = true,
		[ "ungag" ] = true,
		--[ "ban" ] = { [ 2 ] = { min = "1s", max = "60m" } },
		[ "ban" ] = true,
	},
	color = Color( 33, 255, 0, 255 ),
	icon = "icon16/ruby_add.png",
}

anus.Groups[ "admin" ] =
{
	name = "Admin",
	Inheritance = "trusted",
	can_target = "!%superadmin",
	isadmin = true,
	Permissions = 
	{
		[ "ban" ] = true,
		[ "mute" ] = true,
		[ "unmute" ] = true,
		[ "slay" ] = true,
		[ "strip" ] = true,
		[ "arm" ] = true,
		[ "respawn" ] = true,
		[ "freeze" ] = true,
		[ "unfreeze" ] = true,
		[ "bring" ] = true,
		[ "god" ] = true,
		[ "ungod" ] = true,
		[ "noclip" ] = true,
	},
	color = Color( 95, 63, 127, 255 ),
	icon = "icon16/shield.png",
	--hardcoded = true,
}

anus.Groups[ "superadmin" ] =
{
	name = "SuperAdmin",
	Inheritance = "admin",
	can_target = "!#owner",
	isadmin = true,
	issuperadmin = true,
	Permissions =
	{
		[ "unban" ] = true,
		[ "banid" ] = true,
	},
	color = Color( 255, 93, 0, 255 ),
	icon = "icon16/shield_add.png",
	--hardcoded = true,
}

anus.Groups[ "owner" ] =
{
	name = "Owner",
	Inheritance = "superadmin",
	can_target = "*",
	isadmin = true,
	issuperadmin = true,
	Permissions =
	{
		[ "*" ] = true,
	},
	color = Color( 255, 0, 0, 255 ),
	icon = "icon16/lightning_add.png",
		-- can't delete or edit in any way
	hardcoded = true,
	}