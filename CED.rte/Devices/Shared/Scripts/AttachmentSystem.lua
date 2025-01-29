require("Mods.Extensions.ExtensionMan");
require("MasterList");

function Create(self)
	self.Menu = table.Copy(require("Mods.Extensions.imenu.core"));
	self.Menu:Initialize();

	self.sounds = {
		Confirm = CreateSoundContainer("Confirm", "Base.rte"),
		Deselect = CreateSoundContainer("Confirm", "Base.rte"),
		Error = CreateSoundContainer("Error", "Base.rte"),
	};

	self.Activity = ActivityMan:GetActivity();
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

function AttMenu(self)

	-- Amount of items per row
	local perRow = 5;
	-- Distance between buttons
	local buttonDist = Vector(50, 60);
	
	local buttonPos = Vector(5, 5);

	self.tabs = {};
	local buttons = {};
	
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

			local iconPath = item.IconPath;
			if not iconPath or iconPath == "" then
				button:SetText("NO ICON");
			else
				button:SetText(item.Name);
			end

			button.Think = function()
				local world_pos = button:GetAbsolutePos();

				if button:IsHovered() then
					if button.Selected then
						button:Color(146);
						button:OutlineColor(71);
					end
					button:OutlineColor(117);
				else
					if button.Selected then
						button:Color(146);
						button:OutlineColor(71);
					else
						button:Color(144);
						button:OutlineColor(146);
					end
				end

				if iconPath and iconPath ~= "" then
					PrimitiveMan:DrawBitmapPrimitive(self.Menu.Screen, world_pos + button:GetSize() / 2, iconPath, 0);
				end
			end

			button.OnPress = function(key)
				if key == Controller.PRIMARY_ACTION then
					if button.Selected == false then
						self.sounds.Confirm:Play(-1);
						for _, btn in ipairs(tab.Buttons) do
							btn.Selected = false;
						end
						button.Selected = true;
					else
						button.Selected = false;
						self.sounds.Deselect:Play(-1);
					end
				end
			end
			table.insert(tab.Buttons, button);
		end
	end
end

function ThreadedUpdate(self)
	if self.parent then
		if self.parent:IsPlayerControlled() then
			if self.parentController:IsState(Controller.WEAPON_AUXILIARY_HOTKEYSTART) and self.Menu:ToOpen(self.parent, Controller.CIM_DISABLED) then
				AttMenu(self);
			end
		end
		if self.Menu:Update() then
			for i = 1, #self.tabs do
				self.tabs[i]:Update();
			end
			self.Menu:DrawCursor();
		end
	end
end