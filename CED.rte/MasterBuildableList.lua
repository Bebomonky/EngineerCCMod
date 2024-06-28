CEDMasterBuildableList = {};

CEDMasterBuildableList.Fortifications = {};
CEDMasterBuildableList.Turrets = {};
CEDMasterBuildableList.Buildings = {};
CEDMasterBuildableList.Utility = {};

-------  FORTIFICATIONS  -------
CEDMasterBuildableList.Fortifications.CEDLogo = {["DisplayName"] = "CED Logo",
								  ["IconPath"] = "Coalition.rte/Actors/Mecha/GatlingDrone/Icon.png",
								  ["IconPos"] = Vector(0, -5),
								  ["RenderPath"] = "CED.rte/Buildables/GenericTerrainBuildable/GenericTerrainBuildable.png",
								  ["RenderSize"] = Box(Vector(-40, -20), Vector(40, 20)),
								  ["BuildablePresetName"] = "CED Generic Terrain Buildable",
								  ["BuildableClassName"] = "MOSRotating",
								  ["BuildableTechName"] = "CED",
								  ["MaxAltitude"] = 25,
								  ["Cost"] = 50,
								  ["SnapToGround"] = false};

-------  TURRETS  -------
CEDMasterBuildableList.Turrets.PlinkTurret = {["DisplayName"] = "Plink Turret",
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


-------  BUILDINGS  -------
CEDMasterBuildableList.Buildings.AtmoCoagulator = {["DisplayName"] = "Atmo-coagulator",
								  ["IconPath"] = "Coalition.rte/Actors/Mecha/GatlingDrone/Icon.png",
								  ["IconPos"] = Vector(0, -5),
								  ["RenderPath"] = "CED.rte/Buildings/Coagulator/Coagulator.png",
								  ["RenderSize"] = Box(Vector(-50, -50), Vector(50, 50)),
								  ["BuildablePresetName"] = "CED Atmospheric Coagulator Buildable",
								  ["BuildableClassName"] = "MOSRotating",
								  ["BuildableTechName"] = "CED",
								  ["MaxAltitude"] = 57,
								  ["Cost"] = 100,
								  ["SnapToGround"] = true};	

-------  UTILITY  -------
