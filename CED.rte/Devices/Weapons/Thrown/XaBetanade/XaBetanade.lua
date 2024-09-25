function Create(self)

	self.pinPullSound = CreateSoundContainer("Pin Pull CED Xarix Betanade", "CED.rte");
	
	self.bounceJetSound = CreateSoundContainer("Bounce Jet CED Xarix Betanade", "CED.rte");
	
	self.firstExploSound = CreateSoundContainer("First Explo CED Xarix Betanade", "CED.rte");
	
	self.secondExploOutdoorsSound = CreateSoundContainer("Second Explo Outdoors CED Xarix Betanade", "CED.rte");
	self.secondExploIndoorsSound = CreateSoundContainer("Second Explo Indoors CED Xarix Betanade", "CED.rte");
	
	self.bounceDelay = 1000;
	self.maxBounceDelay = 5000;
	self.firstExploDelay = 400;
	self.secondExploDelay = 400;
	
	self.Timer = Timer();
	self.maxBounceDelayTimer = Timer();

end

function Update(self)
	self.bounceJetSound.Pos = self.Pos;

	if self.firstExploDone then
		if self.Vel.Magnitude > 2 then
			self.GlobalAccScalar = self.originalAccScalar;
		end
		if self.Timer:IsPastSimMS(self.secondExploDelay) then
		
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
				self.secondExploOutdoorsSound:Play(self.Pos);
			else
				self.secondExploIndoorsSound:Play(self.Pos);
			end		
			
			self:GibThis();
		end
	elseif self.Bounced then
		if self.Timer:IsPastSimMS(self.firstExploDelay) then
			self.firstExploSound:Play(self.Pos);
			self.firstExploDone = true;
			self.Timer:Reset();
			
			 -- Account for activities that might lower this by themselves
			self.originalAccScalar = self.GlobalAccScalar;
			self.GlobalAccScalar = math.min(self.GlobalAccScalar * 0.2, 0.2);
			
			for i = 1, 2 do
				local flipFactor = i == 1 and -1 or 1;
				for i = 1, 16 do
					local Effect = CreateMOSParticle("Tiny Smoke Ball 1", "Base.rte")
					if Effect then
						Effect.HitsMOs = false;
						Effect.Pos = self.Pos + Vector(10 * flipFactor, 0);
						Effect.Vel = Vector(RangeRand(60, 100) * flipFactor, RangeRand(-3, 3));
						MovableMan:AddParticle(Effect)
					end
				end
				for i = 1, 9 do
					local Effect = CreateMOSParticle("Side Thruster Blast Ball 1", "Base.rte")
					if Effect then
						Effect.HitsMOs = false;
						Effect.Pos = self.Pos + Vector(10 * flipFactor, 0);
						Effect.Vel = Vector(RangeRand(60, 100) * flipFactor, RangeRand(-3, 3));
						MovableMan:AddParticle(Effect)
					end
				end
				for i = 1, 20 do
					local Effect = CreateMOPixel("CED Xarix Betanade Grenade Fragment Yellow", "CED.rte")
					if Effect then
						Effect.Pos = self.Pos + Vector(10 * flipFactor, 0);
						Effect.Vel = Vector(RangeRand(60, 100) * flipFactor, RangeRand(-3, 3));
						MovableMan:AddParticle(Effect)
					end
				end
				local Effect = CreateMOPixel("CED Xarix Betanade Grenade Fragment Yellow Scripted", "CED.rte")
				if Effect then
					Effect.Pos = self.Pos + Vector(10 * flipFactor, 0);
					Effect.Vel = Vector(RangeRand(60, 100) * flipFactor, RangeRand(-3, 3));
					MovableMan:AddParticle(Effect)
				end
			end
		end
	elseif self.Active then
		local overMax = self.maxBounceDelayTimer:IsPastSimMS(self.maxBounceDelay);
		if self.Vel.Magnitude > 2 and not overMax then
			self.Timer:Reset();
		elseif self.Timer:IsPastSimMS(self.bounceDelay) or overMax then
			self.Bounced = true;
			self.bounceJetSound:Play(self.Pos);
			self.Vel = self.Vel + Vector(0, -8);
			self.Timer:Reset();
			
			for i = 1, 9 do
				local Effect = CreateMOSParticle("Tiny Smoke Ball 1", "Base.rte")
				if Effect then
					Effect.HitsMOs = false;
					Effect.Pos = self.Pos;
					Effect.Vel = Vector(RangeRand(-2, 2), RangeRand(30, 40));
					MovableMan:AddParticle(Effect)
				end
			end
			
			for i = 1, 3 do
				local Effect = CreateMOSParticle("Side Thruster Blast Ball 1", "Base.rte")
				if Effect then
					Effect.HitsMOs = false;
					Effect.Pos = self.Pos;
					Effect.Vel = Vector(RangeRand(-2, 2), RangeRand(30, 40));
					MovableMan:AddParticle(Effect)
				end
			end
		end
	elseif self.Activated then
		if not self:IsAttached() then
			self.Active = true;
			self.Timer:Reset();
			self.maxBounceDelayTimer:Reset();
		end
	elseif self:IsActivated() then
		self.Frame = 1;
		self.pinPullSound:Play(self.Pos);
		local pin = CreateMOSRotating("Pin CED Xarix Betanade", "CED.rte");
		pin.Vel = self.Vel + Vector (0, -3):RadRotate(self.RotAngle);
		pin.Pos = self.Pos + Vector(0, -2):RadRotate(self.RotAngle);
		MovableMan:AddParticle(pin);
		self.Activated = true;
	end
end