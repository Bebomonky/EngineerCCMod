CEDMasterList = {};

CEDMasterList.Fortifications = {};
CEDMasterList.Turrets = {};
CEDMasterList.Actors = {};
CEDMasterList.Guns = {};
CEDMasterList.Buildings = {};
CEDMasterList.Utility = {};
CEDMasterList.Technology = {};
CEDMasterList.Technology.Xarix = {};
CEDMasterList.Technology.Khrabarovsk = {};
CEDMasterList.Technology.Vossberg = {};

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
CEDMasterList.Guns.XaVidara = {["DisplayName"] = "Xarix Vidara",
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
CEDMasterList.Buildings.Coagulator = {["DisplayName"] = "     Atmo\ncoagulator",
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
	-------  XARIX  -------
CEDMasterList.Technology.Xarix.XaDoctra = {["DisplayName"] = "Xarix A Doctra",
								  ["RequiredTech"] = "None",
								  ["Description"] = [[
Xarix-brand defensive pistol. Unassuming.
Does more damage against robotic enemies.
]],
								  ["Pos"] = Vector(100, 75),
								  ["IconPath"] = "",
								  ["IconSize"] = Vector(),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};

CEDMasterList.Technology.Xarix.XaA12Axiom = {["DisplayName"] = "Xarix A-12 Axiom",
								  ["RequiredTech"] = "None",
								  ["Description"] = [[
Xarix-brand defensive pistol. Unassuming.
Does more damage against robotic enemies.
]],
								  ["Pos"] = Vector(150, 75),
								  ["IconPath"] = "",
								  ["IconSize"] = Vector(),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};

CEDMasterList.Technology.Xarix.XaMTXDirective = {["DisplayName"] = "Xarix MTX Directive",
								  ["RequiredTech"] = "None",
								  ["Description"] = [[
Xarix-brand smart plasma SMG. Merciless once locked on.
Computerized plasma shots home in on targets, and deal more damage against robots.
]],
								  ["Pos"] = Vector(200, 75),
								  ["IconPath"] = "",
								  ["IconSize"] = Vector(),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};

CEDMasterList.Technology.Xarix.XaVidara = {["DisplayName"] = "Xarix Vidara",
								  ["RequiredTech"] = "None",
								  ["Description"] = [[
Xarix-brand hybrid weapon. Multimodal lasergun.
]],
								  ["Pos"] = Vector(250, 75),
								  ["IconPath"] = "",
								  ["IconSize"] = Vector(),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};

CEDMasterList.Technology.Xarix.XaEACondor = {["DisplayName"] = "Xarix EA Condor",
								  ["RequiredTech"] = "None",
								  ["Description"] = [[
Xarix-brand charge cannon. Destructive.
]],
								  ["Pos"] = Vector(300, 75),
								  ["IconPath"] = "",
								  ["IconSize"] = Vector(),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};
	-------  KHRABAROVSK  -------
CEDMasterList.Technology.Khrabarovsk.KhSPr40 = {["DisplayName"] = "Khrabarovsk SPr-40",
								  ["RequiredTech"] = "None",
								  ["Description"] = [[
Khrabarovsk-brand revolver. Double-action.
]],
								  ["Pos"] = Vector(100, 75),
								  ["IconPath"] = "",
								  ["IconSize"] = Vector(),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};

CEDMasterList.Technology.Khrabarovsk.KhGS7 = {["DisplayName"] = "Khrabarovsk GS7",
								  ["RequiredTech"] = "None",
								  ["Description"] = [[
Khrabarovsk-brand pump shotgun.
The CQB weapon of choice since time immemorial.
]],
								  ["Pos"] = Vector(150, 75),
								  ["IconPath"] = "",
								  ["IconSize"] = Vector(),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};

CEDMasterList.Technology.Khrabarovsk.Kh11p35 = {["DisplayName"] = "Khrabarovsk 11p35-rifle",
								  ["RequiredTech"] = "None",
								  ["Description"] = [[
Khrabarovsk-brand pump shotgun.
The CQB weapon of choice since time immemorial.
]],
								  ["Pos"] = Vector(200, 75),
								  ["IconPath"] = "",
								  ["IconSize"] = Vector(),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};

CEDMasterList.Technology.Khrabarovsk.KhMOSKA = {["DisplayName"] = "Khrabarovsk MOSKA",
								  ["RequiredTech"] = "None",
								  ["Description"] = [[
Khrabarovsk-brand weapon.
A boxy little big offbore-handled bolt-action.
]],
								  ["Pos"] = Vector(250, 75),
								  ["IconPath"] = "",
								  ["IconSize"] = Vector(),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};

CEDMasterList.Technology.Khrabarovsk.KhJS50 = {["DisplayName"] = "Khrabarovsk JS50",
								  ["RequiredTech"] = "None",
								  ["Description"] = [[
Khrabarovsk-brand marksman rifle. Semi-automatic.
]],
								  ["Pos"] = Vector(300, 75),
								  ["IconPath"] = "",
								  ["IconSize"] = Vector(),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};

CEDMasterList.Technology.Khrabarovsk.KhC8Chimera = {["DisplayName"] = "Khrabarovsk C8 Chimera",
								  ["RequiredTech"] = "None",
								  ["Description"] = [[
Khrabarovsk-brand GPMG. Unmatched firepower in an unwieldy package.
For non-heavy actors, can only be used when crouching and still.
]],
								  ["Pos"] = Vector(350, 75),
								  ["IconPath"] = "",
								  ["IconSize"] = Vector(),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};
	-------  VOSSBERG  -------
CEDMasterList.Technology.Vossberg.VoHammerhead = {["DisplayName"] = "Vossberg Hammerhead",
								  ["RequiredTech"] = "None",
								  ["Description"] = [[
Vossberg-brand handcannon. High-caliber, high-octane.
]],
								  ["Pos"] = Vector(100, 75),
								  ["IconPath"] = "",
								  ["IconSize"] = Vector(),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};

CEDMasterList.Technology.Vossberg.VoAtlastar = {["DisplayName"] = "Vossberg Atlastar",
								  ["RequiredTech"] = "None",
								  ["Description"] = [[
Vossberg-brand SMG. Double-barreled with hyperburst capabilities. That's two hyperbursts at once.
]],
								  ["Pos"] = Vector(150, 75),
								  ["IconPath"] = "",
								  ["IconSize"] = Vector(),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};

CEDMasterList.Technology.Vossberg.VoTrigoliath = {["DisplayName"] = "Vossberg Trigoliath",
								  ["RequiredTech"] = "None",
								  ["Description"] = [[
Vossberg-brand triple barrel shotgun. A real hunter's weapon.
]],
								  ["Pos"] = Vector(200, 75),
								  ["IconPath"] = "",
								  ["IconSize"] = Vector(),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};

CEDMasterList.Technology.Vossberg.VoGrandarme = {["DisplayName"] = "Vossberg Grandarme",
								  ["RequiredTech"] = "None",
								  ["Description"] = [[
Vossberg-brand assault rifle. Heavy and hardcore.
]],
								  ["Pos"] = Vector(250, 75),
								  ["IconPath"] = "",
								  ["IconSize"] = Vector(),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};

CEDMasterList.Technology.Vossberg.VoTitanAMI = {["DisplayName"] = "Vossberg Titan AMI",
								  ["RequiredTech"] = "None",
								  ["Description"] = [[
Vossberg-brand materia destroyer. Huge single-shot rifle.
]],
								  ["Pos"] = Vector(300, 75),
								  ["IconPath"] = "",
								  ["IconSize"] = Vector(),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};

CEDMasterList.Technology.Vossberg.EXPTurbolance = {["DisplayName"] = "CED-EXP Turbolance",
								  ["RequiredTech"] = "None",
								  ["Description"] = [[
Experimental microgun.
Emplacement-grade firerate. Overheats rapidly - avoid overuse
]],
								  ["Pos"] = Vector(200, 200),
								  ["IconPath"] = "",
								  ["IconSize"] = Vector(),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};