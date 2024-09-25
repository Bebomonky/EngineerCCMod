function Create(self)
	self.pinPullSound = CreateSoundContainer("Pin Pull CED Vossberg Concussor", "CED.rte");
	
	self.implodeSound = CreateSoundContainer("Implode CED Vossberg Concussor", "CED.rte");
	
	self.exploOutdoorsSound = CreateSoundContainer("Explo Outdoors CED Vossberg Concussor", "CED.rte");
	self.exploIndoorsSound = CreateSoundContainer("Explo Indoors CED Vossberg Concussor", "CED.rte");
	
	self.exploDelay = 2500;
	self.implosionRadius = 150;
	self.currentRadius = 0;
	
	self.Timer = Timer();
	self.pushTime = 300;
	self.pullTime = 300;
end

function Update(self)
	self.implodeSound.Pos = self.Pos;
	
	PrimitiveMan:DrawCirclePrimitive(self.Pos, self.currentRadius, 13);
	
	if self.Exploding then
		self.Vel = Vector(self.Vel.X * 0.3, self.Vel.Y * 0.3);
	end

	if self.Imploding then
		self.currentRadius = self.implosionRadius;
		
		for mo in MovableMan:GetMOsInRadius(self.Pos, self.currentRadius, -1, false) do
			local dist = SceneMan:ShortestDistance(self.Pos, mo.Pos, SceneMan.SceneWrapsX);
			
			if SceneMan:CastStrengthSumRay(self.Pos, self.Pos + dist, 2, -1) < 1000 then
				mo.Vel = mo.Vel + dist:SetMagnitude(math.max(-1, -1 / (mo.Mass / 200)));
				
				if IsActor(mo) then
					mo = ToActor(mo);
					mo.Status = math.max(mo.Status, 1);
				end
			end
		end
		
		if self.Timer:IsPastSimMS(self.pullTime) then	
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

			self.ray = SceneMan:CastObstacleRay(self.Pos, Vector2, Vector3, Vector4, self.RootID, self.Team, 128, 7);
			self.rayRight = SceneMan:CastObstacleRay(self.Pos, Vector2Right, Vector3, Vector4, self.RootID, self.Team, 128, 7);
			self.rayLeft = SceneMan:CastObstacleRay(self.Pos, Vector2Left, Vector3, Vector4, self.RootID, self.Team, 128, 7);			
			self.raySlightRight = SceneMan:CastObstacleRay(self.Pos, Vector2SlightRight, Vector3, Vector4, self.RootID, self.Team, 128, 7);
			self.raySlightLeft = SceneMan:CastObstacleRay(self.Pos, Vector2SlightLeft, Vector3, Vector4, self.RootID, self.Team, 128, 7);
			
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
				self.exploOutdoorsSound:Play(self.Pos);
			else
				self.exploIndoorsSound:Play(self.Pos);
			end		
			
			local payload = CreateMOPixel("CED Vossberg Concussor Stun Particle", "CED.rte");
			if payload then
				payload.Pos = self.Pos;
				MovableMan:AddParticle(payload);
			end			
			self:GibThis();
			
			for mo in MovableMan:GetMOsInRadius(self.Pos, self.currentRadius, -1, false) do
				local dist = SceneMan:ShortestDistance(self.Pos, mo.Pos, SceneMan.SceneWrapsX);
				if SceneMan:CastStrengthSumRay(self.Pos, self.Pos + dist, 2, -1) < 1000	then
					mo.Vel = mo.Vel + dist:SetMagnitude(math.min(8, 8 / (mo.Mass / 200)));
					mo.Vel = mo.Vel + Vector (0, math.min(mo.Vel.Y, -9));
				end
			end			
			
		end
	elseif self.Exploding then
		self.currentRadius = self.implosionRadius * (self.Timer.ElapsedSimTimeMS / self.pushTime);
		
		for mo in MovableMan:GetMOsInRadius(self.Pos, self.currentRadius, -1, false) do
			local dist = SceneMan:ShortestDistance(self.Pos, mo.Pos, SceneMan.SceneWrapsX);
		
			if SceneMan:CastStrengthSumRay(self.Pos, self.Pos + dist, 2, -1) < 1000	then
				mo.Vel = mo.Vel + dist:SetMagnitude(math.min(1, 1 / (mo.Mass / 200)));
				
				if IsActor(mo) then
					mo = ToActor(mo);
					mo.Status = math.max(mo.Status, 1);
				end
			end
		end

		if self.Timer:IsPastSimMS(self.pushTime) then
			self.Imploding = true;
			self.Timer:Reset();
			
			for mo in MovableMan:GetMOsInRadius(self.Pos, self.currentRadius, -1, false) do
				local dist = SceneMan:ShortestDistance(self.Pos, mo.Pos, SceneMan.SceneWrapsX);
				if SceneMan:CastStrengthSumRay(self.Pos, self.Pos + dist, 2, -1) < 1000	then
					mo.Vel = mo.Vel + Vector (0, math.min(mo.Vel.Y, -5));
				end
			end
		end
	elseif self.Active then
		if self.Timer:IsPastSimMS(self.exploDelay) then
			self.Exploding = true;
			self.implodeSound:Play(self.Pos);
			self.currentRadius = 0;
			self.Timer:Reset();
			
			for i = 1, 9 do
				local Effect = CreateMOSParticle("Tiny Smoke Ball 1", "Base.rte")
				if Effect then
					Effect.HitsMOs = false;
					Effect.Pos = self.Pos;
					Effect.Vel = self.Vel;
					MovableMan:AddParticle(Effect)
				end
			end
		end
	elseif self.Activated then
		if not self:IsAttached() then
			self.Active = true;
			self.Timer:Reset();
		end
	elseif self:IsActivated() then
		self.Frame = 1;
		self.pinPullSound:Play(self.Pos);
		local pin = CreateMOSRotating("Pin CED Vossberg Concussor", "CED.rte");
		pin.Vel = self.Vel + Vector (0, -3):RadRotate(self.RotAngle);
		pin.Pos = self.Pos + Vector(0, -2):RadRotate(self.RotAngle);
		MovableMan:AddParticle(pin);
		self.Activated = true;
	end
end