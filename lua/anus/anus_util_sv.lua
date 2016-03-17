	-- my own.
function anus.TeleportPlayer( from, to, bForce, testenum )
	if not to:IsInWorld() and not bForce then return false end
	
	local pos = {}
	local tries = 10
	local ang = 360
	
	for i=1,ang,tries do
		local rad = i * (3.14 / 180)
		local x = 45 * math.cos( rad )
		local y = 45 * math.sin( rad )
	
		pos[ #pos + 1 ] = to:GetPos() + Vector( x, y, 0 )
	end
	
	local tr = {}
	tr.start = to:GetPos()
	tr.endpos = pos[ 1 ]
	tr.filter = to
	
	local tried = 1
	
	local trace = util.TraceEntity( tr, from )
	while trace.Hit do
		tried = tried + 1 
		if not pos[ tried ] then
			if bForce then
				return pos[ 1 ]
			else
				return false
			end
		end
		
		tr.endpos = pos[ tried ]
		trace = util.TraceEntity( tr, from )
	end
	
	return pos[ tried ]
end