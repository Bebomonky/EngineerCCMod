function Create(self)

	-- Firing animation system
	self.useHEATFiringAnimation = false;
	
	self.HEATFiringAnimationEndFrame = 0;
	
	-- CompliSound atmo firing sound system
	
	self.HEATReflectionOutdoorsSound = CreateSoundContainer("Reflection Outdoors CED Test Shotgun", "CED.rte");
	self.HEATReflectionIndoorsSound = CreateSoundContainer("Reflection Indoors CED Test Shotgun", "CED.rte");
	
	self.HEATFireCallback = function (self)
		self.HEATCurrentReloadPhase = 2;
	end

	-- Reload system
	self.useHEATReload = true;
	
	self.HEATPlusOneChamberedRound = false;
	self.HEATFullMagazineRoundCount = 5;
	
	self.HEATStageAfterEveryShot = true;
	
	self.HEATTotalFullReloadTimeOverride = 19999;
	self.HEATTotalEmptyReloadTimeOverride = 19999;
	
	-- Ignore FlipFactor here, it is handled automatically
	self.HEATCasing = CreateAEmitter("Shell CED Test Shotgun", "CED.rte");
	self.HEATCasingOffset = Vector(-3, -1);
	self.HEATCasingVelocity = Vector(-3, -3);
	
	self.HEATFakeMagazineMOSRotating = nil;
	self.HEATFakeMagazineOffset = Vector(0, 0);
	self.HEATFakeMagazineVelocity = Vector(0, 0);
	self.HEATFakeMagazineAngularVel = 0;
	
	-- During callbacks, you have access to self.
	
	self.HEATReloadPhases = {};
	
	------------------------------------------------------------------------------
	
	local i = 1;
	local reloadPhase = {};
	reloadPhase.Name = "Raise";
	reloadPhase.removesMag = false;
	reloadPhase.addsMag = false;
	reloadPhase.autoProgressIfFinishedButInterrupted = false;
	reloadPhase.prepareSound = nil;
	reloadPhase.prepareDelay = 50;
	reloadPhase.prepareSoundLength = 0;
	reloadPhase.afterSound = CreateSoundContainer("Raise CED Test Shotgun", "CED.rte");
	reloadPhase.afterDelay = 450;
	reloadPhase.reloadStanceOffsetTarget = Vector(-1, -1);
	reloadPhase.reloadSupportOffsetSpeed = 10;
	reloadPhase.reloadSupportOffsetTarget = Vector(2, 2)
	reloadPhase.rotationTarget = 20;
	reloadPhase.angVel = 0;
	reloadPhase.horizontalAnim = 0;
	reloadPhase.verticalAnim = 0;
	reloadPhase.autoAnimateFrames = true;
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
		if self.HEATAmmoCounter == 0 then
			self.HEATReloadPhaseOverride = 2;
		else
			self.HEATReloadPhaseOverride = 5;
		end
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
	reloadPhase.prepareSound = nil;
	reloadPhase.prepareDelay = 200;
	reloadPhase.prepareSoundLength = 0;
	reloadPhase.afterSound = CreateSoundContainer("Bolt Back CED Test Shotgun", "CED.rte");
	reloadPhase.afterDelay = 200;
	reloadPhase.reloadStanceOffsetTarget = Vector(0, 0);
	reloadPhase.reloadSupportOffsetSpeed = 7;
	reloadPhase.reloadSupportOffsetTarget = Vector(2, 2)
	reloadPhase.rotationTarget = 20;
	reloadPhase.angVel = 0;
	reloadPhase.horizontalAnim = 0;
	reloadPhase.verticalAnim = 0;
	reloadPhase.autoAnimateFrames = true;
	reloadPhase.startFrame = 0;
	reloadPhase.endFrame = 3;
	reloadPhase.phaseOnInterrupt = nil;
	reloadPhase.endIfNotEmptyReload = true;
	reloadPhase.shotgunReloadLoop = false;
	reloadPhase.spawnCasing = true;
	reloadPhase.enterPhaseCallback = function (self)
	
	end
	reloadPhase.constantCallback = function (self)
		if self:IsReloading() then
			self.HEATRotationTarget = (30 * self.HEATReloadTimer.ElapsedSimTimeMS / (self.HEATCurrentReloadPhaseData.prepareDelay + self.HEATCurrentReloadPhaseData.afterDelay))
		else
			self.HEATRotationTarget = (5 * self.HEATReloadTimer.ElapsedSimTimeMS / (self.HEATCurrentReloadPhaseData.prepareDelay + self.HEATCurrentReloadPhaseData.afterDelay))
		end
		if self.HEATReloadTimer:IsPastSimMS(self.HEATCurrentReloadPhaseData.prepareDelay) then
			local progressFactor = (self.HEATReloadTimer.ElapsedSimTimeMS - self.HEATCurrentReloadPhaseData.prepareDelay) / (self.HEATCurrentReloadPhaseData.afterDelay)
			if progressFactor > 1 then
				progressFactor = 1;
			end			
		
			self.HEATReloadSupportOffsetTarget.X = -2
		end		
	end
	reloadPhase.finishCallback = function (self)
		if self:IsReloading() then
			if self.HEATAmmoCounter == 0 then
				self.HEATReloadPhaseOverride = 3;
			else
				self.HEATReloadPhaseOverride = 6;
			end
		else
			self.HEATReloadPhaseOverride = 6;
		end
	end
	reloadPhase.exitPhaseCallback = function (self)
		
	end
	
	self.HEATReloadPhases[i] = reloadPhase;
	
	------------------------------------------------------------------------------	
	
	i = i + 1;
	reloadPhase = {};
	reloadPhase.Name = "FirstRoundIn";
	reloadPhase.removesMag = false;
	reloadPhase.addsMag = false;
	reloadPhase.autoProgressIfFinishedButInterrupted = false;
	reloadPhase.prepareSound = CreateSoundContainer("First Round In Prepare CED Test Shotgun", "CED.rte");
	reloadPhase.prepareDelay = 600;
	reloadPhase.prepareSoundLength = 280;
	reloadPhase.afterSound = CreateSoundContainer("First Round In CED Test Shotgun", "CED.rte");
	reloadPhase.afterDelay = 300;
	reloadPhase.reloadStanceOffsetTarget = Vector(0, 0);
	reloadPhase.reloadSupportOffsetSpeed = 3;
	reloadPhase.reloadSupportOffsetTarget = Vector(-4, -3)
	reloadPhase.rotationTarget = 30;
	reloadPhase.angVel = 0;
	reloadPhase.horizontalAnim = 1;
	reloadPhase.verticalAnim = -1;
	reloadPhase.autoAnimateFrames = true;
	reloadPhase.startFrame = 3;
	reloadPhase.endFrame = 5;
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
	reloadPhase.Name = "FirstRoundInBoltForward";
	reloadPhase.removesMag = false;
	reloadPhase.addsMag = false;
	reloadPhase.autoProgressIfFinishedButInterrupted = false;
	reloadPhase.prepareSound = nil;
	reloadPhase.prepareDelay = 300;
	reloadPhase.prepareSoundLength = 0;
	reloadPhase.afterSound = CreateSoundContainer("Bolt Forward CED Test Shotgun", "CED.rte");
	reloadPhase.afterDelay = 400;
	reloadPhase.reloadStanceOffsetTarget = Vector(0, 0);
	reloadPhase.reloadSupportOffsetSpeed = 10;
	reloadPhase.reloadSupportOffsetTarget = Vector(-1, 2)
	reloadPhase.rotationTarget = 32;
	reloadPhase.angVel = 0;
	reloadPhase.horizontalAnim = 0;
	reloadPhase.verticalAnim = 0;
	reloadPhase.autoAnimateFrames = false;
	reloadPhase.startFrame = 5;
	reloadPhase.endFrame = 0;
	reloadPhase.phaseOnInterrupt = nil;
	reloadPhase.endIfNotEmptyReload = false;
	reloadPhase.shotgunReloadLoop = false;
	reloadPhase.spawnCasing = false;
	reloadPhase.enterPhaseCallback = function (self)
		
	end
	reloadPhase.constantCallback = function (self)
		if self.HEATReloadTimer:IsPastSimMS(self.HEATCurrentReloadPhaseData.prepareDelay) then
			local progressFactor = (self.HEATReloadTimer.ElapsedSimTimeMS - self.HEATCurrentReloadPhaseData.prepareDelay) / (self.HEATCurrentReloadPhaseData.afterDelay)
			if progressFactor > 1 then
				progressFactor = 1;
			end			
		
			self.Frame = math.floor(5 + math.floor(3 * progressFactor, 0.55))
			if self.Frame == 8 then
				self.Frame = 0;
			end
			self.HEATReloadSupportOffsetTarget.X = 4;
		end
	end
	reloadPhase.finishCallback = function (self)
		self.HEATAmmoCounter = self.HEATAmmoCounter + 1;
		if self.HEATReloadManuallyInterrupted then
			self.HEATForceEndReload = true;
		end
	end
	reloadPhase.exitPhaseCallback = function (self)
		
	end
	
	self.HEATReloadPhases[i] = reloadPhase;
	
	------------------------------------------------------------------------------	
	
	i = i + 1;
	reloadPhase = {};
	reloadPhase.Name = "RoundIn";
	reloadPhase.removesMag = false;
	reloadPhase.addsMag = false;
	reloadPhase.autoProgressIfFinishedButInterrupted = false;
	reloadPhase.prepareSound = nil;
	reloadPhase.prepareDelay = 450;
	reloadPhase.prepareSoundLength = 0;
	reloadPhase.afterSound = CreateSoundContainer("Round In CED Test Shotgun", "CED.rte");
	reloadPhase.afterDelay = 380;
	reloadPhase.reloadStanceOffsetTarget = Vector(0, 0);
	reloadPhase.reloadSupportOffsetSpeed = 10;
	reloadPhase.reloadSupportOffsetTarget = Vector(-4, 5)
	reloadPhase.rotationTarget = 15;
	reloadPhase.angVel = 0;
	reloadPhase.horizontalAnim = 1;
	reloadPhase.verticalAnim = -1;
	reloadPhase.autoAnimateFrames = false;
	reloadPhase.startFrame = 0;
	reloadPhase.endFrame = 0;
	reloadPhase.phaseOnInterrupt = nil;
	reloadPhase.endIfNotEmptyReload = false;
	reloadPhase.shotgunReloadLoop = true;
	reloadPhase.spawnCasing = false;
	reloadPhase.enterPhaseCallback = function (self)
		self.HEATReloadSupportOffsetTarget.Y = 5;
	end
	reloadPhase.constantCallback = function (self)
		self.HEATRotationTarget = 15 + (5 * self.HEATReloadTimer.ElapsedSimTimeMS / (self.HEATCurrentReloadPhaseData.prepareDelay + self.HEATCurrentReloadPhaseData.afterDelay))
		if self.HEATReloadTimer:IsPastSimMS(self.HEATCurrentReloadPhaseData.prepareDelay) then
			self.HEATReloadSupportOffsetTarget.Y = -1;
		end		
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
	reloadPhase.prepareDelay = 200;
	reloadPhase.prepareSoundLength = 0;
	reloadPhase.afterSound = CreateSoundContainer("Bolt Forward CED Test Shotgun", "CED.rte");
	reloadPhase.afterDelay = 350;
	reloadPhase.reloadStanceOffsetTarget = Vector(0, 0);
	reloadPhase.reloadSupportOffsetSpeed = 7;
	reloadPhase.reloadSupportOffsetTarget = Vector(-2, 2)
	reloadPhase.rotationTarget = -5;
	reloadPhase.angVel = 0;
	reloadPhase.horizontalAnim = 0;
	reloadPhase.verticalAnim = 0;
	reloadPhase.autoAnimateFrames = true;
	reloadPhase.startFrame = 3;
	reloadPhase.endFrame = 0;
	reloadPhase.phaseOnInterrupt = nil;
	reloadPhase.endIfNotEmptyReload = false;
	reloadPhase.shotgunReloadLoop = false;
	reloadPhase.spawnCasing = false;
	reloadPhase.enterPhaseCallback = function (self)
	
	end
	reloadPhase.constantCallback = function (self)
		if self.HEATReloadTimer:IsPastSimMS(self.HEATCurrentReloadPhaseData.prepareDelay) then
			local progressFactor = (self.HEATReloadTimer.ElapsedSimTimeMS - self.HEATCurrentReloadPhaseData.prepareDelay) / (self.HEATCurrentReloadPhaseData.afterDelay / 2)
			if progressFactor > 1 then
				progressFactor = 1;
			end			
		
			self.HEATReloadSupportOffsetTarget.X = 2;
		end				
	end
	reloadPhase.finishCallback = function (self)
		if self:IsReloading() then
			if self.HEATAmmoCounter < self.HEATFullMagazineRoundCount then
				self.HEATReloadPhaseOverride = 5;
			end
		end
	end
	reloadPhase.exitPhaseCallback = function (self)
	
	end

	self.HEATReloadPhases[i] = reloadPhase;
	
	------------------------------------------------------------------------------	
	
	-- Recoil system
	self.useHEATRecoil = true;
	
	self.HEATRecoilHorizontalAnim = 5;
	self.HEATRecoilAngAnim = 10;
	self.HEATRecoilAngVariation = 0.3;
	
	self.HEATRecoilAcc = 0 -- for sinous
	self.HEATRecoilStr = 0 -- for accumulator
	self.HEATRecoilStrength = 29 -- multiplier for base recoil added to the self.recoilStr when firing
	self.HEATRecoilPowStrength = 0.2 -- multiplier for self.recoilStr when firing
	self.HEATRecoilRandomUpper = 1.1 -- upper end of random multiplier (1 is lower)
	self.HEATRecoilDamping = 0.6
	
	self.HEATRecoilMax = 4 -- in deg.
	
	
	-- Delayed fire system
	self.useHEATDelayedFire = false;
	
	self.HEATPreSound = nil;
	self.HEATDelayedFireTimeMS = 70
end