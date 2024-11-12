require("/CEDSettings");

function Create(self)
	self.KhAMAVogastir40FireVelocity = 140;
	self.KhAMAVogastir40FireSpread = 5 / 2;

	self.KhAMAVogastir40MechEndSound = CreateSoundContainer("Mech End CED Khrabarovsk AMA-Vogastir 40", "CED.rte");
	
	self.KhAMAVogastir40WalkBeltSound = CreateSoundContainer("Walk CED Khrabarovsk AMA-Vogastir 40", "CED.rte");
	self.KhAMAVogastir40DeploySound = CreateSoundContainer("Deploy CED Khrabarovsk AMA-Vogastir 40", "CED.rte");
	self.KhAMAVogastir40StandingDeploySound = CreateSoundContainer("Standing Deploy CED Khrabarovsk AMA-Vogastir 40", "CED.rte");
	self.KhAMAVogastir40UndeploySound = CreateSoundContainer("Undeploy CED Khrabarovsk AMA-Vogastir 40", "CED.rte");

	self.KhAMAVogastir40Deployed = false;
	self.KhAMAVogastir40InvalidlyDeployed = false;
	self.KhAMAVogastir40DeploySoundPlayed = false;
	self.KhAMAVogastir40UndeploySoundPlayed = false;
	self.KhAMAVogastir40InvalidStanceGraceTimer = Timer();
	self.KhAMAVogastir40InvalidStanceGraceTime = 400;
	self.KhAMAVogastir40DeployTimer = Timer();
	self.KhAMAVogastir40DeployTime = 1600;
	
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
	self.KhAMAVogastir40WalkBeltSound.Pos = self.Pos;
	self.KhAMAVogastir40DeploySound.Pos = self.Pos;
	self.KhAMAVogastir40UndeploySound.Pos = self.Pos;

	if self.parent then
		local isMoving = (self.parentController:IsState(Controller.MOVE_LEFT) == true or self.parentController:IsState(Controller.MOVE_RIGHT) == true);
		local isNotCrouching = (self.parentController:IsState(Controller.BODY_PRONE) == false) and (self.parentController:IsState(Controller.BODY_WALKCROUCH) == false);
		-- I tried a lot to get this neater, but without an if statement it goes weird and returns nil for no reason... very strange
		local invalidStance;
		if isMoving or isNotCrouching then
			invalidStance = true;
		end
		local heavyEnoughForStandingFire = self.parent.IndividualMass >= 60;
		local superHeavy = self.parent.IndividualMass >= 90;
		local isPlayerControlled = self.parent:IsPlayerControlled();
		local validnessOverride = (heavyEnoughForStandingFire and not isMoving) or (superHeavy) or not isPlayerControlled;
		local aimAngle = math.deg(self.parent:GetAimAngle(false));
		
		if (invalidStance or self.parent.Vel.Magnitude > 3) and not self:IsReloading() and not validnessOverride then
			if self.KhAMAVogastir40InvalidStanceGraceTimer:IsPastSimMS(self.KhAMAVogastir40InvalidStanceGraceTime) then
				if self.KhAMAVogastir40Deployed then
					self.KhAMAVogastir40Deployed = false;
					self.KhAMAVogastir40DeploySound:FadeOut(200);
					self.KhAMAVogastir40UndeploySound:Play(self.Pos);
					
					self.KhAMAVogastir40DeploySoundPlayed = false;
				end
				
				self.KhAMAVogastir40DeployTimer:Reset();

				self.HUDVisible = false;
				self.parentController:SetState(Controller.AIM_SHARP, false)
				self.HEATOriginalSharpLength = 0;
				
				self.HEATRotationTargetOverride = 70 - aimAngle;
				self.HEATRotationSpeed = 3;
				
				if IsAHuman(self.parent) and ToAHuman(self.parent).StrideFrame then
					self.HEATAngVelOverride = 18;
					if self.Magazine then
						self.KhAMAVogastir40WalkBeltSound:Play(self.Pos);
					end
				else
					self.HEATAngVelOverride = 0;
				end
			end
		else
			if not self.KhAMAVogastir40DeploySoundPlayed then
				self.KhAMAVogastir40DeploySoundPlayed = true;
				self.KhAMAVogastir40UndeploySound:Stop(-1);
				if invalidStance then
					self.KhAMAVogastir40StandingDeploySound:Play(self.Pos);
				else
					self.KhAMAVogastir40DeploySound:Play(self.Pos);
				end
			end
				
			self.HUDVisible = true;
			self.HEATRotationTargetOverride = nil;
			
			if self.KhAMAVogastir40DeployTimer:IsPastSimMS(self.KhAMAVogastir40DeployTime) or validnessOverride then
				self.KhAMAVogastir40InvalidStanceGraceTimer:Reset();
				self.HEATRotationSpeed = 9;
				self.HEATAngVelOverride = 0;
				if not self.KhAMAVogastir40Deployed then
					self.KhAMAVogastir40Deployed = true;
					self.KhAMAVogastir40AIFairnessEnabled = false;
					self.HEATAngVelOverride = 5;
				end
				self.HEATRotationTargetOverride = nil;
				
				self.HEATOriginalSharpLength = 170;
				self.HEATRecoilStrength = 25
				self.HEATRecoilDamping = 0.55
				self.HEATRecoilMax = 4;
				self.SharpShakeRange = 3;
				self.ShakeRange = 5;				
				
				if invalidStance then
					if not self.KhAMAVogastir40InvalidlyDeployed then
						self.KhAMAVogastir40InvalidlyDeployed = true;
						self.KhAMAVogastir40DeploySound:FadeOut(200);
						self.KhAMAVogastir40UndeploySound:Play(self.Pos);
					end
					if isPlayerControlled then
						self.HEATOriginalSharpLength = 50;
						self.HEATRecoilStrength = 30
						self.HEATRecoilDamping = 0.2
						self.HEATRecoilMax = 12;
						self.SharpShakeRange = 6;
						self.ShakeRange = 6;
					end
					
					-- AI fairness stuff if they shouldn't be firing at all during this time
					if (isMoving and not superHeavy) or not heavyEnoughForStandingFire then
						if self.KhAMAVogastir40AIFairnessTimer:IsPastSimMS(self.KhAMAVogastir40AIFairnessTime) then
							if self.KhAMAVogastir40AIFairnessEnabled then
								self.KhAMAVogastir40AIFairnessEnabled = false;
							else
								self.KhAMAVogastir40AIFairnessEnabled = true;
							end
							self.KhAMAVogastir40AIFairnessTime = math.random(1000, 3000)
							self.KhAMAVogastir40AIFairnessTimer:Reset();
						end
					end
				else
					if self.KhAMAVogastir40InvalidlyDeployed then
						self.KhAMAVogastir40DeployTimer:Reset();
						self.KhAMAVogastir40DeploySoundPlayed = false;
						self.KhAMAVogastir40AIFairnessEnabled = false;
						self.KhAMAVogastir40InvalidlyDeployed = false;
					end
				end
			elseif self.KhAMAVogastir40DeployTimer:IsPastSimMS(self.KhAMAVogastir40DeployTime / 3) then
				self.HEATRotationSpeed = 5;
				
				self.HEATOriginalSharpLength = 50;
				self.HEATRotationTargetOverride = 3;
			else
				self.HEATRotationSpeed = 3;
				self.HEATRotationTargetOverride = 20;
			end
		end
		if isPlayerControlled and not self.KhAMAVogastir40Deployed then
			self:Deactivate();
		end
	end
end