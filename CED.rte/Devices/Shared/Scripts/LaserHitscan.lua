function Create(self)
	self.hitSound = CreateSoundContainer(self:GetStringValue("HitSound"), self:GetStringValue("HitSoundTech") .. ".rte");
	
	self.damageParticle = CreateMOPixel(self:GetStringValue("DamageParticle"), self:GetStringValue("DamageParticleTech") .. ".rte");
	
	self.primaryGlow = CreateMOPixel(self:GetStringValue("PrimaryGlow"), self:GetStringValue("PrimaryGlowTech") .. ".rte");
	self.secondaryGlow = CreateMOPixel(self:GetStringValue("SecondaryGlow"), self:GetStringValue("SecondaryGlowTech") .. ".rte");
	
	self.woundDamageMultiplier = self:NumberValueExists("CED_LaserWoundDamageMultiplier") and self:GetNumberValue("CED_LaserWoundDamageMultiplier") or 1;

	local glow = self.primaryGlow:Clone();
	glow.Pos = self.Pos;
	MovableMan:AddParticle(glow);
	
	self.lastPos = Vector(self.Pos.X, self.Pos.Y);
	
	self.cast = true;
	self.castLength = 700;
end

function Update(self)
	self.Vel = Vector();
	
	if self.cast then
		local step = self.castLength
		local endPos = Vector(self.Pos.X, self.Pos.Y); -- This value is going to be overriden by function below, this is the end of the ray
		self.ray = SceneMan:CastObstacleRay(self.Pos, Vector(1 * self.FlipFactor, 0):RadRotate(self.RotAngle) * step, Vector(0, 0), endPos, 0 , self.Team, 0, 1) -- Do the hitscan stuff, raycast
		
		local travel = SceneMan:ShortestDistance(endPos, self.Pos,SceneMan.SceneWrapsX);
		self.cast = false	
		self.hitPos = Vector(endPos.X, endPos.Y)
		
		if travel.Magnitude > 5 then
			local maxi = travel.Magnitude / GetPPM() * 6
			for i = 0, maxi do
				local glow = self.secondaryGlow:Clone();
				glow.Pos = endPos + travel * math.max(math.min(1 / maxi * i, 1), 0);
				MovableMan:AddParticle(glow);
			end		
		end
		
		if self.ray > -1 then	
		
			self.hitSound:Play(self.hitPos);
		
			local glow = self.primaryGlow:Clone();
			glow.Pos = self.hitPos;
			MovableMan:AddParticle(glow);
			
			local pixel = self.damageParticle:Clone();
			pixel.Vel = Vector(1 * self.FlipFactor, 0):RadRotate(self.RotAngle) * 70;
			pixel.Pos = self.hitPos - Vector(2 * self.FlipFactor, 0):RadRotate(self.RotAngle);
			pixel.Team = self.Team
			pixel.IgnoresTeamHits = true;
			pixel.WoundDamageMultiplier = self.woundDamageMultiplier;
			MovableMan:AddParticle(pixel);
			
			local smoke = CreateMOSParticle("Tiny Smoke Ball 1");
			smoke.Pos = self.hitPos - Vector(1 * self.FlipFactor, 0):RadRotate(self.RotAngle);
			smoke.Vel = Vector(-1, 0):RadRotate(self.RotAngle + RangeRand(-0.3,0.3)) * RangeRand(0.4, 16);
			smoke.Lifetime = smoke.Lifetime * RangeRand(0.6, 1.6) * 0.9; -- Randomize lifetime
			smoke.GlobalAccScalar = RangeRand(-0.1, 0.1)
			MovableMan:AddParticle(smoke);
			
			local smoke = CreateMOPixel("Drop Oil");
			smoke.Pos = self.hitPos
			smoke.Vel = Vector(-1, 0):RadRotate(self.RotAngle + RangeRand(-0.3,0.3)) * RangeRand(0.2, 26);
			smoke.Lifetime = 1000 * RangeRand(0.1, 1.0); -- Randomize lifetime
			MovableMan:AddParticle(smoke);
			
			local smoke = CreateMOPixel("Spark Yellow "..math.random(1,2));
			smoke.Pos = self.hitPos - Vector(1 * self.FlipFactor, 0):RadRotate(self.RotAngle);
			smoke.Vel = Vector(-1, 0):RadRotate(self.RotAngle + RangeRand(-0.8,0.8)) * RangeRand(7, 45);
			smoke.Lifetime = 700 * RangeRand(0.1, 1.0); -- Randomize lifetime
			MovableMan:AddParticle(smoke);
			
			local smoke = CreateMOSParticle("Small Smoke Ball 1");
			smoke.Pos = self.hitPos - Vector(1 * self.FlipFactor, 0):RadRotate(self.RotAngle);
			smoke.Vel = Vector(-1, 0):RadRotate(self.RotAngle + RangeRand(-0.3,0.3)) * RangeRand(0.4, 8);
			smoke.Lifetime = smoke.Lifetime * RangeRand(0.6, 1.6) * 0.5; -- Randomize lifetime
			smoke.GlobalAccScalar = RangeRand(-0.1, 0.1)
			MovableMan:AddParticle(smoke);
		end		
	end
	
	self.ToDelete = true;
	
end