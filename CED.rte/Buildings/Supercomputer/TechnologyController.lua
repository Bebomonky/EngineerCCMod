function OnGlobalMessage(self, message, object)
	if message == "CED_UnlockTechnology" then
		self.Technologies[object] = true;
	end
end

function OnMessage(self, message, object)
	if message == "CED_UnlockTechnology" then
		self.Technologies[object] = true;
	end
end

function Create(self)
	self.Activity = ActivityMan:GetActivity();
	
	self.fixedTeam = self.Team;
	
	self.saveLoadHandler = require("Activities/Utility/SaveLoadHandler");
	self.saveLoadHandler:Initialize(false);
	
	if self:StringValueExists("CEDUnlockedTechnologies") then
		self.Technologies = self.saveLoadHandler:DeserializeTable(self:GetStringValue("CEDUnlockedTechnologies"), "CEDUnlockedTechnologies");
		self:RemoveStringValue("CEDUnlockedTechnologies");
	else
		self.Technologies = {};
	end
end

function ThreadedUpdate(self)
	self.ToSettle = false;
	self.ToDelete = false;
	
	-- Prevent any team-switching shenanigans
	if self.Team ~= self.fixedTeam then
		self.Team = self.fixedTeam;
	end
end

function Destroy(self)
	print("CED Technology Controller destroyed. If this happened outside of leaving an activity, something went wrong.");
end

function OnSave(self)
	self:SetStringValue("CEDUnlockedTechnologies", self.saveLoadHandler:SerializeTable(self.Technologies));
end