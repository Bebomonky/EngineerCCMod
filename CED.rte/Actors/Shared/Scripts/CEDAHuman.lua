-- CED AHuman functionality like foley sounds, jumping, sprinting.
-- Tightly integrated with CompliSound ActorMovementSounds.

function Create(self)
	self.CEDAHumanJumpTimer = Timer();
	self.CEDAHumanJumpDelay = 400;
	self.CEDAHumanJumpStrength = self.CEDAHumanJumpStrength or 1.5;

	self.CEDAHumanSprintAndWalkDifference = self.CEDAHumanSprintMultiplier - self.CEDAHumanWalkMultiplier;
	self.CEDAHumanCurrentMoveMultiplier = 1;
	
	self.CEDAHumanLimbPathDefaultSpeed = self:GetLimbPathTravelSpeed(Actor.WALK);
	
	self.CEDAHumanDefaultWalkRotAngleTarget = self:GetRotAngleTarget(Actor.WALK);
	
	self.CompliSoundActorStepCallback = function (self)
		if self.CompliSoundActorSprinting then
			if self.CEDAHumanFoleySounds.Sprint then
				self.CEDAHumanFoleySounds.Sprint.Volume = (self.CEDAHumanCurrentMoveMultiplier - self.CEDAHumanWalkMultiplier) / (self.CEDAHumanSprintAndWalkDifference)
				self.CEDAHumanFoleySounds.Sprint:Play(self.Pos);
			end
			if self.CEDAHumanFoleySounds.Walk then
				self.CEDAHumanFoleySounds.Walk.Volume = 1 - self.CEDAHumanFoleySounds.Sprint.Volume;
				self.CEDAHumanFoleySounds.Walk:Play(self.Pos);
			end
		else
			if self.CEDAHumanFoleySounds.Walk then
				self.CEDAHumanFoleySounds.Walk.Volume = 1;
				if self.CompliSoundActorCrouching then
					self.CEDAHumanFoleySounds.Walk.Volume = 0.4;
				end
				self.CEDAHumanFoleySounds.Walk:Play(self.Pos);
			end		
		end
	end
	
	-- Sure, theoretically we're already telling CompliSound to jump, but... neater this way
	self.CompliSoundActorJumpCallback = function (self)
		if self.CEDAHumanFoleySounds.Jump then
			self.CEDAHumanFoleySounds.Jump:Play(self.Pos);
		end
	end
	
	self.CompliSoundActorLandCallback = function (self)
		if self.CEDAHumanFoleySounds.Land then
			self.CEDAHumanFoleySounds.Land:Play(self.Pos);
		end		
	end

	self.CompliSoundActorProneCallback = function (self)
		if self.CEDAHumanFoleySounds.Prone then
			self.CEDAHumanFoleySounds.Prone:Play(self.Pos);
		end		
	end
	
	self.CompliSoundActorCrawlCallback = function (self)
		if self.CEDAHumanFoleySounds.Crawl then
			self.CEDAHumanFoleySounds.Crawl:Play(self.Pos);
		end		
	end
	
	self.CompliSoundActorImpactLightCallback = function (self)
		if self.CEDAHumanFoleySounds.ImpactLight then
			self.CEDAHumanFoleySounds.ImpactLight:Play(self.Pos);
		end		
	end
	
	self.CompliSoundActorImpactHeavyCallback = function (self)
		if self.CEDAHumanFoleySounds.ImpactHeavy then
			self.CEDAHumanFoleySounds.ImpactHeavy:Play(self.Pos);
		end				
	end
	
end

function ThreadedUpdate(self)
	local isPlayerControlled = self:IsPlayerControlled();
	for soundType, soundContainer in pairs(self.CEDAHumanFoleySounds) do
		soundContainer.Pos = self.Pos;
	end

	self.CompliSoundActorPlayJumpSound = false;
	local controller = self:GetController();
	local crouching = controller:IsState(Controller.BODY_WALKCROUCH)
	local proning = controller:IsState(Controller.BODY_PRONE)
	local moving = controller:IsState(Controller.MOVE_LEFT) or controller:IsState(Controller.MOVE_RIGHT);
	
	-- Crouching/standing
	if (crouching and not self.CEDAHumanCrouching) and self.CompliSoundActorMoveSoundTimer:IsPastSimMS(500) then
		self.CEDAHumanCrouching = true;
		self.CEDAHumanFoleySounds.Crouch:Play(self.Pos);
		self.CompliSoundActorMoveSoundTimer:Reset();
	elseif (self.CEDAHumanCrouching and not crouching) then
		self.CEDAHumanCrouching = false;
		if self.CompliSoundActorMoveSoundTimer:IsPastSimMS(500) then
			self.CEDAHumanFoleySounds.Stand:Play(self.Pos);
			self.CompliSoundActorMoveSoundTimer:Reset();
		end
	end
	
	-- Proning/standing
	if (proning and not self.CEDAHumanProning) and self.CompliSoundActorMoveSoundTimer:IsPastSimMS(500) then
		self.CEDAHumanProning = true;
		self.CEDAHumanFoleySounds.ProneStart:Play(self.Pos);
		self.CompliSoundActorMoveSoundTimer:Reset();
	elseif (self.CEDAHumanProning and not proning) then
		self.CEDAHumanProning = false;
		if self.CompliSoundActorMoveSoundTimer:IsPastSimMS(500) then
			self.CEDAHumanFoleySounds.Stand:Play(self.Pos);
			self.CompliSoundActorMoveSoundTimer:Reset();
		end
	end
	
	-- Jumping
	if controller:IsState(Controller.BODY_JUMPSTART) == true and controller:IsState(Controller.BODY_CROUCH) == false and self.CEDAHumanJumpTimer:IsPastSimMS(self.CEDAHumanJumpDelay) and not self.CompliSoundActorIsJumping and not self.CompliSoundActorWasInAir then
		if (isPlayerControlled and self.CompliSoundActorFootContacts[1] == true or self.CompliSoundActorFootContacts[2] == true) or self.CompliSoundActorWasInAir == false then
			local jumpStrength = sprinting and self.CEDAHumanJumpStrength * 2 or self.CEDAHumanJumpStrength;
			local jumpVec = Vector(0, -self.CEDAHumanJumpStrength)
			local jumpWalkX = 3
			if controller:IsState(Controller.MOVE_LEFT) == true then
				jumpVec.X = -jumpWalkX
			elseif controller:IsState(Controller.MOVE_RIGHT) == true then
				jumpVec.X = jumpWalkX
			end
			
			if math.abs(self.Vel.X) > jumpWalkX * 2.0 then
				self.Vel = Vector(self.Vel.X, self.Vel.Y + jumpVec.Y)
			else
				self.Vel = Vector(self.Vel.X + jumpVec.X, self.Vel.Y + jumpVec.Y)
			end
			self.CEDAHumanJumpTimer:Reset()
			self.CompliSoundActorPlayJumpSound = true;
		end
	end
	
	-- Sprinting
	if self.CompliSoundActorSprinting and self.Vel.Magnitude > 1 then
	
		-- Acceleration
		self:SetRotAngleTarget(AHuman.RUN, self.CEDAHumanDefaultWalkRotAngleTarget + (self.CEDAHumanSprintingRotAngleOffset) * (self.CEDAHumanCurrentMoveMultiplier - self.CEDAHumanWalkMultiplier) / (self.CEDAHumanSprintAndWalkDifference));
		
		if self.CEDAHumanCurrentMoveMultiplier < self.CEDAHumanSprintMultiplier then
			self.CEDAHumanCurrentMoveMultiplier = self.CEDAHumanCurrentMoveMultiplier + TimerMan.DeltaTimeSecs * self.CEDAHumanAccelerationFactor;
			if self.CEDAHumanCurrentMoveMultiplier > self.CEDAHumanSprintMultiplier then
				self.CEDAHumanCurrentMoveMultiplier = self.CEDAHumanSprintMultiplier;
			end
		end

		--self:SetLimbPathTravelSpeed(Actor.RUN, self.CEDAHumanLimbPathDefaultSpeed * self.CEDAHumanCurrentMoveMultiplier);
		
		self:GetLimbPath(AHuman.FGROUND, Actor.RUN).BaseTravelSpeedMultiplier = self.CEDAHumanCurrentMoveMultiplier;
		self:GetLimbPath(AHuman.BGROUND, Actor.RUN).BaseTravelSpeedMultiplier = self.CEDAHumanCurrentMoveMultiplier;
	else
		-- Slowing down
		if self.CEDAHumanCurrentMoveMultiplier > self.CEDAHumanWalkMultiplier then
			self.CEDAHumanCurrentMoveMultiplier = self.CEDAHumanCurrentMoveMultiplier - TimerMan.DeltaTimeSecs * self.CEDAHumanDecelerationFactor;
			if self.CEDAHumanCurrentMoveMultiplier < self.CEDAHumanWalkMultiplier then
				self.CEDAHumanCurrentMoveMultiplier = self.CEDAHumanWalkMultiplier;
			end
		end
		
		if not moving then
			self.CEDAHumanCurrentMoveMultiplier = self.CEDAHumanWalkMultiplier;
		end
		
		--self:SetLimbPathTravelSpeed(Actor.WALK, self.CEDAHumanLimbPathDefaultSpeed * self.CEDAHumanCurrentMoveMultiplier);
		
		self:GetLimbPath(AHuman.FGROUND, Actor.WALK).BaseTravelSpeedMultiplier = self.CEDAHumanCurrentMoveMultiplier;
		self:GetLimbPath(AHuman.BGROUND, Actor.WALK).BaseTravelSpeedMultiplier = self.CEDAHumanCurrentMoveMultiplier;
	end
end