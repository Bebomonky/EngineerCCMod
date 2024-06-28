require("Mods.Extensions.ExtensionMan")
function Create(self)

	self.buildingLaser = true
	self.buildingLaserTimer = Timer();
	self.buildingLaserDelay = 70;
	self.buildingPos = Vector(self.Pos.X, self.Pos.Y)
	self.buildingMOUniqueID = -1

end

function ThreadedUpdate(self)

	PrimitiveMan:DrawCirclePrimitive(self.Pos, self.CEDBuildRange, 13);
	
	local foundAnyMO = false;
	for mo in MovableMan:GetMOsInRadius(self.Pos, self.CEDBuildRange, self.Team) do
		if mo:IsInGroup("CED - Buildables") then
			foundAnyMO = true;
			if self.closestMO and MovableMan:ValidMO(self.closestMO) then
				if self.closestMO.UniqueID ~= mo.UniqueID and SceneMan:ShortestDistance(self.Pos, mo.Pos, SceneMan.SceneWrapsX).Magnitude	< self.closestDistance.Magnitude then
					self.closestMO = mo;
					self.closestDistance = SceneMan:ShortestDistance(self.Pos, self.closestMO.Pos, SceneMan.SceneWrapsX);
				end
			else
				self.closestMO = mo;
			end
			-- always update distance vector
			self.closestDistance = SceneMan:ShortestDistance(self.Pos, self.closestMO.Pos, SceneMan.SceneWrapsX);
		end
	end
	if not foundAnyMO then
		self.closestMO = nil;
		self.closestDistance = nil;
	end
	
	if self.closestMO then
	
		if self.CEDBuildTimer:IsPastSimMS(self.CEDBuildDelay) then
			self.CEDBuildTimer:Reset();
			self.toSendBuildPoints = true;
			self:RequestSyncedUpdate()
		end
	
		-- Laser
		local offset = Vector(-2 * self.FlipFactor, -3):RadRotate(self.closestDistance.AbsRadAngle)
		local point = self.Pos + offset
		
		--PrimitiveMan:DrawCirclePrimitive(point, 1, 13);
		--PrimitiveMan:DrawLinePrimitive(point, point, 13);
		
		if self.buildingLaserTimer:IsPastSimMS(self.buildingLaserDelay) then
			local glow = CreateMOPixel("Mine Laser Particle");
			glow.Pos = point;
			MovableMan:AddParticle(glow);
			
			local rayVec = self.closestDistance;
			
			local endPos = point + rayVec; -- This value is going to be overriden by function below, this is the end of the ray
			self.ray = SceneMan:CastObstacleRay(point, rayVec, Vector(0, 0), endPos, self.ID, self.Team, 0, 2) -- Do the hitscan stuff, raycast
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
					glow.EffectRotAngle = self.closestDistance.AbsRadAngle;
					MovableMan:AddParticle(glow);
				end
			end
			
			self.buildingLaserTimer:Reset()
		end
	end

end

function SyncedUpdate(self)
	if self.toSendBuildPoints and self.closestMO then
		self.closestMO:SendMessage("CED_AddBuildPoints", self.CEDBuildRate);
	end
		
	self.toSendBuildPoints = false;
end