require("/CEDSettings");

function Create(self)
	self.VoRedoubtWalkSound = CreateSoundContainer("Walk CED Vossberg Redoubt", "CED.rte");
	self.VoRedoubtSprintSound = CreateSoundContainer("Sprint CED Vossberg Redoubt", "CED.rte");
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
	
	self.VoRedoubtActualGibWoundLimit = 90;
	self.GibWoundLimit = 999; -- Not quite invincible, just to make sure
	self.VoRedoubtEffectiveWoundCount = self:NumberValueExists("VoRedoubt_EffectiveWoundCount") and self:GetNumberValue("VoRedoubt_EffectiveWoundCount") or 0;
	self.VoRedoubtPreviousWoundCounter = self.WoundCount;
	
	self.VoRedoubtHitReactionStartingWounds = 0;
	self.VoRedoubtHitReactionCountingWounds = false;
	self.VoRedoubtHitReactionWoundCountTimer = Timer();
	
	local i = 1;
	for att in self.Attachables do
		self.VoRedoubtPreviousWoundCounter = self.VoRedoubtPreviousWoundCounter + att.WoundCount;
		
		if att.PresetName == "Top Extension CED Vossberg Redoubt" then
			att.Frame = 1;
			self.VoRedoubtTopExtensionAttachment = att;
			self.VoRedoubtTopExtensionAttachment.GetsHitByMOs = false;
		end		
		
		i = i + 1;
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
	self.VoRedoubtSprintSound.Pos = self.Pos;
	self.VoRedoubtEquipSound.Pos = self.Pos;
	self.VoRedoubtDropSound.Pos = self.Pos;
	self.VoRedoubtDeploySound.Pos = self.Pos;
	self.VoRedoubtUndeploySound.Pos = self.Pos;
	self.VoRedoubtHeavyHitReactionSound.Pos = self.Pos;
	
	local totalWoundCount = self.WoundCount;
	
	local i = 1;
	for att in self.Attachables do
		totalWoundCount = totalWoundCount + att.WoundCount;
		
		i = i + 1;
	end

	if self.parent then
		local isCrouching = self.parentController:IsState(Controller.BODY_WALKCROUCH); -- can't check crouch movement state because it's also triggered by low ceilings
		local isMoving = self.parent.MovementState == Actor.WALK or self.parent.MovementState == Actor.CRAWL;
		local isMovingFast = self.parent.Vel.Magnitude > 5;
		local isSprinting = self.parent.MovementState == Actor.RUN;
		
		if self.parent.StrideFrame then
			local sound = isSprinting and self.VoRedoubtSprintSound or self.VoRedoubtWalkSound;
		
			if self.VoRedoubtAlternateStrideNum == 0 or isSprinting then
				sound:Play(self.Pos);
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
					
					if self.VoRedoubtTopExtensionAttachment then
						self.VoRedoubtTopExtensionAttachment.GetsHitByMOs = true;
						self.VoRedoubtTopExtensionAttachment:SetEntryWound("Dent Metal Bolted CED Vossberg Redoubt", "CED.rte");
					end
										
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

					if totalWoundCount > self.VoRedoubtPreviousWoundCounter then
						-- Start heavy hit reaction logic
						if not self.VoRedoubtCountingWounds then
							--print("Began counting effective wounds! Starting number: "	.. tostring(self.VoRedoubtEffectiveWoundCount));
							self.VoRedoubtCountingWounds = true;
							self.VoRedoubtHitReactionStartingWounds = self.VoRedoubtEffectiveWoundCount;
							self.VoRedoubtHitReactionWoundCountTimer:Reset();
						end
						
						-- Ignore single wounds, and halve any received wounds above 1
						if totalWoundCount - self.VoRedoubtPreviousWoundCounter > 1 then
						
							--print("Received enough wounds to change Effective WC. Received wounds: " .. tostring(totalWoundCount - self.VoRedoubtPreviousWoundCounter));
							self.VoRedoubtEffectiveWoundCount = self.VoRedoubtEffectiveWoundCount + ((totalWoundCount - self.VoRedoubtPreviousWoundCounter) / 2);
						
						--	print("New effective wound count: "	.. tostring(self.VoRedoubtEffectiveWoundCount));
						end
					end	
					
					-- Check counted wounds to see if we should play hit reaction
					if self.VoRedoubtCountingWounds and self.VoRedoubtHitReactionWoundCountTimer:IsPastSimMS(100) then
						self.VoRedoubtCountingWounds = false;
						--print("Finished counting. Effective wound count now: " .. tostring(self.VoRedoubtEffectiveWoundCount));
						--print("Reminder we started counting with: " .. tostring(self.VoRedoubtHitReactionStartingWounds));
						--print("Counted this many effective wounds: " .. tostring(self.VoRedoubtEffectiveWoundCount - self.VoRedoubtHitReactionStartingWounds));
						if self.VoRedoubtEffectiveWoundCount - self.VoRedoubtHitReactionStartingWounds > 5 then
							self.VoRedoubtHeavyHitReactionSound:Play(self.Pos);
						end
					end
				end	
			else
				self.Frame = 1;
			end
		else
			if self.VoRedoubtDeployed or self.VoRedoubtDeploying then
				self.VoRedoubtDeployed = false;
				self.VoRedoubtDeploying = false;
				self.VoRedoubtDeploySound:FadeOut(300);
				self.VoRedoubtUndeploySound:Play(self.Pos);
				self.JointStiffness = self.VoRedoubtUndeployedJointStiffness;
				self.GripStrengthMultiplier = self.VoRedoubtUndeployedGripStrengthMultiplier;
				self.StanceOffset = self.VoRedoubtOriginalStanceOffset;
				self:SetEntryWound("Dent Metal CED Vossberg Redoubt", "CED.rte");
				
				if self.VoRedoubtTopExtensionAttachment then
					self.VoRedoubtTopExtensionAttachment.GetsHitByMOs = false;
					self.VoRedoubtTopExtensionAttachment:SetEntryWound("Dent Metal CED Vossberg Redoubt", "CED.rte");
					
					-- Clear all its wounds visually - we count them anyway elsewhere
					self.VoRedoubtTopExtensionAttachment:RemoveWounds(self.VoRedoubtTopExtensionAttachment.WoundCount);
				end
				
				self.VoRedoubtCountingWounds = false;
			end
			if self.Frame > 0 then
				self.Frame = self.Frame - 1;
			end
			-- Add any wounds received directly to our effective wound count when not deployed
			if totalWoundCount - self.VoRedoubtPreviousWoundCounter > 0 then
				--print("Received straight wounds! Number: " .. tostring(totalWoundCount - self.VoRedoubtPreviousWoundCounter));
				self.VoRedoubtEffectiveWoundCount = self.VoRedoubtEffectiveWoundCount + (totalWoundCount - self.VoRedoubtPreviousWoundCounter);
				--print("New effective WC: " .. tostring(self.VoRedoubtEffectiveWoundCount));
			end	
		end
	end
	
	if self.VoRedoubtEffectiveWoundCount > self.VoRedoubtActualGibWoundLimit then
		self:GibThis();
	end
	
	self.VoRedoubtPreviousWoundCounter = totalWoundCount;
end

function OnSave(self)
	self:SetNumberValue("VoRedoubt_EffectiveWoundCount", self.VoRedoubtEffectiveWoundCount);
end