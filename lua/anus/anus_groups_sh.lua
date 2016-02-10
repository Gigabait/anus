anus.Groups = anus.Groups or {}


anus.Groups[ "user" ] =
{
	id = 1,
	name = "Guest",
	Inheritance = nil,
	Permissions = {	},
	icon = "icon16/user.png",
}

--[[anus.Groups[ "commoner" ] =
{
	id = 2,
	name = "Commoner",
	Inheritance = 1,
	Permissions = {},
	icon = "icon16/user_green.png",
}

anus.Groups[ "respected" ] =
{
	id = 3,
	name = "Respected",
	Inheritance = 2,
	Permissions = {},
	icon = "icon16/user_orange.png",
}
	
anus.Groups[ "friend" ] =
{
	id = 4,
	name = "Friend",
	Inheritance = 3,
	Permissions = {},
	icon = "icon16/ruby.png",
}]]

anus.Groups[ "trusted" ] =
{
	id = 2,
	name = "Trusted Player",
	Inheritance = 1,
	Permissions =
	{
		["kick"] = true,
		["gag"] = true,
		["ungag"] = true,
		["ban60"] = true,
	},
	icon = "icon16/ruby_add.png",
}

anus.Groups[ "admin" ] =
{
	id = 3,
	name = "Admin",
	Inheritance = 2,
	isadmin = true,
	Permissions = 
	{
		["kick"] = true,
		["ban"] = true,
		["gag"] = true,
		["ungag"] = true,
		["mute"] = true,
		["unmute"] = true,
		["slay"] = true,
		["strip"] = true,
		["arm"] = true,
		["respawn"] = true,
		["freeze"] = true,
		["unfreeze"] = true,
		["bring"] = true,
	},
	icon = "icon16/shield.png",
}

anus.Groups[ "superadmin" ] =
{
	id = 4,
	name = "Superadmin",
	Inheritance = 3,
	isadmin = true,
	issuperadmin = true,
	Permissions =
	{
		["ban"] = true,
		["kick"] = true,
		["gag"] = true,
		["ungag"] = true,
		["mute"] = true,
		["unmute"] = true,
		["slay"] = true,
		["noclip"] = true,
		["god"] = true,
		["ungod"] = true,
		["unban"] = true,
		["strip"] = true,
		["arm"] = true,
		["banid"] = true,
		["respawn"] = true,
		["freeze"] = true,
		["unfreeze"] = true,
		["bring"] = true,
	},
	icon = "icon16/shield_add.png",
}

--[[anus.Groups[ "coowner" ] =
{
	id = 8,
	name = "Co-Owner",
	Inheritance = 7,
	isadmin = true,
	issuperadmin = true,
	Permissions =
	{
		["ban"] = true,
		["kick"] = true,
		["gag"] = true,
		["ungag"] = true,
		["mute"] = true,
		["unmute"] = true,
		["slay"] = true,
		["adduser"] = true,
		["noclip"] = true,
		["adduser_temp"] = true,
		["god"] = true,
		["ungod"] = true,
		["unban"] = true,
		["configuregroups"] = true,
		["strip"] = true,
		["arm"] = true,
		["banid"] = true,
		["respawn"] = true,
		["freeze"] = true,
		["unfreeze"] = true,
		["bring"] = true,
	},
	icon = "icon16/lightning.png",
		-- can edit perms, can't delete.
	candelete = false,
}]]

anus.Groups[ "owner" ] =
{
	id = 5,
	name = "Owner",
	Inheritance = 4,
	isadmin = true,
	issuperadmin = true,
	Permissions =
	{
			-- no need to add anything in here anymore, owner has everything.
		["ban"] = true,
		["banf"] = true,
		["kick"] = true,
		["gag"] = true,
		["ungag"] = true,
		["mute"] = true,
		["unmute"] = true,
		["slay"] = true,
		["noclip"] = true,
		["spray"] = true,
		["adduser"] = true,
		["addusertemp"] = true,
		["god"] = true,
		["ungod"] = true,
		["unban"] = true,
		["configuregroups"] = true,
		["strip"] = true,
		["arm"] = true,
		["banid"] = true,
		["respawn"] = true,
		["freeze"] = true,
		["unfreeze"] = true,
		["adduserid"] = true,
	},
	icon = "icon16/lightning_add.png",
		-- can't delete or edit in any way
	hardcoded = true,
}

hook.Add("InitPostEntity", "anus_FixGroups", function()
	
	if not SERVER then return end
	
	timer.Simple(0.1, function()
		if not file.Exists("anus/groups.txt", "DATA") then
			print("hey we should do something here right guys")
		end
	end)

end)

