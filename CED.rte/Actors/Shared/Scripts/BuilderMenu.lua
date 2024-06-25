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

	self.SelectedObject = false
	self.SelectDelayTime = Timer()

	self.Icons = {
		Drone = "Coalition.rte/Actors/Mecha/GatlingDrone/Icon.png"
	}
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

	local button = igui.Button()
	button:SetName("Gatling_Turret")
	button:SetParent(self.Main.Box)
	button:SetPos(Vector(10, 15))
	button:SetSize(Vector(28, 26))
	button:SetColor(146)
	button:SetOutlineThickness(2)
	button:SetOutlineColor(144)

	button.Think = function(entity, screen)
		button:SetOutlineColor(button.IsHovered and 117 or 144)
		local world_pos = button.Parent.Pos + button:GetPos() + CameraMan:GetOffset(screen)
		PrimitiveMan:DrawBitmapPrimitive(screen, world_pos + Vector(15, 13), self.Icons.Drone, 0)

		if self.SelectedObject then
			self.Mouse = Vector(self.Mouse.X + UInputMan:GetMouseMovement(entity.Team).X, SceneMan.SceneHeight * -1)
			entity.ViewPoint = SceneMan:MovePointToGround(self.Mouse, 50, 25)

			PrimitiveMan:DrawBitmapPrimitive(screen, self.Menu.Cursor, self.Icons.Drone, 0)
			if self.SelectDelayTime:IsPastSimMS(200) then
				if self.Menu.Controller:IsState(Controller.PRIMARY_ACTION) then
					local buildable = CreateMOSRotating("CED.rte/CED Generic Buildable")
					buildable.Team = entity.Team
					buildable.Pos = self.Menu.Cursor
					MovableMan:AddParticle(buildable)
					self.SelectDelayTime:Reset()
					self.SelectedObject = false
				end
			end
		end
	end

	button.OnPress = function(key)
		if key == Controller.PRIMARY_ACTION then
			self.SelectDelayTime:Reset()
			self.Mouse = self.ViewPoint
			self.SelectedObject = true
		end
	end

	local cancelButton = igui.Button()
	cancelButton:SetName("CancelButton")
	cancelButton:SetParent(self.Main.Box)
	cancelButton:SetPos(Vector(50, 15))
	cancelButton:SetSize(Vector(26, 26))
	cancelButton:SetColor(146)
	cancelButton:SetOutlineThickness(2)
	cancelButton:SetOutlineColor(144)

	cancelButton.Think = function(entity, screen)
		cancelButton:SetOutlineColor(cancelButton.IsHovered and 117 or 144)
	end

	cancelButton.OnPress = function(key)
		if key == Controller.PRIMARY_ACTION then
			print("bbbbb")
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