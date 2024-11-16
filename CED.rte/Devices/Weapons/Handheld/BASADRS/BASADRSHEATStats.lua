function Create(self)

	-----------------
	----------------- HEAT system stats file
	-----------------
	
	-- This is a bunch of stats defining how your gun behaves in the HEAT system.
	-- There are very many variables and complex behaviors, so a monolithic instruction set is difficult to make.
	-- Instead, all variables are commented.
	
	-- Vanilla-equivalent reloads, such as basic shotgun-style reloads and magazine feds, should be doable without any callback coding.
	-- For anything more complicated, you've been provided callbacks at various points, and the HEATSystem file has all relevant variables
	-- commented such that you can change them for custom behavior. Don't be afraid to mess with them all to achieve what you need.
	-- However, the HEATSystem file should not be changed.
	
	-----------------
	----------------- General
	-----------------
	
	-- Whether to enable verbose console logging or not.
	self.HEATVerboseLogging = true;
	
	-- Easing functions. They have to be here so they're defined by the time you use them in reload phases.
	self.HEATEaseLinear = function (x)
		return x;
	end
	self.HEATEaseOutCubic = function (x)
		return 1 - math.pow(1 - x, 3);
	end
	self.HEATEaseInOutCubic = function (x)
		return x < 0.5 and 4 * x * x * x or 1 - math.pow(-2 * x + 2, 3) / 2;
	end
	self.HEATEaseInCirc = function (x)
		return 1 - math.sqrt(1 - math.pow(x, 2));
	end
	
	-- Callback when firing.
	self.HEATFireCallback = function (self)
		
	end
	
	-- Callback when a CC reload is finished, after variables are set.
	self.HEATDoneReloadingCallback = function (self)
		
	end

	-----------------
	----------------- Firing animation system
	-----------------
	
	-- Disable or enable the firing animation system.
	self.useHEATFiringAnimation = true;
	
	-- Final frame of the firing animation. Start frame is always 0.
	self.HEATFiringAnimationEndFrame = 1;
	-- Whether to set the PersistentFrame to the above EndFrame on the final shot of a magazine.
	-- Note that this can happily be overriden later by your callbacks.
	self.HEATLockBackOnEmpty = true;
	
	-----------------
	----------------- ParticleUtility firing smoke
	-----------------
	
	-- Disable or enable using the ParticleUtility for firing smoke FX.
	self.useHEATParticleUtilityFiringSmoke = true;
	
	-- Data to feed into the ParticleUtility. Read the ParticleUtility itself for information on these properties.
	self.HEATParticleUtilityFiringSmokeDataTable = {};
	self.HEATParticleUtilityFiringSmokeDataTable.Power = 80;
	self.HEATParticleUtilityFiringSmokeDataTable.Spread = 5;
	self.HEATParticleUtilityFiringSmokeDataTable.SmokeMult = 0.3;
	self.HEATParticleUtilityFiringSmokeDataTable.ExploMult = 1.5;
	self.HEATParticleUtilityFiringSmokeDataTable.WidthSpread = 2;
	self.HEATParticleUtilityFiringSmokeDataTable.VelocityMult = 0.4;
	self.HEATParticleUtilityFiringSmokeDataTable.LingerMult = 1.0;
	self.HEATParticleUtilityFiringSmokeDataTable.AirResistanceMult = 1.8;
	self.HEATParticleUtilityFiringSmokeDataTable.GravMult = 1;	
	
	-----------------
	----------------- CompliSound firing sound system
	-----------------
	
	-- Disable or enable the CompliSound system.
	self.useHEATCompliSound = true;
	
	-- CreateSoundContainer for your outdoors tail sound.
	self.HEATReflectionOutdoorsSound = CreateSoundContainer("Reflection Outdoors CED CED-BAS ADRS", "CED.rte");
	-- CreateSoundContainer for your indoors tail sound.
	self.HEATReflectionIndoorsSound = CreateSoundContainer("Reflection Indoors CED CED-BAS ADRS", "CED.rte");


	-----------------
	----------------- Staged reload system
	-----------------
	
	-- Disable or enable the entire staged reload system.
	self.useHEATReload = true;
	
	-- Whether to take away one round from the final reload when reloading from empty.
	self.HEATPlusOneChamberedRound = false;
	-- Your full magazine size, including the one in the chamber. This should be equal to the Magazine's RoundCount.
	self.HEATFullMagazineRoundCount = 1;
	
	-- Whether this becomes dual-reloadable when not emptied. Won't have an effect if you don't expect this to ever be dual-wielded.
	-- If you don't want the HEATSystem to meddle with this at all, leave it false.
	self.HEATDualReloadableIfNotEmpty = true;	
	
	-- Whether to trigger the reload staging after every shot, for pump-actions, bolt-actions, etcetera.
	self.HEATStageAfterEveryShot = false;
	-- Phase to go to if the above is true, and triggered during regular gunfire where the gun isn't emptied.
	-- Useful to skip your reloading first phase to go to, for example, a pumping second and third phase.
	self.HEATPhaseAfterFiringIfNotReloading = nil;
	
	-- Override for the ReloadTime when reloading with rounds still in the magazine.
	-- Autocalculated using endsIfNotEmptyReload if nil here. Relevant only for the progress bar.
	-- Make sure not to set these two variables lower than the actual time that will be taken or it will end the reload prematurely
	-- and break things.
	self.HEATTotalFullReloadTimeOverride = nil;
	-- Override for the ReloadTime when reloading from empty.
	-- Autocalculated using all phases if nil here. Relevant only for the progress bar.
	self.HEATTotalEmptyReloadTimeOverride = nil;
	
	-- Casing object to spawn on phases with spawnCasing.
	self.HEATCasing = nil;
	-- Position to spawn the casing at. Basically EjectionOffset. If nil here, will indeed use EjectionOffset. Don't include FlipFactor.
	self.HEATCasingOffset = nil;
	-- Velocity with which to spawn the casing.  Don't include FlipFactor.
	self.HEATCasingVelocity = nil;
	
	-- MOSRotating object to spawn on phases with removesMag.
	self.HEATFakeMagazineMOSRotating = nil;
	-- Position to spawn the object at.  Don't include FlipFactor.
	self.HEATFakeMagazineOffset = nil;
	-- Velocity with which to spawn the object.  Don't include FlipFactor.
	self.HEATFakeMagazineVelocity =nil;
	-- AngularVel to spawn the object with.  Don't include FlipFactor.
	self.HEATFakeMagazineAngularVel = 0;
	
	self.HEATReloadPhases = {};
	
	------------------------------------------------------------------------------
	
	local i = 1;
	local reloadPhase = {};
	-- Name of the reloadPhase. Used for organization only.
	reloadPhase.Name = "Open";
	-- Whether to remove the FakeMag and spawn a fake magazine object on this phase.
	reloadPhase.removesMag = false;
	-- Whether to trigger the FakeMag to be visible on the gun again this phase.
	reloadPhase.addsMag = false;
	-- Whether to consider this phase finished and progress to the next one (or a specified phase number)
	-- if the reload was interrupted after passing prepareDelay.
	reloadPhase.autoProgressIfFinishedButInterrupted = false;
	-- SoundContainer to play while preparing to finish this phase.
	reloadPhase.prepareSound = CreateSoundContainer("Open Prepare CED CED-BAS ADRS", "CED.rte");
	-- Time it takes to finish this phase.
	reloadPhase.prepareDelay = 600;
	-- Time before finishing that the prepareSound will play. You can line up short prepareSounds with long prepareDelays
	-- this way.
	reloadPhase.prepareSoundLength = 600;
	-- Sound upon finishing the phase.
	reloadPhase.afterSound = CreateSoundContainer("Open CED CED-BAS ADRS", "CED.rte");
	-- Time after finishing the phase before the reload is progressed.
	reloadPhase.afterDelay = 400;
	-- Absolute StanceOffset to set when in this phase.
	reloadPhase.reloadStanceOffsetTarget = Vector(0, 7);
	-- Speed at which SupportOffset moves when in this phase.
	reloadPhase.reloadSupportOffsetSpeed = 10;
	-- Absolute SupportOffset to set when in this phase. Note that low Speed can make this not be reached within the phase's lifetime.
	reloadPhase.reloadSupportOffsetTarget = Vector(9, -4)
	-- Rotation to set in this phase.
	reloadPhase.rotationTarget = 45;
	-- Strength of the rotational "kick" animation to do when this phase is finished.
	reloadPhase.angVel = 0;
	-- Strength of the horizontal "kick" animation to do when this phase is finished.
	reloadPhase.horizontalAnim = 1;
	-- Strength of the vertical "kick" animation to do when this phase is finished.
	reloadPhase.verticalAnim = 0;
	-- Whether to animate between the frames specified below, between this phase finishing and exiting.
	reloadPhase.autoAnimateFrames = false;
	-- Start frame of the auto animation.
	reloadPhase.startFrame = 0;
	-- End frame of the auto animation.
	reloadPhase.endFrame = 0;
	-- Whether to set the PersistentFrame to the endFrame above, which will persist even outside reloads until cleared by a finished reload.
	reloadPhase.setEndFrameAsPersistent = false;
	-- Easing function to use. You could define your own here if you really wanted.
	reloadPhase.easingFunction = self.HEATEaseLinear;
	-- Phase to restart the reload from if this phase is interrupted at any point.
	reloadPhase.phaseOnInterrupt = nil;
	-- Whether the reload ends at this phase, instead of progressing, if there were still rounds left in the magazine before a reload.
	reloadPhase.endIfNotEmptyReload = false;
	-- Whether this phase is a shotgun-style, looping, one-round-at-a-time reload.
	-- This will also trigger shotgun ammo counting and setting behavior and makes PlusOneChamberedRound irrelevant.
	reloadPhase.shotgunReloadLoop = false;
	-- Whether this phase spawns a casing when finished.
	reloadPhase.spawnCasing = false;
	-- Callback after this phase is entered and all default values are set.
	reloadPhase.enterPhaseCallback = function (self)

	end
	-- Callback done every frame of the reload, after value setting but before finish-specific behavior.
	reloadPhase.constantCallback = function (self)
		if self.HEATReloadTimer:IsPastSimMS(self.HEATCurrentReloadPhaseData.prepareDelay) then
			self.HEATCurrentReloadPhaseData.reloadSupportOffsetTarget = Vector(14, -4);
		end		
	end
	-- Callback once this phase is finished.
	reloadPhase.finishCallback = function (self)

	end
	-- Callback just before exiting the phase and deleting current phase data.
	reloadPhase.exitPhaseCallback = function (self)
		
	end
	
	self.HEATReloadPhases[i] = reloadPhase;
	
	------------------------------------------------------------------------------		
	
	local i = i + 1;
	local reloadPhase = {};
	reloadPhase.Name = "Fetch";
	reloadPhase.removesMag = false;
	reloadPhase.addsMag = false;
	reloadPhase.autoProgressIfFinishedButInterrupted = false;
	reloadPhase.prepareSound = CreateSoundContainer("Fetch Prepare CED CED-BAS ADRS", "CED.rte");
	reloadPhase.prepareDelay = 800;
	reloadPhase.prepareSoundLength = 800;
	reloadPhase.afterSound = nil;
	reloadPhase.afterDelay = 100;
	reloadPhase.reloadStanceOffsetTarget = Vector(0, 7);
	reloadPhase.reloadSupportOffsetSpeed = 10;
	reloadPhase.reloadSupportOffsetTarget = Vector(-15, -4)
	reloadPhase.rotationTarget = 50;
	reloadPhase.angVel = 0;
	reloadPhase.horizontalAnim = 0;
	reloadPhase.verticalAnim = 0;
	reloadPhase.autoAnimateFrames = false;
	reloadPhase.startFrame = 0;
	reloadPhase.endFrame = 0;
	reloadPhase.setEndFrameAsPersistent = false;
	reloadPhase.easingFunction = self.HEATEaseLinear;
	reloadPhase.phaseOnInterrupt = nil;
	reloadPhase.endIfNotEmptyReload = false;
	reloadPhase.shotgunReloadLoop = false;
	reloadPhase.spawnCasing = false;
	reloadPhase.enterPhaseCallback = function (self)
		
	end
	reloadPhase.constantCallback = function (self)
		if self.HEATReloadTimer:IsPastSimMS(self.HEATCurrentReloadPhaseData.prepareDelay / 1.2) then
			self.HEATCurrentReloadPhaseData.reloadSupportOffsetTarget = Vector(13, -1);
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
	reloadPhase.Name = "Insert";
	reloadPhase.removesMag = false;
	reloadPhase.addsMag = false;
	reloadPhase.autoProgressIfFinishedButInterrupted = true;
	reloadPhase.prepareSound = CreateSoundContainer("Insert Prepare CED CED-BAS ADRS", "CED.rte");
	reloadPhase.prepareDelay = 470;
	reloadPhase.prepareSoundLength = 470;
	reloadPhase.afterSound = CreateSoundContainer("Insert CED CED-BAS ADRS", "CED.rte");
	reloadPhase.afterDelay = 250;
	reloadPhase.reloadStanceOffsetTarget = Vector(0, 8);
	reloadPhase.reloadSupportOffsetSpeed = 16;
	reloadPhase.reloadSupportOffsetTarget = Vector(18, 0)
	reloadPhase.rotationTarget = 50;
	reloadPhase.angVel = 0;
	reloadPhase.horizontalAnim = -1;
	reloadPhase.verticalAnim = 0;
	reloadPhase.autoAnimateFrames = true;
	reloadPhase.startFrame = 1;
	reloadPhase.endFrame = 6;
	reloadPhase.setEndFrameAsPersistent = false;
	reloadPhase.easingFunction = self.HEATEaseLinear;
	reloadPhase.phaseOnInterrupt = 2;
	reloadPhase.endIfNotEmptyReload = false;
	reloadPhase.shotgunReloadLoop = false;
	reloadPhase.spawnCasing = false;
	reloadPhase.enterPhaseCallback = function (self)
	end
	reloadPhase.constantCallback = function (self)
		if self.HEATReloadTimer:IsPastSimMS(self.HEATCurrentReloadPhaseData.prepareDelay + self.HEATCurrentReloadPhaseData.afterDelay / 2) then
			self.HEATCurrentReloadPhaseData.reloadSupportOffsetTarget = Vector(12, 0);
		elseif self.HEATReloadTimer:IsPastSimMS(self.HEATCurrentReloadPhaseData.prepareDelay / 1.5) then
			self.HEATCurrentReloadPhaseData.reloadSupportOffsetTarget = Vector(16, 0);
			self.Frame = 2;
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
	reloadPhase.Name = "Close";
	reloadPhase.removesMag = false;
	reloadPhase.addsMag = false;
	reloadPhase.autoProgressIfFinishedButInterrupted = false;
	reloadPhase.prepareSound = CreateSoundContainer("Close Prepare CED CED-BAS ADRS", "CED.rte");
	reloadPhase.prepareDelay = 360;
	reloadPhase.prepareSoundLength = 360;
	reloadPhase.afterSound = CreateSoundContainer("Close CED CED-BAS ADRS", "CED.rte");
	reloadPhase.afterDelay = 400;
	reloadPhase.reloadStanceOffsetTarget = Vector(0, 7);
	reloadPhase.reloadSupportOffsetSpeed = 16;
	reloadPhase.reloadSupportOffsetTarget = Vector(13, -4)
	reloadPhase.rotationTarget = 35;
	reloadPhase.angVel = 0;
	reloadPhase.horizontalAnim = -1;
	reloadPhase.verticalAnim = 0;
	reloadPhase.autoAnimateFrames = true;
	reloadPhase.startFrame = 6;
	reloadPhase.endFrame = 6;
	reloadPhase.setEndFrameAsPersistent = true;
	reloadPhase.easingFunction = self.HEATEaseOutCubic;
	reloadPhase.phaseOnInterrupt = nil;
	reloadPhase.endIfNotEmptyReload = false;
	reloadPhase.shotgunReloadLoop = false;
	reloadPhase.spawnCasing = false;
	reloadPhase.enterPhaseCallback = function (self)
	
	end
	reloadPhase.constantCallback = function (self)
		
	end
	reloadPhase.finishCallback = function (self)
		self.HEATCurrentReloadPhaseData.reloadSupportOffsetTarget = Vector(8, -4);
	end
	reloadPhase.exitPhaseCallback = function (self)
		
	end
	
	self.HEATReloadPhases[i] = reloadPhase;
	
	------------------------------------------------------------------------------	
	
	i = i + 1;
	reloadPhase = {};
	reloadPhase.Name = "Lower";
	reloadPhase.removesMag = false;
	reloadPhase.addsMag = false;
	reloadPhase.autoProgressIfFinishedButInterrupted = false;
	reloadPhase.prepareSound = CreateSoundContainer("Lower Prepare CED CED-BAS ADRS", "CED.rte");
	reloadPhase.prepareDelay = 660;
	reloadPhase.prepareSoundLength = 660;
	reloadPhase.afterSound = CreateSoundContainer("Lower CED CED-BAS ADRS", "CED.rte");
	reloadPhase.afterDelay = 0;
	reloadPhase.reloadStanceOffsetTarget = Vector(0, 0);
	reloadPhase.reloadSupportOffsetSpeed = 6;
	reloadPhase.reloadSupportOffsetTarget = Vector(2, 5)
	reloadPhase.rotationTarget = 15;
	reloadPhase.angVel = 0;
	reloadPhase.horizontalAnim = 0;
	reloadPhase.verticalAnim = 0;
	reloadPhase.autoAnimateFrames = true;
	reloadPhase.startFrame = 6;
	reloadPhase.endFrame = 6;
	reloadPhase.setEndFrameAsPersistent = true;
	reloadPhase.easingFunction = self.HEATEaseOutCubic;
	reloadPhase.phaseOnInterrupt = nil;
	reloadPhase.endIfNotEmptyReload = false;
	reloadPhase.shotgunReloadLoop = false;
	reloadPhase.spawnCasing = false;
	reloadPhase.enterPhaseCallback = function (self)

	end
	reloadPhase.constantCallback = function (self)
		if self.HEATReloadTimer:IsPastSimMS(self.HEATCurrentReloadPhaseData.prepareDelay / 1.5) then
			self.HEATCurrentReloadPhaseData.rotationTargett = 0;
		end
	end
	reloadPhase.finishCallback = function (self)

	end
	reloadPhase.exitPhaseCallback = function (self)
		
	end
	
	self.HEATReloadPhases[i] = reloadPhase;

	------------------------------------------------------------------------------	
	
	-----------------
	----------------- Recoil system
	-----------------
	
	-- Whether to use the recoil system.
	self.useHEATRecoil = true;
	
	-- Strength of the horizontal "kick" animation when firing.
	self.HEATRecoilHorizontalAnim = 5;
	-- Strength of the rotational "kick" animation when firing.
	self.HEATRecoilAngAnim = 2;
	-- Variative multiplier for the rotational kick animation. A value of "0.1" here would give you anywhere from x0.95 to x1.05 the AngAnim.
	self.HEATRecoilAngVariation = 0;
	
	-- Strength of the recoil when firing. Affects rotation and SharpLength kickback.
	self.HEATRecoilStrength = 32
	-- Some sort of mathemagical strength value to affect the recoil.
	self.HEATRecoilPowStrength = 0.2
	-- Upper end of a random multiplier applied to the recoil. 1 is the lower end.
	self.HEATRecoilRandomUpper = 1
	-- Damping effect on the recoil - how fast it returns to normal.
	self.HEATRecoilDamping = 0.6
	
	-- Maximum rotation in degrees the recoil can cause.
	self.HEATRecoilMax = 0;
	-- Maximum low value for SharpLength as a multiplier.
	self.HEATSharpLengthMinimumMult = 0.8;
	-- Multiplier for recoil strength when proning.
	self.HEATRecoilProneMultiplier = 0.8;
	-- Multiplier for recoil strength when crouching.
	self.HEATRecoilCrouchMultiplier = 0.8;
	
	-----------------
	----------------- Delayed fire system
	-----------------
	
	-- Whether to enable the delayed fire system or not.
	self.useHEATDelayedFire = true;
	
	-- The sound to play when being activated, before firing.
	self.HEATPreSound = CreateSoundContainer("Pre CED CED-BAS ADRS", "CED.rte");
	-- Delay between being activated and firing.
	self.HEATDelayedFireTimeMS = 80;
end