require("/CEDSettings");

function Create(self)
	self.VoAtlastarFirstShotSound = CreateSoundContainer("First Shot CED Vossberg Atlastar", "CED.rte");
	self.VoAtlastarPostFireSound = CreateSoundContainer("Post Fire CED Vossberg Atlastar", "CED.rte");
	self.VoAtlastarBurstReflectionOutdoorsSound = CreateSoundContainer("Burst Reflection Outdoors CED Vossberg Atlastar", "CED.rte");
	self.VoAtlastarBurstReflectionIndoorsSound = CreateSoundContainer("Burst Reflection Indoors CED Vossberg Atlastar", "CED.rte");
	
	self.VoAtlastarFired = false;
	self.VoAtlastarBurstCounter = 0;
	self.VoAtlastarBurstReflectionSoundPlayed = false;
	self.VoAtlastarLastRoundInMagCount = self.RoundInMagCount;

	self.VoAtlastarPostFireTimer = Timer();
	self.VoAtlastarPostFireCooldown = 250;
	self.VoAtlastarPostFireTimer.ElapsedSimTimeMS = self.VoAtlastarPostFireCooldown + 1; -- start it past the cooldown
	
	self.RateOfFire = 3600;
	self.HEATRecoilStrength = 35;
end

function OnFire(self)
	self.VoAtlastarPostFireSound:Play(self.Pos);
	if not self.VoAtlastarFired then
		self.VoAtlastarFired = true;
		self.VoAtlastarBurstReflectionSoundPlayed = false;
		if self.RoundInMagCount > 0 then
			self.VoAtlastarFirstShotSound:Play(self.Pos);
		end
	end
	if self.RoundInMagCount == 0 then
		self.VoAtlastarLastRoundInMagCount = 0;
	end
	self.VoAtlastarToSpawnCasing = false;
	self.VoAtlastarPostFireTimer:Reset();
	
	self.VoAtlastarBurstCounter = self.VoAtlastarBurstCounter + 1;

	local velocity = 140;

	local shot = CreateMOPixel("Bullet CED Vossberg Atlastar Scripted", "CED.rte");
	shot.Pos = self.MuzzlePos + Vector(0.1*self.FlipFactor, 0):RadRotate(self.RotAngle);
	shot.Vel = self.Vel + Vector(velocity * self.FlipFactor, 0):RadRotate(self.RotAngle);
	shot.Team = self.Team;
	shot.IgnoresTeamHits = true;
	shot:SetWhichMOToNotHit(ToMovableObject(self), 150);
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
	self.parent = newParent:GetRootParent();
end

function OnDetach(self)
	self.parent = nil;
end

function OnReload(self)
	if self.VoAtlastarLastRoundInMagCount == 1 then
		self.HEATEmptyReload = true;
		-- HEATSystem will have picked the wrong one
		self.BaseReloadTime = self.HEATTotalEmptyReloadTimeOverride;
		self.VoAtlastarToSpawnCasing = true;
	end
	self.VoAtlastarPostFireSound:Stop(-1);
	if self.VoAtlastarBurstCounter > 1 then
		if not self.VoAtlastarBurstReflectionSoundPlayed then
			self.VoAtlastarBurstReflectionSoundPlayed = true;
			if self.HEATCheckIfPointIsIndoors(self, self.Pos) then
				self.VoAtlastarBurstReflectionIndoorsSound:Play(self.Pos);
			else
				self.VoAtlastarBurstReflectionOutdoorsSound:Play(self.Pos);
			end
		end	
	end
	self.VoAtlastarBurstCounter = 0;
	self.VoAtlastarFired = false;
	self.VoAtlastarOnCooldown = false;
	self.VoAtlastarBurstReflectionSoundPlayed = false;
	self.RateOfFire = 3600;
	self.HEATRecoilStrength = 14;
end

function ThreadedUpdate(self)
	self.VoAtlastarPostFireSound.Pos = self.Pos;
	
	if self.Magazine then
		self.VoAtlastarLastRoundInMagCount = self.RoundInMagCount;
	end
	
	if self.VoAtlastarFired then
		if self.VoAtlastarBurstCounter < 4 then
			self:Activate();
			self.FireSound.SoundOverlapMode = SoundContainer.RESTART;
		else
			if not self.VoAtlastarBurstReflectionSoundPlayed then
				self.VoAtlastarBurstReflectionSoundPlayed = true;
				if self.HEATCheckIfPointIsIndoors(self, self.Pos) then
					self.VoAtlastarBurstReflectionIndoorsSound:Play(self.Pos);
				else
					self.VoAtlastarBurstReflectionOutdoorsSound:Play(self.Pos);
				end
			end	
			self.FireSound.SoundOverlapMode = SoundContainer.OVERLAP;
			self.RateOfFire = 800;
			self.HEATRecoilStrength = 4;
			if not self:IsActivated() then
				self.VoAtlastarOnCooldown = true;
			end
			if self.VoAtlastarOnCooldown then
				self:Deactivate();
				if self.VoAtlastarPostFireTimer:IsPastSimMS(self.VoAtlastarPostFireCooldown) then
					self.VoAtlastarFired = false;
					self.VoAtlastarBurstCounter = 0;
					self.VoAtlastarOnCooldown = false;
					self.VoAtlastarBurstReflectionSoundPlayed = false;
					self.RateOfFire = 3600;
					self.HEATRecoilStrength = 14;
				end
			end
		end
	end
end