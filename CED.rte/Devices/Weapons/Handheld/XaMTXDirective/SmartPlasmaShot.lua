function Create(self)
	self.flyLoop = CreateSoundContainer("Smart Plasma Fly Loop CED Xarix MTX Directive", "CED.rte");
	self.flyLoop:Play(self.Pos);
	self.engageSound = CreateSoundContainer("Smart Plasma Engage CED Xarix MTX Directive", "CED.rte");
	
	self.homingStrength = 85;
	
	if self:NumberValueExists("TargetID") and MovableMan:ValidMO(MovableMan:FindObjectByUniqueID(self:GetNumberValue("TargetID"))) then
		local mo = MovableMan:FindObjectByUniqueID(self:GetNumberValue("TargetID"));
		if mo and IsActor(mo) then
			self.target = ToActor(mo);
			self.targetPos = mo.Pos;	
			
			-- see if the angle we've been fired at is extreme, and if so initiate a delay before homing kicks in	
			local dif = SceneMan:ShortestDistance(self.Pos,self.targetPos,SceneMan.SceneWrapsX);
			local angToTarget = dif.AbsRadAngle;
			local velAngleTest = Vector(self.Vel.X, self.Vel.Y):SetMagnitude(100)-- + SceneMan.GlobalAcc
			local velAngleTestTarget = Vector(100, 0):RadRotate(angToTarget)
			local velTestDif = velAngleTestTarget - velAngleTest	
			if velTestDif.Magnitude > 65 then
				self.homingDelayTimer = Timer();
				self.homingDelay = 100;
				self.homingStrength = 160;
			else
				self.engageSound:Play(self.Pos);
				self.engagePlayed = true;
			end
		end
	end
	
	self.WoundDamageMultiplier = 1.5;
	
	self.penetrationStrength = 200;
	self.mechanicalDamageMultiplier = 2;
	self.EffectRotAngle = self.Vel.AbsRadAngle;
	--Check backward (second argument) on the first frame as the projectile might be bouncing off something immediately
	PlasmaDissipate(self, true);

	self.trailPar = CreateMOPixel("Particle CED Plasma Shot Trail Glow", "CED.rte");
	self.trailPar.Pos = self.Pos - (self.Vel * rte.PxTravelledPerFrame);
	self.trailPar.Vel = self.Vel * 0.1;
	self.trailPar.Lifetime = 60;
	MovableMan:AddParticle(self.trailPar);	
	
end
function Update(self)
	self.flyLoop.Pos = self.Pos;
	self.engageSound.Pos = self.Pos;
	
	self.GlobalAccScalar = 0
	
	if self.target and ((not self.homingDelayTimer) or (self.homingDelayTimer:IsPastSimMS(self.homingDelay))) then
		if not MovableMan:ValidMO(self.target) then
			self.target = nil;
		else
			if not self.engagePlayed then
				self.engagePlayed = true;
				self.engageSound:Play(self.Pos);
			end
			
			self.targetPos = self.target.Pos + Vector(0, -10):RadRotate(self.target.RotAngle); -- bias so it's not low torso we're aiming for
			
			local dif = SceneMan:ShortestDistance(self.Pos,self.targetPos,SceneMan.SceneWrapsX);
			local angToTarget = dif.AbsRadAngle	
			local velCurrent = self.Vel-- + SceneMan.GlobalAcc
			local velTarget = Vector(70, 0):RadRotate(angToTarget)
			velTarget = velTarget:RadRotate(angToTarget * 0.01)
			--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + velTarget,  5);
			local velDif = velTarget - velCurrent
			
			local oldVelMagnitude = self.Vel.Magnitude;
			
			-- acceleration
			self.Vel = self.Vel + (velDif:SetMagnitude(math.max(velDif.Magnitude, self.homingStrength)) * TimerMan.DeltaTimeSecs * 4)
			
			self.flyLoopFactor = oldVelMagnitude - self.Vel.Magnitude;
			self.flyLoop.Volume = math.min(1.5, math.abs(self.flyLoopFactor) / 5);
			self.flyLoop.Pitch = 1 + math.min(0.5, math.abs(self.flyLoopFactor) / 10);
		end
	else
		self.flyLoop.Volume = 0.5;
		self.flyLoop.Pitch = 1;
	end
	
	self.ToSettle = false;
	if self.explosion then
		self.ToDelete = true;
	else
		self.EffectRotAngle = self.Vel.AbsRadAngle;
		if self.trailPar and MovableMan:IsParticle(self.trailPar) then
			self.trailPar.Pos = self.Pos - Vector(self.Vel.X, self.Vel.Y):SetMagnitude(10 - 1);
			self.trailPar.Vel = self.Vel * 0.5;
			self.trailPar.Lifetime = self.Age + TimerMan.DeltaTimeMS;
		else
			self.trailPar = nil;
		end
	end	
end

function PlasmaDissipate(self, inverted)
	if not self.ToDelete then
		local trace = inverted and Vector(-self.Vel.X, -self.Vel.Y):SetMagnitude(GetPPM()) or Vector(self.Vel.X, self.Vel.Y):SetMagnitude(self.Vel.Magnitude * rte.PxTravelledPerFrame + 1);
		local hit = inverted == false;
		local hitPos = Vector(self.Pos.X, self.Pos.Y);
		local skipPx = math.sqrt(self.Vel.Magnitude) * 0.5;

		local moid = SceneMan:CastObstacleRay(self.Pos, trace, hitPos, Vector(), self.ID, self.Team, rte.airID, skipPx) >= 0 and SceneMan:GetMOIDPixel(hitPos.X, hitPos.Y) or self.HitWhatMOID;
		local mo = MovableMan:GetMOFromID(moid);
		
		if mo and mo.Team ~= self.Team then
			hit = true;
			if IsMOSRotating(mo) and self.penetrationStrength > mo.Material.StructuralIntegrity then
				mo = ToMOSRotating(mo);
				local woundName = mo:GetEntryWoundPresetName();
				if woundName ~= "" then
					local wound = CreateAEmitter(woundName);
					wound.BurstDamage = wound.BurstDamage * self.WoundDamageMultiplier;
					local woundOffset = SceneMan:ShortestDistance(mo.Pos, hitPos, SceneMan.SceneWrapsX);
					woundOffset.X = woundOffset.X * mo.FlipFactor;
					wound.InheritedRotAngleOffset = woundOffset.AbsRadAngle;
					mo:AddWound(wound, woundOffset:RadRotate(-mo.RotAngle * mo.FlipFactor), true);
				end
				if IsActor(mo:GetRootParent()) and ToActor(mo:GetRootParent()):IsMechanical() then
					local woundName = mo:GetEntryWoundPresetName();
					if woundName ~= "" then
						local wound = CreateAEmitter(woundName);
						wound.BurstDamage = (wound.BurstDamage * self.WoundDamageMultiplier) * self.mechanicalDamageMultiplier;
						local woundOffset = SceneMan:ShortestDistance(mo.Pos, hitPos, SceneMan.SceneWrapsX);
						woundOffset.X = woundOffset.X * mo.FlipFactor;
						wound.InheritedRotAngleOffset = woundOffset.AbsRadAngle;
						mo:AddWound(wound, woundOffset:RadRotate(-mo.RotAngle * mo.FlipFactor), true);
					end
				end
			end
		elseif self.Vel:MagnitudeIsLessThan(1) then
			hit = true;
		end

		if hit then
			self.flyLoop:Stop(-1);
			self.engageSound:Stop(-1);
			local offset = Vector(self.Vel.X, self.Vel.Y):SetMagnitude(skipPx);
			self.explosion = CreateAEmitter("CED.rte/CED Plasma Dissipate Effect");
			self.explosion.Pos = hitPos - offset;
			self.explosion.RotAngle = offset.AbsRadAngle;
			self.explosion.Team = self.Team;
			self.explosion.Vel = offset;
			MovableMan:AddParticle(self.explosion);

			self.TrailLength = 0;
			self.ToDelete = true;
		end
		
		return hit;
	end
	
	return false;
end

function OnCollideWithMO(self, mo, parentMO)
	PlasmaDissipate(self, false);
end

function OnCollideWithTerrain(self, terrainID)
	PlasmaDissipate(self, false);
end

function Destroy(self)
	self.flyLoop:Stop(-1);
	self.engageSound:Stop(-1);
end