require("/CEDSettings");

function OnMessage(self, message, object)

	-- This is a full update, even if it's redundant. It only runs whenever any attachment is changed, so it should be fine.

	if message == "TriumvirateAtt_Update" then
		
		--if self:GetNumberValue("TriumvirateAtt_FullAuto_Equipped") == 1 then
		--	self.EXPPulsarSingleMode = false;
		--	self.FullAuto = true;
		--elseif self:GetNumberValue("TriumvirateAtt_SemiAuto_Equipped") == 1 then
		--	self.EXPPulsarSingleMode = true;
		--	self.FullAuto = false;
		--end		
		
	end
end

function Create(self)
	self.Activity = ActivityMan:GetActivity();
	
	self.EXPPulsarFireVelocity = 180;
	self.EXPPulsarFireSpread = 1.5 / 2;

	self.EXPPulsarMechSound = CreateSoundContainer("Mech CED CED-EXP Pulsar", "CED.rte");
	self.EXPPulsarShotSound = CreateSoundContainer("Shot CED CED-EXP Pulsar", "CED.rte");
	self.EXPPulsarShotSound.Pitch = 0.9; -- Just plain sounds cooler to be honest
	
	self.EXPPulsarAttSightingRange = 175;
end

function OnFire(self)
	CameraMan:AddScreenShake(3, self.Pos);

	self.EXPPulsarMechSound:Play(self.Pos);
	self.EXPPulsarShotSound:Play(self.Pos);
	
	local spread = math.random(-self.EXPPulsarFireSpread, self.EXPPulsarFireSpread);

	local shot = CreateMOPixel("Bullet CED CED-EXP Pulsar Scripted", "CED.rte");
	shot.Pos = self.MuzzlePos + Vector(0.1*self.FlipFactor, 0):RadRotate(self.RotAngle);
	shot.Vel = self.Vel + Vector(self.EXPPulsarFireVelocity * self.FlipFactor, spread):RadRotate(self.RotAngle);
	shot.Team = self.Team;
	shot.IgnoresTeamHits = true;
	shot:SetWhichMOToNotHit(ToMovableObject(self), 150);
	MovableMan:AddParticle(shot);
	
	for i = 1, 1 do
		local shot = CreateMOPixel("Bullet CED CED-EXP Pulsar", "CED.rte");
		shot.Pos = self.MuzzlePos + Vector(0.1*self.FlipFactor, 0):RadRotate(self.RotAngle);
		shot.Vel = self.Vel + Vector(self.EXPPulsarFireVelocity * self.FlipFactor, spread):RadRotate(self.RotAngle);
		shot.Team = self.Team;
		shot.IgnoresTeamHits = true;
		shot:SetWhichMOToNotHit(ToMovableObject(self), 150);
		MovableMan:AddParticle(shot);
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
	self.EXPPulsarMechSound.Pos = self.Pos;
end