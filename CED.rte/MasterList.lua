CEDMasterList = {};

CEDMasterList.Fortifications = {};
CEDMasterList.Turrets = {};
CEDMasterList.Buildings = {};
CEDMasterList.Utility = {};
CEDMasterList.Technology = {};

-------  FORTIFICATIONS  -------
CEDMasterList.Fortifications.CEDLogo = {["DisplayName"] = "CED Logo",
								  ["Description"] = [[
Desc: Builds the CED Logo
What it does: Yes
Yay!]],
								  ["TooltipSize"] = Vector(100, 75),
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
CEDMasterList.Turrets.PlinkTurret = {["DisplayName"] = "Plink Turret",
								  ["Description"] = [[
Desc: Builds the Plink Turret
What it does: Yes
Yay!]],
								  ["TooltipSize"] = Vector(100, 75),
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
CEDMasterList.Buildings.AtmoCoagulator = {["DisplayName"] = "Atmo-coagulator",
								  ["Description"] = [[
Desc: Builds the Atmo-coagulator
What it does: Yes
Yay!]],
								  ["TooltipSize"] = Vector(130, 75),
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
								  
CEDMasterList.Buildings.Supercomputer = {["DisplayName"] = "Supercomputer",
								  ["Description"] = [[
Desc: Builds the Supercomputer
What it does: Yes
Yay!]],
								  ["TooltipSize"] = Vector(130, 75),
								  ["IconPath"] = "Coalition.rte/Actors/Mecha/GatlingDrone/Icon.png",
								  ["IconPos"] = Vector(0, -5),
								  ["RenderPath"] = "CED.rte/Buildings/Supercomputer/Supercomputer.png",
								  ["RenderSize"] = Box(Vector(-50, -50), Vector(50, 50)),
								  ["BuildablePresetName"] = "CED Supercomputer Buildable",
								  ["BuildableClassName"] = "MOSRotating",
								  ["BuildableTechName"] = "CED",
								  ["MaxAltitude"] = 57,
								  ["Cost"] = 500,
								  ["SnapToGround"] = true};	

-------  UTILITY  -------

-------  TECHNOLOGY  -------
CEDMasterList.Technology.PlinkTurret = {["DisplayName"] = "Research\nPlink Turret",
								  ["ResearchName"] = "Plink_Turret",
								  ["Description"] = [[
Desc: Researches the Plink Turret
What it does: Researches
Yay!]],
								  ["Delay"] = 1000,
								  ["TooltipSize"] = Vector(130, 75),
								  ["Cost"] = 1000,
}

CEDMasterList.Technology.Atmo_coagulator = {["DisplayName"] = "Research\nAtmo-coagulator",
								  ["ResearchName"] = "Atmo_coagulator",
								  ["Description"] = [[
Desc: Researches the
Atmo-coagulator
What it does: Researches
Yay!]],
								  ["Delay"] = 1000,
								  ["TooltipSize"] = Vector(130, 75),
								  ["Cost"] = 500,
}