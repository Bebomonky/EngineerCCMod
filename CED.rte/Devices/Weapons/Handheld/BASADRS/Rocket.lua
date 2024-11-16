function Create(self)
	self.lifeTimer = Timer();
	
	self.lifeTimer:SetSimTimeLimitMS(math.random(self.Lifetime * 0.5, self.Lifetime - math.ceil(TimerMan.DeltaTimeMS)));
	self.activationDelay = 150;
	
	self.GlobalAccScalar = 0.05;
end

function Update(self)
	if self.lifeTimer:IsPastSimMS(self.activationDelay) then
		if self:IsEmitting() == false then
			self:EnableEmission(true);
		end
		self.GlobalAccScalar = 1/math.sqrt(1 + math.abs(self.Vel.X) * 0.1);
	end
end

function Destroy(self)
	self.BurstSound:Stop(-1);
end