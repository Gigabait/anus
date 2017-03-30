local psizew,psizeh = nil, nil
local bgColor = Color( 231, 230, 237, 255 )

local panel = {}

function panel:Init()

	self:SetSize( anus.universalWidth( 640 ), anus.universalHeight( 760 ) )
	self:Center()
	self:MakePopup()
	
	self.content = self:Add( "anus_contentpanel" )
	self.content:SetTitle( "Group Editor (2)" )
	self.content:Dock( FILL )
	self.content.Think = function( pnl )
		for k,v in next, pnl:GetChildren() do
			v:DockMargin( 20, 40, 20, 0 )
		end
	end

	self.content.body = self.content:Add( "anus_contentpanel" )
	self.content.body:Dock( FILL )
	self.content.body.Think = function( pnl )
		for k,v in next, pnl:GetChildren() do
			v:DockMargin( 20, 0, 20, 0 )
		end
	end
	
	local body = self.content.body
	
	body.grouptabs = body:Add( "DPropertySheet" )
	body.grouptabs:Dock( FILL )
	body.grouptabs.Think = function( pnl )
		if not pnl.HasItems or #pnl.Items == 0 then return end
		
		for k,v in next, pnl.Items do
			v.Tab.Paint = function( pnl, w, h )
				local bgColor = Color( 140, 140, 140, 255 )
				if pnl:GetPropertySheet():GetActiveTab() == pnl then
					bgColor = Color( 160, 160, 160, 255 )
				end
				draw.RoundedBox( 0, 0, 0, w, h, bgColor )
			end
			
			v.Tab.UpdateColours = function( pnl, skin )
				local active = pnl:GetPropertySheet():GetActiveTab() == pnl
				
				return pnl:SetTextStyleColor( Color( 230, 230, 230, 255 ) )
			end
			
			v.Panel.Paint = function() end
		end
		
		pnl.HasItems = true
	end
		
	body.grouptabs.ScrollPanel = body.grouptabs:Add( "anus_scrollpanel" )
	--parent.panel.content.SheetPnl.ScrollPnl:SetSize( parent.panel.content.SheetPnl:GetSize() / 7, parent.panel.content.SheetPnl:GetTall() )
	body.grouptabs.ScrollPanel:Dock( FILL ) --LEFT )
	body.grouptabs.ScrollPanel.Paint = function( pnl, w, h )
		local new_h = h
		if self.resizeNum and self.resizeNum > new_h then
			new_h = h - self.resizeNum
		elseif self.resizeNum then
			new_h = self.resizeNum
		end
		draw.RoundedBox( 0, 0, 0, w, 0, color_white )
	end
	body.grouptabs.ScrollPanel.Creations = {}
	
	local bodycontent = body.grouptabs.ScrollPanel.Creations
	
	
	
	local function createNewPanel( parent, header, customthink )
			-- i dont feel like incrementing
		local rand = math.random( 1, 99999 )
		body.grouptabs.ScrollPanel.Creations[ parent ][ "Spacer" .. rand ] = body.grouptabs.ScrollPanel.Creations[ parent ]:Add( "DPanel" )
		body.grouptabs.ScrollPanel.Creations[ parent ][ "Spacer" .. rand ]:Dock( TOP )
		body.grouptabs.ScrollPanel.Creations[ parent ][ "Spacer" .. rand ]:SetTall( anus.universalHeight( 15 ) )
		body.grouptabs.ScrollPanel.Creations[ parent ][ "Spacer" .. rand ].Paint = function() end
		
		body.grouptabs.ScrollPanel.Creations[ parent ][ "SubContents" .. rand ] = body.grouptabs.ScrollPanel.Creations[ parent ].SubContents or {}
		
		body.grouptabs.ScrollPanel.Creations[ parent ][ "SubContents" .. rand ].Base = body.grouptabs.ScrollPanel.Creations[ parent ]:Add( "DPanel" )
		body.grouptabs.ScrollPanel.Creations[ parent ][ "SubContents" .. rand ].Base:Dock( TOP )
		body.grouptabs.ScrollPanel.Creations[ parent ][ "SubContents" .. rand ].Base.Paint = function( pnl, w, h )
			--draw.RoundedBox( 0, 0, 0, w, h, Color( 105, 150, 150, 255 ) )
		end
		body.grouptabs.ScrollPanel.Creations[ parent ][ "SubContents" .. rand ].Base.Contents = {}
		
		body.grouptabs.ScrollPanel.Creations[ parent ][ "SubContents" .. rand ].Base.Contents[ "LabelPanel" ] = body.grouptabs.ScrollPanel.Creations[ parent ][ "SubContents" .. rand ].Base:Add( "DPanel" )
		body.grouptabs.ScrollPanel.Creations[ parent ][ "SubContents" .. rand ].Base.Contents[ "LabelPanel" ]:Dock( TOP )
		--body.grouptabs.ScrollPanel.Creations[ k ].SubContents.Base.Contents[ "LabelPanel" ]:SetTall( body.grouptabs.ScrollPanel.Creations[ k ].RankImage.Contents[ "LabelPanel" ]:GetTall() + 5 )	
		body.grouptabs.ScrollPanel.Creations[ parent ][ "SubContents" .. rand ].Base.Contents[ "LabelPanel" ].Paint = function() end
		
		body.grouptabs.ScrollPanel.Creations[ parent ][ "SubContents" .. rand ].Base.Contents[ "LabelPanel" ].LabelText = body.grouptabs.ScrollPanel.Creations[ parent ][ "SubContents" .. rand ].Base.Contents[ "LabelPanel" ]:Add( "DLabel" )
		body.grouptabs.ScrollPanel.Creations[ parent ][ "SubContents" .. rand ].Base.Contents[ "LabelPanel" ].LabelText:SetText( header )
		body.grouptabs.ScrollPanel.Creations[ parent ][ "SubContents" .. rand ].Base.Contents[ "LabelPanel" ].LabelText:SetFont( "anus_SmallText" )
		body.grouptabs.ScrollPanel.Creations[ parent ][ "SubContents" .. rand ].Base.Contents[ "LabelPanel" ].LabelText:SetTextColor( Color( 82, 82, 82, 255 ) )
		body.grouptabs.ScrollPanel.Creations[ parent ][ "SubContents" .. rand ].Base.Contents[ "LabelPanel" ].LabelText:SizeToContents()
		if customthink then
			body.grouptabs.ScrollPanel.Creations[ parent ][ "SubContents" .. rand ].Base.Contents[ "LabelPanel" ].LabelText.Think = function( pnl )
				customthink( pnl )
			end
		end
		
		body.grouptabs.ScrollPanel.Creations[ parent ][ "SubContents" .. rand ].Base.Contents[ "MainContent" ] = body.grouptabs.ScrollPanel.Creations[ parent ][ "SubContents" .. rand ].Base:Add( "DPanel" )
		body.grouptabs.ScrollPanel.Creations[ parent ][ "SubContents" .. rand ].Base.Contents[ "MainContent" ]:Dock( TOP )
		body.grouptabs.ScrollPanel.Creations[ parent ][ "SubContents" .. rand ].Base.Contents[ "MainContent" ]:SetTall( anus.universalHeight( 240 ) )
		body.grouptabs.ScrollPanel.Creations[ parent ][ "SubContents" .. rand ].Base.Contents[ "MainContent" ].Paint = function( pnl, w, h)
			draw.RoundedBox( 0, 0, 0, w, h, Color( 40, 40, 40, 255 ) )
		end
	
	end
	
	
	
	for k,v in next, anus.Groups do
		bodycontent[ k ] = body.grouptabs.ScrollPanel:Add( "DPanel" )
		
		bodycontent[ k ].BasicInfo = bodycontent[ k ]:Add( "DPanel" )
		bodycontent[ k ].BasicInfo:Dock( TOP )
		bodycontent[ k ].BasicInfo.Paint = function( pnl, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 60, 60, 60, 255 ) )
		end
		bodycontent[ k ].BasicInfo.TblInfo =
		{
			{ "Group Name", v.name, "DTextEntry" },
			{ "Group ID", k, "DTextEntry" },
			{ "Inheritance", v.Inheritance or "NONE", "DComboBox", function()
				local results = {}
				if k == "user" then return results end
				
				for a,b in next, anus.Groups do 
					results[ #results + 1 ] = a
				end
				return results
			end
			},
		}
		bodycontent[ k ].BasicInfo.Contents = {}
	
		for a,b in next, bodycontent[ k ].BasicInfo.TblInfo do
			bodycontent[ k ].BasicInfo.Contents[ b[ 1 ] ] = bodycontent[ k ].BasicInfo:Add( "DPanel" )
			bodycontent[ k ].BasicInfo.Contents[ b[ 1 ] ]:Dock( LEFT )
			--bodycontent[ k ].BasicInfo.Contents[ b[ 1 ] ].assigned = math.random( 10, 255 )
			bodycontent[ k ].BasicInfo.Contents[ b[ 1 ] ].Paint = function( pnl, w, h )
				--draw.RoundedBox( 0, 0, 0, w, h, Color( math.random( 100, 255 ), 25, 25, pnl.assigned ) )
			end

			bodycontent[ k ].BasicInfo.Contents[ b[ 1 ] ].Header = bodycontent[ k ].BasicInfo.Contents[ b[ 1 ] ]:Add( "DLabel" )
			bodycontent[ k ].BasicInfo.Contents[ b[ 1 ] ].Header:SetText( b[ 1 ] )
			bodycontent[ k ].BasicInfo.Contents[ b[ 1 ] ].Header:SetFont( "anus_SmallText" )
			bodycontent[ k ].BasicInfo.Contents[ b[ 1 ] ].Header:SetTextColor( Color( 82, 82, 82, 255 ) )
			bodycontent[ k ].BasicInfo.Contents[ b[ 1 ] ].Header:SizeToContents()
			--bodycontent[ k ].BasicInfo.Contents[ b[ 1 ] ].Header:SetPos(
			
			bodycontent[ k ].BasicInfo.Contents[ b[ 1 ] ].Content = bodycontent[ k ].BasicInfo.Contents[ b[ 1 ] ]:Add( b[ 3 ] )
			bodycontent[ k ].BasicInfo.Contents[ b[ 1 ] ].Content:SetText( b[ 2 ] )
			if b[ 4 ] and bodycontent[ k ].BasicInfo.Contents[ b[ 1 ] ].Content.AddChoice then
				for x,y in next, b[ 4 ]() do
					bodycontent[ k ].BasicInfo.Contents[ b[ 1 ] ].Content:AddChoice( y )
				end
				bodycontent[ k ].BasicInfo.Contents[ b[ 1 ] ].Content:AddChoice( "NONE" )
			end
			--bodycontent[ k ].BasicInfo.Contents[ b[ 1 ] ].Content:SetWide( anus.universalWidth( 125 ) )
		end
		
		createNewPanel( k, "Rank Color" )
		
		
		
		
		
		
		body.grouptabs:AddSheet( k, bodycontent[ k ], v.icon )
	end

	local old = body.grouptabs.SetActiveTab
	body.grouptabs.SetActiveTab = function( pnl, active )
		old( pnl, active )
		timer.Simple( 0, function()
			self:InvalidateLayout( true )
		end )
	end
		
	
	LocalPlayer().GroupEditors2 = LocalPlayer().GroupEditors2 or {}
	LocalPlayer().GroupEditors2[ self ] = true

end

function panel:PerformLayout( w, h )

	if not self.content.body.grouptabs.m_pActiveTab then return end

	local tabName = self.content.body.grouptabs.m_pActiveTab:GetText()
	local amount = #self.content.body.grouptabs.ScrollPanel.Creations[ tabName ].BasicInfo.TblInfo
	
	for k,v in next, self.content.body.grouptabs.ScrollPanel.Creations[ tabName ].BasicInfo.Contents do
		v:SetWide( v:GetParent():GetWide() / amount )
		
		surface.SetFont( v.Header:GetFont() )
		local headersizew, headersizeh = surface.GetTextSize( v.Header:GetText() )
		v.Header:SetPos( v:GetWide() / 2 - headersizew / 2, 5 )
		
		v.Content:SetWide( v:GetWide() / 1.5 )
		if not v:GetParent().OverridedTall then
			v:GetParent():SetTall( v:GetParent():GetTall() + v.Content:GetTall() )
			v:GetParent().OverridedTall = true
		end
		v.Content:SetPos( v:GetWide() / 2 - v.Content:GetWide() / 2, v:GetParent():GetTall() - v.Content:GetTall() )
		--v:GetParent():SetTall( 45 )
	end
	
	
end
	
	
concommand.Add( "closegroupeditor2", function()
	if not LocalPlayer().GroupEditors2 then return end
	for k,v in next, LocalPlayer().GroupEditors2 do
		k:Remove()
		LocalPlayer().GroupEditors2[ k ] = nil
	end
end )

function panel:Paint( w, h )
	draw.RoundedBox( 0, 0, 0, w, h, Color( 140, 140, 140, 255 ) ) 
	draw.RoundedBox( 0, 1, 1, w - 2, h - 2, color_white )
end
	
vgui.Register( "anus_groupeditor_new", panel, "EditablePanel" )