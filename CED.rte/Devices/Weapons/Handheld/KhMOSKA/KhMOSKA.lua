-- While this interfaces with the HEATSystem, it's probably neater to have this stuff here that in HEATStats.
-- This was a painful gun to make to account for every singular edge case.

require("/CEDSettings");

function OnMessage(self, message, object)

	-- This is a full update, even if it's redundant. It only runs whenever any attachment is changed, so it should be fine.

	if message == "TriumvirateAtt_Update" then
	
		-- Sights
		
		local sightAttachable;
		for att in self.Attachables do
			if att.PresetName == "Sights Attachment CED Khrabarovsk MOSKA" then
				sightAttachable = att;
			end
		end
		
		if self:GetNumberValue("TriumvirateAtt_IronSights_Equipped") == 1 then
			if sightAttachable then
				sightAttachable.Frame = 0;
			end
			self.HEATOriginalSharpLength = 180;
		elseif self:GetNumberValue("TriumvirateAtt_Scope_Equipped") == 1 then
			if sightAttachable then
				sightAttachable.Frame = 1;
			end
			self.HEATOriginalSharpLength = 320;
		end
	
		-- Ammo
		if self:GetNumberValue("TriumvirateAtt_NormalRounds_Equipped") == 1 then
			if self.KhMOSKAToLoadRBullet then
				self.KhMOSKAToLoadRBullet = false;
				self.HEATDelayedFireTimeMS = 50;
				
				self.HEATRecoilStrength = 39
				self.HEATRecoilPowStrength = 0.2
				self.HEATRecoilRandomUpper = 1.1
				self.HEATRecoilDamping = 0.7
				self.HEATRecoilMax = 4
				self.HEATParticleUtilityFiringSmokeDataTable = {};
				self.HEATParticleUtilityFiringSmokeDataTable.Power = 35;
				self.HEATParticleUtilityFiringSmokeDataTable.Spread = 35;
				self.HEATParticleUtilityFiringSmokeDataTable.SmokeMult = 0.6;
				self.HEATParticleUtilityFiringSmokeDataTable.ExploMult = 1.3;
				self.HEATParticleUtilityFiringSmokeDataTable.WidthSpread = 2;
				self.HEATParticleUtilityFiringSmokeDataTable.VelocityMult = 0.35;
				self.HEATParticleUtilityFiringSmokeDataTable.LingerMult = 2.4;
				self.HEATParticleUtilityFiringSmokeDataTable.AirResistanceMult = 1.8;
				self.HEATParticleUtilityFiringSmokeDataTable.GravMult = 1;	
				-- Note that AmmoCounter 1 and an unfired R Bullet means we're about to eject the one round and get to 0
				if not self:IsReloading() and self.HEATAmmoCounter == 0 or (self.HEATAmmoCounter == 1 and not self.KhMOSKARBulletFired) then
					self:Reload();
				else
					self.HEATNonReloadStaging = true;
					if self.Magazine then
						if self.KhMOSKARBulletFired then
							-- The HEATSystem has already decremented one
							self.Magazine.RoundCount = self.HEATAmmoCounter;
						else
							self.Magazine.RoundCount = math.max(1, self.HEATAmmoCounter - 1);
						end
					end
				end
			end
			
		elseif self:GetNumberValue("TriumvirateAtt_RBullet_Equipped") == 1 then
			if not self.KhMOSKAToLoadRBullet then
				self.KhMOSKAToLoadRBullet = true;
				self.HEATDelayedFireTimeMS = 100;
				
				self.HEATRecoilStrength = 50
				self.HEATRecoilPowStrength = 0.2
				self.HEATRecoilRandomUpper = 1.1
				self.HEATRecoilDamping = 0.35
				self.HEATRecoilMax = 12
				self.HEATParticleUtilityFiringSmokeDataTable = {};
				self.HEATParticleUtilityFiringSmokeDataTable.Power = 45;
				self.HEATParticleUtilityFiringSmokeDataTable.Spread = 20;
				self.HEATParticleUtilityFiringSmokeDataTable.SmokeMult = 0.7;
				self.HEATParticleUtilityFiringSmokeDataTable.ExploMult = 1.3;
				self.HEATParticleUtilityFiringSmokeDataTable.WidthSpread = 2;
				self.HEATParticleUtilityFiringSmokeDataTable.VelocityMult = 1.0;
				self.HEATParticleUtilityFiringSmokeDataTable.LingerMult = 1.0;
				self.HEATParticleUtilityFiringSmokeDataTable.AirResistanceMult = 1.4;
				self.HEATParticleUtilityFiringSmokeDataTable.GravMult = 1;	
				if not self:IsReloading() then
					self:Reload();
				end
			end
		end
		
		-- Action
		if self:GetNumberValue("TriumvirateAtt_MachinedBolt_Equipped") == 1 then
			self.KhMOSKAHasMachinedBolt = true
		end
	end
end

function Create(self)
	-- Activity.
	self.Activity = ActivityMan:GetActivity();
	
	self.KhMOSKAFireVelocity = 130;
	self.KhMOSKARBulletFireVelocity = 180;
	self.KhMOSKAFireSpread = 0.5 / 2;	
	
	self.KhMOSKABassSound = CreateSoundContainer("Bass CED Khrabarovsk MOSKA", "CED.rte");
	self.KhMOSKACasingEjectAddSound = CreateSoundContainer("Casing Eject Add CED Khrabarovsk MOSKA", "CED.rte");
	self.KhMOSKARBulletAddSound = CreateSoundContainer("R Bullet Add CED Khrabarovsk MOSKA", "CED.rte");
	
	-- Whether there's an R Bullet in the chamber or not.
	self.KhMOSKARBulletLoaded = false;
	-- Whether we intend to use R Bullets or not.
	self.KhMOSKAToLoadRBullet = false;
	-- Whether we fired the loaded R Bullet or not, needed to autoswitch away from it in case of manual reload.
	self.KhMOSKARBulletFired = true;
	-- Timer to not insta-reload after firing R Bullet.
	self.KhMOSKAReloadDelayTimer = Timer();
	-- Delay for above timer.
	self.KhMOSKAReloadDelay = 400;
	
	self.KhMOSKAHasMachinedBolt = false
end

function OnFire(self)
	self.KhMOSKABassSound:Play(self.Pos);

	local spread = math.random(-self.KhMOSKAFireSpread, self.KhMOSKAFireSpread);
	local velocity = self.KhMOSKARBulletLoaded and self.KhMOSKARBulletFireVelocity or self.KhMOSKAFireVelocity;

	local shot = CreateMOPixel("Bullet CED Khrabarovsk MOSKA Scripted", "CED.rte");
	shot.Pos = self.MuzzlePos + Vector(0.1*self.FlipFactor, 0):RadRotate(self.RotAngle);
	shot.Vel = self.Vel + Vector(velocity * self.FlipFactor, spread):RadRotate(self.RotAngle);
	shot.Team = self.Team;
	shot.IgnoresTeamHits = true;
	shot:SetWhichMOToNotHit(ToMovableObject(self), 150);
	MovableMan:AddParticle(shot);

	for i = 1, 3 do
		local shot = CreateMOPixel("Bullet CED Khrabarovsk MOSKA", "CED.rte");
		shot.Pos = self.MuzzlePos + Vector(0.1*i*self.FlipFactor, 0):RadRotate(self.RotAngle);
		shot.Vel = self.Vel + Vector(velocity * self.FlipFactor, spread):RadRotate(self.RotAngle);
		shot.Team = self.Team;
		shot.IgnoresTeamHits = true;
		shot:SetWhichMOToNotHit(ToMovableObject(self), 150);
		MovableMan:AddParticle(shot);
	end
	
	if self.KhMOSKARBulletLoaded then
		self.KhMOSKARBulletAddSound:Play(self.Pos);
		for i = 1, 3 do
			local shot = CreateMOPixel("Bullet CED Khrabarovsk MOSKA", "CED.rte");
			shot.Pos = self.MuzzlePos + Vector(0.1*i*self.FlipFactor, 0):RadRotate(self.RotAngle);
			shot.Vel = self.Vel + Vector(velocity * self.FlipFactor, spread):RadRotate(self.RotAngle);
			shot.Team = self.Team;
			shot.IgnoresTeamHits = true;
			shot:SetWhichMOToNotHit(ToMovableObject(self), 150);
			MovableMan:AddParticle(shot);
		end
		
		self.Reloadable = false;
		self.KhMOSKAReloadDelayTimer:Reset();
		
	end
	self.KhMOSKARBulletFired = true;
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
	if self.parent then
		if self.parent:IsPlayerControlled() then
			local screen = ActivityMan:GetActivity():ScreenOfPlayer(self.parentController.Player);
			if self.KhMOSKAToLoadRBullet then
				if self.KhMOSKARBulletLoaded then
					if not self:IsReloading() then
						local stringToDraw = "R"
					
						if not (self.HEATParent.Jetpack and self.HEATParent.Jetpack:IsEmitting()) then
							-- Thanks JustAlex for this snippet
							local yPos = self.parentController:IsState(Controller.PIE_MENU_ACTIVE) and 15 or 6
							PrimitiveMan:DrawTextPrimitive(
								screen,
								self.HEATParent.AboveHUDPos + Vector(3, yPos),
								stringToDraw,
								true,
								0)
						end
					end
				elseif self:IsReloading() then
					PrimitiveMan:DrawTextPrimitive(screen, self.Pos + Vector(10, -10), "Loading R-Bullet...", true, 1);
				end
			end
		end
	end
	
	if self.KhMOSKAReloadDelayTimer:IsPastSimMS(self.KhMOSKAReloadDelay) then
		self.Reloadable = true;
	end	
end