require("Mods.Extensions.ExtensionMan")

function Create(self)
	self.Menu = table.Copy(require("Mods.Extensions.imenu.core"))
	self.Menu:Initialize()

	self.MenuFunc = {}
	self.MenuFunc[1] = BuilderBasic
	self.Main = {}

	self.ConfirmSound = CreateSoundContainer("Base.rte/Confirm")
	self.ErrorSound = CreateSoundContainer("Base.rte/Error")
	self.PieMenu:AddPieSlice(CreatePieSlice("CED.rte/BuilderMenu"), self)

	self.SelectDelayTime = Timer()

	self.Activity = ActivityMan:GetActivity()
end

function DisplayNumber(self, screen, color, pos, text)
	for i = 1, string.len(text) do
		local digit = string.sub(text, i, i)
		PrimitiveMan:DrawBitmapPrimitive(pos + Vector((3 + 1) * (i - 1) + 1, 5),
		"CED.rte/Effects/Font/" .. color .. "/Numbers/" .. digit .. ".png", 0)
	end
end

--This is the greatest BuilderBasic of all time
function BuilderBasic(self)
	self.Main.Box = self.Menu:CreateGUI("CollectionBox")
	self.Main.Box:SetTitle("")
	self.Main.Box:SetPos(10, 25)
	self.Main.Box:SetSize(260, 50)
	self.Main.Box:Color(146)
	self.Main.Box:OutlineColor(71)
	self.Main.Box:OutlineThickness(2)

	local category = {
		{"Fortification", self.CEDAvailableBuildables.Fortifications},
		{"Turrets", self.CEDAvailableBuildables.Turrets},
		{"Buildings", self.CEDAvailableBuildables.Buildings},
		{"Utility", self.CEDAvailableBuildables.Utility}
	}

	local isRemoving = false
	local renderPos = Vector()
	local box = nil
	local validPlacement = false
	local tolerance = 0.1

	--Bitmap will be modifed so we need to make sure it's always default
	self.Menu.Cursor_Bitmap = "Data/Base.rte/GUIs/Skins/Cursor.png"

	local rows = 3
	local maxHeight = 295
	local height = 0
	--used for Distance between buttons, height
	local posMultiplier = 85
	local maxRadius = 20

	local textWidth = 0
	local textWidth_price = 0
	local oz_width = 0
	local textPos = Vector()
	local itemFund = false

	local function drawMenu()
		local buttons = {}
		for i = 1, #category do
			local tab = category[i]
			local name = tab[1]
			local buildableList = tab[2]

			local x = -3 + self.Main.Box:GetPosX() + ((i - 1) % 4 + 1 - 1) * 65
			local y = 5 + (math.floor((i - 1) / 4 ) + 1 - 1) * 35

			local mainTab = self.Menu:CreateGUI("Button", self.Main.Box)
			mainTab.BuildList = buildableList
			mainTab:SetPos(x, y)
			mainTab:SetSize(50, 13)
			mainTab:SetText(name)
			mainTab:Color(146)
			mainTab:OutlineColor(144)
			mainTab:OutlineThickness(2)

			mainTab.Think = function(entity, screen)
				mainTab:OutlineColor(mainTab.IsHovered and 117 or 144)
			end

			mainTab.OnPress = function(key)
				if key == Controller.PRIMARY_ACTION then
					if table.IsEmpty(mainTab.BuildList) then
						print("Table is empty!")
						self.ErrorSound:Play(-1)
						return
					end

					self.Main.Box:ClearChildren()
					drawMenu()

					local currentHeight = 40
					height = math.max(height, currentHeight)

					local scroll = 0
					local totalRows = math.ceil(#mainTab.BuildList / rows)

					local tooltip_bar = self.Menu:CreateGUI("CollectionBox", self.Main.Box)
					tooltip_bar:SetTitle("")
					tooltip_bar:SetPos(tooltip_bar:GetParent():GetWidth() + 10, 25)
					tooltip_bar:SetSize(100, 75)
					tooltip_bar:Color(146)
					tooltip_bar:OutlineColor(71)
					tooltip_bar:OutlineThickness(2)
					tooltip_bar:SetVisible(false) --Set to false to prevent flicker

					local desc = self.Menu:CreateGUI("Label", tooltip_bar)
					desc:SmallText(true)
					desc:SetContentAlignment(1)
					desc:SetPos(desc:GetPosX() + 10, desc:GetPosY() + 10)
					desc:SetVisible(false)

					desc.Think = function(entity, screen)
						desc:SetVisible(false)
					end

					tooltip_bar.Think = function(entity, screen)
						tooltip_bar:SetVisible(false)
					end

					for i = 1, #mainTab.BuildList do
						local x = 0 + self.Main.Box:GetPosX() + ((i - 1) % rows + 1 - 1) * posMultiplier
						local y = 40 + (math.floor((i - 1) / rows ) + 1 - 1) * posMultiplier

						local button = self.Menu:CreateGUI("Button", self.Main.Box)
						button.Buildable = mainTab.BuildList[i]
						button.Selected = false
						button.IsResearched = false
						button:SetPos(x, y)
						button:SetSize(65, 65)
						button:SetText(button.Buildable.DisplayName)
						button:TextPos(0, 10)
						button:Color(146)
						button:OutlineColor(144)
						button:OutlineThickness(2)

						button.Think = function(entity, screen)
							local offset = CameraMan:GetOffset(screen)
							local world_pos = Vector(button:GetParent():GetPos()) + Vector(button:GetPos()) + offset
							local parent_world_pos = Vector(button:GetParent():GetPos()) + offset
							local hasFund = self.Activity:GetTeamFunds(entity.Team) >= button.Buildable.Cost

							button:Color(hasFund and 146 or 248)

							if button.IsHovered then
								itemFund = self.Activity:GetTeamFunds(entity.Team) >= button.Buildable.Cost
								tooltip_bar:SetVisible(true)
								desc:SetVisible(true)
								if tooltip_bar:GetTitle() ~= button.Buildable.DisplayName then
									local size = button.Buildable.TooltipSize
									tooltip_bar:SetSize(size.X, size.Y)
									desc:SetSize(size.X, size.Y)
									desc:SetText(button.Buildable.Description)
									tooltip_bar:SetTitle(button.Buildable.DisplayName)

									textWidth = FrameMan:CalculateTextWidth(button.Buildable.DisplayName .. " ", true)
									textWidth_price = FrameMan:CalculateTextWidth(tostring(button.Buildable.Cost), true)
									oz_width = FrameMan:CalculateTextWidth("oz", true)
									textPos = offset + Vector(textWidth, 0) + Vector(tooltip_bar:GetPosX() + 10, tooltip_bar:GetPosY() + 25)
								end

								PrimitiveMan:DrawTextPrimitive(screen, textPos, "(", true, 0)
								DisplayNumber(self, screen,
								itemFund and "Green" or "Red",
								textPos + Vector(4, 0),
								tostring(button.Buildable.Cost))

								PrimitiveMan:DrawTextPrimitive(screen, textPos + Vector(4 + textWidth_price, 0), "oz", true, 0)
								PrimitiveMan:DrawTextPrimitive(screen,
								textPos + Vector(4 + textWidth_price + oz_width, 0), ")",
								true,
								0)
								button:OutlineColor(itemFund and 117 or 13)

								button:Color(hasFund and 127 or 249)
							else
								button:OutlineColor(144)
							end

							PrimitiveMan:DrawBitmapPrimitive(screen, world_pos + Vector(button:GetSize()) / 2 + button.Buildable.IconPos, button.Buildable.IconPath, 0)

							if not self.Menu:cursor_inside(parent_world_pos, Vector(button:GetParent():GetSize())) and button.Selected then
								local size = (Vector(box.Width, box.Height) / 2)
								renderPos = self.Menu.Cursor
								if button.Buildable.SnapToGround then
									renderPos = SceneMan:MovePointToGround(renderPos, 1, 1)
									renderPos.Y = renderPos.Y - (box.Height / 2)
	
									--If we are floating it's invalid
									if SceneMan:FindAltitude(renderPos, 0, 10) > button.Buildable.MaxAltitude then
										validPlacement = false
									end
								else
									validPlacement = true
								end

								local startPos = renderPos - size
								local endPos = renderPos + size
								local totalPixels = (endPos.X - startPos.X + 1) * (endPos.Y - startPos.Y + 1)
								local nonAirPixels = 0
								validPlacement = true

								for x = startPos.X, endPos.X do
									for y = startPos.Y, endPos.Y do
										local terraCheck = SceneMan:GetTerrMatter(x, y)
										if terraCheck ~= rte.airID then
											nonAirPixels = nonAirPixels + 1
										end
									end
								end

								local nonAirRatio = nonAirPixels / totalPixels
								if nonAirRatio > tolerance then
									validPlacement = false
								end

								local radius = math.abs(box.Corner.X)
								local foundMO = nil
								local MOs = MovableMan:GetMOsInRadius(renderPos, radius + maxRadius, -1, false)
								for mo in MOs do
									if mo then
										if mo:IsInGroup("CED - Buildables") then
											foundMO = mo
										end
										if IsActor(mo) then
											foundMO = mo
										end
									end
								end

								if foundMO then
									validPlacement = false
								end

								PrimitiveMan:DrawPrimitives(50, {
									BoxFillPrimitive(screen, renderPos + box.Corner, renderPos + size, validPlacement and 5 or 13),
									BitmapPrimitive(screen, renderPos, button.Buildable.RenderPath, 0, false, false)
								});

								if self.SelectDelayTime:IsPastSimMS(200) then
									if self.Menu.Controller then
										if self.Menu.Controller:IsState(Controller.PRIMARY_ACTION) then
											if validPlacement then
												local createFunc = "Create" .. button.Buildable.BuildableClassName
												local buildablePreset = _G[createFunc](button.Buildable.BuildablePresetName, button.Buildable.BuildableTechName);
												buildablePreset.Team = entity.Team
												buildablePreset.Pos = renderPos
												MovableMan:AddParticle(buildablePreset)
												self.Activity:SetTeamFunds(self.Activity:GetTeamFunds(entity.Team) - button.Buildable.Cost, entity.Team)
												self.ConfirmSound:Play(-1)
												self.SelectDelayTime:Reset()
												print("Just placed the following: " .. button.Buildable.DisplayName);
											else
												self.ErrorSound:Play(-1)
												self.SelectDelayTime:Reset()
											end
										end
									end
								end
							end
							if isRemoving then
								button.Selected = false
							end
						end

						button.OnPress = function(key)
							if key == Controller.PRIMARY_ACTION then
								if itemFund then
									self.ConfirmSound:Play(-1)
									self.SelectDelayTime:Reset()
									box = button.Buildable.RenderSize
									isRemoving = false
									self.Menu.Cursor_Bitmap = "Data/Base.rte/GUIs/Skins/Cursor.png"
									for _, btn in ipairs(buttons) do
										btn.Selected = false
									end
									button.Selected = true
								else
									self.ErrorSound:Play(-1)
								end
							end
						end

						table.insert(buttons, button)

						currentHeight = y + posMultiplier
						height = math.min(maxHeight, currentHeight)
					end

					self.Main.Box.Think = function(entity, screen)
						self.Main.Box:SetSize(260, height + self.cancel_button:GetHeight())
						self.cancel_button:SetPos(5, self.Main.Box:GetHeight() - 20)

						if self.Menu.Controller then
							--Without this if statement it will scroll regardless
							if height == maxHeight then
								local go_up = self.Menu.Controller:IsState(Controller.SCROLL_UP)
								local go_down = self.Menu.Controller:IsState(Controller.SCROLL_DOWN)
	
								if go_up then
									--Subtracts 1
									scroll = math.max(0, scroll - 1)
								elseif go_down then
									--Adds 1
									scroll = math.min(totalRows - rows, scroll + 1)
								end

								--This whole fucking thing is just itself then recreates itself, and it's within itself. xd
								for i = 1, #mainTab.BuildList do
									local row = math.floor((i - 1) / rows) + 1
									local isVisible = row >= scroll + 1 and row < scroll + 1 + rows
									--Everything that is parented to self.Main.Box is a key string
									local button = self.Main.Box.Child["Buildable " .. i]
									if button then --If it somehow doesn't exist wtf

										--Epic copy and paste
										local x = 0 + self.Main.Box:GetPosX() + ((i - 1) % rows + 1 - 1) * posMultiplier
										local y = 40 + (math.floor((i - 1) / rows ) + 1 - 1) * posMultiplier
										button:SetPos(x, y - scroll * posMultiplier)
										button:SetVisible(isVisible)
									end
								end
							end
						end
					end
				end
			end
		end
		self.cancel_button = self.Menu:CreateGUI("Button", self.Main.Box)
		self.cancel_button:SetPos(5, self.cancel_button:GetParent():GetHeight() - 20)
		self.cancel_button:SetSize(26, 16)
		self.cancel_button:SetText("Remove\nBuild")
		self.cancel_button:TextPos(1, -4)
		self.cancel_button:Color(146)
		self.cancel_button:OutlineColor(144)
		self.cancel_button:OutlineThickness(2)

		self.cancel_button.Think = function(entity, screen)
			self.cancel_button:OutlineColor(self.cancel_button.IsHovered and 117 or 144)

			if isRemoving then
				local MOs = MovableMan:GetMOsInRadius(self.Menu.Cursor, 15, -1, false)
				for mo in MOs do
					if mo then
						if mo:IsInGroup("CED - Buildables") then
							local buildable = nil
							for group in pairs(self.CEDAvailableBuildables) do
								local category = self.CEDAvailableBuildables[group]
								for _, item in pairs(category) do
									if item.BuildablePresetName == mo.PresetName then
										buildable = item
										break
									end
								end
							end
							if buildable then
								--Temp cursor snap
								self.Menu.Cursor = mo.Pos

								--I think it's a good idea to set it once instead of constantly
								if box == nil then
									box = buildable.RenderSize
								end
								local size = (Vector(box.Width, box.Height) / 2)
								renderPos = mo.Pos
								PrimitiveMan:DrawPrimitives(50, {
									BoxFillPrimitive(screen, renderPos + box.Corner, renderPos + size, 13),
								});

								if self.Menu.Controller then 
									if self.Menu.Controller:IsState(Controller.PRIMARY_ACTION) then
										self.ErrorSound:Play(-1)
										self.Menu.Cursor_Bitmap = "Data/Base.rte/GUIs/Skins/Cursor.png"
										isRemoving = false
										mo:SendMessage("CED_CancelBuildable")
									end
								end
							end
						end
					end
				end
			end
		end

		self.cancel_button.OnPress = function(key)
			if key == Controller.PRIMARY_ACTION then
				self.Menu.Cursor_Bitmap = "Mods/CED.rte/Actors/Shared/Sprites/Menus/CancelCursor.png"
				box = nil
				isRemoving = true
			end
		end
	end

	drawMenu()
end

function ThreadedUpdate(self)
	if self:IsPlayerControlled() then
		if self:NumberValueExists("BuilderMenu") then
			self.Main = {}
			self.Menu:New(self, self.MenuFunc[1])
			self:RemoveNumberValue("BuilderMenu")
		end
	else
		self.Menu:Remove()
	end
	if self.Menu:Update(self) then
	    for k, gui in pairs(self.Main) do
	        gui:Update(self, {Cursor = self.Menu.Cursor})
	    end
	    self.Menu:DrawCursor(self.Menu.Screen)
	end
end

function Destroy(self)
	self.Menu:Remove()
end