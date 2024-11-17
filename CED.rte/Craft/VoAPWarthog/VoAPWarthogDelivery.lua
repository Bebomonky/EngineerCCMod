function Create(self)
	self.barrageImpactSound = CreateSoundContainer("Barrage Impact CED Vossberg AP-Warthog", "CED.rte");
	self.breathOfGod = CreateSoundContainer("Breath Of God CED Vossberg AP-Warthog", "CED.rte");
	self.incomingSound = CreateSoundContainer("Incoming CED Vossberg AP-Warthog", "CED.rte");
	
	self.startingPosition = self.Pos + Vector(0, -500);
	
	self.Pod = CreateACRocket("Vossberg AP-Warthog", "CED.rte");
	self.Pod.MissionCritical = true;
	self.Pod.Pos = self.startingPosition;
	self.Pod.Team = self.Team;
	self.Pod.HitsMOs = false;
	self.Pod.GetsHitByMOs = false;
	
	local itemTable = {};
	local i = 1;
	for item in self.Inventory do
		itemTable[i] = self:RemoveInventoryItemAtIndex(i - 1);
		i = i + 1;
	end
	
	for i, item in ipairs(itemTable) do
		self.Pod:AddInventoryItem(item);
	end
	
	MovableMan:AddActor(self.Pod);

	self.MissionCritical = true;
	self.PinStrength = 9999999;
	
	self.Timer = Timer();
	self.barrageTimer = Timer();
	
	self.timeBetweenShots = 30;
	self.timeUntilBarrage = 1000;
	self.barrageDuration = 1500;
	
	self.timeUntilPodDrop = 5000;
	
	local sceneWraps = SceneMan.SceneWrapsX;
	
	local middleRayPos = self.startingPosition;
	local middleRayVec = Vector(0, 99999);
	self.middleRayHitPos = Vector();
	-- I've never heard of NotMaterialRay but checking for "not air" should be a good enough ghetto terrain-only CastObstacleRay...
	self.middleRay = SceneMan:CastNotMaterialRay(middleRayPos, middleRayVec, 0, self.middleRayHitPos, 30, true);
	
	local leftRayPos = self.startingPosition + Vector(-150, 0);
	if leftRayPos.X < 0 and not sceneWraps then
		leftRayPos.X = 1;
	end
	local leftRayVec = Vector(0, 99999);
	self.leftRayHitPos = Vector();
	self.leftRay = SceneMan:CastNotMaterialRay(leftRayPos, leftRayVec, 0, self.leftRayHitPos, 30, true);
	
	local rightRayPos = self.startingPosition + Vector(150, 0);
	if rightRayPos.X > SceneMan.SceneWidth and not sceneWraps then
		rightRayPos.X = SceneMan.SceneWidth - 1;
	end
	local rightRayVec = Vector(0, 99999);
	self.rightRayHitPos = Vector();
	self.rightRay = SceneMan:CastNotMaterialRay(rightRayPos, rightRayVec, 0, self.rightRayHitPos, 30, true);
	
	self.averageHitPos = (self.middleRayHitPos + self.leftRayHitPos + self.rightRayHitPos) * (1/3);
end

function Update(self)
	if not self.deliveryDone then
		self.Pod.Pos = self.startingPosition;
		self.Pod.Vel = Vector(0, 0);
		self.Pod.HitsMOs = false;
		self.Pod.GetsHitByMOs = false;
	
		if self.Timer:IsPastSimMS(self.timeUntilPodDrop) then
			self.MissionCritical = false;
			self.Pod.MissionCritical = false;
			self.Pod.Pos = self.startingPosition + Vector(0, 500);
			self.Pod.Vel = Vector(0, 120);
			self.Pod.HitsMOs = true;
			self.Pod.GetsHitByMOs = true;
			self.deliveryDone = true;
			self.ToDelete = true;
			
		elseif self.Timer:IsPastSimMS(self.timeUntilBarrage) then
			if not self.Timer:IsPastSimMS(self.timeUntilBarrage + self.barrageDuration) then
				if not self.barrageImpactSoundPlayed then
					self.barrageImpactSoundPlayed = true;
					self.barrageImpactSound:Play(self.averageHitPos);
				end
				
				CameraMan:AddScreenShake(5, self.averageHitPos);
			
				if self.barrageTimer:IsPastSimMS(self.timeBetweenShots) then
					self.barrageTimer:Reset();
					
					local shot = CreateMOSRotating("Explosive Barrage Shot CED Vossberg AP-Warthog", "CED.rte");
					shot.Pos = self.startingPosition + Vector(math.random(-60, 60), 50);
					shot.Vel = self.Vel + Vector(math.random(-20, 20), 400);
					shot.Team = self.Team;
					MovableMan:AddParticle(shot);
				end
			else
				if not self.breathOfGodPlayed then
					self.breathOfGodPlayed = true;
					self.breathOfGod:Play(self.averageHitPos);
				end
			end
		end
	else
		self.ToDelete = true;
		self:GibThis();
	end
end