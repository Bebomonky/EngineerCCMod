function Create(self)
	self.makeUnstableMassThreshold = 170;
end

function OnCollideWithMO(self, MO, rootMO)
	if not self.madeActorUnstable then
		if self.Vel.Magnitude > 90 then
			if IsActor(rootMO) and rootMO.Mass < self.makeUnstableMassThreshold then
				ToActor(rootMO).Status = 1;
				self.madeActorUnstable = true;
			end
		end
	end
end
