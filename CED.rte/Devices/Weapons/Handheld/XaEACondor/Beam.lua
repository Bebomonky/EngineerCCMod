function Create(self)
	self.exploSound = CreateSoundContainer("Explo CED Xarix EA Condor", "CED.rte");
	self.exploReflectionOutdoorsSound = CreateSoundContainer("Explo Reflection Outdoors CED Xarix EA Condor", "CED.rte");
	self.exploReflectionIndoorsSound = CreateSoundContainer("Explo Reflection Indoors CED Xarix EA Condor", "CED.rte");
	
	local glow = CreateMOPixel("Glow CED Xarix EA Condor Beam Extra", "CED.rte");
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
				local glow = CreateMOPixel("Glow CED Xarix EA Condor Beam Particle "..math.random(1,5));
				glow.Pos = endPos + travel * math.max(math.min(1 / maxi * i, 1), 0);
				MovableMan:AddParticle(glow);
				
				local smoke = CreateMOSParticle("Small Smoke Ball 1");
				smoke.Pos = endPos + travel * math.max(math.min(1 / maxi * i, 1), 0);
				smoke.Vel = Vector(1, 0):RadRotate(self.RotAngle);
				smoke.Lifetime = smoke.Lifetime * RangeRand(0.6, 1.6) * 0.5; -- Randomize lifetime
				smoke.GlobalAccScalar = RangeRand(-0.1, 0.1)
				MovableMan:AddParticle(smoke);
				
				local smoke = CreateMOSParticle("Tiny Smoke Ball 1");
				smoke.Pos = endPos + travel * math.max(math.min(1 / maxi * i, 1), 0);
				smoke.Vel = Vector(1, 0):RadRotate(self.RotAngle);
				smoke.Lifetime = smoke.Lifetime * RangeRand(0.6, 1.6) * 0.5; -- Randomize lifetime
				smoke.GlobalAccScalar = RangeRand(-0.1, 0.1)
				MovableMan:AddParticle(smoke);
			end		
		end
		
		if self.ray > -1 then
		
			self.exploSound:Play(self.hitPos);
		
			local outdoorRays = 0;
			local indoorRays = 0;
			local bigIndoorRays = 0;
			local rayThreshold = 2;

			local Vector2 = Vector(0,-700); -- straight up
			local Vector2Left = Vector(0,-700):RadRotate(45*(math.pi/180));
			local Vector2Right = Vector(0,-700):RadRotate(-45*(math.pi/180));			
			local Vector2SlightLeft = Vector(0,-700):RadRotate(22.5*(math.pi/180));
			local Vector2SlightRight = Vector(0,-700):RadRotate(-22.5*(math.pi/180));		
			local Vector3 = Vector(0,0); -- dont need this but is needed as an arg
			local Vector4 = Vector(0,0); -- dont need this but is needed as an arg

			self.ray = SceneMan:CastObstacleRay(self.hitPos, Vector2, Vector3, Vector4, self.RootID, self.Team, 128, 7);
			self.rayRight = SceneMan:CastObstacleRay(self.hitPos, Vector2Right, Vector3, Vector4, self.RootID, self.Team, 128, 7);
			self.rayLeft = SceneMan:CastObstacleRay(self.hitPos, Vector2Left, Vector3, Vector4, self.RootID, self.Team, 128, 7);			
			self.raySlightRight = SceneMan:CastObstacleRay(self.hitPos, Vector2SlightRight, Vector3, Vector4, self.RootID, self.Team, 128, 7);
			self.raySlightLeft = SceneMan:CastObstacleRay(self.hitPos, Vector2SlightLeft, Vector3, Vector4, self.RootID, self.Team, 128, 7);
			
			self.rayTable = {self.ray, self.rayRight, self.rayLeft, self.raySlightRight, self.raySlightLeft};
			
			for _, rayLength in ipairs(self.rayTable) do
				if rayLength < 0 then
					outdoorRays = outdoorRays + 1;
				elseif rayLength > 170 then
					bigIndoorRays = bigIndoorRays + 1;
				else
					indoorRays = indoorRays + 1;
				end
			end
			
			if outdoorRays >= rayThreshold then
				self.exploReflectionOutdoorsSound:Play(self.hitPos);
			else
				self.exploReflectionIndoorsSound:Play(self.hitPos);
			end
			
			local payload = CreateMOSRotating("Beam Hit Payload CED Xarix EA Condor", "CED.rte");
			payload.Pos = self.hitPos;
			MovableMan:AddParticle(payload);
			payload:GibThis();
		
			local glow = CreateMOPixel("Glow CED Xarix EA Condor Beam Extra", "CED.rte");
			glow.Pos = self.Pos;
			MovableMan:AddParticle(glow);
			
			local smoke = CreateMOSParticle("Tiny Smoke Ball 1", "Base.rte");
			smoke.Pos = self.hitPos - Vector(1 * self.FlipFactor, 0):RadRotate(self.RotAngle);
			smoke.Vel = Vector(-1, 0):RadRotate(self.RotAngle + RangeRand(-0.3,0.3)) * RangeRand(0.4, 16);
			smoke.Lifetime = smoke.Lifetime * RangeRand(0.6, 1.6) * 0.9; -- Randomize lifetime
			smoke.GlobalAccScalar = RangeRand(-0.1, 0.1)
			MovableMan:AddParticle(smoke);
			
			local smoke = CreateMOPixel("Drop Oil", "Base.rte");
			smoke.Pos = self.hitPos
			smoke.Vel = Vector(-1, 0):RadRotate(self.RotAngle + RangeRand(-0.3,0.3)) * RangeRand(0.2, 26);
			smoke.Lifetime = 1000 * RangeRand(0.1, 1.0); -- Randomize lifetime
			MovableMan:AddParticle(smoke);
			
			local smoke = CreateMOPixel("Spark Yellow "..math.random(1,2), "Base.rte");
			smoke.Pos = self.hitPos - Vector(1 * self.FlipFactor, 0):RadRotate(self.RotAngle);
			smoke.Vel = Vector(-1, 0):RadRotate(self.RotAngle + RangeRand(-0.8,0.8)) * RangeRand(7, 45);
			smoke.Lifetime = 700 * RangeRand(0.1, 1.0); -- Randomize lifetime
			MovableMan:AddParticle(smoke);
			
			local smoke = CreateMOSParticle("Small Smoke Ball 1", "Base.rte");
			smoke.Pos = self.hitPos - Vector(1 * self.FlipFactor, 0):RadRotate(self.RotAngle);
			smoke.Vel = Vector(-1, 0):RadRotate(self.RotAngle + RangeRand(-0.3,0.3)) * RangeRand(0.4, 8);
			smoke.Lifetime = smoke.Lifetime * RangeRand(0.6, 1.6) * 0.5; -- Randomize lifetime
			smoke.GlobalAccScalar = RangeRand(-0.1, 0.1)
			MovableMan:AddParticle(smoke);
		end		
	end
	
	self.ToDelete = true;
	
end