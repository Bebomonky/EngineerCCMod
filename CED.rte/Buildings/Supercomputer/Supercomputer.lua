require("Mods.Extensions.ExtensionMan")

function Create(self)
	self.Menu = table.Copy(require("Mods.Extensions.imenu.core"))
	self.Menu:Initialize()

	self.MenuFunc = {}
	self.MenuFunc[1] = SupercomputerTechMenu
	self.Main = {}

	self.ConfirmSound = CreateSoundContainer("Base.rte/Confirm")
	self.ErrorSound = CreateSoundContainer("Base.rte/Error")

	self.Activity = ActivityMan:GetActivity()
	
	-- SaveLoadHandler could help with this here, but this is unique per-team so this also works Just Fine
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
	
	if not self.technologyController then
		self.technologyController = CreateMOSRotating("CED Technology Controller", "CED.rte");
		self.technologyController.Pos = self.Pos;
		self.technologyController.Team = self.Team;
		MovableMan:AddParticle(self.technologyController);
	end
end

function SupercomputerTechMenu(self)
	self.Main.Box = self.Menu:CreateGUI("CollectionBox")
	self.Main.Box:SetTitle("")
	self.Main.Box:SetPos(10, 25)
	self.Main.Box:SetSize(260, 50)
	self.Main.Box:Color(146)
	self.Main.Box:OutlineColor(71)
	self.Main.Box:OutlineThickness(2)
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
	if self.Menu:Update(self) then
	    for k, gui in pairs(self.Main) do
			gui:Update(self, {Cursor = self.Menu.Cursor})
	    end
	    self.Menu:DrawCursor(self.Menu.Screen)
	end
end

function Destroy()
	self.Menu:Remove()
end