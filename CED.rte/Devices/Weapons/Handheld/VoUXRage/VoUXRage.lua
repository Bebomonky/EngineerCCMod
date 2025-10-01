require("/CEDSettings");

function OnMessage(self, message, object)

	-- This is a full update, even if it's redundant. It only runs whenever any attachment is changed, so it should be fine.

	if message == "TriumvirateAtt_Update" then
		
		if self:GetNumberValue("TriumvirateAtt_FullAuto_Equipped") == 1 then	
			self.VoUXRageAutoMode = true;
			self.VoUXRageSwitchSingleSound:FadeOut(200);
			
			self.HEATReflectionOutdoorsSound.Volume = 0.2;
			self.HEATReflectionIndoorsSound.Volume = 0.2;
			
			self.FullAuto = true;
			self.RateOfFire = 430;
			self.HEATRecoilStrength = 40;
			
			self.HEATParticleUtilityFiringSmokeDataTable.Power = 45;			
			
		elseif self:GetNumberValue("TriumvirateAtt_SemiAuto_Equipped") == 1 then
			self.VoUXRageAutoMode = false;
			self.VoUXRageSwitchAutoSound:FadeOut(200);
			
			self.HEATReflectionOutdoorsSound.Volume = 0.3;
			self.HEATReflectionIndoorsSound.Volume = 0.3;
			
			self.FullAuto = false;
			self.RateOfFire = 100;
			self.HEATRecoilStrength = 32;
			
			self.HEATParticleUtilityFiringSmokeDataTable.Power = 80;
		end		
		
	end
end

function Create(self)
	self.VoUXRageFireVelocity = 100;
	self.VoUXRageFireAutoVelocity = 45;
	self.VoUXRageFireSpread = 1 / 2;
	
	self.VoUXRageShotSound = CreateSoundContainer("Shot CED Vossberg UX-Rage", "CED.rte");
	self.VoUXRageShotAutoSound = CreateSoundContainer("Shot Auto CED Vossberg UX-Rage", "CED.rte");
	self.VoUXRageShotAutoEndSound = CreateSoundContainer("Shot Auto End CED Vossberg UX-Rage", "CED.rte");
	
	self.VoUXRageSwitchAutoSound = CreateSoundContainer("Switch Auto CED Vossberg UX-Rage", "CED.rte");
	self.VoUXRageSwitchSingleSound = CreateSoundContainer("Switch Single CED Vossberg UX-Rage", "CED.rte");
	
	self.HEATReflectionOutdoorsSound.Volume = 0.3;
	self.HEATReflectionIndoorsSound.Volume = 0.3;

	self.VoUXRageAutoMode = false;
end

function OnFire(self)
	CameraMan:AddScreenShake(7, self.Pos);

	local velocity = self.VoUXRageAutoMode and self.VoUXRageFireAutoVelocity or self.VoUXRageFireVelocity;
	local spread = math.random(-self.VoUXRageFireSpread, self.VoUXRageFireSpread);

	local shot = CreateAEmitter("Explosive Shot CED Vossberg UX-Rage", "CED.rte");
	shot.Pos = self.MuzzlePos + Vector(0.1*self.FlipFactor, 0):RadRotate(self.RotAngle);
	shot.Vel = self.Vel + Vector(velocity * self.FlipFactor, spread):RadRotate(self.RotAngle);
	shot.RotAngle = self.RotAngle;
	shot.HFlipped = self.HFlipped;
	shot.Team = self.Team;
	shot.IgnoresTeamHits = true;
	shot:SetWhichMOToNotHit(ToMovableObject(self), 150);
	MovableMan:AddParticle(shot);
	
	-- Vent smoke
	for i = 1, math.ceil(25 / (math.random(2,4))) do
		local spread = math.pi * RangeRand(-1, 1) * 0.05
		local velocity = 110 * RangeRand(0.1, 0.9) * 0.4;
		
		local particle = CreateMOSParticle((math.random() * 15) < 19 and "Tiny Smoke Ball 1" or "Small Smoke Ball 1");
		particle.Pos = self.Pos + Vector(-1, -2):RadRotate(self.RotAngle);
		particle.Vel = self.Vel + Vector(0 * self.FlipFactor, -20):RadRotate(self.RotAngle + spread)
		particle.Lifetime = particle.Lifetime * RangeRand(0.9, 1.6) * 0.3
		particle.AirThreshold = particle.AirThreshold * 0.5
		particle.GlobalAccScalar = 0
		MovableMan:AddParticle(particle);
	end	
	
	if self.VoUXRageAutoMode then
		self.VoUXRageShotAutoSound:Play(self.Pos);
		self.VoUXRageShotAutoEndSound:Play(self.Pos);
		
		if self.VoUXRageFirstShot then
			self.VoUXRageFirstShot = false;
			self.HEATReflectionOutdoorsSound.Volume = 0.2;
			self.HEATReflectionIndoorsSound.Volume = 0.2;
		else
			self.HEATReflectionOutdoorsSound.Volume = math.min(1, self.HEATReflectionOutdoorsSound.Volume + 0.2);
			self.HEATReflectionIndoorsSound.Volume = math.min(0.5, self.HEATReflectionIndoorsSound.Volume + 0.1);
		end
	else
		self.VoUXRageShotSound:Play(self.Pos);
	end
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
	self.VoUXRageShotSound.Pos = self.Pos;
	self.VoUXRageShotAutoSound.Pos = self.Pos;
	self.VoUXRageShotAutoEndSound.Pos = self.Pos;
	self.VoUXRageSwitchAutoSound.Pos = self.Pos;
	self.VoUXRageSwitchSingleSound.Pos = self.Pos;

	if self.parent then
		-- AI does better with the single mode
		if self.VoUXRageAutoMode and not self.parent:IsPlayerControlled() and not self.Menu:IsOpen() then
			self.VoUXRageAutoMode = false;
			self.VoUXRageSwitchSingleSound:Play(self.Pos);
			self.VoUXRageSwitchAutoSound:FadeOut(200);
			
			self.HEATReflectionOutdoorsSound.Volume = 0.3;
			self.HEATReflectionIndoorsSound.Volume = 0.3;
			
			self.FullAuto = false;
			self.RateOfFire = 100;
			self.HEATRecoilStrength = 32;
			
			self.HEATParticleUtilityFiringSmokeDataTable.Power = 80;
		end
	end
	
	if not self:IsActivated() then
		self.VoUXRageFirstShot = true;
	end
end