function Create(self)
	self.goldTimer = Timer();
	if self:NumberValueExists("goldTimerElapsedSimTimeMS") then
		self.goldTimer.ElapsedSimTimeMS = self:GetNumberValue("goldTimerElapsedSimTimeMS");
		self:RemoveNumberValue("goldTimerElapsedSimTimeMS");
	end
	self.goldDelay = 1000;
	self.goldAmount = 10;
end

function ThreadedUpdate(self)
	if self.goldTimer:IsPastSimMS(self.goldDelay) then
		self.goldTimer:Reset();
		ActivityMan:GetActivity():SetTeamFunds(ActivityMan:GetActivity():GetTeamFunds(self.Team) + self.goldAmount, self.Team)
	end
end

function OnSave(self)
	self:SetNumberValue("goldTimerElapsedSimTimeMS", self.goldTimer.ElapsedSimTimeMS);
end