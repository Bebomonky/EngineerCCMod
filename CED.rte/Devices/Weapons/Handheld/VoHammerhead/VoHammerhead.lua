require("/CEDSettings");

function Create(self)
	self.VoHammerheadFireVelocity = 140;
	self.VoHammerheadFireSpread = 1 / 2;

	self.VoHammerheadPlayerRateOfFire = 320;
	self.VoHammerheadAIRateOfFire = 145;
end

function OnFire(self)
	local spread = math.random(-self.VoHammerheadFireSpread, self.VoHammerheadFireSpread);

	local shot = CreateMOPixel("Bullet CED Vossberg Hammerhead Scripted", "CED.rte");
	shot.Pos = self.MuzzlePos + Vector(0.1*self.FlipFactor, 0):RadRotate(self.RotAngle);
	shot.Vel = self.Vel + Vector(self.VoHammerheadFireVelocity * self.FlipFactor, spread):RadRotate(self.RotAngle);
	shot.Team = self.Team;
	shot.IgnoresTeamHits = true;
	shot:SetWhichMOToNotHit(ToMovableObject(self), 150);
	MovableMan:AddParticle(shot);

	for i = 1, 1 do
		local shot = CreateMOPixel("Bullet CED Vossberg Hammerhead", "CED.rte");
		shot.Pos = self.MuzzlePos + Vector(0.1*i*self.FlipFactor, 0):RadRotate(self.RotAngle);
		shot.Vel = self.Vel + Vector(self.VoHammerheadFireVelocity * self.FlipFactor, spread):RadRotate(self.RotAngle);
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
end
					
function OnAttach(self, newParent)
	self.parent = newParent:GetRootParent();
end

function OnDetach(self)
	self.parent = nil;
end

function ThreadedUpdate(self)
	if self.parent and IsActor(self.parent) then
		if ToActor(self.parent):IsPlayerControlled() then
			self.RateOfFire = self.VoHammerheadPlayerRateOfFire;
			self.HEATRecoilMax = 12;
		else
			self.RateOfFire = self.VoHammerheadAIRateOfFire;
			self.HEATRecoilMax = 4;
		end
	end
end