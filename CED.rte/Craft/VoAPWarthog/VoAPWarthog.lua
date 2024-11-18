function Create(self)
	self.enterSound = CreateSoundContainer("Enter CED Vossberg AP-Warthog", "CED.rte");
	self.enterSound:Play(self.Pos);
	self.incomingSound = CreateSoundContainer("Incoming CED Vossberg AP-Warthog", "CED.rte");
	self.impactSound = CreateSoundContainer("Impact CED Vossberg AP-Warthog", "CED.rte");
	
	self.incomingTimer = Timer();
	local altitude = SceneMan:FindAltitude(self.Pos, 0, 50);
	-- Arbitrary
	self.incomingTime = 20 / (120 / altitude);
	
	self.openTimer = Timer();
	self.openTime = 1000;
	
	self.MissionCritical = true;
end

function Update(self)
	self.incomingSound.Pos = self.Pos;

	if self.incomingTimer:IsPastSimMS(self.incomingTime) and not self.Incoming then
		self.Incoming = true;
		self.incomingSound:Play(self.Pos);
	end

	if self.Pos.Y > 0 then
		self.HitsMOs = true;
		self.GetsHitByMOs = true;
	end

	if self.HatchState == 2 then
		self.HatchOpenSound = nil;
	end
	if self.Impacted and self.openTimer:IsPastSimMS(self.openTime) then
		self:OpenHatch();
		self.HitsMOs = false;
		self.GetsHitByMOs = false;
		self.Health = 0;
	end
	self.AngularVel = self.AngularVel * 0.2;
end

function OnCollideWithTerrain(self)
	if not self.Impacted then
		CameraMan:AddScreenShake(30, self.Pos);
		self.Impacted = true;
		self.openTimer:Reset();
		self.incomingSound:FadeOut(200);
		self.impactSound:Play(self.Pos);
		
		local landingFX = CreateMOSRotating("Landing Payload CED Vossberg AP-Warthog", "CED.rte");
		landingFX.Pos = self.Pos;
		landingFX.Vel = Vector(0, 30);
		MovableMan:AddParticle(landingFX);
		landingFX:GibThis();
		
		self.Vel = self.Vel / 2;
	end
end

function Destroy(self)
	ActivityMan:GetActivity():ReportDeath(self.Team, -1);
end