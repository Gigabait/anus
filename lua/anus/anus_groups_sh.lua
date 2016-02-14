anus.Groups = anus.Groups or {}

anus.Groups[ "user" ] =
{
	id = 1,
	name = "Guest",
	Inheritance = nil,
	Permissions = {	},
	icon = "icon16/user.png",
}

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
		["ban"] = true,
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
		["noclip"] = true,
		["god"] = true,
		["ungod"] = true,
		["unban"] = true,
		["banid"] = true,
	},
	icon = "icon16/shield_add.png",
}

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

function anus.CountGroupsAccess( plugin )
	local count = 0
	local groups = {}
	for k,v in next, anus.Groups do
		if v.Permissions[ plugin ] then
			count = count + 1
			groups[ #groups + 1 ] = k
		end
	end
		
	return count, groups
end

hook.Add("InitPostEntity", "anus_FixGroups", function()
	
	if not SERVER then return end
	
	timer.Simple(0.1, function()
		if not file.Exists("anus/groups.txt", "DATA") then
			print("hey we should do something here right guys")
		end
	end)

end)

