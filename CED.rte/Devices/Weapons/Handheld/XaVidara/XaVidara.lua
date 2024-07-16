require("/CEDSettings");

function Create(self)

	self.XaVidaraSwitchRifleSound = CreateSoundContainer("Switch Rifle CED Xarix Vidara", "CED.rte");
	self.XaVidaraSwitchShotgunSound = CreateSoundContainer("Switch Shotgun CED Xarix Vidara", "CED.rte");
	
	self.XaVidaraRifleShotSound = CreateSoundContainer("Rifle Shot CED Xarix Vidara", "CED.rte");
	self.XaVidaraShotgunShotSound = CreateSoundContainer("Shotgun Shot CED Xarix Vidara", "CED.rte");

	-- Whether we are in spreadshot mode or not.
	self.XaVidaraSpreadshotMode = false;
	-- Spread to achieve shotgun effect, in degrees per direction. 2 here would result in a 4 degree cone.
	self.XaVidaraSpread = 0;
	-- Shots to fire at once.
	self.XaVidaraShotsToFire = 1;
	-- Wound damage multiplier to set.
	self.XaVidaraWoundDamageMultiplier = 1;
	-- Extra ammo to deduct when firing in spreadshot mode.
	self.XaVidaraSpreadshotExtraAmmoToDeduct = 2;
end

function OnFire(self)
	local actingRoundInMagCount = self.RoundInMagCount + 1; -- the game runs this function late, so ammo is already deducted
	if self.XaVidaraSpreadshotMode then
		if actingRoundInMagCount < self.XaVidaraSpreadshotExtraAmmoToDeduct then
			self.XaVidaraShotsToFire = self.XaVidaraShotsToFire + (actingRoundInMagCount - (self.XaVidaraSpreadshotExtraAmmoToDeduct + 1));
		end
		if self.Magazine then
			self.Magazine.RoundCount = math.max(0, self.Magazine.RoundCount - self.XaVidaraSpreadshotExtraAmmoToDeduct);
		end
		self.XaVidaraShotgunShotSound:Play(self.Pos);
	else
		self.XaVidaraRifleShotSound:Play(self.Pos);
	end

	local velocity = 100;

	for i = 1, self.XaVidaraShotsToFire do
		local shot = CreateMOSRotating("Laser Particle CED Xarix Vidara", "CED.rte");
		shot.Pos = self.MuzzlePos + Vector(0.1*self.FlipFactor, 0):RadRotate(self.RotAngle);
		shot.Vel = self.Vel + Vector(velocity * self.FlipFactor, 0):RadRotate(self.RotAngle);
		shot.HFlipped = self.HFlipped;
		shot.RotAngle = self.RotAngle + math.rad(math.random(-self.XaVidaraSpread, self.XaVidaraSpread))
		shot.Team = self.Team;
		shot.IgnoresTeamHits = true;
		shot:SetWhichMOToNotHit(ToMovableObject(self), 150);
		shot:SetNumberValue("CED_LaserWoundDamageMultiplier", self.XaVidaraWoundDamageMultiplier);
		MovableMan:AddParticle(shot);
	end
end

function ThreadedUpdate(self)
	if self.HEATParent and self.HEATParent:IsPlayerControlled() then
		if UInputMan:KeyPressed(CEDSettings.WeaponAbilityPrimary) then
			if self.XaVidaraSpreadshotMode then
				self.XaVidaraSwitchRifleSound:Play(self.Pos);
				self.XaVidaraSpreadshotMode = false;
				self.XaVidaraSpread = 0;
				self.XaVidaraShotsToFire = 1;
				self.XaVidaraWoundDamageMultiplier = 1;
				self.RateOfFire = 400;
				self.HEATRecoilStrength = 20;
			else
				self.XaVidaraSwitchShotgunSound:Play(self.Pos);
				self.XaVidaraSpreadshotMode = true;
				self.XaVidaraSpread = 5;
				self.XaVidaraShotsToFire = 4;
				self.XaVidaraWoundDamageMultiplier = 0.7; -- hey, the description is accurate!
				self.RateOfFire = 150;
				self.HEATRecoilStrength = 50;
			end
		end
	end
end