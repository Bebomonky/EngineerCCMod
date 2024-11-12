function Create(self)
	self.impactSound = CreateSoundContainer("Casing Impact CED Khrabarovsk AMA-Vogastir 40", "CED.rte");
end

function OnCollideWithTerrain(self, terrainID)
	if not self.impactDone then
		self.impactDone = true;
		self.impactSound:Play(self.Pos);
	end
end