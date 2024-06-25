function OnGlobalMessage(self, message, object)
	if message == "CED_CancelBuildable" then
		self.ToDelete = true;
	elseif message == "CED_AddBuildPoints" then
		self.buildPoints = self.buildPoints + object;
	end
end

function OnMessage(self, message, object)
	if message == "CED_CancelBuildable" then
		self.ToDelete = true;
	elseif message == "CED_AddBuildPoints" then
		self.buildPoints = self.buildPoints + object;
	end
end

function Create(self)
	self.buildPointRequirement = self:NumberValueExists("BuildPointRequirement") and self:GetNumberValue("BuildPointRequirement") or 100;

	if self:NumberValueExists("buildPoints") then
		self.buildPoints = self:GetNumberValue("buildPoints");
		self:RemoveNumberValue("buildPoints");
	else
		self.buildPoints = 0;
	end

	self.Team = self:NumberValueExists("CED_BuildableTeam") and self:GetNumberValue("CED_BuildableTeam") or -1;
	
	self.Activity = ToGameActivity(ActivityMan:GetActivity());
	self.Scene = SceneMan.Scene;
	
	self.autoBuild = self:GetNumberValue("AutoBuild") == 1 and true or false;
	self.autoBuildRate = self:NumberValueExists("AutoBuildRate") and self:GetNumberValue("AutoBuildRate") or 10;
	
	self.autoBuildTimer = Timer();
	self.autoBuildDelay = 1000;
end

function ThreadedUpdate(self)
	if self.autoBuild then
		if self.autoBuildTimer:IsPastSimMS(self.autoBuildDelay) then
			self.buildPoints = self.buildPoints + self.autoBuildRate
			self.autoBuildTimer:Reset();
		end
	end
		
	if self.buildPoints >= self.buildPointRequirement then
		print("Buildable built!");
		self:RequestSyncedUpdate();
	end
	
	PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(0, -100), self.buildPoints, true, 1);
	PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(0, -80), self.buildPointRequirement, true, 1);
end

function SyncedUpdate(self)

end

function OnSave(self)
	self:SetNumberValue("buildPoints", self.buildPoints);
end