function Create(self)
	self.AttachmentPositions = {};
	
	--------------------------------------------------
	
	local i = 1;
	self.AttachmentPositions[i] = {};
	self.AttachmentPositions[i].Name = "Fire Mode";
	self.AttachmentPositions[i].PositionOnGun = Vector(-2, 0);
	self.AttachmentPositions[i].MenuPosition = Vector(-100, -30);
	self.AttachmentPositions[i].Attachments = {};
	
	local iAtt = 1;
	self.AttachmentPositions[i].Attachments[iAtt] = {};
	self.AttachmentPositions[i].Attachments[iAtt].Name = "Semi-Auto";
	self.AttachmentPositions[i].Attachments[iAtt].InternalName = "SemiAuto";
	self.AttachmentPositions[i].Attachments[iAtt].Description = "Semi-automatic. Engages propellant fully.";
	self.AttachmentPositions[i].Attachments[iAtt].IconPath = "CED.rte/Devices/Weapons/Handheld/Kh11p35/SemiAutoIcon.png";
	self.AttachmentPositions[i].Attachments[iAtt].IconSize = Vector(26, 26);
	self.AttachmentPositions[i].Attachments[iAtt].DefaultOwned = true;
	self.AttachmentPositions[i].Attachments[iAtt].DefaultEquipped = true;
	self.AttachmentPositions[i].Attachments[iAtt].Owned = true;
	self.AttachmentPositions[i].Attachments[iAtt].Equipped = true;	
	self.AttachmentPositions[i].Attachments[iAtt].Cost = 0;
	self.AttachmentPositions[i].Attachments[iAtt].CustomEquipSound = CreateSoundContainer("Switch Single CED Vossberg UX-Rage", "CED.rte");
	
	iAtt = iAtt + 1;
	self.AttachmentPositions[i].Attachments[iAtt] = {};
	self.AttachmentPositions[i].Attachments[iAtt].Name = "Full-Auto";
	self.AttachmentPositions[i].Attachments[iAtt].InternalName = "FullAuto";
	self.AttachmentPositions[i].Attachments[iAtt].Description = "Fully-automatic. Engages propellant partially.";
	self.AttachmentPositions[i].Attachments[iAtt].IconPath = "CED.rte/Devices/Weapons/Handheld/Kh11p35/FullAutoIcon.png";
	self.AttachmentPositions[i].Attachments[iAtt].IconSize = Vector(26, 26);
	self.AttachmentPositions[i].Attachments[iAtt].DefaultOwned = true;
	self.AttachmentPositions[i].Attachments[iAtt].DefaultEquipped = false;
	self.AttachmentPositions[i].Attachments[iAtt].Owned = true;
	self.AttachmentPositions[i].Attachments[iAtt].Equipped = false;	
	self.AttachmentPositions[i].Attachments[iAtt].Cost = 0;
	self.AttachmentPositions[i].Attachments[iAtt].CustomEquipSound = CreateSoundContainer("Switch Auto CED Vossberg UX-Rage", "CED.rte");
	
	--------------------------------------------------	
	
end