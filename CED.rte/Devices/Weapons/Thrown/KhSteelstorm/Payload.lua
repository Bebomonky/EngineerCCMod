function Create(self)
	self.exploOutdoorsSound = CreateSoundContainer("Explo Small Add Outdoors CED", "CED.rte");
	
	self.ricochetIndoorsSound = CreateSoundContainer("Ricochet CED Khrabarovsk Steelstorm", "CED.rte");

	local outdoorRays = 0;
	local indoorRays = 0;
	local bigIndoorRays = 0;
	local rayThreshold = 2;

	local Vector2 = Vector(0,-700); -- straight up
	local Vector2Left = Vector(0,-700):RadRotate(45*(math.pi/180));
	local Vector2Right = Vector(0,-700):RadRotate(-45*(math.pi/180));			
	local Vector2SlightLeft = Vector(0,-700):RadRotate(22.5*(math.pi/180));
	local Vector2SlightRight = Vector(0,-700):RadRotate(-22.5*(math.pi/180));		
	local Vector3 = Vector(0,0); -- dont need this but is needed as an arg
	local Vector4 = Vector(0,0); -- dont need this but is needed as an arg

	self.ray = SceneMan:CastObstacleRay(self.Pos, Vector2, Vector3, Vector4, self.RootID, self.Team, 128, 7);
	self.rayRight = SceneMan:CastObstacleRay(self.Pos, Vector2Right, Vector3, Vector4, self.RootID, self.Team, 128, 7);
	self.rayLeft = SceneMan:CastObstacleRay(self.Pos, Vector2Left, Vector3, Vector4, self.RootID, self.Team, 128, 7);			
	self.raySlightRight = SceneMan:CastObstacleRay(self.Pos, Vector2SlightRight, Vector3, Vector4, self.RootID, self.Team, 128, 7);
	self.raySlightLeft = SceneMan:CastObstacleRay(self.Pos, Vector2SlightLeft, Vector3, Vector4, self.RootID, self.Team, 128, 7);
	
	self.rayTable = {self.ray, self.rayRight, self.rayLeft, self.raySlightRight, self.raySlightLeft};
	
	for _, rayLength in ipairs(self.rayTable) do
		if rayLength < 0 then
			outdoorRays = outdoorRays + 1;
		elseif rayLength > 170 then
			bigIndoorRays = bigIndoorRays + 1;
		else
			indoorRays = indoorRays + 1;
		end
	end
	
	if outdoorRays >= rayThreshold then
		self.exploOutdoorsSound:Play(self.Pos);
	else
		self.ricochetIndoorsSound:Play(self.Pos);
	end
	
	self:GibThis();	
end