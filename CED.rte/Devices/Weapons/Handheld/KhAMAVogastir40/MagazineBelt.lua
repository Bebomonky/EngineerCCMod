function Create(self)
	self.belts = {}
	self.beltsVel = {}
	self.beltsPos = {}
	self.beltsMaxFrame = {}
	for attachable in self.Attachables do
		self.belts[#self.belts + 1] = attachable
		self.beltsVel[#self.beltsVel + 1] = Vector(0, 0)
		self.beltsMaxFrame[#self.beltsMaxFrame + 1] = 0
		self.beltsPos[#self.beltsPos + 1] = Vector(self.Pos.X, self.Pos.Y)
	end

	self.roundMax = self.RoundCount
	self.roundCounter = 0
	self.roundsPerFrame = self.roundMax / (5 * 4)
end
function Update(self)
	local parent = self:GetParent()
	local playerControlled
	if IsHDFirearm(parent) then
		parent = ToHDFirearm(parent)
	else
		parent = nil
	end

	for _ = 0, (#self.belts - 1) do
		i = #self.belts - _
		if self.beltsMaxFrame[i] < 4 then
			if parent and parent.FiredFrame then
				self.roundCounter = self.roundCounter + 1
			end

			if self.roundCounter > self.roundsPerFrame then
				self.roundCounter = self.roundCounter - self.roundsPerFrame
				self.beltsMaxFrame[i] = self.beltsMaxFrame[i] + 1
			end
			break
		end
	end

	local parentPos = self.Pos
	for i, belt in ipairs(self.belts) do
		belt.Pos = parentPos

		local vel = Vector(self.beltsVel[i].X, self.beltsVel[i].Y) + SceneMan.GlobalAcc * TimerMan.DeltaTimeSecs -- Gravity
		local pos = Vector(self.beltsPos[i].X, self.beltsPos[i].Y)

		if i == math.random(1, #self.beltsPos) and parent and parent.FiredFrame then
			vel = vel + Vector(math.random() - 0.5, -math.random()) * 3
		end

		-- Pull
		local dist = SceneMan:ShortestDistance(pos, parentPos, SceneMan.SceneWrapsX)
		vel = vel + dist * math.min(math.max(dist.Magnitude, 0), 6) * TimerMan.DeltaTimeSecs

		-- Friction
		vel = vel / (1 + TimerMan.DeltaTimeSecs * 6.0) -- Air Friction

		pos = pos + vel * rte.PxTravelledPerFrame

		-- Limit Position
		local newPos = SceneMan:ShortestDistance(parentPos, pos, SceneMan.SceneWrapsX)
		newPos = parentPos + newPos:SetMagnitude(math.min(newPos.Magnitude, 4))
		pos = Vector(newPos.X, newPos.Y)

		local dif = SceneMan:ShortestDistance(parentPos, pos, SceneMan.SceneWrapsX)
		belt.RotAngle = dif.AbsRadAngle - math.pi * 0.5
		belt.Frame = math.min(
			math.max(3 - math.floor(SceneMan:ShortestDistance(parentPos, pos, SceneMan.SceneWrapsX).Magnitude), 0),
			3
		)

		belt.Frame = math.max(self.beltsMaxFrame[i], belt.Frame)

		self.beltsVel[i] = vel
		self.beltsPos[i] = pos

		--PrimitiveMan:DrawCirclePrimitive(pos, 1, 5);

		parentPos = belt.Pos + Vector(0, -4 + belt.Frame):RadRotate(belt.RotAngle)
		--parentPos = pos
	end
end

function OnDetach(self)
	self:GibThis()
end
