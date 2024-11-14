require("/CEDSettings");

function Create(self)
	self.KhC8ChimeraFireVelocity = 160;
	self.KhC8ChimeraFireSpread = 5 / 2;

	self.KhC8ChimeraBassSound = CreateSoundContainer("Bass CED Khrabarovsk C8 Chimera", "CED.rte");
	self.KhC8ChimeraShotSound = CreateSoundContainer("Shot CED Khrabarovsk C8 Chimera", "CED.rte");
	self.KhC8ChimeraMechEndSound = CreateSoundContainer("Mech End CED Khrabarovsk C8 Chimera", "CED.rte");
	
	self.KhC8ChimeraWalkBeltSound = CreateSoundContainer("Walk Belt CED Khrabarovsk C8 Chimera", "CED.rte");
	self.KhC8ChimeraDeploySound = CreateSoundContainer("Deploy CED Khrabarovsk C8 Chimera", "CED.rte");
	self.KhC8ChimeraStandingDeploySound = CreateSoundContainer("Standing Deploy CED Khrabarovsk C8 Chimera", "CED.rte");
	self.KhC8ChimeraUndeploySound = CreateSoundContainer("Undeploy CED Khrabarovsk C8 Chimera", "CED.rte");

	self.KhC8ChimeraDeployed = false;

	self.KhC8ChimeraDeploySoundPlayed = false;
	self.KhC8ChimeraUndeploySoundPlayed = false;
	
	self.KhC8ChimeraInvalidStanceGraceTimer = Timer();
	self.KhC8ChimeraInvalidStanceGraceTime = 400;
	self.KhC8ChimeraInvalidStanceGraceTimer.ElapsedSimTimeMS = self.KhC8ChimeraInvalidStanceGraceTime * 2; -- Just make sure...
	
	self.KhC8ChimeraDeployTimer = Timer();
	self.KhC8ChimeraDeployTime = 1000;
	self.KhC8ChimeraStandingDeployTime = 500;
	
	self.KhC8ChimeraOriginalSupportOffset = Vector(math.abs(self.SupportOffset.X), self.SupportOffset.Y);
	self.KhC8ChimeraDeployedSupportOffset = Vector(-3, -3);
	
	self.KhC8ChimeraAIFairnessTimer = Timer();
	self.KhC8ChimeraAIFairnessTime = 2500; -- Half of this time is spent not shooting, it is also randomized
	self.KhC8ChimeraAIFairnessEnabled = false;
	
	self.KhC8ChimeraOriginalStanceOffset = Vector(math.abs(self.StanceOffset.X), self.StanceOffset.Y);
end

function OnFire(self)
	self.KhC8ChimeraBassSound:Play(self.Pos);
	self.KhC8ChimeraShotSound:Play(self.Pos);
	self.KhC8ChimeraMechEndSound:Play(self.Pos);
	
	local spread = math.random(-self.KhC8ChimeraFireSpread, self.KhC8ChimeraFireSpread);
	
	local shot = CreateMOPixel("Bullet CED Khrabarovsk C8 Chimera Scripted", "CED.rte");
	shot.Pos = self.MuzzlePos + Vector(0.1*self.FlipFactor, 0):RadRotate(self.RotAngle);
	shot.Vel = self.Vel + Vector(self.KhC8ChimeraFireVelocity * self.FlipFactor, spread):RadRotate(self.RotAngle);
	shot.Team = self.Team;
	shot.IgnoresTeamHits = true;
	shot:SetWhichMOToNotHit(ToMovableObject(self), 150);
	MovableMan:AddParticle(shot);
	
	for i = 1, 1 do
		local shot = CreateMOPixel("Bullet CED Khrabarovsk C8 Chimera", "CED.rte");
		shot.Pos = self.MuzzlePos + Vector(0.1*self.FlipFactor, 0):RadRotate(self.RotAngle);
		shot.Vel = self.Vel + Vector(self.KhC8ChimeraFireVelocity * self.FlipFactor, spread):RadRotate(self.RotAngle);
		shot.Team = self.Team;
		shot.IgnoresTeamHits = true;
		shot:SetWhichMOToNotHit(ToMovableObject(self), 150);
		MovableMan:AddParticle(shot);
	end

	-- Use our HEATStats to spawn a casing every time we fire.
	local casing
	casing = self.HEATCasing:Clone();
	casing.Pos = self.EjectionPos;
	casing.Vel = self.Vel + Vector(self.HEATCasingVelocity.X * self.FlipFactor, self.HEATCasingVelocity.Y):RadRotate(self.RotAngle);
	casing.RotAngle = self.RotAngle;
	casing.HFlipped = self.HFlipped;
	MovableMan:AddParticle(casing);	
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
	self.HUDVisible = true;
end

function ThreadedUpdate(self)
	self.KhC8ChimeraWalkBeltSound.Pos = self.Pos;
	self.KhC8ChimeraDeploySound.Pos = self.Pos;
	self.KhC8ChimeraUndeploySound.Pos = self.Pos;

	if self.parent then
		self.HEATRotationTargetOverride = nil; -- Just reset these every frame to make sure
		self.HEATRotationTargetManualAddition = 0;	
	
		local isPlayerControlled = self.parent:IsPlayerControlled();
		local aimAngle = math.deg(self.parent:GetAimAngle(false));	
	
		local isMoving = (self.parentController:IsState(Controller.MOVE_LEFT) == true or self.parentController:IsState(Controller.MOVE_RIGHT) == true) or self.parent.Vel.Magnitude > 3;
		local isMovingFast = self.parent.MovementState == Actor.RUN or self.parent.Vel.Magnitude > 6;
		local isCrouching = (self.parentController:IsState(Controller.BODY_PRONE) == true) or (self.parentController:IsState(Controller.BODY_WALKCROUCH) == true);
		
		local heavyEnoughForWalkingFire = self.parent.IndividualMass >= 60;
		local heavyEnoughForRunningFire = self.parent.IndividualMass >= 90;
		
		local canDeploy;
		local standingDeploy = not isCrouching;
		if isCrouching and not isMoving then
			canDeploy = true;
			self.KhC8ChimeraAIFairnessEnabled = false;
		elseif heavyEnoughForWalkingFire and not isMovingFast then
			canDeploy = true;
			self.KhC8ChimeraAIFairnessEnabled = false;
		elseif heavyEnoughForRunningFire then
			canDeploy = true;
			self.KhC8ChimeraAIFairnessEnabled = false;
		elseif not isPlayerControlled then
			canDeploy = true;
			self.KhC8ChimeraAIFairnessEnabled = true;
		end
		
		local timeToUse = standingDeploy and self.KhC8ChimeraStandingDeployTime or self.KhC8ChimeraDeployTime;
		
		if self.KhC8ChimeraAIFairnessEnabled then
			if self.KhC8ChimeraAIFairnessTimer:IsPastSimMS(self.KhC8ChimeraAIFairnessTime) then
				self.KhC8ChimeraAIFairnessTime = math.random(2500, 4000)
				self.KhC8ChimeraAIFairnessTimer:Reset();
			elseif self.KhC8ChimeraAIFairnessTimer:IsPastSimMS(self.KhC8ChimeraAIFairnessTime / 1.5) then
				self:Deactivate();
				canDeploy = false;
				timeToUse = 200;
			end
		end		
		
		if canDeploy then
			-- Sound
			if not self.KhC8ChimeraDeploySoundPlayed then
				self.KhC8ChimeraDeploySoundPlayed = true;
				self.KhC8ChimeraUndeploySound:Stop(-1);
				if standingDeploy then
					if isPlayerControlled and not self:IsReloading() then
						self.KhC8ChimeraStandingDeploySound:Play(self.Pos);
					end
				else
					if isPlayerControlled and not self:IsReloading() then
						self.KhC8ChimeraDeploySound:Play(self.Pos);
					end
				end
			end
			
			self.HUDVisible = true;
			self.HEATRotationTargetOverride = nil;
			
			-- Fully deployed
			if self.KhC8ChimeraDeployTimer:IsPastSimMS(timeToUse) then
				self.HEATRotationTargetOverride = nil;
				self.HEATAngVelManualAddition = 0;
				
				if not self.KhC8ChimeraDeployed then
					self.KhC8ChimeraDeployed = true;
					self.HEATAngVelManualAddition = 5;
				end
				
				if not self:IsReloading() then
					if standingDeploy then
						self.HEATRecoilDamping = 0.35;
						self.HEATOriginalSharpLength = 50;
						self.SupportOffset = self.KhC8ChimeraOriginalSupportOffset;
						self.HEATOriginalSupportOffset = self.KhC8ChimeraOriginalSupportOffset;
					else
						self.HEATRecoilDamping = 0.35;
						self.HEATOriginalSharpLength = 170;
						self.SupportOffset = self.KhC8ChimeraDeployedSupportOffset;
						self.HEATOriginalSupportOffset = self.KhC8ChimeraDeployedSupportOffset;
					end
				else
					self.HEATOriginalSupportOffset = self.KhC8ChimeraOriginalSupportOffset;
				end
				
				self.KhC8ChimeraInvalidStanceGraceTimer:Reset();
			elseif self.KhC8ChimeraDeployTimer:IsPastSimMS(timeToUse / 1.5) then
				self.HEATRotationSpeed = 5;
				
				self.HEATOriginalSharpLength = 50;
				self.HEATRotationTargetOverride = 3;
			else
				self.HEATRotationSpeed = 3;
				self.HEATRotationTargetOverride = 20;
				self:Deactivate();
			end
		-- Not valid for deployment
		elseif self.KhC8ChimeraInvalidStanceGraceTimer:IsPastSimMS(self.KhC8ChimeraInvalidStanceGraceTime) then
			if self.KhC8ChimeraDeploySoundPlayed then
				if self.KhC8ChimeraDeployed then
					if isPlayerControlled and not self:IsReloading() then
						self.KhC8ChimeraUndeploySound:Play(self.Pos);
					end
				end
				self.KhC8ChimeraDeployed = false;
				self.KhC8ChimeraDeploySound:FadeOut(200);
				
				self.KhC8ChimeraDeploySoundPlayed = false;
				
				self.SupportOffset = self.KhC8ChimeraOriginalSupportOffset;
				self.HEATOriginalSupportOffset = self.KhC8ChimeraOriginalSupportOffset;
			end			

			self:Deactivate();			
			self.KhC8ChimeraDeployTimer:Reset();

			self.HUDVisible = false;
			self.parentController:SetState(Controller.AIM_SHARP, false)
			self.HEATOriginalSharpLength = 0;
			
			if self:IsReloading() then
				self.HEATRotationTargetOverride = 0;
				self.HEATRotationTargetManualAddition = 35 - aimAngle;
			else
				self.HEATRotationTargetOverride = 70 - aimAngle;
			end
			self.HEATRotationSpeed = 3;
		end
		if self.parent.StrideFrame then
			if not canDeploy then
				self.HEATAngVelManualAddition = 18;
			end
			if self.Magazine then
				self.KhC8ChimeraWalkBeltSound:Play(self.Pos);
			end
		else
			self.HEATAngVelManualAddition = 0;
		end		
	end

	if self.KhC8ChimeraAIFairnessEnabled then
		if self.KhC8ChimeraAIFairnessTimer:IsPastSimMS(self.KhC8ChimeraAIFairnessTime) then
			self.KhC8ChimeraAIFairnessTime = math.random(1500, 4000)
			self.KhC8ChimeraAIFairnessTimer:Reset();
		elseif self.KhC8ChimeraAIFairnessTimer:IsPastSimMS(self.KhC8ChimeraAIFairnessTime / 2) then
			self:Deactivate();
		end
	end
end