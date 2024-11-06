require("/CEDSettings");

function Create(self)
	self.XaEACondorChargeUpSound = CreateSoundContainer("Charge Up CED Xarix EA Condor", "CED.rte");

	self.XaEACondorCharging = false;
	self.XaEACondorChargeTimer = Timer();
	self.XaEACondorChargeTime = 3440;
	
	self.XaEACondorFireReloadableCooldown = 1200;
	
	self.XaEACondorVerticalSmokeDataTable = {};
	self.XaEACondorVerticalSmokeDataTable.Power = 100;
	self.XaEACondorVerticalSmokeDataTable.Spread = 5;
	self.XaEACondorVerticalSmokeDataTable.SmokeMult = 0.7;
	self.XaEACondorVerticalSmokeDataTable.ExploMult = 1.0;
	self.XaEACondorVerticalSmokeDataTable.WidthSpread = 1;
	self.XaEACondorVerticalSmokeDataTable.VelocityMult = 0.1;
	self.XaEACondorVerticalSmokeDataTable.LingerMult = 2.0;
	self.XaEACondorVerticalSmokeDataTable.AirResistanceMult = 1.4;
	self.XaEACondorVerticalSmokeDataTable.GravMult = 1.0;		
end

function OnFire(self)
	CameraMan:AddScreenShake(30, self.Pos);

	local velocity = 10;

	local shot = CreateMOSRotating("Beam Particle CED Xarix EA Condor", "CED.rte");
	shot.Pos = self.MuzzlePos + Vector(0.1*self.FlipFactor, 0):RadRotate(self.RotAngle);
	shot.Vel = self.Vel + Vector(velocity * self.FlipFactor, 0):RadRotate(self.RotAngle);
	shot.HFlipped = self.HFlipped;
	shot.RotAngle = self.RotAngle;
	shot.Team = self.Team;
	shot.IgnoresTeamHits = true;
	shot:SetWhichMOToNotHit(ToMovableObject(self), 150);
	MovableMan:AddParticle(shot);
	
	-- Vertical smoke
	
	self.XaEACondorVerticalSmokeDataTable.Position = self.MuzzlePos;
	self.XaEACondorVerticalSmokeDataTable.Source = self;
	self.XaEACondorVerticalSmokeDataTable.RadAngle = (self.HFlipped and (self.RotAngle + math.pi) or self.RotAngle) + math.pi/2.2;
	self.HEATParticleUtility:CreateDirectionalSmokeEffect(self.XaEACondorVerticalSmokeDataTable);
	
	self.XaEACondorVerticalSmokeDataTable.RadAngle = (self.HFlipped and (self.RotAngle + math.pi) or self.RotAngle) - math.pi/2.2;
	self.HEATParticleUtility:CreateDirectionalSmokeEffect(self.XaEACondorVerticalSmokeDataTable);
	
	self.Reloadable = false;
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
	self.XaEACondorChargeUpSound.Pos = self.Pos;

	if self.parent then
		if self.parentController:IsState(Controller.WEAPON_PRIMARY_HOTKEYSTART) then
		end
	end
	
	local fire = self:IsActivated();
	
	self:Deactivate();
	
	if self.RoundInMagCount > 0 and fire and not self.XaEACondorCharging then
		CameraMan:AddScreenShake(6, self.Pos);
		self.XaEACondorCharging = true;
		self.XaEACondorChargeTimer:Reset();
		self.XaEACondorChargeUpSound:Play(self.Pos);
	end
	
	if self.XaEACondorCharging then
		self.HEATAngVelOverride = math.random(-3, 3) * (1 - self.XaEACondorChargeTimer.ElapsedSimTimeMS / self.XaEACondorChargeTime);
		CameraMan:AddScreenShake(1.35 * (self.XaEACondorChargeTimer.ElapsedSimTimeMS / self.XaEACondorChargeTime), self.Pos);
		if self.XaEACondorChargeTimer:IsPastSimMS(self.XaEACondorChargeTime) then
			self:Activate();
			self.XaEACondorCharging = false;
			self.XaEACondorChargeTimer:Reset();
		end
	elseif not self.Reloadable and self.XaEACondorChargeTimer:IsPastSimMS(self.XaEACondorFireReloadableCooldown) then
		self.Reloadable = true;
	end
end