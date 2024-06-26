function Create(self)
	self.CEDBuildRange = 200;
	self.CEDBuildRate = 10;
	self.CEDBuildDelay = 1000;
	
	self.CEDBuildTimer = Timer();

	self.CEDAvailableBuildables = {};
	self.CEDAvailableBuildables.Fortifications = {};
	self.CEDAvailableBuildables.Turrets = {};
	self.CEDAvailableBuildables.Buildings = {};
	self.CEDAvailableBuildables.Utility = {};
	-------  FORTIFICATIONS  -------
	
	
	-------  TURRETS  -------
	local i = 1;
	self.CEDAvailableBuildables.Turrets[i] = {["DisplayName"] = "Plink Turret",
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
	
	
	-------  BUILDINGS  -------
	local i = 1;
	self.CEDAvailableBuildables.Buildings[i] = {["DisplayName"] = "Atmo-coagulator",
									  ["IconPath"] = "Coalition.rte/Actors/Mecha/GatlingDrone/Icon.png",
									  ["IconPos"] = Vector(0, -5),
									  ["RenderPath"] = "CED.rte/Buildings/Coagulator/Coagulator.png",
									  ["RenderSize"] = Box(Vector(-50, -50), Vector(50, 50)),
									  ["BuildablePresetName"] = "CED Atmospheric Coagulator Buildable",
									  ["BuildableClassName"] = "MOSRotating",
									  ["BuildableTechName"] = "CED",
									  ["Cost"] = 100,
									  ["SnapToGround"] = true};	
	i = i + 1;
	
	-------  UTILITY  -------
end