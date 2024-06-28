require("Mods.Extensions.ExtensionMan")
local igui = require("Mods.Extensions.imenu.igui")

function Create(self)
	self.Menu = require("Mods.Extensions.imenu.core")
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
	self.Main.Box = igui.CollectionBox()
	self.Main.Box:SetTitle("")
	self.Main.Box:SetName("Main")
	self.Main.Box:SetPos(Vector(10, 25))
	self.Main.Box:SetSize(Vector(260, 100))
	self.Main.Box:SetColor(146)
	self.Main.Box:SetOutlineColor(71)
	self.Main.Box:SetOutlineThickness(2)
end

function ThreadedUpdate(self)
	if self:IsPlayerControlled() then
		if not self.menuOpen then
			self.Main = {};
			self.Menu:New(self, self.MenuFunc[1]);
			self.menuOpen = true;
		end
	else
		self.menuOpen = false;
	end
	if self.Menu:Update(self) then
	    igui.Update(self.Menu.Player, self.Menu:GetScreen(), self.Menu.Cursor);
	    for k, gui in pairs(self.Main) do
	        gui:Update(self);
	    end
	    self.Menu:DrawCursor(self.Menu:GetScreen());
	end
end