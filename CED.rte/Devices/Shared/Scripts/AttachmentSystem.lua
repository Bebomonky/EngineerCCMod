require("Mods.Extensions.ExtensionMan");
require("MasterList");

function Create(self)
	self.Menu = table.Copy(require("Mods.Extensions.imenu.core"));
	self.Menu:Initialize();

	self.sounds = {
		GenericEquip = CreateSoundContainer("CED Generic Attachment Equip", "CED.rte"),
		Deselect = CreateSoundContainer("Confirm", "Base.rte"),
		Error = CreateSoundContainer("Error", "Base.rte"),
	};

	self.Activity = ActivityMan:GetActivity();
	for i = 1, #self.AttachmentPositions do
		local att_stat = self.AttachmentPositions[i];
		local attachements = att_stat.Attachments;
		for ii = 1, #attachements do
			local item = attachements[ii];
			if item.DefaultOwned == true then
				local triumvirateAttOwned = "TriumvirateAtt_" .. item.InternalName .. "_Owned";
				self:SetNumberValue(triumvirateAttOwned, 1);
			end
			if item.DefaultEquipped == true then
				local triumvirateAttEquipped = "TriumvirateAtt_" .. item.InternalName .. "_Equipped";
				self:SetNumberValue(triumvirateAttEquipped, 1);
				self:SendMessage("TriumvirateAtt_Update");
			end
		end
	end
end

function itemDescription(desc, isSmall, panelWidth)
	if desc == nil or desc == "" then
		desc = "Description not set";
	end
	local newDesc = "";
	local line = "";
	local longestWord = "";
	for word in string.gmatch(desc, "%S+") do
		local newLine = line .. (line ~= "" and " " or "") .. word;
		local descWidth = FrameMan:CalculateTextWidth(newLine, isSmall) + 8;
		if descWidth > panelWidth then
			if line ~= "" then
				newDesc = newDesc .. line .. "\n";
			end
			line = word;
		else
			line = newLine;
		end
		if #word > #longestWord then
			longestWord = word;
		end
	end
	if line ~= "" then
		newDesc = newDesc .. line;
	end

	local descHeight = FrameMan:CalculateTextHeight(newDesc, 0, isSmall) + 25;
	return newDesc, descHeight, longestWord;
end

function CC_TooltipSkin(parent, new)
	new = new or false;
	local w = parent:GetWidth();
	local h = parent:GetHeight();
	local outlines = {
		{ Vector(w + 1, 0), Vector(1, h + 2), false, 21 },
		{ Vector(0, h + 1), Vector(w + 2, 1), false, 21 },
		{ Vector(0, 0),     Vector(1, h),     true,  21 },
		{ Vector(0, 0),     Vector(w, 1),     true,  21 },
		{ Vector(w - 1, 1), Vector(1, h - 1), true,  59 },
		{ Vector(1, h - 1), Vector(w - 1, 1), true,  59 },
	};
	if new then
		parent:Color(93);
		parent:OutlineColor(70);
		parent:OutlineThickness(1);
		for i = 1, #outlines do
			local drawAfterParent = outlines[i][3];
			local color = outlines[i][4];
			local line = {};
			line._name = "CC_TOOLTIPSKIN";
			line._drawAfterParent = drawAfterParent;
			line._x, line._y = 0, 0;
			line._w, line._h = 0, 0;

			function line:SetPos(x, y)
				self._x, self._y = parent._x + x, parent._y + y;
			end

			function line:GetAbsolutePos()
				return Vector(self._x, self._y) + CameraMan:GetOffset(parent._screen);
			end

			function line:SetSize(w, h)
				self._w, self._h = w, h;
			end

			function line:GetSize()
				return Vector(self._w, self._h);
			end

			function line:Update()

				local world_pos = self:GetAbsolutePos();
				local size = self:GetSize() - Vector(1, 1);
				if math.min(size.X, size.Y) >= 0 then
					PrimitiveMan:DrawLinePrimitive(parent._screen, world_pos, world_pos + size, color, 1);
				end
			end

			table.insert(parent:GetChildren(), line);
		end
		return;
	end

	for i, panel in pairs(parent:GetChildren()) do
		if panel._name == "CC_TOOLTIPSKIN" then
			local pos = outlines[i][1];
			local size = outlines[i][2];
			panel:SetPos(pos.X, pos.Y);
			panel:SetSize(size.X, size.Y);
		end
	end
end

function CC_TooltipSkin(parent, new)
	new = new or false;
	local w = parent:GetWidth();
	local h = parent:GetHeight();
	local outlines = {
		{ Vector(w + 1, 0), Vector(1, h + 2), false, 21 },
		{ Vector(0, h + 1), Vector(w + 2, 1), false, 21 },
		{ Vector(0, 0),     Vector(1, h),     true,  21 },
		{ Vector(0, 0),     Vector(w, 1),     true,  21 },
		{ Vector(w - 1, 1), Vector(1, h - 1), true,  59 },
		{ Vector(1, h - 1), Vector(w - 1, 1), true,  59 },
	};
	if new then
		parent:Color(93);
		parent:OutlineColor(70);
		parent:OutlineThickness(1);
		for i = 1, #outlines do
			local drawAfterParent = outlines[i][3];
			local color = outlines[i][4];
			local line = {};
			line._name = "CC_TOOLTIPSKIN";
			line._drawAfterParent = drawAfterParent;
			line._x, line._y = 0, 0;
			line._w, line._h = 0, 0;

			function line:SetPos(x, y)
				self._x, self._y = parent._x + x, parent._y + y;
			end

			function line:GetAbsolutePos()
				return Vector(self._x, self._y) + CameraMan:GetOffset(parent._screen);
			end

			function line:SetSize(w, h)
				self._w, self._h = w, h;
			end

			function line:GetSize()
				return Vector(self._w, self._h);
			end

			function line:Update()

				local world_pos = self:GetAbsolutePos();
				local size = self:GetSize() - Vector(1, 1);
				if math.min(size.X, size.Y) >= 0 then
					PrimitiveMan:DrawLinePrimitive(parent._screen, world_pos, world_pos + size, color, 1);
				end
			end

			table.insert(parent:GetChildren(), line);
		end
		return;
	end

	for i, panel in pairs(parent:GetChildren()) do
		if panel._name == "CC_TOOLTIPSKIN" then
			local pos = outlines[i][1];
			local size = outlines[i][2];
			panel:SetPos(pos.X, pos.Y);
			panel:SetSize(size.X, size.Y);
		end
	end
end

function DisplayNumber(screen, vector, txt, isSmall, color)
	local x = 0;
	for i = 1, #txt do
		local char = txt:sub(i, i);
		local spriteWidth = char == "1" and (isSmall and 3 or 4) or (isSmall and 4 or 6);
		local pos = vector + Vector(x + spriteWidth / 2, isSmall and 5 or 8);
		local size = isSmall and "Small" or "Big";
		local path = "CED.rte/Effects/Font/" .. color .. "/Numbers/" .. size .. "/" .. char .. ".png";
		x = x + spriteWidth;
		if tonumber(char) ~= nil then
			PrimitiveMan:DrawBitmapPrimitive(screen, pos, path, 0);
		else
			PrimitiveMan:DrawTextPrimitive(screen, pos - Vector(2, 8), tostring(char), isSmall, 0);
		end
	end
end

function AttMenu(self)

	-- Amount of items per row
	local perRow = 5;
	-- Distance between buttons
	local buttonDist = Vector(50, 60);
	
	local buttonPos = Vector(5, 5);

	self.tabs = {};
	self.buttons = {};

	-- Tooltip when hovering over elements
	self.tooltip = self.Menu:CreateGUI("COLLECTIONBOX");
	self.tooltip:SetTitle("");
	self.tooltip:SetHide(true);
	self.tooltip:SetSize(125, 12);
	CC_TooltipSkin(self.tooltip, true);
	self.tooltip.Think = function()
		self.tooltip:SetHide(true);
	end

	local tooltipDesc = self.Menu:CreateGUI("LABEL", self.tooltip);
	tooltipDesc:SetSmallText(true);
	tooltipDesc:SetContentAlignment(5);

	-- Update the tooltip when just hovering over something
	self.tooltip.UpdateTooltip = function(button, x, y)
		local pos = button:GetRelativePos();
		local isSmall = false;

		local tooltipWidth = self.tooltip:GetWidth();
		local desc, descHeight = itemDescription(button.Item.Description, true, tooltipWidth);

		self.tooltip:SetPos(pos.X + x, pos.Y + y);
		--self.tooltip:SetSize(textWidth + 5, 12);
		self.tooltip:SetSize(125, descHeight);

		tooltipDesc:SetSize(tooltipWidth, descHeight);
		tooltipDesc:SetText(desc);
		tooltipDesc:SetPos(3, 3);

		CC_TooltipSkin(self.tooltip);
	end
	
	for i = 1, #self.AttachmentPositions do
		local att_stat = self.AttachmentPositions[i];
		local attachements = att_stat.Attachments;
		local tab = self.Menu:CreateGUI("COLLECTIONBOX");
		tab:SetTitle("");
		local pos = Vector(500 + att_stat.MenuPosition.X, 250 + att_stat.MenuPosition.Y);
		tab:SetPos(pos.X, pos.Y);
		tab:SetSize(#attachements * 26, 15);
		tab.Buttons = {};
		table.insert(self.tabs, tab);

		local label = self.Menu:CreateGUI("LABEL", tab);
		label:SetPos(0, -1);
		label:SetSmallText(false);
		label:SetText(att_stat.Name);
		label:SetSize(label:GetParent():GetWidth(), label:GetParent():GetHeight());
		label:SetContentAlignment(5);

		for i = 1, #attachements do
			local item = attachements[i];

			local pos = buttonPos;
			local row = math.floor((i - 1) / perRow);
			local j = ((i - 1) % perRow);
			pos = pos + Vector(j * buttonDist.X, row * buttonDist.Y);

			local button = self.Menu:CreateGUI("BUTTON", tab, "ATTACHABLE");
			button:SetPos(pos.X - 5, pos.Y + 15);
			button:SetSize(26, 26);
			button:SetTextPos(1, 20);
			button:Color(146);
			button:OutlineColor(144);
			button:OutlineThickness(2);
			button.Selected = false;
			button.JustHovered = false;
			button.Item = item;

			local iconPath = button.Item.IconPath;
			if not iconPath or iconPath == "" then
				button:SetText("NO ICON");
			else
				button:SetText(button.Item.Name);
			end

			if button.Item.Equipped then
				button.Selected = true;
			end

			button.Think = function()
				local world_pos = button:GetAbsolutePos();

				if button:IsHovered() then
					self.tooltip:SetHide(false);
					if button.Selected then
						button:Color(146);
						button:OutlineColor(71);
					end
					button:OutlineColor(117);
					if button.JustHovered == false then
						self.tooltip.UpdateTooltip(button, 30, 15);
						button.JustHovered = true;
					end
				else
					if button.Selected then
						button:Color(146);
						button:OutlineColor(71);
					else
						button:Color(144);
						button:OutlineColor(146);
					end
					button.JustHovered = false;
				end

				if iconPath and iconPath ~= "" then
					PrimitiveMan:DrawBitmapPrimitive(self.Menu.Screen, world_pos + button:GetSize() / 2, iconPath, 0);
				end
			end

			button.OnPress = function(key)
				if key == Controller.PRIMARY_ACTION then
					local hasFund = self.Activity:GetTeamFunds(self.parent.Team) >= button.Item.Cost;
					local triumvirateAttOwned = "TriumvirateAtt_" .. button.Item.InternalName .. "_Owned";
					local triumvirateAttEquipped = "TriumvirateAtt_" .. button.Item.InternalName .. "_Equipped";
					local isOwned = self:NumberValueExists(triumvirateAttOwned) and self:GetNumberValue(triumvirateAttOwned) or 0;

					local function unequipOtherItem()
						for _, otherButton in ipairs(tab.Buttons) do
							if otherButton ~= button then
								local otherTriumvirateAttEquipped = "TriumvirateAtt_" .. otherButton.Item.InternalName .. "_Equipped";
								self:SetNumberValue(otherTriumvirateAttEquipped, 0);
								otherButton.Item.Equipped = false;
								otherButton.Selected = false;
							end
						end
						self:SetNumberValue(triumvirateAttEquipped, 1);
						self:SendMessage("TriumvirateAtt_Update");
					end

					if isOwned == 1 then
						button.Item.Equipped = not button.Item.Equipped;
						button.Selected = not button.Selected;
						if button.Selected then
							if button.Item.CustomEquipSound then
								button.Item.CustomEquipSound:Play(self.Pos);
							else
								self.sounds.GenericEquip:Play(self.Pos);
							end
							unequipOtherItem();
						else
							self:SetNumberValue(triumvirateAttEquipped, 0);
							self.sounds.Deselect:Play(self.Pos);
						end
					else
						if hasFund == true then
							self:SetNumberValue(triumvirateAttOwned, 1);
							button.Item.Equipped = true;
							button.Selected = true;
							if button.Item.CustomEquipSound then
								button.Item.CustomEquipSound:Play(self.Pos);
							else
								self.sounds.GenericEquip:Play(self.Pos);
							end
							self.Activity:ChangeTeamFunds(self.parent.Team - button.Item.Cost, self.parent.Team);
							unequipOtherItem();
						else
							self.sounds.Error:Play(self.Pos);
						end
					end
				end
			end
			table.insert(tab.Buttons, button);
			table.insert(self.buttons, button)
		end
	end
end

function ThreadedUpdate(self)
	if self.parent then
		if self.parent:IsPlayerControlled() then
			if self.parentController:IsState(Controller.WEAPON_AUXILIARY_HOTKEYSTART) and self.Menu:ToOpen(self.parent, Controller.CIM_DISABLED) then
				AttMenu(self);
				--? The ControlState for the parent keeps going forever for some reason, so we set it to false for safety reasons I guess
				self.parentController:SetState(Controller.WEAPON_AUXILIARY_HOTKEYSTART, false);
				--? Set it to false regardless so that it doesn't count as soon as we open the menu
				self.Menu.Controller:SetState(Controller.WEAPON_AUXILIARY_HOTKEYSTART, false);
			end
		end
		if self.Menu:Update() then
			for i = 1, #self.tabs do
				self.tabs[i]:Update();
			end
			if self.tooltip:GetHide() == false then
				self.tooltip:Update();
				for i = 1, #self.buttons do
					local button = self.buttons[i];
					if button:IsHovered() then
						local world_pos = self.tooltip:GetAbsolutePos();
						local hasFund = self.Activity:GetTeamFunds(self.parent.Team) >= button.Item.Cost;
						local color = hasFund and "Green" or "Red";
						local triumvirateAttOwned = "TriumvirateAtt_" .. button.Item.InternalName .. "_Owned";
						local isOwned = self:NumberValueExists(triumvirateAttOwned) and self:GetNumberValue(triumvirateAttOwned) or 0;
						local isSmall = false;
						local pos = world_pos + Vector(2, -1);
						if isOwned == 1 then
							PrimitiveMan:DrawTextPrimitive(self.Menu.Screen, pos, "OWNED", isSmall, 0);
						else
							local textWidth = FrameMan:CalculateTextWidth("Cost: ", isSmall);
							PrimitiveMan:DrawTextPrimitive(self.Menu.Screen, pos, "Cost: ", isSmall, 0);
							if button.Item.Cost > 0 then
								DisplayNumber(self.Menu.Screen, pos + Vector(textWidth, 0), tostring(button.Item.Cost), isSmall, color);
							else
								PrimitiveMan:DrawTextPrimitive(self.Menu.Screen, pos + Vector(textWidth, 0), "FREE", isSmall, 0);
							end
						end
					end
				end
			end
			-- Pressing the same hotkey will close the menu
			if self.Menu.Controller and self.Menu.Controller:IsState(Controller.WEAPON_AUXILIARY_HOTKEYSTART) then
				self.Menu:Remove();
			end
			self.Menu:DrawCursor();
		end
	end
end