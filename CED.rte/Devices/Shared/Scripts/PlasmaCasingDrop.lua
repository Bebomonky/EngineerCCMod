function Create(self)
	self.dropSound = CreateSoundContainer("CED Plasma Casing Drop", "CEDrte");
end

function OnCollideWithTerrain(self, terrainID)
	if not self.dropDone then
		self.dropDone = true;
		self.dropSound:Play(self.Pos);
	end
end