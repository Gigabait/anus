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
	Inheritance = "user",
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
	Inheritance = "trusted",
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
	Inheritance = "admin",
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
	Inheritance = "superadmin",
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

function anus.GetGroupInheritance( group )
	if not group then return nil end

	return anus.Groups[ group ].Inheritance
end

local function anus_GroupsInherit()
		-- insert into these groups that have already have all permissions synced.
	local has_inherited = {"user"}
	
	while table.Count( anus.Groups ) > table.Count( has_inherited ) do
		for k,v in pairs( anus.Groups ) do
			if not v.Inheritance then
				has_inherited[ #has_inherited + 1 ] =k
				continue
			end
			print( "hm", v.Inheritance )
			table.Inherit( v.Permissions, anus.Groups[ v.Inheritance ].Permissions )
			has_inherited[ #has_inherited + 1 ] = k
		end
	end
	
	local function runBaseClass( group, tbl )
		if tbl.BaseClass then
			table.Inherit( anus.Groups[ group ].Permissions, tbl.BaseClass )
			
			runBaseClass( group, tbl.BaseClass )
		end
		
		return nil
	end
end
hook.Add( "Initialize", "anus_groupinheritance", anus_GroupsInherit )
hook.Add( "inherit", "fa", anus_GroupsInherit )

