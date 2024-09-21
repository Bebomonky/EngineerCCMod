require("MasterList")

function Create(self)
	self.CEDAHumanJumpStrength = 1.5;
	
	self.CEDAHumanAccelerationFactor = 1.0;
	self.CEDAHumanDecelerationFactor = 1.0;
	self.CEDAHumanWalkMultiplier = 1.0;
	self.CEDAHumanSprintMultiplier = 2.0;
	self.CEDAHumanSprintingRotAngleOffset = -0.15;
	self.CEDAHumanCrouchRunAmount = 1.0;
	
	self.CompliSoundActorTerrainSoundDefaultVolumeOverride = 1.0;
	self.CompliSoundActorTerrainSoundPitchOverride = 1.0;

	self.CEDAHumanFoleySounds = {};
	self.CEDAHumanFoleySounds.Walk = CreateSoundContainer("Walk CED Combat Engineer", "CED.rte");
	self.CEDAHumanFoleySounds.Sprint = CreateSoundContainer("Sprint CED Combat Engineer", "CED.rte");
	self.CEDAHumanFoleySounds.Jump = CreateSoundContainer("Jump CED Combat Engineer", "CED.rte");
	self.CEDAHumanFoleySounds.Land = CreateSoundContainer("Land CED Combat Engineer", "CED.rte");
	self.CEDAHumanFoleySounds.Crouch = CreateSoundContainer("Crouch CED Combat Engineer", "CED.rte");
	self.CEDAHumanFoleySounds.Stand = CreateSoundContainer("Stand CED Combat Engineer", "CED.rte");
	self.CEDAHumanFoleySounds.ProneStart = CreateSoundContainer("Prone Start CED Combat Engineer", "CED.rte");
	self.CEDAHumanFoleySounds.Prone = CreateSoundContainer("Land CED Combat Engineer", "CED.rte");
	self.CEDAHumanFoleySounds.Crawl = CreateSoundContainer("Crawl CED Combat Engineer", "CED.rte");
	self.CEDAHumanFoleySounds.ImpactLight = nil;
	self.CEDAHumanFoleySounds.ImpactHeavy = nil;

end