require("/CEDSettings");

function Create(self)
	self.VoTrigoliathPreSound = CreateSoundContainer("Pre CED Vossberg Trigoliath", "CED.rte");
	self.VoTrigoliathMultiFirePreSound = CreateSoundContainer("Multi Fire Pre CED Vossberg Trigoliath", "CED.rte");
	
	self.VoTrigoliathMultiFireAddSound = CreateSoundContainer("Multi Fire Add CED Vossberg Trigoliath", "CED.rte");
	
	self.VoTrigoliathMultiFireReflectionOutdoorsSound = CreateSoundContainer("Multi Fire Reflection Outdoors CED Vossberg Trigoliath", "CED.rte");
	self.VoTrigoliathMultiFireReflectionIndoorsSound = CreateSoundContainer("Multi Fire Reflection Indoors CED Vossberg Trigoliath", "CED.rte");
	
	self.VoTrigoliathSlugsLoaded = false;
	
	self.VoTrigoliathCasingsToRemove = 0;
	
	self.VoTrigoliathMultiFireHoldTime = 200;
	self.VoTrigoliathMultiFireTimer = Timer();
	
	self.VoTrigoliathMultiFireReloadableCooldown = 700;
	
	self.VoTrigoliathSpawnProjectileFunction = function (self, extraParticleForMultifire)
		self.VoTrigoliathCasingsToRemove = self.VoTrigoliathCasingsToRemove + 1;
		
		local topBarrelVector = Vector(0, 0);
		if self.HEATAmmoCounter == 1 then
			topBarrelVector = Vector(0, -2):RadRotate(self.RotAngle);
		end

		if self.VoTrigoliathSlugsLoaded then
			local velocity = 170;
			local spread = 0;
			
			for i = 1, 3 + extraParticleForMultifire do
				local shot = CreateMOPixel("Slug CED Vossberg Trigoliath", "CED.rte");
				shot.Pos = self.MuzzlePos + topBarrelVector;
				shot.Vel = self.Vel + Vector(velocity * self.FlipFactor, spread):RadRotate(self.RotAngle);
				shot.Team = self.Team;
				shot.IgnoresTeamHits = true;
				shot:SetWhichMOToNotHit(ToMovableObject(self), 150);
				MovableMan:AddParticle(shot);
			end
		else
			local velocity = 150;
			local spread = 2;
			
			for i = 1, 8 + extraParticleForMultifire do
				local shot = CreateMOPixel("Pellet CED Vossberg Trigoliath", "CED.rte");
				shot.Pos = self.MuzzlePos + topBarrelVector;
				shot.Vel = self.Vel + Vector(velocity * self.FlipFactor, spread):RadRotate(self.RotAngle);
				shot.Team = self.Team;
				shot.IgnoresTeamHits = true;
				shot:SetWhichMOToNotHit(ToMovableObject(self), 150);
				MovableMan:AddParticle(shot);
			end
		end
	end
end

function OnFire(self)
	local topBarrelVector = Vector(0, 0);
	if self.HEATAmmoCounter == 1 then
		topBarrelVector = Vector(0, -2):RadRotate(self.RotAngle);
	end

	-- Spawn our scripted particles here, since we only want to do it once even on multifire
	if self.VoTrigoliathSlugsLoaded then
		local velocity = 170;
		local spread = 0;
	
		local shot = CreateMOPixel("Slug CED Vossberg Trigoliath Scripted", "CED.rte");
		shot.Pos = self.MuzzlePos + topBarrelVector;
		shot.Vel = self.Vel + Vector(velocity * self.FlipFactor, 0):RadRotate(self.RotAngle);
		shot.Team = self.Team;
		shot.IgnoresTeamHits = true;
		shot:SetWhichMOToNotHit(ToMovableObject(self), 150);
		MovableMan:AddParticle(shot);
	else
		local velocity = 150;
		local spread = 2;
	
		local shot = CreateMOPixel("Pellet CED Vossberg Trigoliath Scripted", "CED.rte");
		shot.Pos = self.MuzzlePos + topBarrelVector;
		shot.Vel = self.Vel + Vector(velocity * self.FlipFactor, 0):RadRotate(self.RotAngle);
		shot.Team = self.Team;
		shot.IgnoresTeamHits = true;
		shot:SetWhichMOToNotHit(ToMovableObject(self), 150);
		MovableMan:AddParticle(shot);
	end

	self.VoTrigoliathSpawnProjectileFunction(self, 0);
	
	if self.VoTrigoliathMultiFire then
		if self.HEATAmmoCounter > 1 then
			self.VoTrigoliathMultiFireAddSound:Play(self.Pos);
			
			CameraMan:AddScreenShake(6 * self.HEATAmmoCounter, self.MuzzlePos);
			
			for i = 1, self.HEATAmmoCounter - 1 do
				self.VoTrigoliathSpawnProjectileFunction(self, 1);
			end

			if self.HEATCheckIfPointIsIndoors(self, self.Pos) then
				self.VoTrigoliathMultiFireReflectionIndoorsSound:Play(self.Pos);
			else
				self.VoTrigoliathMultiFireReflectionOutdoorsSound:Play(self.Pos);
			end
		end
		self.HEATAmmoCounter = 0;
		if self.Magazine then
			self.Magazine.RoundCount = 0;
		end
	end
end

function OnAttach(self, newParent)
	if IsAHuman(newParent:GetRootParent()) then
		self.parent = ToAHuman(newParent:GetRootParent());
	end
end

function OnDetach(self)
	self.parent = nil;
end

function OnReload(self)
	self.VoTrigoliathMultiFire = false;
end

function ThreadedUpdate(self)
	if self.HEATParent and self.HEATParent:IsPlayerControlled() then
		if not self.HEATDelayedFire then
			if UInputMan:KeyPressed(CEDSettings.WeaponAbilitySecondary) then
				self.BaseReloadTime = 9999999;
				self.VoTrigoliathSwitchedAmmo = true;
				if self.VoTrigoliathSlugsLoaded then
					self.VoTrigoliathSlugsLoaded = false;
				else
					self.VoTrigoliathSlugsLoaded = true;
				end
				self:Reload();
				self.VoTrigoliathCasingsToRemove = self.VoTrigoliathCasingsToRemove + self.HEATAmmoCounter;
				self.HEATAmmoCounter = 0;
			end
		end
	end
	
	if self.parent then
		if (self.parent.EquippedItem and self.parent.EquippedItem.UniqueID == self.UniqueID and not self.parent.EquippedBGItem) or (self.parent.EquippedBGItem and self.parent.EquippedBGItem.UniqueID == self.UniqueID and not self.parent.EquippedItem) then
			local fire = self.RoundInMagCount > 0 and self:IsActivated();
			self:Deactivate();
			
			if fire and not self.VoTrigoliathMultiFire then
				self.VoTrigoliathActivated = true;
				if self.VoTrigoliathMultiFireTimer:IsPastSimMS(self.VoTrigoliathMultiFireHoldTime) then
					if self.RoundInMagCount > 1 then
						self.VoTrigoliathMultiFire = true;
						self.Reloadable = false;
						self.VoTrigoliathMultiFireTimer:Reset();
					else
						self:Activate();
						self.HEATDelayedFireTimeMS = 110;
						self.HEATPreSound = self.VoTrigoliathPreSound;
						self.VoTrigoliathActivated = false;
					end
				end
			else
				if self.VoTrigoliathActivated then
					self.VoTrigoliathActivated = false;
					self:Activate();
					if self.VoTrigoliathMultiFire then
						self.HEATRecoilStrength = 50;
						self.HEATRecoilDamping = 0.5;
						self.HEATRecoilMax = 12;
						self.HEATDelayedFireTimeMS = 140;
						self.HEATPreSound = self.VoTrigoliathMultiFirePreSound;
						
						self.HEATParticleUtilityFiringSmokeDataTable.Power = 70;
						self.HEATParticleUtilityFiringSmokeDataTable.Spread = 25;
						self.HEATParticleUtilityFiringSmokeDataTable.SmokeMult = 1.0;
						self.HEATParticleUtilityFiringSmokeDataTable.ExploMult = 1.0;
						self.HEATParticleUtilityFiringSmokeDataTable.WidthSpread = 4;
						self.HEATParticleUtilityFiringSmokeDataTable.VelocityMult = 0.5;
					else
						self.HEATRecoilStrength = 35;
						self.HEATRecoilDamping = 0.6;
						self.HEATRecoilMax = 4;
						self.HEATDelayedFireTimeMS = 110;
						self.HEATPreSound = self.VoTrigoliathPreSound;
						
						self.HEATParticleUtilityFiringSmokeDataTable.Power = 45;
						self.HEATParticleUtilityFiringSmokeDataTable.Spread = 50;
						self.HEATParticleUtilityFiringSmokeDataTable.SmokeMult = 0.7;
						self.HEATParticleUtilityFiringSmokeDataTable.ExploMult = 1.0;
						self.HEATParticleUtilityFiringSmokeDataTable.WidthSpread = 2;
						self.HEATParticleUtilityFiringSmokeDataTable.VelocityMult = 0.3;
					end
				end
				if self.Reloadable then
					self.VoTrigoliathMultiFireTimer:Reset();
				elseif self.VoTrigoliathMultiFireTimer:IsPastSimMS(self.VoTrigoliathMultiFireReloadableCooldown) then
					self.Reloadable = true;
				end
			end
		end
	end
	
end