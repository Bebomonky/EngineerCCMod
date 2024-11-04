require("/CEDSettings");

function Create(self)
	self.Activity = ActivityMan:GetActivity();

	self.Kh11p35ToGLSound = CreateSoundContainer("To GL CED Khrabarovsk 11p35-rifle", "CED.rte");
	self.Kh11p35FromGLSound = CreateSoundContainer("From GL CED Khrabarovsk 11p35-rifle", "CED.rte");
	
	self.Kh11p35GLFireSound = CreateSoundContainer("GL Fire CED Khrabarovsk 11p35-rifle", "CED.rte");
	self.Kh11p35FireSound = CreateSoundContainer("Fire CED Khrabarovsk 11p35-rifle", "CED.rte");
	
	self.Kh11p35SelectSingleSound = CreateSoundContainer("Select Single CED Khrabarovsk 11p35-rifle", "CED.rte");
	self.Kh11p35SelectFullSound = CreateSoundContainer("Select Full CED Khrabarovsk 11p35-rifle", "CED.rte");
	
	self.Kh11p35GLMode = false;
	self.Kh11p35GLLoaded = true;
	self.Kh11p35GLCost = 5;
	
	self.Kh11p35SingleMode = false;
end

function OnFire(self)
	if self.Kh11p35GLMode then
		self.Kh11p35GLFireSound:Play(self.Pos);
		self.Kh11p35GLLoaded = false;
		
		self.Kh11p35GLToSpawnCasing = true;
	
		local velocity = 100;

		local shot = CreateMOSRotating("Ronin M79 Grenade Shot", "Ronin.rte");
		shot.Pos = self.MuzzlePos + Vector(0.1*self.FlipFactor, 0):RadRotate(self.RotAngle);
		shot.Vel = self.Vel + Vector(velocity * self.FlipFactor, 0):RadRotate(self.RotAngle);
		shot.Team = self.Team;
		shot.IgnoresTeamHits = true;
		shot:SetWhichMOToNotHit(ToMovableObject(self), 150);
		MovableMan:AddParticle(shot);		
	else
		self.Kh11p35FireSound:Play(self.Pos);
	
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
	self.Kh11p35ToGLSound.Pos = self.Pos;
	self.Kh11p35FromGLSound.Pos = self.Pos;
	
	self.Kh11p35SelectSingleSound.Pos = self.Pos;
	self.Kh11p35SelectFullSound.Pos = self.Pos;

	local beingReloaded;
	if self.parent and IsActor(self.parent) then
		local controller = ToActor(self.parent):GetController();
		if controller:IsState(Controller.WEAPON_RELOAD) then
			beingReloaded = true;
		end
	end

	if self.parent then
		if self.parentController:IsState(Controller.WEAPON_AUXILIARY_HOTKEYSTART) then
			if self.Kh11p35SingleMode then
				self.Kh11p35SelectFullSound:Play(self.Pos);
				self.Kh11p35SingleMode = false;
				self.FullAuto = true;
			else
				self.Kh11p35SelectSingleSound:Play(self.Pos);
				self.Kh11p35SingleMode = true;
				self.FullAuto = false;
			end
		end
		if self.Magazine and self.parentController:IsState(Controller.WEAPON_PRIMARY_HOTKEYSTART) then
			if self.Kh11p35GLMode then
				self.Kh11p35FromGLSound:Play(self.Pos);
				self.Kh11p35GLMode = false;
				self.HEATOriginalSharpLength = 175;
				self.Reloadable = true;
				
				self.Magazine.RoundCount = self.Kh11p35SavedAmmo;
				self.HEATAmmoCounter = self.Kh11p35SavedAmmo;
				
				if self.RoundInMagCount > 0 then
					self.HEATEmptyReload = false;
				end
				
				self.MuzzleOffset = Vector(15, 0);
			else
				self.Kh11p35ToGLSound:Play(self.Pos);
				self.Kh11p35GLMode = true;
				self.HEATOriginalSharpLength = 70;
				self.Reloadable = false;
				
				self.Kh11p35SavedAmmo = self.RoundInMagCount;
				
				if self.Kh11p35GLLoaded then
					self.Magazine.RoundCount = 1;
				else
					self.Magazine.RoundCount = 0;
				end
				
				self.MuzzleOffset = Vector(12, 3);
			end
		end
	end
	
	if self.RoundInMagCount > 0 then
		self.HEATCurrentReloadPhase = 2;
	end
	
	if self.Kh11p35GLMode and self.Magazine then
		self.HEATCurrentReloadPhase = 5;
	end

	if self.Kh11p35GLMode then
		if self.Reloadable and self.Magazine then
			self.Reloadable = false;
		elseif beingReloaded and self.RoundInMagCount == 0 and self.Activity:GetTeamFunds(self.parent.Team) > self.Kh11p35GLCost then
			self.Reloadable = true;
			self:Reload();
			if self.parent then
				self.Activity:SetTeamFunds(self.Activity:GetTeamFunds(self.parent.Team) - self.Kh11p35GLCost, self.parent.Team)
			end
		end
		if self:DoneReloading() then
			self.Magazine.RoundCount = 1;
		end
	end
end