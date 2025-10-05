require("/CEDSettings");

-- Yeah, this is AI. I'm not a mathematician. What're you gonna do about it, sue me?
function segmentsIntersect(A, B, C, D)
    local function orientation(p, q, r)
        return (q.X - p.X) * (r.Y - p.Y) - (q.Y - p.Y) * (r.X - p.X)
    end
    
    local function onSegment(p, q, r)
        return q.X <= math.max(p.X, r.X) and q.X >= math.min(p.X, r.X) and
               q.Y <= math.max(p.Y, r.Y) and q.Y >= math.min(p.Y, r.Y)
    end
    
    local o1 = orientation(A, B, C)
    local o2 = orientation(A, B, D)
    local o3 = orientation(C, D, A)
    local o4 = orientation(C, D, B)
    
    if o1 * o2 < 0 and o3 * o4 < 0 then
        return true
    end
    
    if o1 == 0 and onSegment(A, C, B) then return true end
    if o2 == 0 and onSegment(A, D, B) then return true end
    if o3 == 0 and onSegment(C, A, D) then return true end
    if o4 == 0 and onSegment(C, B, D) then return true end
    
    return false
end

function Create(self)
	self.KhSferaDeflectLightSound = CreateSoundContainer("Deflect Light CED Khrabarovsk Sfera", "CED.rte");
	self.KhSferaDeflectHeavySound = CreateSoundContainer("Deflect Heavy CED Khrabarovsk Sfera", "CED.rte");

	self.KhSferaWalkSound = CreateSoundContainer("Walk CED Khrabarovsk Sfera", "CED.rte");
	self.KhSferaSprintSound = CreateSoundContainer("Sprint CED Khrabarovsk Sfera", "CED.rte");
	self.KhSferaEquipSound = CreateSoundContainer("Equip CED Khrabarovsk Sfera", "CED.rte");
	self.KhSferaDropSound = CreateSoundContainer("Drop CED Khrabarovsk Sfera", "CED.rte");
	
	-- Particle utility.
	self.KhSferaParticleUtility = require("Scripts/Utility/ParticleUtility");	
	
	self.KhSferaAlternateStrideNum = 0;
	
	self.KhSferaDeflectingMinVel = 1.5; -- Min vel to be able to deflect incoming projectiles. This represents 40% chance.
	self.KhSferaDeflectingMaxVel = 6; -- Max vel to be able to deflect incoming projectiles. This represents 95% chance.
	
	self.KhSferaTimer = Timer(); -- Used as a timekeeper, really, will run forever
	self.KhSferaDeflectedMOs = {}; -- So we can re-enable their collision later. Maps UniqueID to elapsed sim time at the time of deflection
	self.KhSferaFailedDeflections = {}; -- So we don't accidentally retry.
	self.KhSferaReenableProjectileTime = 300; --ms
end
					
function OnAttach(self, newParent)
	self.KhSferaAlternateStrideSound = 0;
	self.KhSferaToPlayTerrainImpact = false;
	
	self.KhSferaEquipSound:Play(self.Pos);
	
	if IsAHuman(newParent:GetRootParent()) then
		self.parent = ToAHuman(newParent:GetRootParent());
		self.parentController = self.parent:GetController();
	end
end

function OnDetach(self)
	self.KhSferaEquipSound:Stop(-1);
	
	self.KhSferaToPlayTerrainImpact = true;

	self.parent = nil;
	self.parentController = nil;
end

function OnCollideWithTerrain(self)
	if self.KhSferaToPlayTerrainImpact then
		self.KhSferaToPlayTerrainImpact = false;
		self.KhSferaDropSound:Play(self.Pos);
	end
end

function ThreadedUpdate(self)
	self.KhSferaDeflectLightSound.Pos = self.Pos;
	self.KhSferaDeflectHeavySound.Pos = self.Pos;
	self.KhSferaWalkSound.Pos = self.Pos;
	self.KhSferaSprintSound.Pos = self.Pos;
	self.KhSferaEquipSound.Pos = self.Pos;
	self.KhSferaDropSound.Pos = self.Pos;
	
	for uniqueID, timeAtDeflection in pairs(self.KhSferaDeflectedMOs) do
		local mo = MovableMan:FindObjectByUniqueID(uniqueID)
		if mo then
			if self.KhSferaTimer.ElapsedSimTimeMS - timeAtDeflection > self.KhSferaReenableProjectileTime then
				mo.HitsMOs = true;
				self.KhSferaDeflectedMOs[uniqueID] = nil;
			end
		end
	end

	if self.parent then
		local isMovingFast = self.parent.Vel.Magnitude > self.KhSferaDeflectingMinVel;
		local isSprinting = self.parent.MovementState == Actor.RUN;
		
		if self.parent.StrideFrame then
			local sound = isSprinting and self.KhSferaSprintSound or self.KhSferaWalkSound;
		
			if self.KhSferaAlternateStrideNum == 0 or isSprinting then
				sound:Play(self.Pos);
				self.KhSferaAlternateStrideNum = 1;
			else
				self.KhSferaAlternateStrideNum = 0;
			end
		end
		
		if isMovingFast then
			-- Create a segment that roughly approximates our front surface, segment A made out of points A and B.
			local segmentApointA = self.Pos + Vector(4 * self.FlipFactor, 12):RadRotate(self.RotAngle);
			local segmentApointB = self.Pos + Vector(4 * self.FlipFactor, -12):RadRotate(self.RotAngle);
			-- Flip so cross product makes sense later, we want positive to be valid always
			if self.HFlipped then
				segmentApointA, segmentApointB = segmentApointB, segmentApointA;
			end
			
			--PrimitiveMan:DrawLinePrimitive(segmentApointA, segmentApointB, 120);
			for mo in MovableMan:GetMOsInRadius(self.Pos, 300) do
				if (mo.Team ~= self.parent.Team or mo.IgnoresTeamHits) and mo.Vel.Magnitude > 20 then
					local point = mo.Pos;
					local crossProduct = (segmentApointB.X - segmentApointA.X) * (point.Y - segmentApointA.Y) - (segmentApointB.Y - segmentApointA.Y) * (point.X - segmentApointA.X);
					if crossProduct > 0 then -- It's in front of us!
						-- Check if it's gonna hit us next frame. If so, in synced update, we're going to teleport it to us, make it harmless, then deflect it.
						-- Hopefully not too noticeable...
						local segmentBpointA = mo.Pos;
						local segmentBpointB = mo.Pos + mo.Vel;
						if segmentsIntersect(segmentApointA, segmentApointB, segmentBpointA, segmentBpointB) then
							self.KhSferaProjToDeflect = mo.UniqueID;
							self:RequestSyncedUpdate();
							break;
						end
					end
				end
			end
			
		end
	end
end

function SyncedUpdate(self)
	if not self.parent then
		return
	end
	
	local mo = MovableMan:FindObjectByUniqueID(self.KhSferaProjToDeflect);

	if mo then
		if self.KhSferaFailedDeflections[mo.UniqueID] then
			return
		end	
		
		-- We are definitely past minimum vel if we got here, so start there
		local chance = 0.4 + (math.min(1, self.Vel.Magnitude / 6) * 0.55);
		if math.random() > chance then
			self.KhSferaFailedDeflections[mo.UniqueID] = true;
			return
		end
	
		self.KhSferaDeflectedMOs[mo.UniqueID] = self.KhSferaTimer.ElapsedSimTimeMS;
	
		local heavyDeflection = IsMOSRotating(mo) and mo.Mass > 2;
		local dist = (self.Pos - mo.Pos).Magnitude
		mo.Pos = mo.Pos + Vector(mo.Vel.X, mo.Vel.Y):SetMagnitude(dist)
		mo.HitsMOs = false;
		mo.GetsHitByMOs = false;
		
		mo.Vel = Vector(mo.Vel.X * 0.6, mo.Vel.Y * 0.6):RadRotate(math.random(-0.1, 0.1))
		
		local smokeDataTable = {};
		smokeDataTable.Position = mo.Pos;
		smokeDataTable.Source = self
		smokeDataTable.RadAngle = mo.Vel.AbsRadAngle;
		
		if heavyDeflection then
			CameraMan:AddScreenShake(15, self.Pos);
			self.KhSferaDeflectHeavySound:Play(self.Pos);
			
			for i = 1, 20 do
				local spread = math.random(-5, 5);
				
				local particle = math.random(0, 100) >= 50 and CreateMOPixel("Spark Yellow 1", "Base.rte") or CreateMOPixel("Spark Yellow 2", "Base.rte")
				particle.Pos = mo.Pos + Vector(0, math.random(-2, 2)):RadRotate(mo.RotAngle);
				particle.Vel = self.Vel + Vector(20 * RangeRand(0.5, 1.5) * self.FlipFactor, spread):RadRotate(self.RotAngle);
				particle.Team = self.Team;
				particle.IgnoresTeamHits = true;
				particle:SetWhichMOToNotHit(ToMovableObject(self), 150);
				MovableMan:AddParticle(particle);
			end
			
			smokeDataTable.Power = 75;
			smokeDataTable.Spread = 25;
			smokeDataTable.SmokeMult = 1.0;
			smokeDataTable.ExploMult = 2.0;
			smokeDataTable.WidthSpread = 2;
			smokeDataTable.VelocityMult = 0.3
			smokeDataTable.LingerMult = 1.2;
			smokeDataTable.AirResistanceMult = 1.8;
			smokeDataTable.GravMult = 1;
			self.KhSferaParticleUtility:CreateDirectionalSmokeEffect(smokeDataTable);
			
			-- Now a wider FX in front!
			smokeDataTable.RadAngle = mo.Vel.AbsRadAngle + math.pi;
			smokeDataTable.Power = 25;
			smokeDataTable.Spread = 45;
			smokeDataTable.VelocityMult = 0.1;
			self.KhSferaParticleUtility:CreateDirectionalSmokeEffect(smokeDataTable);
			
		else
			self.KhSferaDeflectLightSound:Play(self.Pos);
			
			for i = 1, 2 do
				local spread = math.random(-5, 5);
				
				local particle = math.random(0, 100) >= 50 and CreateMOPixel("Spark Yellow 1", "Base.rte") or CreateMOPixel("Spark Yellow 2", "Base.rte")
				particle.Pos = mo.Pos + Vector(0, math.random(-2, 2)):RadRotate(mo.RotAngle);
				particle.Vel = self.Vel + Vector(20 * RangeRand(0.5, 1.5) * self.FlipFactor, spread):RadRotate(self.RotAngle);
				particle.Team = self.Team;
				particle.IgnoresTeamHits = true;
				particle:SetWhichMOToNotHit(ToMovableObject(self), 150);
				MovableMan:AddParticle(particle);
			end			
			
			smokeDataTable.Power = 25;
			smokeDataTable.Spread = 15;
			smokeDataTable.SmokeMult = 1.0;
			smokeDataTable.ExploMult = 0.0;
			smokeDataTable.WidthSpread = 2;
			smokeDataTable.VelocityMult = 3
			smokeDataTable.LingerMult = 1;
			smokeDataTable.AirResistanceMult = 1.1;
			smokeDataTable.GravMult = 0.2;
			self.KhSferaParticleUtility:CreateDirectionalSmokeEffect(smokeDataTable);
			
			-- Now a wider FX in front!
			smokeDataTable.RadAngle = mo.Vel.AbsRadAngle + math.pi;
			smokeDataTable.Power = 10;
			smokeDataTable.Spread = 70;
			smokeDataTable.VelocityMult = 0.2
			self.KhSferaParticleUtility:CreateDirectionalSmokeEffect(smokeDataTable);
		end
		
		self.KhSferaParticleUtility:CreateDirectionalSmokeEffect(smokeDataTable);
		
	end
end