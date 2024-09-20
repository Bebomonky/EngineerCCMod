require("Mods.Extensions.ExtensionMan")

function ThreadedUpdate(self)
    PrimitiveMan:DrawCirclePrimitive(self.Pos, self.CEDConstructRange, 13)

	local foundAnyMO = false;
	for actor in MovableMan:GetMOsInRadius(self.Pos, self.CEDConstructRange, -1, false) do
		if actor:IsInGroup("Actors - Builders") then
			if IsAHuman(actor) or IsACrab(actor) then
				actor = ToActor(actor)
				if actor.Team == self.Team then
					foundAnyMO = true;
					if self.ClosestActor and MovableMan:ValidMO(self.ClosestActor) then
						if self.ClosestActor.UniqueID ~= actor.UniqueID and SceneMan:ShortestDistance(self.Pos, actor.Pos, SceneMan.SceneWrapsX).Magnitude	< self.closestDistance.Magnitude then
							self.ClosestActor = actor;
							self.closestDistance = SceneMan:ShortestDistance(self.Pos, self.ClosestActor.Pos, SceneMan.SceneWrapsX);
						end
					else
						self.ClosestActor = actor;
					end
					-- always update distance vector
					self.closestDistance = SceneMan:ShortestDistance(self.Pos, self.ClosestActor.Pos, SceneMan.SceneWrapsX);
				end
			end
		end
	end
	if not foundAnyMO then
		self.ClosestActor = nil;
		self.closestDistance = nil;
	end

    if self.ClosestActor then
        self:RequestSyncedUpdate()
    end
end

function SyncedUpdate(self)
end