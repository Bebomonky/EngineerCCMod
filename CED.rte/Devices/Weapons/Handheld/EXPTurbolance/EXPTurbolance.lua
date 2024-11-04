require("/CEDSettings");

function Create(self)
	self.EXPTurbolanceShotStartSound = CreateSoundContainer("Shot Start CED CED-EXP Turbolance", "CED.rte");
	self.EXPTurbolanceShotEndSound = CreateSoundContainer("Shot End CED CED-EXP Turbolance", "CED.rte");
	
	self.EXPTurbolanceSpinLoopSound = CreateSoundContainer("Spin Loop CED CED-EXP Turbolance", "CED.rte");
	self.EXPTurbolanceSpinEndSound = CreateSoundContainer("Spin End CED CED-EXP Turbolance", "CED.rte");
	
	self.EXPTurbolanceOverheatLoopSound = CreateSoundContainer("Overheat Loop CED CED-EXP Turbolance", "CED.rte");
	self.EXPTurbolanceOverheatLoopSound.Volume = 0;
	self.EXPTurbolanceOverheatLoopSound:Play(self.Pos);
	self.EXPTurbolanceJamSound = CreateSoundContainer("Jam CED CED-EXP Turbolance", "CED.rte");
	
	self.EXPTurbolanceLooping = false;
	self.EXPTurbolanceShotCounter = 0;
	
	self.EXPTurbolanceFrameOverride = 0;
	
	self.EXPTurbolanceHeat = 0;
	self.EXPTurbolanceHeatLimit = 100;
	self.EXPTurbolanceHeatDissipation = 10;
	
	self.EXPTurbolanceHeatFXTimer = Timer();

	self.drawPos = Vector()

	self.EXPTurbolanceBlinkTimer = Timer()
	self.EXPTurbolanceToBlink = false
	self.EXPTurbolanceBlinkRange = 70
end

function OnFire(self)
	-- Weird numbers here, but they achieve the best effect
	if self.EXPTurbolanceShotCounter % 8 == 0 then
		CameraMan:AddScreenShake(7, self.Pos);
	end

	if not self.EXPTurbolanceLooping then
		self.EXPTurbolanceLooping = true;
		self.EXPTurbolanceShotStartSound:Play(self.Pos);
		self.EXPTurbolanceSpinLoopSound:Play(self.Pos);
	end
	
	self.EXPTurbolanceShotCounter = self.EXPTurbolanceShotCounter + 1;
	
	self.HEATReflectionOutdoorsSound.Volume = math.min(1, self.EXPTurbolanceShotCounter / 30);
	self.HEATReflectionIndoorsSound.Volume = math.min(1, self.EXPTurbolanceShotCounter / 10);
	
	self.EXPTurbolanceHeat = math.min(self.EXPTurbolanceHeatLimit, self.EXPTurbolanceHeat + 1);
	
	if self.EXPTurbolanceHeat >= self.EXPTurbolanceHeatLimit then
		if self.RoundInMagCount > 0 then
			self:Deactivate();
			self.EXPTurbolanceOverheated = true;
			self.EXPTurbolanceJamSound:Play(self.Pos);
			self.HEATNonReloadStaging = true;
			
			CameraMan:AddScreenShake(5, self.Pos);
			
			for i = 1, 10 do
				local particle = CreateMOSParticle("Tiny Smoke Ball 1", "Base.rte");
				particle.Lifetime = math.random(250, 600);
				particle.Vel = self.Vel + Vector(math.random(-100, 100)/100, -2);
				particle.Pos = self.Pos;
				MovableMan:AddParticle(particle);
			end		
			
			for i = 1, 5 do
				local particle = CreateMOSParticle("Small Smoke Ball 1", "Base.rte");
				particle.Lifetime = math.random(250, 600);
				particle.Vel = self.Vel + Vector(math.random(-100, 100)/100, -2);
				particle.Pos = self.Pos;
				MovableMan:AddParticle(particle);
			end
			
			for i = 1, 3 do
				local particle = CreateMOSParticle("Side Thruster Blast Ball 1", "Base.rte");
				particle.HitsMOs = false;
				particle.Lifetime = math.random(250, 600);
				particle.Vel = self.Vel + Vector(math.random(-200, 200)/100, -3);
				particle.Pos = self.Pos;
				MovableMan:AddParticle(particle);
			end
			
			for i = 1, 1 do
				local particle = CreateMOPixel("Glow Explosion Huge", "Base.rte");
				particle.HitsMOs = false;
				particle.Lifetime = math.random(10, 50);
				particle.Vel = self.Vel
				particle.Pos = self.Pos;
				MovableMan:AddParticle(particle);
			end			
			
			for i = 1, 1 do
				local particle = CreateMOSParticle("Fire Puff Large", "Base.rte");
				particle.HitsMOs = false;
				particle.Lifetime = math.random(250, 600);
				particle.Vel = self.Vel + Vector(math.random(-200, 200)/100, -3);
				particle.Pos = self.Pos;
				MovableMan:AddParticle(particle);
			end			
			
			for i = 1, 3 do
				local particle = CreateMOSParticle("Fire Puff Medium", "Base.rte");
				particle.HitsMOs = false;
				particle.Lifetime = math.random(250, 600);
				particle.Vel = self.Vel + Vector(math.random(-200, 200)/100, -3);
				particle.Pos = self.Pos;
				MovableMan:AddParticle(particle);
			end	
		end
	end
	
	local velocity = 130;
	
	local shot = CreateMOPixel("Bullet CED CED-EXP Turbolance Scripted", "CED.rte");
	shot.Pos = self.MuzzlePos + Vector(0.1*self.FlipFactor, 0):RadRotate(self.RotAngle);
	shot.Vel = self.Vel + Vector(velocity * self.FlipFactor, math.random(-5, 5)):RadRotate(self.RotAngle);
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
	if IsAHuman(newParent:GetRootParent()) then
		self.parent = ToAHuman(newParent:GetRootParent());
		self.parentController = self.parent:GetController();
	end
end

function OnDetach(self)
	self.parent = nil;
	self.parentController = nil;
	self.EXPTurbolanceSpinLoopSound:Stop(-1);
	self.EXPTurbolanceOverheatLoopSound.Volume = 0; -- Don't outright stop this because we can't tell if we're being dropped or put in inventory
end

function ThreadedUpdate(self)
	self.EXPTurbolanceShotEndSound.Pos = self.Pos;
	
	self.EXPTurbolanceSpinLoopSound.Pos = self.Pos;
	self.EXPTurbolanceSpinEndSound.Pos = self.Pos;
	
	self.EXPTurbolanceOverheatLoopSound.Pos = self.Pos;
	self.EXPTurbolanceJamSound.Pos = self.Pos;
	
	self.EXPTurbolanceOverheatLoopSound.Volume = math.min(1, self.EXPTurbolanceHeat / self.EXPTurbolanceHeatLimit);

	if self.RoundInMagCount > 0 and (not self:IsReloading()) and self:IsActivated() then
		self.EXPTurbolanceFrameOverride = (self.EXPTurbolanceFrameOverride + 1) % 5;
	elseif not self:IsActivated() then
		self.EXPTurbolanceHeat = math.max(0, self.EXPTurbolanceHeat - TimerMan.DeltaTimeSecs * self.EXPTurbolanceHeatDissipation);
	end
	
	self.HEATPersistentFrame = self.EXPTurbolanceFrameOverride;

	if self.parent and IsActor(self.parent) then
		if ToActor(self.parent):IsPlayerControlled() then
			self.HEATRecoilMax = 4;
		else
			self.HEATRecoilMax = 1;
		end
	end
	
	if self.EXPTurbolanceLooping and not self:IsActivated() then
		self.EXPTurbolanceLooping = false;
		self.EXPTurbolanceSpinLoopSound:Stop(-1);
		self.EXPTurbolanceShotEndSound:Play(self.Pos);
		self.EXPTurbolanceSpinEndSound:Play(self.Pos);
		
		self.EXPTurbolanceShotCounter = 0;
	end

	if self.parent and self.parent:IsPlayerControlled() then
		self.drawPos = Vector(self.parent.AboveHUDPos.X, self.parent.AboveHUDPos.Y)

		local ctrl = self.parent:GetController()
		local screen = ActivityMan:GetActivity():ScreenOfPlayer(ctrl.Player)
		local heat_pos = self.drawPos - Vector(10, 5)
		local ammo_pos = heat_pos - Vector(-20, 0)
		local box_y = -5
		local box_x = -20

		if self.EXPTurbolanceOverheated then
			self.EXPTurbolanceHeat = math.max(0, self.EXPTurbolanceHeat - TimerMan.DeltaTimeSecs * self.EXPTurbolanceHeatDissipation);
		end

		local heat = math.floor(self.EXPTurbolanceHeat)
		if self.EXPTurbolanceHeat > 0 then
			if self.EXPTurbolanceHeat >= self.EXPTurbolanceBlinkRange then
				if self.EXPTurbolanceBlinkTimer:IsPastSimMS(250) then
					self.EXPTurbolanceToBlink = not self.EXPTurbolanceToBlink
					self.EXPTurbolanceBlinkTimer:Reset()
				end
			else
				self.EXPTurbolanceToBlink = false
				self.EXPTurbolanceBlinkTimer:Reset()
			end
			PrimitiveMan:DrawPrimitives(100 - heat,
			{BoxFillPrimitive(screen, ammo_pos - Vector(-box_x - 1, box_y - 1), ammo_pos + Vector(box_x + heat / 4, -box_y + 2), 245),
			BoxFillPrimitive(screen, ammo_pos - Vector(-box_x, box_y), ammo_pos + Vector(box_x + heat / 4, -box_y + 1),
			self.EXPTurbolanceHeat >= self.EXPTurbolanceBlinkRange and (self.EXPTurbolanceToBlink and 77 or 13) or 149)})
		end

		if not self:IsReloading() and not self.HEATNonReloadStaging and not self.HEATDelayedFire and not self:IsActivated() then
			if self.parentController:IsState(Controller.WEAPON_PRIMARY_HOTKEYSTART) then
				if self.EXPTurbolanceHeat > 0 then
					self.EXPTurbolanceActiveCooling = true;
					self.HEATNonReloadStaging = true;
					self.EXPTurbolanceHeat = 0;
					self.HEATCurrentReloadPhase = 8;
					for i = 1, 10 do
						local particle = CreateMOSParticle("Tiny Smoke Ball 1", "Base.rte");
						particle.Lifetime = math.random(250, 600);
						particle.Vel = self.Vel + Vector(math.random(-100, 100)/100, -2);
						particle.Pos = self.Pos;
						MovableMan:AddParticle(particle);
					end		
					
					for i = 1, 5 do
						local particle = CreateMOSParticle("Small Smoke Ball 1", "Base.rte");
						particle.Lifetime = math.random(250, 600);
						particle.Vel = self.Vel + Vector(math.random(-100, 100)/100, -2);
						particle.Pos = self.Pos;
						MovableMan:AddParticle(particle);
					end
					
					for i = 1, 3 do
						local particle = CreateMOSParticle("Side Thruster Blast Ball 1", "Base.rte");
						particle.HitsMOs = false;
						particle.Lifetime = math.random(250, 600);
						particle.Vel = self.Vel + Vector(math.random(-200, 200)/100, -3);
						particle.Pos = self.Pos;
						MovableMan:AddParticle(particle);
					end
				end
			end
		end
	end

	if self.EXPTurbolanceHeatFXTimer:IsPastSimMS(200) then
		self.EXPTurbolanceHeatFXTimer:Reset();
		for i = 1, self.EXPTurbolanceHeat / 3 do
			local particle = CreateMOSParticle("Tiny Smoke Ball 1", "Base.rte");
			particle.Lifetime = math.random(250, 600);
			particle.Vel = self.Vel + Vector(math.random(-100, 100)/100, -1);
			particle.Pos = self.Pos;
			MovableMan:AddParticle(particle);
		end
		
		for i = 1, self.EXPTurbolanceHeat / 20 do
			local particle = CreateMOSParticle("Small Smoke Ball 1", "Base.rte");
			particle.Lifetime = math.random(250, 600);
			particle.Vel = self.Vel + Vector(math.random(-100, 100)/100, -1);
			particle.Pos = self.Pos;
			MovableMan:AddParticle(particle);
		end	
	end
end

function Destroy(self)
	self.EXPTurbolanceSpinLoopSound:Stop(-1);
	self.EXPTurbolanceOverheatLoopSound:Stop(-1);
end