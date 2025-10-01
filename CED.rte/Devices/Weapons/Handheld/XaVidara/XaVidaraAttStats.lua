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
	self.AttachmentPositions[i].Attachments[iAtt].Name = "Focused";
	self.AttachmentPositions[i].Attachments[iAtt].InternalName = "FocusedMode";
	self.AttachmentPositions[i].Attachments[iAtt].Description = "Focused laser. Very accurate.";
	self.AttachmentPositions[i].Attachments[iAtt].IconPath = "CED.rte/Devices/Weapons/Handheld/Kh11p35/FullAutoIcon.png";
	self.AttachmentPositions[i].Attachments[iAtt].IconSize = Vector(26, 26);
	self.AttachmentPositions[i].Attachments[iAtt].DefaultOwned = true;
	self.AttachmentPositions[i].Attachments[iAtt].DefaultEquipped = true;
	self.AttachmentPositions[i].Attachments[iAtt].Owned = true;
	self.AttachmentPositions[i].Attachments[iAtt].Equipped = true;	
	self.AttachmentPositions[i].Attachments[iAtt].Cost = 0;
	self.AttachmentPositions[i].Attachments[iAtt].CustomEquipSound = CreateSoundContainer("Switch Rifle CED Xarix Vidara", "CED.rte");
	
	iAtt = iAtt + 1;
	self.AttachmentPositions[i].Attachments[iAtt] = {};
	self.AttachmentPositions[i].Attachments[iAtt].Name = "Scatter";
	self.AttachmentPositions[i].Attachments[iAtt].InternalName = "ScatterMode";
	self.AttachmentPositions[i].Attachments[iAtt].Description = "Scattered lasers. More total power, but inaccurate.";
	self.AttachmentPositions[i].Attachments[iAtt].IconPath = "CED.rte/Devices/Weapons/Handheld/Kh11p35/SemiAutoIcon.png";
	self.AttachmentPositions[i].Attachments[iAtt].IconSize = Vector(26, 26);
	self.AttachmentPositions[i].Attachments[iAtt].DefaultOwned = true;
	self.AttachmentPositions[i].Attachments[iAtt].DefaultEquipped = false;
	self.AttachmentPositions[i].Attachments[iAtt].Owned = true;
	self.AttachmentPositions[i].Attachments[iAtt].Equipped = false;	
	self.AttachmentPositions[i].Attachments[iAtt].Cost = 0;
	self.AttachmentPositions[i].Attachments[iAtt].CustomEquipSound = CreateSoundContainer("Switch Shotgun CED Xarix Vidara", "CED.rte");
	
	--------------------------------------------------	
	
end