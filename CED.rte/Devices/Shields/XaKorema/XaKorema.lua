require("/CEDSettings");

function Create(self)
	self.XaKoremaRechargeStartSound = CreateSoundContainer("Recharge Start CED Xarix Korema", "CED.rte");
	self.XaKoremaRechargeFinishSound = CreateSoundContainer("Recharge Finish CED Xarix Korema", "CED.rte");
	
	self.XaKoremaCriticalImpactSound = CreateSoundContainer("Critical Impact CED Xarix Korema", "CED.rte");
	
	self.XaKoremaEquipSound = CreateSoundContainer("Equip CED Xarix Korema", "CED.rte");
	self.XaKoremaDropSound = CreateSoundContainer("Drop CED Xarix Korema", "CED.rte");
	
	self.XaKoremaRechargeTimer = Timer();
	self.XaKoremaRechargeStartTime = 5000;
	self.XaKoremaRechargeFactor = 5;
	
	self.XaKoremaRechargeSoundPlayed = true;
	
	self.XaKoremaActualGibWoundLimit = 17;
	self.GibWoundLimit = 999; -- Not quite invincible, just to make sure
	self.XaKoremaEffectiveWoundCount = self:NumberValueExists("XaKorema_EffectiveWoundCount") and self:GetNumberValue("XaKorema_EffectiveWoundCount") or 0;
	self.XaKoremaPreviousWoundCounter = self.WoundCount;
end
					
function OnAttach(self, newParent)
	self.XaKoremaToPlayTerrainImpact = false;
	
	self.XaKoremaEquipSound:Play(self.Pos);
	
	if IsAHuman(newParent:GetRootParent()) then
		self.parent = ToAHuman(newParent:GetRootParent());
		self.parentController = self.parent:GetController();
	end
end

function OnDetach(self)
	self.XaKoremaEquipSound:Stop(-1);
	
	self.XaKoremaToPlayTerrainImpact = true;
	
	self.parent = nil;
	self.parentController = nil;
end

function OnCollideWithTerrain(self)
	if self.XaKoremaToPlayTerrainImpact then
		self.XaKoremaToPlayTerrainImpact = false;
		self.XaKoremaDropSound:Play(self.Pos);
	end
end

function ThreadedUpdate(self)
	self.XaKoremaRechargeStartSound.Pos = self.Pos;
	self.XaKoremaRechargeFinishSound.Pos = self.Pos;
	
	self.XaKoremaCriticalImpactSound.Pos = self.Pos;

	self.XaKoremaEquipSound.Pos = self.Pos;
	self.XaKoremaDropSound.Pos = self.Pos;
	
	local totalWoundCount = self.WoundCount;
	
	if totalWoundCount - self.XaKoremaPreviousWoundCounter > 0 then
		self.XaKoremaEffectiveWoundCount = self.XaKoremaEffectiveWoundCount + (totalWoundCount - self.XaKoremaPreviousWoundCounter);
		self.XaKoremaRechargeTimer:Reset();
		self.XaKoremaRechargeStartSound:Stop(-1);
		self.XaKoremaRechargeSoundPlayed = false;
	end
	
	if self.XaKoremaRechargeTimer:IsPastSimMS(self.XaKoremaRechargeStartTime) then
		if not self.XaKoremaRechargeSoundPlayed then
			self.XaKoremaRechargeStartSound:Play(self.Pos);
			self.XaKoremaRechargeSoundPlayed = true;
		end
		if self.XaKoremaEffectiveWoundCount > 0 then
			self.XaKoremaEffectiveWoundCount = self.XaKoremaEffectiveWoundCount - (TimerMan.DeltaTimeSecs * self.XaKoremaRechargeFactor);
			if self.XaKoremaEffectiveWoundCount <= 0 then
				self.XaKoremaEffectiveWoundCount = 0;
				self.XaKoremaRechargeFinishSound:Play(self.Pos);
			end
		end
	end
	
	if self.XaKoremaEffectiveWoundCount > self.XaKoremaActualGibWoundLimit then
		self:GibThis();
		self.XaKoremaCriticalImpactSound:Stop-(-1);
	else
		if self.XaKoremaEffectiveWoundCount >= 12 then
			self.Frame = 4;
			if not self.XaKoremaCriticalImpactSoundPlayed then
				self.XaKoremaCriticalImpactSound:Play(self.Pos);
				self.XaKoremaCriticalImpactSoundPlayed = true;
			end
		else
			self.Frame = 0 + math.floor(self.XaKoremaEffectiveWoundCount / 3);
			self.XaKoremaCriticalImpactSoundPlayed = false;
		end
	end

	self.XaKoremaPreviousWoundCounter = totalWoundCount;	
end

function OnSave(self)
	self:SetNumberValue("XaKorema_EffectiveWoundCount", self.XaKoremaEffectiveWoundCount);
end