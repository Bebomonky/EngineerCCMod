require("/CEDSettings");

function Create(self)

	self.KhC8ChimeraMechEndSound = CreateSoundContainer("Mech End CED Khrabarovsk C8 Chimera", "CED.rte");
	
	
	self.KhC8ChimeraWalkBeltSound = CreateSoundContainer("Walk Belt CED Khrabarovsk C8 Chimera", "CED.rte");
	self.KhC8ChimeraDeploySound = CreateSoundContainer("Deploy CED Khrabarovsk C8 Chimera", "CED.rte");
	self.KhC8ChimeraStandingDeploySound = CreateSoundContainer("Standing Deploy CED Khrabarovsk C8 Chimera", "CED.rte");
	self.KhC8ChimeraUndeploySound = CreateSoundContainer("Undeploy CED Khrabarovsk C8 Chimera", "CED.rte");

	self.KhC8ChimeraDeployed = false;
	self.KhC8ChimeraInvalidlyDeployed = false;
	self.KhC8ChimeraDeploySoundPlayed = false;
	self.KhC8ChimeraUndeploySoundPlayed = false;
	self.KHC8ChimeraInvalidStanceGraceTimer = Timer();
	self.KHC8ChimeraInvalidStanceGraceTime = 400;
	self.KhC8ChimeraDeployTimer = Timer();
	self.KhC8ChimeraDeployTime = 1000;
	
	self.KhC8ChimeraAIFairnessTimer = Timer();
	self.KhC8ChimeraAIFairnessTime = 1000;
	self.KhC8ChimeraAIFairnessEnabled = false;
	
	self.KhC8ChimeraOriginalStanceOffset = Vector(math.abs(self.StanceOffset.X), self.StanceOffset.Y);
end

function OnFire(self)
	self.KhC8ChimeraMechEndSound:Play(self.Pos);

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
	if IsActor(newParent:GetRootParent()) then
		self.parent = ToActor(newParent:GetRootParent());
	end
end

function OnDetach(self)
	self.parent = nil;
	self.HUDVisible = true;
end

function ThreadedUpdate(self)
	self.KhC8ChimeraWalkBeltSound.Pos = self.Pos;
	self.KhC8ChimeraDeploySound.Pos = self.Pos;
	self.KhC8ChimeraUndeploySound.Pos = self.Pos;

	if self.parent then
		local controller = self.parent:GetController();
		local isMoving = (controller:IsState(Controller.MOVE_LEFT) == true or controller:IsState(Controller.MOVE_RIGHT) == true);
		local isNotCrouching = (controller:IsState(Controller.MOVE_DOWN) == false);
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
			if self.KHC8ChimeraInvalidStanceGraceTimer:IsPastSimMS(self.KHC8ChimeraInvalidStanceGraceTime) then
				if self.KhC8ChimeraDeployed then
					self.KhC8ChimeraDeployed = false;
					self.KhC8ChimeraDeploySound:FadeOut(200);
					self.KhC8ChimeraUndeploySound:Play(self.Pos);
					
					self.KhC8ChimeraDeploySoundPlayed = false;
				end
				
				self.KhC8ChimeraDeployTimer:Reset();

				self.HUDVisible = false;
				controller:SetState(Controller.AIM_SHARP, false)
				self.HEATOriginalSharpLength = 0;
				
				self.HEATRotationTargetOverride = 70 - aimAngle;
				self.HEATRotationSpeed = 3;
				
				if IsAHuman(self.parent) and ToAHuman(self.parent).StrideFrame then
					self.HEATAngVelOverride = 18;
					if self.Magazine then
						self.KhC8ChimeraWalkBeltSound:Play(self.Pos);
					end
				else
					self.HEATAngVelOverride = 0;
				end
			end
		else
			if not self.KhC8ChimeraDeploySoundPlayed then
				self.KhC8ChimeraDeploySoundPlayed = true;
				self.KhC8ChimeraUndeploySound:Stop(-1);
				if invalidStance then
					self.KhC8ChimeraStandingDeploySound:Play(self.Pos);
				else
					self.KhC8ChimeraDeploySound:Play(self.Pos);
				end
			end
				
			self.HUDVisible = true;
			self.HEATRotationTargetOverride = nil;
			
			if self.KhC8ChimeraDeployTimer:IsPastSimMS(self.KhC8ChimeraDeployTime) or validnessOverride then
				self.KHC8ChimeraInvalidStanceGraceTimer:Reset();
				self.HEATRotationSpeed = 9;
				self.HEATAngVelOverride = 0;
				if not self.KhC8ChimeraDeployed then
					self.KhC8ChimeraDeployed = true;
					self.HEATAngVelOverride = 5;
				end
				self.HEATRotationTargetOverride = nil;
				
				self.HEATOriginalSharpLength = 170;
				self.HEATRecoilStrength = 8
				self.HEATRecoilDamping = 0.55
				self.HEATRecoilMax = 4;
				self.SharpShakeRange = 3;
				self.ShakeRange = 5;				
				
				if invalidStance then
					if not self.KhC8ChimeraInvalidlyDeployed then
						self.KhC8ChimeraInvalidlyDeployed = true;
						self.KhC8ChimeraDeploySound:FadeOut(200);
						self.KhC8ChimeraUndeploySound:Play(self.Pos);
					end
					if isPlayerControlled then
						self.HEATOriginalSharpLength = 50;
						self.HEATRecoilStrength = 14
						self.HEATRecoilDamping = 0.2
						self.HEATRecoilMax = 12;
						self.SharpShakeRange = 6;
						self.ShakeRange = 6;
					end
					
					-- AI fairness stuff if they shouldn't be firing at all during this time
					if (isMoving and not superHeavy) or not heavyEnoughForStandingFire then
						if self.KhC8ChimeraAIFairnessTimer:IsPastSimMS(self.KhC8ChimeraAIFairnessTime) then
							if self.KhC8ChimeraAIFairnessEnabled then
								self.KhC8ChimeraAIFairnessEnabled = false;
							else
								self.KhC8ChimeraAIFairnessEnabled = true;
							end
							self.KhC8ChimeraAIFairnessTime = math.random(1000, 2000)
							self.KhC8ChimeraAIFairnessTimer:Reset();
						end
					else
						self.KhC8ChimeraAIFairnessEnabled = false;
					end
				else
					if self.KhC8ChimeraInvalidlyDeployed then
						self.KhC8ChimeraDeployTimer:Reset();
						self.KhC8ChimeraDeploySoundPlayed = false;
						self.KhC8ChimeraInvalidlyDeployed = false;
					end
				end
				
				if not isPlayerControlled then
					self.HEATRecoilMax = 0; -- they just can't deal with it...
				end
				
			elseif self.KhC8ChimeraDeployTimer:IsPastSimMS(self.KhC8ChimeraDeployTime / 3) then
				self.HEATRotationSpeed = 5;
				
				self.HEATOriginalSharpLength = 50;
				self.HEATRotationTargetOverride = 3;
			else
				self.HEATRotationSpeed = 3;
				self.HEATRotationTargetOverride = 20;
			end
		end
	end
	if not self.KhC8ChimeraDeployed then
		self:Deactivate();
	end
	
	if self.KhC8ChimeraAIFairnessEnabled then
		self:Deactivate();
	end
	
end