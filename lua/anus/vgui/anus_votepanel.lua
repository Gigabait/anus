local panel = {}

function panel:Init()
	self:SetSize( 30, 40 )
	
	self.AlphaPanel = 255
end

function panel:SetText( strText )
	local txtsizew, txtsizeh = surface.GetTextSize( strText )
	
	self.OptionText = self:Add( "DLabel" )
	self.OptionText:SetText( strText )
	self.OptionText:SetFont( "anus_SmallText" )
	self.OptionText:SetTextColor( Color( 140, 140, 140, self.AlphaPanel ) )
	self.OptionText:SetPos( 10, self:GetTall() / 2 - txtsizeh / 2 )
	self.OptionText:SetSize( txtsizew, txtsizeh )
end

function panel:SetNum( num )
	self.Num = num
end

function panel:SetHasBottom( bHasBottom )
	self.HasBottom = bHasBottom
end

function panel:Paint( w, h )
		-- outline
	draw.RoundedBox( 0, 0, 0, w, h, Color( 140, 140, 140, self.AlphaPanel ) ) 
		-- content
	if self.HasBottom then
		draw.RoundedBox( 0, 1, 1, w - 2, h - 2, Color( 255, 255, 255, self.AlphaPanel ) )
	else
		draw.RoundedBox( 0, 1, 1, w - 2, h - 1, Color( 255, 255, 255, self.AlphaPanel ) )
	end
end

function panel:Think()
	if not self.RegisteredNum and self.Num then
		local newText = self.Num .. ". " .. self.OptionText:GetText()
		local txtsizew, txtsizeh = surface.GetTextSize( newText )
	
		self.OptionText = self.OptionText or vgui.Create( "DLabel", self )
		self.OptionText:SetText( newText )
		self.OptionText:SetFont( "anus_SmallText" )
		self.OptionText:SetTextColor( Color( 140, 140, 140, self.AlphaPanel ) )
		self.OptionText:SetPos( 10, self:GetTall() / 2 - txtsizeh / 2 )
		self.OptionText:SetSize( txtsizew, txtsizeh )
		
		self.RegisteredNum = true
	end
	
	if not self.OldAlphaPanel then
		self.OldAlphaPanel = self.AlphaPanel
	end
	
	if self.OldAlphaPanel != self.AlphaPanel then
		local col = self.OptionText:GetTextColor()
		col.a = self.AlphaPanel
		
		self.OptionText:SetTextColor( col )
		
		self.OldAlphaPanel = self.AlphaPanel
	end
end

vgui.Register( "anus_voteoption", panel )





local panel = {}

local bgColor = Color( 231, 230, 237, 255 )

	-- fade out, this is our timer.
	
	-- with the current settings, our max should be 9
function panel:RebuildContents()
	self.TitlePanel = self.TitlePanel or self:Add( "DPanel" )
	self.TitlePanel:SetPos( 0, 0 )
	self.TitlePanel:SetSize( self:GetWide(), 40 )
	self.TitlePanel:Dock( TOP )
	self.TitlePanel.AssignedColor = bgColor
	self.TitlePanel.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, pnl.AssignedColor )
	end
	
	self.ContentPanel = self.ContentPanel or self:Add( "DPanel" )
	self.ContentPanel:SetPos( 0, 0 )
	--print( "t", self:GetTall() - self.TitlePanel:GetTall() )
	self.ContentPanel:SetSize( self:GetWide(), self:GetTall() - self.TitlePanel:GetTall() )
	self.ContentPanel:Dock( FILL )
	self.ContentPanel.AssignedColor = color_white
	self.ContentPanel.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, pnl.AssignedColor )
	end
	
	self.ContentPanel.OptionsPanel = self.ContentPanel.OptionsPanel or self.ContentPanel:Add( "DPanel" )
	self.ContentPanel.OptionsPanel:SetPos( 10, 10 + 1 )
	self.ContentPanel.OptionsPanel:SetSize( self.ContentPanel:GetWide() - 20, self.ContentPanel:GetTall() - 20 )
	self.ContentPanel.OptionsPanel.Paint = function( pnl, w, h )
	end
	self.ContentPanel.OptionsPanel.Vote = self.ContentPanel.OptionsPanel.Vote or {}
end
	
function panel:Init()
	self:SetSize( 242, 45 )
	self:SetPos( 5, ScrH() / 2 - self:GetTall() - 4 )

	self.BaseHeight = self:GetTall()

	self.Options = {}
	
	self:RebuildContents()
end

function panel:SetTitle( strTitle )
	self.strTitle = strTitle
	
	self.TitlePanel.Title = self.TitlePanel:Add( "DLabel" )
	self.TitlePanel.Title:SetText( strTitle )
	self.TitlePanel.Title:SetTextColor( Color( 140, 140, 140, 255 ) )
	self.TitlePanel.Title:SetFont( "anus_SmallTitleHeavy" )
	self.TitlePanel.Title:SetPos( 10, 10 )
	self.TitlePanel.Title:SizeToContents()
end

function panel:SetTime( time )
	self.numTime = time
end

function panel:AddOption( num, strOption, hasBottom )
	self.ContentPanel.OptionsPanel.Vote[ num ] = self.ContentPanel.OptionsPanel:Add( "anus_voteoption" )
	self.ContentPanel.OptionsPanel.Vote[ num ]:SetText( strOption )
	self.ContentPanel.OptionsPanel.Vote[ num ]:SetNum( num )
	self.ContentPanel.OptionsPanel.Vote[ num ]:SetHasBottom( hasBottom or false )
	self.ContentPanel.OptionsPanel.Vote[ num ]:Dock( TOP )
end
	

function panel:Paint( w, h )
		-- title, outline
	--draw.RoundedBox( 0, 0, 0, w, h, bgColor ) 
		-- content
	--draw.RoundedBox( 0, 2, 45, w - 4, h - 47, color_white )
	if self.numTime then
		self.AlphaPanel = self.AlphaPanel or 255
		self.AlphaPanel = math.Approach( self.AlphaPanel, 0, ( 255 / self.numTime ) * FrameTime() )
		
		self.TitlePanel.Paint = function( pnl, w2, h2 )
			local bgColor2 = bgColor
			bgColor2.a = self.AlphaPanel
			draw.RoundedBox( 0, 0, 0, w2, h2, bgColor2 )
			
			local col = pnl.Title:GetTextColor()
			col.a = self.AlphaPanel
			pnl.Title:SetTextColor( col )
		end
		
		self.ContentPanel.Paint = function( pnl, w2, h2 )
			draw.RoundedBox( 0, 0, 0, w2, h2, Color( 255, 255, 255, self.AlphaPanel ) )
		end
		
		for k,v in next, self.ContentPanel.OptionsPanel.Vote or {} do
			v.AlphaPanel = self.AlphaPanel
		end
		
		--[[self.TitlePanel.Paint = function( pnl, w, h )
			local titlepanelOverride = self.TitlePanel.AssignedColor
			titlepanelOverride.a = self.AlphaPanel
			draw.RoundedBox( 0, 0, 0, w, h, titlepanelOverride )
			
			local col = self.TitlePanel.Title:GetTextColor()
			col.a = self.AlphaPanel
			self].TitlePanel.Title:SetTextColor( col )
		end]]

		--[[local col = self.ContentPanel.AssignedColor
		col.a = self.AlphaPanel
		self.ContentPanel.AssignedColor = col]]
		
		--[[for k,v in next, self.ContentPanel.OptionsPanel.Vote or {} do
			v.AlphaPanel = self.AlphaPanel
		end]]
	end	
end

function panel:Think()
	if self.BaseHeight != self:GetTall() then
		local oldposx, oldposy = self:GetPos()
		self:SetPos( oldposx, (ScrH() / 2 + 12 + 5) - self:GetTall() )
		
		self.BaseHeight = self:GetTall()
		self:RebuildContents()
	end
	
--	if self.numTime and not self.registeredTime then
		
end

vgui.Register( "anus_votepanel", panel )