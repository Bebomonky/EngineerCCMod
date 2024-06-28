function Create(self)

	self.parentSet = false;
	
	-- Sounds --
	
	self.reflectionOutdoorsSound = CreateSoundContainer("ReflectionOutdoors NCBTB", "Frostbite.rte");
	self.reflectionIndoorsSound = CreateSoundContainer("ReflectionIndoors NCBTB", "Frostbite.rte");
	
	self.reloadPrepareSounds = {}
	self.reloadPrepareSounds.Raise = nil;
	self.reloadPrepareSounds.BoltBack = nil;
	self.reloadPrepareSounds.FirstRoundIn = CreateSoundContainer("FirstRoundInPrepare NCBTB", "Frostbite.rte");
	self.reloadPrepareSounds.FirstRoundInBoltForward = nil;
	self.reloadPrepareSounds.RoundIn = nil;
	self.reloadPrepareSounds.BoltForward = nil;
	
	self.reloadPrepareLengths = {}
	self.reloadPrepareLengths.Raise = 0
	self.reloadPrepareLengths.BoltBack = 0
	self.reloadPrepareLengths.FirstRoundIn = 280
	self.reloadPrepareLengths.FirstRoundInBoltForward = 0
	self.reloadPrepareLengths.RoundIn = 0
	self.reloadPrepareLengths.BoltForward = 0
	
	self.reloadPrepareDelay = {}
	self.reloadPrepareDelay.Raise = 50
	self.reloadPrepareDelay.BoltBack = 200
	self.reloadPrepareDelay.FirstRoundIn = 600
	self.reloadPrepareDelay.FirstRoundInBoltForward = 300
	self.reloadPrepareDelay.RoundIn = 450
	self.reloadPrepareDelay.BoltForward = 200
	
	self.reloadAfterSounds = {}
	self.reloadAfterSounds.Raise = CreateSoundContainer("Raise NCBTB", "Frostbite.rte");
	self.reloadAfterSounds.BoltBack = CreateSoundContainer("BoltBack NCBTB", "Frostbite.rte");
	self.reloadAfterSounds.FirstRoundIn = CreateSoundContainer("FirstRoundIn NCBTB", "Frostbite.rte");
	self.reloadAfterSounds.FirstRoundInBoltForward = CreateSoundContainer("BoltForward NCBTB", "Frostbite.rte");
	self.reloadAfterSounds.RoundIn = CreateSoundContainer("RoundIn NCBTB", "Frostbite.rte");
	self.reloadAfterSounds.BoltForward = CreateSoundContainer("BoltForward NCBTB", "Frostbite.rte");
	
	self.reloadAfterDelay = {}
	self.reloadAfterDelay.Raise = 450
	self.reloadAfterDelay.BoltBack = 200
	self.reloadAfterDelay.FirstRoundIn = 300
	self.reloadAfterDelay.FirstRoundInBoltForward = 400
	self.reloadAfterDelay.RoundIn = 380
	self.reloadAfterDelay.BoltForward = 350
	
	self.BaseReloadTimer = Timer();
	
	self.reloadPhase = 0;
	
	self.BaseReloadTime = 12000;

	self.parentSet = false;
	
	self.rotation = 0
	self.rotationTarget = 0
	self.rotationSpeed = 6
	
	self.reloadSupportOffsetTarget = Vector(0, 0);
	self.reloadSupportOffsetSpeed = 20
	
	self.reloadingVector = Vector(0, 0)
	
	self.horizontalAnim = 0
	self.verticalAnim = 0
	
	self.angVel = 0
	self.lastRotAngle = (self.RotAngle + self.InheritedRotAngleOffset)
	
	self.originalSharpLength = self.SharpLength
	
	self.originalStanceOffset = Vector(math.abs(self.StanceOffset.X), self.StanceOffset.Y)
	self.originalSharpStanceOffset = Vector(self.SharpStanceOffset.X, self.SharpStanceOffset.Y)
	
	self.originalJointOffset = Vector(self.JointOffset.X, self.JointOffset.Y)
	self.originalSupportOffset = Vector(math.abs(self.SupportOffset.X), self.SupportOffset.Y)
	
	self.FireTimer = Timer();
	
	self.GFXTimer = Timer();
	self.GFXDelay = 50;
	
	self.heatNum = 0;
	
	self.ammoCount = 6
	
	-- Progressive Recoil System 
	self.recoilAcc = 0 -- for sinous
	self.recoilStr = 0 -- for accumulator
	self.recoilStrength = 29 -- multiplier for base recoil added to the self.recoilStr when firing
	self.recoilPowStrength = 0.2 -- multiplier for self.recoilStr when firing
	self.recoilRandomUpper = 1.1 -- upper end of random multiplier (1 is lower)
	self.recoilDamping = 0.6
	
	self.recoilMax = 4 -- in deg.
	self.originalSharpLength = self.SharpLength
	
end

function Update(self)
	self.rotationTarget = 0 -- ZERO IT FIRST AAAA!!!!!
	
	if self.ID == self.RootID then
		self.parent = nil;
		self.parentSet = false;
	elseif self.parentSet == false then
		local actor = MovableMan:GetMOFromID(self.RootID);
		if actor and IsAHuman(actor) then
			self.parent = ToAHuman(actor);
			self.parentSet = true;
		end
	end
	
    -- Smoothing
    local min_value = -math.pi;
    local max_value = math.pi;
    local value = self.RotAngle - self.lastRotAngle
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
    
    self.lastRotAngle = self.RotAngle
    self.angVel = (result / TimerMan.DeltaTimeSecs) * self.FlipFactor
    
    if self.lastHFlipped ~= nil then
        if self.lastHFlipped ~= self.HFlipped then
            self.lastHFlipped = self.HFlipped
            self.angVel = 0
        end
    else
        self.lastHFlipped = self.HFlipped
    end
	

	if self.reChamber then
		if self:IsReloading() then
			self.Reloading = true;
			self.reloadCycle = true;
			if self.ammoCount == 0 then
				self.reloadPhase = 0;
			else
				self.reloadPhase = 0;
			end
		end
		self.reChamber = false;
		self.Chamber = true;
	end
	
	if self:IsReloading() and (not self.Chamber) then -- if we start reloading from "scratch"
		self.Chamber = true;
		self.BaseReloadTime = 19999;
		self.Reloading = true;
		self.reloadCycle = true;
		self.reloadPhase = 0;
	end
	
	if self.parent then
	
		local ctrl = self.parent:GetController();
		local screen = ActivityMan:GetActivity():ScreenOfPlayer(ctrl.Player);
		
		if self.resumeReload then
			self:Reload();
			self.resumeReload = false;
			if self.reloadPhase == 4 and self.ammoCount == 6 then
				self.reloadPhase = 5;
			end
		end
		if self.Chamber then
			self:Deactivate();
			if self:IsReloading() then
				
				-- -- Fancy Reload Progress GUI
				-- if not (not self.reloadCycle and self.parent:GetController():IsState(Controller.WEAPON_FIRE)) and self.parent:IsPlayerControlled() then
					-- for i = 1, self.ammoCount do
						-- local color = 120
						-- local spacing = 4
						-- local offset = Vector(0 - spacing * 0.5 + spacing * (i) - spacing * self.ammoCount / 2, (self.ammoCountRaised and i == self.ammoCount) and 35 or 36)
						-- local position = self.parent.AboveHUDPos + offset
						-- PrimitiveMan:DrawCirclePrimitive(position + Vector(0,-2), 1, color);
						-- PrimitiveMan:DrawLinePrimitive(position + Vector(1,-3), position + Vector(1,3), color);
						-- PrimitiveMan:DrawLinePrimitive(position + Vector(-1,-3), position + Vector(-1,3), color);
						-- PrimitiveMan:DrawLinePrimitive(position + Vector(1,3), position + Vector(-1,3), color);
					-- end
				-- end
				
				if self.Reloading == false then
					self.reloadCycle = true;
					self.BaseReloadTime = 19999;
					self.Reloading = true;
					-- self.BaseReloadTimer:Reset();
					-- self.prepareSoundPlayed = false;
					-- self.afterSoundPlayed = false;
				end
				
			else
				self.Reloading = false;
			end
			
			
			if self.reloadPhase == 0 then
			
				self.reloadSupportOffsetSpeed = 8
			
				self.reloadSupportOffsetTarget = Vector(2, 2)
			
				self.reloadDelay = self.reloadPrepareDelay.Raise;
				self.afterDelay = self.reloadAfterDelay.Raise;		
				
				self.prepareSound = self.reloadAfterSounds.Raise;
				self.prepareSoundLength = self.reloadAfterSounds.Raise;
				self.afterSound = self.reloadAfterSounds.Raise;
				
				self.reloadingVectorTarget = Vector(-1, -1);
				self.rotationTarget = 30;
			
			elseif self.reloadPhase == 1 then
			
				self.reloadSupportOffsetSpeed = 10
			
				self.reloadSupportOffsetTarget = Vector(-1, 2)
			
				self.reloadDelay = self.fasterPump and self.reloadPrepareDelay.BoltBack / 2 or self.reloadPrepareDelay.BoltBack;
				self.afterDelay = self.reloadAfterDelay.BoltBack;		
				
				self.prepareSound = self.reloadPrepareSounds.BoltBack;
				self.prepareSoundLength = self.reloadPrepareLengths.BoltBack;
				self.afterSound = self.reloadAfterSounds.BoltBack;
				
				if self:IsReloading() then
					self.rotationTarget = (30 * self.BaseReloadTimer.ElapsedSimTimeMS / (self.reloadDelay + self.afterDelay))
				else
					self.rotationTarget = (20 * self.BaseReloadTimer.ElapsedSimTimeMS / (self.reloadDelay + self.afterDelay))
				end
				
			elseif self.reloadPhase == 2 then
			
				self.reloadSupportOffsetSpeed = 3
			
				self.reloadSupportOffsetTarget = Vector(-5, -1)

				self.reloadDelay = self.reloadPrepareDelay.FirstRoundIn;
				self.afterDelay = self.reloadAfterDelay.FirstRoundIn;		
				
				self.prepareSound = self.reloadPrepareSounds.FirstRoundIn;
				self.prepareSoundLength = self.reloadPrepareLengths.FirstRoundIn;
				self.afterSound = self.reloadAfterSounds.FirstRoundIn;
				
				self.rotationTarget = 27
				
			elseif self.reloadPhase == 3 then
			
				self.reloadSupportOffsetSpeed = 10
			
				self.reloadSupportOffsetTarget = Vector(-1, 2)
			
				self.reloadDelay = self.reloadPrepareDelay.FirstRoundInBoltForward;
				self.afterDelay = self.reloadAfterDelay.FirstRoundInBoltForward;		
				
				self.prepareSound = nil;
				self.prepareSoundLength = nil;
				self.afterSound = self.reloadAfterSounds.FirstRoundInBoltForward;
				
				self.rotationTarget = 32
				
			elseif self.reloadPhase == 4 then
			
				self.reloadSupportOffsetSpeed = 10
			
				self.reloadSupportOffsetTarget = Vector(-4, 5)
			
				self.reloadDelay = self.reloadPrepareDelay.RoundIn;
				self.afterDelay = self.reloadAfterDelay.RoundIn;		
				
				self.prepareSound = self.reloadPrepareSounds.RoundIn;
				self.prepareSoundLength = self.reloadPrepareLengths.RoundIn;
				self.afterSound = self.reloadAfterSounds.RoundIn;
				
				self.rotationTarget = 15 + (5 * self.BaseReloadTimer.ElapsedSimTimeMS / (self.reloadDelay + self.afterDelay))
				
			elseif self.reloadPhase == 5 then
			
				self.reloadSupportOffsetTarget = Vector(-1, 2)

				self.reloadDelay = self.fasterPump and self.reloadPrepareDelay.BoltForward / 2 or self.reloadPrepareDelay.BoltForward;
				self.afterDelay = self.fasterPump and self.reloadAfterDelay.BoltForward / 2 or self.reloadAfterDelay.BoltForward;	
				
				self.prepareSound = nil;
				self.prepareSoundLength = nil;
				self.afterSound = self.reloadAfterSounds.BoltForward;
				
				self.rotationTarget = -5
				
			end
			
			if self.prepareSoundPlayed ~= true then
				self.prepareSoundPlayed = true;
				if self.prepareSound then
					self.prepareSound:Play(self.Pos);
				end
			end
			
			if self.BaseReloadTimer:IsPastSimMS(self.reloadDelay) then
				--[[
				if self.reloadPhase == 0 and self.Casing then
					local shell
					shell = CreateMOSParticle("Shell Shotgun");
					shell.Pos = self.Pos+Vector(0,-3):RadRotate(self.RotAngle);
					shell.Vel = self.Vel+Vector(-math.random(2,4)*self.FlipFactor,-math.random(3,4)):RadRotate(self.RotAngle);
					MovableMan:AddParticle(shell);
					
					self.Casing = false
				end]]
				-- if self.reloadPhase == 0 then
					-- self.horizontalAnim = self.horizontalAnim + TimerMan.DeltaTimeSecs * self.afterDelay
				-- end
			
				self.phasePrepareFinished = true;
			
				if self.afterSoundPlayed ~= true then
					if self.reloadPhase == 2 or self.reloadPhase == 4 then
						self.horizontalAnim = self.horizontalAnim + 1
						self.verticalAnim = self.verticalAnim - 1
					end
				
					self.afterSoundPlayed = true;
					if self.afterSound then
						self.afterSound:Play(self.Pos);
					end
				end
			
				if self.reloadPhase == 1 then
				
					self.BoltBacked = true;
					
					if self.BaseReloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.5)) then
						self.Frame = 3;
					elseif self.BaseReloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1)) then
						self.Frame = 2;
					elseif self.BaseReloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*0.5)) then
						self.Frame = 1;
						self.reloadSupportOffsetTarget = Vector(-1, 2)
					end
					
				elseif self.reloadPhase == 2 then
				
					if self.parent:GetController():IsState(Controller.WEAPON_FIRE) then
						self.reloadCycle = false;
						PrimitiveMan:DrawTextPrimitive(screen, self.parent.AboveHUDPos + Vector(0, 30), "Interrupting...", true, 1);
					end
					
					self.Frame = 4;
				
					if self.ammoCountRaised ~= true then
						self.ammoCountRaised = true;
						if self.ammoCount < 7 then
							self.ammoCount = self.ammoCount + 1;
							if self.ammoCount == 7 then
								self.reloadCycle = false;
							end
						else
							self.reloadCycle = false;
						end
					end
					
					self.phaseOnStop = 2;
					
				elseif self.reloadPhase == 3 then
				
					self.BoltBacked = false;
					
					if self.BaseReloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*2.0)) then
						self.Frame = 0;
						self.reloadSupportOffsetTarget = Vector(2, 2)
					elseif self.BaseReloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.5)) then
						self.Frame = 7;
						self.reloadSupportOffsetTarget = Vector(2, 2)
					elseif self.BaseReloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.0)) then
						self.Frame = 6;
						self.reloadSupportOffsetTarget = Vector(2, 2)
					elseif self.BaseReloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*0.5)) then
						self.Frame = 5;
						self.reloadSupportOffsetTarget = Vector(2, 2)
					else
						self.Frame = 4;
					end
					
				elseif self.reloadPhase == 4 then
					
					self.phaseOnStop = 3;
					
					if self.BaseReloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*2.0)) then
						self.reloadSupportOffsetTarget = Vector(-3, 2)
					end
				
					if self.parent:GetController():IsState(Controller.WEAPON_FIRE) then
						self.reloadCycle = false;
						PrimitiveMan:DrawTextPrimitive(screen, self.parent.AboveHUDPos + Vector(0, 30), "Interrupting...", true, 1);
					end

					if self.ammoCountRaised ~= true then
						self.ammoCountRaised = true;
						if self.ammoCount < 7 then
							self.ammoCount = self.ammoCount + 1;
							if self.ammoCount == 7 then
								self.reloadCycle = false;
							end
						else
							self.reloadCycle = false;
						end
					end

				elseif self.reloadPhase == 5 then
				
					self.BoltBacked = false;
					
					if self.BaseReloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*2)) then
						self.Frame = 0;
						self.reloadSupportOffsetTarget = Vector(2, 2)
					elseif self.BaseReloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.5)) then
						self.Frame = 1;
						self.reloadSupportOffsetTarget = Vector(2, 2)
					elseif self.BaseReloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1)) then
						self.Frame = 2;
						self.reloadSupportOffsetTarget = Vector(2, 2)
					elseif self.BaseReloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*0.5)) then
						self.Frame = 3;
						self.reloadSupportOffsetTarget = Vector(2, 2)
					end

				end
				
				if self.BaseReloadTimer:IsPastSimMS(self.reloadDelay + self.afterDelay) then
					self.BaseReloadTimer:Reset();
					self.prepareSoundPlayed = false;
					self.afterSoundPlayed = false;
					
					
					if self.reloadPhase == 0 then
					
						if self.BoltBacked then
							if self.breechShellReload then
								self.reloadPhase = 2
							else
								self.reloadPhase = 5;
							end
						elseif self.breechShellReload == false and self.ammoCount < 7 then
							self.reloadPhase = 4;
						else
							self.reloadPhase = self.reloadPhase + 1;
						end
						
					elseif self.reloadPhase == 1 then

						if not self:IsReloading() then
							self.reloadPhase = 5;
						elseif self.breechShellReload == true then
							self.reloadPhase = self.reloadPhase + 1;
						else
							self.reloadPhase = 5;
						end
						if self.Casing then
							local shell
							shell = CreateAEmitter("Shell NCBTB", "Frostbite.rte");
							shell.Pos = self.Pos+Vector(-3 * self.FlipFactor,-1):RadRotate(self.RotAngle);
							shell.Vel = self.Vel+Vector(-math.random(2,4)*self.FlipFactor,-math.random(3,4)):RadRotate(self.RotAngle);
							shell.RotAngle = self.RotAngle
							shell.HFlipped = self.HFlipped
							MovableMan:AddParticle(shell);
							
							self.Casing = false
						end
					
					elseif self.reloadPhase == 2 then
					
						self.ammoCountRaised = false;
					
						self.reloadPhase = self.reloadPhase + 1;
						
					elseif self.reloadPhase == 3 then
					
						if self.reloadCycle then
							self.reloadPhase = 4; -- same phase baby the ride never ends (except at 4 rounds)
						else
							self.BaseReloadTime = 0;
							self.reloadPhase = 0;
							self.Chamber = false;
							self.Reloading = false;
							self.phaseOnStop = nil;
						end
						
					elseif self.reloadPhase == 4 then
					
						self.ammoCountRaised = false;
					
						if self.reloadCycle then
							self.reloadPhase = 4; -- same phase baby the ride never ends (except at 4 rounds)
						else
							self.BaseReloadTime = 0;
							self.reloadPhase = 0;
							self.Chamber = false;
							self.Reloading = false;
							self.phaseOnStop = nil;
						end
					
					elseif self.reloadPhase == 5 then
					
						self.fasterPump = false;
					
						if self:IsReloading() then
							if self.ammoCount < 7 then
								self.reloadPhase = 4;
							else
								self.BaseReloadTime = 0;
								self.reloadPhase = 0;
								self.Chamber = false;
								self.Reloading = false;
								self.phaseOnStop = nil;
								self.reloadSupportOffsetTarget = self.originalSupportOffset;
							end
						else
							self.BaseReloadTime = 0;
							self.reloadPhase = 0;
							self.Chamber = false;
							self.Reloading = false;
							self.phaseOnStop = nil;
							self.reloadSupportOffsetTarget = self.originalSupportOffset;
						end
						
					else
						self.reloadPhase = self.reloadPhase + 1;
					end
				end				
			else
				self.phasePrepareFinished = false;
			end
			
		else
		
			local f = math.max(1 - math.min((self.FireTimer.ElapsedSimTimeMS - 25) / 200, 1), 0)
			self.JointOffset = self.originalJointOffset + Vector(1, 0) * f
			
			self.BaseReloadTimer:Reset();
			self.prepareSoundPlayed = false;
			self.afterSoundPlayed = false;
			self.BaseReloadTime = 19999;
		end		
	
	else
		self.BaseReloadTimer:Reset();
	end
	
	if self:DoneReloading() then
		self.breechShellReload = false;
		self.Magazine.RoundCount = self.ammoCount;
	end	
	
	local recoilFactor = math.pow(math.min(self.FireTimer.ElapsedSimTimeMS / (300 * 4), 1), 2.0)
	self.rotationTarget = self.rotationTarget + math.max(0, math.sin(recoilFactor * math.pi) * 13)
	
	if self.FiredFrame then
	
		self.horizontalAnim = self.horizontalAnim + 2
		
		self.angVel = self.angVel + RangeRand(0.7,1.1) * -10
		
		self.GFXTimer:Reset();
		
		self.heatNum = math.min(100, self.heatNum + 20)
		
		self.BaseReloadTimer:Reset();
		self.reChamber = true;
		self.Casing = true;
		self.reloadPhase = 1;
		
		self.FireTimer:Reset();
		
		if self.Magazine then
			self.ammoCount = 0 + self.Magazine.RoundCount; -- +0 to avoid reference bullshit and save it as a number properly
			if self.ammoCount == 0 then
				self.breechShellReload = true;
				self:Reload();
			end
		else
			self.ammoCount = 0;
			self.breechShellReload = true;
			self:Reload();
		end
		
		local shot = CreateMOPixel("Pellet NCBTB Extra", "Frostbite.rte");
		shot.Pos = self.MuzzlePos;
		shot.Vel = self.Vel + Vector(150 * self.FlipFactor, 0):RadRotate(self.RotAngle);
		shot.Lifetime = shot.Lifetime * math.random(0.8, 1.2);
		shot.Team = self.Team;
		shot.IgnoresTeamHits = true;
		MovableMan:AddParticle(shot);
		
		-- -- Ground Smoke
		-- local maxi = 7 + (math.floor(4))
		-- for i = 1, maxi do
			
			-- local effect = CreateMOSRotating("Ground Smoke Particle Small Frostbite", "Frostbite.rte")
			-- effect.Pos = self.MuzzlePos + Vector(RangeRand(-1,1), RangeRand(-1,1)) * 3
			-- effect.Vel = self.Vel + Vector(math.random(90,150),0):RadRotate(math.pi * 2 / maxi * i + RangeRand(-2,2) / maxi)
			-- effect.Lifetime = effect.Lifetime * RangeRand(0.5,2.0)
			-- effect.AirResistance = effect.AirResistance * RangeRand(0.5,0.8)
			-- MovableMan:AddParticle(effect)
		-- end
		
		local xSpread = 0
		
		local smokeAmount = 10
		local particleSpread = 10 + (math.floor(7))
		
		local smokeLingering = math.sqrt(smokeAmount / 8) * (1)
		local smokeVelocity = (1 + math.sqrt(smokeAmount / 8) ) * 0.5
		
		-- Muzzle main smoke
		for i = 1, math.ceil(smokeAmount / (math.random(2,4))) do
			local spread = math.pi * RangeRand(-1, 1) * 0.05
			local velocity = 110 * RangeRand(0.1, 0.9) * 0.4;
			
			local particle = CreateMOSParticle((math.random() * particleSpread) < 6.5 and "Tiny Smoke Ball 1" or "Small Smoke Ball 1");
			particle.Pos = self.MuzzlePos
			particle.Vel = self.Vel + Vector(velocity * self.FlipFactor,0):RadRotate(self.RotAngle + spread) * smokeVelocity
			particle.Lifetime = particle.Lifetime * RangeRand(0.9, 1.6) * 0.3 * smokeLingering
			particle.AirThreshold = particle.AirThreshold * 0.5
			particle.GlobalAccScalar = 0
			MovableMan:AddParticle(particle);
		end
		
		-- Muzzle lingering smoke
		for i = 1, math.ceil(smokeAmount / (math.random(2,4))) do
			local spread = math.pi * RangeRand(-1, 1) * 0.05
			local velocity = 110 * RangeRand(0.1, 0.9) * 0.4;
			
			local particle = CreateMOSParticle((math.random() * particleSpread) < 10 and "Tiny Smoke Ball 1" or "Small Smoke Ball 1");
			particle.Pos = self.MuzzlePos
			particle.Vel = self.Vel + Vector(velocity * self.FlipFactor,0):RadRotate(self.RotAngle + spread) * smokeVelocity
			particle.Lifetime = particle.Lifetime * RangeRand(0.9, 1.6) * 0.3 * smokeLingering * 3
			particle.AirThreshold = particle.AirThreshold * 0.5
			particle.GlobalAccScalar = 0.01
			MovableMan:AddParticle(particle);
		end
		
		-- Muzzle side smoke
		for i = 1, math.ceil(smokeAmount / (math.random(4,6))) do
			local vel = Vector(110 * self.FlipFactor,0):RadRotate(self.RotAngle)
			
			local xSpreadVec = Vector(xSpread * self.FlipFactor * math.random() * -1, 0):RadRotate(self.RotAngle)
			
			local particle = CreateMOSParticle("Tiny Smoke Ball 1");
			particle.Pos = self.MuzzlePos + xSpreadVec
			-- oh LORD
			particle.Vel = self.Vel + ((Vector(vel.X, vel.Y):RadRotate(math.pi * (math.random(0,1) * 2.0 - 1.0) * 0.5 + math.pi * RangeRand(-1, 1) * 0.15) * RangeRand(0.1, 0.9) * 0.3 + Vector(vel.X, vel.Y):RadRotate(math.pi * RangeRand(-1, 1) * 0.15) * RangeRand(0.1, 0.9) * 0.2) * 0.5) * smokeVelocity;
			-- have mercy
			particle.Lifetime = particle.Lifetime * RangeRand(0.9, 1.6) * 0.3 * smokeLingering
			particle.AirThreshold = particle.AirThreshold * 0.5
			particle.GlobalAccScalar = 0
			MovableMan:AddParticle(particle);
		end
		
		-- Muzzle scary smoke
		for i = 1, math.ceil(smokeAmount / (math.random(8,12))) do
			local spread = math.pi * RangeRand(-1, 1) * 0.05
			local velocity = 110 * RangeRand(0.1, 0.9) * 0.4;
			
			local particle = CreateMOSParticle("Side Thruster Blast Ball 1", "Base.rte");
			particle.Pos = self.MuzzlePos
			particle.Vel = self.Vel + Vector(velocity * self.FlipFactor,0):RadRotate(self.RotAngle + spread) * smokeVelocity
			particle.Lifetime = particle.Lifetime * RangeRand(0.9, 1.6) * 0.3 * smokeLingering
			particle.AirThreshold = particle.AirThreshold * 0.5
			particle.GlobalAccScalar = 0
			MovableMan:AddParticle(particle);
		end
		
		-- Muzzle flash-smoke
		for i = 1, math.ceil(smokeAmount / (math.random(5,10) * 0.5)) do
			local spread = RangeRand(-math.rad(particleSpread), math.rad(particleSpread)) * (1 + math.random(0,3) * 0.3)
			local velocity = 110 * 0.6 * RangeRand(0.9,1.1)
			
			local xSpreadVec = Vector(xSpread * self.FlipFactor * math.random() * -1, 0):RadRotate(self.RotAngle)
			
			local particle = CreateMOSParticle("Flame Smoke 1 Micro")
			particle.Pos = self.MuzzlePos + xSpreadVec
			particle.Vel = self.Vel + Vector(velocity * self.FlipFactor,0):RadRotate(self.RotAngle + spread) * smokeVelocity
			particle.Team = self.Team
			particle.Lifetime = particle.Lifetime * RangeRand(0.9,1.2) * 0.75 * smokeLingering
			particle.AirResistance = particle.AirResistance * 2.5 * RangeRand(0.9,1.1)
			particle.IgnoresTeamHits = true
			particle.AirThreshold = particle.AirThreshold * 0.5
			MovableMan:AddParticle(particle);
		end
		--
		
		local shakenessParticle = CreateMOPixel("Shakeness Particle Glow Frostbite", "Frostbite.rte");
		shakenessParticle.Pos = self.MuzzlePos;
		shakenessParticle.Mass = 25;
		shakenessParticle.Lifetime = 300;
		MovableMan:AddParticle(shakenessParticle);

		local outdoorRays = 0;
		
		local indoorRays = 0;
		
		local bigIndoorRays = 0;

		if self.parent and self.parent:IsPlayerControlled() then
			self.rayThreshold = 2; -- this is the first ray check to decide whether we play outdoors
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
			self.rayThreshold = 1; -- has to be different for AI
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
		
		if outdoorRays >= self.rayThreshold then
			self.reflectionOutdoorsSound:Play(self.Pos);
		else
			self.reflectionIndoorsSound:Play(self.Pos);
		end

	end
	
	-- Animation
	if self.parent then
	
		self.horizontalAnim = math.floor(self.horizontalAnim / (1 + TimerMan.DeltaTimeSecs * 24.0) * 1000) / 1000
		self.verticalAnim = math.floor(self.verticalAnim / (1 + TimerMan.DeltaTimeSecs * 15.0) * 1000) / 1000
		
		local stance = Vector()
		stance = stance + Vector(-1,0) * self.horizontalAnim -- Horizontal animation
		stance = stance + Vector(0,5) * self.verticalAnim -- Vertical animation
		
		self.rotationTarget = self.rotationTarget - (self.angVel * 4)
		
		-- Progressive Recoil Update
		if self.FiredFrame then
			self.recoilStr = self.recoilStr + ((math.random(10, self.recoilRandomUpper * 10) / 10) * 0.5 * self.recoilStrength) + (self.recoilStr * 0.6 * self.recoilPowStrength)
			self:SetNumberValue("recoilStrengthBase", self.recoilStrength * (1 + self.recoilPowStrength) / self.recoilDamping)
		end
		self:SetNumberValue("recoilStrengthCurrent", self.recoilStr)
		
		self.recoilStr = math.floor(self.recoilStr / (1 + TimerMan.DeltaTimeSecs * 8.0 * self.recoilDamping) * 1000) / 1000
		self.recoilAcc = (self.recoilAcc + self.recoilStr * TimerMan.DeltaTimeSecs) % (math.pi * 4)
		
		local recoilA = (math.sin(self.recoilAcc) * self.recoilStr) * 0.05 * self.recoilStr
		local recoilB = (math.sin(self.recoilAcc * 0.5) * self.recoilStr) * 0.01 * self.recoilStr
		local recoilC = (math.sin(self.recoilAcc * 0.25) * self.recoilStr) * 0.05 * self.recoilStr
		
		local recoilFinal = math.max(math.min(recoilA + recoilB + recoilC, self.recoilMax), -self.recoilMax)
		
		self.SharpLength = math.max(self.originalSharpLength - (self.recoilStr * 3 + math.abs(recoilFinal)), 0)
		
		self.rotationTarget = self.rotationTarget + recoilFinal -- apply the recoil
		-- Progressive Recoil Update
		
		-- non reloading supportoffset handling
		local supportOffset = Vector(0,0)
		if self.Frame == 1 or self.Frame == 9 then
			supportOffset = Vector(-1,0)
		elseif self.Frame == 2 or self.Frame == 8 then
			supportOffset = Vector(-2,0)
		elseif self.Frame == 3 or self.Frame == 7 then
			supportOffset = Vector(-3,0)
		end
		if self.parent:GetController():IsState(Controller.AIM_SHARP) == true and self.parent:GetController():IsState(Controller.MOVE_LEFT) == false and self.parent:GetController():IsState(Controller.MOVE_RIGHT) == false then
			supportOffset = supportOffset + Vector(-1,0)
		end
		
		self.SupportOffset = self.originalSupportOffset + supportOffset
		
		self.rotation = (self.rotation + self.rotationTarget * TimerMan.DeltaTimeSecs * self.rotationSpeed) / (1 + TimerMan.DeltaTimeSecs * self.rotationSpeed)
		self.SupportOffset = self.SupportOffset + ((self.reloadSupportOffsetTarget - self.SupportOffset) * TimerMan.DeltaTimeSecs * self.reloadSupportOffsetSpeed)
		local total = math.rad(self.rotation) * self.FlipFactor
		
		self.InheritedRotAngleOffset = total * self.FlipFactor;
		-- self.RotAngle = self.RotAngle + total;
		-- self:SetNumberValue("MagRotation", total);
		
		-- local jointOffset = Vector(self.JointOffset.X * self.FlipFactor, self.JointOffset.Y):RadRotate(self.RotAngle);
		-- local offsetTotal = Vector(jointOffset.X, jointOffset.Y):RadRotate(-total) - jointOffset
		-- self.Pos = self.Pos + offsetTotal;
		-- self:SetNumberValue("MagOffsetX", offsetTotal.X);
		-- self:SetNumberValue("MagOffsetY", offsetTotal.Y);
		
		if self.reloadingVectorTarget then
			self.reloadingVector = self.reloadingVector + ((self.reloadingVectorTarget - self.reloadingVector) * TimerMan.DeltaTimeSecs * 2.5)
			self.StanceOffset = Vector(self.originalStanceOffset.X, self.originalStanceOffset.Y) + stance + self.reloadingVector
			self.SharpStanceOffset = Vector(self.originalSharpStanceOffset.X, self.originalSharpStanceOffset.Y) + stance + self.reloadingVector
		else
			self.reloadingVector = Vector(0, 0)
			self.StanceOffset = Vector(self.originalStanceOffset.X, self.originalStanceOffset.Y) + stance
			self.SharpStanceOffset = Vector(self.originalSharpStanceOffset.X, self.originalSharpStanceOffset.Y) + stance
		end
		
	end
	
	if self.GFXTimer:IsPastSimMS(self.GFXDelay) then
		if self.heatNum > 2 then
			local particles = {"Tiny Smoke Ball 1"}
			
			if self.heatNum > 100 then
				table.insert(particles, "Small Smoke Ball 1")
			end
			
			for i = 1, math.random(1,3) do
				local particle = CreateMOSParticle(particles[math.random(1,#particles)]);
				particle.Lifetime = math.random(250, 600);
				particle.Vel = self.Vel + Vector(0, -0.1);
				particle.Pos = self.MuzzlePos;
				MovableMan:AddParticle(particle);
			end
				
		end
		
		self.GFXTimer:Reset()
		self.GFXDelay = math.max(50, math.random(35, 100) - self.heatNum) 
	end
	
	self.heatNum = math.max(self.heatNum - 0.05, 0)
	
end

function OnDetach(self)

	self.heatNum = 0;
	
	self.rotationSpeed = 6
	
	self:DisableScript("Frostbite.rte/Devices/Weapons/Handheld/NCBTB/Chamber.lua");

end