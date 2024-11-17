require("/CEDSettings");

function Create(self)
	self.BASADRSFireVelocity = 25;
	self.BASADRSFireNoPropVelocity = 45;
	self.BASADRSFireSpread = 0.2 / 2;
	
	self.BASADRSShotSound = CreateSoundContainer("Shot CED CED-BAS ADRS", "CED.rte");
	
	self.BASADRSDeploySound = CreateSoundContainer("Deploy CED CED-BAS ADRS", "CED.rte");
	self.BASADRSUndeploySound = CreateSoundContainer("Undeploy CED CED-BAS ADRS", "CED.rte");
	
	self.BASADRSWalkSound = CreateSoundContainer("Walk CED CED-BAS ADRS", "CED.rte");
	
	self.BASADRSSwitchPropOffSound = CreateSoundContainer("Switch Prop Off CED CED-BAS ADRS", "CED.rte");
	self.BASADRSSwitchPropOnSound = CreateSoundContainer("Switch Prop On CED CED-BAS ADRS", "CED.rte");

	self.BASADRSNoPropMode = false;
	
	self.BASADRSDeployed = false;

	self.BASADRSDeploySoundPlayed = false;
	self.BASADRSUndeploySoundPlayed = false;
	
	self.BASADRSInvalidStanceGraceTimer = Timer();
	self.BASADRSInvalidStanceGraceTime = 400;
	self.BASADRSDeployTimer = Timer();
	self.BASADRSDeployTime = 650;
	
	self.BASADRSAIFairnessTimer = Timer();
	self.BASADRSAIFairnessTime = 2500;
	self.BASADRSAIFairnessEnabled = false;
	
	self.BASADRSOriginalStanceOffset = Vector(math.abs(self.StanceOffset.X), self.StanceOffset.Y);
	self.BASADRSDeployedStanceOffset = Vector(6, -1.5);
	
	-- Timer to not insta-reload after firing.
	self.BASADRSReloadDelayTimer = Timer();
	-- Delay for above timer.
	self.BASADRSReloadDelay = 600;
end

function OnFire(self)
	CameraMan:AddScreenShake(12, self.Pos);
	
	self.BASADRSShotSound:Play(self.Pos);

	local spread = math.random(-self.BASADRSFireSpread, self.BASADRSFireSpread);

	if self.NoPropMode then
		local shot = CreateAEmitter("Rocket No Prop Mode CED CED-BAS ADRS", "CED.rte");
		shot.Pos = self.MuzzlePos + Vector(0.1*self.FlipFactor, 0):RadRotate(self.RotAngle);
		shot.Vel = self.Vel + Vector(self.BASADRSFireNoPropVelocity * self.FlipFactor, spread):RadRotate(self.RotAngle);
		shot.RotAngle = self.RotAngle;
		shot.HFlipped = self.HFlipped;
		shot.Team = self.Team;
		shot.IgnoresTeamHits = true;
		shot:SetWhichMOToNotHit(ToMovableObject(self), 150);
		MovableMan:AddParticle(shot);
	else
		local shot = CreateAEmitter("Rocket CED CED-BAS ADRS", "CED.rte");
		shot.Pos = self.MuzzlePos + Vector(0.1*self.FlipFactor, 0):RadRotate(self.RotAngle);
		shot.Vel = self.Vel + Vector(self.BASADRSFireVelocity * self.FlipFactor, spread):RadRotate(self.RotAngle);
		shot.RotAngle = self.RotAngle;
		shot.HFlipped = self.HFlipped;
		shot.Team = self.Team;
		shot.IgnoresTeamHits = true;
		shot:SetWhichMOToNotHit(ToMovableObject(self), 150);
		MovableMan:AddParticle(shot);	
	end
	
	-- Backblast smoke
	for i = 1, math.ceil(25 / (math.random(10,15))) do
		local spread = math.pi * RangeRand(-1, 1) * 0.05
		local velocity = 110 * RangeRand(0.1, 0.9) * 0.4;
		
		local particle = CreateMOSParticle((math.random() * 15) < 19 and "Tiny Smoke Ball 1" or "Small Smoke Ball 1");
		particle.Pos = self.Pos + Vector(-15, 0):RadRotate(self.RotAngle);
		particle.Vel = self.Vel + Vector(-15 * self.FlipFactor, 0):RadRotate(self.RotAngle + spread)
		particle.Lifetime = particle.Lifetime * RangeRand(0.9, 1.6) * 0.3
		particle.AirThreshold = particle.AirThreshold * 0.5
		particle.GlobalAccScalar = 0
		MovableMan:AddParticle(particle);
	end

	self.Reloadable = false;
	self.BASADRSReloadDelayTimer:Reset();	
end
					
function OnAttach(self, newParent)
	if IsAHuman(newParent:GetRootParent()) then
		self.parent = ToAHuman(newParent:GetRootParent());
		self.parentController = self.parent:GetController();
	end
end

function OnDetach(self)
	self.parent = nil;
	self.parentController = nil;
end

function ThreadedUpdate(self)
	self.BASADRSDeploySound.Pos = self.Pos;
	self.BASADRSUndeploySound.Pos = self.Pos;
	self.BASADRSWalkSound.Pos = self.Pos;
	
	self.BASADRSSwitchPropOnSound.Pos = self.Pos;
	self.BASADRSSwitchPropOffSound.Pos = self.Pos;

	if self.parent then
		-- AI does better with the propellant mode
		if self.NoPropMode and not self.parent:IsPlayerControlled() then
			self.NoPropMode = false;
			self.BASADRSSwitchPropOnSound:Play(self.Pos);
			self.BASADRSSwitchPropOffSound:FadeOut(50);
		end

		if self.parentController:IsState(Controller.WEAPON_PRIMARY_HOTKEYSTART) then
			if self.NoPropMode then
				self.NoPropMode = false;
				self.BASADRSSwitchPropOnSound:Play(self.Pos);
				self.BASADRSSwitchPropOffSound:FadeOut(50);
			else
				self.NoPropMode = true;
				self.BASADRSSwitchPropOffSound:Play(self.Pos);
				self.BASADRSSwitchPropOnSound:FadeOut(50);
			end
		end
		
		self.HEATRotationTargetOverride = nil; -- Just reset these every frame to make sure
		self.HEATRotationTargetManualAddition = 0;
	
		local isPlayerControlled = self.parent:IsPlayerControlled();
	
		local isMoving = (self.parentController:IsState(Controller.MOVE_LEFT) == true or self.parentController:IsState(Controller.MOVE_RIGHT) == true) or self.parent.Vel.Magnitude > 3;
		local isMovingFast = self.parent.MovementState == Actor.RUN or self.parent.Vel.Magnitude > 6;
		
		local heavyEnoughForWalkingFire = self.parent.IndividualMass >= 60;
		local heavyEnoughForRunningFire = self.parent.IndividualMass >= 90;
		
		local canDeploy;
		local standingDeploy = not isCrouching;
		if not isMoving then
			canDeploy = true;
			self.BASADRSAIFairnessEnabled = false;
		elseif heavyEnoughForWalkingFire and not isMovingFast then
			canDeploy = true;
			self.BASADRSAIFairnessEnabled = false;
		elseif heavyEnoughForRunningFire then
			canDeploy = true;
			self.BASADRSAIFairnessEnabled = false;
		elseif not isPlayerControlled then
			canDeploy = true;
			self.BASADRSAIFairnessEnabled = true;
		end
		
		if self.BASADRSAIFairnessEnabled then
			if self.BASADRSAIFairnessTimer:IsPastSimMS(self.BASADRSAIFairnessTime) then
				self.BASADRSAIFairnessTime = math.random(2500, 4000)
				self.BASADRSAIFairnessTimer:Reset();
			elseif self.BASADRSAIFairnessTimer:IsPastSimMS(self.BASADRSAIFairnessTime / 1.5) then
				self:Deactivate();
				canDeploy = false;
				timeToUse = 200;
			end
		end
		
		if canDeploy then	
			-- Sound
			if not self.BASADRSDeploySoundPlayed then
				self.BASADRSDeploySoundPlayed = true;
				self.BASADRSUndeploySound:FadeOut(100);
				if isPlayerControlled and not self:IsReloading() then
					self.BASADRSDeploySound:Play(self.Pos);
				end
			end
			
			self.HUDVisible = true;
			self.HEATRotationTargetOverride = nil;
			
			-- Fully deployed
			if self.BASADRSDeployTimer:IsPastSimMS(self.BASADRSDeployTime) then
				self.HEATRotationTargetOverride = nil;
				self.HEATAngVelManualAddition = 0;
				
				if not self.BASADRSDeployed then
					self.BASADRSDeployed = true;
				end
				
				self.HEATOriginalSharpLength = 200;
				
				self.BASADRSInvalidStanceGraceTimer:Reset();
			elseif self.BASADRSDeployTimer:IsPastSimMS(self.BASADRSDeployTime / 1.5) then
				self.StanceOffset = self.BASADRSDeployedStanceOffset;
				self.HEATOriginalStanceOffset = self.BASADRSDeployedStanceOffset;
				self.SharpStanceOffset = self.BASADRSDeployedStanceOffset;
				self.HEATOriginalSharpStanceOffset = self.BASADRSDeployedStanceOffset;
			
				self.HEATRotationSpeed = 5;
				
				self.HEATOriginalSharpLength = 50;
				if not self:IsReloading() then
					self.HEATRotationTargetOverride = 3;
				end				
			else
				self.HEATRotationSpeed = 3;
				if not self:IsReloading() then
					self.HEATRotationTargetOverride = -15;
				end
				self:Deactivate();
			end
		-- Not valid for deployment
		elseif self.BASADRSInvalidStanceGraceTimer:IsPastSimMS(self.BASADRSInvalidStanceGraceTime) then
			self.StanceOffset = self.BASADRSOriginalStanceOffset;
			self.HEATOriginalStanceOffset = self.BASADRSOriginalStanceOffset;
			self.SharpStanceOffset = self.BASADRSOriginalStanceOffset;
			self.HEATOriginalSharpStanceOffset = self.BASADRSOriginalStanceOffset;		
		
			if self.BASADRSDeploySoundPlayed then
				if self.BASADRSDeployed then
					if isPlayerControlled and not self:IsReloading() then
						self.BASADRSUndeploySound:Play(self.Pos);
					end
				end
				self.BASADRSDeployed = false;
				self.BASADRSDeploySound:FadeOut(200);
				
				self.BASADRSDeploySoundPlayed = false;
			end			

			self:Deactivate();			
			self.BASADRSDeployTimer:Reset();

			self.HUDVisible = false;
			self.parentController:SetState(Controller.AIM_SHARP, false)
			self.HEATOriginalSharpLength = 0;
			
			if self:IsReloading() then
				self.HEATRotationTargetOverride = nil;
			else
				self.HEATRotationTargetOverride = -35;
			end
			self.HEATRotationSpeed = 3;	
		end
		
		if self.parent.StrideFrame then
			if not self.BASADRSDeployed then
				self.HEATAngVelManualAddition = 12;
			end
			if self.Magazine then
				self.BASADRSWalkSound:Play(self.Pos);
			end
		else
			self.HEATAngVelManualAddition = 0;
		end		
	end
	
	if self:DoneReloading() then
		self.HEATPersistentFrame = 0;
	end
	
	if self.BASADRSReloadDelayTimer:IsPastSimMS(self.BASADRSReloadDelay) then
		self.Reloadable = true;
	end
end