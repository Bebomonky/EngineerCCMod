function Create(self)
	self.AttachmentPositions = {};
	
	--------------------------------------------------
	
	local i = 1;
	self.AttachmentPositions[i] = {};
	self.AttachmentPositions[i].Name = "UGL";
	self.AttachmentPositions[i].PositionOnGun = Vector(5, 2);
	self.AttachmentPositions[i].MenuPosition = Vector(50, -20);
	self.AttachmentPositions[i].Attachments = {};
	
	local iAtt = 1;
	self.AttachmentPositions[i].Attachments[iAtt] = {};
	self.AttachmentPositions[i].Attachments[iAtt].Name = "Ammo Pack";
	self.AttachmentPositions[i].Attachments[iAtt].InternalName = "GLAmmo";
	self.AttachmentPositions[i].Attachments[iAtt].Description = "A lifetime supply of Spitback rounds for the underbarrel launcher.";
	self.AttachmentPositions[i].Attachments[iAtt].IconPath = "CED.rte/Devices/Weapons/Handheld/Kh11p35/GLAmmoIcon.png";
	self.AttachmentPositions[i].Attachments[iAtt].IconSize = Vector(5, 4);
	self.AttachmentPositions[i].Attachments[iAtt].DefaultOwned = false;
	self.AttachmentPositions[i].Attachments[iAtt].DefaultEquipped = false;
	self.AttachmentPositions[i].Attachments[iAtt].Owned = false;
	self.AttachmentPositions[i].Attachments[iAtt].Equipped = false;	
	self.AttachmentPositions[i].Attachments[iAtt].Cost = 65;
	
	--------------------------------------------------
	
	i = i + 1;
	self.AttachmentPositions[i] = {};
	self.AttachmentPositions[i].Name = "Sights";
	self.AttachmentPositions[i].PositionOnGun = Vector(0, -2);
	self.AttachmentPositions[i].MenuPosition = Vector(10, -50);
	self.AttachmentPositions[i].Attachments = {};
	
	iAtt = 1;
	self.AttachmentPositions[i].Attachments[iAtt] = {};
	self.AttachmentPositions[i].Attachments[iAtt].Name = "Iron Sights";
	self.AttachmentPositions[i].Attachments[iAtt].InternalName = "IronSights";
	self.AttachmentPositions[i].Attachments[iAtt].Description = "Basic iron sights.";
	self.AttachmentPositions[i].Attachments[iAtt].IconPath = "CED.rte/Devices/Weapons/Handheld/Kh11p35/IronSightsIcon.png";
	self.AttachmentPositions[i].Attachments[iAtt].IconSize = Vector(5, 4);
	self.AttachmentPositions[i].Attachments[iAtt].DefaultOwned = true;
	self.AttachmentPositions[i].Attachments[iAtt].DefaultEquipped = true;
	self.AttachmentPositions[i].Attachments[iAtt].Owned = false;
	self.AttachmentPositions[i].Attachments[iAtt].Equipped = false;	
	self.AttachmentPositions[i].Attachments[iAtt].Cost = 0;
	
	iAtt = iAtt + 1;
	self.AttachmentPositions[i].Attachments[iAtt] = {};
	self.AttachmentPositions[i].Attachments[iAtt].Name = "Reflex Sight";
	self.AttachmentPositions[i].Attachments[iAtt].InternalName = "ReflexSight";
	self.AttachmentPositions[i].Attachments[iAtt].Description = "A decent reflex sight. Improves sighting range and recoil recovery.";
	self.AttachmentPositions[i].Attachments[iAtt].IconPath = "CED.rte/Devices/Weapons/Handheld/Kh11p35/ReflexSightIcon.png";
	self.AttachmentPositions[i].Attachments[iAtt].IconSize = Vector(5, 4);
	self.AttachmentPositions[i].Attachments[iAtt].DefaultOwned = false;
	self.AttachmentPositions[i].Attachments[iAtt].DefaultEquipped = false;
	self.AttachmentPositions[i].Attachments[iAtt].Owned = false;
	self.AttachmentPositions[i].Attachments[iAtt].Equipped = false;	
	self.AttachmentPositions[i].Attachments[iAtt].Cost = 5;	
	
	--------------------------------------------------
	
end