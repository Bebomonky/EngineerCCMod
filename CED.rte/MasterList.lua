CEDMasterList = {};

CEDMasterList.Fortifications = {};
CEDMasterList.Turrets = {};
CEDMasterList.Actors = {};
CEDMasterList.Guns = {};
CEDMasterList.Buildings = {};
CEDMasterList.Utility = {};
CEDMasterList.Technology = {};

-------  FORTIFICATIONS  -------
CEDMasterList.Fortifications.CEDLogo = {["DisplayName"] = "CED Logo",
								  ["Description"] = [[
Builds the CED Logo
What it does: Yes
Yay!]],
								  ["TooltipSize"] = Vector(150, 75),
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
CEDMasterList.Turrets.PlinkTurret = {["DisplayName"] = "  Plink\nTurret",
								  ["ResearchName"] = "Defensive Combat",
								  ["Description"] = [[
Builds the Plink Turret
What it does: Yes
Yay!]],
								  ["TooltipSize"] = Vector(150, 75),
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

-------  ACTORS  -------
CEDMasterList.Actors.Behemoth = {["DisplayName"] = "Behemoth",
								  ["Description"] = [[
Consumes Combat Engineer and
transforms into a behemoth!
Requirement: 1 Combat Engineer
Yay!]],
								  ["TooltipSize"] = Vector(150, 75),
								  ["IconPath"] = "CED.rte/Actors/Infantry/Behemoth/Helmet.png",
								  ["IconPos"] = Vector(0, -5),
								  ["EntityPresetName"] = "CED.rte/Behemoth",
								  ["EntityClassName"] = "AHuman",
								  ["EntityTechName"] = "CED",
								  ["QueueTime"] = 20000,
								  ["Cost"] = 100};
-------  GUNS  -------
CEDMasterList.Guns.XarixVidara = {["DisplayName"] = "Xarix Vidara",
								  ["Description"] = [[
Creates a gun
and pops out the machine!
Yay!]],
								  ["TooltipSize"] = Vector(150, 75),
								  ["IconPath"] = "CED.rte/Devices/Weapons/Handheld/XaVidara/XaVidaraBuyIcon.png",
								  ["IconPos"] = Vector(0, -5),
								  ["EntityPresetName"] = "CED.rte/Xarix Vidara",
								  ["EntityClassName"] = "HDFirearm",
								  ["EntityTechName"] = "CED",
								  ["QueueTime"] = 10000,
								  ["Cost"] = 200};


-------  BUILDINGS  -------
CEDMasterList.Buildings.AtmoCoagulator = {["DisplayName"] = "     Atmo\ncoagulator",
								  ["ResearchName"] = "Economics",
								  ["Description"] = [[
Builds the Atmo-coagulator
What it does: Yes
Yay!]],
								  ["TooltipSize"] = Vector(150, 75),
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
								  
CEDMasterList.Buildings.Supercomputer = {["DisplayName"] = "   Super\ncomputer",
								  ["Description"] = [[
Builds the Supercomputer
What it does: Yes
Yay!]],
								  ["TooltipSize"] = Vector(150, 75),
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

CEDMasterList.Buildings.XarixNanofab = {["DisplayName"] = "   Xarix\nNanofab",
								  ["ResearchName"] = "Xarix Start 1",
								  ["Description"] = [[
Builds the Xarix-Nanofab
What it does: Yes
Yay!]],
								  ["TooltipSize"] = Vector(150, 75),
								  ["IconPath"] = "Coalition.rte/Actors/Mecha/GatlingDrone/Icon.png",
								  ["IconPos"] = Vector(0, -5),
								  ["RenderPath"] = "CED.rte/Buildings/XarixNanofab/XarixNanofab.png",
								  ["RenderSize"] = Box(Vector(-50, -50), Vector(50, 50)),
								  ["BuildablePresetName"] = "CED Xarix Nanofab Buildable",
								  ["BuildableClassName"] = "MOSRotating",
								  ["BuildableTechName"] = "CED",
								  ["MaxAltitude"] = 57,
								  ["Cost"] = 250,
								  ["SnapToGround"] = true};

-------  UTILITY  -------

-------  TECHNOLOGY  -------
CEDMasterList.Technology.PlinkTurret = {["DisplayName"] = "Research\nPlink Turret",
								  ["ResearchName"] = "Defensive Combat",
								  ["Description"] = [[
Researches the Plink Turret
What it does: Researches
Yay!]],
								  ["Delay"] = 1000,
								  ["TooltipSize"] = Vector(150, 75),
								  ["Cost"] = 1000,
}

CEDMasterList.Technology.Atmo_coagulator = {["DisplayName"] = "Research\nAtmo-coagulator",
								  ["ResearchName"] = "Economics",
								  ["Description"] = [[
Researches the
Atmo-coagulator
What it does: Researches
Yay!]],
								  ["Delay"] = 1000,
								  ["TooltipSize"] = Vector(150, 75),
								  ["Cost"] = 500,
}

CEDMasterList.Technology.XarixNanofab = {["DisplayName"] = "Research\nXarix-Nanofab",
								  ["ResearchName"] = "Xarix Start 1",
								  ["Description"] = [[
Researches the
Xarix-Nanofab
What it does: Researches
Yay!]],
								  ["Delay"] = 1000,
								  ["TooltipSize"] = Vector(150, 75),
								  ["Cost"] = 500,
}