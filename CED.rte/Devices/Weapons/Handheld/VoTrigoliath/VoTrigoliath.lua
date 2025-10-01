require("/CEDSettings");

function OnMessage(self, message, object)

	-- This is a full update, even if it's redundant. It only runs whenever any attachment is changed, so it should be fine.

	if message == "TriumvirateAtt_Update" then
		
		if self:GetNumberValue("TriumvirateAtt_Buckshot_Equipped") == 1 then
			-- Prevent loading on spawn
			if not (self.VoTrigoliathSlugsLoaded == false and self.HEATAmmoCounter == 3) then
				self.VoTrigoliathMessageShownForOneReload = false;
				
				self.BaseReloadTime = 9999999;
				self.VoTrigoliathSwitchedAmmo = true;

				self.VoTrigoliathSlugsLoaded = false;

				self:Reload();
				self.VoTrigoliathCasingsToRemove = self.VoTrigoliathCasingsToRemove + self.HEATAmmoCounter;
				self.HEATAmmoCounter = 0;		
			end
			
		elseif self:GetNumberValue("TriumvirateAtt_Slugs_Equipped") == 1 then
			self.VoTrigoliathMessageShownForOneReload = false;
			
			self.BaseReloadTime = 9999999;
			self.VoTrigoliathSwitchedAmmo = true;

			self.VoTrigoliathSlugsLoaded = true;
			
			self:Reload();
			self.VoTrigoliathCasingsToRemove = self.VoTrigoliathCasingsToRemove + self.HEATAmmoCounter;
			self.HEATAmmoCounter = 0;
		end		
		
	end
end

function Create(self)
	self.VoTrigoliathFireVelocity = 130;
	self.VoTrigoliathFireSlugVelocity = 150;
	self.VoTrigoliathFireSpread = 10 / 2;
	self.VoTrigoliathFireSlugSpread = 0.5 / 2;

	self.VoTrigoliathBassSound = CreateSoundContainer("Bass CED Vossberg Trigoliath", "CED.rte");
	self.VoTrigoliathPreSound = CreateSoundContainer("Pre CED Vossberg Trigoliath", "CED.rte");
	self.VoTrigoliathMultiFirePreSound = CreateSoundContainer("Multi Fire Pre CED Vossberg Trigoliath", "CED.rte");
	
	self.VoTrigoliathMultiFireAddSound = CreateSoundContainer("Multi Fire Add CED Vossberg Trigoliath", "CED.rte");
	
	self.VoTrigoliathMultiFireReflectionOutdoorsSound = CreateSoundContainer("Multi Fire Reflection Outdoors CED Vossberg Trigoliath", "CED.rte");
	self.VoTrigoliathMultiFireReflectionIndoorsSound = CreateSoundContainer("Multi Fire Reflection Indoors CED Vossberg Trigoliath", "CED.rte");
	
	self.VoTrigoliathSlugsLoaded = false;
	self.VoTrigoliathMessageShownForOneReload = true;
	
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
			for i = 1, 3 + extraParticleForMultifire do
				local shot = CreateMOPixel("Slug CED Vossberg Trigoliath", "CED.rte");
				shot.Pos = self.MuzzlePos + topBarrelVector;
				shot.Vel = self.Vel + Vector(self.VoTrigoliathActingVelocity * self.FlipFactor, self.VoTrigoliathActingSpread):RadRotate(self.RotAngle);
				shot.Team = self.Team;
				shot.IgnoresTeamHits = true;
				shot:SetWhichMOToNotHit(ToMovableObject(self), 150);
				MovableMan:AddParticle(shot);
			end
		else		
			for i = 1, 8 + extraParticleForMultifire do
				self.VoTrigoliathActingSpread = math.random(-self.VoTrigoliathFireSpread, self.VoTrigoliathFireSpread);
			
				local shot = CreateMOPixel("Pellet CED Vossberg Trigoliath", "CED.rte");
				shot.Pos = self.MuzzlePos + topBarrelVector;
				shot.Vel = self.Vel + Vector(self.VoTrigoliathActingVelocity * self.FlipFactor, self.VoTrigoliathActingSpread):RadRotate(self.RotAngle);
				shot.Team = self.Team;
				shot.IgnoresTeamHits = true;
				shot:SetWhichMOToNotHit(ToMovableObject(self), 150);
				MovableMan:AddParticle(shot);
			end
		end
	end
end

function OnFire(self)
	self.VoTrigoliathBassSound:Play(self.Pos);

	local topBarrelVector = Vector(0, 0);
	if self.HEATAmmoCounter == 1 then
		topBarrelVector = Vector(0, -2):RadRotate(self.RotAngle);
	end

	-- Spawn our scripted particles here, since we only want to do it once even on multifire
	if self.VoTrigoliathSlugsLoaded then
		self.VoTrigoliathActingVelocity = self.VoTrigoliathFireSlugVelocity;
		self.VoTrigoliathActingSpread = math.random(-self.VoTrigoliathFireSpread, self.VoTrigoliathFireSlugSpread);
	
		local shot = CreateMOPixel("Slug CED Vossberg Trigoliath Scripted", "CED.rte");
		shot.Pos = self.MuzzlePos + topBarrelVector;
		shot.Vel = self.Vel + Vector(self.VoTrigoliathActingVelocity * self.FlipFactor, self.VoTrigoliathActingSpread):RadRotate(self.RotAngle);
		shot.Team = self.Team;
		shot.IgnoresTeamHits = true;
		shot:SetWhichMOToNotHit(ToMovableObject(self), 150);
		MovableMan:AddParticle(shot);
	else
		self.VoTrigoliathActingVelocity = self.VoTrigoliathFireVelocity;
		self.VoTrigoliathActingSpread = math.random(-self.VoTrigoliathFireSpread, self.VoTrigoliathFireSpread);
	
		local shot = CreateMOPixel("Pellet CED Vossberg Trigoliath Scripted", "CED.rte");
		shot.Pos = self.MuzzlePos + topBarrelVector;
		shot.Vel = self.Vel + Vector(self.VoTrigoliathActingVelocity * self.FlipFactor, self.VoTrigoliathActingSpread):RadRotate(self.RotAngle);
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
		self.HEATAmmoCounter = 1; -- HEATSystem will decrement to 0 later
		if self.Magazine then
			self.Magazine.RoundCount = 0;
		end
	end
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

function OnReload(self)
	self.VoTrigoliathMultiFire = false;
end

function ThreadedUpdate(self)
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
						self.HEATRecoilStrength = 60;
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
						self.HEATRecoilStrength = 50;
						self.HEATRecoilDamping = 0.6;
						self.HEATRecoilMax = 12;
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
		
		if self.VoTrigoliathMessageShownForOneReload == false and self:IsReloading() then
			local text = "Loading buckshot...";
			if self.VoTrigoliathSlugsLoaded then
				text = "Loading slug...";
			end
			local ctrl = self.parent:GetController();
			local screen = ActivityMan:GetActivity():ScreenOfPlayer(ctrl.Player);
			PrimitiveMan:DrawTextPrimitive(screen, self.Pos + Vector(10, -15), text, true, 1);
		elseif self:DoneReloading() then
			self.VoTrigoliathMessageShownForOneReload = true;
		end		
	end
end