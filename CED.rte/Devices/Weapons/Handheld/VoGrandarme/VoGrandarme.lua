require("/CEDSettings");

function Create(self)
	self.VoGrandarmeFireVelocity = 160;
	self.VoGrandarmeFireSpread = 3.5 / 2;

	self.VoGrandarmeSlowROFOnSound = CreateSoundContainer("Slow ROF On CED Vossberg Grandarme", "CED.rte");
	self.VoGrandarmeSlowROFOffSound = CreateSoundContainer("Slow ROF Off CED Vossberg Grandarme", "CED.rte");

	self.VoGrandarmeShotSound = CreateSoundContainer("Shot CED Vossberg Grandarme", "CED.rte");
	self.VoGrandarmeShotAutoSound = CreateSoundContainer("Shot Auto CED Vossberg Grandarme", "CED.rte");

	self.VoGrandarmeFirstShot = true;
	
	self.VoGrandarmeSlowROFMode = false;
	self.VoGrandarmeSlowROF = 250;
	self.VoGrandarmeFastROF = 490;
end

function OnFire(self)
	if self.VoGrandarmeFirstShot then
		self.VoGrandarmeShotSound:Play(self.Pos);
	else
		self.VoGrandarmeShotAutoSound:Play(self.Pos);
	end
	
	local spread = math.random(-self.VoGrandarmeFireSpread, self.VoGrandarmeFireSpread);

	local shot = CreateMOPixel("Bullet CED Vossberg Grandarme Scripted", "CED.rte");
	shot.Pos = self.MuzzlePos + Vector(0.1*self.FlipFactor, 0):RadRotate(self.RotAngle);
	shot.Vel = self.Vel + Vector(self.VoGrandarmeFireVelocity * self.FlipFactor, spread):RadRotate(self.RotAngle);
	shot.Team = self.Team;
	shot.IgnoresTeamHits = true;
	shot:SetWhichMOToNotHit(ToMovableObject(self), 150);
	MovableMan:AddParticle(shot);
	
	for i = 1, 1 do
		local shot = CreateMOPixel("Bullet CED Vossberg Grandarme", "CED.rte");
		shot.Pos = self.MuzzlePos + Vector(0.1*self.FlipFactor, 0):RadRotate(self.RotAngle);
		shot.Vel = self.Vel + Vector(self.VoGrandarmeFireVelocity * self.FlipFactor, spread):RadRotate(self.RotAngle);
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
	
	self.VoGrandarmeFirstShot = false;
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
	self.VoGrandarmeSlowROFOnSound.Pos = self.Pos;
	self.VoGrandarmeSlowROFOffSound.Pos = self.Pos;

	if not self:IsActivated() then
		self.VoGrandarmeFirstShot = true;
	end

	if self.parent then
		if self.parentController:IsState(Controller.WEAPON_PRIMARY_HOTKEYSTART) then
			if self.VoGrandarmeSlowROFMode then
				self.VoGrandarmeSlowROFOffSound:Play(self.Pos);
				self.VoGrandarmeSlowROFMode = false;
				self.RateOfFire = self.VoGrandarmeFastROF;
				self.ShakeRange = 5;
				self.SharpShakeRange = 4;
				self.HEATRecoilStrength = 8
				self.HEATRecoilPowStrength = 0.2;
				self.HEATRecoilRandomUpper = 2
				self.HEATRecoilDamping = 0.55
				self.HEATRecoilMax = 12;
			else
				self.VoGrandarmeSlowROFOnSound:Play(self.Pos);
				self.VoGrandarmeSlowROFMode = true;
				self.RateOfFire = self.VoGrandarmeSlowROF;
				self.ShakeRange = 4;
				self.SharpShakeRange = 2;
				self.HEATRecoilStrength = 10
				self.HEATRecoilPowStrength = 0.2;
				self.HEATRecoilRandomUpper = 2
				self.HEATRecoilDamping = 0.8
				self.HEATRecoilMax = 3;
			end
		end
	end
end