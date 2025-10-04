require("/CEDSettings");

function Create(self)
	self.KhKhuliganBashSound = CreateSoundContainer("Bash CED Khrabarovsk Khuligan", "CED.rte");
	self.KhKhuliganMovingLoopSound = CreateSoundContainer("Moving Loop CED Khrabarovsk Khuligan", "CED.rte");
	self.KhKhuliganWalkSound = CreateSoundContainer("Walk CED Khrabarovsk Khuligan", "CED.rte");
	self.KhKhuliganSprintSound = CreateSoundContainer("Sprint CED Khrabarovsk Khuligan", "CED.rte");
	self.KhKhuliganEquipSound = CreateSoundContainer("Equip CED Khrabarovsk Khuligan", "CED.rte");
	self.KhKhuliganDropSound = CreateSoundContainer("Drop CED Khrabarovsk Khuligan", "CED.rte");
	
	self.KhKhuliganAlternateStrideNum = 0;
	
	self.KhKhuliganIsTackling = false;
	self.KhKhuliganTackleMinVel = 6;
	
	self.KhKhuliganTackleGraceTimer = Timer();
	self.KhKhuliganTackleGraceTime = 400;
	
	-- Table to keep last hit MOs to prevent repeatedly hitting them.
	self.KhKhuliganHitMOTable = {};
	self.KhKhuliganHitMOTableResetTimer = Timer();
	
end
					
function OnAttach(self, newParent)
	self.KhKhuliganAlternateStrideSound = 0;
	self.KhKhuliganToPlayTerrainImpact = false;
	
	self.KhKhuliganEquipSound:Play(self.Pos);
	
	self.KhKhuliganMovingLoopSound:Play(self.Pos);
	
	if IsAHuman(newParent:GetRootParent()) then
		self.parent = ToAHuman(newParent:GetRootParent());
		self.parentController = self.parent:GetController();
	end
end

function OnDetach(self)
	self.KhKhuliganEquipSound:Stop(-1);
	
	self.KhKhuliganToPlayTerrainImpact = true;
	
	self.KhKhuliganMovingLoopSound:Stop(-1);
	
	self.parent = nil;
	self.parentController = nil;
end

function OnCollideWithTerrain(self)
	if self.KhKhuliganToPlayTerrainImpact then
		self.KhKhuliganToPlayTerrainImpact = false;
		self.KhKhuliganDropSound:Play(self.Pos);
	end
end

function ThreadedUpdate(self)
	self.KhKhuliganBashSound.Pos = self.Pos;
	self.KhKhuliganMovingLoopSound.Pos = self.Pos;
	self.KhKhuliganWalkSound.Pos = self.Pos;
	self.KhKhuliganSprintSound.Pos = self.Pos;
	self.KhKhuliganEquipSound.Pos = self.Pos;
	self.KhKhuliganDropSound.Pos = self.Pos;
	
	self.KhKhuliganMovingVolumeTarget = math.max(0, math.min(1, -0.25 + (self.Vel.Magnitude / (self.KhKhuliganTackleMinVel*2))));
	
	if self.KhKhuliganMovingLoopSound.Volume < self.KhKhuliganMovingVolumeTarget then
		self.KhKhuliganMovingLoopSound.Volume = math.min(1, self.KhKhuliganMovingLoopSound.Volume + TimerMan.DeltaTimeSecs);
	else
		self.KhKhuliganMovingLoopSound.Volume = math.max(0, self.KhKhuliganMovingLoopSound.Volume - (TimerMan.DeltaTimeSecs * 20));
	end
		

	if self.parent then
		local isMovingFast = self.parent.Vel.Magnitude > self.KhKhuliganTackleMinVel;
		local isSprinting = self.parent.MovementState == Actor.RUN;
		
		if self.parent.StrideFrame then
			local sound = isSprinting and self.KhKhuliganSprintSound or self.KhKhuliganWalkSound;
		
			if self.KhKhuliganAlternateStrideNum == 0 or isSprinting then
				sound:Play(self.Pos);
				self.KhKhuliganAlternateStrideNum = 1;
			else
				self.KhKhuliganAlternateStrideNum = 0;
			end
		end
		
		if self.KhKhuliganHitMOTableResetTimer:IsPastSimMS(1000) then
			self.KhKhuliganHitMOTable = {};
			self.KhKhuliganHitMOTableResetTimer:Reset();
		end		
		
		if isMovingFast then
			if not self.KhKhuliganIsTackling then
				self.KhKhuliganIsTackling = true;
			else
				self.KhKhuliganTackleGraceTimer:Reset();
			
				local rayVec = Vector(10 * self.FlipFactor, 0);
				local rayOrigin = self.Pos;		
					
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
						if self.KhKhuliganHitMOTable then
							for index, root in pairs(self.KhKhuliganHitMOTable) do
								if root == MO:GetRootParent().UniqueID or index == MO.UniqueID then
									hitAllowed = false;
								end
							end
						end
						if hitAllowed == true then
							self.KhKhuliganLastHitMO = MO;
							self.KhKhuliganLastRayHitPos = rayHitPos;
							self:RequestSyncedUpdate();		
						end
					end
				end
			end
		elseif self.KhKhuliganTackleGraceTimer:IsPastSimMS(self.KhKhuliganTackleGraceTime) then
			self.KhKhuliganIsTackling = false;
		end
	end
end

function SyncedUpdate(self)
	if not self.parent then
		return
	end
	
	local MO = ToMOSRotating(self.KhKhuliganLastHitMO)
	local rootMOHit = MO:GetRootParent();
	
	self.KhKhuliganHitMOTable[MO.UniqueID] = MO:GetRootParent().UniqueID;
	self.KhKhuliganHitMOTableResetTimer:Reset();
	
	local woundName = MO:GetEntryWoundPresetName()
	local woundNameExit = MO:GetExitWoundPresetName()
	local woundOffset = (self.KhKhuliganLastRayHitPos - MO.Pos):RadRotate(MO.RotAngle * -1.0)
	local material = MO.Material.PresetName
	-- For every 40 mass we are above the hit object, add one damage
	local damage = 1 + math.min(4, (math.max(0, (self.parent.Mass-rootMOHit.Mass) / 40)));							
	local woundsToAdd = damage;
	
	-- Hurt the actor, add extra damage
	local rootMOHit = MO:GetRootParent();
	if (rootMOHit and IsActor(rootMOHit)) then
		rootMOHit = ToActor(rootMOHit)
		
		self.KhKhuliganBashSound:Play(self.Pos);
	
		rootMOHit = ToActor(rootMOHit)
		
		if rootMOHit.BodyHitSound then
			rootMOHit.BodyHitSound:Play(rootMOHit.Pos)
		end
		
		if rootMOHit.Mass < self.parent.Mass then
			rootMOHit.Status = 1;
		end
		rootMOHit.Vel = rootMOHit.Vel + (self.Vel*0.6)
		
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

function Destroy(self)
	self.KhKhuliganMovingLoopSound:Stop(-1);
end