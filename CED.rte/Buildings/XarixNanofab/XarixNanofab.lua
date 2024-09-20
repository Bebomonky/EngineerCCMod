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
		rows = 3,
		maxHeight = 295,
		height = 0,
		--used for Distance between buttons, height
		posMultiplier = 85,
		textWidth = 0,
		textWidth_price = 0,
		oz_width = 0,
		textPos = Vector(),
		itemFund = false,
		pickedActor = false,
	}
	drawMenu(self, self.menu_data)
end

function resetMenu(self, data)
	self.Main.Box:ClearChildren()
	drawMenu(self, data)
end

function ProgressMenu(self, menu_data)
	if self.QueueProgress.InProgress == true then
		self.QueueBar:SetVisible(true)
		self.QueueProgress.Visible = true
	end
	local currentHeight = 40
	menu_data.height = 0
	menu_data.height = math.max(menu_data.height, currentHeight)
	for i = 1, #self.Queue do
		local x = 8 + self.Main.Box:GetPosX() + ((i - 1) % 5 + 1 - 1) * 45
		local y = 60 + (math.floor((i - 1) / 5 ) + 1 - 1) * 45
		self.QueueButtons[i] = self.Menu:CreateGUI("Button", self.Main.Box)
		self.QueueButtons[i].HasThickness = true
		self.QueueButtons[i]:SetPos(x, y)
		self.QueueButtons[i]:SetSize(30, 30)
		self.QueueButtons[i]:SetText(tostring(i))
		self.QueueButtons[i]:TextPos(0, 0)
		self.QueueButtons[i]:Color(146)
		self.QueueButtons[i]:OutlineColor(144)
		self.QueueButtons[i]:OutlineThickness(2)

		self.QueueButtons[i].Think = function(entity, screen)
			if self.QueueButtons[i].IsHovered then
				self.QueueButtons[i]:OutlineColor(117)
				self.QueueButtons[i]:Color(127)
			else
				self.QueueButtons[i]:OutlineColor(144)
				self.QueueButtons[i]:Color(146)
			end
		end

		self.QueueButtons[i].OnPress = function(key)
			if key == Controller.PRIMARY_ACTION then
				self.QueueButtons[i]:Remove()
				table.remove(self.Queue, i)
			end
		end

		currentHeight = y + menu_data.posMultiplier
		menu_data.height = math.min(menu_data.maxHeight, currentHeight)
	end
end

function drawMenu(self, menu_data)

	self.QueueBar = self.Menu:CreateGUI("ProgressBar", self.Main.Box)
	self.QueueBar:SetPos(10, 30)
	self.QueueBar:SetSize(230, 10)
	self.QueueBar:BGColor(146)
	self.QueueBar:FGColor(117)
	self.QueueBar:OutlineColor(144)
	self.QueueBar:SetVisible(self.QueueProgress.Visible)
	self.QueueBar.Timer = Timer()
	self.QueueBar.Timer.ElapsedSimTimeMS = self.QueueProgress.SavedElapsedSimTimeMS
	self.QueueBar.InProgress = self.QueueProgress.InProgress
	self.QueueBar:SetFraction(self.QueueProgress.Fraction)

	local isUpdated = false
	self.QueueBar.Think = function(entity, screen)
		if not isUpdated then
			self.QueueBar:SetFraction(self.QueueProgress.Fraction)
			isUpdated = true
		end
		if self.QueueProgress.InProgress then
			self.QueueProgress.SavedElapsedSimTimeMS = self.QueueBar.Timer.ElapsedSimTimeMS
		end
	end

	self.IsInProgressMenu = false

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
					local scroll = 0
					local totalRows = math.ceil(#self.Queue / 5)
					self.Main.Box.Think = function(entity, screen)
						self.Main.Box:SetSize(260, menu_data.height)
	
						if self.Menu.Controller then
							--Without this if statement it will scroll regardless
							if menu_data.height == menu_data.maxHeight then
								local go_up = self.Menu.Controller:IsState(Controller.SCROLL_UP)
								local go_down = self.Menu.Controller:IsState(Controller.SCROLL_DOWN)
	
								if go_up then
									--Subtracts 1
									scroll = math.max(0, scroll - 1)
								elseif go_down then
									--Adds 1
									scroll = math.min(totalRows - 5, scroll + 1)
								end
	
								--This whole fucking thing is just itself then recreates itself, and it's within itself. xd
								for ii = 1, #self.Queue do
									local row = math.floor((ii - 1) / 5) + 1
									local isVisible = row >= scroll + 1 and row < scroll + 1 + 5
									for iii, button in pairs(self.Main.Box:GetChildren()) do
										if ii == iii then
											--Epic copy and paste
											local x = 8 + self.Main.Box:GetPosX() + ((ii - 1) % 5 + 1 - 1) * 45
											local y = 60 + (math.floor((ii - 1) / 5 ) + 1 - 1) * 45
											button:SetPos(x, y - scroll * 45)
											button:SetVisible(isVisible)
										end
									end
								end
							end
						end
					end
				else
					self.IsInProgressMenu = false
					self.QueueBar:SetVisible(false)
					if table.IsEmpty(mainTab.BuildList) then
						print("Table is empty!")
						self.ErrorSound:Play(-1)
						return
					end

					local currentHeight = 40
					menu_data.height = math.max(menu_data.height, currentHeight)

					local scroll = 0
					local totalRows = math.ceil(#mainTab.BuildList / menu_data.rows)

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

					for i = 1, #mainTab.BuildList do
						local x = 0 + self.Main.Box:GetPosX() + ((i - 1) % menu_data.rows + 1 - 1) * menu_data.posMultiplier
						local y = 40 + (math.floor((i - 1) / menu_data.rows ) + 1 - 1) * menu_data.posMultiplier

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
								menu_data.itemFund = self.Activity:GetTeamFunds(entity.Team) >= button.Construct.Cost
								tooltip_bar:SetVisible(true)
								desc:SetVisible(true)
								if tooltip_bar.Displaying == false then
									local size = button.Construct.TooltipSize
									tooltip_bar:SetSize(size.X, size.Y)
									desc:SetSize(size.X, size.Y)
									tooltip_bar:SetTitle(button.Construct.DisplayName)

									menu_data.textWidth = FrameMan:CalculateTextWidth(button.Construct.DisplayName .. " ", true)
									menu_data.textWidth_price = FrameMan:CalculateTextWidth(tostring(button.Construct.Cost), true)
									menu_data.oz_width = FrameMan:CalculateTextWidth("oz", true)
									menu_data.textPos = offset + Vector(menu_data.textWidth, 0) + Vector(tooltip_bar:GetPosX() + 10, tooltip_bar:GetPosY() + 25)
									tooltip_bar.Displaying = true
								end

								local button_text
								if button.IsResearched == true then
									button_text = button.Construct.Description
								else
									button_text = "Research Required: " .. button.Construct.ResearchName .. "\n" .. button.Construct.Description
								end
								desc:SetText(button_text)

								PrimitiveMan:DrawTextPrimitive(screen, menu_data.textPos, "(", true, 0)
								DisplayNumber(self, screen,
								menu_data.itemFund and "Green" or "Red",
								menu_data.textPos + Vector(4, 0),
								tostring(button.Construct.Cost))

								PrimitiveMan:DrawTextPrimitive(screen, menu_data.textPos + Vector(4 + menu_data.textWidth_price, 0), "oz", true, 0)
								PrimitiveMan:DrawTextPrimitive(screen,
								menu_data.textPos + Vector(4 + menu_data.textWidth_price + menu_data.oz_width, 0), ")",
								true,
								0)
								if button.IsResearched == true then
									button:OutlineColor(menu_data.itemFund and 117 or 13)

									button:Color(menu_data.itemFund and 127 or 249)
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
																if self.Menu.Controller:IsState(Controller.PRIMARY_ACTION) and menu_data.pickedActor == false then
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
																		EntityPresetName = button.Construct.EntityPresetName,
																		EntityClassName = button.Construct.EntityClassName,
																		EntityTechName = button.Construct.EntityTechName,
																		QueueTime = button.Construct.QueueTime,
																		IconPath = button.Construct.IconPath,
																		PrimaryWeapon = actor.EquippedItem ~= nil and _G["To" .. actor.EquippedItem.ClassName](actor.EquippedItem):Clone() or nil,
																		OffhandWeapon = actor.EquippedBGItem ~= nil and _G["To" .. actor.EquippedBGItem.ClassName](actor.EquippedBGItem):Clone() or nil,
																		Timer = Timer(),
																		Inventory = inv,
																		Pos = Vector(actor.Pos.X, actor.Pos.Y)
																	})
																	self.Queue[#self.Queue].Timer:Reset()
																	self.QueueProgress.InProgress = true
																	menu_data.pickedActor = true
																	actor.ToDelete = true
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
									if menu_data.itemFund then
										if mainTab.Index == 2 then --Infantry
											menu_data.pickedActor = false
										elseif mainTab.Index == 3 then --Guns
											print("Creating Device: " .. button.Construct.DisplayName);
											table.insert(self.Queue,
											{
												Increment = 1.0 / (button.Construct.QueueTime / self.QueueDelay),
												EntityPresetName = button.Construct.EntityPresetName,
												EntityClassName = button.Construct.EntityClassName,
												EntityTechName = button.Construct.EntityTechName,
												QueueTime = button.Construct.QueueTime,
												IconPath = button.Construct.IconPath,
												Timer = Timer(),
											})
											self.Queue[#self.Queue].Timer:Reset()
											self.QueueProgress.InProgress = true
										end
										self.ConfirmSound:Play(-1)
										self.SelectDelayTime:Reset()
									else
										self.ErrorSound:Play(-1)
									end
								end
							end
						end

						currentHeight = y + menu_data.posMultiplier
						menu_data.height = math.min(menu_data.maxHeight, currentHeight)
					end
					self.Main.Box.Think = function(entity, screen)
						self.Main.Box:SetSize(260, menu_data.height)
	
						if self.Menu.Controller then
							--Without this if statement it will scroll regardless
							if menu_data.height == menu_data.maxHeight then
								local go_up = self.Menu.Controller:IsState(Controller.SCROLL_UP)
								local go_down = self.Menu.Controller:IsState(Controller.SCROLL_DOWN)
	
								if go_up then
									--Subtracts 1
									scroll = math.max(0, scroll - 1)
								elseif go_down then
									--Adds 1
									scroll = math.min(totalRows - menu_data.rows, scroll + 1)
								end
	
								--This whole fucking thing is just itself then recreates itself, and it's within itself. xd
								for i = 1, #mainTab.BuildList do
									local row = math.floor((i - 1) / menu_data.rows) + 1
									local isVisible = row >= scroll + 1 and row < scroll + 1 + menu_data.rows
									for ii, button in pairs(self.Main.Box:GetChildren()) do
										if i == ii then
											--Epic copy and paste
											local x = 0 + self.Main.Box:GetPosX() + ((i - 1) % menu_data.rows + 1 - 1) * menu_data.posMultiplier
											local y = 40 + (math.floor((i - 1) / menu_data.rows ) + 1 - 1) * menu_data.posMultiplier
											button:SetPos(x, y - scroll * menu_data.posMultiplier)
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
	end
end

function ThreadedUpdate(self)
	if self:IsPlayerControlled() then
		if not self.Menu.Open then
			self.Main = {};
			self.Menu:New(self, self.MenuFunc[1]);
		end
	else
		self.Menu:Remove()
	end

	for i = 1, #self.Queue do
		if i == 1 then
			local construct = self.Queue[i]
			if self.QueueProgress.Fraction >= 0.99 then--[[if math.floor(construct.Timer.ElapsedSimTimeMS) >= construct.QueueTime then]]
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
				print("Finished queue item: " .. construct.EntityPresetName)
				self.QueueProgress.Fraction = 0
				self.QueueBar:SetFraction(0)
				self.QueueBar:SetText("")
				if self.IsInProgressMenu then
					self.QueueButtons[i]:Remove()
				end
				table.remove(self.Queue, 1)
			else
				--Visual queue
				self.QueueBar:SetVisible(self.IsInProgressMenu)
				if self.QueueBar.Timer:IsPastSimMS(1000) then
					self.QueueProgress.Fraction = self.QueueProgress.Fraction + construct.Increment
					self.QueueBar:SetFraction(self.QueueProgress.Fraction)
					self.QueueBar.Timer:Reset()
				end
				self.QueueBar:SetText(string.format("%.0f%%", self.QueueProgress.Fraction * 100))
			end
		end
		--Figure out showing all queues
	end

	if table.IsEmpty(self.Queue) then
		if self.QueueProgress.InProgress == true then
			self.QueueBar:SetVisible(false)
			self.QueueProgress.Visible = false
			self.QueueProgress.Fraction = 0
			self.QueueBar:SetFraction(0)
			self.QueueBar:SetText("")
			self.QueueProgress.InProgress = false
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