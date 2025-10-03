function Create(self)
	
	self.KhSverlitPlantSound = CreateSoundContainer("Plant CED Khrabarovsk w-BN Sverlit", "CED.rte");
	self.KhSverlitDrillSound = CreateSoundContainer("Drill CED Khrabarovsk w-BN Sverlit", "CED.rte");
	
	-- Sounds for being planted on, or drilling certain materials, on top of the default sounds.
	self.KhSverlitTerrainSounds = {
	Impact = {[12] = CreateSoundContainer("Plant Concrete CED Khrabarovsk w-BN Sverlit", "CED.rte"),
			[164] = CreateSoundContainer("Plant Concrete CED Khrabarovsk w-BN Sverlit", "CED.rte"),
			[177] = CreateSoundContainer("Plant Concrete CED Khrabarovsk w-BN Sverlit", "CED.rte"),
			[9] = CreateSoundContainer("Plant Soft CED Khrabarovsk w-BN Sverlit", "CED.rte"),
			[10] = CreateSoundContainer("Plant Soft CED Khrabarovsk w-BN Sverlit", "CED.rte"),
			[11] = CreateSoundContainer("Plant Soft CED Khrabarovsk w-BN Sverlit", "CED.rte"),
			[128] = CreateSoundContainer("Plant Soft CED Khrabarovsk w-BN Sverlit", "CED.rte"),
			[6] = CreateSoundContainer("Plant Soft CED Khrabarovsk w-BN Sverlit", "CED.rte"),
			[8] = CreateSoundContainer("Plant Soft CED Khrabarovsk w-BN Sverlit", "CED.rte"),
			[178] = CreateSoundContainer("Plant SolidMetal CED Khrabarovsk w-BN Sverlit", "CED.rte"),
			[179] = CreateSoundContainer("Plant SolidMetal CED Khrabarovsk w-BN Sverlit", "CED.rte"),
			[180] = CreateSoundContainer("Plant SolidMetal CED Khrabarovsk w-BN Sverlit", "CED.rte"),
			[181] = CreateSoundContainer("Plant SolidMetal CED Khrabarovsk w-BN Sverlit", "CED.rte"),
			[182] = CreateSoundContainer("Plant SolidMetal CED Khrabarovsk w-BN Sverlit", "CED.rte")},
			
	Drill = {[12] = CreateSoundContainer("Drill Concrete CED Khrabarovsk w-BN Sverlit", "CED.rte"),
			[164] = CreateSoundContainer("Drill Concrete CED Khrabarovsk w-BN Sverlit", "CED.rte"),
			[177] = CreateSoundContainer("Drill Concrete CED Khrabarovsk w-BN Sverlit", "CED.rte"),
			[178] = CreateSoundContainer("Drill SolidMetal CED Khrabarovsk w-BN Sverlit", "CED.rte"),
			[179] = CreateSoundContainer("Drill SolidMetal CED Khrabarovsk w-BN Sverlit", "CED.rte"),
			[180] = CreateSoundContainer("Drill SolidMetal CED Khrabarovsk w-BN Sverlit", "CED.rte"),
			[181] = CreateSoundContainer("Drill SolidMetal CED Khrabarovsk w-BN Sverlit", "CED.rte"),
			[182] = CreateSoundContainer("Drill SolidMetal CED Khrabarovsk w-BN Sverlit", "CED.rte")}};
			
	self.KhSverlitTerrainDrillSound = nil; -- So we can cancel it on destroy
	
	self.KhSverlitParticleVelocity = 135;
	self.KhSverlitParticleSpread = 45 / 2;
	
	self.KhSverlitPlanted = false;
	self.KhSverlitPlantedTerrainID = -1;
	
	self.KhSverlitPinPosition = self.Pos;
	self.KhSverlitPinRotAngle = self.RotAngle;
	
	self.KhSverlitDrillTimer = Timer();
	self.KhSverlitDrillStartDelay = 500; --ms
	self.KhSverlitDrillTotalTime = 6400; --ms total time of drill/forwards destruction progression
	self.KhSverlitDrillGibAfterSpentDelay = 1500; --ms
	
	self.KhSverlitDrillStarted = false;
	self.KhSverlitDrillSpent = false;
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
	-- Suuuuper old, Softstorm.rte era placement logic. Dunno if there's anything better, but this works lol
	if self.parent then
		local hitLocation = Vector()
		local checkOrigin = self.parent.FGArm.Pos + Vector(7 * self.FlipFactor, 2):RadRotate(self.RotAngle)
		local checkVec = Vector(24 * self.FlipFactor, 0):RadRotate(self.RotAngle)
		local terrCheck = SceneMan:CastStrengthRay(checkOrigin, checkVec, 30, hitLocation, 2, 0, SceneMan.SceneWrapsX)		
		local direction = self.RotAngle		
		local rayEndPos = checkOrigin + checkVec
		
		if terrCheck then -- Valid placement possible
			local rayHitPos = SceneMan:GetLastRayHitPos()
			rayEndPos = Vector(rayHitPos.X, rayHitPos.Y)
			
			local normal = Vector()
			local maxi = 25
			for i = 1, maxi do
				local vec = Vector(3,0):RadRotate(math.pi * 2 * (i / maxi))
				PrimitiveMan:DrawLinePrimitive(vec, vec, 5)
				local checkPos = rayEndPos + vec
				local checkPix = SceneMan:GetTerrMatter(checkPos.X, checkPos.Y)
				if checkPix == 0 then
					normal = normal + vec
				end
			end
			direction = normal.AbsRadAngle
			
			-- cool VISUALIZATIONZZZZ
			local color = 120
			local position = rayEndPos + Vector(2,0):RadRotate(direction)
			local width = 27 * 0.5
			local height = 4 * 0.5
			
			PrimitiveMan:DrawLinePrimitive(position + Vector(width, height):RadRotate(direction + math.pi/2), position + Vector(-width, height):RadRotate(direction + math.pi/2), color)		
			PrimitiveMan:DrawLinePrimitive(position + Vector(-width, height):RadRotate(direction + math.pi/2), position + Vector(-width, -height):RadRotate(direction + math.pi/2), color)
			PrimitiveMan:DrawLinePrimitive(position + Vector(width, -height):RadRotate(direction + math.pi/2), position + Vector(width, height):RadRotate(direction + math.pi/2), color)	
			PrimitiveMan:DrawLinePrimitive(position + Vector(width, -height):RadRotate(direction + math.pi/2), position + Vector(-width, -height):RadRotate(direction + math.pi/2), color)
			
			if self:IsActivated() then
				-- Stick
				self.KhSverlitPlanted = true;
				self.KhSverlitPlantedTerrainID = terrainID
				
				self.KhSverlitPlantSound:Play(self.Pos);
				
				local terrainID = SceneMan:GetTerrMatter(hitLocation.X, hitLocation.Y);
				self.KhSverlitPlantedTerrainID = terrainID;
				if self.KhSverlitTerrainSounds.Impact[terrainID] ~= nil then
					self.KhSverlitTerrainSounds.Impact[terrainID]:Play(self.Pos);
				else -- default to concrete
					self.KhSverlitTerrainSounds.Impact[177]:Play(self.Pos);
				end
				
				self.KhSverlitPlantedTerrainID = terrainID
				
				self:RemoveFromParent(true, false)
				self.Pos = rayEndPos + Vector(2,0):RadRotate(direction);
				self.KhSverlitPinPosition = Vector(self.Pos.X, self.Pos.Y);
				self.RotAngle = direction + math.pi
				self.KhSverlitPinRotAngle = self.RotAngle + 0;
				self.Team = -1;
				ToHeldDevice(self).Unpickupable = true; -- doesn't work gg
				self.HitsMOs = true;
				self.Vel = Vector(0, 0);
				
				self.HUDVisible = false;
				self.UnPickupable = true;

				self.KhSverlitDrillTimer:Reset();
				
			end
		else -- Invalid placement
			local color = 120
			local maxi = 3
			for i = 1, maxi do
				PrimitiveMan:DrawLinePrimitive(checkOrigin + checkVec * i / maxi * 0.8, checkOrigin + checkVec * i / maxi, color)
			end
			PrimitiveMan:DrawLinePrimitive(checkOrigin + checkVec, checkOrigin + checkVec + Vector(-5 * self.FlipFactor, 4):RadRotate(self.RotAngle), color)
			PrimitiveMan:DrawLinePrimitive(checkOrigin + checkVec, checkOrigin + checkVec + Vector(-5 * self.FlipFactor, -4):RadRotate(self.RotAngle), color)		
		end
		
	elseif self.KhSverlitPlanted then
		self.Pos = self.KhSverlitPinPosition;
		self.RotAngle = self.KhSverlitPinRotAngle;
		self.Vel = Vector(0, 0);
		
		if self.KhSverlitDrillSpent then
			if self.KhSverlitDrillTimer:IsPastSimMS(self.KhSverlitDrillGibAfterSpentDelay) then
				self:GibThis();
			end
		
		elseif self.KhSverlitDrillStarted then
			
			if self.KhSverlitDrillTimer:IsPastSimMS(self.KhSverlitDrillTotalTime) then
				self.KhSverlitDrillSpent = true
				self.KhSverlitDrillTimer:Reset();
			else
			
				for i = 1, 2 do
					local spread = math.random(-self.KhSverlitParticleSpread, self.KhSverlitParticleSpread);
				
					local particle = CreateMOPixel("Particle CED Khrabarovsk w-BN Sverlit", "CED.rte");
					particle.Pos = self.Pos + Vector(0.1*self.FlipFactor, math.random(-2, 2)):RadRotate(self.RotAngle);
					particle.Vel = self.Vel + Vector(self.KhSverlitParticleVelocity, spread):RadRotate(self.RotAngle);
					particle.Team = self.Team;
					particle.IgnoresTeamHits = true;
					particle:SetWhichMOToNotHit(ToMovableObject(self), 150);
					MovableMan:AddParticle(particle);
				end
			end
			
		else
			if self.KhSverlitDrillTimer:IsPastSimMS(self.KhSverlitDrillStartDelay) then
				self.KhSverlitDrillStarted = true
				self.KhSverlitDrillSound:Play(self.Pos);
				
				if self.KhSverlitTerrainSounds.Drill[self.KhSverlitPlantedTerrainID] ~= nil then
					self.KhSverlitTerrainSounds.Drill[self.KhSverlitPlantedTerrainID]:Play(self.Pos);
					self.KhSverlitTerrainDrillSound = self.KhSverlitTerrainSounds.Drill[self.KhSverlitPlantedTerrainID];
				end
				
				self.KhSverlitDrillTimer:Reset();
			end
		end	
	end
end

function Destroy(self)
	self.KhSverlitTerrainDrillSound:Stop(-1);
	self.KhSverlitDrillSound:Stop(-1);
end