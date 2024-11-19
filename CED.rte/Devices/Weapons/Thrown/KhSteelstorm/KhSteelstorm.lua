function Create(self)
	self.pinPullSound = CreateSoundContainer("Pin Pull CED Khrabarovsk Steelstorm", "CED.rte");
	
	self.Timer = Timer();
	self.fuzeTime = 4000;
end

function OnAttach(self, newParent)
	if IsAHuman(newParent:GetRootParent()) then
		self.parent = ToAHuman(newParent:GetRootParent());
		self.parentController = self.parent:GetController();
	end
end

function OnDetach(self)
	self.parent = nil;
	self.parentController = nil;
end

function Update(self)
	if self.Active then
		if self.Timer:IsPastSimMS(self.fuzeTime) then
			self:GibThis();
		end
	elseif self.Activated then
		if not self:IsAttached() then
			self.Active = true;
			self.Timer:Reset();
		end
	elseif self.parent and self.parentController:IsState(Controller.WEAPON_FIRE) then
		self.Frame = 1;
		self.pinPullSound:Play(self.Pos);
		local pin = CreateMOSRotating("Pin CED Khrabarovsk Steelstorm", "CED.rte");
		pin.Vel = self.Vel + Vector (0, -3):RadRotate(self.RotAngle);
		pin.Pos = self.Pos + Vector(1, -2):RadRotate(self.RotAngle);
		MovableMan:AddParticle(pin);
		self.Activated = true;
	end
end