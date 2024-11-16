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
								  ["ItemID"] = "CEDLogo",
								  ["Type"] = "Building",
								  ["Description"] = [[
Builds the CED Logo
What it does: Yes
Yay!]],
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
								  ["ItemID"] = "PlinkTurret",
								  ["Type"] = "Actor",
								  ["Description"] = [[
Builds the Plink Turret
What it does: Yes
Yay!]],
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
								  ["ItemID"] = "Behemoth",
								  ["Type"] = "Actor",
								  ["Description"] = [[
Consumes Combat Engineer and
transforms into a behemoth!
Requirement: 1 Combat Engineer
Yay!]],
								  ["IconPath"] = "CED.rte/Actors/Infantry/Behemoth/Helmet.png",
								  ["IconPos"] = Vector(0, -5),
								  ["EntityPresetName"] = "CED.rte/Behemoth",
								  ["EntityClassName"] = "AHuman",
								  ["EntityTechName"] = "CED",
								  ["QueueTime"] = 20000,
								  ["Cost"] = 100};
-------  GUNS  -------
CEDMasterList.Guns.XaVidara = {["DisplayName"] = "Xarix Vidara",
								  ["ItemID"] = "XaVidara",
								  ["Type"] = "Device",
								  ["Description"] = [[
Creates a gun
and pops out the machine!
Yay!]],
								  ["IconPath"] = "CED.rte/Devices/Weapons/Handheld/XaVidara/XaVidaraBuyIcon.png",
								  ["IconPos"] = Vector(0, -5),
								  ["EntityPresetName"] = "CED.rte/Xarix Vidara",
								  ["EntityClassName"] = "HDFirearm",
								  ["EntityTechName"] = "CED",
								  ["QueueTime"] = 10000,
								  ["Cost"] = 200};


-------  BUILDINGS  -------
CEDMasterList.Buildings.Coagulator = {["DisplayName"] = "     Atmo\ncoagulator",
								  ["RequiredTech"] = "None",
								  ["ItemID"] = "Coagulator",
								  ["Type"] = "Building",
								  ["Description"] = [[
Builds the Atmo-coagulator
What it does: Yes
Yay!]],
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
								  ["ItemID"] = "Supercomputer",
								  ["Type"] = "Building",
								  ["Description"] = [[
Builds the Supercomputer
What it does: Yes
Yay!]],
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
								  ["RequiredTech"] = "None",
								  ["ItemID"] = "XarixNanofab",
								  ["Type"] = "Building",
								  ["Description"] = [[
Builds the Xarix-Nanofab
What it does: Yes
Yay!]],
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
	-------  GUNS  -------
CEDMasterList.Technology.Xarix.XaDoctra = {["DisplayName"] = "A Doctra",
								  ["RequiredTech"] = "None",
								  ["Type"] = "Device",
								  ["Description"] = [[
Plasma pistol.
]],
								  ["InfoBoxDescription"] = [[
Blank
]],
								  ["Action"] = "\t SEMI\nAUTOMATIC",
								  ["RPM"] = "\tSEMI",
								  ["MAG"] = "\t  12",
								  ["Pos"] = Vector(100, 75),
								  ["IconPath"] = "CED.rte/Devices/Weapons/Handheld/XaDoctra/Icon.png",
								  ["IconSize"] = Vector(15, 8),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};

CEDMasterList.Technology.Xarix.XaA12Axiom = {["DisplayName"] = "A-12 Axiom",
								  ["RequiredTech"] = "None",
								  ["Type"] = "Device",
								  ["Description"] = [[
Plasma autorevolver.
]],
["InfoBoxDescription"] = [[
Blank
]],
								  ["Action"] = "\tDOUBLE\n\tACTION",
								  ["RPM"] = "\tSEMI",
								  ["MAG"] = "\t   5",
								  ["Pos"] = Vector(150, 75),
								  ["IconPath"] = "CED.rte/Devices/Weapons/Handheld/XaA12Axiom/Icon.png",
								  ["IconSize"] = Vector(23, 12),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};

CEDMasterList.Technology.Xarix.XaMTXDirective = {["DisplayName"] = "MTX Directive",
								  ["RequiredTech"] = "None",
								  ["Type"] = "Device",
								  ["Description"] = [[
Plasma smartgun.
]],
["InfoBoxDescription"] = [[
Blank
]],
								  ["Action"] = "\tFULLY\nAUTOMATIC",
								  ["RPM"] = "\t 800",
								  ["MAG"] = "\t30+1",
								  ["Pos"] = Vector(200, 75),
								  ["IconPath"] = "CED.rte/Devices/Weapons/Handheld/XaMTXDirective/Icon.png",
								  ["IconSize"] = Vector(17, 10),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};

CEDMasterList.Technology.Xarix.XaVidara = {["DisplayName"] = "Vidara",
								  ["RequiredTech"] = "None",
								  ["Type"] = "Device",
								  ["Description"] = [[
Hybrid lasergun.
]],
["InfoBoxDescription"] = [[
Blank
]],
								  ["Action"] = "  ELECTRIC",
								  ["RPM"] = " 150-400",
								  ["MAG"] = "\t  24",
								  ["Pos"] = Vector(250, 75),
								  ["IconPath"] = "CED.rte/Devices/Weapons/Handheld/XaVidara/Icon.png",
								  ["IconSize"] = Vector(25, 10),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};

CEDMasterList.Technology.Xarix.XaEACondor = {["DisplayName"] = "EA Condor",
								  ["RequiredTech"] = "None",
								  ["Type"] = "Device",
								  ["Description"] = [[
Charge cannon.
]],
["InfoBoxDescription"] = [[
Blank
]],
								  ["Action"] = "   CHARGE",
								  ["RPM"] = "\tSEMI",
								  ["MAG"] = "\t   1",
								  ["Pos"] = Vector(300, 75),
								  ["IconPath"] = "CED.rte/Devices/Weapons/Handheld/XaEACondor/Icon.png",
								  ["IconSize"] = Vector(34, 13),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};
	-------  BUILDINGS  -------

	-------  KHRABAROVSK  -------
CEDMasterList.Technology.Khrabarovsk.KhSPr40 = {["DisplayName"] = "SPr-40",
								  ["RequiredTech"] = "None",
								  ["Type"] = "Device",
								  ["Description"] = [[
Double-action revolver.
]],
["InfoBoxDescription"] = [[
Blank
]],
								  ["Action"] = "\tDOUBLE\n\tACTION",
								  ["RPM"] = "\tSEMI",
								  ["MAG"] = "\t   8",
								  ["Pos"] = Vector(100, 75),
								  ["IconPath"] = "CED.rte/Devices/Weapons/Handheld/KhSPr40/Icon.png",
								  ["IconSize"] = Vector(14, 10),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};

CEDMasterList.Technology.Khrabarovsk.KhGS7 = {["DisplayName"] = "GS7",
								  ["RequiredTech"] = "None",
								  ["Type"] = "Device",
								  ["Description"] = [[
Pump action shotgun.
]],
["InfoBoxDescription"] = [[
Blank
]],
								  ["Action"] = "\t PUMP\n\tACTION",
								  ["RPM"] = "\tSEMI",
								  ["MAG"] = "\t 4+1",
								  ["Pos"] = Vector(150, 75),
								  ["IconPath"] = "CED.rte/Devices/Weapons/Handheld/KhGS7/Icon.png",
								  ["IconSize"] = Vector(28, 10),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};

CEDMasterList.Technology.Khrabarovsk.Kh11p35 = {["DisplayName"] = "11p35-rifle",
								  ["RequiredTech"] = "None",
								  ["Type"] = "Device",
								  ["Description"] = [[
Select-fire assault rifle with underbarrel launcher.
]],
["InfoBoxDescription"] = [[
Blank
]],
								  ["Action"] = "   SELECT\n\t FIRE",
								  ["RPM"] = "\t 600",
								  ["MAG"] = "\t30+1",
								  ["Pos"] = Vector(200, 75),
								  ["IconPath"] = "CED.rte/Devices/Weapons/Handheld/Kh11p35/Icon.png",
								  ["IconSize"] = Vector(28, 12),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};

CEDMasterList.Technology.Khrabarovsk.KhMOSKA = {["DisplayName"] = "MOSKA",
								  ["RequiredTech"] = "None",
								  ["Type"] = "Device",
								  ["Description"] = [[
Bolt-action rifle.
]],
["InfoBoxDescription"] = [[
Blank
]],
								  ["Action"] = "\t  BOLT\n\tACTION",
								  ["RPM"] = "\tSEMI",
								  ["MAG"] = "\t 4+1",
								  ["Pos"] = Vector(250, 75),
								  ["IconPath"] = "CED.rte/Devices/Weapons/Handheld/KhMOSKA/Icon.png",
								  ["IconSize"] = Vector(32, 10),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};

CEDMasterList.Technology.Khrabarovsk.KhJS50 = {["DisplayName"] = "JS50",
								  ["RequiredTech"] = "None",
								  ["Type"] = "Device",
								  ["Description"] = [[
Marksman rifle.
]],
["InfoBoxDescription"] = [[
Blank
]],
								  ["Action"] = "\t SEMI\nAUTOMATIC",
								  ["RPM"] = "\tSEMI",
								  ["MAG"] = "\t 7+1",
								  ["Pos"] = Vector(300, 75),
								  ["IconPath"] = "CED.rte/Devices/Weapons/Handheld/KhJS50/Icon.png",
								  ["IconSize"] = Vector(34, 12),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};

CEDMasterList.Technology.Khrabarovsk.KhC8Chimera = {["DisplayName"] = "C8 Chimera",
								  ["RequiredTech"] = "None",
								  ["Type"] = "Device",
								  ["Description"] = [[
Deployable GPMG.
]],
["InfoBoxDescription"] = [[
Blank
]],
								  ["Action"] = "\tFULLY\nAUTOMATIC",
								  ["RPM"] = "\t 550",
								  ["MAG"] = "\t  80",
								  ["Pos"] = Vector(350, 75),
								  ["IconPath"] = "CED.rte/Devices/Weapons/Handheld/KhC8Chimera/Icon.png",
								  ["IconSize"] = Vector(43, 13),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};
								  
CEDMasterList.Technology.Khrabarovsk.KhAMAVogastir40 = {["DisplayName"] = "AMA-Vogastir 40",
								  ["RequiredTech"] = "None",
								  ["Type"] = "Device",
								  ["Description"] = [[
Deployable GMG.
]],
["InfoBoxDescription"] = [[
Khrabarovsk-brand grenade machine gun.
Slow, but supreme. For non-heavy
actors, can only be used when
crouching and still.
 
You don't generally hear the words
'sawn-off grenade machine gun'
put together that way, but the
AMA-Vogastir 40 is just that, a
shorty belt-fed GMG with detachable
box-magazines, LMG-style, firing
full-power, high-velocity 40x76mm
explosive shells at a rate-limited,
but steady pace. Suffice to say,
few things will want to come into 
this creature's line of sight when
it's all set up and loaded.
]],
								  ["Action"] = "\tFULLY\nAUTOMATIC",
								  ["RPM"] = "\t 220",
								  ["MAG"] = "\t  25",
								  ["Pos"] = Vector(350, 100),
								  ["IconPath"] = "CED.rte/Devices/Weapons/Handheld/KhAMAVogastir40/Icon.png",
								  ["IconSize"] = Vector(29, 12),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};
	-------  VOSSBERG  -------
CEDMasterList.Technology.Vossberg.VoHammerhead = {["DisplayName"] = "Hammerhead",
								  ["RequiredTech"] = "None",
								  ["Type"] = "Device",
								  ["Description"] = [[
Handcannon.
]],
["InfoBoxDescription"] = [[
Blank
]],
								  ["Action"] = "\t SEMI\nAUTOMATIC",
								  ["RPM"] = "\tSEMI",
								  ["MAG"] = "\t 7+1",
								  ["Pos"] = Vector(100, 75),
								  ["IconPath"] = "CED.rte/Devices/Weapons/Handheld/VoHammerhead/Icon.png",
								  ["IconSize"] = Vector(18, 10),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};

CEDMasterList.Technology.Vossberg.VoAtlastar = {["DisplayName"] = "Atlastar",
								  ["RequiredTech"] = "None",
								  ["Type"] = "Device",
								  ["Description"] = [[
Double-barreled hyperburst SMG.
]],
["InfoBoxDescription"] = [[
Blank
]],
								  ["Action"] = "\tFULLY\nAUTOMATIC",
								  ["RPM"] = "800-3600",
								  ["MAG"] = "\t  20",
								  ["Pos"] = Vector(150, 75),
								  ["IconPath"] = "CED.rte/Devices/Weapons/Handheld/VoAtlastar/Icon.png",
								  ["IconSize"] = Vector(22, 10),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};

CEDMasterList.Technology.Vossberg.VoTrigoliath = {["DisplayName"] = "Trigoliath",
								  ["RequiredTech"] = "None",
								  ["Type"] = "Device",
								  ["Description"] = [[
Triple-barrel shotgun.
]],
["InfoBoxDescription"] = [[
Blank
]],
								  ["Action"] = "\tBREAK\n   ACTION",
								  ["RPM"] = "\tSEMI",
								  ["MAG"] = "\t   3",
								  ["Pos"] = Vector(200, 75),
								  ["IconPath"] = "CED.rte/Devices/Weapons/Handheld/VoTrigoliath/Icon.png",
								  ["IconSize"] = Vector(36, 11),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};

CEDMasterList.Technology.Vossberg.VoGrandarme = {["DisplayName"] = "Grandarme",
								  ["RequiredTech"] = "None",
								  ["Type"] = "Device",
								  ["Description"] = [[
High-caliber assault rifle.
]],
["InfoBoxDescription"] = [[
Blank
]],
								  ["Action"] = "\tFULLY\nAUTOMATIC",
								  ["RPM"] = " 250-490",
								  ["MAG"] = "\t30+1",
								  ["Pos"] = Vector(250, 75),
								  ["IconPath"] = "CED.rte/Devices/Weapons/Handheld/VoGrandarme/Icon.png",
								  ["IconSize"] = Vector(35, 16),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};

CEDMasterList.Technology.Vossberg.VoTitanAMI = {["DisplayName"] = "Titan AMI",
								  ["RequiredTech"] = "None",
								  ["Type"] = "Device",
								  ["Description"] = [[
Anti-materiel rifle.
]],
["InfoBoxDescription"] = [[
Blank
]],
								  ["Action"] = "   BREECH\n  LOADING",
								  ["RPM"] = "\tSEMI",
								  ["MAG"] = "\t   1",
								  ["Pos"] = Vector(300, 75),
								  ["IconPath"] = "CED.rte/Devices/Weapons/Handheld/VoTitanAMI/Icon.png",
								  ["IconSize"] = Vector(39, 11),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};

CEDMasterList.Technology.Vossberg.EXPTurbolance = {["DisplayName"] = "Turbolance",
								  ["RequiredTech"] = "None",
								  ["Type"] = "Device",
								  ["Description"] = [[
Minigun.
]],
["InfoBoxDescription"] = [[
Experimental microgun. Emplacement-grade firerate.
 Overheats rapidly - avoid overuse,
 or use the Primary Ability Hotkey
 (default V) to manually cool off the gun.

The Turbolance makes no concessions when
 it comes to giving you the power of a minigun,
 except in the sensical areas like "capacity"
 and "practicality". It's armed to the teeth with
 gyroscopic stabilizers so you can be armed to the
 teeth with it, leaving only the overheating to fear.
 Luckily, active thermal vents are available to use,
 so you'll never be stuck waiting around for minutes
 at a time for the gun to cool off.
]],
								  ["Action"] = "  ELECTRIC",
								  ["RPM"] = "\t3600",
								  ["MAG"] = "\t 200",
								  ["Pos"] = Vector(200, 200),
								  ["IconPath"] = "CED.rte/Devices/Weapons/Handheld/EXPTurbolance/Icon.png",
								  ["IconSize"] = Vector(37, 16),
								  ["ResearchTime"] = 1000,
								  ["Cost"] = 1000};