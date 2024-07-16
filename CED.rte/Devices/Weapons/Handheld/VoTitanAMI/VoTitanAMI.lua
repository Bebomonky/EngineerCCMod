require("/CEDSettings");

function Create(self)
	-- Timer to not insta-reload after firing.
	self.VoTitanAMIReloadDelayTimer = Timer();
	-- Delay for above timer.
	self.VoTitanAMIReloadDelay = 600;
end

function OnFire(self)

	CameraMan:AddScreenShake(30, self.Pos);

	local velocity = 180;

	local shot = CreateMOPixel("Bullet CED Vossberg Titan AMI Scripted", "CED.rte");
	shot.Pos = self.MuzzlePos + Vector(0.1*self.FlipFactor, 0):RadRotate(self.RotAngle);
	shot.Vel = self.Vel + Vector(velocity * self.FlipFactor, 0):RadRotate(self.RotAngle);
	shot.Team = self.Team;
	shot.IgnoresTeamHits = true;
	shot:SetWhichMOToNotHit(ToMovableObject(self), 150);
	MovableMan:AddParticle(shot);

	for i = 1, 9 do
		local shot = CreateMOPixel("Bullet CED Vossberg Titan AMI", "CED.rte");
		shot.Pos = self.MuzzlePos + Vector(0.1*i*self.FlipFactor, 0):RadRotate(self.RotAngle);
		shot.Vel = self.Vel + Vector(velocity * self.FlipFactor, 0):RadRotate(self.RotAngle);
		shot.Team = self.Team;
		shot.IgnoresTeamHits = true;
		shot:SetWhichMOToNotHit(ToMovableObject(self), 150);
		MovableMan:AddParticle(shot);
	end

	self.Reloadable = false;
	self.VoTitanAMIReloadDelayTimer:Reset();
end

function ThreadedUpdate(self)
	if self.VoTitanAMIReloadDelayTimer:IsPastSimMS(self.VoTitanAMIReloadDelay) then
		self.Reloadable = true;
	end
end