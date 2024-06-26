require("Mods.Extensions.ExtensionMan")
local igui = require("Mods.Extensions.imenu.igui")

function Create(self)
	self.Menu = require("Mods.Extensions.imenu.core")
	self.Menu:Initialize()

	self.MenuFunc = {}
	self.MenuFunc[1] = BuilderBasic
	self.Main = {}

	self.ConfirmSound = CreateSoundContainer("Base.rte/Confirm")
	self.PieMenu:AddPieSlice(CreatePieSlice("CED.rte/BuilderMenu"), self)

	self.SelectDelayTime = Timer()

	self.Activity = ActivityMan:GetActivity()
end

function BuilderBasic(self)
	self.Main.Box = igui.CollectionBox()
	self.Main.Box:SetTitle("Title")
	self.Main.Box:SetName("Main")
	self.Main.Box:SetPos(Vector(10, 25))
	self.Main.Box:SetSize(Vector(150, 100))
	self.Main.Box:SetColor(146)
	self.Main.Box:SetOutlineColor(71)
	self.Main.Box:SetOutlineThickness(2)

	--changes mouse bitmap,
	local isRemoving = false

	--Bitmap will be modifed so we need to make sure it's always default
	self.Menu.Cursor_Bitmap = "Data/Base.rte/GUIs/Skins/Cursor.png"

	local rows = 4
	for i = 1, #self.CEDAvailableBuildables do

		local x = -5 + self.Main.Box:GetPos().X + ((i - 1) % rows + 1 - 1) * 60
		local y = 10 + (math.floor((i - 1) / rows ) + 1 - 1) * 35

		local button = igui.Button()
		button:SetName("Buildable " .. i)
		button.Buildable = self.CEDAvailableBuildables[i]
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
				if button.Buildable.SnapToGround then
					self.Menu.Cursor = SceneMan:MovePointToGround(self.Menu.Cursor, 25, 25)
				end
				PrimitiveMan:DrawBitmapPrimitive(screen, self.Menu.Cursor, button.Buildable.IconPath, 0)

				if self.SelectDelayTime:IsPastSimMS(200) then
					if self.Menu.Controller and self.Menu.Controller:IsState(Controller.PRIMARY_ACTION) then
						local createFunc = "Create" .. button.Buildable.BuildableClassName
						local buildablePreset = _G[createFunc](button.Buildable.BuildablePresetName, button.Buildable.BuildableTechName);
						buildablePreset.Team = entity.Team
						buildablePreset.Pos = self.Menu.Cursor
						MovableMan:AddParticle(buildablePreset)
						self.Activity:SetTeamFunds(self.Activity:GetTeamFunds(entity.Team) - button.Buildable.Cost, entity.Team)
						self.ConfirmSound:Play(-1)
						self.SelectDelayTime:Reset()
						button.Buildable.Selected = false
						print("Just placed the following: " .. button.Buildable.DisplayName);
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
				isRemoving = false
				self.Menu.Cursor_Bitmap = "Data/Base.rte/GUIs/Skins/Cursor.png"
				button.Buildable.Selected = true
			end
		end
	end

	local cancelButton = igui.Button()
	cancelButton:SetName("Delete_Buildable")
	cancelButton:SetParent(self.Main.Box)
	cancelButton:SetPos(Vector(5, self.Main.Box.Size.Y - 20))
	cancelButton:SetSize(Vector(26, 16))
	cancelButton:SetColor(146)
	cancelButton:SetText("Remove\nBuild")
	cancelButton:SetTextPos(Vector(1, -4))
	cancelButton:SetOutlineThickness(2)
	cancelButton:SetOutlineColor(144)

	cancelButton.Think = function(entity, screen)
		cancelButton:SetOutlineColor(cancelButton.IsHovered and 117 or 144)
	end

	cancelButton.OnPress = function(key)
		if key == Controller.PRIMARY_ACTION then
			self.Menu.Cursor_Bitmap = "Mods/CED.rte/Actors/Shared/Sprites/Menus/CancelCursor.png"
			isRemoving = true
		end
	end
end

function Update(self)
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