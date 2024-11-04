require("/CEDSettings");

function Create(self)
	self.KhGS7BoltForwardSound = CreateSoundContainer("Bolt Forward CED Khrabarovsk GS7", "CED.rte");
	
	self.KhGS7SlamFireMode = false;
	self.KhGS7SlamFireModeTimer = Timer();
	self.KhGS7SlamFireModeDelayedFireTime = 120;
	self.KhGS7SlamFireModePostFireTime = 90;
	self.KhGS7SlamFireModeBoltBackTime = 120;
	
end

function OnFire(self)
	local velocity = 150;

	local shot = CreateMOPixel("Pellet CED Khrabarovsk GS7 Scripted", "CED.rte");
	shot.Pos = self.MuzzlePos + Vector(0.1*self.FlipFactor, 0):RadRotate(self.RotAngle);
	shot.Vel = self.Vel + Vector(velocity * self.FlipFactor, 0):RadRotate(self.RotAngle);
	shot.Team = self.Team;
	shot.IgnoresTeamHits = true;
	shot:SetWhichMOToNotHit(ToMovableObject(self), 150);
	MovableMan:AddParticle(shot);

	if self.KhGS7SlamFireMode then
		self.HEATCurrentReloadPhase = 2;
	end
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

function ThreadedUpdate(self)
	if self.parent then
		if not self:IsReloading() and not self.HEATNonReloadStaging and not self.HEATDelayedFire then
			if self.parentController:IsState(Controller.WEAPON_PRIMARY_HOTKEYSTART) then
				if self.KhGS7SlamFireMode == false then
					self.FullAuto = true;
					self.RateOfFire = 600;
					
					self.HEATOriginalSupportOffset = Vector(-2, 2);
					self.HEATOriginalSharpLength = 90;
					self.HEATOriginalStanceOffset = Vector(3, 7);
					self.HEATOriginalSharpStanceOffset = Vector(3, 7);
					
					self.HEATCurrentReloadPhase = 2;
					self.KhGS7SlamFireMode = true;
					self.HEATNonReloadStaging = true;
					self.HEATRecoilStrength = 45;
					self.HEATRecoilDamping = 0.34;
					self.HEATRecoilMax = 16;
					self.useHEATDelayedFire = true;
					self.HEATPreSound = self.KhGS7BoltForwardSound;
					self.HEATDelayedFireTimeMS = self.KhGS7SlamFireModeDelayedFireTime;
				else
					self.FullAuto = false;
					self.RateOfFire = 300;
					
					self.HEATOriginalSupportOffset = Vector(2, 2);
					self.HEATOriginalSharpLength = 180;
					self.HEATOriginalStanceOffset = Vector(3, 7);
					self.HEATOriginalSharpStanceOffset = Vector(6, 2);						
					
					self.HEATCurrentReloadPhase = 6;
					self.KhGS7SlamFireMode = false;
					self.HEATNonReloadStaging = true;
					self.HEATRecoilStrength = 29;
					self.HEATRecoilDamping = 0.6;
					self.HEATRecoilMax = 4;
					self.useHEATDelayedFire = false;
					self.HEATPreSound = nil;
					self.HEATDelayedFireTimeMS = nil;
				end
			end
		end
	end
	
	if self.KhGS7SlamFireMode then
		if self:DoneReloading() then
			self.HEATCurrentReloadPhase = 2;
			self.HEATNonReloadStaging = true;
		end
		if self.HEATDelayedFire then
			self.SupportOffset = Vector(2, 2);
			self.HEATPersistentFrame = nil;
			local f = math.max(1 - math.min((self.HEATDelayedFireTimer.ElapsedSimTimeMS) / self.HEATDelayedFireTimeMS*0.5, 1), 0)
			self.Frame = math.floor(3 - math.floor(f * 3 + 0.55));
		end
	end
end