function Create(self)
	self.makeUnstableMassThreshold = 170;
end

function OnCollideWithMO(self, MO, rootMO)
	if not self.madeActorUnstable then
		if self.Vel.Magnitude > 90 then
			if IsActor(rootMO) and rootMO.Mass < self.makeUnstableMassThreshold then
				ToActor(rootMO).Status = 1;
				self.madeActorUnstable = true;
			end
		end
	end
end

function OnCollideWithTerrain(self, terrainID)

	self.Sharpness = 0.5;
	
	-- raycast forwards, as this function seems to happen early and our pos is not at the hit terrain
	local endPos = Vector(0, 0);
	local ray = SceneMan:CastObstacleRay(self.Pos, self.Vel, Vector(0, 0), endPos, 0 , self.Team, 0, 1);
	
	if ray ~= -1 then
		-- then just fine-tune backwards a little...
		endPos = endPos - Vector(self.Vel.X, self.Vel.Y):SetMagnitude(15);
		for i = 1, 26 do
			local particle = CreateMOPixel("Terrain Damage Particle CED Vossberg Titan AMI", "CED.rte");
			particle.Pos = endPos;
			particle.Vel = Vector(self.Vel.X, self.Vel.Y):DegRotate((i - 13) * 2);
			particle.Sharpness = math.random(4, 15);
			particle.Lifetime = 16;
			particle.Team = self.Team;
			MovableMan:AddParticle(particle)
		end
	end

end
