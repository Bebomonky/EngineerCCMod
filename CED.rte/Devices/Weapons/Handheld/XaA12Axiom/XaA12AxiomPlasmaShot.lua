function OnMessage(self, message, object)
	if message == "XaA12AxiomCharged" then
		self.HitsMOs = false;
	end
end

function Create(self)
	self.maxPenetratedStructuralIntegrity = 250;
	self.maxPenetrations = 2;
	self.Penetrations = 0;
	self.mechanicalDamageMultiplier = 2;
	self.EffectRotAngle = self.Vel.AbsRadAngle;
	--Check backward (second argument) on the first frame as the projectile might be bouncing off something immediately
	PlasmaDissipate(self, true);

	self.trailPar = CreateMOPixel("Particle CED Plasma Shot Trail Glow", "CED.rte");
	self.trailPar.Pos = self.Pos - (self.Vel * rte.PxTravelledPerFrame);
	self.trailPar.Vel = self.Vel * 0.1;
	self.trailPar.Lifetime = 60;
	MovableMan:AddParticle(self.trailPar);
	
	self.hitMOTable = {}
end

function Update(self)
	self.ToSettle = false;
	if self.explosion then
		self.ToDelete = true;
	else
		self.EffectRotAngle = self.Vel.AbsRadAngle;
		if self.trailPar and MovableMan:IsParticle(self.trailPar) then
			self.trailPar.Pos = self.Pos - Vector(self.Vel.X, self.Vel.Y):SetMagnitude(self.TrailLength - 1);
			self.trailPar.Vel = self.Vel * 0.5;
			self.trailPar.Lifetime = self.Age + TimerMan.DeltaTimeMS;
		else
			self.trailPar = nil;
		end
	end
	
	if self.HitsMOs == false then
	
		local offset = self.Vel * rte.PxTravelledPerFrame
		
		local rayOrigin = self.Pos - offset
		local rayVec = Vector(self.Vel.X,self.Vel.Y):SetMagnitude(self.Vel.Magnitude * rte.PxTravelledPerFrame);
		local moCheck = SceneMan:CastMORay(rayOrigin, rayVec, self.ID, self.Team, 0, false, 2); -- Raycast
		if moCheck ~= rte.NoMOID then	
			local rayHitPos = SceneMan:GetLastRayHitPos()
			local mo = MovableMan:GetMOFromID(moCheck)
			if IsMOSRotating(mo) then
				local hitAllowed = true;
				if self.hitMOTable then -- this shouldn't be needed but it is
					for index, root in pairs(self.hitMOTable) do
						if root == mo:GetRootParent().UniqueID or index == mo.UniqueID then
							hitAllowed = false;
						end
					end
				end
				if hitAllowed == true then
					mo = ToMOSRotating(mo);
					self.hitMOTable[mo.UniqueID] = mo:GetRootParent().UniqueID;
					local hitPos = SceneMan:GetLastRayHitPos()
					local dist = SceneMan:ShortestDistance(mo.Pos, hitPos, SceneMan.SceneWrapsX);
					local hitOffset = Vector(dist.X * mo.FlipFactor, dist.Y):RadRotate(-mo.RotAngle * mo.FlipFactor);		
					local hitAngle = hitOffset.AbsRadAngle - (mo.HFlipped and math.pi or 0);
					
					local penetration = self.maxPenetratedStructuralIntegrity/math.max(mo.Material.StructuralIntegrity, 1);
					self.maxPenetratedStructuralIntegrity = self.maxPenetratedStructuralIntegrity - mo.Material.StructuralIntegrity;
					if self.maxPenetratedStructuralIntegrity < 0 then
						self.HitsMOs = true;
					end
					self.Penetrations = self.Penetrations + 1;
					if self.Penetrations > self.maxPenetrations then
						self.HitsMOs = true;
					end
					
					local woundsToAdd = 2;
					local woundDamageMultiplier = self.WoundDamageMultiplier;
					if IsActor(mo:GetRootParent()) and ToActor(mo:GetRootParent()):IsMechanical() then
						woundsToAdd = 3;
					end
					
					local dist = SceneMan:ShortestDistance(mo.Pos, hitPos, SceneMan.SceneWrapsX);
					
					local woundName = mo:GetEntryWoundPresetName();
					local woundNameExit = mo:GetExitWoundPresetName();
					for i = 1, woundsToAdd do
						if woundName ~= "" then
							local wound = CreateAEmitter(woundName);
							wound.DamageMultiplier = woundDamageMultiplier;
							wound.InheritedRotAngleOffset = hitAngle;
							wound.DrawAfterParent = true;
							mo:AddWound(wound, hitOffset, true);
						end
						if woundNameExit ~= "" then
							local wound = CreateAEmitter(woundNameExit);
							wound.DamageMultiplier = woundDamageMultiplier;
							wound.InheritedRotAngleOffset = hitAngle;
							wound.DrawAfterParent = true;
							mo:AddWound(wound, hitOffset, true);
						end
					end
					
					local hitEffect = CreateAEmitter("CED.rte/CED Plasma Burst Effect");
					hitEffect.Pos = hitPos;
					hitEffect.RotAngle = offset.AbsRadAngle;
					hitEffect.Team = self.Team;
					hitEffect.Vel = -self.Vel:SetMagnitude(5);
					MovableMan:AddParticle(hitEffect);
					
				end
			end
		end
	end	
	
end

function PlasmaDissipate(self, inverted)
	local trace = inverted and Vector(-self.Vel.X, -self.Vel.Y):SetMagnitude(GetPPM()) or Vector(self.Vel.X, self.Vel.Y):SetMagnitude(self.Vel.Magnitude * rte.PxTravelledPerFrame + 1);
	local hit = inverted == false;
	local hitPos = Vector(self.Pos.X, self.Pos.Y);
	local skipPx = math.sqrt(self.Vel.Magnitude) * 0.5;

	local moid = SceneMan:CastObstacleRay(self.Pos, trace, hitPos, Vector(), self.ID, self.Team, rte.airID, skipPx) >= 0 and SceneMan:GetMOIDPixel(hitPos.X, hitPos.Y) or self.HitWhatMOID;
	local mo = MovableMan:GetMOFromID(moid);
	
	if mo and mo.Team ~= self.Team then
		hit = true;
		if IsMOSRotating(mo) and self.maxPenetratedStructuralIntegrity > mo.Material.StructuralIntegrity then
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

function OnCollideWithMO(self, mo, parentMO)
	PlasmaDissipate(self, false);
end

function OnCollideWithTerrain(self, terrainID)
	PlasmaDissipate(self, false);
end