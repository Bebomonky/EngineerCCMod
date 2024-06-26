function Create(self)
	self.CEDBuildRange = 200;
	self.CEDBuildRate = 10;
	self.CEDBuildDelay = 1000;
	
	self.CEDBuildTimer = Timer();

	self.CEDAvailableBuildables = {};
	local i = 1;
	self.CEDAvailableBuildables[i] = {["DisplayName"] = "Plink Turret",
									  ["IconPath"] = "Coalition.rte/Actors/Mecha/GatlingDrone/Icon.png",
									  ["IconPos"] = Vector(0, -5),
									  ["RenderPath"] = "CED.rte/Buildables/GenericBuildable/GenericBuildable.png",
									  ["RenderSize"] = Box(Vector(-40, -20), Vector(40, 20)),
									  ["BuildablePresetName"] = "CED Plink Turret Buildable",
									  ["BuildableClassName"] = "MOSRotating",
									  ["BuildableTechName"] = "CED",
									  ["Cost"] = 50,
									  ["SnapToGround"] = true};
	i = i + 1;
	self.CEDAvailableBuildables[i] = {["DisplayName"] = "Plink Turret 2\nTest",
									  ["IconPath"] = "Coalition.rte/Actors/Mecha/GatlingDrone/Icon.png",
									  ["IconPos"] = Vector(0, -5),
									  ["RenderPath"] = "CED.rte/Buildables/GenericBuildable/GenericBuildable.png",
									  ["RenderSize"] = Box(Vector(-40, -20), Vector(40, 20)),
									  ["BuildablePresetName"] = "CED Plink Turret Buildable",
									  ["BuildableClassName"] = "MOSRotating",
									  ["BuildableTechName"] = "CED",
									  ["Cost"] = 50,
									  ["SnapToGround"] = true};
	i = i + 1;
	self.CEDAvailableBuildables[i] = {["DisplayName"] = "Plink Turret 3\nTest",
									  ["IconPath"] = "Coalition.rte/Actors/Mecha/GatlingDrone/Icon.png",
									  ["IconPos"] = Vector(0, -5),
									  ["RenderPath"] = "CED.rte/Buildables/GenericBuildable/GenericBuildable.png",
									  ["RenderSize"] = Box(Vector(-40, -20), Vector(40, 20)),
									  ["BuildablePresetName"] = "CED Plink Turret Buildable",
									  ["BuildableClassName"] = "MOSRotating",
									  ["BuildableTechName"] = "CED",
									  ["Cost"] = 50,
									  ["SnapToGround"] = true};
	i = i + 1;
end