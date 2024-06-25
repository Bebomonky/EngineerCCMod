function Create(self)
	self.CEDBuildRange = 200;
	self.CEDBuildRate = 10;
	self.CEDBuildDelay = 1000;
	
	self.CEDBuildTimer = Timer();

	self.CEDAvailableBuildables = {};
	local i = 1;
	self.CEDAvailableBuildables[i] = {["DisplayName"] = "Plink Turret",
									  ["IconPath"] = "Coalition.rte/Actors/Mecha/GatlingDrone/Icon.png",
									  ["BuildablePresetName"] = "CED Plink Turret Buildable",
									  ["Cost"] = 50,
									  ["SnapToGround"] = true};
	i = i + 1;
end