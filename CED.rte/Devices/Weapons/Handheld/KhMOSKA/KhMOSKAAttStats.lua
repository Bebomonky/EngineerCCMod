function Create(self)
	self.AttachmentPositions = {};
	
	--------------------------------------------------
	
	local i = 1;
	self.AttachmentPositions[i] = {};
	self.AttachmentPositions[i].Name = "Ammo";
	self.AttachmentPositions[i].PositionOnGun = Vector(-2, 0);
	self.AttachmentPositions[i].MenuPosition = Vector(-50, -100);
	self.AttachmentPositions[i].Attachments = {};
	
	local iAtt = 1;
	self.AttachmentPositions[i].Attachments[iAtt] = {};
	self.AttachmentPositions[i].Attachments[iAtt].Name = "Normal Rounds";
	self.AttachmentPositions[i].Attachments[iAtt].InternalName = "NormalRounds";
	self.AttachmentPositions[i].Attachments[iAtt].Description = "Normal operation with normal rounds.";
	self.AttachmentPositions[i].Attachments[iAtt].IconPath = "CED.rte/Devices/Weapons/Handheld/Kh11p35/FullAutoIcon.png";
	self.AttachmentPositions[i].Attachments[iAtt].IconSize = Vector(26, 26);
	self.AttachmentPositions[i].Attachments[iAtt].DefaultOwned = true;
	self.AttachmentPositions[i].Attachments[iAtt].DefaultEquipped = true;
	self.AttachmentPositions[i].Attachments[iAtt].Owned = true;
	self.AttachmentPositions[i].Attachments[iAtt].Equipped = true;	
	self.AttachmentPositions[i].Attachments[iAtt].Cost = 0;
	self.AttachmentPositions[i].Attachments[iAtt].CustomEquipSound = nil;
	
	iAtt = iAtt + 1;
	self.AttachmentPositions[i].Attachments[iAtt] = {};
	self.AttachmentPositions[i].Attachments[iAtt].Name = "R-Bullet";
	self.AttachmentPositions[i].Attachments[iAtt].InternalName = "RBullet";
	self.AttachmentPositions[i].Attachments[iAtt].Description = "Load one R-Bullet at a time. R-Bullets are faster and stronger.";
	self.AttachmentPositions[i].Attachments[iAtt].IconPath = "CED.rte/Devices/Weapons/Handheld/Kh11p35/SemiAutoIcon.png";
	self.AttachmentPositions[i].Attachments[iAtt].IconSize = Vector(26, 26);
	self.AttachmentPositions[i].Attachments[iAtt].DefaultOwned = true;
	self.AttachmentPositions[i].Attachments[iAtt].DefaultEquipped = false;
	self.AttachmentPositions[i].Attachments[iAtt].Owned = true;
	self.AttachmentPositions[i].Attachments[iAtt].Equipped = false;	
	self.AttachmentPositions[i].Attachments[iAtt].Cost = 5;
	self.AttachmentPositions[i].Attachments[iAtt].CustomEquipSound = nil;
	
	--------------------------------------------------
	
	i = i + 1;
	self.AttachmentPositions[i] = {};
	self.AttachmentPositions[i].Name = "Action";
	self.AttachmentPositions[i].PositionOnGun = Vector(5, 2);
	self.AttachmentPositions[i].MenuPosition = Vector(50, -100);
	self.AttachmentPositions[i].Attachments = {};
	
	iAtt = 1;
	self.AttachmentPositions[i].Attachments[iAtt] = {};
	self.AttachmentPositions[i].Attachments[iAtt].Name = "Machined Bolt";
	self.AttachmentPositions[i].Attachments[iAtt].InternalName = "MachinedBolt";
	self.AttachmentPositions[i].Attachments[iAtt].Description = "A high-quality bolt. Faster to work.";
	self.AttachmentPositions[i].Attachments[iAtt].IconPath = "CED.rte/Devices/Weapons/Handheld/Kh11p35/GLAmmoIcon.png";
	self.AttachmentPositions[i].Attachments[iAtt].IconSize = Vector(26, 26);
	self.AttachmentPositions[i].Attachments[iAtt].DefaultOwned = false;
	self.AttachmentPositions[i].Attachments[iAtt].DefaultEquipped = false;
	self.AttachmentPositions[i].Attachments[iAtt].Owned = false;
	self.AttachmentPositions[i].Attachments[iAtt].Equipped = false;	
	self.AttachmentPositions[i].Attachments[iAtt].Cost = 5;	
	
	--------------------------------------------------
	
end