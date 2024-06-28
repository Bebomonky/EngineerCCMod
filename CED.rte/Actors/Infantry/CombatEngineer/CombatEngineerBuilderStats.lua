function Create(self)
	self.CEDBuildRange = 150;
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
									  ["MaxAltitude"] = 25,
									  ["Cost"] = 50,
									  ["SnapToGround"] = true};
	i = i + 1;
	
	
	-------  BUILDINGS  -------
	
	-------  UTILITY  -------
end