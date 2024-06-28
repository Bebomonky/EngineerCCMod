function Create(self)
	self.HEATParent = nil;
	self.HEATParentSet = false;
	
	self.HEATLastAge = self.Age
	
	self.HEATOriginalSharpLength = self.SharpLength
	self.HEATOriginalStanceOffset = Vector(math.abs(self.StanceOffset.X), self.StanceOffset.Y)
	self.HEATOriginalSharpStanceOffset = Vector(self.SharpStanceOffset.X, self.SharpStanceOffset.Y)
	self.HEATOriginalSupportOffset = Vector(self.SupportOffset.X, self.SupportOffset.Y)
	
	self.HEATRotation = 0
	self.HEATRotationTarget = 0
	self.HEATRotationSpeed = 9
	self.HEATHorizontalAnim = 0
	self.HEATVerticalAnim = 0
	self.HEATAngVel = 0
	self.HEATLastRotAngle = self.RotAngle
	self.HEATLastHFlipped = self.HFlipped
	
	self.HEATReloadStanceOffset = Vector(0, 0);
	self.HEATReloadStanceOffsetTarget = Vector(0, 0)
	self.HEATReloadSupportOffsetSpeed = 16
	self.HEATReloadSupportOffsetTarget = Vector(0, 0);
	
	self.HEATReloadTimer = Timer();
	self.HEATCurrentReloadPhase = 1;
	
	self.HEATAmmoCounter = (self.Magazine and self.Magazine.RoundCount ~= self.HEATFullMagazineRoundCount) and self.Magazine.RoundCount or self.HEATFullMagazineRoundCount;
	
	self.HEATTotalFullReloadTime = self.HEATTotalFullReloadTimeOverride or nil;
	self.HEATTotalEmptyReloadTime = self.HEATTotalEmptyReloadTimeOverride or nil;
	
	-- Autocalculate best guesses
	-- Probably a neater way to do this without 2 loops...
	if not self.HEATTotalFullReloadTime then
		local totalFullTime = 0;
		for i = 1, #self.HEATReloadPhases do
			totalFullTime = totalFullTime + self.HEATReloadPhases[i].prepareDelay + self.HEATReloadPhases[i].afterDelay;
			if self.HEATReloadPhases[i].endIfNotEmptyReload then
				break;
			end
		end
		self.HEATTotalFullReloadTime = totalFullTime + 1;
	end
	if not self.HEATTotalEmptyReloadTime then
		local totalEmptyTime = 0;
		for i = 1, #self.HEATReloadPhases do
			totalEmptyTime = totalEmptyTime + self.HEATReloadPhases[i].prepareDelay + self.HEATReloadPhases[i].afterDelay;
		end	
		self.HEATTotalEmptyReloadTime = totalEmptyTime + 1;
	end
	
	self.BaseReloadTime = self.HEATTotalFullReloadTime;
	
	self.HEATFireDelayTimer = Timer();
	self.HEATDelayedFire = false
	self.HEATDelayedFireTimer = Timer();
	self.HEATDelayedFireActivated = false
	
	self.HEATFiringAnimationTimer = Timer();
end

function ThreadedUpdate(self)
	self.Frame = 0;
	self.HEATRotationTarget = 0
	
	if self.ID == self.RootID then
		self.HEATParent = nil;
		self.HEATParentSet = false;
	elseif self.HEATParentSet == false then
		local actor = MovableMan:GetMOFromID(self.RootID);
		if actor and IsAHuman(actor) then
			self.HEATParent = ToAHuman(actor);
			self.HEATParentSet = true;
		end
	end
	
    -- Smoothing
    local min_value = -math.pi;
    local max_value = math.pi;
    local value = self.RotAngle - self.HEATLastRotAngle
    local result;
    local ret = 0
    
    local range = max_value - min_value;
    if range <= 0 then
        result = min_value;
    else
        ret = (value - min_value) % range;
        if ret < 0 then ret = ret + range end
        result = ret + min_value;
    end
    
    self.HEATLastRotAngle = self.RotAngle
    self.HEATAngVel = (result / TimerMan.DeltaTimeSecs) * self.FlipFactor
    
    if self.HEATLastHFlipped ~= nil then
        if self.HEATLastHFlipped ~= self.HFlipped then
            self.HEATLastHFlipped = self.HFlipped
            self.HEATAngVel = 0
        end
    end
	
	-- Check if switched weapons/hide in the inventory, etc.
	if self.Age > (self.HEATLastAge + TimerMan.DeltaTimeSecs * 2000) then
		if self.HEATDelayedFire then
			self.HEATDelayedFire = false
		end
		self.HEATFireDelayTimer:Reset()
	end
	self.HEATLastAge = self.Age + 0
	
	-- SLIDE animation when firing
	-- don't ask, math magic
	local f = math.max(1 - math.min((self.HEATFiringAnimationTimer.ElapsedSimTimeMS) / 200, 1), 0)
	self.Frame = math.floor(f * 3 + 0.55);
	
	-- Reload system

	if self:IsReloading() or self.HEATStageWithoutReloading then
	
		self:Deactivate();
		
		local ctrl = self.HEATParent:GetController();
		local screen = ActivityMan:GetActivity():ScreenOfPlayer(ctrl.Player);

		self.HEATFireDelayTimer:Reset()
		self.HEATDelayedFireActivated = false;
		self.HEATDelayedFire = false;
		
		if not self.HEATCurrentReloadPhaseData then
			self.HEATCurrentReloadPhaseData = {};
			-- To support things in callbacks overriding values without overriding originals, we need a table copy:
			for k, v in pairs(self.HEATReloadPhases[self.HEATCurrentReloadPhase]) do
				self.HEATCurrentReloadPhaseData[k] = v;
			end	
		end
		
		if self.HEATWasInterrupted then
			self.HEATWasInterrupted = false;
			-- Autocalculate best guesses again so we can keep it accurate
			local totalTime = 0;
			if self.HEATEmptyReload and not self.HEATTotalEmptyReloadTimeOverride then
				for i = self.HEATCurrentReloadPhase, #self.HEATReloadPhases do
					totalTime = totalTime + self.HEATReloadPhases[i].prepareDelay + self.HEATReloadPhases[i].afterDelay;
				end	
				self.BaseReloadTime = totalTime + 1;
			elseif not self.HEATTotalFullReloadTimeOverride then
				for i = self.HEATCurrentReloadPhase, #self.HEATReloadPhases do
					totalTime = totalTime + self.HEATReloadPhases[i].prepareDelay + self.HEATReloadPhases[i].afterDelay;
					if self.HEATReloadPhases[i].endIfNotEmptyReload then
						break;
					end
				end
				self.BaseReloadTime = totalTime + 1;
			end
		end
				
		self.HEATReloadPhaseOnInterrupt = self.HEATCurrentReloadPhaseData.phaseOnInterrupt or nil;
		
		if self.HEATReloadTimer:IsPastSimMS(self.HEATCurrentReloadPhaseData.prepareDelay - self.HEATCurrentReloadPhaseData.prepareSoundLength) and self.HEATPrepareSoundPlayed ~= true then
			self.HEATPrepareSoundPlayed = true;
			if self.HEATCurrentReloadPhaseData.prepareSound then
				self.HEATCurrentReloadPhaseData.prepareSound:Play(self.Pos)
			end
		end
		
		self.Frame = self.HEATCurrentReloadPhaseData.startFrame;
		self.HEATRotationTarget = self.HEATCurrentReloadPhaseData.rotationTarget;
		
		self.HEATReloadStanceOffsetTarget = self.HEATCurrentReloadPhaseData.reloadStanceOffsetTarget;
		self.HEATReloadSupportOffsetSpeed = self.HEATCurrentReloadPhaseData.reloadSupportOffsetSpeed;
		self.HEATReloadSupportOffsetTarget = self.HEATCurrentReloadPhaseData.reloadSupportOffsetTarget;
		
		if self.HEATEnterPhaseCallbackDone ~= true then
			self.HEATEnterPhaseCallbackDone = true;
			self.HEATCurrentReloadPhaseData.enterPhaseCallback(self);
		end
		
		self.HEATCurrentReloadPhaseData.constantCallback(self);
	
		if self.HEATReloadTimer:IsPastSimMS(self.HEATCurrentReloadPhaseData.prepareDelay) then
		
			-- Frame animation
			if self.HEATCurrentReloadPhaseData.autoAnimateFrames then
				local progressFactor = (self.HEATReloadTimer.ElapsedSimTimeMS - self.HEATCurrentReloadPhaseData.prepareDelay) / self.HEATCurrentReloadPhaseData.afterDelay
				if progressFactor > 1 then
					progressFactor = 1;
				end			
			
				local frameChange = self.HEATCurrentReloadPhaseData.endFrame - self.HEATCurrentReloadPhaseData.startFrame
				self.Frame = math.floor(self.HEATCurrentReloadPhaseData.startFrame + math.floor(frameChange * progressFactor, 0.55))
			end
			
			if self.HEATParent:GetController():IsState(Controller.WEAPON_FIRE) then
				self.HEATReloadManuallyInterrupted = true;
			end		
			
			if self.HEATAfterSoundPlayed ~= true then
			
				if self.HEATCurrentReloadPhaseData.spawnCasing then
					local casing
					casing = self.HEATCasing:Clone();
					casing.Pos = self.Pos + Vector(self.HEATCasingOffset.X * self.FlipFactor, self.HEATCasingOffset.Y):RadRotate(self.RotAngle);
					casing.Vel = self.Vel + Vector(self.HEATCasingVelocity.X * self.FlipFactor, self.HEATCasingVelocity.Y):RadRotate(self.RotAngle);
					casing.RotAngle = self.RotAngle;
					casing.HFlipped = self.HFlipped;
					MovableMan:AddParticle(casing);
				end
			
				if self.HEATCurrentReloadPhaseData.removesMag and not self:NumberValueExists("HEAT_FakeMagRemoved") then
					self:SetNumberValue("HEAT_FakeMagRemoved", 1);
					local fakeMag
					fakeMag = self.HEATFakeMagazineMOSRotating:Clone();
					fakeMag.Pos = self.Pos + Vector(self.HEATFakeMagazineOffset.X * self.FlipFactor, self.HEATFakeMagazineOffset.Y):RadRotate(self.RotAngle);
					fakeMag.Vel = self.Vel + Vector(self.HEATFakeMagazineVelocity.X * self.FlipFactor, self.HEATFakeMagazineVelocity.Y):RadRotate(self.RotAngle);
					fakeMag.RotAngle = self.RotAngle;
					fakeMag.AngularVel = self.HEATFakeMagazineAngularVel * self.FlipFactor;
					fakeMag.HFlipped = self.HFlipped;
					MovableMan:AddParticle(fakeMag);
				elseif self.HEATCurrentReloadPhaseData.addsMag then
					self:RemoveNumberValue("HEAT_FakeMagRemoved");
				end				
			
				self.HEATAngVel = self.HEATAngVel + self.HEATCurrentReloadPhaseData.angVel;
				self.HEATHorizontalAnim = self.HEATHorizontalAnim + self.HEATCurrentReloadPhaseData.horizontalAnim;
				self.HEATVerticalAnim = self.HEATVerticalAnim + self.HEATCurrentReloadPhaseData.verticalAnim;
				
				if self.HEATCurrentReloadPhaseData.shotgunReloadLoop then
					self.HEATAmmoCounter = self.HEATAmmoCounter + 1;
					self.HEATApplyAmmoCount = true;		
				end
				
				if not self.HEATReloadPhaseOnInterrupt then
					if self.HEATCurrentReloadPhaseData.autoProgressIfFinishedButInterrupted and not ((not self.HEATEmptyReload) and self.HEATCurrentReloadPhaseData.endIfNotEmptyReload) then
						if type(self.HEATCurrentReloadPhaseData.autoProgressIfFinishedButInterrupted) == "number" then
							self.HEATReloadPhaseOnInterrupt = self.HEATCurrentReloadPhaseData.autoProgressIfFinishedButInterrupted;
						else
							self.HEATReloadPhaseOnInterrupt = self.HEATCurrentReloadPhase + 1;
						end
					end
				end		
			
				self.HEATAfterSoundPlayed = true;
				if self.HEATCurrentReloadPhaseData.afterSound then
					self.HEATCurrentReloadPhaseData.afterSound:Play(self.Pos);	
				end
				
			end
			
			if self.HEATReloadTimer:IsPastSimMS(self.HEATCurrentReloadPhaseData.prepareDelay + self.HEATCurrentReloadPhaseData.afterDelay) then
				self.HEATCurrentReloadPhaseData.finishCallback(self);
				self.HEATReloadTimer:Reset();
				self.HEATPrepareSoundPlayed = false;
				self.HEATAfterSoundPlayed = false;
				
				self.HEATEnterPhaseCallbackDone = false;
				
				if self.HEATForceEndReload then
					self.HEATCurrentReloadPhase = 1;
					self.HEATStageWithoutReloading = false;
					self.HEATReloadStanceOffsetTarget = Vector(0, 0);
					self.HEATReloadSupportOffsetTarget = Vector(0, 0);
					
					self.HEATReloadPhaseOnInterrupt = nil;
					
					self.BaseReloadTime = 0;
				
				elseif self.HEATReloadPhaseOverride then
					self.HEATCurrentReloadPhase = self.HEATReloadPhaseOverride;
				elseif self.HEATCurrentReloadPhaseData.shotgunReloadLoop and self.HEATAmmoCounter < self.HEATFullMagazineRoundCount then
					if self.HEATReloadManuallyInterrupted then
						
						self.HEATCurrentReloadPhase = 1;
						self.HEATStageWithoutReloading = false;
						self.HEATReloadStanceOffsetTarget = Vector(0, 0);
						self.HEATReloadSupportOffsetTarget = Vector(0, 0);
						
						self.HEATReloadPhaseOnInterrupt = nil;
						
						self.BaseReloadTime = 0;
					else
						-- repeat
					end
				elseif (not self.HEATEmptyReload and self.HEATCurrentReloadPhaseData.endIfNotEmptyReload)
				or self.HEATCurrentReloadPhaseData.shotgunReloadLoop and self.HEATAmmoCounter == self.HEATFullMagazineRoundCount then
					self.HEATCurrentReloadPhase = 1;
					self.HEATStageWithoutReloading = false;
					self.HEATReloadStanceOffsetTarget = Vector(0, 0);
					self.HEATReloadSupportOffsetTarget = Vector(0, 0);
					
					self.HEATReloadPhaseOnInterrupt = nil;
					
					self.BaseReloadTime = 0;
					
				elseif self.HEATReloadPhases[self.HEATCurrentReloadPhase + 1] == nil then
					self.HEATCurrentReloadPhase = 1;
					self.HEATStageWithoutReloading = false;
					self.HEATReloadStanceOffsetTarget = Vector(0, 0);
					self.HEATReloadSupportOffsetTarget = Vector(0, 0);
					
					self.HEATReloadPhaseOnInterrupt = nil;
					
					self.BaseReloadTime = 0;
				else
					self.HEATCurrentReloadPhase = self.HEATCurrentReloadPhase + 1;
				end
				
				self.HEATReloadPhaseOverride = nil;
				self.HEATForceEndReload = false;
				self.HEATReloadManuallyInterrupted = false;
				self.HEATCurrentReloadPhaseData.exitPhaseCallback(self);
				self.HEATCurrentReloadPhaseData = nil;			
			end
		end
	else
		if self.BaseReloadTime == 0 then
			self.BaseReloadTime = self.HEATTotalFullReloadTime;
		end
	
		self.HEATCurrentReloadPhaseData = nil;
		self.HEATPrepareSoundPlayed = false;
		self.HEATAfterSoundPlayed = false;
		
		self.HEATReloadTimer:Reset();
		if self.HEATReloadPhaseOnInterrupt then
			self.HEATCurrentReloadPhase = self.HEATReloadPhaseOnInterrupt;
			self.HEATReloadPhaseOnInterrupt = nil;
			self.HEATWasInterrupted = true;
		end
	
		self.HEATCurrentReloadPhaseData = nil;
		self.HEATPrepareSoundPlayed = false;
		self.HEATAfterSoundPlayed = false;	
		
	end
	
	if self:DoneReloading() == true then
		self.HEATFireDelayTimer:Reset()
		if self.HEATApplyAmmoCount then
			self.Magazine.RoundCount = self.HEATAmmoCounter;
		else
			self.Magazine.RoundCount = self.HEATFullMagazineRoundCount;
			if self.HEATEmptyReload and self.HEATPlusOneChamberedRound then
				self.HEATEmptyReload = false;
				self.Magazine.RoundCount = math.max(1, self.Magazine.RoundCount - 1);
			end
		end
	end	

	-- Delayed fire system
	
	if self.useHEATDelayedFire then
		local fire = self:IsActivated() and self.RoundInMagCount > 0;
		if self.RoundInMagCount > 0 then
			self:Deactivate()
		end

		if self.HEATParent and self.HEATDelayedFirstShot == true then
			
			--if self.parent:GetController():IsState(Controller.WEAPON_FIRE) and not self:IsReloading() then
			if fire and not self:IsReloading() then
				if not self.Magazine or self.Magazine.RoundCount < 1 then
					--self:Reload()
					self:Activate()
				elseif not self.activated and not self.HEATDelayedFire and self.HEATFireDelayTimer:IsPastSimMS(1 / (self.RateOfFire / 60) * 1000) then
					self.HEATDelayedFireActivated = true
					
					if self.HEATPreSound then
						self.HEATPreSound:Play(self.Pos);
					end
					
					self.HEATFireDelayTimer:Reset()
					
					self.HEATDelayedFire = true
					self.HEATDelayedFireTimer:Reset()
				end
			else
				if self.HEATDelayedFireActivated then
					self.HEATDelayedFireActivated = false
				end
			end
		elseif fire == false then
			self.HEATDelayedFirstShot = true;
		end
	end
	
	if self.FiredFrame then
	
		self.HEATAmmoCounter = self.HEATAmmoCounter - 1;
	
		self.HEATHorizontalAnim = self.HEATRecoilHorizontalAnim;
		self.HEATFiringAnimationTimer:Reset();
	
		self.HEATAngVel = self.HEATAngVel - RangeRand(1 - self.HEATRecoilAngVariation / 2, 1 + self.HEATRecoilAngVariation / 2) * self.HEATRecoilAngAnim
		
		if self.HEATStageAfterEveryShot then
			self.HEATStageWithoutReloading = true;
		end
		
		if self.RoundInMagCount > 0 then
		else
			self.HEATEmptyReload = true;
			self.BaseReloadTime = self.HEATTotalEmptyReloadTime;
		end
		
		for i = 1, 3 do
			local Effect = CreateMOSParticle("Tiny Smoke Ball 1", "Base.rte")
			if Effect then
				Effect.Pos = self.MuzzlePos;
				Effect.Vel = (self.Vel + Vector(RangeRand(-20,20), RangeRand(-20,20)) + Vector(150*self.FlipFactor,0):RadRotate(self.RotAngle)) / 30
				MovableMan:AddParticle(Effect)
			end
		end
		
		local Effect = CreateMOSParticle("Side Thruster Blast Ball 1", "Base.rte")
		if Effect then
			Effect.Pos = self.MuzzlePos;
			Effect.Vel = (self.Vel + Vector(150*self.FlipFactor,0):RadRotate(self.RotAngle)) / 10
			MovableMan:AddParticle(Effect)
		end

		local outdoorRays = 0;
		local indoorRays = 0;
		local bigIndoorRays = 0;
		
		local rayThreshold = 2;

		if self.HEATParent and self.HEATParent:IsPlayerControlled() then
			local Vector2 = Vector(0,-700); -- straight up
			local Vector2Left = Vector(0,-700):RadRotate(45*(math.pi/180));
			local Vector2Right = Vector(0,-700):RadRotate(-45*(math.pi/180));			
			local Vector2SlightLeft = Vector(0,-700):RadRotate(22.5*(math.pi/180));
			local Vector2SlightRight = Vector(0,-700):RadRotate(-22.5*(math.pi/180));		
			local Vector3 = Vector(0,0); -- dont need this but is needed as an arg
			local Vector4 = Vector(0,0); -- dont need this but is needed as an arg

			self.ray = SceneMan:CastObstacleRay(self.Pos, Vector2, Vector3, Vector4, self.RootID, self.Team, 128, 7);
			self.rayRight = SceneMan:CastObstacleRay(self.Pos, Vector2Right, Vector3, Vector4, self.RootID, self.Team, 128, 7);
			self.rayLeft = SceneMan:CastObstacleRay(self.Pos, Vector2Left, Vector3, Vector4, self.RootID, self.Team, 128, 7);			
			self.raySlightRight = SceneMan:CastObstacleRay(self.Pos, Vector2SlightRight, Vector3, Vector4, self.RootID, self.Team, 128, 7);
			self.raySlightLeft = SceneMan:CastObstacleRay(self.Pos, Vector2SlightLeft, Vector3, Vector4, self.RootID, self.Team, 128, 7);
			
			self.rayTable = {self.ray, self.rayRight, self.rayLeft, self.raySlightRight, self.raySlightLeft};
		else
			rayThreshold = 1; -- has to be different for AI
			local Vector2 = Vector(0,-700); -- straight up
			local Vector3 = Vector(0,0); -- dont need this but is needed as an arg
			local Vector4 = Vector(0,0); -- dont need this but is needed as an arg		
			self.ray = SceneMan:CastObstacleRay(self.Pos, Vector2, Vector3, Vector4, self.RootID, self.Team, 128, 7);
			
			self.rayTable = {self.ray};
		end
		
		for _, rayLength in ipairs(self.rayTable) do
			if rayLength < 0 then
				outdoorRays = outdoorRays + 1;
			elseif rayLength > 170 then
				bigIndoorRays = bigIndoorRays + 1;
			else
				indoorRays = indoorRays + 1;
			end
		end
		
		if outdoorRays >= rayThreshold then
			self.HEATReflectionOutdoorsSound:Play(self.Pos);
		else
			self.HEATReflectionIndoorsSound:Play(self.Pos);
		end
		
		self.HEATFireCallback(self);
		
	end
	
	if self.HEATDelayedFire and self.HEATDelayedFireTimer:IsPastSimMS(self.HEATDelayedFireTimeMS) then
		self:Activate()	
		self.HEATDelayedFire = false
		self.HEATDelayedFirstShot = false;
	end
	
	-- Animation
	if self.HEATParent then
		self.HEATHorizontalAnim = math.floor(self.HEATHorizontalAnim / (1 + TimerMan.DeltaTimeSecs * 24.0) * 1000) / 1000
		self.HEATVerticalAnim = math.floor(self.HEATVerticalAnim / (1 + TimerMan.DeltaTimeSecs * 15.0) * 1000) / 1000
		
		local stance = Vector()
		stance = stance + Vector(-1,0) * self.HEATHorizontalAnim -- Horizontal animation
		stance = stance + Vector(0,5) * self.HEATVerticalAnim -- Vertical animation
		
		self.HEATRotationTarget = self.HEATRotationTarget - (self.HEATAngVel * 4)
		
		if self.FiredFrame then
			self.HEATRecoilStr = self.HEATRecoilStr + ((math.random(10, self.HEATRecoilRandomUpper * 10) / 10) * 0.5 * self.HEATRecoilStrength) + (self.HEATRecoilStr * 0.6 * self.HEATRecoilPowStrength)
			self:SetNumberValue("recoilStrengthBase", self.HEATRecoilStrength * (1 + self.HEATRecoilPowStrength) / self.HEATRecoilDamping)
		end
		self:SetNumberValue("recoilStrengthCurrent", self.HEATRecoilStr)
		
		self.HEATRecoilStr = math.floor(self.HEATRecoilStr / (1 + TimerMan.DeltaTimeSecs * 8.0 * self.HEATRecoilDamping) * 1000) / 1000
		self.HEATRecoilAcc = (self.HEATRecoilAcc + self.HEATRecoilStr * TimerMan.DeltaTimeSecs) % (math.pi * 4)
		
		local recoilA = (math.sin(self.HEATRecoilAcc) * self.HEATRecoilStr) * 0.05 * self.HEATRecoilStr
		local recoilB = (math.sin(self.HEATRecoilAcc * 0.5) * self.HEATRecoilStr) * 0.01 * self.HEATRecoilStr
		local recoilC = (math.sin(self.HEATRecoilAcc * 0.25) * self.HEATRecoilStr) * 0.05 * self.HEATRecoilStr
		
		local recoilFinal = math.max(math.min(recoilA + recoilB + recoilC, self.HEATRecoilMax), -self.HEATRecoilMax)
		
		self.SharpLength = math.max(self.HEATOriginalSharpLength - (self.HEATRecoilStr * 3 + math.abs(recoilFinal)), 0)
		
		self.HEATRotationTarget = self.HEATRotationTarget + recoilFinal -- apply the recoil	
		
		self.HEATRotation = (self.HEATRotation + self.HEATRotationTarget * TimerMan.DeltaTimeSecs * self.HEATRotationSpeed) / (1 + TimerMan.DeltaTimeSecs * self.HEATRotationSpeed)
		if self:IsReloading() or self.HEATStageWithoutReloading then
			self.SupportOffset = self.SupportOffset + ((self.HEATReloadSupportOffsetTarget - self.SupportOffset) * TimerMan.DeltaTimeSecs * self.HEATReloadSupportOffsetSpeed)
		else
			self.SupportOffset = self.HEATOriginalSupportOffset;
		end
		local total = math.rad(self.HEATRotation) * self.FlipFactor
		
		self.InheritedRotAngleOffset = total * self.FlipFactor;
		-- self.RotAngle = self.RotAngle + total;
		-- self:SetNumberValue("MagRotation", total);
		
		-- local jointOffset = Vector(self.JointOffset.X * self.FlipFactor, self.JointOffset.Y):RadRotate(self.RotAngle);
		-- local offsetTotal = Vector(jointOffset.X, jointOffset.Y):RadRotate(-total) - jointOffset
		-- self.Pos = self.Pos + offsetTotal;
		-- self:SetNumberValue("MagOffsetX", offsetTotal.X);
		-- self:SetNumberValue("MagOffsetY", offsetTotal.Y);
		
		if self.HEATReloadStanceOffsetTarget then
			self.HEATReloadStanceOffset = self.HEATReloadStanceOffset + ((self.HEATReloadStanceOffsetTarget - self.HEATReloadStanceOffset) * TimerMan.DeltaTimeSecs * 2.5)
			self.StanceOffset = Vector(self.HEATOriginalStanceOffset.X, self.HEATOriginalStanceOffset.Y) + stance + self.HEATReloadStanceOffset
			self.SharpStanceOffset = Vector(self.HEATOriginalSharpStanceOffset.X, self.HEATOriginalSharpStanceOffset.Y) + stance + self.HEATReloadStanceOffset;
		else
			self.HEATReloadStanceOffset = Vector(0, 0)
			self.StanceOffset = Vector(self.HEATOriginalStanceOffset.X, self.HEATOriginalStanceOffset.Y) + stance
			self.SharpStanceOffset = Vector(self.HEATOriginalSharpStanceOffset.X, self.HEATOriginalSharpStanceOffset.Y) + stance
		end
	end
end