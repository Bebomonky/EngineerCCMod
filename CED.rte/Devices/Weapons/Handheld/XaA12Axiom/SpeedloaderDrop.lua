function Create(self)
	self.dropSound = CreateSoundContainer("Speedloader Drop CED Xarix A-12 Axiom", "CED.rte");
end

function OnCollideWithTerrain(self, terrainID)
	if not self.dropDone then
		self.dropDone = true;
		self.dropSound:Play(self.Pos);
	end
end

function ThreadedUpdate(self)
	self.dropSound.Pos = self.Pos;
end