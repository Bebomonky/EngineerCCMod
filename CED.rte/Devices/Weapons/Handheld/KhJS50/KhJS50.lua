require("/CEDSettings");

function Create(self)
	self.KhJS50FireVelocity = 140;
	self.KhJS50FireSpread = 0.5 / 2;

	self.KhJS50BassSound = CreateSoundContainer("Bass CED Khrabarovsk JS50", "CED.rte");
	self.KhJS50ShotSound = CreateSoundContainer("Shot CED Khrabarovsk JS50", "CED.rte");
	self.KhJS50ScopeClickSound = CreateSoundContainer("Scope Click CED Khrabarovsk JS50", "CED.rte");
	
	-- Table of SharpLengths to cycle through.
	self.KhJS50SharpLengthSettings = {[1] = 450,[2] =  350,[3] =  250};
	-- Current index of our SharpLength setting.
	self.KhJS50CurrentSharpLengthSetting = 2;
	
	self.SharpLength = self.KhJS50SharpLengthSettings[self.KhJS50CurrentSharpLengthSetting];
	self.HEATOriginalSharpLength = self.KhJS50SharpLengthSettings[self.KhJS50CurrentSharpLengthSetting];
end

function OnFire(self)
	self.KhJS50BassSound:Play(self.Pos);
	self.KhJS50ShotSound:Play(self.Pos);
	local spread = math.random(-self.KhJS50FireSpread, self.KhJS50FireSpread);

	local shot = CreateMOPixel("Bullet CED Khrabarovsk JS50 Scripted", "CED.rte");
	shot.Pos = self.MuzzlePos + Vector(0.1*self.FlipFactor, 0):RadRotate(self.RotAngle);
	shot.Vel = self.Vel + Vector(self.KhJS50FireVelocity * self.FlipFactor, spread):RadRotate(self.RotAngle);
	shot.Team = self.Team;
	shot.IgnoresTeamHits = true;
	shot:SetWhichMOToNotHit(ToMovableObject(self), 150);
	MovableMan:AddParticle(shot);

	for i = 1, 2 do
		local shot = CreateMOPixel("Bullet CED Khrabarovsk JS50", "CED.rte");
		shot.Pos = self.MuzzlePos + Vector(0.1*i*self.FlipFactor, 0):RadRotate(self.RotAngle);
		shot.Vel = self.Vel + Vector(self.KhJS50FireVelocity * self.FlipFactor, spread):RadRotate(self.RotAngle);
		shot.Team = self.Team;
		shot.IgnoresTeamHits = true;
		shot:SetWhichMOToNotHit(ToMovableObject(self), 150);
		MovableMan:AddParticle(shot);
	end		

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
	if self.parent then
		if self.parentController:IsState(Controller.WEAPON_PRIMARY_HOTKEYSTART) then
			self.KhJS50ScopeClickSound:Play(self.Pos);
			self.KhJS50CurrentSharpLengthSetting = (self.KhJS50CurrentSharpLengthSetting + 1) % #self.KhJS50SharpLengthSettings + 1;
			self.SharpLength = self.KhJS50SharpLengthSettings[self.KhJS50CurrentSharpLengthSetting];
			self.HEATOriginalSharpLength = self.KhJS50SharpLengthSettings[self.KhJS50CurrentSharpLengthSetting];
		end
	end
end