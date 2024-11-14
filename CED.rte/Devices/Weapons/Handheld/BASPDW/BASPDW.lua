require("/CEDSettings");

function Create(self)
	self.BASPDWFireVelocity = 100;
	self.BASPDWFireSpread = 7 / 2;

	self.BASPDWShotSound = CreateSoundContainer("Shot CED CED-BAS PDW", "CED.rte");
	self.BASPDWMechLastSound = CreateSoundContainer("Mech Last CED CED-BAS PDW", "CED.rte");
	
	self.BASPDWSpecialFakeMagFrame = 1;
	
	self.BASPDWDualMagUsed = false;
	self.HEATCurrentReloadPhase = 3;
end

function OnFire(self)
	self.BASPDWShotSound:Play(self.Pos);

	local spread = math.random(-self.BASPDWFireSpread, self.BASPDWFireSpread);

	local shot = CreateMOPixel("Bullet CED CED-BAS PDW Scripted", "CED.rte");
	shot.Pos = self.MuzzlePos + Vector(0.1*self.FlipFactor, 0):RadRotate(self.RotAngle);
	shot.Vel = self.Vel + Vector(self.BASPDWFireVelocity * self.FlipFactor, spread):RadRotate(self.RotAngle);
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
	
	if self.RoundInMagCount == 0 then
		self.BASPDWMechLastSound:Play(self.Pos);
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
	
	if self.BASPDWMagazineRemoved then
		self.BASPDWDualMagUsed = true;
		self:SetNumberValue("HEAT_FakeMagRemoved", 1);
		self.HEATCurrentReloadPhase = 2;
		
		local fakeMag
		fakeMag = self.HEATFakeMagazineMOSRotating:Clone();
		fakeMag.Pos = self.Pos + Vector(self.HEATFakeMagazineOffset.X * self.FlipFactor, self.HEATFakeMagazineOffset.Y):RadRotate(self.RotAngle);
		fakeMag.Vel = self.Vel + Vector(self.HEATFakeMagazineVelocity.X * self.FlipFactor, self.HEATFakeMagazineVelocity.Y):RadRotate(self.RotAngle);
		fakeMag.RotAngle = self.RotAngle;
		fakeMag.AngularVel = self.HEATFakeMagazineAngularVel * self.FlipFactor;
		fakeMag.HFlipped = self.HFlipped;
		MovableMan:AddParticle(fakeMag);
	end
end

function ThreadedUpdate(self)
	self.BASPDWMechLastSound.Pos = self.Pos;
	
	if self:DoneReloading() then
		if self.BASPDWDualMagUsed then
			self.BASPDWDualMagUsed = false;
		else
			self.BASPDWDualMagUsed = true;
		end
	end
	
	if not self:IsReloading() then
		if self.BASPDWMagazineRemoved then
			self.HEATCurrentReloadPhase = 2;
		else
			if self.BASPDWDualMagUsed then
				self.HEATCurrentReloadPhase = 1;
			else
				self.HEATCurrentReloadPhase = 3;
			end
		end
	end
	
	if self.parent then
		if self.parentController:IsState(Controller.WEAPON_PRIMARY_HOTKEYSTART) and not self:IsReloading() then
			self.BASPDWDualMagUsed = true;
			self.HEATCurrentReloadPhase = 1;
			self:Reload();
		end
	end
end