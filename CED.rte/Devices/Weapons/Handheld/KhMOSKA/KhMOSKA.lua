-- While this interfaces with the HEATSystem, it's probably neater to have this stuff here that in HEATStats.
-- This was a painful gun to make to account for every singular edge case.

require("/CEDSettings");

function Create(self)
	-- Activity.
	self.Activity = ActivityMan:GetActivity();
	-- Whether we intend to use R Bullets or not.
	self.KhMOSKAToLoadRBullet = false;
	-- Whether we fired the loaded R Bullet or not, needed to autoswitch away from it in case of manual reload.
	self.KhMOSKARBulletFired = true;
	-- Timer to not insta-reload after firing R bullet.
	self.KhMOSKAReloadDelayTimer = Timer();
	-- Delay for above timer.
	self.KhMOSKAReloadDelay = 400;
	-- Cost to fire an R-Bullet.
	self.KhMOSKARBulletCost = 5;
end

function OnFire(self)
	
	local velocity = self.KhMOSKARBulletLoaded and 180 or 130;

	local shot = CreateMOPixel("Bullet CED Khrabarovsk MOSKA Scripted", "CED.rte");
	shot.Pos = self.MuzzlePos + Vector(0.1*self.FlipFactor, 0):RadRotate(self.RotAngle);
	shot.Vel = self.Vel + Vector(velocity * self.FlipFactor, 0):RadRotate(self.RotAngle);
	shot.Team = self.Team;
	shot.IgnoresTeamHits = true;
	shot:SetWhichMOToNotHit(ToMovableObject(self), 150);
	MovableMan:AddParticle(shot);

	for i = 1, 2 do
		local shot = CreateMOPixel("Bullet CED Khrabarovsk MOSKA", "CED.rte");
		shot.Pos = self.MuzzlePos + Vector(0.1*i*self.FlipFactor, 0):RadRotate(self.RotAngle);
		shot.Vel = self.Vel + Vector(velocity * self.FlipFactor, 0):RadRotate(self.RotAngle);
		shot.Team = self.Team;
		shot.IgnoresTeamHits = true;
		shot:SetWhichMOToNotHit(ToMovableObject(self), 150);
		MovableMan:AddParticle(shot);
	end
	
	if self.KhMOSKARBulletLoaded then
		self.KhMOSKARBulletAddSound:Play(self.Pos);
		for i = 1, 3 do
			local shot = CreateMOPixel("Bullet CED Khrabarovsk MOSKA", "CED.rte");
			shot.Pos = self.MuzzlePos + Vector(0.1*i*self.FlipFactor, 0):RadRotate(self.RotAngle);
			shot.Vel = self.Vel + Vector(velocity * self.FlipFactor, 0):RadRotate(self.RotAngle);
			shot.Team = self.Team;
			shot.IgnoresTeamHits = true;
			shot:SetWhichMOToNotHit(ToMovableObject(self), 150);
			MovableMan:AddParticle(shot);
		end
		
		self.Reloadable = false;
		self.KhMOSKAReloadDelayTimer:Reset();
		
		if self.HEATParent then
			self.Activity:SetTeamFunds(self.Activity:GetTeamFunds(self.HEATParent.Team) - self.KhMOSKARBulletCost, self.HEATParent.Team)
		end
	end
	self.KhMOSKARBulletFired = true;
end

function Update(self)
	if self.KhMOSKAReloadDelayTimer:IsPastSimMS(self.KhMOSKAReloadDelay) then
		self.Reloadable = true;
	end
	
	if self.HEATParent and self.HEATParent:IsPlayerControlled() then
		if UInputMan:KeyPressed(CEDSettings.WeaponAbilitySecondary) then
			if self.KhMOSKAToLoadRBullet then
				self.KhMOSKAToLoadRBullet = false;
				self.HEATDelayedFireTimeMS = 50;
				
				self.HEATRecoilStrength = 39
				self.HEATRecoilPowStrength = 0.2
				self.HEATRecoilRandomUpper = 1.1
				self.HEATRecoilDamping = 0.7
				self.HEATRecoilMax = 4
				if not self:IsReloading() then
					self.HEATDelayedFireTimeMS = 100;
					self:Reload();
				end
			else
				self.KhMOSKAToLoadRBullet = true;
				self.HEATDelayedFireTimeMS = 100;
				
				self.HEATRecoilStrength = 50
				self.HEATRecoilPowStrength = 0.2
				self.HEATRecoilRandomUpper = 1.1
				self.HEATRecoilDamping = 0.35
				self.HEATRecoilMax = 12
				if not self:IsReloading() then
					self:Reload();
				end
			end
		end
	end
	
	local ctrl;
	local screen;
	if self.HEATParent then
		ctrl = self.HEATParent:GetController();
		screen = ActivityMan:GetActivity():ScreenOfPlayer(ctrl.Player);
		if self.KhMOSKAToLoadRBullet then
			if self.KhMOSKARBulletLoaded then
				if not self:IsReloading() then
					local stringToDraw = "R"
				
					if self.Activity:GetTeamFunds(self.HEATParent.Team) < self.KhMOSKARBulletCost then
						self:Deactivate();
						stringToDraw = "noOz!"
					end
				
					if not (self.HEATParent.Jetpack and self.HEATParent.Jetpack:IsEmitting()) then
						-- Thanks JustAlex for this snippet
						local yPos = ctrl:IsState(Controller.PIE_MENU_ACTIVE) and 15 or 6
						PrimitiveMan:DrawTextPrimitive(
							screen,
							self.HEATParent.AboveHUDPos + Vector(3, yPos),
							stringToDraw,
							true,
							0)
					end
				end
			elseif self:IsReloading() then
				PrimitiveMan:DrawTextPrimitive(screen, self.Pos + Vector(10, -10), "Loading R-Bullet...", true, 1);
			end
		end
	end
end