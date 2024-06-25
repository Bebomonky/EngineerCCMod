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
		local buildable = self.CEDAvailableBuildables[i]
		buildable.Selected = false

		local x = -5 + self.Main.Box:GetPos().X + ((i - 1) % rows + 1 - 1) * 60
		local y = 7 + (math.floor((i - 1) / rows ) + 1 - 1) * 35

		local button = igui.Button()
		button:SetName("Buildable " .. i)
		button:SetParent(self.Main.Box)
		button:SetPos(Vector(x, y))
		button:SetSize(Vector(49, 26))
		button:SetColor(146)
		button:SetText(buildable.DisplayName)
		button:SetTextPos(Vector(0, 10))
		button:SetOutlineThickness(2)
		button:SetOutlineColor(144)

		button.Think = function(entity, screen)
			button:SetOutlineColor(button.IsHovered and 117 or 144)
			local world_pos = button.Parent.Pos + button:GetPos() + CameraMan:GetOffset(screen)
			PrimitiveMan:DrawBitmapPrimitive(screen, world_pos + Vector(15, 13), buildable.IconPath, 0)
	
			if buildable.Selected then
				PrimitiveMan:DrawBitmapPrimitive(screen, self.Menu.Cursor, buildable.IconPath, 0)
				if self.SelectDelayTime:IsPastSimMS(200) then
					if self.Menu.Controller and self.Menu.Controller:IsState(Controller.PRIMARY_ACTION) then
						local buildable = CreateMOSRotating("CED.rte/CED Generic Buildable")
						buildable.Team = entity.Team
						buildable.Pos = self.Menu.Cursor
						MovableMan:AddParticle(buildable)
						self.SelectDelayTime:Reset()
						buildable.Selected = false
					end
				end
			end
		end
	
		button.OnPress = function(key)
			if key == Controller.PRIMARY_ACTION then
				self.SelectDelayTime:Reset()
				buildable.Selected = true
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