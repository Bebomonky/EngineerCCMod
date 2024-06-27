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
	
	local createFunc = "Create" .. self:GetStringValue("ChunkClassName");
	
	self.Chunks = {};
	for i = 1, self:GetNumberValue("ChunkCount") do
		self.Chunks[i] = {};
		self.Chunks[i].Chunk = _G[createFunc](self:GetStringValue("ChunkPresetName") .. " " .. i , self:GetStringValue("ChunkTechName"));
		self.Chunks[i].Built = false;
	end
		
	self.chunkThreshold = self.buildPointRequirement / #self.Chunks;

	if self:NumberValueExists("buildPoints") then
		self.buildPoints = self:GetNumberValue("buildPoints");
		self:RemoveNumberValue("buildPoints");
	else
		self.buildPoints = 0;
	end

	self.Team = self:NumberValueExists("CED_BuildableTeam") and self:GetNumberValue("CED_BuildableTeam") or self.Team;
	
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
	
	for i = 1, #self.Chunks do
		if self.buildPoints >= self.chunkThreshold * i then
			self:RequestSyncedUpdate();
			-- we'll loop again and spawn all chunks in case we're actually past the threshold of multiple of them in SyncedUpdate
			break;
		end
	end
	
	PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(0, -100), tostring(self.buildPoints), true, 1);
	PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(0, -80), tostring(self.buildPointRequirement), true, 1);
end

function SyncedUpdate(self)
	for i = 1, #self.Chunks do
		if self.buildPoints >= self.chunkThreshold * i and not self.Chunks[i].Built then
			self.Chunks[i].Built = true
			self.Chunks[i].Chunk.Pos = self.Pos;
			self.Chunks[i].Chunk.Team = -1;
			self.Chunks[i].Chunk.HFlipped = self.HFlipped;
			MovableMan:AddParticle(self.Chunks[i].Chunk);
			self.Chunks[i].Chunk.ToSettle = true
		end
	end

	if self.buildPoints >= self.buildPointRequirement then
		self.ToDelete = true;
	end
end

function OnSave(self)
	self:SetNumberValue("buildPoints", self.buildPoints);
end