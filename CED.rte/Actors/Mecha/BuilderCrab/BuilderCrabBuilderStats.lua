require("MasterList")

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
	local i = 1;
	self.CEDAvailableBuildables.Fortifications[i] = CEDMasterList.Fortifications.CEDLogo
	i = i + 1;
	
	-------  TURRETS  -------
	local i = 1;
	self.CEDAvailableBuildables.Turrets[i] = CEDMasterList.Turrets.PlinkTurret
	i = i + 1;
	
	
	-------  BUILDINGS  -------
	local i = 1;
	self.CEDAvailableBuildables.Buildings[i] = CEDMasterList.Buildings.AtmoCoagulator
	i = i + 1;
	self.CEDAvailableBuildables.Buildings[i] = CEDMasterList.Buildings.Supercomputer
	i = i + 1;
	
	-------  UTILITY  -------
end