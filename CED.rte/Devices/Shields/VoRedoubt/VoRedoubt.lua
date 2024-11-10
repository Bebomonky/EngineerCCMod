require("/CEDSettings");

function Create(self)
	self.VoRedoubtWalkSound = CreateSoundContainer("Walk CED Vossberg Redoubt", "CED.rte");
	self.VoRedoubtEquipSound = CreateSoundContainer("Equip CED Vossberg Redoubt", "CED.rte");
	self.VoRedoubtDropSound = CreateSoundContainer("Drop CED Vossberg Redoubt", "CED.rte");
	self.VoRedoubtDeploySound = CreateSoundContainer("Deploy CED Vossberg Redoubt", "CED.rte");
	self.VoRedoubtUndeploySound = CreateSoundContainer("Undeploy CED Vossberg Redoubt", "CED.rte");
	self.VoRedoubtHeavyHitReactionSound = CreateSoundContainer("Heavy Hit Reaction CED Vossberg Redoubt", "CED.rte");
	
	self.VoRedoubtOriginalStanceOffset = Vector(math.abs(self.StanceOffset.X), self.StanceOffset.Y);
	self.VoRedoubtDeployingStanceOffset = self.VoRedoubtOriginalStanceOffset + Vector(12, -4);
	self.VoRedoubtDeployedStanceOffset = self.VoRedoubtOriginalStanceOffset + Vector(11, 2);
	
	self.VoRedoubtAlternateStrideNum = 0;
	
	self.VoRedoubtDeployed = false;
	self.VoRedoubtDeploying = false;
	self.VoRedoubtDeployTimer = Timer();
	self.VoRedoubtDeployTime = 300;
	
	self.VoRedoubtUndeployedJointStiffness = 0.5
	self.VoRedoubtDeployedJointStiffness = 0.05;
	
	self.VoRedoubtUndeployedGripStrengthMultiplier = 2;
	self.VoRedoubtDeployedGripStrengthMultiplier = 10;
	
	self.VoRedoubtWoundCounter = self.WoundCount;
	self.VoRedoubtGlassWoundCounter = self.WoundCount;
	self.VoRedoubtHitReactionWoundCounter = self.WoundCount;
	self.VoRedoubtCountingWounds = false;
	self.VoRedoubtWoundCountTimer = Timer();
	
	for att in self.Attachables do
		if att.PresetName == "Glass CED Vossberg Redoubt" then
			self.VoRedoubtGlassAttachment = att;
			self.VoRedoubtGlassWoundCount = att.WoundCount;
		end
	end
end
					
function OnAttach(self, newParent)
	self.VoRedoubtAlternateStrideSound = 0;
	self.VoRedoubtToPlayTerrainImpact = false;
	
	self.VoRedoubtEquipSound:Play(self.Pos);
	
	if IsAHuman(newParent:GetRootParent()) then
		self.parent = ToAHuman(newParent:GetRootParent());
		self.parentController = self.parent:GetController();
	end
end

function OnDetach(self)
	self.VoRedoubtEquipSound:Stop(-1);
	
	self.VoRedoubtToPlayTerrainImpact = true;
	
	self.parent = nil;
	self.parentController = nil;
end

function OnCollideWithTerrain(self)
	if self.VoRedoubtToPlayTerrainImpact then
		self.VoRedoubtToPlayTerrainImpact = false;
		self.VoRedoubtDropSound:Play(self.Pos);
	end
end

function ThreadedUpdate(self)
	self.VoRedoubtWalkSound.Pos = self.Pos;
	self.VoRedoubtEquipSound.Pos = self.Pos;
	self.VoRedoubtDropSound.Pos = self.Pos;
	self.VoRedoubtDeploySound.Pos = self.Pos;
	self.VoRedoubtUndeploySound.Pos = self.Pos;
	self.VoRedoubtHeavyHitReactionSound.Pos = self.Pos;
	
	if self.VoRedoubtGlassAttachment then
		self.VoRedoubtGlassWoundCount = self.VoRedoubtGlassAttachment.WoundCount;
	end

	if self.parent then
		local isCrouching = self.parentController:IsState(Controller.BODY_WALKCROUCH); -- can't check movement state because it's also triggered by low ceilings
		local isMoving = self.parent.MovementState == Actor.WALK;
		local isMovingFast = self.parent.Vel.Magnitude > 5;
		
		if self.parent.StrideFrame then
			if self.VoRedoubtAlternateStrideNum == 0 then
				self.VoRedoubtWalkSound:Play(self.Pos);
				self.VoRedoubtAlternateStrideNum = 1;
			else
				self.VoRedoubtAlternateStrideNum = 0;
			end
		end
		
		if isCrouching and (not isMoving) and (not isMovingFast) then
			self.parentController:SetState(Controller.WEAPON_FIRE, false);
			self.parentController:SetState(Controller.AIM_SHARP, false);
			if not self.VoRedoubtDeploying then
				self.VoRedoubtDeploying = true;
				self.VoRedoubtDeploySound:Play(self.Pos);
				self.VoRedoubtDeployTimer:Reset();
				self.StanceOffset = self.VoRedoubtDeployingStanceOffset;
			elseif self.VoRedoubtDeployTimer:IsPastSimMS(self.VoRedoubtDeployTime) then
				if not self.VoRedoubtDeployed then
					CameraMan:AddScreenShake(7, self.Pos);
					self.Frame = self.FrameCount - 1;
					self.VoRedoubtDeployed = true;
					self.JointStiffness = self.VoRedoubtDeployedJointStiffness;
					self.GripStrengthMultiplier = self.VoRedoubtDeployedGripStrengthMultiplier;
					self.StanceOffset = self.VoRedoubtDeployedStanceOffset;
					self:SetEntryWound("Dent Metal Bolted CED Vossberg Redoubt", "CED.rte");
										
					-- FX
					for i = 1, 4 do						
						local effect = CreateMOSRotating("CompliSound Ground Smoke Particle Small", "0CompliSoundEmporium.rte")
						effect.Pos = self.Pos + Vector(RangeRand(-1,1), RangeRand(-1,1)) * 3
						effect.Vel = self.Vel + Vector(math.random(-20, 20), 50):RadRotate(math.pi / 4 * i / 10):RadRotate(self.RotAngle);
						effect.Lifetime = 50
						effect.AirResistance = effect.AirResistance * RangeRand(0.5,0.8)
						MovableMan:AddParticle(effect)
					end
					
					for i = 1, 2 do				
						local effect = CreateMOSRotating("CompliSound Ground Smoke Particle Large", "0CompliSoundEmporium.rte")
						effect.Pos = self.Pos + Vector(RangeRand(-1,1), RangeRand(-1,1)) * 3
						effect.Vel = self.Vel + Vector(math.random(-20, 20), 50):RadRotate(math.pi / 2 * i / 10):RadRotate(self.RotAngle);
						effect.Lifetime = 50
						effect.AirResistance = effect.AirResistance * RangeRand(0.5,0.8)
						MovableMan:AddParticle(effect)
					end			
					
				else
					if self.WoundCount > self.VoRedoubtWoundCounter then
						if not self.VoRedoubtCountingWounds then
							self.VoRedoubtCountingWounds = true;
							self.VoRedoubtWoundCountTimer:Reset();
						end
						self.GibWoundLimit = self.GibWoundLimit + (self.WoundCount - self.VoRedoubtWoundCounter);
						self.VoRedoubtWoundCounter = self.WoundCount;
					end
					
					if self.VoRedoubtCountingWounds and self.VoRedoubtWoundCountTimer:IsPastSimMS(100) then
						self.VoRedoubtCountingWounds = false;
						local glassWounds = self.VoRedoubtGlassWoundCount and self.VoRedoubtGlassWoundCount or 0;
						if self.WoundCount + self.VoRedoubtGlassWoundCount - self.VoRedoubtHitReactionWoundCounter > 5 then
							self.VoRedoubtHeavyHitReactionSound:Play(self.Pos);
						end
						self.VoRedoubtHitReactionWoundCounter = self.WoundCount + glassWounds;
					end
					
				end	
			else
				self.Frame = 1;
			end
		else
			self.VoRedoubtHitReactionWoundCounter = self.WoundCount;
			if self.VoRedoubtDeployed or self.VoRedoubtDeploying then
				self.VoRedoubtDeployed = false;
				self.VoRedoubtDeploying = false;
				self.VoRedoubtDeploySound:FadeOut(300);
				self.VoRedoubtUndeploySound:Play(self.Pos);
				self.JointStiffness = self.VoRedoubtUndeployedJointStiffness;
				self.GripStrengthMultiplier = self.VoRedoubtUndeployedGripStrengthMultiplier;
				self.StanceOffset = self.VoRedoubtOriginalStanceOffset;
				self:SetEntryWound("Dent Metal CED Vossberg Redoubt", "CED.rte");
				
				self.VoRedoubtCountingWounds = false;
			end
			if self.Frame > 0 then
				self.Frame = self.Frame - 1;
			end
		end
	end
end