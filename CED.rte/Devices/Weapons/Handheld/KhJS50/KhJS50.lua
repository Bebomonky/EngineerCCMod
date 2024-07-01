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

function ThreadedUpdate(self)
	if self.HEATParent and self.HEATParent:IsPlayerControlled() then
		if UInputMan:KeyPressed(CEDSettings.WeaponAbilitySecondary) then
			self.KhJS50ScopeClickSound:Play(self.Pos);
			self.KhJS50CurrentSharpLengthSetting = (self.KhJS50CurrentSharpLengthSetting + 1) % #self.KhJS50SharpLengthSettings + 1;
			self.SharpLength = self.KhJS50SharpLengthSettings[self.KhJS50CurrentSharpLengthSetting];
			self.HEATOriginalSharpLength = self.KhJS50SharpLengthSettings[self.KhJS50CurrentSharpLengthSetting];
		end
	end
end