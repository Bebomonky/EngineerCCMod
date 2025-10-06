function Create(self)
	self.XaIatosInjectSound = CreateSoundContainer("Inject CED Xarix MoR-RS Iatos", "CED.rte");
	self.XaIatosPlayerAddOrganicSound = CreateSoundContainer("Player Add Organic CED Xarix MoR-RS Iatos", "CED.rte");
	self.XaIatosPlayerAddMechanicalSound = CreateSoundContainer("Player Add Mechanical CED Xarix MoR-RS Iatos", "CED.rte");
	
	self.XaIatosDropTimer = Timer();
	self.XaIatosDropDelay = 500;
end

function OnFire(self)
	local parent = self:GetRootParent();
	if parent and IsActor(parent) then
		parent = ToActor(parent)
		self.XaIatosInjectSound:Play(self.Pos);
		
		if parent:IsPlayerControlled() then
			if parent:IsOrganic() then
				self.XaIatosPlayerAddOrganicSound:Play(self.Pos);
			elseif parent:IsMechanical() then
				self.XaIatosPlayerAddMechanicalSound:Play(self.Pos);
			end
		end
		
		parent:FlashWhite(50);
		
		local particleCount = math.ceil(1 + parent.Radius * 0.5);
		for i = 1, particleCount do
			local part = CreateMOPixel("Heal Glow", "Base.rte");
			local vec = Vector(particleCount * 2, 0):RadRotate(math.pi * 2 * i/particleCount);
			part.Pos = parent.Pos + Vector(0, -particleCount * 0.3):RadRotate(parent.RotAngle) + vec;
			part.Vel = parent.Vel * 0.5 - Vector(vec.X, vec.Y) * 0.25;
			MovableMan:AddParticle(part);
		end
		local cross = CreateMOSParticle("Particle Heal Effect", "Base.rte");
		cross.Pos = parent.AboveHUDPos + Vector(0, 5);
		MovableMan:AddParticle(cross);
		
		-- AddScript kills the game here. I have no idea why, so I'm reverting to this caveman method.
		local attachment = CreateAttachable("Effect Attachment CED Xarix MoR-RS Iatos", "CED.rte");
		parent:AddAttachable(attachment);
		
		self.StanceOffset = Vector(5, 6);
		self.SharpStanceOffset = Vector(5, 6);
		
		self.XaIatosDropTimer:Reset();
	end
end

function Update(self)
	if self.RoundInMagCount == 0 then
		if self.Frame < 2 then
			self.Frame = self.Frame + 1;
		end
		
		if self:IsAttached() and self.XaIatosDropTimer:IsPastSimMS(self.XaIatosDropDelay) then
			self:RemoveFromParent(true, false);
			self.UnPickupable = true;
			self.GibImpulseLimit = 1;
		end
	end
end