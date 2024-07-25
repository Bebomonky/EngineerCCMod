require("/CEDSettings");

function Create(self)
	self.KhSPr40HammerBackSound = CreateSoundContainer("Hammer Back CED Khrabarovsk SPr-40", "CED.rte");
	self.KhSPr40PreSound = CreateSoundContainer("Pre CED Khrabarovsk SPr-40", "CED.rte");
	self.KhSPr40SinglePreSound = CreateSoundContainer("Single Pre CED Khrabarovsk SPr-40", "CED.rte");

	self.KhSPr40PrecisionMode = false;
	self.KhSPr40PrecisionModeTimer = Timer();
	self.KhSPr40PrecisionModeHoldTime = 170;
	self.KhSPr40PrecisionModeFocusTime = 400;
	
	self.KhSPr40PrecisionModeExtraSharpLength = 150;
end

function OnFire(self)
	local velocity = 160;

	local shot = CreateMOPixel("Bullet CED Khrabarovsk SPr-40 Scripted", "CED.rte");
	shot.Pos = self.MuzzlePos + Vector(0.1*self.FlipFactor, 0):RadRotate(self.RotAngle);
	shot.Vel = self.Vel + Vector(velocity * self.FlipFactor, 0):RadRotate(self.RotAngle);
	shot.Team = self.Team;
	shot.IgnoresTeamHits = true;
	shot:SetWhichMOToNotHit(ToMovableObject(self), 150);
	MovableMan:AddParticle(shot);
	
	self.HEATPreSound = self.KhSPr40PreSound;
	self.HEATDelayedFireTimeMS = 50;
end
					
function OnAttach(self, newParent)
	if IsAHuman(newParent:GetRootParent()) then
		self.parent = ToAHuman(newParent:GetRootParent());
	end
end

function OnDetach(self)
	self.parent = nil;
end

function ThreadedUpdate(self)
	self.KhSPr40HammerBackSound.Pos = self.Pos;
	self.KhSPr40PreSound.Pos = self.Pos;
	self.KhSPr40SinglePreSound.Pos = self.Pos;
	
	self.HEATRotationTargetOverride = nil;
	self.HEATAngVelOverride = 0;
	self.HEATPersistentFrame = 0;

	if self.parent then
		if (self.parent.EquippedItem and self.parent.EquippedItem.UniqueID == self.UniqueID and not self.parent.EquippedBGItem) or (self.parent.EquippedBGItem and self.parent.EquippedBGItem.UniqueID == self.UniqueID and not self.parent.EquippedItem) then
			local fire = self.RoundInMagCount > 0 and self:IsActivated();
			self:Deactivate();
			
			if fire then
				self.KhSPr40Activated = true;
				self.HEATDelayedFireTimeMS = 50;
				if self.KhSPr40PrecisionModeTimer:IsPastSimMS(self.KhSPr40PrecisionModeHoldTime) then
					self.HEATPersistentFrame = 1;
					if not self.KhSPr40PrecisionMode then
						self.KhSPr40PrecisionMode = true;
						self.KhSPr40HammerBackSound:Play(self.Pos);
						self.HEATAngVelOverride = -5;
						self.HEATOriginalSharpLength = 300;
					end
					self.HEATPreSound = self.KhSPr40SinglePreSound;
					self.HEATDelayedFireTimeMS = 10;
					
					local sharpFocus = math.sin(math.pow(math.min((self.KhSPr40PrecisionModeTimer.ElapsedSimTimeMS - self.KhSPr40PrecisionModeHoldTime) / (self.KhSPr40PrecisionModeHoldTime + self.KhSPr40PrecisionModeFocusTime), 1), 1.2) * math.pi / 2)
					self.HEATRotationTargetOverride = 5 * math.sin(sharpFocus * math.pi);
					self.HEATOriginalSharpLength = 180 + self.KhSPr40PrecisionModeExtraSharpLength * sharpFocus;
				end
			else
				self.HEATOriginalSharpLength = 180;
				self.KhSPr40PrecisionMode = false;
				if self.KhSPr40Activated then
					self.KhSPr40Activated = false;
					self:Activate();
				end
				self.KhSPr40PrecisionModeTimer:Reset();
			end
		end
	end
	
	if self.HEATDelayedFire then
		self.HEATPersistentFrame = 1;
	end

	if self.parent and IsActor(self.parent) then
		if ToActor(self.parent):IsPlayerControlled() then
			self.HEATRecoilMax = 6;
		else
			self.HEATRecoilMax = 2;
		end
	end
end