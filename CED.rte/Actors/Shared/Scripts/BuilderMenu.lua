require("Mods.Extensions.ExtensionMan")
local igui = require("Mods.Extensions.imenu.igui")

function Create(self)
	self.Menu = require("Mods.Extensions.imenu.core")
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

--This is the greatest BuilderBasic of all time
function BuilderBasic(self)
	self.Main.Box = igui.CollectionBox()
	self.Main.Box:SetTitle("")
	self.Main.Box:SetName("Main")
	self.Main.Box:SetPos(Vector(10, 25))
	self.Main.Box:SetSize(Vector(240, 100))
	self.Main.Box:SetColor(146)
	self.Main.Box:SetOutlineColor(71)
	self.Main.Box:SetOutlineThickness(2)

	local category = {
		{"Fortification", self.CEDAvailableBuildables.Fortifications},
		{"Turrets", self.CEDAvailableBuildables.Turrets},
		{"Buildings", self.CEDAvailableBuildables.Buildings},
		{"Utility", self.CEDAvailableBuildables.Utility}
	}

	--changes mouse bitmap,
	local isRemoving = false
	local renderPos = Vector()
	local box = Box()
	local validPlacement = false
	local tolerance = 0.1

	--Bitmap will be modifed so we need to make sure it's always default
	self.Menu.Cursor_Bitmap = "Data/Base.rte/GUIs/Skins/Cursor.png"

	local rows = 4

	local function drawMenu()
		for i = 1, #category do
			local tab = category[i]
			local name = tab[1]
			local buildableList = tab[2]
	
			local x = -5 + self.Main.Box:GetPos().X + ((i - 1) % rows + 1 - 1) * 60
			local y = 5 + (math.floor((i - 1) / rows ) + 1 - 1) * 35
	
			local mainTab = igui.Button()
			mainTab:SetName(name)
			mainTab.BuildList = buildableList
			mainTab:SetParent(self.Main.Box)
			mainTab:SetPos(Vector(x, y))
			mainTab:SetSize(Vector(50, 13))
			mainTab:SetColor(146)
			mainTab:SetText(name)
			mainTab:SetOutlineThickness(2)
			mainTab:SetOutlineColor(144)
			
			mainTab.Think = function(entity, screen)
				mainTab:SetOutlineColor(mainTab.IsHovered and 117 or 144)
			end
	
			mainTab.OnPress = function(key)
				if key == Controller.PRIMARY_ACTION then
					if table.IsEmpty(mainTab.BuildList) then
						print("Table is empty!")
						self.ErrorSound:Play(-1)
						return
					end
	
					self.Main.Box.Child = {}
					drawMenu()
	
					for i = 1, #mainTab.BuildList do
						local x = -5 + self.Main.Box:GetPos().X + ((i - 1) % rows + 1 - 1) * 60
						local y = 25 + (math.floor((i - 1) / rows ) + 1 - 1) * 35
				
						local button = igui.Button()
						button:SetName("Buildable " .. i)
						button.Buildable = mainTab.BuildList[i]
						button.Buildable.Selected = false
						button:SetParent(self.Main.Box)
						button:SetPos(Vector(x, y))
						button:SetSize(Vector(49, 49))
						button:SetColor(146)
						button:SetText(button.Buildable.DisplayName)
						button:SetTextPos(Vector(0, 10))
						button:SetOutlineThickness(2)
						button:SetOutlineColor(144)
				
						button.Think = function(entity, screen)
							button:SetOutlineColor(button.IsHovered and 117 or 144)
							local world_pos = button.Parent.Pos + button:GetPos() + CameraMan:GetOffset(screen)
							local parent_world_pos = button.Parent.Pos + CameraMan:GetOffset(screen)
							PrimitiveMan:DrawBitmapPrimitive(screen, world_pos + button:GetSize() / 2 + button.Buildable.IconPos, button.Buildable.IconPath, 0)
				
							if not cursor_inside(parent_world_pos, button.Parent.Size) and button.Buildable.Selected then
								local size = (Vector(box.Width, box.Height) / 2)
								renderPos = self.Menu.Cursor
								if button.Buildable.SnapToGround then
									renderPos = SceneMan:MovePointToGround(renderPos, 1, 1)
									renderPos.Y = renderPos.Y - (box.Height / 2)
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
								else
									validPlacement = true
								end
				
								PrimitiveMan:DrawPrimitives(50, {
									BoxFillPrimitive(screen, renderPos + box.Corner, renderPos + size, validPlacement and 5 or 13),
									BitmapPrimitive(screen, renderPos, button.Buildable.RenderPath, 0, false, false)
								});
				
								if self.SelectDelayTime:IsPastSimMS(200) then
									if self.Menu.Controller and self.Menu.Controller:IsState(Controller.PRIMARY_ACTION) then
										if validPlacement then
											local createFunc = "Create" .. button.Buildable.BuildableClassName
											local buildablePreset = _G[createFunc](button.Buildable.BuildablePresetName, button.Buildable.BuildableTechName);
											buildablePreset.Team = entity.Team
											buildablePreset.Pos = renderPos
											MovableMan:AddParticle(buildablePreset)
											self.Activity:SetTeamFunds(self.Activity:GetTeamFunds(entity.Team) - button.Buildable.Cost, entity.Team)
											self.ConfirmSound:Play(-1)
											self.SelectDelayTime:Reset()
											button.Buildable.Selected = false
											print("Just placed the following: " .. button.Buildable.DisplayName);
										else
											self.ErrorSound:Play(-1)
											self.SelectDelayTime:Reset()
										end
									end
								end
							end
							if isRemoving then
								button.Buildable.Selected = false
							end
						end
					
						button.OnPress = function(key)
							if key == Controller.PRIMARY_ACTION then
								self.SelectDelayTime:Reset()
								box = button.Buildable.RenderSize
								isRemoving = false
								self.Menu.Cursor_Bitmap = "Data/Base.rte/GUIs/Skins/Cursor.png"
								button.Buildable.Selected = true
							end
						end
					end
				end
			end
		end

		local cancel_button = igui.Button()
		cancel_button:SetName("Destroy_Button")
		cancel_button:SetParent(self.Main.Box)
		cancel_button:SetPos(Vector(5, self.Main.Box.Size.Y - 20))
		cancel_button:SetSize(Vector(26, 16))
		cancel_button:SetColor(146)
		cancel_button:SetText("Remove\nBuild")
		cancel_button:SetTextPos(Vector(1, -4))
		cancel_button:SetOutlineThickness(2)
		cancel_button:SetOutlineColor(144)
	
		cancel_button.Think = function(entity, screen)
			cancel_button:SetOutlineColor(cancel_button.IsHovered and 117 or 144)
		end
	
		cancel_button.OnPress = function(key)
			if key == Controller.PRIMARY_ACTION then
				self.Menu.Cursor_Bitmap = "Mods/CED.rte/Actors/Shared/Sprites/Menus/CancelCursor.png"
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
	end
	if self.Menu:Update(self) then
	    igui.Update(self.Menu.Player, self.Menu:GetScreen(), self.Menu.Cursor)
	    for k, gui in pairs(self.Main) do
	        gui:Update(self)
	    end
	    self.Menu:DrawCursor(self.Menu:GetScreen())
	end
end

function cursor_inside(el_pos, size)
	local el_x = el_pos.X
	local el_y = el_pos.Y

	local el_width = size.X
	local el_height = size.Y

	local mouse_x = igui.Cursor.X
	local mouse_y = igui.Cursor.Y

	return (mouse_x > el_x) and (mouse_x < el_x + el_width) and (mouse_y > el_y) and (mouse_y < el_y + el_height)
end