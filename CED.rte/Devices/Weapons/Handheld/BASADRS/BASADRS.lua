require("/CEDSettings");

function Create(self)
	self.BASADRSFireVelocity = 45;
	self.BASADRSFireSpread = 0.2 / 2;
	
	self.BASADRSShotSound = CreateSoundContainer("Shot CED CED-BAS ADRS", "CED.rte");
	self.BASADRSSwitchPropOffSound = CreateSoundContainer("Switch Prop Off CED CED-BAS ADRS", "CED.rte");
	
	self.BASADRSSwitchPropOnSound = CreateSoundContainer("Switch Prop On CED CED-BAS ADRS", "CED.rte");

	self.BASADRSNoPropMode = false;
	
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
		shot.Vel = self.Vel + Vector(self.BASADRSFireVelocity * self.FlipFactor, spread):RadRotate(self.RotAngle);
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
	for i = 1, math.ceil(25 / (math.random(2,4))) do
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
	end
	
	if self:DoneReloading() then
		self.HEATPersistentFrame = 0;
	end
	
	if self.BASADRSReloadDelayTimer:IsPastSimMS(self.BASADRSReloadDelay) then
		self.Reloadable = true;
	end
end