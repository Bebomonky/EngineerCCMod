function Create(self)
	self.XaIatosHealPerSecond = 5;
	self.XaIatosEffectDuration = 25000; -- ms
	
	self.XaIatosTimer = Timer();
end

function Update(self)
	if not self.parent then
		self.parent = ToActor(self:GetRootParent());
	else
		self.parent.Health = math.min(self.parent.MaxHealth, self.parent.Health + (self.XaIatosHealPerSecond * TimerMan.DeltaTimeSecs));
	end
	if self.XaIatosTimer:IsPastSimMS(self.XaIatosEffectDuration) then
		self.ToDelete = true;
	end
end