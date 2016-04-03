anus.MenuCategories = {}

function anus.AddCategory( tbl )
	anus.MenuCategories[ tbl.CategoryName ] =
	{
	pluginid = tbl.pluginid,
	CategoryName = tbl.CategoryName,
	Initialize = tbl.Initialize, 
	}
end

function createVote( title, args, time )
	if VOTEPANEL and IsValid( VOTEPANEL ) then
		VOTEPANEL:Remove()
		VOTEPANEL = nil
	end
	
	time = time or 15

	VOTEPANEL = vgui.Create( "anus_votepanel" )
	VOTEPANEL:SetTitle( title )
	VOTEPANEL:SetTime( time )
	local addheight = 0
	for k,v in next, args or {} do
		--print( VOTEPANEL:GetTall() )
		--VOTEPANEL:SetTall( VOTEPANEL:GetTall() + 44 )--50 )
		VOTEPANEL.ContentPanel.OptionsPanel:SetTall( VOTEPANEL.ContentPanel.OptionsPanel:GetTall() + 40 )
		
		--print( "optionstall", VOTEPANEL.ContentPanel.OptionsPanel:GetTall() )
		
		if k == #args then
			VOTEPANEL:AddOption( k, v, true )
		else
			VOTEPANEL:AddOption( k, v, false )
		end
	end
	
	VOTEPANEL:SetTall( VOTEPANEL:GetTall() + VOTEPANEL.ContentPanel.OptionsPanel:GetTall() + 10 + 5 + 1)
	
	timer.Create( "anus_EndVote", time, 1, function()
		endVote()
	end )
end

function endVote()
	if VOTEPANEL and IsValid( VOTEPANEL ) then
		VOTEPANEL:Remove()
		VOTEPANEL = nil
	end
end