function Create(self)
	self.effectRadius = 200;
	self.materialThreshold = 25;
	self.strength = self.PinStrength; --Affects the duration of the effect
	self.flashScreen = false; --Do not turn on if you are prone to seizures

	self.actorTable = {};
	local actorCount = 0;

	for actor in MovableMan.Actors do
		local dist = SceneMan:ShortestDistance(self.Pos, actor.Pos, SceneMan.SceneWrapsX);
		if dist:MagnitudeIsLessThan(self.effectRadius) then
			local skipPx = 1 + math.floor(math.sqrt(dist.Magnitude));
			local strCheck = SceneMan:CastStrengthSumRay(self.Pos, self.Pos + dist, skipPx, rte.airID);
			if strCheck < self.materialThreshold/skipPx then
				--The effect is diminished by target actor mass, material strength and distance
				local resistance = math.sqrt(math.abs(actor.Mass) + actor.Material.StructuralIntegrity + dist.Magnitude + 1);
				actor:SetNumberValue("CEDConcussorStun", math.floor(actor:GetNumberValue("CEDConcussorStun") + self.strength/resistance));
				actor:FlashWhite(20);
				if self.flashScreen and actor:IsPlayerControlled() then
					local screen = ActivityMan:GetActivity():ScreenOfPlayer(actor:GetController().Player);
					local white, black = 254, 245;
					FrameMan:FlashScreen(screen, white, 1000);
				end
				table.insert(self.actorTable, actor);
				actorCount = actorCount + 1;
			end
		end
	end
end

function Update(self)
	self.ToSettle = false;
	local actorCount = 0;
	for i = 1, #self.actorTable do
		if MovableMan:IsActor(self.actorTable[i]) then
			local actor = ToActor(self.actorTable[i]);
			if actor:NumberValueExists("CEDConcussorStun") and actor.Status < Actor.DYING then
				actorCount = actorCount + 1;
				local numberValue = actor:GetNumberValue("CEDConcussorStun");
				if numberValue > 0 then
					actor.Status = Actor.UNSTABLE;
					local ctrl = actor:GetController();
					local dir = 0;
					if ctrl:IsState(Controller.MOVE_LEFT) then
						dir = dir - 1;
					end

					if ctrl:IsState(Controller.MOVE_RIGHT) then
						dir = dir + 1;
					end

					actor.AngularVel = actor.AngularVel - dir/(1 + math.abs(actor.AngularVel));
					if math.random(50) < numberValue then
						for i = 0, 29 do --Go through and disable the gameplay-related controller states
							ctrl:SetState(i, false);
						end
					end

					local framesPerFlash = 6;
					if (numberValue/framesPerFlash) - math.floor(numberValue/framesPerFlash) == 0 then
						actor:FlashWhite(1);
					end

					actor:SetNumberValue("CEDConcussorStun", numberValue - 1);
				else
					actor:RemoveNumberValue("CEDConcussorStun");
				end
			end
		end
	end

	if actorCount == 0 then
		self.ToDelete = true;
	end
end