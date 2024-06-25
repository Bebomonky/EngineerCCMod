function Create(self)
	self.CEDBuildRange = 1000;
	self.CEDBuildRate = 10;

	self.CEDAvailableBuildables = {};
	local i = 1;
	self.CEDAvailableBuildables[i] = {["DisplayName"] = "Plink Turret",
									  ["IconPath"] = "Coalition.rte/Actors/Mecha/GatlingDrone/Icon.png",
									  ["BuildablePresetName"] = "CED Plink Turret Buildable",
									  ["Cost"] = 50,
									  ["SnapToGround"] = true};
	i = i + 1;
end