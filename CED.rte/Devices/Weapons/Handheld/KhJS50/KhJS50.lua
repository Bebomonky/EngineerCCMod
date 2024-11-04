require("/CEDSettings");

function Create(self)
	self.KhJS50ScopeClickSound = CreateSoundContainer("Scope Click CED Khrabarovsk JS50", "CED.rte");
	
	-- Table of SharpLengths to cycle through.
	self.KhJS50SharpLengthSettings = {[1] = 450,[2] =  350,[3] =  250};
	-- Current index of our SharpLength setting.
	self.KhJS50CurrentSharpLengthSetting = 2;
	
	self.SharpLength = self.KhJS50SharpLengthSettings[self.KhJS50CurrentSharpLengthSetting];
	self.HEATOriginalSharpLength = self.KhJS50SharpLengthSettings[self.KhJS50CurrentSharpLengthSetting];
end

function OnFire(self)
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
		if self.parentController:IsState(Controller.WEAPON_AUXILIARY_HOTKEYSTART) then
			self.KhJS50ScopeClickSound:Play(self.Pos);
			self.KhJS50CurrentSharpLengthSetting = (self.KhJS50CurrentSharpLengthSetting + 1) % #self.KhJS50SharpLengthSettings + 1;
			self.SharpLength = self.KhJS50SharpLengthSettings[self.KhJS50CurrentSharpLengthSetting];
			self.HEATOriginalSharpLength = self.KhJS50SharpLengthSettings[self.KhJS50CurrentSharpLengthSetting];
		end
	end
end