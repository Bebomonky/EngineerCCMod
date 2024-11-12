require("/CEDSettings");

function Create(self)
	self.BASLRCFireVelocity = 140;
	self.BASLRCFireSpread = 1 / 2;
	
	self.BASLRCMechSound = CreateSoundContainer("Mech CED CED-BAS LRC", "CED.rte");
	self.BASLRCMechLastSound = CreateSoundContainer("Mech CED CED-BAS LRC", "CED.rte");
	
	self.BASLRCSwitchToHipfireSound = CreateSoundContainer("Switch To Hipfire CED CED-BAS LRC", "CED.rte");
	self.BASLRCSwitchToScopeSound = CreateSoundContainer("Switch To Scope CED CED-BAS LRC", "CED.rte");

	self.BASLRCHipfireMode = false;
end

function OnFire(self)
	if self.RoundInMagCount > 0 then
		self.BASLRCMechSound:Play(self.Pos);
	else
		self.BASLRCMechLastSound:Play(self.Pos);
	end

	local spread = math.random(-self.BASLRCFireSpread, self.BASLRCFireSpread);

	local shot = CreateMOPixel("Bullet CED CED-BAS LRC Scripted", "CED.rte");
	shot.Pos = self.MuzzlePos + Vector(0.1*self.FlipFactor, 0):RadRotate(self.RotAngle);
	shot.Vel = self.Vel + Vector(self.BASLRCFireVelocity * self.FlipFactor, spread):RadRotate(self.RotAngle);
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
	self.BASLRCMechSound.Pos = self.Pos;
	self.BASLRCMechLastSound.Pos = self.Pos;
	self.BASLRCSwitchToHipfireSound.Pos = self.Pos;
	self.BASLRCSwitchToScopeSound.Pos = self.Pos;

	if self.parent then
		if self.parentController:IsState(Controller.WEAPON_PRIMARY_HOTKEYSTART) then
			if self.BASLRCHipfireMode then
				self.BASLRCHipfireMode = false;
				self.BASLRCSwitchToScopeSound:Play(self.Pos);
			else
				self.BASLRCHipfireMode = true;
				self.BASLRCSwitchToHipfireSound:Play(self.Pos);
			end
		end
		
		if self.BASLRCHipfireMode then
			self.parentController:SetState(Controller.AIM_SHARP, false);
			if not self.parent:IsPlayerControlled() then
				self.BASLRCHipfireMode = false;
			end
		end
	end
end