function Create(self)
	self.lingeringBurstSound = CreateSoundContainer("Rocket Ignite Lingering CED CED-BAS ADRS", "CED.rte");

	self.lifeTimer = Timer();
	
	self.lifeTimer:SetSimTimeLimitMS(math.random(self.Lifetime * 0.5, self.Lifetime - math.ceil(TimerMan.DeltaTimeMS)));
	self.activationDelay = 150;
	
	self.GlobalAccScalar = 0.05;
end

function Update(self)
	if self.lifeTimer:IsPastSimMS(self.activationDelay) then
		if self:IsEmitting() == false then
			self:EnableEmission(true);
			self.Vel = self.Vel + Vector(50*self.FlipFactor, 0):RadRotate(self.RotAngle);
			self.lingeringBurstSound:Play(self.Pos);
		end
		self.GlobalAccScalar = 1/math.sqrt(1 + math.abs(self.Vel.X) * 0.1);
	end
end

function Destroy(self)
	self.BurstSound:Stop(-1);
	self.lingeringBurstSound:FadeOut(1000);
end