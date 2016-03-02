anus.Groups = anus.Groups or {}

print( "load groups" )

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
	--local output = {}
	for k,v in pairs( anus.Groups ) do
		if not v.Inheritance then continue end
		
		--output[ k ] = {}
		
		local function loopThrough( group, inheritance, permissions )
				-- will need to manually sort through and replace all occurences'
			
				-- for debugging
			--output[ group ][ inheritance ] = output[ group ][ inheritance ] or {}
			--output[ group ][ inheritance ] = permissions
			--print( "group: " .. group, "inheritance: ", inheritance )

			for a,b in pairs( permissions ) do
				anus.Groups[ group ].Permissions[ a ] = b
			end
			
			if not anus.Groups[ inheritance ].Inheritance then return end
	
			if anus.Groups[ inheritance ].Inheritance then
				loopThrough( group, anus.Groups[ inheritance ].Inheritance, anus.Groups[ anus.Groups[ inheritance ].Inheritance ].Permissions )
			end
		end
		
		loopThrough( k, v.Inheritance, anus.Groups[ v.Inheritance ].Permissions )
	end
	
	--THEOUTPUT = output
end
hook.Add( "Initialize", "anus_groupinheritance", anus_GroupsInherit )
hook.Add( "inherit", "fa", anus_GroupsInherit )

function anus.CreateGroup( name, inheritance )
	if not name then
		error( "Name not found!")
	end
	if not inheritance then
		error( "Inheritance not found!" )
	end
	
	local inherit = anus.Groups[ inheritance ] and inheritance or "user"
	
		-- id key is really not neccessary.
		-- remnants left over from old permission checking
		-- todo for that ^: Add function to return groups inherited from
		-- use that for every check for ids.
	anus.Groups[ name:lower() ] =
	{
	id = math.random( 6, 99999 ),
	name = name,
	Inheritance = inherit,
	Permissions = {},
	icon = "",
	}
	
	anus_GroupsInherit()
end