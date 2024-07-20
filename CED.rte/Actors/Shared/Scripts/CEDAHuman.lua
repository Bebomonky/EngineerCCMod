-- Handles jumping as well as all non-CompliSound-provided foley sounds, via its callbacks or otherwise.
-- Makes use of CompliSound script variables like the MoveSoundTimer.

function Create(self)
	self.CEDAHumanJumpTimer = Timer();
	self.CEDAHumanJumpDelay = 400;
	self.CEDAHumanJumpStrength = self.CEDAHumanJumpStrength or 1.5;

	self.CEDAHumanCurrentMoveMultiplier = 1;
	
	self.CEDAHumanLimbPathDefaultSpeed0 = self:GetLimbPathSpeed(0);
	self.CEDAHumanLimbPathDefaultSpeed1 = self:GetLimbPathSpeed(1);
	self.CEDAHumanLimbPathDefaultSpeed2 = self:GetLimbPathSpeed(2);
	
	self.CEDAHumanLimbPathDefaultPushForce = self.LimbPathPushForce;
	
	self.CEDAHumanOriginalWalkRotAngleTarget = self:GetRotAngleTarget(AHuman.WALK);
	
	self.CEDAHumanSprintDoubleTapState = 0;
	self.CEDAHumanSprintDoubleTapTimer = Timer();
	self.CEDAHumanSprintDoubleTapMaxDelay = 250;
	
	self.CompliSoundActorStepCallback = function (self)
		if self.CompliSoundActorIsSprinting then
			if self.CEDAHumanFoleySounds.Sprint then
				self.CEDAHumanFoleySounds.Sprint:Play(self.Pos);
			end
		else
			if self.CEDAHumanFoleySounds.Walk then
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
		if self.CEDAHumanFoleySounds.Impact then
			self.CEDAHumanFoleySounds.Impact:Play(self.Pos);
		end		
	end
	
	self.CompliSoundActorImpactHeavyCallback = function (self)
		if self.CEDAHumanFoleySounds.Impact then
			self.CEDAHumanFoleySounds.Impact:Play(self.Pos);
		end				
	end
	
end

-- Update and not ThreadedUpdate so we can guarantee the PlayJumpSound variable always being seen by the CompliSound script.
function Update(self)
	self.CompliSoundActorPlayJumpSound = false;
	local controller = self:GetController();
	local crouching = controller:IsState(Controller.BODY_CROUCH)
	local moving = controller:IsState(Controller.MOVE_LEFT) or controller:IsState(Controller.MOVE_RIGHT);
	
	-- Crouching/standing
	if (crouching and not self.CEDAHumanCrouching) and self.CompliSoundActorMoveSoundTimer:IsPastSimMS(500) then
		self.CEDAHumanCrouching = true;
		if moving and not self.CompliSoundActorIsSprinting then
			self.CEDAHumanFoleySounds.ProneStart:Play(self.Pos);
		else
			self.CEDAHumanFoleySounds.Crouch:Play(self.Pos);
		end
		self.CompliSoundActorMoveSoundTimer:Reset();
	elseif (self.CEDAHumanCrouching and not crouching) then
		self.CEDAHumanCrouching = false;
		if self.CompliSoundActorMoveSoundTimer:IsPastSimMS(500) then
			self.CEDAHumanFoleySounds.Stand:Play(self.Pos);
			self.CompliSoundActorMoveSoundTimer:Reset();
		end
	end
	
	-- Jumping
	if controller:IsState(Controller.BODY_JUMPSTART) == true and controller:IsState(Controller.BODY_CROUCH) == false and self.CEDAHumanJumpTimer:IsPastSimMS(self.CEDAHumanJumpDelay) and not self.CompliSoundActorIsJumping and not self.CompliSoundActorWasInAir then
		if (self:IsPlayerControlled() and self.CompliSoundActorFootContacts[1] == true or self.CompliSoundActorFootContacts[2] == true) or self.CompliSoundActorWasInAir == false then
			local jumpStrength = self.CompliSoundActorIsSprinting and self.CEDAHumanJumpStrength * 2 or self.CEDAHumanJumpStrength;
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
	local sprintInput = not self.CompliSoundActorIsJumping
	and not crouching
	and ((controller:IsState(Controller.MOVE_LEFT) == true or controller:IsState(Controller.MOVE_RIGHT) == true)
	and not (controller:IsState(Controller.MOVE_LEFT) == true and controller:IsState(Controller.MOVE_RIGHT) == true))
	and not (controller:IsState(Controller.MOVE_LEFT) == true and self.HFlipped == false or controller:IsState(Controller.MOVE_RIGHT) == true and self.HFlipped == true)
	
	if self.CEDAHumanSprintDoubleTapState == 0 then
		if sprintInput == true then
			self.CEDAHumanSprintDoubleTapTimer:Reset()
		else
			self.CEDAHumanSprintDoubleTapState = 1
		end
	elseif self.CEDAHumanSprintDoubleTapState == 1 then
		if self.CEDAHumanSprintDoubleTapTimer:IsPastSimMS(self.CEDAHumanSprintDoubleTapMaxDelay) then
			self.CEDAHumanSprintDoubleTapState = 0
		elseif sprintInput == true then
			self.CompliSoundActorIsSprinting = true
			self.CEDAHumanSprintDoubleTapState = 0
		end
	end
	
	if self.CompliSoundActorIsSprinting then
		self:SetRotAngleTarget(AHuman.WALK, self.CEDAHumanOriginalWalkRotAngleTarget - 0.15);
		self.CrouchAmountOverride = 0.15;
		controller:SetState(Controller.AIM_SHARP, false);
		controller:SetState(Controller.BODY_CROUCH, false);
		
		if crouching then
			self.CrouchAmountOverride = 1.0
			self:SetRotAngleTarget(AHuman.WALK, self.CEDAHumanOriginalWalkRotAngleTarget);
		end
		
		if self.CEDAHumanCurrentMoveMultiplier < self.CEDAHumanSprintMultiplier then
			self.CEDAHumanCurrentMoveMultiplier = self.CEDAHumanCurrentMoveMultiplier + TimerMan.DeltaTimeSecs * self.CEDAHumanAccelerationFactor;
			if self.CEDAHumanCurrentMoveMultiplier > self.CEDAHumanSprintMultiplier then
				self.CEDAHumanCurrentMoveMultiplier = self.CEDAHumanSprintMultiplier;
			end
		end
		
		self:SetLimbPathSpeed(0, self.CEDAHumanLimbPathDefaultSpeed0 * self.CEDAHumanCurrentMoveMultiplier);
		self:SetLimbPathSpeed(1, self.CEDAHumanLimbPathDefaultSpeed1 * self.CEDAHumanCurrentMoveMultiplier);
		self:SetLimbPathSpeed(2, self.CEDAHumanLimbPathDefaultSpeed2 * self.CEDAHumanCurrentMoveMultiplier);
		
		self.LimbPathPushForce = self.CEDAHumanLimbPathDefaultPushForce * 1.5
	else
		self:SetRotAngleTarget(AHuman.WALK, self.CEDAHumanOriginalWalkRotAngleTarget);
		self.WalkRotAngleTarget = self.CEDAHumanOriginalWalkRotAngleTarget;
		self.CrouchAmountOverride = -1;
		self.CEDAHumanCurrentMoveMultiplier = self.CEDAHumanWalkMultiplier;
		self:SetLimbPathSpeed(0, self.CEDAHumanLimbPathDefaultSpeed0 * self.CEDAHumanCurrentMoveMultiplier);
		self:SetLimbPathSpeed(1, self.CEDAHumanLimbPathDefaultSpeed1 * self.CEDAHumanCurrentMoveMultiplier);
		self:SetLimbPathSpeed(2, self.CEDAHumanLimbPathDefaultSpeed2 * self.CEDAHumanCurrentMoveMultiplier);
	end
	
	if not moving then
		self.CompliSoundActorIsSprinting = false;
	end
end