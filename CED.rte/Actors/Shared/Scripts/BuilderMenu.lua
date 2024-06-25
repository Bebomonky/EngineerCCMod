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

	local rows = 4
	for i = 1, #self.CEDAvailableBuildables do

		local x = -5 + self.Main.Box:GetPos().X + ((i - 1) % rows + 1 - 1) * 60
		local y = 7 + (math.floor((i - 1) / rows ) + 1 - 1) * 35

		local button = igui.Button()
		button:SetName("Buildable " .. i)
		button.Buildable = self.CEDAvailableBuildables[i]
		button.Buildable.Selected = false
		button:SetParent(self.Main.Box)
		button:SetPos(Vector(x, y))
		button:SetSize(Vector(49, 26))
		button:SetColor(146)
		button:SetText(button.Buildable.DisplayName)
		button:SetTextPos(Vector(0, 10))
		button:SetOutlineThickness(2)
		button:SetOutlineColor(144)

		button.Think = function(entity, screen)
			button:SetOutlineColor(button.IsHovered and 117 or 144)
			local world_pos = button.Parent.Pos + button:GetPos() + CameraMan:GetOffset(screen)
			local parent_world_pos = button.Parent.Pos + CameraMan:GetOffset(screen)
			PrimitiveMan:DrawBitmapPrimitive(screen, world_pos + Vector(15, 13), button.Buildable.IconPath, 0)

			if not cursor_inside(parent_world_pos, button.Parent.Size) and button.Buildable.Selected then
				PrimitiveMan:DrawBitmapPrimitive(screen, self.Menu.Cursor, button.Buildable.IconPath, 0)
				if self.SelectDelayTime:IsPastSimMS(200) then
					if self.Menu.Controller and self.Menu.Controller:IsState(Controller.PRIMARY_ACTION) then
						local createFunc = "Create" .. button.Buildable.BuildableClassName
						local buildablePreset = _G[createFunc](button.Buildable.BuildablePresetName, button.Buildable.BuildableTechName);
						buildablePreset.Team = entity.Team
						buildablePreset.Pos = self.Menu.Cursor
						MovableMan:AddParticle(buildablePreset)
						self.SelectDelayTime:Reset()
						button.Buildable.Selected = false
						print("Just placed the following: " .. button.Buildable.DisplayName);
					end
				end
			end
		end
	
		button.OnPress = function(key)
			if key == Controller.PRIMARY_ACTION then
				self.SelectDelayTime:Reset()
				button.Buildable.Selected = true
			end
		end
	end

	local pbar = igui.ProgressBar()
	pbar:SetName("MyFirstProgressBar")
	pbar:SetParent(self.Main.Box)
	pbar:SetPos(Vector(13, 70))
	pbar:SetSize(Vector(100, 10))
	pbar:SetBGColor(146)
	pbar:SetFGColor(117)
	pbar:SetOutlineColor(144)
	pbar:SetDrawAfterParent(true)
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