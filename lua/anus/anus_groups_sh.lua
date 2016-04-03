if SERVER then
	anus.Groups = anus.Groups or {}
elseif CLIENT and not anus.Groups then
	anus.Groups = {}

	anus.Groups[ "user" ] =
	{
		--id = 1,
		name = "Guest",
		Inheritance = nil,
		Permissions = {	},
		color = Color( 0, 161, 255, 255 ),
		icon = "icon16/user.png",
	}

	anus.Groups[ "trusted" ] =
	{
		--id = 2,
		name = "Trusted Player",
		Inheritance = "user",
		Permissions =
		{
			["kick"] = true,
			["gag"] = true,
			["ungag"] = true,
			["ban"] = { [ 2 ] = { min = "1s", max = "60m" } },
		},
		color = Color( 33, 255, 0, 255 ),
		icon = "icon16/ruby_add.png",
	}

	anus.Groups[ "admin" ] =
	{
		--id = 3,
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
		color = Color( 95, 63, 127, 255 ),
		icon = "icon16/shield.png",
	}

	anus.Groups[ "superadmin" ] =
	{
		--id = 4,
		name = "SuperAdmin",
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
		color = Color( 255, 93, 0, 255 ),
		icon = "icon16/shield_add.png",
	}

	anus.Groups[ "owner" ] =
	{
		--id = 5,
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
		color = Color( 255, 0, 0, 255 ),
		icon = "icon16/lightning_add.png",
			-- can't delete or edit in any way
		hardcoded = true,
	}
end

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

function anus.GetGroupInheritanceTree( group )
	if not group then return nil end
	if not anus.Groups[ group ].Inheritance then return { group } end
	
	
	local output = {}
	output = { group }
	
	local function loopThrough( prev, inheritance )
		output[ #output + 1 ] = inheritance
		
		if anus.Groups[ inheritance ].Inheritance then
			loopThrough( inheritance, anus.Groups[ inheritance ].Inheritance )
		end
	end
	loopThrough( nil, anus.Groups[ group ].Inheritance )
	
	return output
end

function anus.GroupHasInheritanceFrom( group1, group2, samegroup )
	if not group1 or not group2 then return nil end
	if group1 == group2 and not samegroup then return false end
	
	local tree = anus.GetGroupInheritanceTree( group1 )
	for k,v in next, tree do
		if v == group2 then
			return true
		end
	end
	
	return false
end
		

local function anus_GroupsInherit()
	for k,v in next, anus.Groups do
		if not v.Inheritance then continue end
		
		local function loopThrough( group, inheritance, permissions )
			for a,b in next, permissions do
				anus.Groups[ group ].Permissions[ a ] = b
			end
			
			if not anus.Groups[ inheritance ].Inheritance then return end
	
			if anus.Groups[ inheritance ].Inheritance then
				loopThrough( group, anus.Groups[ inheritance ].Inheritance, anus.Groups[ anus.Groups[ inheritance ].Inheritance ].Permissions )
			end
		end
		
		loopThrough( k, v.Inheritance, anus.Groups[ v.Inheritance ].Permissions )
	end
end
hook.Add( "Initialize", "anus_groupinheritance", anus_GroupsInherit )
hook.Add( "inherit", "fa", anus_GroupsInherit )

function anus.CreateGroup( id, name, inheritance, icon )
	if not id or not name then
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
	anus.Groups[ id:lower() ] =
	{
	--id = math.random( 6, 99999 ),
	name = name,
	Inheritance = inherit,
	Permissions = {},
	icon = icon or "",
	}
	
	anus_GroupsInherit()
	
	return anus.Groups[ name:lower() ]
end

function anus.RemoveGroup( id )
	if not id then 
		error( "ID not found!" )
	end
	
	anus.Groups[ id:lower() ] = nil
	
	anus_GroupsInherit()
end

if CLIENT then
	net.Receive( "anus_broadcastgroups", function()
		print( "TEST" )
		anus.Groups = net.ReadTable()
	end )
end