function Create(self)
	self.BehemothSprintWhooshSound = CreateSoundContainer("Sprint Whoosh CED Behemoth", "CED.rte");
	self.BehemothSprintWhooshSound.Volume = 0.5;
	self.BehemothIsTackling = false;
	self.BehemothOriginalMass = self.IndividualMass;
	
	self.BehemothTackleGraceTimer = Timer();
	self.BehemothTackleGraceTime = 400;
	
	-- Table to keep last hit MOs to prevent repeatedly hitting them.
	self.BehemothHitMOTable = {};
	self.BehemothHitMOTableResetTimer = Timer();
end

function OnStride(self)
	if self.BehemothIsTackling then
		if self.BGFoot and self.FGFoot then
			-- Note this is reversed, because CompliSound adds this itself and we go after it
			startPos = self.CompliSoundActorFootIterator == 0 and self.FGFoot.Pos or self.BGFoot.Pos
		elseif self.BGFoot then
			startPos = self.BGFoot.Pos
		elseif self.FGFoot then
			startPos = self.FGFoot.Pos
		end
		local smoke = CreateMOSRotating("CompliSound Ground Smoke Particle Small", "0CompliSoundEmporium.rte");
		smoke.Pos = startPos;
		smoke.Vel = Vector(0, 9);
		MovableMan:AddParticle(smoke);
	end
end

function ThreadedUpdate(self)
	self.BehemothSprintWhooshSound.Pos = self.Pos;
	
	if self.BehemothHitMOTableResetTimer:IsPastSimMS(1000) then
		self.BehemothHitMOTable = {};
		self.BehemothHitMOTableResetTimer:Reset();
	end
			
	if self.CompliSoundActorIsSprinting and self.CEDAHumanCurrentMoveMultiplier > self.CEDAHumanSprintMultiplier - 0.1 and self.Vel.Magnitude > 1 then
		if not self.BehemothIsTackling then
			self.BehemothIsTackling = true;
			self.BehemothSprintWhooshSound:Play(self.Pos);
		else
			self.BehemothTackleGraceTimer:Reset();
		
			local rayVec = Vector(20 * self.FlipFactor, 0);
			local rayOrigin = self.Pos;		
			if self.EquippedItem then
				rayVec = Vector(4 * self.FlipFactor, 0):RadRotate(self.EquippedItem.RotAngle);
				rayOrigin = self.EquippedItem.MuzzlePos and self.EquippedItem.MuzzlePos or self.EquippedItem.Pos;
			elseif self.EquippedBGItem then
				rayVec = Vector(4 * self.FlipFactor, 0):RadRotate(self.EquippedBGItem.RotAngle);
				rayOrigin = self.EquippedBGItem.MuzzlePos and self.EquippedBGItem.MuzzlePos or self.EquippedBGItem.Pos;
			end
			
			-- Reset back to our pos if the muzzle is too far up or down
			if math.abs(rayOrigin.Y - self.Pos.Y) > 10 then
				rayOrigin = self.Pos;
				rayVec = Vector(20 * self.FlipFactor, 0);
			end
				
			local moCheck = SceneMan:CastMORay(rayOrigin, rayVec, self.ID, self.Team, 0, false, 2);		
			
			if moCheck and moCheck ~= rte.NoMOID then
				local rayHitPos = SceneMan:GetLastRayHitPos()
				local rayHitPos = Vector(rayHitPos.X, rayHitPos.Y);
				local MO = MovableMan:GetMOFromID(moCheck);		
				local dist = SceneMan:ShortestDistance(self.Pos, rayHitPos, SceneMan.SceneWrapsX);
				
				local eligible = true;		
				
				if (self.Vel.X < 0 and dist.X > 0) or (self.Vel.X > 0 and dist.X < 0) then -- check that we're facing the right way
					eligible = false;
				end

				if eligible and IsMOSRotating(MO) then
					local hitAllowed = true;
					-- Check the table to not hit the same thing multiple times
					if self.BehemothHitMOTable then
						for index, root in pairs(self.BehemothHitMOTable) do
							if root == MO:GetRootParent().UniqueID or index == MO.UniqueID then
								hitAllowed = false;
							end
						end
					end
					if hitAllowed == true then
						self.BehemothLastHitMO = MO;
						self.BehemothLastRayHitPos = rayHitPos;
						self:RequestSyncedUpdate();		
					end
				end
			end
		end
	elseif self.BehemothTackleGraceTimer:IsPastSimMS(self.BehemothTackleGraceTime) then
		self.BehemothIsTackling = false;
	end
end

function SyncedUpdate(self)
	local MO = ToMOSRotating(self.BehemothLastHitMO)
	local rootMOHit = MO:GetRootParent();
	
	self.BehemothHitMOTable[MO.UniqueID] = MO:GetRootParent().UniqueID;
	self.BehemothHitMOTableResetTimer:Reset();
	
	local woundName = MO:GetEntryWoundPresetName()
	local woundNameExit = MO:GetExitWoundPresetName()
	local woundOffset = (self.BehemothLastRayHitPos - MO.Pos):RadRotate(MO.RotAngle * -1.0)
	local material = MO.Material.PresetName
	-- For every 40 mass we are above the hit object, add one damage
	local damage = 1 + math.min(4, (math.max(0, (self.Mass-rootMOHit.Mass) / 40)));							
	local woundsToAdd = damage;
	
	-- Hurt the actor, add extra damage
	local rootMOHit = MO:GetRootParent();
	if (rootMOHit and IsActor(rootMOHit)) then
		rootMOHit = ToActor(rootMOHit)
		
		if self.CEDAHumanFoleySounds.ImpactHeavy then
			self.CEDAHumanFoleySounds.ImpactHeavy:Play(self.Pos);
		end				
	
		rootMOHit = ToActor(rootMOHit)
		
		if rootMOHit.BodyHitSound then
			rootMOHit.BodyHitSound:Play(rootMOHit.Pos)
		end
		
		if rootMOHit.Mass < self.Mass then
			rootMOHit.Status = 1;
		end
		-- For every 40 mass above the hit actor, multiply throwing distance to a max of 3 times
		rootMOHit.Vel = rootMOHit.Vel + (self.Vel) * math.min(math.max(1, (self.Mass-rootMOHit.Mass) / 40), 3);
		
		if IsAttachable(MO) and ToAttachable(MO):IsAttached() then
			-- Sometimes knock things out of hands
			if MO:IsDevice() and math.random(1,3) >= 2 then
				ToAttachable(MO):RemoveFromParent(true, true);
			end													
		end
		if woundName and woundName ~= "" then
			for i = 1, woundsToAdd do
				MO:AddWound(CreateAEmitter(woundName), woundOffset, true)
			end
		end

	elseif woundName and woundName ~= "" then
		-- Generic wound adding for non-actors
		for i = 1, woundsToAdd do
			MO:AddWound(CreateAEmitter(woundName), woundOffset, true)
		end
	end
end