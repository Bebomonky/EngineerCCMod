function Create(self)
	self.jumpTimer = Timer();
	self.jumpDelay = 400;
	self.jumpStrength = 1.5;
end

function Update(self)
	self.CompliSoundActorPlayJumpSound = false;
	local controller = self:GetController();
	
	if controller:IsState(Controller.BODY_JUMPSTART) == true and controller:IsState(Controller.BODY_CROUCH) == false and self.jumpTimer:IsPastSimMS(self.jumpDelay) and not self.isJumping then
		if (self:IsPlayerControlled() and self.CompliSoundActorFootContacts[1] == true or self.CompliSoundActorFootContacts[2] == true) or self.CompliSoundActorWasInAir == false then
			local jumpVec = Vector(0, -self.jumpStrength)
			local jumpWalkX = 3
			if controller:IsState(Controller.MOVE_LEFT) == true then
				jumpVec.X = -jumpWalkX
			elseif controller:IsState(Controller.MOVE_RIGHT) == true then
				jumpVec.X = jumpWalkX
			end
			
			if math.abs(self.Vel.X) > jumpWalkX * 2.0 then
				self.Vel = Vector(self.Vel.X, self.Vel.Y + jumpVec.Y)
			else
				self.Vel = Vector(self.Vel.X + jumpVec.X, self.Vel.Y + jumpVec.Y)
			end
			self.jumpTimer:Reset()
			self.CompliSoundActorPlayJumpSound = true;
		end
	end
end