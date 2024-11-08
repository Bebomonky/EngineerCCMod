require("/CEDSettings");

function Create(self)
	self.BASCGSRMechLastSound = CreateSoundContainer("Mech Last CED CED-BAS CGSR", "CED.rte");
	
	self.BASCGSRLaserOnSound = CreateSoundContainer("Laser On CED CED-BAS CGSR", "CED.rte");
	self.BASCGSRLaserOffSound = CreateSoundContainer("Laser Off CED CED-BAS CGSR", "CED.rte");
	
	self.BASCGSRLaserOn = false;
end

function OnFire(self)
	local velocity = 100;

	local shot = CreateMOPixel("Bullet CED CED-BAS CGSR Scripted", "CED.rte");
	shot.Pos = self.MuzzlePos + Vector(0.1*self.FlipFactor, 0):RadRotate(self.RotAngle);
	shot.Vel = self.Vel + Vector(velocity * self.FlipFactor, 0):RadRotate(self.RotAngle);
	shot.Team = self.Team;
	shot.IgnoresTeamHits = true;
	shot:SetWhichMOToNotHit(ToMovableObject(self), 150);
	MovableMan:AddParticle(shot);

	-- Use our HEATStats to spawn a casing every time we fire.
	local casing
	casing = self.HEATCasing:Clone();
	casing.Pos = self.EjectionPos;
	casing.Vel = self.Vel + Vector(self.HEATCasingVelocity.X * self.FlipFactor, self.HEATCasingVelocity.Y):RadRotate(self.RotAngle);
	casing.RotAngle = self.RotAngle;
	casing.HFlipped = self.HFlipped;
	MovableMan:AddParticle(casing);
	
	if self.RoundInMagCount == 0 then
		self.BASCGSRMechLastSound:Play(self.Pos);
	end
end

function OnAttach(self, newParent)
	if IsAHuman(newParent:GetRootParent()) then
		self.parent = ToAHuman(newParent:GetRootParent());
		self.parentController = self.parent:GetController();
	end
end

function OnDetach(self)
	self.parent = nil;
	self.parentController = nil;
end

function ThreadedUpdate(self)
	self.BASCGSRMechLastSound.Pos = self.Pos;
	self.BASCGSRLaserOnSound.Pos = self.Pos;
	self.BASCGSRLaserOffSound.Pos = self.Pos;
	
	if self.parent then
		if self.parentController:IsState(Controller.WEAPON_PRIMARY_HOTKEYSTART) then
			if self.BASCGSRLaserOn then
				self.BASCGSRLaserOn = false;
				self.BASCGSRLaserOffSound:Play(self.Pos);
			else
				self.BASCGSRLaserOn = true;
				self.BASCGSRLaserOnSound:Play(self.Pos);
			end
		end
	end
	
	-- Laser by fil
	if self.BASCGSRLaserOn then
		local offset = Vector(1 * self.FlipFactor, -3):RadRotate(self.RotAngle)
		local point = self.Pos + offset
		
		--PrimitiveMan:DrawCirclePrimitive(point, 1, 13);
		--PrimitiveMan:DrawLinePrimitive(point, point, 13);
	
		local glow = CreateMOPixel("Mine Laser Particle");
		glow.Pos = point;
		MovableMan:AddParticle(glow);
		
		local rayVec = Vector(700 * self.FlipFactor, 0):RadRotate(self.RotAngle)
		
		local endPos = point + rayVec; -- This value is going to be overriden by function below, this is the end of the ray
		self.ray = SceneMan:CastObstacleRay(point, rayVec, Vector(0, 0), endPos, self.parent and self.parent.ID or self.ID, self.Team, 0, 2) -- Do the hitscan stuff, raycast
		local vec = SceneMan:ShortestDistance(point,endPos,SceneMan.SceneWrapsX);
		
		--PrimitiveMan:DrawLinePrimitive(point, point + vec, 13);
		if self.ray > 0 then
			local glow = CreateMOPixel("Mine Laser Particle");
			glow.Pos = endPos;
			MovableMan:AddParticle(glow);
			
			glow = CreateMOPixel("Mine Laser Particle");
			glow.Pos = endPos;
			MovableMan:AddParticle(glow);
			PrimitiveMan:DrawLinePrimitive(endPos, endPos, 13);
		end
		
		local maxi = vec.Magnitude / GetPPM() * 1.5
		for i = 1, maxi do
			if math.random(1,3) >= 2 then
				local glow = CreateMOPixel("Mine Laser Beam "..math.random(1,3));
				glow.Pos = point + vec * math.max(math.min((1 / maxi * i) + RangeRand(-1.0,1.0) * 0.03, 1), 0);
				glow.EffectRotAngle = self.RotAngle;
				MovableMan:AddParticle(glow);
			end
		end
	end
end