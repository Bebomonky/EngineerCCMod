require("MasterBuildableList")

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
	self.CEDAvailableBuildables.Turrets[i] = CEDMasterBuildableList.Turrets.PlinkTurret
	i = i + 1;
	
	
	-------  BUILDINGS  -------
	
	-------  UTILITY  -------
end