require("MasterList")

function Create(self)
	self.CEDAHumanJumpStrength = 1.0;
	
	self.CEDAHumanAccelerationFactor = 0.4;
	self.CEDAHumanWalkMultiplier = 0.55;
	self.CEDAHumanSprintMultiplier = 1.0;
	self.CEDAHumanSprintingRotAngleOffset = -0.02;
	self.CEDAHumanCrouchRunAmount = 0.6;
	
	self.CEDAHumanFoleyAIVolume = 0.6;

	self.CEDAHumanFoleySounds = {};
	self.CEDAHumanFoleySounds.Walk = CreateSoundContainer("Walk CED Behemoth", "CED.rte");
	self.CEDAHumanFoleySounds.Sprint = CreateSoundContainer("Sprint CED Behemoth", "CED.rte");
	self.CEDAHumanFoleySounds.Jump = CreateSoundContainer("Jump CED Behemoth", "CED.rte");
	self.CEDAHumanFoleySounds.Land = CreateSoundContainer("Land CED Behemoth", "CED.rte");
	self.CEDAHumanFoleySounds.Crouch = CreateSoundContainer("Crouch CED Behemoth", "CED.rte");
	self.CEDAHumanFoleySounds.Stand = CreateSoundContainer("Stand CED Behemoth", "CED.rte");
	self.CEDAHumanFoleySounds.ProneStart = CreateSoundContainer("Prone Start CED Behemoth", "CED.rte");
	self.CEDAHumanFoleySounds.Prone = CreateSoundContainer("Impact Light CED Behemoth", "CED.rte");
	self.CEDAHumanFoleySounds.Crawl = CreateSoundContainer("Crawl CED Behemoth", "CED.rte");
	self.CEDAHumanFoleySounds.ImpactLight = CreateSoundContainer("Impact Light CED Behemoth", "CED.rte");
	self.CEDAHumanFoleySounds.ImpactHeavy = CreateSoundContainer("Impact Heavy CED Behemoth", "CED.rte");

end