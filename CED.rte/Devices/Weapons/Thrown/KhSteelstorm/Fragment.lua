function Create(self)
	self.HitsMOs = false;

	self.Timer = Timer();
	self.randomHitTime = math.random(0, 150);
end

function ThreadedUpdate(self)
	if self.Timer:IsPastSimMS(self.randomHitTime) then
		self.HitsMOs = true;
	end
end