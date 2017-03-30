local Category = {}

Category.pluginid = "modifyautopromotion"
Category.CategoryName = "Auto Promote"

function Category:Initialize( parent )

	self.panel = parent:Add( "anus_contentpanel" )
	self.panel:SetTitle( "Auto Promote" )
	self.panel:Dock( FILL )

	self.panel.listview = self.panel:Add( "anus_listview" )
	self.panel.listview:SetMultiSelect( false )
	self.panel.listview:AddColumn( "Group" )
	self.panel.listview:AddColumn( "Time (h)" )
	self.panel.listview:AddColumn( "Enabled" )
	self.panel.listview:Dock( FILL )
	
	local count = 0
	for k,v in next, anus_autopromote or {} do
		count = count + 1
		timer.Simple( 0.0125 * count, function()
			if not parent or not self.panel then return end

			local line = self.panel.listview:AddLine( k, v, v == -1 and "icon16/cross.png" or "icon16/accept.png" )
			line.pluginid = k
				-- Registers the column to show this as an icon
			line:SetColumnIcon( 3 )
		end )
	end
	
	function self.panel.listview:DoDoubleClick( lineid, line )
		if line.LineClick then
			line.LineClickFunction( lineid, line )
		end
	end
	
	timer.Simple( table.Count( anus.Groups ) * 0.01 + 0.03, function()
		if not parent or not self.panel then return end

		self.panel.listview:SortByColumn( 1, false )
	end )
		
	self.panel.listview.OnRowRightClick = function( pnl, index, pnlRow )
		local posx, posy = gui.MousePos() 
		local menu = vgui.Create( "DMenu" )
		menu:SetPos( posx, posy )
		menu:AddOption( "Change Time Required", function()
			local column = pnlRow
			
			Derma_StringRequest( 
				column:GetColumnText( 1 ), 
				"Change auto promotion time (hours)",
				column:GetColumnText( 2 ),
				function( txt )
					if not tonumber( txt ) then return end
					
					net.Start( "anus_autopromotesv" )
						net.WriteFloat( math.Round( tonumber( txt ), 2 ) )
						net.WriteString( column:GetColumnText( 1 ) )
					net.SendToServer()
				end,
				function( txt ) 
				end
			)
			
		end )
		menu:AddOption( "Remove Group", function()
			Derma_Query( "Are you sure you want to remove this group's autopromotion?", "Confirm", "Yes", function() 
				net.Start( "anus_autopromoteremovegroupsv" )
					net.WriteString( pnlRow:GetColumnText( 1 ) )
				net.SendToServer()
			end, "No", function() end )
		end )
		menu:AddSpacer()
		menu:AddOption( "Close" )
		menu.Think = function( pnl2 )
			if not IsValid( pnl ) or not anus_mainMenu or not anus_mainMenu:IsVisible() then
				menu:Remove()
			end
		end
		menu:Open( posx, posy, true, pnl )
	end
	
	hook.Add( "anus_AutoPromoteGroupsChanged", self.panel, function( _, group, time, oldtime )
		for k,v in ipairs( self.panel.listview:GetLines() ) do
			if v:GetColumnText( 1 ) == group then
				v:SetColumnText( 2, time )
				if time == -1 then
					v:SetColumnText( 3, "icon16/cross.png" )
				else
					v:SetColumnText( 3, "icon16/accept.png" )
				end
			end
		end
	end )
	
	hook.Add( "anus_AutoPromoteGroupsBroadcasted", self.panel, function( _ )
		if not self.panel then return end
		for k,v in next, self.panel.listview.Lines do
			if not anus_autopromote[ v:GetColumnText( 1 ) ] then
				self.panel.listview:RemoveLine( k )
			end
		end
	end )

end

	
hook.Add( "anus_PluginUnloaded", "anus_UpdateAutoPromoteCat", function( plugin )
	if plugin == "autopromote" then
		anus_mainMenu:Refresh()
	end
end )
	
hook.Add( "anus_PluginLoaded", "anus_UpdateAutoPromoteCat", function( plugin )
	if plugin == "autopromote" then
		anus_mainMenu:Refresh()
	end
end )

anus.registerCategory( Category )

-- hud

CreateClientConVar( "anus_showplaytime", "1", true )

local function CreatePlayTime()
	if anus_playTimeHud then
		anus_playTimeHud:Remove()
		anus_playTimeHud = nil
	end

	timer.Simple( 0.5, function()
	
		if not anus.getPlugin( "playertime" ) then return end

		anus_playTimeHud = vgui.Create( "DPanel" )
		anus_playTimeHud:SetSize( 160, 40 )
		anus_playTimeHud:SetPos( ScrW() - 175, 15 )
		anus_playTimeHud.Paint = function( pnl, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 140, 140, 140, 255 ) )
			draw.RoundedBox( 0, 2, 2, w - 4, h - 4, color_white ) 
		end
		anus_playTimeHud:ParentToHUD()
				
		hook.Add( "anus_PluginUnloaded", anus_playTimeHud, function( _, plugin )
			if plugin != "playertime" then return end

			anus_playTimeHud:Hide()
		end )
		hook.Add( "anus_PluginLoaded", anus_playTimeHud, function( _, plugin )
			if plugin != "playertime" then return end

			anus_playTimeHud:Show()
		end )

		local SessionPanel = anus_playTimeHud:Add( "DPanel" )
		SessionPanel:Dock( TOP )
		SessionPanel:SetTall( anus_playTimeHud:GetTall() / 2 )
		SessionPanel.Paint = function( pnl, w, h )
			--draw.RoundedBox( 0, 0, 0, w, h, Color( 30, 30, 30, 255 ) )
		end

		local TotalPanel = anus_playTimeHud:Add( "DPanel" )
		TotalPanel:Dock( TOP )
		TotalPanel:SetTall( anus_playTimeHud:GetTall() / 2 )
		TotalPanel.Paint = function( pnl, w, h )
			--draw.RoundedBox( 0, 0, 0, w, h, Color( 55, 20, 20, 255 ) )
		end

		local SessionHeader = SessionPanel:Add( "DLabel" )
		SessionHeader:SetText( "Session:" )
		SessionHeader:SetTextInset( 5, 0 )
		SessionHeader:SetTextColor( Color( 82, 82, 82, 255 ) )
		SessionHeader:Dock( LEFT )
		SessionHeader:SizeToContents()

		local GetSessionSizeW = nil

		local SessionBody = SessionPanel:Add( "DLabel" )
			-- Using patterns to add spaces after every letter
		SessionBody:SetText( LocalPlayer().getSessionTimePlayed and anus.convertTimeToString( LocalPlayer():getSessionTimePlayed(), true ):gsub( "%a+", "%1 " ):TrimRight() or "0s" )
		SessionBody:SetTextColor( Color( 82, 82, 82, 255 ) )
		SessionBody:Dock( RIGHT )
		SessionBody:DockMargin( 0, 0, 5, 0 )
		SessionBody:SizeToContents()
		SessionBody.StartWide = SessionBody:GetWide()
		SessionBody.Think = function( self )
			if self.LastThink and self.LastThink > CurTime() then return end
			if not LocalPlayer().getSessionTimePlayed then return end

			surface.SetFont( "DermaDefault" )
			local NewText = anus.convertTimeToString( LocalPlayer():getSessionTimePlayed(), true ):gsub( "%a+", "%1 " ):TrimRight()
			GetSessionSizeW = surface.GetTextSize( NewText )

			self:SetText( NewText )
			if self.StartWide > GetSessionSizeW then
				self:SetWide( self.StartWide - ( math.abs( self.StartWide - GetSessionSizeW ) ) )
			elseif self.StartWide < GetSessionSizeW then
				self:SetWide( self.StartWide + ( math.abs( self.StartWide - GetSessionSizeW ) ) )
			else
				self:SetWide( self.StartWide )
			end

			self.LastThink = CurTime() + 1
		end

		local TotalHeader = TotalPanel:Add( "DLabel" )
		TotalHeader:SetText( "Total:" )
		TotalHeader:SetTextInset( 5, 0 )
		TotalHeader:SetTextColor( Color( 82, 82, 82, 255 ) )
		TotalHeader:Dock( LEFT )
		TotalHeader:SizeToContents()

		local GetTotalSizeW = nil

		local TotalBody = TotalPanel:Add( "DLabel" )
		TotalBody:SetText( LocalPlayer().getTotalTimePlayed and anus.convertTimeToString( LocalPlayer():getTotalTimePlayed(), true ):gsub( "%a+", "%1 " ):TrimRight() or "0s" )
		TotalBody:SetTextColor( Color( 82, 82, 82, 255 ) )
		TotalBody:Dock( RIGHT )
		TotalBody:DockMargin( 0, 0, 5, 0 )
		TotalBody:SizeToContents()
		TotalBody.StartWide = TotalBody:GetWide()
		TotalBody.Think = function( self )
			if self.LastThink and self.LastThink > CurTime() then return end
			if not LocalPlayer().getTotalTimePlayed then return end

			surface.SetFont( "DermaDefault" )
			local NewText = anus.convertTimeToString( LocalPlayer():getTotalTimePlayed(), true ):gsub( "%a+", "%1 " ):TrimRight()
			GetTotalSizeW = surface.GetTextSize( NewText )

			self:SetText( NewText ) 
			if self.StartWide > GetTotalSizeW then
				self:SetWide( self.StartWide - ( math.abs( self.StartWide - GetTotalSizeW ) ) )
			elseif self.StartWide < GetTotalSizeW then
				self:SetWide( self.StartWide + ( math.abs( self.StartWide - GetTotalSizeW ) ) )
			else
				self:SetWide( self.StartWide )
			end
			
			self.LastThink = CurTime() + 1
		end
	end )
end
hook.Add( "InitPostEntity", "anus_playtimehud", CreatePlayTime )

cvars.AddChangeCallback( "anus_showplaytime", function( cvar, old, new )
	if new == "0" then
		anus_playTimeHud:Remove()
		anus_playTimeHud = nil
	else
		CreatePlayTime()
	end
end, "anus_showplaytime" )