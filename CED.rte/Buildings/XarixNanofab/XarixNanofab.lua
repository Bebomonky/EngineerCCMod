require("Mods.Extensions.ExtensionMan")

function OnGlobalMessage(self, message, object)
	if message == tostring(self.Team) .. "_Research" then
		for i = 1, #self.Category do
			local tab = self.Category[i]
			local constructList = tab[2]
			for j = 1, #constructList do
				local construct = constructList[j]
				if construct.ResearchName == object then
					self.ResearchList[i][j] = true
				end
			end
		end
	end
end

function OnMessage(self, message, object)
	if message == tostring(self.Team) .. "_Research" then
		for i = 1, #self.Category do
			local tab = self.Category[i]
			local constructList = tab[2]
			for j = 1, #constructList do
				local construct = constructList[j]
				if construct.ResearchName ~= nil and construct.ResearchName == object then
					self.ResearchList[i][j] = true
				end
			end
		end
	end
end

function Create(self)
	self.Menu = table.Copy(require("Mods.Extensions.imenu.core"))
	self.Menu:Initialize()

	self.MenuFunc = {}
	self.MenuFunc[1] = ConstructBasic
	self.Main = {}

	self.ConfirmSound = CreateSoundContainer("Base.rte/Confirm")
	self.ErrorSound = CreateSoundContainer("Base.rte/Error")

	self.SelectDelayTime = Timer()

	self.Activity = ActivityMan:GetActivity()

	for mo in MovableMan.Particles do
		if mo.PresetName == "CED Technology Controller" and mo.Team == self.Team then
			self.technologyController = mo;
		end
	end
	for mo in MovableMan.AddedParticles do
		if mo.PresetName == "CED Technology Controller" and mo.Team == self.Team then
			self.technologyController = mo;
		end
	end

	self.Category = {
		{"Progress", {}},
		{"Infantry", self.CEDAvailableConstructs.Actors},
		{"Guns", self.CEDAvailableConstructs.Guns},
	}

	self.Queue = {}
	self.QueueButtons = {}
	self.QueueTime = Timer()
	self.QueueDelay = 1000

	self.QueueProgress = {
		Timer = Timer(),
		SavedElapsedSimTimeMS = 0,
		InProgress = false,
		Active = false,
		Visible = false,
		Fraction = 0,
	}

	self.ResearchList = {}
	for i = 1, #self.Category do
		local tab = self.Category[i]
		local constructList = tab[2]
		self.ResearchList[i] = {}
		for j = 1, #constructList do
			local construct = constructList[j]
			if construct.ResearchName ~= nil then
				self.ResearchList[i][j] = false
				if self.technologyController ~= nil then
					if self.technologyController:NumberValueExists(construct.ResearchName) then
						self.ResearchList[i][j] = true
					end
				end
			else
				self.ResearchList[i][j] = true
			end
		end
	end

	self.ActorQueueBar = self.Menu:CreateGUI("ProgressBar")
	self.ActorQueueBar:SetPos(self.Pos.X - 25, self.Pos.Y - 60)
	self.ActorQueueBar:SetSize(50, 4)
	self.ActorQueueBar:BGColor(146)
	self.ActorQueueBar:FGColor(117)
	self.ActorQueueBar:OutlineColor(144)
	self.ActorQueueBar:SetVisible(false)
	self.ActorQueueBar:DividedFromMenu(true)
	self.ActorQueueBar:SetScreen(self.Team)
end

function DisplayNumber(self, screen, color, pos, text)
	for i = 1, string.len(text) do
		local digit = string.sub(text, i, i)
		PrimitiveMan:DrawBitmapPrimitive(pos + Vector((3 + 1) * (i - 1) + 1, 5),
		"CED.rte/Effects/Font/" .. color .. "/Numbers/" .. digit .. ".png", 0)
	end
end

--This is the greatest ConstructBasic of all time
function ConstructBasic(self)
	self.Main.Box = self.Menu:CreateGUI("CollectionBox")
	self.Main.Box:SetTitle("")
	self.Main.Box:SetPos(10, 25)
	self.Main.Box:SetSize(260, 50)
	self.Main.Box:Color(146)
	self.Main.Box:OutlineColor(71)
	self.Main.Box:OutlineThickness(2)

	self.menu_data = {
		Rows = 3,
		QueueRows = 5,
		Scroll = 0,
		MaxHeight = 295,
		Height = 0,
		--used for Distance between buttons, height
		PosMultiplier = 85,
		TextWidth = 0,
		TextWidth_price = 0,
		Oz_width = 0,
		TextPos = Vector(),
		ItemFund = false,
		Pickedactor = false,
	}
	drawMenu(self, self.menu_data)
end

function resetMenu(self, data)
	self.Main.Box:ClearChildren()
	drawMenu(self, data)
end

function ProgressMenu(self, menu_data)
	if self.QueueProgress.InProgress == true then
		self.MenuQueueBar:SetVisible(true)
		self.QueueProgress.Visible = true
	end

	self.QueueButtons = {}
	local currentHeight = 40
	menu_data.Height = 0
	menu_data.Height = math.max(menu_data.Height, currentHeight)
	for i = 1, #self.Queue do
		local construct = self.Queue[i] --IconPath
		local x = 8 + self.Main.Box:GetPosX() + ((i - 1) % menu_data.QueueRows + 1 - 1) * 45
		local y = 60 + (math.floor((i - 1) / menu_data.QueueRows ) + 1 - 1) * 45
		local button = self.Menu:CreateGUI("Button", self.Main.Box, "QueueButton" .. i)
		button.HasThickness = true
		button:SetPos(x, y)
		button:SetSize(30, 30)
		button:TextPos(0, 0)
		button:Color(146)
		button:OutlineColor(144)
		button:OutlineThickness(2)

		button.OnPress = function(key)
			if key == Controller.PRIMARY_ACTION then
				button:Remove()
				print("Cancelled queue item: " .. self.Queue[i].EntityPresetName)
				if construct.StoredEntity ~= nil then
					MovableMan:AddActor(construct.StoredEntity)
				end
				if construct.Cost ~= nil then
					self.Activity:SetTeamFunds(self.Activity:GetTeamFunds(self.Team) + construct.Cost, self.Team)
				end
				table.remove(self.Queue, i)
				table.remove(self.QueueButtons, i)
				resetMenu(self, menu_data)
				ProgressMenu(self, menu_data)
				self.QueueProgress.Fraction = 0
				self.MenuQueueBar:SetFraction(0)
				self.ActorQueueBar:SetFraction(0)
				self.MenuQueueBar:SetText("")
			end
		end

		button.Think = function(entity, screen)
			if button then
				local offset = CameraMan:GetOffset(screen)
				local world_pos = Vector(button:GetParent():GetPos()) + Vector(button:GetPos()) + offset

				if button.IsHovered then
					button:OutlineColor(117)
					button:Color(127)
				else
					button:OutlineColor(144)
					button:Color(146)
				end

				PrimitiveMan:DrawBitmapPrimitive(screen, world_pos + Vector(button:GetSize()) / 2 + Vector(0, -1), construct.IconPath, 0)
			end
		end

		currentHeight = y + menu_data.PosMultiplier
		menu_data.Height = math.min(menu_data.MaxHeight, currentHeight)
		table.insert(self.QueueButtons, button)
	end

	local totalRows = math.ceil(#self.QueueButtons / menu_data.QueueRows)
	self.Main.Box.Think = function(entity, screen)
		self.Main.Box:SetSize(260, menu_data.Height)

		if self.Menu.Controller then
			--Without this if statement it will scroll regardless
			if menu_data.Height == menu_data.MaxHeight then
				local go_up = self.Menu.Controller:IsState(Controller.SCROLL_UP)
				local go_down = self.Menu.Controller:IsState(Controller.SCROLL_DOWN)

				if go_up then
					--Subtracts 1
					menu_data.Scroll = math.max(0, menu_data.Scroll - 1)
				elseif go_down then
					--Adds 1
					menu_data.Scroll = math.min(totalRows - menu_data.QueueRows, menu_data.Scroll + 1)
				end

				for i = 1, #self.QueueButtons do
					local button = self.QueueButtons[i]
					local row = math.floor((i - 1) / menu_data.QueueRows) + 1
					local isVisible = row >= menu_data.Scroll + 1 and row < menu_data.Scroll + 1 + menu_data.QueueRows
					local y = 60 + (math.floor((i - 1) / menu_data.QueueRows ) + 1 - 1) * 45
					button:SetPos(button:GetPosX(), y - menu_data.Scroll * 45)
					button:SetVisible(isVisible)
				end
			end
		end
	end
end

function drawMenu(self, menu_data)

	self.MenuQueueBar = self.Menu:CreateGUI("ProgressBar", self.Main.Box)
	self.MenuQueueBar:SetPos(10, 30)
	self.MenuQueueBar:SetSize(230, 10)
	self.MenuQueueBar:BGColor(146)
	self.MenuQueueBar:FGColor(117)
	self.MenuQueueBar:OutlineColor(144)
	self.MenuQueueBar:SetVisible(self.QueueProgress.Visible)
	self.MenuQueueBar.Timer = Timer()
	self.MenuQueueBar.Timer.ElapsedSimTimeMS = self.QueueProgress.SavedElapsedSimTimeMS
	self.MenuQueueBar.InProgress = self.QueueProgress.InProgress
	self.MenuQueueBar:SetFraction(self.QueueProgress.Fraction)

	local isUpdated = false
	self.MenuQueueBar.Think = function(entity, screen)
		if not isUpdated then
			self.MenuQueueBar:SetFraction(self.QueueProgress.Fraction)
			isUpdated = true
		end
		if self.QueueProgress.InProgress then
			self.QueueProgress.SavedElapsedSimTimeMS = self.MenuQueueBar.Timer.ElapsedSimTimeMS
		end
	end

	for i = 1, #self.Category do
		local tab = self.Category[i]
		local name = tab[1]
		local constructList = tab[2]

		local x = -3 + self.Main.Box:GetPosX() + ((i - 1) % 4 + 1 - 1) * 65
		local y = 5 + (math.floor((i - 1) / 4 ) + 1 - 1) * 35

		local mainTab = self.Menu:CreateGUI("Button", self.Main.Box)
		mainTab.BuildList = constructList
		mainTab.Index = i
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
				self.SelectDelayTime:Reset()
				resetMenu(self, menu_data)
				if i == 1 then
					self.IsInProgressMenu = true
					ProgressMenu(self, menu_data)
				else
					self.IsInProgressMenu = false
					self.MenuQueueBar:SetVisible(false)
					if table.IsEmpty(mainTab.BuildList) then
						print("Table is empty!")
						self.ErrorSound:Play(-1)
						return
					end

					local currentHeight = 40
					menu_data.Height = math.max(menu_data.Height, currentHeight)

					local scroll = 0
					local totalRows = math.ceil(#mainTab.BuildList / menu_data.Rows)

					local tooltip_bar = self.Menu:CreateGUI("CollectionBox", self.Main.Box)
					tooltip_bar:SetTitle("")
					tooltip_bar:SetPos(tooltip_bar:GetParent():GetWidth() + 10, 25)
					tooltip_bar:SetSize(100, 75)
					tooltip_bar:Color(146)
					tooltip_bar:OutlineColor(71)
					tooltip_bar:OutlineThickness(2)
					tooltip_bar:SetVisible(false) --Set to false to prevent flicker
					tooltip_bar.Displaying = false

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

					local buttons = {}
					for i = 1, #mainTab.BuildList do
						local x = 0 + self.Main.Box:GetPosX() + ((i - 1) % menu_data.Rows + 1 - 1) * menu_data.PosMultiplier
						local y = 40 + (math.floor((i - 1) / menu_data.Rows ) + 1 - 1) * menu_data.PosMultiplier

						local button = self.Menu:CreateGUI("Button", self.Main.Box)
						button.Construct = mainTab.BuildList[i]
						button.HasThickness = true
						button:SetPos(x, y)
						button:SetSize(65, 65)
						button:SetText(button.Construct.DisplayName)
						button:TextPos(0, 10)
						button:Color(146)
						button:OutlineColor(144)
						button:OutlineThickness(2)

						button.Think = function(entity, screen)
							local offset = CameraMan:GetOffset(screen)
							local world_pos = Vector(button:GetParent():GetPos()) + Vector(button:GetPos()) + offset
							local parent_world_pos = Vector(button:GetParent():GetPos()) + offset
							local hasFund = self.Activity:GetTeamFunds(entity.Team) >= button.Construct.Cost
							button.IsResearched = self.ResearchList[mainTab.Index][i]
							if button.IsResearched == true then
								if button.HasThickness == false then
									button:OutlineThickness(2)
									button.HasThickness = true
								end
							else
								if button.HasThickness == true then
									button:OutlineThickness(0)
									button.HasThickness = false
								end
							end
							button:Color(hasFund and 146 or 248)

							if button.IsHovered then
								menu_data.ItemFund = self.Activity:GetTeamFunds(entity.Team) >= button.Construct.Cost
								tooltip_bar:SetVisible(true)
								desc:SetVisible(true)
								if tooltip_bar.Displaying == false then
									local size = button.Construct.TooltipSize
									tooltip_bar:SetSize(size.X, size.Y)
									desc:SetSize(size.X, size.Y)
									tooltip_bar:SetTitle(button.Construct.DisplayName)

									menu_data.TextWidth = FrameMan:CalculateTextWidth(button.Construct.DisplayName .. " ", true)
									if button.Construct.Cost > 0 then
										menu_data.TextWidth_price = FrameMan:CalculateTextWidth(tostring(button.Construct.Cost), true)
										menu_data.Oz_width = FrameMan:CalculateTextWidth("oz", true)
									else
										menu_data.TextWidth_price = FrameMan:CalculateTextWidth("FREE", true)
									end
									menu_data.TextPos = offset + Vector(menu_data.TextWidth, 0) + Vector(tooltip_bar:GetPosX() + 10, tooltip_bar:GetPosY() + 25)
									tooltip_bar.Displaying = true
								end

								local button_text
								if button.IsResearched == true then
									button_text = button.Construct.Description
								else
									button_text = "Research Required: " .. button.Construct.ResearchName .. "\n" .. button.Construct.Description
								end
								desc:SetText(button_text)

								PrimitiveMan:DrawTextPrimitive(screen, menu_data.TextPos, "(", true, 0)
								DisplayNumber(self, screen,
								menu_data.ItemFund and "Green" or "Red",
								menu_data.TextPos + Vector(4, 0),
								button.Construct.Cost > 0 and tostring(button.Construct.Cost) or "FREE")

								if button.Construct.Cost > 0 then
									PrimitiveMan:DrawTextPrimitive(screen, menu_data.TextPos + Vector(4 + menu_data.TextWidth_price, 0), "oz", true, 0)
									PrimitiveMan:DrawTextPrimitive(screen,
									menu_data.TextPos + Vector(4 + menu_data.TextWidth_price + menu_data.Oz_width, 0), ")",
									true,
									0)
								else
									PrimitiveMan:DrawTextPrimitive(screen,
									menu_data.TextPos + Vector(4 + menu_data.TextWidth_price, 0), ")",
									true,
									0)
								end
								if button.IsResearched == true then
									button:OutlineColor(menu_data.ItemFund and 117 or 13)

									button:Color(menu_data.ItemFund and 127 or 249)
								else
									button:OutlineColor(13)
									button:Color(249)
								end
							else
								if button.IsResearched == true then
									button:OutlineColor(144)
								else
									button:Color(249)
								end
								tooltip_bar.Displaying = false
							end

							PrimitiveMan:DrawBitmapPrimitive(screen, world_pos + Vector(button:GetSize()) / 2 + button.Construct.IconPos, button.Construct.IconPath, 0)
							if mainTab.Index == 2 then
								if not self.Menu:cursor_inside(parent_world_pos, Vector(button:GetParent():GetSize())) then --Infantry
									if self.ClosestActor ~= nil then
										if self.SelectDelayTime:IsPastSimMS(200) then
											if self.Menu.Controller then
												for actor in MovableMan:GetMOsInRadius(self.Menu.Cursor, 15, -1, false) do
													--check distance between cursor and actor
													if actor:IsInGroup("Actors - Builders") then
														if IsAHuman(actor) then
															actor = ToAHuman(actor)
															if actor.UniqueID == self.ClosestActor.UniqueID then
																if self.Menu.Controller:IsState(Controller.PRIMARY_ACTION) and menu_data.Pickedactor == false then
																	self.ConfirmSound:Play(-1)
																	self.SelectDelayTime:Reset()
																	print("Creating actor: " .. button.Construct.DisplayName);
																	local inv = {}
																	for item in actor.Inventory do
																		table.insert(inv, _G["To" .. item.ClassName](item):Clone())
																	end
																	table.insert(self.Queue,
																	{
																		Increment = 1.0 / (button.Construct.QueueTime / self.QueueDelay),
																		StoredEntity = MovableMan:RemoveActor(actor),
																		EntityPresetName = button.Construct.EntityPresetName,
																		EntityClassName = button.Construct.EntityClassName,
																		EntityTechName = button.Construct.EntityTechName,
																		QueueTime = button.Construct.QueueTime,
																		IconPos = button.Construct.IconPos,
																		IconPath = button.Construct.IconPath,
																		Cost = button.Construct.Cost > 0 and button.Construct.Cost or nil,
																		PrimaryWeapon = actor.EquippedItem ~= nil and _G["To" .. actor.EquippedItem.ClassName](actor.EquippedItem):Clone() or nil,
																		OffhandWeapon = actor.EquippedBGItem ~= nil and _G["To" .. actor.EquippedBGItem.ClassName](actor.EquippedBGItem):Clone() or nil,
																		Timer = Timer(),
																		Inventory = inv,
																		Pos = Vector(actor.Pos.X, actor.Pos.Y)
																	})
																	self.Queue[#self.Queue].Timer:Reset()
																	self.QueueProgress.InProgress = true
																	menu_data.Pickedactor = true
																	if button.Construct.Cost > 0 then
																		self.Activity:SetTeamFunds(self.Activity:GetTeamFunds(self.Team) - button.Construct.Cost, self.Team)
																	end
																end
															end
														end
													end
												end
											end
										end
									else
										if self.SelectDelayTime:IsPastSimMS(200) then
											if self.Menu.Controller:IsState(Controller.PRIMARY_ACTION) then
												self.ErrorSound:Play(-1)
												self.SelectDelayTime:Reset()
											end
										end
									end
								end
							end
						end

						button.OnPress = function(key)
							if key == Controller.PRIMARY_ACTION then
								if button.IsResearched == false then
									self.ErrorSound:Play(-1)
								else
									if menu_data.ItemFund then
										if mainTab.Index == 2 then --Infantry
											menu_data.Pickedactor = false
										elseif mainTab.Index == 3 then --Guns
											print("Creating Device: " .. button.Construct.DisplayName);
											table.insert(self.Queue,
											{
												Increment = 1.0 / (button.Construct.QueueTime / self.QueueDelay),
												EntityPresetName = button.Construct.EntityPresetName,
												EntityClassName = button.Construct.EntityClassName,
												EntityTechName = button.Construct.EntityTechName,
												QueueTime = button.Construct.QueueTime,
												IconPos = button.Construct.IconPos,
												IconPath = button.Construct.IconPath,
												Cost = button.Construct.Cost > 0 and button.Construct.Cost or nil,
												Timer = Timer(),
											})
											self.Queue[#self.Queue].Timer:Reset()
											self.QueueProgress.InProgress = true
											if button.Construct.Cost > 0 then
												self.Activity:SetTeamFunds(self.Activity:GetTeamFunds(self.Team) - button.Construct.Cost, self.Team)
											end
										end
										self.ConfirmSound:Play(-1)
										self.SelectDelayTime:Reset()
									else
										self.ErrorSound:Play(-1)
									end
								end
							end
						end

						currentHeight = y + menu_data.PosMultiplier
						menu_data.Height = math.min(menu_data.MaxHeight, currentHeight)
						table.insert(buttons, button)
					end
					self.Main.Box.Think = function(entity, screen)
						self.Main.Box:SetSize(260, menu_data.Height)
	
						if self.Menu.Controller then
							--Without this if statement it will scroll regardless
							if menu_data.Height == menu_data.MaxHeight then
								local go_up = self.Menu.Controller:IsState(Controller.SCROLL_UP)
								local go_down = self.Menu.Controller:IsState(Controller.SCROLL_DOWN)
	
								if go_up then
									--Subtracts 1
									scroll = math.max(0, scroll - 1)
								elseif go_down then
									--Adds 1
									scroll = math.min(totalRows - menu_data.Rows, scroll + 1)
								end

								for i = 1, #buttons do
									local button = buttons[i]
									local row = math.floor((i - 1) / menu_data.Rows) + 1
									local isVisible = row >= scroll + 1 and row < scroll + 1 + menu_data.Rows
									local y = 40 + (math.floor((i - 1) / menu_data.Rows ) + 1 - 1) * menu_data.PosMultiplier
									button:SetPos(button:GetPosX(), y - scroll * menu_data.PosMultiplier)
									button:SetVisible(isVisible)
								end
							end
						end
					end
				end
			end
		end
	end
end

function ThreadedUpdate(self)
	if self:IsPlayerControlled() then
		if not self.Menu.Open then
			self.Main = {};
			self.Menu:New(self, self.MenuFunc[1]);
		end
	else
		self.ActorQueueBar:Update(self, {Cursor = self.Menu.Cursor})
		self.Menu:Remove()
	end

	if table.IsEmpty(self.Queue) then
		if self.QueueProgress.InProgress == true then
			self.MenuQueueBar:SetVisible(false)
			self.ActorQueueBar:SetVisible(false)
			self.QueueProgress.Visible = false
			self.QueueProgress.Fraction = 0
			self.MenuQueueBar:SetFraction(0)
			self.ActorQueueBar:SetFraction(0)
			self.MenuQueueBar:SetText("")
			self.QueueProgress.InProgress = false
		end
	else
		for i = 1, #self.Queue do
			if i == 1 then
				local construct = self.Queue[i]
				if self.QueueProgress.Fraction >= 0.99 then
					if construct.EntityClassName == "AHuman" then
						local createFunc = "Create" .. construct.EntityClassName
						local constructPreset = _G[createFunc](construct.EntityPresetName, construct.EntityTechName);
						constructPreset.Team = self.Team
						constructPreset.Pos = construct.Pos
						MovableMan:AddActor(constructPreset)
						if not table.IsEmpty(construct.Inventory) then
							for _, item in pairs(construct.Inventory) do
								constructPreset:AddInventoryItem(item)
							end
						end
						if construct.PrimaryWeapon ~= nil then
							constructPreset:AddInventoryItem(construct.PrimaryWeapon)
							constructPreset:EquipNamedDevice(construct.PrimaryWeapon:GetModuleAndPresetName(), true)
						end
						if construct.OffhandWeapon ~= nil then
							constructPreset:AddInventoryItem(construct.OffhandWeapon)
							constructPreset:EquipNamedDevice(construct.OffhandWeapon:GetModuleAndPresetName(), true)
						end
					elseif construct.EntityClassName == "ACrab" then
						local createFunc = "Create" .. construct.EntityClassName
						local constructPreset = _G[createFunc](construct.EntityPresetName, construct.EntityTechName);
						constructPreset.Team = self.Team
						constructPreset.Pos = construct.Pos
						MovableMan:AddActor(constructPreset)
					elseif (construct.EntityClassName == "HDFirearm"
					or construct.EntityClassName == "TDExplosive"
					or construct.EntityClassName == "HeldDevice") then
						local createFunc = "Create" .. construct.EntityClassName
						local weaponPreset = _G[createFunc](construct.EntityPresetName, construct.EntityTechName);
						weaponPreset.Pos = self.Pos + Vector(-50, 6)
						weaponPreset.RotAngle = 0.45
						weaponPreset.Vel = Vector()
						MovableMan:AddItem(weaponPreset)
					end
					if self.IsInProgressMenu then
						self.QueueButtons[i]:Remove()
					end
					print("Finished queue item: " .. construct.EntityPresetName)
					table.remove(self.Queue, 1)
					table.remove(self.QueueButtons, 1)
					if self.IsInProgressMenu then
						resetMenu(self, self.menu_data)
						ProgressMenu(self, self.menu_data)
					end
					self.QueueProgress.Fraction = 0
					self.MenuQueueBar:SetFraction(0)
					self.ActorQueueBar:SetFraction(0)
					self.MenuQueueBar:SetText("")
				else
					--Visual queue
					self.MenuQueueBar:SetVisible(self.IsInProgressMenu)
					if self.MenuQueueBar.Timer:IsPastSimMS(1000) then
						self.QueueProgress.Fraction = self.QueueProgress.Fraction + construct.Increment
						self.MenuQueueBar:SetFraction(self.QueueProgress.Fraction)
						self.ActorQueueBar:SetFraction(self.QueueProgress.Fraction)
						self.MenuQueueBar.Timer:Reset()
					end
					self.MenuQueueBar:SetText(string.format("%.0f%%", self.QueueProgress.Fraction * 100))
					if self:IsPlayerControlled() == false and self.QueueProgress.InProgress == true then
						if self.ActorQueueBar:GetVisible() == false then
							self.IsInProgressMenu = false
							self.ActorQueueBar:SetVisible(true)
						end
					else
						if self.ActorQueueBar:GetVisible() == true then
							self.ActorQueueBar:SetVisible(false)
						end
					end
				end
			end
		end
	end

	--This is to prevent menu resize bugs
	local dontUpdateMenu = false
	for _, input in pairs({Controller.SECONDARY_ACTION, Controller.ACTOR_NEXT_PREP, Controller.ACTOR_PREV_PREP}) do
		if self:GetController():IsState(input) then
			dontUpdateMenu = true
			break
		end
	end
	if dontUpdateMenu == false then
		if self.Menu:Update(self) then
			for k, gui in pairs(self.Main) do
				gui:Update(self, {Cursor = self.Menu.Cursor})
			end
			self.Menu:DrawCursor(self.Menu.Screen)
		end
	end
end

function Destroy(self)
	self.Menu:Remove()
end