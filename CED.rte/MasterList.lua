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
								  ["InfoBoxDescription"] = [[
Blank
]],
								  ["Action"] = "\tSEMI\nAUTOMATIC",
								  ["RPM"] = "SEMI",
								  ["MAG"] = "12",
								  ["Pos"] = Vector(100, 75),
								  ["IconPath"] = "CED.rte/Devices/Weapons/Handheld/XaDoctra/Icon.png",
								  ["IconSize"] = Vector(15, 8),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};

CEDMasterList.Technology.Xarix.XaA12Axiom = {["DisplayName"] = "Xarix A-12 Axiom",
								  ["RequiredTech"] = "None",
								  ["Description"] = [[
Xarix-brand defensive pistol. Unassuming.
Does more damage against robotic enemies.
]],
["InfoBoxDescription"] = [[
Blank
]],
								  ["Action"] = "\tDOUBLE\nACTION",
								  ["RPM"] = "SEMI",
								  ["MAG"] = "5",
								  ["Pos"] = Vector(150, 75),
								  ["IconPath"] = "CED.rte/Devices/Weapons/Handheld/XaA12Axiom/Icon.png",
								  ["IconSize"] = Vector(23, 12),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};

CEDMasterList.Technology.Xarix.XaMTXDirective = {["DisplayName"] = "Xarix MTX Directive",
								  ["RequiredTech"] = "None",
								  ["Description"] = [[
Xarix-brand smart plasma SMG. Merciless once locked on.
Computerized plasma shots home in on targets, and deal more damage against robots.
]],
["InfoBoxDescription"] = [[
Blank
]],
								  ["Action"] = "\tFULLY\nAUTOMATIC",
								  ["RPM"] = "800",
								  ["MAG"] = "30+1",
								  ["Pos"] = Vector(200, 75),
								  ["IconPath"] = "CED.rte/Devices/Weapons/Handheld/XaMTXDirective/Icon.png",
								  ["IconSize"] = Vector(17, 10),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};

CEDMasterList.Technology.Xarix.XaVidara = {["DisplayName"] = "Xarix Vidara",
								  ["RequiredTech"] = "None",
								  ["Description"] = [[
Xarix-brand hybrid weapon. Multimodal lasergun.
]],
["InfoBoxDescription"] = [[
Blank
]],
								  ["Action"] = "ELECTRIC",
								  ["RPM"] = "150-400",
								  ["MAG"] = "24",
								  ["Pos"] = Vector(250, 75),
								  ["IconPath"] = "CED.rte/Devices/Weapons/Handheld/XaVidara/Icon.png",
								  ["IconSize"] = Vector(25, 10),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};

CEDMasterList.Technology.Xarix.XaEACondor = {["DisplayName"] = "Xarix EA Condor",
								  ["RequiredTech"] = "None",
								  ["Description"] = [[
Xarix-brand charge cannon. Destructive.
]],
["InfoBoxDescription"] = [[
Blank
]],
								  ["Action"] = "CHARGE",
								  ["RPM"] = "SEMI",
								  ["MAG"] = "1",
								  ["Pos"] = Vector(300, 75),
								  ["IconPath"] = "CED.rte/Devices/Weapons/Handheld/XaEACondor/Icon.png",
								  ["IconSize"] = Vector(34, 13),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};
	-------  KHRABAROVSK  -------
CEDMasterList.Technology.Khrabarovsk.KhSPr40 = {["DisplayName"] = "Khrabarovsk SPr-40",
								  ["RequiredTech"] = "None",
								  ["Description"] = [[
Khrabarovsk-brand revolver. Double-action.
]],
["InfoBoxDescription"] = [[
Blank
]],
								  ["Action"] = "\tDOUBLE\nACTION",
								  ["RPM"] = "SEMI",
								  ["MAG"] = "8",
								  ["Pos"] = Vector(100, 75),
								  ["IconPath"] = "CED.rte/Devices/Weapons/Handheld/KhSPr40/Icon.png",
								  ["IconSize"] = Vector(14, 10),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};

CEDMasterList.Technology.Khrabarovsk.KhGS7 = {["DisplayName"] = "Khrabarovsk GS7",
								  ["RequiredTech"] = "None",
								  ["Description"] = [[
Khrabarovsk-brand pump shotgun.
The CQB weapon of choice since time immemorial.
]],
["InfoBoxDescription"] = [[
Blank
]],
								  ["Action"] = "\tPUMP\nACTION",
								  ["RPM"] = "SEMI",
								  ["MAG"] = "4+1",
								  ["Pos"] = Vector(150, 75),
								  ["IconPath"] = "CED.rte/Devices/Weapons/Handheld/KhGS7/Icon.png",
								  ["IconSize"] = Vector(28, 10),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};

CEDMasterList.Technology.Khrabarovsk.Kh11p35 = {["DisplayName"] = "Khrabarovsk 11p35-rifle",
								  ["RequiredTech"] = "None",
								  ["Description"] = [[
Khrabarovsk-brand assault rifle. Versatile.
]],
["InfoBoxDescription"] = [[
Blank
]],
								  ["Action"] = "\tSELECT\nFIRE",
								  ["RPM"] = "600",
								  ["MAG"] = "30+1",
								  ["Pos"] = Vector(200, 75),
								  ["IconPath"] = "CED.rte/Devices/Weapons/Handheld/Kh11p35/Icon.png",
								  ["IconSize"] = Vector(28, 12),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};

CEDMasterList.Technology.Khrabarovsk.KhMOSKA = {["DisplayName"] = "Khrabarovsk MOSKA",
								  ["RequiredTech"] = "None",
								  ["Description"] = [[
Khrabarovsk-brand weapon.
A boxy little big offbore-handled bolt-action.
]],
["InfoBoxDescription"] = [[
Blank
]],
								  ["Action"] = "\tBOLT\nACTION",
								  ["RPM"] = "SEMI",
								  ["MAG"] = "4+1",
								  ["Pos"] = Vector(250, 75),
								  ["IconPath"] = "CED.rte/Devices/Weapons/Handheld/KhMOSKA/Icon.png",
								  ["IconSize"] = Vector(32, 10),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};

CEDMasterList.Technology.Khrabarovsk.KhJS50 = {["DisplayName"] = "Khrabarovsk JS50",
								  ["RequiredTech"] = "None",
								  ["Description"] = [[
Khrabarovsk-brand marksman rifle. Semi-automatic.
]],
["InfoBoxDescription"] = [[
Blank
]],
								  ["Action"] = "\tSEMI\nAUTOMATIC",
								  ["RPM"] = "SEMI",
								  ["MAG"] = "7+1",
								  ["Pos"] = Vector(300, 75),
								  ["IconPath"] = "CED.rte/Devices/Weapons/Handheld/KhJS50/Icon.png",
								  ["IconSize"] = Vector(34, 12),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};

CEDMasterList.Technology.Khrabarovsk.KhC8Chimera = {["DisplayName"] = "Khrabarovsk C8 Chimera",
								  ["RequiredTech"] = "None",
								  ["Description"] = [[
Khrabarovsk-brand GPMG. Unmatched firepower in an unwieldy package.
For non-heavy actors, can only be used when crouching and still.
]],
["InfoBoxDescription"] = [[
Blank
]],
								  ["Action"] = "\tFULLY\nAUTOMATIC",
								  ["RPM"] = "550",
								  ["MAG"] = "80",
								  ["Pos"] = Vector(350, 75),
								  ["IconPath"] = "CED.rte/Devices/Weapons/Handheld/KhC8Chimera/Icon.png",
								  ["IconSize"] = Vector(43, 13),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};
	-------  VOSSBERG  -------
CEDMasterList.Technology.Vossberg.VoHammerhead = {["DisplayName"] = "Vossberg Hammerhead",
								  ["RequiredTech"] = "None",
								  ["Description"] = [[
Vossberg-brand handcannon. High-caliber, high-octane.
]],
["InfoBoxDescription"] = [[
Blank
]],
								  ["Action"] = "\tSEMI\nAUTOMATIC",
								  ["RPM"] = "SEMI",
								  ["MAG"] = "7+1",
								  ["Pos"] = Vector(100, 75),
								  ["IconPath"] = "CED.rte/Devices/Weapons/Handheld/VoHammerhead/Icon.png",
								  ["IconSize"] = Vector(18, 10),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};

CEDMasterList.Technology.Vossberg.VoAtlastar = {["DisplayName"] = "Vossberg Atlastar",
								  ["RequiredTech"] = "None",
								  ["Description"] = [[
Vossberg-brand SMG. Double-barreled with hyperburst capabilities. That's two hyperbursts at once.
]],
["InfoBoxDescription"] = [[
Blank
]],
								  ["Action"] = "\tFULLY\nAUTOMATIC",
								  ["RPM"] = "800-3600",
								  ["MAG"] = "20",
								  ["Pos"] = Vector(150, 75),
								  ["IconPath"] = "CED.rte/Devices/Weapons/Handheld/VoAtlastar/Icon.png",
								  ["IconSize"] = Vector(22, 10),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};

CEDMasterList.Technology.Vossberg.VoTrigoliath = {["DisplayName"] = "Vossberg Trigoliath",
								  ["RequiredTech"] = "None",
								  ["Description"] = [[
Vossberg-brand triple barrel shotgun. A real hunter's weapon.
]],
["InfoBoxDescription"] = [[
Blank
]],
								  ["Action"] = "\tBREAK\nACTION",
								  ["RPM"] = "SEMI",
								  ["MAG"] = "3",
								  ["Pos"] = Vector(200, 75),
								  ["IconPath"] = "CED.rte/Devices/Weapons/Handheld/VoTrigoliath/Icon.png",
								  ["IconSize"] = Vector(36, 11),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};

CEDMasterList.Technology.Vossberg.VoGrandarme = {["DisplayName"] = "Vossberg Grandarme",
								  ["RequiredTech"] = "None",
								  ["Description"] = [[
Vossberg-brand assault rifle. Heavy and hardcore.
]],
["InfoBoxDescription"] = [[
Blank
]],
								  ["Action"] = "\tFULLY\nAUTOMATIC",
								  ["RPM"] = "250-490",
								  ["MAG"] = "30+1",
								  ["Pos"] = Vector(250, 75),
								  ["IconPath"] = "CED.rte/Devices/Weapons/Handheld/VoGrandarme/Icon.png",
								  ["IconSize"] = Vector(35, 16),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};

CEDMasterList.Technology.Vossberg.VoTitanAMI = {["DisplayName"] = "Vossberg Titan AMI",
								  ["RequiredTech"] = "None",
								  ["Description"] = [[
Vossberg-brand materia destroyer. Huge single-shot rifle.
]],
["InfoBoxDescription"] = [[
Blank
]],
								  ["Action"] = "\tBREECH\nLOADING",
								  ["RPM"] = "SEMI",
								  ["MAG"] = "1",
								  ["Pos"] = Vector(300, 75),
								  ["IconPath"] = "CED.rte/Devices/Weapons/Handheld/VoTitanAMI/Icon.png",
								  ["IconSize"] = Vector(39, 11),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};

CEDMasterList.Technology.Vossberg.EXPTurbolance = {["DisplayName"] = "CED-EXP Turbolance",
								  ["RequiredTech"] = "None",
								  ["Description"] = [[
Experimental microgun.
Emplacement-grade firerate. Overheats rapidly - avoid overuse.
]],
["InfoBoxDescription"] = [[
Blank
]],
								  ["Action"] = "ELECTRIC",
								  ["RPM"] = "3600",
								  ["MAG"] = "200",
								  ["Pos"] = Vector(200, 200),
								  ["IconPath"] = "CED.rte/Devices/Weapons/Handheld/EXPTurbolance/Icon.png",
								  ["IconSize"] = Vector(37, 16),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};