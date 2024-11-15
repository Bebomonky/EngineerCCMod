function Create(self)
	self.enterSound = CreateSoundContainer("Enter CED Vossberg AP-Warthog", "CED.rte");
	self.enterSound:Play(self.Pos);
	self.incomingSound = CreateSoundContainer("Incoming CED Vossberg AP-Warthog", "CED.rte");
	self.incomingSound:Play(self.Pos);
	self.impactSound = CreateSoundContainer("Impact CED Vossberg AP-Warthog", "CED.rte");
	
	self.openTimer = Timer();
	self.openTime = 1000;
end

function Update(self)
	if self.Pos.Y < 0 then
		self.ToDelete = false;
	end
	
	self.incomingSound.Pos = self.Pos;
	if self.HatchState == 2 then
		self.HatchOpenSound = nil;
	end
	if self.Impacted and self.openTimer:IsPastSimMS(self.openTime) then
		self:OpenHatch();
		self.HitsMOs = false;
		self.GetsHitByMOs = false;
		self.Health = 0;
	end
	self.RotAngle = 0;
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
		
		self.PinStrength = 5000;
		self.Vel = self.Vel / 3;
	end
end

function Destroy(self)
	ActivityMan:GetActivity():ReportDeath(self.Team, -1);
end