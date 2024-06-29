function Create(self)

	-- Firing animation system
	self.useHEATFiringAnimation = true;
	
	self.HEATFiringAnimationEndFrame = 2;
	self.HEATLockBackOnEmpty = false;
	
	-- CompliSound atmo firing sound system
	
	self.useHEATCompliSound = true;
	
	self.HEATReflectionOutdoorsSound = CreateSoundContainer("Reflection Outdoors CED Test Pistol", "CED.rte");
	self.HEATReflectionIndoorsSound = CreateSoundContainer("Reflection Indoors CED Test Pistol", "CED.rte");
	
	self.HEATFireCallback = function (self)
		
	end

	-- Reload system
	self.useHEATReload = true;
	
	self.HEATPlusOneChamberedRound = true;
	self.HEATFullMagazineRoundCount = 10;
	
	self.HEATStageAfterEveryShot = false;
	
	self.HEATTotalFullReloadTimeOverride = 1131;
	self.HEATTotalEmptyReloadTimeOverride = 1906;
	
	-- Ignore FlipFactor here, it is handled automatically
	self.HEATCasing = nil;
	self.HEATCasingOffset = Vector(0, 0);
	self.HEATCasingVelocity = Vector(0, 0);
	
	self.HEATFakeMagazineMOSRotating = CreateMOSRotating("Fake Magazine MOSRotating CED Test Pistol", "CED.rte");
	self.HEATFakeMagazineOffset = Vector(-4, 2);
	self.HEATFakeMagazineVelocity = Vector(0.5, 2);
	self.HEATFakeMagazineAngularVel = -1;
	
	-- During callbacks, you have access to self.
	
	self.HEATReloadPhases = {};
	
	------------------------------------------------------------------------------		
	
	local i = 1;
	local reloadPhase = {};
	reloadPhase.Name = "MagOut";
	reloadPhase.removesMag = true;
	reloadPhase.addsMag = false;
	reloadPhase.autoProgressIfFinishedButInterrupted = true;
	reloadPhase.prepareSound = CreateSoundContainer("Mag Out Prepare CED Test Pistol", "CED.rte");
	reloadPhase.prepareDelay = 100;
	reloadPhase.prepareSoundLength = 140;
	reloadPhase.afterSound = CreateSoundContainer("Mag Out CED Test Pistol", "CED.rte");
	reloadPhase.afterDelay = 200;
	reloadPhase.reloadStanceOffsetTarget = Vector(5, -2);
	reloadPhase.reloadSupportOffsetSpeed = 16;
	reloadPhase.reloadSupportOffsetTarget = Vector(-4, 5)
	reloadPhase.rotationTarget = 25;
	reloadPhase.angVel = 2;
	reloadPhase.horizontalAnim = 0;
	reloadPhase.verticalAnim = 1;
	reloadPhase.autoAnimateFrames = false;
	reloadPhase.startFrame = 0;
	reloadPhase.endFrame = 0;
	reloadPhase.phaseOnInterrupt = nil;
	reloadPhase.endIfNotEmptyReload = false;
	reloadPhase.shotgunReloadLoop = false;
	reloadPhase.spawnCasing = false;
	reloadPhase.enterPhaseCallback = function (self)
		
	end
	reloadPhase.constantCallback = function (self)
		
	end
	reloadPhase.finishCallback = function (self)
		
	end
	reloadPhase.exitPhaseCallback = function (self)
		
	end
	
	self.HEATReloadPhases[i] = reloadPhase;
	
	------------------------------------------------------------------------------		
	
	i = i + 1;
	reloadPhase = {};
	reloadPhase.Name = "MagIn";
	reloadPhase.removesMag = false;
	reloadPhase.addsMag = true;
	reloadPhase.autoProgressIfFinishedButInterrupted = true;
	reloadPhase.prepareSound = CreateSoundContainer("Mag In Prepare CED Test Pistol", "CED.rte");
	reloadPhase.prepareDelay = 630;
	reloadPhase.prepareSoundLength = 550;
	reloadPhase.afterSound = CreateSoundContainer("Mag In CED Test Pistol", "CED.rte");
	reloadPhase.afterDelay = 200;
	reloadPhase.reloadStanceOffsetTarget = Vector(0, 0);
	reloadPhase.reloadSupportOffsetSpeed = 16;
	reloadPhase.reloadSupportOffsetTarget = Vector(-4, 8)
	reloadPhase.rotationTarget = 20;
	reloadPhase.angVel = -2;
	reloadPhase.horizontalAnim = 0;
	reloadPhase.verticalAnim = -1;
	reloadPhase.autoAnimateFrames = false;
	reloadPhase.startFrame = 0;
	reloadPhase.endFrame = 0;
	reloadPhase.phaseOnInterrupt = nil;
	reloadPhase.endIfNotEmptyReload = true;
	reloadPhase.shotgunReloadLoop = false;
	reloadPhase.spawnCasing = false;
	reloadPhase.enterPhaseCallback = function (self)
		
	end
	reloadPhase.constantCallback = function (self)
		
	end
	reloadPhase.finishCallback = function (self)
		
	end
	reloadPhase.exitPhaseCallback = function (self)
		
	end
	
	self.HEATReloadPhases[i] = reloadPhase;
	
	------------------------------------------------------------------------------		
	
	i = i + 1;
	reloadPhase = {};
	reloadPhase.Name = "BoltBack";
	reloadPhase.removesMag = false;
	reloadPhase.addsMag = false;
	reloadPhase.autoProgressIfFinishedButInterrupted = false;
	reloadPhase.prepareSound = CreateSoundContainer("Bolt Back Prepare CED Test Pistol", "CED.rte");
	reloadPhase.prepareDelay = 250;
	reloadPhase.prepareSoundLength = 220;
	reloadPhase.afterSound = CreateSoundContainer("Bolt Back CED Test Pistol", "CED.rte");
	reloadPhase.afterDelay = 150;
	reloadPhase.reloadStanceOffsetTarget = Vector(4, -2);
	reloadPhase.reloadSupportOffsetSpeed = 16;
	reloadPhase.reloadSupportOffsetTarget = Vector(-4, -3)
	reloadPhase.rotationTarget = 30;
	reloadPhase.angVel = -15;
	reloadPhase.horizontalAnim = 0;
	reloadPhase.verticalAnim = 0;
	reloadPhase.autoAnimateFrames = true;
	reloadPhase.startFrame = 0;
	reloadPhase.endFrame = 2;
	reloadPhase.phaseOnInterrupt = nil;
	reloadPhase.endIfNotEmptyReload = false;
	reloadPhase.shotgunReloadLoop = false;
	reloadPhase.spawnCasing = false;
	reloadPhase.enterPhaseCallback = function (self)
		
	end
	reloadPhase.constantCallback = function (self)
		
	end
	reloadPhase.finishCallback = function (self)
		
	end
	reloadPhase.exitPhaseCallback = function (self)
		
	end
	
	self.HEATReloadPhases[i] = reloadPhase;
	
	------------------------------------------------------------------------------		
	
	i = i + 1;
	reloadPhase = {};
	reloadPhase.Name = "BoltForward";
	reloadPhase.removesMag = false;
	reloadPhase.addsMag = false;
	reloadPhase.autoProgressIfFinishedButInterrupted = false;
	reloadPhase.prepareSound = nil;
	reloadPhase.prepareDelay = 175;
	reloadPhase.prepareSoundLength = 0;
	reloadPhase.afterSound = CreateSoundContainer("Bolt Forward CED Test Pistol", "CED.rte");
	reloadPhase.afterDelay = 200;
	reloadPhase.reloadStanceOffsetTarget = Vector(0, 0);
	reloadPhase.reloadSupportOffsetSpeed = 16;
	reloadPhase.reloadSupportOffsetTarget = Vector(-7, -2)
	reloadPhase.rotationTarget = 30;
	reloadPhase.angVel = 35;
	reloadPhase.horizontalAnim = 0;
	reloadPhase.verticalAnim = 0;
	reloadPhase.autoAnimateFrames = true;
	reloadPhase.startFrame = 2;
	reloadPhase.endFrame = 0;
	reloadPhase.phaseOnInterrupt = 3;
	reloadPhase.endIfNotEmptyReload = false;
	reloadPhase.shotgunReloadLoop = false;
	reloadPhase.spawnCasing = false;
	reloadPhase.enterPhaseCallback = function (self)
		
	end
	reloadPhase.constantCallback = function (self)
		
	end
	reloadPhase.finishCallback = function (self)
		
	end
	reloadPhase.exitPhaseCallback = function (self)
		
	end
	
	self.HEATReloadPhases[i] = reloadPhase;

	------------------------------------------------------------------------------	
	
	-- Recoil system
	self.useHEATRecoil = true;
	
	self.HEATRecoilHorizontalAnim = 5;
	self.HEATRecoilAngAnim = 7;
	self.HEATRecoilAngVariation = 0.2;
	
	self.HEATRecoilAcc = 0 -- for sinous
	self.HEATRecoilStr = 0 -- for accumulator
	self.HEATRecoilStrength = 10 -- multiplier for base recoil added to the self.recoilStr when firing
	self.HEATRecoilPowStrength = 0.2 -- multiplier for self.recoilStr when firing
	self.HEATRecoilRandomUpper = 2 -- upper end of random multiplier (1 is lower)
	self.HEATRecoilDamping = 0.8
	
	self.HEATRecoilMax = 4 -- in deg.
	
	
	-- Delayed fire system
	self.useHEATDelayedFire = true;
	
	self.HEATPreSound = CreateSoundContainer("Pre CED Test Pistol", "CED.rte");
	self.HEATDelayedFireTimeMS = 70
end