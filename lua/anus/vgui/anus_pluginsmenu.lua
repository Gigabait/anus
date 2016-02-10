--------------------------------------------------------
--------------------------------------------------------
----------------
---------------- I'm so sorry who ever is reading this code, I literately cannot make menus for shit.
----------------
--------------------------------------------------------
--------------------------------------------------------

local panel = {}

AccessorFunc( panel, "m_bDraggable", 			"Draggable", 		FORCE_BOOL )

surface.CreateFont( "anus_PluginDescription",
{
	--font = "Arial",
	font = "Verdana",
	size = 18,
	weight = 1000,
} )
surface.CreateFont( "anus_SidebarContent",
{
	font = "Verdana",
	size = 14,
} )

local psizew, psizeh = 550, 500
local boxpaddingw, boxpaddingh = 5, 5
local bgColor = Color( 10, 28, 40, 255 )
function panel:Init()
	self:SetFocusTopLevel( true )
	self:SetSize( psizew, psizeh )
	self:SetPos( 400, 40 )
	self:SetDraggable( true )
	self:MakePopup()
	
	self.Padding = self:Add("DPanel")
	self.Padding:SetWide( psizew )
	self.Padding:Dock( TOP )
	self.Padding.Paint = function() end
	
	self.MenuTitle = self:Add("DPanel")
	self.MenuTitle:SetWide( sizew )
	self.MenuTitle:SetTall( self.MenuTitle:GetTall() )
	self.MenuTitle:Dock( TOP )
	self.MenuTitle.Paint = function( pnl, w, h )
	end
	
	self.MenuTitle.Label = self.MenuTitle:Add( "DLabel" )
	self.MenuTitle.Label:SetText( "Plugins" )
	self.MenuTitle.Label:SetTextColor( Color( 0, 36, 60, 255 ) )
	self.MenuTitle.Label:Dock( FILL )
	self.MenuTitle.Label:SetFont( "anus_BigTitleFancy" )
	self.MenuTitle.Label:SetContentAlignment( 2 )
	self.MenuTitle.Label:SizeToContents()
	
	self.MenuTitle.Div = self:Add("DPanel")
	self.MenuTitle.Div:SetWide( sizew )
	self.MenuTitle.Div:Dock( TOP )
	self.MenuTitle.Div.Paint = function( pnl, w, h )
		surface.SetDrawColor( bgColor )
		surface.DrawRect( boxpaddingw, psizeh * 0.031, psizew - 10, psizeh)
	end
	
	
	local titleLabel = self.MenuTitle.Label:GetTall()
	
	self.Sidebar = self:Add("DPanel")
	self.Sidebar:SetWide( psizew * 0.25 )
	self.Sidebar:Dock( LEFT )
	self.Sidebar.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, boxpaddingw, 0, w, (psizeh - boxpaddingh) - (titleLabel * 4), bgColor )
	end
	
	self.Sidebar.Close = self.Sidebar:Add("DButton")
	self.Sidebar.Close:SetText( "" )
	self.Sidebar.Close:SetWide( psizew )
	self.Sidebar.Close:SetTall( psizeh * 0.15 )
	self.Sidebar.Close.DoClick = function() self:Remove() end
	self.Sidebar.Close:Dock( TOP )
	local closebuttonx,closebuttony = self.Sidebar.Close:GetPos()
	surface.SetFont("anus_SmallTitle")
	local closetextw,closetexth = surface.GetTextSize( "CLOSE" )
	self.Sidebar.Close.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, boxpaddingw, 0, w, psizeh * 0.15, Color( 195, 70, 70, 255 ) )
		draw.DrawText( "CLOSE", "anus_SmallTitle", closebuttonx + closetextw + (boxpaddingw * 2), (h / 2) - (closetexth / 2), Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
	end
	
	for k,v in SortedPairs( LocalPlayer().PlayerInfo[ LocalPlayer() ]["perms"] ) do
		if not anus.Plugins[ k ] then continue end
		if anus.Plugins[ k ].nomenu then continue end
		
		local category = anus.Plugins[ k ].category or "Other"
		if not self.Sidebar[ category ] then
			self.Sidebar[ category ] = self.Sidebar:Add("DCollapsibleCategory")
			self.Sidebar[ category ]:SetLabel( category )
			self.Sidebar[ category ]:SetExpanded( 0 )
			self.Sidebar[ category ]:SetSize( psize, psizeh * 0.2 )
			self.Sidebar[ category ]:Dock( TOP )
			self.Sidebar[ category ].Paint = function( pnl, w, h )
				derma.SkinHook( "Anus", "CollapsibleCategory", pnl, w, h )
			end
			
			self.Sidebar[ category ].Header:SetSize( 30, 40 )
			self.Sidebar[ category ].Header:SetFont( "anus_SmallTitle" )
			self.Sidebar[ category ].Header:SetTextColor( Color( 115, 166, 161, 255 ) )
			
				-- for referencing
			self.Sidebar.CatNames = self.Sidebar.CatNames or {}
			self.Sidebar.CatNames[ #self.Sidebar.CatNames + 1 ] = category
			self.Sidebar[ category ].CatName = category
			self.Sidebar[ category ].Header.DoClick = function( pnl )
				self.Sidebar[ category ]:Toggle()
				
				for k,v in pairs(self.Sidebar:GetTable().CatNames) do
					if v == pnl:GetParent().CatName then continue end
						
					self.Sidebar[ v ]:SetExpanded( false )
					self.Sidebar[ v ].animSlide:Start( self.Sidebar[ v ]:GetAnimTime(),{ From = self.Sidebar[ v ]:GetTall() } )
					self.Sidebar[ v ]:InvalidateLayout( true )
					self.Sidebar[ v ]:GetParent():InvalidateLayout()
					self.Sidebar[ v ]:GetParent():GetParent():InvalidateLayout()
						
					self.Sidebar[ v ]:SetCookie( "Open", "0" )
				end
			end
		
			self.Sidebar[ category ].Panel = self.Sidebar[ category ]:Add( "DPanel" )
			self.Sidebar[ category ].Panel:SetWide( psizew )
			self.Sidebar[ category ].Panel:SetTall( psizeh * 0.15 )
			self.Sidebar[ category ].Panel:SetSize( psizew, psizeh * 0.21 )
			self.Sidebar[ category ].Panel:Dock( TOP )
			
			self.Sidebar[ category ].Panel.Layout = self.Sidebar[ category ].Panel:Add("DListView")
			self.Sidebar[ category ].Panel.Layout.LineCount = 1
			self.Sidebar[ category ].Panel.Layout:SetHideHeaders( true )
			self.Sidebar[ category ].Panel.Layout:SetSize( psizew, psizeh * 0.21 )
			self.Sidebar[ category ].Panel.Layout:SetMultiSelect( false )
			self.Sidebar[ category ].Panel.Layout:AddColumn("Plugin")
			print(self.Sidebar[ category ].Contents)
			self.Sidebar[ category ].Panel.Layout.AddLine = function( self2, ... )
				self.Sidebar[ category ].Panel.Layout:SetDirty( true )
				self.Sidebar[ category ].Panel.Layout:InvalidateLayout()

				local Line = vgui.Create( "DListView_Line", self.Sidebar[ category ].Panel.Layout.pnlCanvas )
				local ID = table.insert( self.Sidebar[ category ].Panel.Layout.Lines, Line )
	
				Line:SetListView( self.Sidebar[ category ].Panel.Layout ) 
				Line:SetID( ID )
	
				-- This assures that there will be an entry for every column
				for k, v in pairs( self.Sidebar[ category ].Panel.Layout.Columns ) do
					Line:SetColumnText( k, "" )
				end

				for k, v in pairs( {...} ) do
					Line:SetColumnText( k, v )
				end
	
				-- Make appear at the bottom of the sorted list
				local SortID = table.insert( self.Sidebar[ category ].Panel.Layout.Sorted, Line )
	
				if ( SortID % 2 == 1 ) then
					Line:SetAltLine( true )
				end

				self.Sidebar[ category ].Panel.Layout.LineCount = self.Sidebar[ category ].Panel.Layout.LineCount + 1
				self.Sidebar[ category ].Panel:SetSize( psizew, 17 * (self.Sidebar[ category ].Panel.Layout.LineCount - 1) )---psizeh * 0.21 + (self.Sidebar[ category ].Panel.Layout.LineCount * 4.3) )
				self.Sidebar[ category ].Panel.Layout:SetSize( psizew, 17 * self.Sidebar[ category ].Panel.Layout.LineCount )--psizeh * 0.21 + (self.Sidebar[ category ].Panel.Layout.LineCount * 4.3) )
				
				return Line
			end
			
			self.Sidebar[ category ].Panel.Layout.OnClickLine = function( parent, line, b_selected )
				self.Sidebar[ category ].Panel.Layout:ClearSelection()
				line:SetSelected( true )
				line.m_fClickTime = SysTime()
				self.Sidebar[ category ].Panel.Layout:OnRowSelected( line:GetID(), line )
				if self.Content.Panel.ContentInfo then
					self.Content.Panel.ContentInfo:Remove() self.Content.Panel.ContentInfo = nil
				end
				if self.Content.Panel.ContentInfo2 then
					self.Content.Panel.ContentInfo2:Remove() self.Content.Panel.ContentInfo2 = nil
				end
				
					
				if self.Content and self.Content.Description then
					local help = "No help information found."
					if anus.Plugins[ line:GetValue( 1 ) ].help then help = anus.Plugins[ line:GetValue( 1 ) ].help end
					
					self.Content.Description:SetFont( "anus_PluginDescription" )
					self.Content.Description:SetText( help )
					self.Content.Description:SizeToContents()
					self.Content.Description:SetContentAlignment( 2 )
				end
					
				local function CreatePluginInfo( plugin, parent )
						-- lua_run_cl local usage = "<Player>; [Reason]" local tbl = string.Explode(";", usage) for k,v in pairs(tbl) do tbl[ k ] = string.gsub( v, "%A", "" ) end PrintTable(tbl)
					if not anus.Plugins[ plugin ].usage then print("OH NOOOOnoo") return nil end
						
					local usage = anus.Plugins[ plugin ].usage
					local tbl = string.Explode(";", usage)
						
					for k,v in ipairs( tbl ) do
						tbl[ k ] = string.gsub( v, "%A", "" )
					end
						
					if tbl[ 1 ]:lower() == "player" then
						parent.ContentInfo = parent:Add( "DListView" )
							-- false for now
						parent.ContentInfo:SetMultiSelect( false )
						parent.ContentInfo:Dock( LEFT )
						--parent.ContentInfo.SelectedLine = 0
						parent.ContentInfo:AddColumn( "Name" )
						parent.ContentInfo:AddColumn( "Group" )
						for k,v in pairs(player.GetAll()) do
							if LocalPlayer().PlayerInfo and LocalPlayer().PlayerInfo[ v ] then
								if anus.Groups[ LocalPlayer().PlayerInfo[ v ]["group"] ].id > anus.Groups[ LocalPlayer().PlayerInfo[ LocalPlayer() ]["group"] ].id then continue end
									
								parent.ContentInfo:AddLine( v:Nick(), LocalPlayer().PlayerInfo[ v ].group )
							else
								parent.ContentInfo:AddLine( v:Nick(), "user" )
							end
						end
						parent.ContentInfo.LineSelected = 0
						parent.ContentInfo.OnClickLine = function( parent2, line2, b_selected2 )
							if not b_selected2 then parent.ContentInfo.SelectedLine = 0 end
							parent.ContentInfo:ClearSelection()
							line2:SetSelected( true )
							parent.ContentInfo.LineSelected = line2
							line2.m_fClickTime = SysTime()
							parent.ContentInfo:OnRowSelected( line2:GetID(), line2 )
						end
							

						parent.ContentInfo2 = parent:Add( "DPanel" )
						parent.ContentInfo2:SetWide( parent.ContentInfo:GetWide() * 2.5 )
						parent.ContentInfo2:Dock( RIGHT )
						parent.ContentInfo2.Paint = function()
							draw.RoundedBox( 0, 0, 0, parent.ContentInfo2:GetWide() - boxpaddingw, psizeh, Color( 255, 255, 255, 255 ) )
						end
										
							
						if #tbl > 1 then
							
							parent.ContentInfo2.sideNames = parent.ContentInfo2.sideNames or {}
							
							for i=1,#anus.Plugins[ line:GetValue( 1 ) ][ "args" ] do
								local arg_v = anus.Plugins[ line:GetValue( 1 ) ][ "args" ][ i ]
							
								parent.ContentInfo2.sideNames[ #parent.ContentInfo2.sideNames + 1 ] = tbl[ i + 1 ]
									-- i + 1 to get rid of the first argument (Players)
								parent.ContentInfo2[ tbl[ i + 1 ] ] = parent.ContentInfo2:Add( "DPanel" )
								parent.ContentInfo2[ tbl[ i + 1 ] ]:SetWide( psizew )
								parent.ContentInfo2[ tbl[ i + 1 ] ]:SetTall( 50 )
								parent.ContentInfo2[ tbl[ i + 1 ] ]:Dock( TOP )
								parent.ContentInfo2[ tbl[ i + 1 ] ].Paint = function() end
								
								parent.ContentInfo2[ tbl[ i + 1 ] ].Text = parent.ContentInfo2[ tbl[ i + 1 ] ]:Add( "DLabel" )
								parent.ContentInfo2[ tbl[ i + 1 ] ].Text:SetFont( "anus_SidebarContent" )
								parent.ContentInfo2[ tbl[ i + 1 ] ].Text:SetTextColor( Color( 30, 75, 100, 255 ) )
								surface.SetFont( "anus_SidebarContent" )
								local content2textw, content2texth = surface.GetTextSize( tbl[ i + 1 ] )
								parent.ContentInfo2[ tbl[ i + 1 ] ].Text:SetText( tbl[ i + 1 ] )
								parent.ContentInfo2[ tbl[ i + 1 ] ]:SizeToContents()
								parent.ContentInfo2[ tbl[ i + 1 ] ]:Dock( TOP )
																				
								parent.ContentInfo2[ tbl[ i + 1 ] ].TextDiv = parent.ContentInfo2[ tbl[ i + 1 ] ]:Add( "DPanel" )
								parent.ContentInfo2[ tbl[ i + 1 ] ].TextDiv:SetWide( psizew )
								parent.ContentInfo2[ tbl[ i + 1 ] ].TextDiv:SetTall( content2texth + 5 )
								parent.ContentInfo2[ tbl[ i + 1 ] ].TextDiv:Dock( TOP )
								parent.ContentInfo2[ tbl[ i + 1 ] ].TextDiv.Paint = function() end
								
								if arg_v == "Groups" then
									parent.ContentInfo2[ tbl[ i + 1 ] ].ContentBox = parent.ContentInfo2[ tbl[ i + 1 ] ]:Add( "DComboBox" )
									parent.ContentInfo2[ tbl[ i + 1 ] ].ContentBox:SetValue( "user" )
									for groups,_ in pairs(anus.Groups) do
										parent.ContentInfo2[ tbl[ i + 1 ] ].ContentBox:AddChoice( groups )
										parent.ContentInfo2[ tbl[ i + 1 ] ].ContentBox.OnSelect = function( pnl, index, value )
											print( value .. " was selected" )
										end
									end
									parent.ContentInfo2[ tbl[ i + 1 ] ].ContentBox:Dock( TOP )
									parent.ContentInfo2[ tbl[ i + 1 ] ].ContentBox.Paint = function()
										draw.RoundedBox( 2, 0, 0, (parent.ContentInfo2:GetWide() * 0.92) - boxpaddingw, psizeh, Color( 100, 100, 100, 255 ) )
										draw.RoundedBox( 2, 1, 1, (parent.ContentInfo2:GetWide() * 0.92) - boxpaddingw - 2, psizeh, Color( 240, 240, 240, 255 ) )
									end
								elseif string.find(arg_v, "Int") then
									local argv_Explode = string.Explode( ";", arg_v )
									
									print("\nargv_Explode\n")
									PrintTable(argv_Explode)
									
									parent.ContentInfo2[ tbl[ i + 1 ] ].ContentSlider = parent.ContentInfo2[ tbl[ i + 1 ] ]:Add( "DNumSlider" )
									parent.ContentInfo2[ tbl[ i + 1 ] ].ContentSlider:SetText( "<------>" )
									parent.ContentInfo2[ tbl[ i + 1 ] ].ContentSlider.Label:SetTextColor( Color( 100, 100, 100, 255 ) )--Color( 0, 120, 190, 255 ) )
									parent.ContentInfo2[ tbl[ i + 1 ] ].ContentSlider:SetMin( argv_Explode[ 2 ] or 10 )
									parent.ContentInfo2[ tbl[ i + 1 ] ].ContentSlider:SetMax( argv_Explode[ 3 ] or 600 )
									parent.ContentInfo2[ tbl[ i + 1 ] ].ContentSlider:SetValue( math.Round( (argv_Explode[ 3 ] or 600) * 0.5 ) )
									parent.ContentInfo2[ tbl[ i + 1 ] ].ContentSlider.Slider:SetSlideX( (argv_Explode[ 2 ] or 10) / (argv_Explode[ 3 ] or 600) )
									if argv_Explode[ 4 ] and argv_Explode[ 4 ] == "true" then 
										parent.ContentInfo2[ tbl[ i + 1 ] ].ContentSlider:SetDecimals( 1 )
									else
										parent.ContentInfo2[ tbl[ i + 1 ] ].ContentSlider:SetDecimals( 0 )
									end
									parent.ContentInfo2[ tbl[ i + 1 ] ].ContentSlider:Dock( TOP )
								elseif string.find(arg_v, "String") then
									local argv_Explode = string.Explode( ";", arg_v )
								
									parent.ContentInfo2[ tbl[ i + 1 ] ].ContentEntry = parent.ContentInfo2[ tbl[ i + 1 ] ]:Add( "DTextEntry" )
									parent.ContentInfo2[ tbl[ i + 1 ] ].ContentEntry:SetText( argv_Explode[ 2 ] or "Default text" )
									parent.ContentInfo2[ tbl[ i + 1 ] ].ContentEntry:Dock( TOP )
									parent.ContentInfo2[ tbl[ i + 1 ] ].ContentEntry.Paint = function( pnl, w, h )
										draw.RoundedBox( 2, 0, 0, (parent.ContentInfo2:GetWide() * 0.92) - boxpaddingw, psizeh, Color( 100, 100, 100, 255 ) )
										draw.RoundedBox( 2, 1, 1, (parent.ContentInfo2:GetWide() * 0.92) - boxpaddingw - 2, (parent.ContentInfo2[ tbl[ i + 1 ] ]:GetTall() * 0.25) + boxpaddingh, Color( 255, 255, 255, 255 ) )
										
											-- nerd
										pnl:DrawTextEntryText( pnl.m_colText, pnl.m_colHighlight, pnl.m_colCursor )
									end
								end
							end
						end
							
						parent.ContentInfo2.Div = parent.ContentInfo2:Add( "DLabel" )
						parent.ContentInfo2.Div:SetText( "" )
						parent.ContentInfo2.Div:Dock( TOP )
							
						parent.ContentInfo2.Run = parent.ContentInfo2:Add( "DButton" )
						local contentbuttontext = "anus_" .. line:GetValue( 1 )
						surface.SetFont( "anus_SmallTitle" )
						local contentsizew, contentsizeh = surface.GetTextSize( contentbuttontext )
						parent.ContentInfo2.Run:SetText( contentbuttontext )
						parent.ContentInfo2.Run:SetTextColor( Color( 0, 120, 190, 255 ) )
						parent.ContentInfo2.Run.DoClick = function()
							local output = {}
							
							local anus_plugin = anus.Plugins[ line:GetValue( 1 ) ]
							if anus_plugin.usage then
								local usage = anus.Plugins[ plugin ].usage
								local tbl = string.Explode(";", usage)
						
								for k,v in ipairs( tbl ) do
									tbl[ k ] = string.gsub( v, "%A", "" )
								end
								
								if tbl[ 1 ] == "Player" then
									if not parent.ContentInfo:GetSelectedLine() then print("not selected a player!") return end
									local playerline = parent.ContentInfo:GetLine( parent.ContentInfo:GetSelectedLine() )
									local lineamount = #parent.ContentInfo.Lines
									plname = playerline:GetValue( 1 )
									output = {plname}
									
									print( "lines is " .. #parent.ContentInfo.Lines)
										-- if there's no extra info
									if not parent.ContentInfo2.sideNames then
										RunConsoleCommand( "anus_" .. line:GetValue(1), unpack(output) )
									else
										for i=1,#parent.ContentInfo2.sideNames do
											local v = parent.ContentInfo2.sideNames[ i ]
											
											if parent.ContentInfo2[ v ].ContentBox then 
												output[ #output + 1 ] =  parent.ContentInfo2[ v ].ContentBox:GetValue()
											elseif parent.ContentInfo2[ v ].ContentSlider then
												output[ #output + 1 ] = parent.ContentInfo2[ v ].ContentSlider:GetValue()
											elseif parent.ContentInfo2[ v ].ContentEntry then
												output[ #output + 1 ] = parent.ContentInfo2[ v ].ContentEntry:GetValue()
											end
										end

										RunConsoleCommand( "anus_" .. line:GetValue(1), unpack(output) )
									
										-- messy update
										parent.ContentInfo:Clear()
										timer.Simple(0.15, function()
											for k,v in pairs(player.GetAll()) do
												if LocalPlayer().PlayerInfo and LocalPlayer().PlayerInfo[ v ] then
													if anus.Groups[ LocalPlayer().PlayerInfo[ v ]["group"] ].id > anus.Groups[ LocalPlayer().PlayerInfo[ LocalPlayer() ]["group"] ].id then continue end
														
													parent.ContentInfo:AddLine( v:Nick(), LocalPlayer().PlayerInfo[ v ].group )
												else
													parent.ContentInfo:AddLine( v:Nick(), "user" )
												end
											end
										end)
									end
									
								end
							end
								
								
									
						end
						parent.ContentInfo2.Run:Dock( BOTTOM )
						parent.ContentInfo2.Run.Paint = function( pnl )
							if pnl.Hovered then
								pnl:SetTextColor( Color( 191, 153, 96, 255 ) )
							else
								pnl:SetTextColor( Color( 128, 112, 89, 255 ) )
							end
							draw.RoundedBox( 2, parent.ContentInfo2:GetWide() * 0.1, 0, (parent.ContentInfo2:GetWide() * 0.8) - boxpaddingw, psizeh, Color( 100, 100, 100, 255 ) )
							draw.RoundedBox( 2, (parent.ContentInfo2:GetWide() * 0.1) + 1, 1, (parent.ContentInfo2:GetWide() * 0.8) - boxpaddingw - 2, psizeh, Color( 240, 240, 240, 255 ) )
							draw.RoundedBox( 2, (parent.ContentInfo2:GetWide() * 0.1) + 1, (contentsizeh / 2) + 2, (parent.ContentInfo2:GetWide() * 0.8) - boxpaddingw - 2, psizeh, Color( 225, 225, 225, 255 ) )
						end
							
						return parent.ContentInfo, parent.ContentInfo2 or nil
							------
							------
							------
							------
							------
							------
							------
							------
							------
							------
							------
							------
							------
							------
					else
						parent.ContentInfo = parent:Add( "DPanel" )
						parent.ContentInfo:Dock( LEFT )
						parent.ContentInfo.Paint = function() end
					
						parent.ContentInfo2 = parent:Add( "DPanel" )
						parent.ContentInfo2:SetWide( parent.ContentInfo:GetWide() * 2.5 )
						parent.ContentInfo2:Dock( RIGHT )
						parent.ContentInfo2.Paint = function()
							draw.RoundedBox( 0, 0, 0, parent.ContentInfo2:GetWide() - boxpaddingw, psizeh, Color( 255, 255, 255, 255 ) )
						end
							
							parent.ContentInfo2.sideNames = parent.ContentInfo2.sideNames or {}
							
							for i=1,#anus.Plugins[ line:GetValue( 1 ) ][ "args" ] do
								local arg_v = anus.Plugins[ line:GetValue( 1 ) ][ "args" ][ i ]
							
								parent.ContentInfo2.sideNames[ #parent.ContentInfo2.sideNames + 1 ] = tbl[ i ]
									-- i + 1 to get rid of the first argument (Players)
								parent.ContentInfo2[ tbl[ i ] ] = parent.ContentInfo2:Add( "DPanel" )
								parent.ContentInfo2[ tbl[ i ] ]:SetWide( psizew )
								parent.ContentInfo2[ tbl[ i ] ]:SetTall( 50 )
								parent.ContentInfo2[ tbl[ i ] ]:Dock( TOP )
								parent.ContentInfo2[ tbl[ i ] ].Paint = function() end
								
								parent.ContentInfo2[ tbl[ i ] ].Text = parent.ContentInfo2[ tbl[ i ] ]:Add( "DLabel" )
								parent.ContentInfo2[ tbl[ i  ] ].Text:SetFont( "anus_SidebarContent" )
								parent.ContentInfo2[ tbl[ i  ] ].Text:SetTextColor( Color( 128, 112, 89, 255 ) )
								surface.SetFont( "anus_SidebarContent" )
								local content2textw, content2texth = surface.GetTextSize( tbl[ i ] )
								parent.ContentInfo2[ tbl[ i ] ].Text:SetText( tbl[ i ] )
								parent.ContentInfo2[ tbl[ i ] ]:SizeToContents()
								parent.ContentInfo2[ tbl[ i ] ]:Dock( TOP )
																				
								parent.ContentInfo2[ tbl[ i  ] ].TextDiv = parent.ContentInfo2[ tbl[ i ] ]:Add( "DPanel" )
								parent.ContentInfo2[ tbl[ i  ] ].TextDiv:SetWide( psizew )
								parent.ContentInfo2[ tbl[ i ] ].TextDiv:SetTall( content2texth + 5 )
								parent.ContentInfo2[ tbl[ i ] ].TextDiv:Dock( TOP )
								parent.ContentInfo2[ tbl[ i  ] ].TextDiv.Paint = function() end
								
								if arg_v == "Groups" then
									parent.ContentInfo2[ tbl[ i  ] ].ContentBox = parent.ContentInfo2[ tbl[ i ] ]:Add( "DComboBox" )
									parent.ContentInfo2[ tbl[ i ] ].ContentBox:SetValue( "user" )
									for groups,_ in pairs(anus.Groups) do
										parent.ContentInfo2[ tbl[ i  ] ].ContentBox:AddChoice( groups )
										parent.ContentInfo2[ tbl[ i  ] ].ContentBox.OnSelect = function( pnl, index, value )
											print( value .. " was selected" )
										end
									end
									parent.ContentInfo2[ tbl[ i  ] ].ContentBox:Dock( TOP )
									parent.ContentInfo2[ tbl[ i ] ].ContentBox.Paint = function()
										draw.RoundedBox( 2, 0, 0, (parent.ContentInfo2:GetWide() * 0.92) - boxpaddingw, psizeh, Color( 100, 100, 100, 255 ) )
										draw.RoundedBox( 2, 1, 1, (parent.ContentInfo2:GetWide() * 0.92) - boxpaddingw - 2, psizeh, Color( 240, 240, 240, 255 ) )
									end
								elseif string.find(arg_v, "Int") then
									local argv_Explode = string.Explode( ";", arg_v )
									
									print("\nargv_Explode\n")
									PrintTable(argv_Explode)
									
									parent.ContentInfo2[ tbl[ i  ] ].ContentSlider = parent.ContentInfo2[ tbl[ i ] ]:Add( "DNumSlider" )
									parent.ContentInfo2[ tbl[ i ] ].ContentSlider:SetText( "<------>" )
									parent.ContentInfo2[ tbl[ i ] ].ContentSlider.Label:SetTextColor( Color( 100, 100, 100, 255 ) )--Color( 0, 120, 190, 255 ) )
									parent.ContentInfo2[ tbl[ i ] ].ContentSlider:SetMin( argv_Explode[ 2 ] or 10 )
									parent.ContentInfo2[ tbl[ i ] ].ContentSlider:SetMax( argv_Explode[ 3 ] or 600 )
									parent.ContentInfo2[ tbl[ i ] ].ContentSlider:SetValue( math.Round( (argv_Explode[ 3 ] or 600) * 0.5 ) )
									parent.ContentInfo2[ tbl[ i ] ].ContentSlider.Slider:SetSlideX( (argv_Explode[ 2 ] or 10) / (argv_Explode[ 3 ] or 600) )
									if argv_Explode[ 4 ] and argv_Explode[ 4 ] == "true" then 
										parent.ContentInfo2[ tbl[ i ] ].ContentSlider:SetDecimals( 1 )
									else
										parent.ContentInfo2[ tbl[ i] ].ContentSlider:SetDecimals( 0 )
									end
									parent.ContentInfo2[ tbl[ i] ].ContentSlider:Dock( TOP )
								elseif string.find(arg_v, "String") then
									local argv_Explode = string.Explode( ";", arg_v )
								
									parent.ContentInfo2[ tbl[ i ] ].ContentEntry = parent.ContentInfo2[ tbl[ i ] ]:Add( "DTextEntry" )
									parent.ContentInfo2[ tbl[ i ] ].ContentEntry:SetText( argv_Explode[ 2 ] or "Default text" )
									parent.ContentInfo2[ tbl[ i ] ].ContentEntry:Dock( TOP )
									parent.ContentInfo2[ tbl[ i ] ].ContentEntry.Paint = function( pnl, w, h )
										draw.RoundedBox( 2, 0, 0, (parent.ContentInfo2:GetWide() * 0.92) - boxpaddingw, psizeh, Color( 100, 100, 100, 255 ) )
										draw.RoundedBox( 2, 1, 1, (parent.ContentInfo2:GetWide() * 0.92) - boxpaddingw - 2, (parent.ContentInfo2[ tbl[ i ] ]:GetTall() * 0.25) + boxpaddingh, Color( 255, 255, 255, 255 ) )
										
											-- nerd
										pnl:DrawTextEntryText( pnl.m_colText, pnl.m_colHighlight, pnl.m_colCursor )
									end
								end
						end
							
						parent.ContentInfo2.Div = parent.ContentInfo2:Add( "DLabel" )
						parent.ContentInfo2.Div:SetText( "" )
						parent.ContentInfo2.Div:Dock( TOP )
							
						parent.ContentInfo2.Run = parent.ContentInfo2:Add( "DButton" )
						local contentbuttontext = "anus_" .. line:GetValue( 1 )
						surface.SetFont( "anus_SmallTitle" )
						local contentsizew, contentsizeh = surface.GetTextSize( contentbuttontext )
						parent.ContentInfo2.Run:SetText( contentbuttontext )
						parent.ContentInfo2.Run:SetTextColor( Color( 0, 120, 190, 255 ) )
						parent.ContentInfo2.Run.DoClick = function()
							local output = {}
							
							local anus_plugin = anus.Plugins[ line:GetValue( 1 ) ]
							if anus_plugin.usage then
								local usage = anus.Plugins[ plugin ].usage
								local tbl = string.Explode(";", usage)
						
								for k,v in ipairs( tbl ) do
									tbl[ k ] = string.gsub( v, "%A", "" )
								end
									
								if not parent.ContentInfo2.sideNames then
									RunConsoleCommand( "anus_" .. line:GetValue(1), unpack(output) )
								else
									for i=1,#parent.ContentInfo2.sideNames do
										local v = parent.ContentInfo2.sideNames[ i ]
											
										if parent.ContentInfo2[ v ].ContentBox then 
											output[ #output + 1 ] =  parent.ContentInfo2[ v ].ContentBox:GetValue()
										elseif parent.ContentInfo2[ v ].ContentSlider then
											output[ #output + 1 ] = parent.ContentInfo2[ v ].ContentSlider:GetValue()
										elseif parent.ContentInfo2[ v ].ContentEntry then
											output[ #output + 1 ] = parent.ContentInfo2[ v ].ContentEntry:GetValue()
										end
									end

									RunConsoleCommand( "anus_" .. line:GetValue(1), unpack(output) )
								end
					
							end
						end
						
						parent.ContentInfo2.Run:Dock( BOTTOM )
						parent.ContentInfo2.Run.Paint = function( pnl )
							if pnl.Hovered then
								pnl:SetTextColor( Color( 0, 190, 255, 255 ) )
							else
								pnl:SetTextColor( Color( 0, 120, 190, 255 ) )
							end
							draw.RoundedBox( 2, parent.ContentInfo2:GetWide() * 0.1, 0, (parent.ContentInfo2:GetWide() * 0.8) - boxpaddingw, psizeh, Color( 100, 100, 100, 255 ) )
							draw.RoundedBox( 2, (parent.ContentInfo2:GetWide() * 0.1) + 1, 1, (parent.ContentInfo2:GetWide() * 0.8) - boxpaddingw - 2, psizeh, Color( 240, 240, 240, 255 ) )
							draw.RoundedBox( 2, (parent.ContentInfo2:GetWide() * 0.1) + 1, (contentsizeh / 2) + 2, (parent.ContentInfo2:GetWide() * 0.8) - boxpaddingw - 2, psizeh, Color( 225, 225, 225, 255 ) )
						end
							
						return nil, parent.ContentInfo2 or nil
					end
						
				end
					
					
				local plugininfo,plugininfo2 = CreatePluginInfo( line:GetValue( 1 ), self.Content.Panel )
				if plugininfo then
					plugininfo:SetWide( self.Content.Panel:GetWide() * 0.6 )
				end
					
			end
			
			self.Sidebar[ category ].Panel.Layout:AddLine( k )
		else
			self.Sidebar[ category ].Panel.Layout:AddLine( k )
		end
	end
	
	self.Content = self:Add("DPanel")
	self.Content:SetTall( psizeh - (psizeh * 0.21) - boxpaddingh + 1 )
	self.Content:Dock( TOP )
	self.Content.Paint = function() end
	
	self.Content.Panel = self.Content:Add("DPanel")
	self.Content.Panel:SetTall( psizeh )
	self.Content.Panel:Dock( FILL )
	self.Content.Panel.Paint = function() end
end

function panel:Paint()
	draw.RoundedBox( 6, 0, 0, psizew, psizeh - 31, bgColor )
	draw.RoundedBox( 0, boxpaddingw, boxpaddingh, psizew - 10 , psizeh - 42, Color( 241, 235, 209, 255 ) )
end

vgui.Register( "anus_pluginsmenu", panel, "EditablePanel" )--, "DFrame" )