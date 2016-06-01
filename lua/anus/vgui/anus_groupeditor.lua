local panel = {}

local psizew,psizeh = nil, nil
local bgColor = Color( 231, 230, 237, 255 )


--[[function panel:RebuildContents()
	self.ContentPanel = self.ContentPanel or self:Add( "DPanel" )
	self.ContentPanel:SetPos( 0, 0 )
	self.ContentPanel:SetSize( self:GetWide(), self:GetTall() - self.TitlePanel:GetTall() )
	self.ContentPanel:Dock( FILL )
	self.ContentPanel.Paint = function( pnl, w, h )
		--draw.RoundedBox( 0, 0, 0, w, h, Color( 100, 50, 50, 255 ) )
	end
	
	self.ContentPanel.OptionsPanel = self.ContentPanel.OptionsPanel or self.ContentPanel:Add( "DPanel" )
	self.ContentPanel.OptionsPanel:SetPos( 10, 10 + 1 )
	self.ContentPanel.OptionsPanel:SetSize( self.ContentPanel:GetWide() - 20, self.ContentPanel:GetTall() - 20 )
	self.ContentPanel.OptionsPanel.Paint = function( pnl, w, h )
	end
	self.ContentPanel.OptionsPanel.Vote = self.ContentPanel.OptionsPanel.Vote or {}
end]]
	
function panel:Init()
	psizew, psizeh = anus.UniversalWidth( 640 ), anus.UniversalHeight( 760 )
	self:SetSize( psizew, psizeh )
	self:Center()
	self:MakePopup()
	
	local parent = self
	
	parent.panel = parent:Add( "anus_contentpanel" )
	parent.panel:SetTitle( "Group Editor" )
	parent.panel:Dock( FILL )
	parent.panel.Think = function( pnl )
		for k,v in next, pnl:GetChildren() do
			v:DockMargin( 20, 40, 20, 0 )
		end
	end
	
	parent.panel.content = parent.panel:Add( "anus_contentpanel" )
	parent.panel.content:Dock( FILL )
	parent.panel.content.Think = function( pnl )
		for k,v in next, pnl:GetChildren() do
			v:DockMargin( 20, 0, 20, 0 )
		end
	end
	
	parent.panel.content.SheetPnl = parent.panel.content:Add( "DPropertySheet" )
	parent.panel.content.SheetPnl:Dock( FILL )
	timer.Simple( 0.1, function()
	for k,v in next, parent.panel.content.SheetPnl.Items do
		v.Tab.Paint = function( pnl, w, h )
			local bgColor = Color( 140, 140, 140, 255 )
			if pnl:GetPropertySheet():GetActiveTab() == pnl then
				bgColor = Color( 160, 160, 160, 255 )
			end
			draw.RoundedBox( 0, 0, 0, w, h, bgColor )
		end
		
		v.Tab.UpdateColours = function( pnl, skin )
			local active = pnl:GetPropertySheet():GetActiveTab() == pnl
			
			--if active then
			return pnl:SetTextStyleColor( Color( 230, 230, 230, 255 ) )
		end
		
		v.Panel.Paint = function() end
	end
	end )
	parent.panel.content.SheetPnl.Paint = function() end
	--parent.panel.content.SheetPnl.tabScroller.Paint = function() end
	--parent.panel.content.SheetPnl.Creations = {}
	
	parent.panel.content.SheetPnl.ScrollPnl = parent.panel.content.SheetPnl:Add( "anus_scrollpanel" )
	parent.panel.content.SheetPnl.ScrollPnl:SetSize( parent.panel.content.SheetPnl:GetSize() / 7, parent.panel.content.SheetPnl:GetTall() )
	parent.panel.content.SheetPnl.ScrollPnl:Dock( FILL ) --LEFT )
	parent.panel.content.SheetPnl.ScrollPnl.Paint = function( pnl, w, h )
		local new_h = h
		if self.resizeNum and self.resizeNum > new_h then
			new_h = h - self.resizeNum
		elseif self.resizeNum then
			new_h = self.resizeNum
		end
		draw.RoundedBox( 0, 0, 0, w, 0, color_white )
	end
	parent.panel.content.SheetPnl.ScrollPnl.Creations = {}
	
	local creations = parent.panel.content.SheetPnl.ScrollPnl.Creations
	
	for k,v in next, anus.Groups do
		creations[ k ] = parent.panel.content.SheetPnl.ScrollPnl:Add( "DPanel" )
		
		creations[ k ].BasicInfo = creations[ k ]:Add( "DPanel" )
		creations[ k ].BasicInfo:Dock( TOP )
		creations[ k ].BasicInfo.Paint = function() end
		--print( "s", parent.panel.content.SheetPnl.Creations[ k ].BasicInfo:GetWide(), parent.panel.content.SheetPnl:GetWide(), parent.panel.content:GetWide(), parent.panel:GetWide(), parent:GetWide() ) 
		creations[ k ].BasicInfo.TblInfo =
		{
			{ "Group Name", v.name },
			{ "Group ID", k },
			{ "Inheritance", v.Inheritance or "" },
		}
		creations[ k ].BasicInfo.Contents = {}
		
		for a,b in next, creations[ k ].BasicInfo.TblInfo do
			creations[ k ].BasicInfo.Contents[ b[ 1 ] ] = creations[ k ].BasicInfo:Add( "DPanel" )
			creations[ k ].BasicInfo.Contents[ b[ 1 ] ]:Dock( LEFT )
			creations[ k ].BasicInfo.Contents[ b[ 1 ] ].Paint = function() end

			creations[ k ].BasicInfo.Contents[ b[ 1 ] ].Header = creations[ k ].BasicInfo.Contents[ b[ 1 ] ]:Add( "DLabel" )
			creations[ k ].BasicInfo.Contents[ b[ 1 ] ].Header:SetText( b[ 1 ] )
			creations[ k ].BasicInfo.Contents[ b[ 1 ] ].Header:SetFont( "anus_SmallText" )
			creations[ k ].BasicInfo.Contents[ b[ 1 ] ].Header:SetTextColor( Color( 82, 82, 82, 255 ) )
			--parent.panel.content.SheetPnl.Creations[ k ].BasicInfo.Contents[ b[ 1 ] ].Header:Dock( LEFT )
			creations[ k ].BasicInfo.Contents[ b[ 1 ] ].Header:SizeToContents()
			creations[ k ].BasicInfo.Contents[ b[ 1 ] ].Header.Think = function( pnl )
				if not pnl:GetParent().OverridedSetWide or pnl.OverridedSetPos then return end
				
				--if a == 1 then -- != #parent.panel.content.SheetPnl.Creations[ k ].BasicInfo.TblInfo then
					creations[ k ].BasicInfo.Contents[ b[ 1 ] ].Header:SetPos( 20, 2 )
				--[[elseif a == 2 then
					parent.panel.content.SheetPnl.Creations[ k ].BasicInfo.Contents[ b[ 1 ] ].Header:SetPos( 60, 2 )
				else
					--print( "a", parent.panel.content.SheetPnl.Creations[ k ].BasicInfo.Contents[ b[ 1 ] ]:GetWide()  )
					parent.panel.content.SheetPnl.Creations[ k ].BasicInfo.Contents[ b[ 1 ] ].Header:SetPos( pnl:GetParent():GetWide() - pnl:GetWide() - 20  , 2 )
				end]]
				
				pnl.OverridedSetPos = true
			end
			--print( "a", parent.panel.content.SheetPnl.Creations[ k ].BasicInfo:GetWide(), #parent.panel.content.SheetPnl.Creations[ k ].BasicInfo.TblInfo )
			parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].BasicInfo.Contents[ b[ 1 ] ]:SetWide( 100 / #parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].BasicInfo.TblInfo )--parent.panel.content.SheetPnl.Creations[ k ].BasicInfo.Contents[ b[ 1 ] ].Header:GetWide() * 2 )
			parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].BasicInfo.Contents[ b[ 1 ] ].Think = function( pnl )
				if pnl.CheckTime and pnl.CheckTime < CurTime() then return end
				
				if not pnl.CheckTime then
					pnl.CheckTime = CurTime() + 0.25
				else
					if pnl.CheckTime >= CurTime() then
						--print( parent.panel.content.SheetPnl.Creations[ k ].BasicInfo:GetWide() )
						pnl:SetWide( parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].BasicInfo:GetWide() / #parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].BasicInfo.TblInfo )
						--pnl:SetTall( 100 )
						--pnl:GetParent():SetTall( 100 )
						pnl:GetParent().OverridedSetTall = pnl:GetParent().OverridedSetTall or pnl:GetParent():GetTall() + pnl.Content:GetTall() + 5
						pnl:GetParent():SetTall( pnl:GetParent().OverridedSetTall )
						pnl.OverridedSetWide = true
					end
				end
			end

			parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].BasicInfo.Contents[ b[ 1 ] ].Content = parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].BasicInfo.Contents[ b[ 1 ] ]:Add( "DTextEntry" )
			parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].BasicInfo.Contents[ b[ 1 ] ].Content:SetText( b[ 2 ] )
			--parent.panel.content.SheetPnl.Creations[ k ].BasicInfo.Contents[ b[ 1 ] ].Content:SetFont( "anus_SmallText" )
			parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].BasicInfo.Contents[ b[ 1 ] ].Content:SetWide( anus.UniversalWidth( 125 ) )
			parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].BasicInfo.Contents[ b[ 1 ] ].Content.Think = function( pnl )
				if not pnl:GetParent().OverridedSetWide or pnl.OverridedSetPos then return end
				
				pnl.OverridedSetPos = true
				
				local headerposx, headerposy = parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].BasicInfo.Contents[ b[ 1 ] ].Header:GetPos()
				parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].BasicInfo.Contents[ b[ 1 ] ].Content:SetPos( headerposx + 5, headerposy + parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].BasicInfo.Contents[ b[ 1 ] ].Header:GetTall() + 5  )
			end
			--parent.panel.content.SheetPnl.Creations[ k ].BasicInfo.Contents[ b[ 1 ] ].Content:SetDisabled( true )
			
			
			--parent.panel.content.SheetPnl.Creations[ k ].RankColor
			
			
			
			--parent.panel.content.SheetPnl.Creations[ k ].BasicInfo[ b[ 1 ] ]:Dock( TOP )
			--parent.panel.content.SheetPnl.Creations[ k ].BasicInfo.Contents[ b[ 1 ] ].Header:SetPos( 5^a, 5 )
			--parent.panel.content.SheetPnl.Creations[ k ].BasicInfo.Contents[ b[ 1 ] ].Header:SizeToContents()
			
			--[[parent.panel.content.SheetPnl.Creations[ k ].BasicInfo.Contents[ b[ 2 ] ] = parent.panel.content.SheetPnl.Creations[ k ]:Add( "DLabel" )
			parent.panel.content.SheetPnl.Creations[ k ].BasicInfo.Contents[ b[ 2 ] ]:SetText( b[ 2 ] )
			parent.panel.content.SheetPnl.Creations[ k ].BasicInfo[ b[ 2 ] ]:SetFont( "anus_SmallText" )
			parent.panel.content.SheetPnl.Creations[ k ].BasicInfo[ b[ 2 ] ]:SetTextColor( Color( 10, 10, 10, 255 ) )
			parent.panel.content.SheetPnl.Creations[ k ].BasicInfo[ b[ 2 ] ]:Dock( TOP )]]
		end
		
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].Spacer1 = parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ]:Add( "DPanel" )
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].Spacer1:Dock( TOP )
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].Spacer1:SetTall( anus.UniversalHeight( 15 ) )
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].Spacer1.Paint = function() end
		
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankColor = parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ]:Add( "DPanel" )
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankColor:Dock( TOP )
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankColor.Paint = function( pnl, w, h )
			--draw.RoundedBox( 0, 0, 0, w, h, Color( 150, 150, 150, 255 ) )
		end
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankColor.Contents = {}
			
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankColor.Contents[ "LabelPanel" ] = parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankColor:Add( "DPanel" )
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankColor.Contents[ "LabelPanel" ]:Dock( TOP )
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankColor.Contents[ "LabelPanel" ]:SetTall( parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankColor.Contents[ "LabelPanel" ]:GetTall() + 5 )	
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankColor.Contents[ "LabelPanel" ].Paint = function() end
		
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankColor.Contents[ "LabelPanel" ].RankLabel = parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankColor.Contents[ "LabelPanel" ]:Add( "DLabel" )
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankColor.Contents[ "LabelPanel" ].RankLabel:SetText( "Rank Color" )
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankColor.Contents[ "LabelPanel" ].RankLabel:SetFont( "anus_SmallText" )
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankColor.Contents[ "LabelPanel" ].RankLabel:SetTextColor( Color( 82, 82, 82, 255 ) )
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankColor.Contents[ "LabelPanel" ].RankLabel:SizeToContents()
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankColor.Contents[ "LabelPanel" ].RankLabel.Think = function( pnl )
			pnl:SetTextColor( parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankColor.Contents[ "ColorPanel" ].RankColor:GetColor() )
		end
		
			
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankColor.Contents[ "ColorPanel" ] = parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankColor:Add( "DPanel" )
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankColor.Contents[ "ColorPanel" ]:Dock( TOP )
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankColor.Contents[ "ColorPanel" ]:SetTall( anus.UniversalHeight( 240 ) )
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankColor.Contents[ "ColorPanel" ].Paint = function( pnl, w, h)
			--draw.RoundedBox( 0, 0, 0, w, h, Color( 10, 10, 10, 255 ) )
		end
			
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankColor.Contents[ "ColorPanel" ].RankColor = parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankColor.Contents[ "ColorPanel" ]:Add( "DColorMixer" )
		--parent.panel.content.SheetPnl.Creations[ k ].RankColor.Contents[ "ColorPanel" ].RankColor:Dock( FILL )
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankColor.Contents[ "ColorPanel" ].RankColor:SetAlphaBar( false )
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankColor.Contents[ "ColorPanel" ].RankColor:SetColor( v.color )
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankColor.Contents[ "ColorPanel" ].RankColor:SetWide( anus.UniversalWidth( 540 ) )

		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankColor:SetTall( parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankColor.Contents[ "ColorPanel" ].RankColor:GetTall() + parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankColor.Contents[ "LabelPanel" ]:GetTall() )
		
		
		
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].Spacer2 = parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ]:Add( "DPanel" )
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].Spacer2:Dock( TOP )
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].Spacer2:SetTall( anus.UniversalHeight( 15 ) )
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].Spacer2.Paint = function() end
		
		
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankImage = parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ]:Add( "DPanel" )
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankImage:Dock( TOP )
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankImage.Paint = function( pnl, w, h )
			--draw.RoundedBox( 0, 0, 0, w, h, Color( 105, 150, 150, 255 ) )
		end
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankImage.Contents = {}
		
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankImage.Contents[ "LabelPanel" ] = parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankImage:Add( "DPanel" )
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankImage.Contents[ "LabelPanel" ]:Dock( TOP )
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankImage.Contents[ "LabelPanel" ]:SetTall( parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankImage.Contents[ "LabelPanel" ]:GetTall() + 5 )	
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankImage.Contents[ "LabelPanel" ].Paint = function() end
		
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankImage.Contents[ "LabelPanel" ].RankLabel = parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankImage.Contents[ "LabelPanel" ]:Add( "DLabel" )
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankImage.Contents[ "LabelPanel" ].RankLabel:SetText( "Rank Image" )
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankImage.Contents[ "LabelPanel" ].RankLabel:SetFont( "anus_SmallText" )
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankImage.Contents[ "LabelPanel" ].RankLabel:SetTextColor( Color( 82, 82, 82, 255 ) )
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankImage.Contents[ "LabelPanel" ].RankLabel:SizeToContents()
		
		
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankImage.Contents[ "IconPanel" ] = parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankImage:Add( "DPanel" )
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankImage.Contents[ "IconPanel" ]:Dock( TOP )
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankImage.Contents[ "IconPanel" ]:SetTall( anus.UniversalHeight( 240 ) )
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankImage.Contents[ "IconPanel" ].Paint = function( pnl, w, h)
			--draw.RoundedBox( 0, 0, 0, w, h, Color( 10, 10, 10, 255 ) )
		end
		
		print( parent.panel.content.SheetPnl:GetWide() )
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankImage.Contents[ "IconPanel" ].RankImage = parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankImage.Contents[ "IconPanel" ]:Add( "DIconBrowser" )
		--parent.panel.content.SheetPnl.Creations[ k ].RankColor.Contents[ "ColorPanel" ].RankColor:Dock( FILL )
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankImage.Contents[ "IconPanel" ].RankImage:SetWide( anus.UniversalWidth( 540 ) )
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankImage.Contents[ "IconPanel" ].RankImage:SetTall( anus.UniversalHeight( 140 ) )
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankImage.Contents[ "IconPanel" ].RankImage:SetSelectedIcon( v.icon )
		
		parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankImage:SetTall( parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankImage.Contents[ "IconPanel" ].RankImage:GetTall() + parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankImage.Contents[ "LabelPanel" ]:GetTall() )
		
		
		
		
		creations[ k ].Spacer3 = creations[ k ]:Add( "DPanel" )
		creations[ k ].Spacer3:Dock( TOP )
		creations[ k ].Spacer3:SetTall( 15 )
		creations[ k ].Spacer3.Paint = function() end
		
		creations[ k ].RankPermissions = creations[ k ]:Add( "DPanel" )
		creations[ k ].RankPermissions:Dock( TOP )
		creations[ k ].RankPermissions:SetTall( 900 )
		creations[ k ].RankPermissions.Paint = function( pnl, w, h )
			--draw.RoundedBox( 0, 0, 0, w, h, Color( 105, 150, 150, 255 ) )
		end
		creations[ k ].RankPermissions.Contents = {}

		
		creations[ k ].RankPermissions.Contents[ "LabelPanel" ] = creations[ k ].RankPermissions:Add( "DPanel" )
		creations[ k ].RankPermissions.Contents[ "LabelPanel" ]:Dock( TOP )
		creations[ k ].RankPermissions.Contents[ "LabelPanel" ]:SetTall( parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankImage.Contents[ "LabelPanel" ]:GetTall() + 5 )	
		creations[ k ].RankPermissions.Contents[ "LabelPanel" ].Paint = function( pnl, w, h )
			--draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 0, 0 ,255 ) )
		end
		
		creations[ k ].RankPermissions.Contents[ "LabelPanel" ].RankLabel = creations[ k ].RankPermissions.Contents[ "LabelPanel" ]:Add( "DLabel" )
		creations[ k ].RankPermissions.Contents[ "LabelPanel" ].RankLabel:SetText( "Rank Permissions" )
		creations[ k ].RankPermissions.Contents[ "LabelPanel" ].RankLabel:SetFont( "anus_SmallText" )
		creations[ k ].RankPermissions.Contents[ "LabelPanel" ].RankLabel:SetTextColor( Color( 82, 82, 82, 255 ) )
		creations[ k ].RankPermissions.Contents[ "LabelPanel" ].RankLabel:SizeToContents()
		
		creations[ k ].RankPermissions.Contents[ "RankContent" ] = creations[ k ].RankPermissions:Add( "DPanel" )
		creations[ k ].RankPermissions.Contents[ "RankContent" ]:Dock( TOP )
		--creations[ k ].RankPermissions.Contents[ "RankContent" ]:SetWide( 90 )
		creations[ k ].RankPermissions.Contents[ "RankContent" ]:SetTall( 50 )--parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ].RankImage.Contents[ "LabelPanel" ]:GetTall() + 5 )	
		creations[ k ].RankPermissions.Contents[ "RankContent" ].Paint = function( pnl, w, h )
			--draw.RoundedBox( 0, 0, 0, w, h, Color( 90, 90, 90, 255 ) )
		end
		
		creations[ k ].RankPermissions.Contents[ "RankPermissions" ] = creations[ k ].RankPermissions.Contents[ "RankContent" ]:Add( "DPanel" )
		creations[ k ].RankPermissions.Contents[ "RankPermissions" ]:Dock( LEFT )
		creations[ k ].RankPermissions.Contents[ "RankPermissions" ]:SetWide( anus.UniversalWidth( 540 ) / 2  )
		creations[ k ].RankPermissions.Contents[ "RankPermissions" ].Paint = function( pnl, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 60, 60, 60, 255 ) )
		end
		
		--creat
		
		
		
		
		--[[parent.panel.content.SheetPnl.Creations[ k ].BasicInfo = {}
		parent.panel.content.SheetPnl.Creations[ k ].BasicInfo.TblInfo =
		{
			{ "Group Name", v.name },
			{ "Group ID", k },
			{ "Inheritance", v.Inheritance or "" },
		}
		
		for a,b in next, parent.panel.content.SheetPnl.Creations[ k ].BasicInfo.TblInfo do
			parent.panel.content.SheetPnl.Creations[ k ].BasicInfo[ b[ 1 ] ] = parent.panel.content.SheetPnl.Creations[ k ]:Add( "DLabel" )
			parent.panel.content.SheetPnl.Creations[ k ].BasicInfo[ b[ 1 ] ]:SetText( b[ 1 ] )
			parent.panel.content.SheetPnl.Creations[ k ].BasicInfo[ b[ 1 ] ]:SetFont( "anus_SmallText" )
			parent.panel.content.SheetPnl.Creations[ k ].BasicInfo[ b[ 1 ] ]:SetTextColor( Color( 10, 10, 10, 255 ) )
			--parent.panel.content.SheetPnl.Creations[ k ].BasicInfo[ b[ 1 ] ]:Dock( TOP )
			parent.panel.content.SheetPnl.Creations[ k ].BasicInfo[ b[ 1 ] ]:SetPos( 5^a, 5 )
			parent.panel.content.SheetPnl.Creations[ k ].BasicInfo[ b[ 1 ] ]:SizeToContents()
			
			parent.panel.content.SheetPnl.Creations[ k ].BasicInfo[ b[ 2 ] ] = parent.panel.content.SheetPnl.Creations[ k ]:Add( "DLabel" )
			parent.panel.content.SheetPnl.Creations[ k ].BasicInfo[ b[ 2 ] ]:SetText( b[ 2 ] )
			parent.panel.content.SheetPnl.Creations[ k ].BasicInfo[ b[ 2 ] ]:SetFont( "anus_SmallText" )
			parent.panel.content.SheetPnl.Creations[ k ].BasicInfo[ b[ 2 ] ]:SetTextColor( Color( 10, 10, 10, 255 ) )
			parent.panel.content.SheetPnl.Creations[ k ].BasicInfo[ b[ 2 ] ]:Dock( TOP )
		end
		--PrintTable( parent.panel.content.SheetPnl.Creations[ k ].BasicInfo.TblInfo )
			--parent.panel.content.SheetPnl.Creations[ k ].BasicInfo[ b[ 1 ] ] = parent.panel.content.SheetPnl.Creations[ k ]:Add( "DLabel" )
			
		--[[parent.panel.content.SheetPnl.Creations[ k ]
		
		
		parent.panel.content.SheetPnl.Creations[ k ]
		parent.panel.content.SheetPnl.Creations[ k ]
		parent.panel.content.SheetPnl.Creations[ k ]
		parent.panel.content.SheetPnl.Creations[ k ]]
		
		
		
		
		parent.panel.content.SheetPnl:AddSheet( k, parent.panel.content.SheetPnl.ScrollPnl.Creations[ k ], v.icon )
	end
	
	
	
	
	
	
	
	
	--[[parent.panel.contents.InfoPanel = parent.panel.contents:Add( "DPanel" )
	parent.panel.contents.InfoPanel:Dock( TOP )
	
	parent.panel.contents.InfoPanel.TblInfo =
	{
	[ "Group ID" ] = "trusted",
	[ "Group Name" ] = "Trusted",
	[ "Inheritance" ] = "user",
	}
	surface.SetFont( "anus_SmallText" )
	local infopaneltxtsizew, infopaneltxtsizeh = surface.GetTextSize( "" )
	for k,v in next, parent.panel.contents.InfoPanel.TblInfo do
		parent.panel.contents.InfoPanel[ k ] = parent.panel.contents.InfoPanel:Add( "DLabel" )
		parent.panel.contents.InfoPanel[ k ]:SetText( k )
		parent.panel.contents.InfoPanel[ k ]:SetFont( "anus_SmallText" )
		parent.panel.contents.InfoPanel[ k ]:SetTextColor( Color( 10, 10, 10, 255 ) )
		parent.panel.contents.InfoPanel[ k ]:Dock( TOP )
		
		parent.panel.contents.InfoPanel[ v ] = parent.panel.contents.InfoPanel:Add( "DLabel" )
		parent.panel.contents.InfoPanel[ v ]:SetText( v )
		parent.panel.contents.InfoPanel[ v ]:SetFont( "anus_SmallText" )
		parent.panel.contents.InfoPanel[ v ]:SetTextColor( Color( 82, 82, 82, 255 ) )
		parent.panel.contents.InfoPanel[ v ]:Dock( TOP )
		
		infopaneltxtsizew, infopaneltxtsizeh = surface.GetTextSize( v )
	end

	parent.panel.contents.InfoPanel:SetTall( table.Count( parent.panel.contents.InfoPanel.TblInfo ) * (infopaneltxtsizeh*2.5) + 4 )]]
	
	
	
		
	
	--[[parent.panel.contents.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 140, 140, 140, 255 ) ) 
		draw.RoundedBox( 0, 1, 1, w - 2, h - 2, color_white )
	end]]
	
	
	--[[parent.panel.contents = parent.panel:Add( "DPanel" )
	parent.panel.contents:Dock( FILL )
	parent.panel.contents.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 140, 140, 140, 255 ) ) 
		draw.RoundedBox( 0, 1, 1, w - 2, h - 2, color_white )
	end
	
	parent.panel.contents.InfoPanel = parent.panel.contents:Add( "DPanel" )
	parent.panel.contents.InfoPanel:Dock( TOP )]]
	--parent.panel.contents.InfoPanel
	
	--[[self:RebuildContents()]]
	
	LocalPlayer().GroupEditors = LocalPlayer().GroupEditors or {}
	LocalPlayer().GroupEditors[ self ] = true
end

function panel:Paint( w, h )
	draw.RoundedBox( 0, 0, 0, w, h, Color( 140, 140, 140, 255 ) ) 
	draw.RoundedBox( 0, 1, 1, w - 2, h - 2, color_white )
end

concommand.Add( "closegroupeditor", function()
	if not LocalPlayer().GroupEditors then return end
	for k,v in next, LocalPlayer().GroupEditors do
		k:Remove()
		LocalPlayer().GroupEditors[ k ] = nil
	end
end )
	
vgui.Register( "anus_groupeditor", panel, "EditablePanel" )