require("/CEDSettings");

function Create(self)
	self.KhAMAVogastir40FireVelocity = 110;
	self.KhAMAVogastir40FireSpread = 5 / 2;

	self.KhAMAVogastir40MechEndSound = CreateSoundContainer("Mech End CED Khrabarovsk AMA-Vogastir 40", "CED.rte");
	
	self.KhAMAVogastir40WalkSound = CreateSoundContainer("Walk CED Khrabarovsk AMA-Vogastir 40", "CED.rte");
	self.KhAMAVogastir40DeploySound = CreateSoundContainer("Deploy CED Khrabarovsk AMA-Vogastir 40", "CED.rte");
	self.KhAMAVogastir40StandingDeploySound = CreateSoundContainer("Standing Deploy CED Khrabarovsk AMA-Vogastir 40", "CED.rte");
	self.KhAMAVogastir40UndeploySound = CreateSoundContainer("Undeploy CED Khrabarovsk AMA-Vogastir 40", "CED.rte");

	self.KhAMAVogastir40Deployed = false;

	self.KhAMAVogastir40DeploySoundPlayed = false;
	self.KhAMAVogastir40UndeploySoundPlayed = false;
	
	self.KhAMAVogastir40InvalidStanceGraceTimer = Timer();
	self.KhAMAVogastir40InvalidStanceGraceTime = 400;
	self.KhAMAVogastir40DeployTimer = Timer();
	self.KhAMAVogastir40DeployTime = 1600;
	
	self.KhAMAVogastir40OriginalSupportOffset = Vector(math.abs(self.SupportOffset.X), self.SupportOffset.Y);
	self.KhAMAVogastir40DeployedSupportOffset = Vector(-5, -3);
	
	self.KhAMAVogastir40AIFairnessTimer = Timer();
	self.KhAMAVogastir40AIFairnessTime = 2000;
	self.KhAMAVogastir40AIFairnessEnabled = false;
	
	self.KhAMAVogastir40OriginalStanceOffset = Vector(math.abs(self.StanceOffset.X), self.StanceOffset.Y);
	
	self.CompliSoundGroundSmokeStr = 15;
end

function OnFire(self)
	CameraMan:AddScreenShake(7, self.Pos);

	self.KhAMAVogastir40MechEndSound:Play(self.Pos);
	
	local spread = math.random(-self.KhAMAVogastir40FireSpread, self.KhAMAVogastir40FireSpread);
	
	local shot = CreateMOSRotating("Explosive Shot CED Khrabarovsk AMA-Vogastir 40", "CED.rte");
	shot.Pos = self.MuzzlePos + Vector(0.1*self.FlipFactor, 0):RadRotate(self.RotAngle);
	shot.Vel = self.Vel + Vector(self.KhAMAVogastir40FireVelocity * self.FlipFactor, spread):RadRotate(self.RotAngle);
	shot.Team = self.Team;
	shot.IgnoresTeamHits = true;
	shot:SetWhichMOToNotHit(ToMovableObject(self), 150);
	MovableMan:AddParticle(shot);

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
	self.KhAMAVogastir40WalkSound.Pos = self.Pos;
	self.KhAMAVogastir40DeploySound.Pos = self.Pos;
	self.KhAMAVogastir40UndeploySound.Pos = self.Pos;

	if self.parent then
		self.HEATRotationTargetOverride = nil; -- Just reset these every frame to make sure
		self.HEATRotationTargetManualAddition = 0;
	
		local isPlayerControlled = self.parent:IsPlayerControlled();
		local aimAngle = math.deg(self.parent:GetAimAngle(false));	
	
		local isMoving = (self.parentController:IsState(Controller.MOVE_LEFT) == true or self.parentController:IsState(Controller.MOVE_RIGHT) == true) or self.parent.Vel.Magnitude > 3;
		local isCrouching = (self.parentController:IsState(Controller.BODY_PRONE) == true) or (self.parentController:IsState(Controller.BODY_WALKCROUCH) == true);
		
		local heavyEnoughForStandingFire = self.parent.IndividualMass >= 60;
		local heavyEnoughForMovingFire = self.parent.IndividualMass >= 90;
		
		local canDeploy;
		local standingDeploy = not isCrouching;
		if isCrouching and not isMoving then
			canDeploy = true;
			self.KhAMAVogastir40AIFairnessEnabled = false;
		elseif heavyEnoughForStandingFire and not isMoving then
			canDeploy = true;
			self.KhAMAVogastir40AIFairnessEnabled = false;
		elseif heavyEnoughForMovingFire then
			canDeploy = true;
			self.KhAMAVogastir40AIFairnessEnabled = false;
		elseif not isPlayerControlled then
			canDeploy = true;
			self.KhAMAVogastir40AIFairnessEnabled = true;
		end
		
		if canDeploy then
			-- Sound
			if not self.KhAMAVogastir40DeploySoundPlayed then
				self.KhAMAVogastir40DeploySoundPlayed = true;
				self.KhAMAVogastir40UndeploySound:Stop(-1);
				if standingDeploy then
					self.KhAMAVogastir40StandingDeploySound:Play(self.Pos);
				else
					self.KhAMAVogastir40DeploySound:Play(self.Pos);
				end
			end
			
			self.HUDVisible = true;
			self.HEATRotationTargetOverride = nil;
			
			local timeToUse = standingDeploy and self.KhAMAVogastir40StandingDeployTime or self.KhAMAVogastir40DeployTime;
			-- Fully deployed
			if self.KhAMAVogastir40DeployTimer:IsPastSimMS(timeToUse) then
				self.HEATRotationTargetOverride = nil;
				self.HEATAngVelManualAddition = 0;
				
				if not self.KhAMAVogastir40Deployed then
					self.KhAMAVogastir40Deployed = true;
					self.HEATAngVelManualAddition = 5;
				end
				
				if not self:IsReloading() then
					if standingDeploy then
						self.HEATRecoilDamping = 0.35;
						self.HEATOriginalSharpLength = 50;
						self.SupportOffset = self.KhAMAVogastir40OriginalSupportOffset;
						self.HEATOriginalSupportOffset = self.KhAMAVogastir40OriginalSupportOffset;
					else
						self.HEATRecoilDamping = 0.35;
						self.HEATOriginalSharpLength = 170;
						self.SupportOffset = self.KhAMAVogastir40DeployedSupportOffset;
						self.HEATOriginalSupportOffset = self.KhAMAVogastir40DeployedSupportOffset;
					end
				else
					self.HEATOriginalSupportOffset = self.KhAMAVogastir40OriginalSupportOffset;
				end
				
				self.KhAMAVogastir40InvalidStanceGraceTimer:Reset();
			elseif self.KhAMAVogastir40DeployTimer:IsPastSimMS(timeToUse / 1.5) then
				self.HEATRotationSpeed = 5;
				
				self.HEATOriginalSharpLength = 50;
				self.HEATRotationTargetOverride = 3;
			else
				self.HEATRotationSpeed = 3;
				self.HEATRotationTargetOverride = 20;
				self:Deactivate();
			end
		-- Not valid for deployment
		elseif self.KhAMAVogastir40InvalidStanceGraceTimer:IsPastSimMS(self.KhAMAVogastir40InvalidStanceGraceTime) then
			if self.KhAMAVogastir40DeploySoundPlayed then
				if self.KhAMAVogastir40Deployed then
					self.KhAMAVogastir40UndeploySound:Play(self.Pos);
				end
				self.KhAMAVogastir40Deployed = false;
				self.KhAMAVogastir40DeploySound:FadeOut(200);
				
				self.KhAMAVogastir40DeploySoundPlayed = false;
				
				self.SupportOffset = self.KhAMAVogastir40OriginalSupportOffset;
				self.HEATOriginalSupportOffset = self.KhAMAVogastir40OriginalSupportOffset;
			end			

			self:Deactivate();			
			self.KhAMAVogastir40DeployTimer:Reset();

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
				self.KhAMAVogastir40WalkSound:Play(self.Pos);
			end
		else
			self.HEATAngVelManualAddition = 0;
		end
	end

	if self.KhAMAVogastir40AIFairnessEnabled then
		if self.KhAMAVogastir40AIFairnessTimer:IsPastSimMS(self.KhAMAVogastir40AIFairnessTime) then
			self.KhAMAVogastir40AIFairnessTime = math.random(1500, 4000)
			self.KhAMAVogastir40AIFairnessTimer:Reset();
		elseif self.KhAMAVogastir40AIFairnessTimer:IsPastSimMS(self.KhAMAVogastir40AIFairnessTime / 2) then
			self:Deactivate();
		end
	end
end