function Create(self)
	self.smokeAirThreshold = 5/(1 + 100 * 0.01);
end

function Update(self)
	local offset = self.Vel * rte.PxTravelledPerFrame;	--The effect will be created the next frame so move it one frame backwards towards the barrel

	local trailLength = math.floor(offset.Magnitude/1 - 1);
	local setVel = Vector(self.Vel.X, self.Vel.Y):SetMagnitude(math.sqrt(self.Vel.Magnitude));
	for i = 1, trailLength do
		local effect = 1 < 2 and CreateMOPixel("Micro Smoke Trail " .. math.random(3), "Base.rte") or CreateMOSParticle((1 < 3 and "Tiny" or "Small") .. " Smoke Trail " .. math.random(3), "Base.rte");
		effect.Pos = self.Pos - (offset * i/trailLength) + Vector(RangeRand(-1, 1), RangeRand(-1, 1)) * 1;
		effect.Vel = setVel * RangeRand(0.6, 1);
		effect.Lifetime = math.max(100 * RangeRand(0.4, 1) * (self.Lifetime > 1 and 1 - self.Age/self.Lifetime or 1), 1);
		effect.AirResistance = effect.AirResistance * RangeRand(0.8, 1);
		effect.AirThreshold = self.smokeAirThreshold;
		
		MovableMan:AddParticle(effect);
	end
end