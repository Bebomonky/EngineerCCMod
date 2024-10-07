require("/CEDSettings");

function Create(self)

end

function OnFire(self)
	if self.RoundInMagCount == 0 then
		self.HEATCurrentReloadPhase = 1;
	end

	local velocity = 140;

	local shot = CreateMOPixel("Bullet CED Khrabarovsk 11p35-rifle Scripted", "CED.rte");
	shot.Pos = self.MuzzlePos + Vector(0.1*self.FlipFactor, 0):RadRotate(self.RotAngle);
	shot.Vel = self.Vel + Vector(velocity * self.FlipFactor, 0):RadRotate(self.RotAngle);
	shot.Team = self.Team;
	shot.IgnoresTeamHits = true;
	shot:SetWhichMOToNotHit(ToMovableObject(self), 150);
	MovableMan:AddParticle(shot);

	-- Use our HEATStats to spawn a casing every time we fire.
	local casing
	casing = self.HEATCasing:Clone();
	casing.Pos = self.EjectionPos;
	casing.Vel = self.Vel + Vector(self.HEATCasingVelocity.X * self.FlipFactor, self.HEATCasingVelocity.Y):RadRotate(self.RotAngle);
	casing.RotAngle = self.RotAngle;
	casing.HFlipped = self.HFlipped;
	MovableMan:AddParticle(casing);
end
					
function OnAttach(self, newParent)
	self.parent = newParent:GetRootParent();
end

function OnDetach(self)
	self.parent = nil;
end

function ThreadedUpdate(self)
	if self.HEATParent and self.HEATParent:IsPlayerControlled() then
		if UInputMan:KeyPressed(CEDSettings.WeaponAbilitySecondary) then

		end
	end
	
	if self.RoundInMagCount > 0 then
		self.HEATCurrentReloadPhase = 2;
	end
end