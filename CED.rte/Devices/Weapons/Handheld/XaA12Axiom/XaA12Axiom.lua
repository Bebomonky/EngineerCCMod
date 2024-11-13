require("/CEDSettings");

function Create(self)
	self.XaA12AxiomFireVelocity = 110;
	self.XaA12AxiomFireSpread = 0.5 / 2;

	self.XaA12AxiomPreSound = CreateSoundContainer("Pre CED Xarix A-12 Axiom", "CED.rte");
	self.XaA12AxiomChargeSound = CreateSoundContainer("Charge CED Xarix A-12 Axiom", "CED.rte");
	
	self.XaA12AxiomHeatReleaseLightSound = CreateSoundContainer("Heat Release Light CED Xarix A-12 Axiom", "CED.rte");
	self.XaA12AxiomHeatReleaseHeavySound = CreateSoundContainer("Heat Release Heavy CED Xarix A-12 Axiom", "CED.rte");
	
	self.XaA12AxiomShotSound = CreateSoundContainer("Shot CED Xarix A-12 Axiom", "CED.rte");
	self.XaA12AxiomChargedShotSound = CreateSoundContainer("Charged Shot CED Xarix A-12 Axiom", "CED.rte");
	
	self.XaA12AxiomHeatMechSound = CreateSoundContainer("Mech CED Xarix A-12 Axiom", "CED.rte");
	self.XaA12AxiomHeatMechChargedSound = CreateSoundContainer("Mech Charged CED Xarix A-12 Axiom", "CED.rte");

	self.XaA12AxiomCharging = false;
	self.XaA12AxiomChargingTimer = Timer();
	self.XaA12AxiomChargingHoldTime = 170;
	self.XaA12AxiomChargingChargeTime = 250;
	
	self.XaA12AxiomShotCounter = 0;
end

function OnFire(self)
	self.XaA12AxiomShotCounter = self.XaA12AxiomShotCounter + 1;
	
	local spread = math.random(-self.XaA12AxiomFireSpread, self.XaA12AxiomFireSpread);

	local shot = CreateMOPixel("Particle CED Xarix A-12 Axiom Plasma Shot", "CED.rte");
	shot.Pos = self.MuzzlePos + Vector(0.1*self.FlipFactor, 0):RadRotate(self.RotAngle);
	shot.Vel = self.Vel + Vector(self.XaA12AxiomFireVelocity * self.FlipFactor, spread):RadRotate(self.RotAngle);
	shot.Team = self.Team;
	shot.IgnoresTeamHits = true;
	shot:SetWhichMOToNotHit(ToMovableObject(self), 150);
	MovableMan:AddParticle(shot);
	self.HEATDelayedFireTimeMS = 50;
	
	if self.XaA12AxiomChargedShot then
		self.XaA12AxiomChargedShot = false;
		self.XaA12AxiomHeatMechChargedSound:Play(self.Pos);
		self.XaA12AxiomChargedShotSound:Play(self.Pos);
		shot:SendMessage("XaA12AxiomCharged");
		shot.Vel = shot.Vel*1.5;
	else
		self.XaA12AxiomHeatMechSound:Play(self.Pos);
		self.XaA12AxiomShotSound:Play(self.Pos);
	end
end
					
function OnAttach(self, newParent)
	if IsAHuman(newParent:GetRootParent()) then
		self.parent = ToAHuman(newParent:GetRootParent());
	end
end

function OnDetach(self)
	self.parent = nil;
end

function ThreadedUpdate(self)
	self.useHEATDelayedFire = false;

	self.XaA12AxiomPreSound.Pos = self.Pos;
	self.XaA12AxiomChargeSound.Pos = self.Pos;
	
	self.XaA12AxiomHeatReleaseLightSound.Pos = self.Pos;
	self.XaA12AxiomHeatReleaseHeavySound.Pos = self.Pos;
	
	self.XaA12AxiomHeatMechSound.Pos = self.Pos;
	self.XaA12AxiomHeatMechChargedSound.Pos = self.Pos;

	self.HEATAngVelManualAddition = 0;

	if self.parent then
		local fire = self.RoundInMagCount > 0 and self:IsActivated();
		self:Deactivate();
		
		if fire then
			if not self.XaA12AxiomFireReset then
				self.XaA12AxiomActivated = true;
				if self.XaA12AxiomChargingTimer:IsPastSimMS(self.XaA12AxiomChargingHoldTime) then
					if not self.XaA12AxiomCharging then
						self.XaA12AxiomCharging = true;
						self.XaA12AxiomChargingTimer:Reset();
						self.XaA12AxiomPreSound:Play(self.Pos);
						self.XaA12AxiomChargeSound:Play(self.Pos);
					end
					
					self.HEATAngVelManualAddition = math.random(-3, 3) * self.XaA12AxiomChargingTimer.ElapsedSimTimeMS / (self.XaA12AxiomChargingHoldTime + self.XaA12AxiomChargingChargeTime);
				end
				
				if self.XaA12AxiomChargingTimer:IsPastSimMS(self.XaA12AxiomChargingHoldTime + self.XaA12AxiomChargingChargeTime) then
					-- Super roundabout dual wielding fire fix - it won't choose the other weapon to fire if it "fires itself"
					if self.parent then
						self.parent:GetController():SetState(Controller.WEAPON_FIRE, true);
					end
					self:Activate();
					self.HEATAngVelManualAddition = 0;
					self.XaA12AxiomActivated = false;
					self.XaA12AxiomCharging = false;
					self.XaA12AxiomChargingTimer:Reset();
					self.XaA12AxiomFireReset = true;
					self.XaA12AxiomChargedShot = true;
					self.HEATParticleUtilityFiringSmokeDataTable.Power = 35;
					self.HEATParticleUtilityFiringSmokeDataTable.ExploMult = 2.0;
					self.HEATRecoilAngAnim = 7;
					self.HEATRecoilStrength = 80;
					self.HEATRecoilDamping = 0.6;
				end
			end
		else
			self.XaA12AxiomFireReset = false;
			self.XaA12AxiomCharging = false;
			if self.XaA12AxiomActivated then
				self.useHEATDelayedFire = true;
				self.XaA12AxiomActivated = false;
				self:Activate();
				self.HEATParticleUtilityFiringSmokeDataTable.Power = 35;
				self.HEATParticleUtilityFiringSmokeDataTable.ExploMult = 1.5;
				self.HEATRecoilAngAnim = 3;
				self.HEATRecoilStrength = 40;
				self.HEATRecoilDamping = 0.8;
			end
			self.XaA12AxiomChargingTimer:Reset();
		end
	end
	
	if self.FiredFrame then
		self.Frame = 3;
	else -- If we are reloading or have a persistent frame in the HEATSystem, this script comes before it, so the below 0 will be overwritten correctly.
		self.Frame = 0;
	end

	if self.parent and IsActor(self.parent) then
		if ToActor(self.parent):IsPlayerControlled() then
			self.HEATRecoilMax = 12;
		else
			self.HEATRecoilMax = 2;
		end
	end
end