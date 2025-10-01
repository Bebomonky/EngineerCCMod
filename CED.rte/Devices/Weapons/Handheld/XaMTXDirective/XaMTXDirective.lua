require("/CEDSettings");

function OnMessage(self, message, object)

	-- This is a full update, even if it's redundant. It only runs whenever any attachment is changed, so it should be fine.

	if message == "TriumvirateAtt_Update" then
		
		if self:GetNumberValue("TriumvirateAtt_QuietLockon_Equipped") == 1 then
			self.smartGunLockSound = self.XaMTXDirectiveQuietLockSound;
			self.XaMTXDirectiveLoudLockOn = false;
			
		elseif self:GetNumberValue("TriumvirateAtt_LoudLockon_Equipped") == 1 then
			self.smartGunLockSound = self.XaMTXDirectiveLoudLockSound;
			self.XaMTXDirectiveLoudLockOn = true;
		end		
	end
end

function Create(self)	
	self.Activity = ActivityMan:GetActivity();
	
	self.XaMTXDirectiveFireVelocity = 80;
	self.XaMTXDirectiveFireSpread = 10 / 2;	
	
	self.XaMTXDirectiveBlipSound = CreateSoundContainer("Blip CED Xarix MTX Directive", "CED.rte");
	self.XaMTXDirectiveQuietLockSound = CreateSoundContainer("Quiet Lock CED Xarix MTX Directive", "CED.rte");
	self.XaMTXDirectiveLoudLockSound = CreateSoundContainer("Loud Lock CED Xarix MTX Directive", "CED.rte");
	self.XaMTXDirectiveRelockSound = CreateSoundContainer("Relock CED Xarix MTX Directive", "CED.rte");
	self.XaMTXDirectiveUnlockSound = CreateSoundContainer("Unlock CED Xarix MTX Directive", "CED.rte");
	
	self.XaMTXDirectiveLoudLockOn = false;
	self.XaMTXDirectiveLoudLockOnSound = CreateSoundContainer("Loud Lock On CED Xarix MTX Directive", "CED.rte");
	self.XaMTXDirectiveLoudLockOffSound = CreateSoundContainer("Loud Lock Off CED Xarix MTX Directive", "CED.rte");
	
	-- Frostbite Smartgun System --
	
	self.smartGunBlipSound = self.XaMTXDirectiveBlipSound;
	self.smartGunLockSound = self.XaMTXDirectiveQuietLockSound;
	self.smartGunRelockSound = self.XaMTXDirectiveRelockSound;
	self.smartGunUnlockSound = self.XaMTXDirectiveUnlockSound;
	
	self.smartGunBlipLockOnThreshold = 3;
	self.smartGunPotentialTargetTable = {};
	self.smartGunIgnoreThisScanTable = {};
	
	self.smartGunTargetTable = {};
	self.smartGunMaxSimultaneousTargets = 1;
	self.smartGunCurrentTargetIndex = 0;
	
	self.smartGunScanningTargetCounter = 0;
	self.smartGunMaxSimultaneousScans = 3;
	
	self.smartGunFailedScans = 0;
	self.smartGunScanLossThreshold = 6;
	
	self.smartGunRange = 350;
	
	self.smartGunScanCone = 20 -- in deg, keep at increments of 2.5
	self.smartGunRayAngle = math.rad(self.smartGunScanCone/2)
	self.smartGunOverloadConeNarrow = 0;
	
	self.smartGunSearchTimer = Timer();
	self.smartGunSearchScanTime = 100; -- one scan is a full series of rays in the scancone, and counts as one blip of scanning, so this times blip requirement is total ms time to lock on
	self.smartGunSearchDelay = self.smartGunSearchScanTime/(self.smartGunScanCone/2.5); -- time between every single ray
	
	-- END FROSTBITE SMARTGUN SYSTEM	
	
end

function OnFire(self)
	local spread = math.random(-self.XaMTXDirectiveFireSpread, self.XaMTXDirectiveFireSpread);

	local shot = CreateMOSRotating("Smart Plasma Shot CED Xarix MTX Directive", "CED.rte");
	shot.Pos = self.MuzzlePos + Vector(0.1*self.FlipFactor, 0):RadRotate(self.RotAngle);
	shot.Vel = self.Vel + Vector(self.XaMTXDirectiveFireVelocity * self.FlipFactor, spread):RadRotate(self.RotAngle);
	shot.RotAngle = self.RotAngle;
	shot.Team = self.Team;
	shot.IgnoresTeamHits = true;
	shot:SetWhichMOToNotHit(ToMovableObject(self), 150);
	if #self.smartGunTargetTable > 0 then
		shot:SetNumberValue("TargetID", self.smartGunTargetTable[self.smartGunCurrentTargetIndex + 1].UniqueID);
		self.smartGunCurrentTargetIndex = (self.smartGunCurrentTargetIndex + 1) % #self.smartGunTargetTable;
	end
	MovableMan:AddParticle(shot);

	-- Use our HEATStats to spawn a casing every time we fire.
	local casing
	casing = self.HEATCasing:Clone();
	casing.Pos = self.EjectionPos;
	casing.Vel = self.Vel + Vector(self.HEATCasingVelocity.X * self.FlipFactor, self.HEATCasingVelocity.Y):RadRotate(self.RotAngle);
	casing.RotAngle = self.RotAngle;
	casing.HFlipped = self.HFlipped;
	MovableMan:AddParticle(casing);
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
	self.XaMTXDirectiveBlipSound.Pos = self.Pos;
	self.XaMTXDirectiveQuietLockSound.Pos = self.Pos;
	self.XaMTXDirectiveLoudLockSound.Pos = self.Pos;
	self.XaMTXDirectiveRelockSound.Pos = self.Pos;
	self.XaMTXDirectiveUnlockSound.Pos = self.Pos;
	self.XaMTXDirectiveLoudLockOnSound.Pos = self.Pos;
	self.XaMTXDirectiveLoudLockOffSound.Pos = self.Pos;
	
	if self.parent then
		if self.parentController:IsState(Controller.WEAPON_PRIMARY_HOTKEYSTART) then
			if #self.smartGunTargetTable > 0 or #self.smartGunPotentialTargetTable > 0 then
				self.smartGunTargetTable = {};
				self.smartGunPotentialTargetTable = {};
				self.XaMTXDirectiveUnlockSound:Play(self.Pos);
			end
		end	

		-- FROSTBITE SMARTGUN SYSTEM --
		
		if #self.smartGunTargetTable > 0 then
			-- validate targets
			for i = 1, #self.smartGunTargetTable do		
				if not MovableMan:ValidMO(self.smartGunTargetTable[i]) then
					table.remove(self.smartGunTargetTable, i);
				end
			
				-- check that targets are still in view
				if self.smartGunTargetTable[i] and SceneMan:CastStrengthSumRay(self.MuzzlePos, self.smartGunTargetTable[i].Pos, 3, 0) < 15 then			
					-- still in view
				else			
					self.smartGunUnlockSound:Play(self.Pos);
					table.remove(self.smartGunTargetTable, i);
					self.smartGunCurrentTargetIndex = 0;
				end
				
				if self.smartGunTargetTable[i] and self.smartGunTargetTable[i]:IsDead() then
					self.smartGunUnlockSound:Play(self.Pos);
					table.remove(self.smartGunTargetTable, i);
					self.smartGunCurrentTargetIndex = 0;
				end								
			end
			
			for i = 1, #self.smartGunTargetTable do
				PrimitiveMan:DrawCirclePrimitive(self.smartGunTargetTable[i].Pos + Vector(0, -10):RadRotate(self.smartGunTargetTable[i].RotAngle), 10, 122)
			end
		end
		
		if #self.smartGunPotentialTargetTable > 0 then
			-- validate potential targets
			for k, v in pairs(self.smartGunPotentialTargetTable) do
				if k > 0 then -- this should never be nil, but... sometimes it is? and checking it that way doesn't work?
					for i = 1, v do
						local mo = MovableMan:FindObjectByUniqueID(k)
						if mo and MovableMan:ValidMO(mo) then
							local color = 5
							local spacing = 4
							local offset = Vector(0 - spacing * 0.5 + spacing * (i) - spacing * v / 2, 35)
							local position = mo.AboveHUDPos + offset
							PrimitiveMan:DrawCirclePrimitive(position + Vector(0,-2), 1, color);
						else -- this is a faulty entry, nix it
							k = nil;
							v = nil;
						end
					end
				end
			end
		end
		
		if #self.smartGunTargetTable == self.smartGunMaxSimultaneousTargets then -- targets already acquired
			if self.smartGunSearchTimer:IsPastSimMS(self.smartGunSearchDelay * 10) and not self:IsReloading() then
				-- check if the player is aiming directly at a new target
				local smartGunRay = Vector(self.smartGunRange*self.FlipFactor, 0):RadRotate(self.RotAngle)
				local moCheck = SceneMan:CastMORay(self.MuzzlePos, smartGunRay, self.ID, self.Team, 0, false, 3); -- Raycast		
				--PrimitiveMan:DrawLinePrimitive(self.MuzzlePos, self.MuzzlePos + smartGunRay,  5);
				
				if moCheck ~= rte.NoMOID then
					local rootMO = MovableMan:GetMOFromID((MovableMan:GetMOFromID(moCheck).RootID))					
					local alreadyTargetted = false;
					
					for i = 1, #self.smartGunTargetTable do
						if rootMO.UniqueID == self.smartGunTargetTable[i].UniqueID then
							alreadyTargetted = true;
						end
					end
					
					if not alreadyTargetted and (IsAHuman(rootMO) or IsACrab(rootMO)) then
					
						self.smartGunBlipSound:Play(self.Pos);
					
						if self.smartGunPotentialTargetTable[rootMO.UniqueID] then
							self.smartGunPotentialTargetTable[rootMO.UniqueID] = self.smartGunPotentialTargetTable[rootMO.UniqueID] + 1
						else
							self.smartGunScanningTargetCounter = self.smartGunScanningTargetCounter + 1
							if self.smartGunScanningTargetCounter > self.smartGunMaxSimultaneousScans then
								-- delete, unfortunately, a random target. ordering them properly would Hurt
								for k, v in pairs(self.smartGunPotentialTargetTable) do
									self.smartGunPotentialTargetTable[k] = nil;
									self.smartGunOverloadConeNarrow = 1
									break;
								end
							end
							self.smartGunPotentialTargetTable[rootMO.UniqueID] = 1;
						end
						
						if self.smartGunPotentialTargetTable[rootMO.UniqueID] >= self.smartGunBlipLockOnThreshold then					
							self.smartGunPotentialTargetTable = {};					
							self.smartGunRelockSound:Play(self.Pos);			
							
							-- push out first target						
							table.remove(self.smartGunTargetTable, 1);
							
							if IsAHuman(rootMO) then
								table.insert(self.smartGunTargetTable, ToAHuman(rootMO));
							elseif IsACrab(rootMO) then
								table.insert(self.smartGunTargetTable, ToACrab(rootMO));
							end
						end
					end
				else
					self.smartGunPotentialTargetTable = {};
				end				
				self.smartGunSearchTimer:Reset();
			end
				
				
		elseif self.smartGunSearchTimer:IsPastSimMS(self.smartGunSearchDelay) and not self:IsReloading() then -- run scans
			local scanCone = math.max(2.5, self.smartGunScanCone - (self.smartGunOverloadConeNarrow * 2.5));
			if self.smartGunRayAngle <= math.rad(-scanCone/2) then	
				self.smartGunIgnoreThisScanTable = {};		
				self.smartGunRayAngle = math.rad(scanCone/2);
				
				if not self.smartGunSuccessfulScan then
					self.smartGunFailedScans = self.smartGunFailedScans + 1
					if self.smartGunFailedScans >= self.smartGunScanLossThreshold then
						self.smartGunOverloadConeNarrow = 0;
						self.smartGunPotentialTargetTable = {};
						self.smartGunScanningTargetCounter = 0;
					end
				else
					self.smartGunFailedScans = 0
					self.smartGunSuccessfulScan = false;
				end		
			end			
			
			self.smartGunRayAngle = (self.smartGunRayAngle - math.rad(math.min(scanCone/2, 2.5)))
			local smartGunRay = Vector(self.smartGunRange*self.FlipFactor, 0):RadRotate(self.RotAngle + self.smartGunRayAngle)
			local moCheck = SceneMan:CastMORay(self.MuzzlePos, smartGunRay, self.ID, self.Team, 0, false, 3); -- Raycast		
			--PrimitiveMan:DrawLinePrimitive(self.MuzzlePos, self.MuzzlePos + smartGunRay,  5);
			
			if moCheck ~= rte.NoMOID then
				self.smartGunSuccessfulScan = true;	
				local rootMO = MovableMan:GetMOFromID((MovableMan:GetMOFromID(moCheck).RootID))			
				local alreadyTargetted = false;
				
				for i = 1, #self.smartGunTargetTable do
					if rootMO.UniqueID == self.smartGunTargetTable[i].UniqueID then
						alreadyTargetted = true;
					end
				end
				
				if (not self.smartGunIgnoreThisScanTable[rootMO.UniqueID]) and (not alreadyTargetted) and (IsAHuman(rootMO) or IsACrab(rootMO)) then			
					self.smartGunIgnoreThisScanTable[rootMO.UniqueID] = true;				
					if self.smartGunPotentialTargetTable[rootMO.UniqueID] then
						self.smartGunPotentialTargetTable[rootMO.UniqueID] = self.smartGunPotentialTargetTable[rootMO.UniqueID] + 1
					else
						self.smartGunScanningTargetCounter = self.smartGunScanningTargetCounter + 1
						if self.smartGunScanningTargetCounter > self.smartGunMaxSimultaneousScans then
							-- delete, unfortunately, a random target. ordering them properly would Hurt
							for k, v in pairs(self.smartGunPotentialTargetTable) do
								self.smartGunPotentialTargetTable[k] = nil;
								self.smartGunOverloadConeNarrow = self.smartGunOverloadConeNarrow + 1
								break;
							end
						end
						self.smartGunPotentialTargetTable[rootMO.UniqueID] = 1;
					end
					
					self.smartGunBlipSound.Pitch = math.min(6, self.smartGunPotentialTargetTable[rootMO.UniqueID]);
					self.smartGunBlipSound:Play(self.Pos);
					
					if self.smartGunPotentialTargetTable[rootMO.UniqueID] >= self.smartGunBlipLockOnThreshold then								
						self.smartGunPotentialTargetTable[rootMO.UniqueID] = nil; -- no longer has potential, because it just became an actual target!					
						self.smartGunLockSound:Play(self.Pos);				
						
						if IsAHuman(rootMO) then
							table.insert(self.smartGunTargetTable, ToAHuman(rootMO));
						elseif IsACrab(rootMO) then
							table.insert(self.smartGunTargetTable, ToACrab(rootMO));
						end
					end
				end
			end	
			self.smartGunSearchTimer:Reset();
		end
		
		-- END FROSTBITE SMARTGUN SYSTEM -- 		
	end
end