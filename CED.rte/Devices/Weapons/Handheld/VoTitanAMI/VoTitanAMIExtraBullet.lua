function Create(self)
	self.deleteThreshold = 70;
end

function ThreadedUpdate(self)
	if self.Vel.Magnitude < self.deleteThreshold then
		self.ToDelete = true;
	end
end


