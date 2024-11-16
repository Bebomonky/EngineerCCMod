require("Mods.Extensions.ExtensionMan");

function OnGlobalMessage(self, message, object)
	if message == "CED_UnlockResearch" then
		self.UnlockedResearches[object] = true;
	end
end

function OnMessage(self, message, research)
	if message == "CED_UnlockResearch" then
		self.UnlockedResearches[object] = true;
	end
end

function Create(self)
	self.Menu = table.Copy(require("Mods.Extensions.imenu.core"));
	self.Menu:Initialize();
	self.menuCreated = false;

	self.sounds = {
		Confirm = CreateSoundContainer("Confirm", "Base.rte"),
		Deselect = CreateSoundContainer("Confirm", "Base.rte"),
		Error = CreateSoundContainer("Error", "Base.rte"),
	};

	if not self.PieMenu:GetFirstPieSliceByPresetName("BuilderMenu") then
		self.PieMenu:AddPieSlice(CreatePieSlice("BuilderMenu", "CED.rte"), self);
	end

	self.selectDelayTime = Timer();

	self.UnlockedResearches = {};

	local defaultUnlockResearch = {
		"CEDLogo",
		"PlinkTurret",
		"Behemoth",
		"Coagulator",
		"Supercomputer"
	};

	for _, tech in pairs(defaultUnlockResearch) do
		self.UnlockedResearches[tech] = true;
	end

	self.Activity = ActivityMan:GetActivity();

	self.menuData = {};
	for catID, data in pairs(self.CEDAvailableBuildables) do
		self.menuData[catID] = {
			ToScroll = false;
			Items = {},
			Buttons = {}
		};

		for i, item in pairs(data) do
			table.insert(self.menuData[catID].Items, item);
		end
	end

	self.menuHistory = {};
	self.MenuCurrent = nil;

	function self:MenuChange(newMenu, addToHistory)
		if addToHistory == nil or addToHistory == true then
			table.insert(self.menuHistory, self.MenuCurrent);
		end

		self.Menu.Cursor_Bitmap = "Data/Base.rte/GUIs/Skins/Cursor.png";
		self.cancelButton.IsRemoving = false;

		-- Set all previous buttons visibility to false
		if self.MenuCurrent then
			for i, button in ipairs(self.MenuCurrent.Buttons) do
				if button:GetName() == "Buildable" then
					button.Selected = false;
				end
				button:SetVisible(false);
			end
		end

		self.MenuCurrent = newMenu;

		-- Set all new buttons visibility to true
		for i, button in ipairs(newMenu.Buttons) do
			if button:GetName() == "Buildable" then
				button.Selected = false;
			end
			if newMenu.ToScroll == false then
				button:SetVisible(true);
			end
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
			PrimitiveMan:DrawTextPrimitive(screen, pos - Vector(2, 8), tostring(char), false, 0);
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

function BuilderMenu(self)
	self.builderBox = self.Menu:CreateGUI("COLLECTIONBOX");
	self.builderBox:SetTitle("");
	self.builderBox:SetPos(10, 25);
	self.builderBox:SetSize(260, 50);
	self.builderBox:Color(146);
	self.builderBox:OutlineColor(71);
	self.builderBox:OutlineThickness(2);
	local screen = self.builderBox:GetScreen();

	--selectedItem info
	local renderBox = Vector();
	local renderPos = Vector();

	self.cancelButton = self.Menu:CreateGUI("BUTTON", self.builderBox, "CancelButton");
	self.cancelButton.Height = 32;
	self.cancelButton:SetSize(26, 26);
	self.cancelButton:SetText("Remove\n  Build");
	self.cancelButton:SetTextPos(1, 1);
	self.cancelButton:Color(146);
	self.cancelButton:OutlineColor(144);
	self.cancelButton:OutlineThickness(2);
	self.cancelButton.IsRemoving = false;

	local height = self.cancelButton:GetHeight();
	self.builderBox:SetSize(260, height + 160);
	self.cancelButton:SetPos(5, self.cancelButton:GetParent():GetHeight() - self.cancelButton.Height);

	self.cancelButton.Think = function()
		self.cancelButton:OutlineColor(self.cancelButton:IsHovered() and 117 or 144);

		if self.cancelButton.IsRemoving == true then
			local MOs = MovableMan:GetMOsInRadius(self.Menu.Cursor, 15, -1, false);
			for mo in MOs do
				if mo then
					if mo:IsInGroup("CED - Buildables") then
						local buildable = nil;
						for group in pairs(self.CEDAvailableBuildables) do
							local category = self.CEDAvailableBuildables[group];
							for _, item in pairs(category) do
								if item.BuildablePresetName == mo.PresetName then
									buildable = item;
									break
								end
							end
						end
						if buildable then
							-- Temp cursor snap
							--? Broken, imenu stuff
							--self.Menu.Cursor = mo.Pos;

							--I think it's a good idea to set it once instead of constantly
							if renderBox.X == 0 then
								renderBox = buildable.RenderSize;
							end
							local size = (Vector(renderBox.Width, renderBox.Height) / 2);
							renderPos = mo.Pos;
							PrimitiveMan:DrawPrimitives(50, {
								BoxFillPrimitive(self.cancelButton:GetScreen(), renderPos + renderBox.Corner, renderPos + size, 13),
							});

							if self.Menu.Controller and self.Menu.Controller:IsState(Controller.PRIMARY_ACTION) then
								self.sounds.Error:Play(-1);
								self.Menu.Cursor_Bitmap = "Data/Base.rte/GUIs/Skins/Cursor.png";
								self.cancelButton.IsRemoving = false;
								mo:SendMessage("CED_CancelBuildable");
							end
						end
					end
				end
			end
		end
	end

	self.cancelButton.OnPress = function(key)
		if key == Controller.PRIMARY_ACTION then
			self.Menu.Cursor_Bitmap = "CED.rte/Effects/Menus/CancelCursor.png";
			renderBox = Vector();
			self.cancelButton.IsRemoving = true;
		end
	end

	self.tooltip = self.Menu:CreateGUI("COLLECTIONBOX");
	self.tooltip:SetTitle("");
	self.tooltip:SetHide(true);
	self.tooltip:SetSize(125, 0);
	CC_TooltipSkin(self.tooltip, true);
	self.tooltip.Think = function()
		self.tooltip:SetHide(true);
	end

	local tooltipTitle = self.Menu:CreateGUI("LABEL", self.tooltip);
	tooltipTitle:SetSmallText(true);

	local tooltipDesc = self.Menu:CreateGUI("LABEL", self.tooltip);
	tooltipDesc:SetSmallText(true);
	tooltipDesc:SetContentAlignment(5);

	local tabs = {};
	local buttons = {};
	local scrolls = {}; --Scroll for each menu
	local tab_pos = {
		["Fortifications"] = 7,
		["Turrets"] = 72,
		["Buildings"] = 137,
		["Utility"] = 202
	};

	--tooltip stuff
	local textWidth = 0;
	local textWidth_price = 0;
	local oz_width = 8;
	local textPos = Vector();
	local itemFund = false;

	local validPlacement = false;

	-- This is for terrain checking for nonair
	local tolerance = 0.1;

	-- Amount of items per row
	local perRow = 5;
	-- Amount of rows before needing to scroll
	local maxRows = 2;
	-- Distance between buttons
	local buttonDist = Vector(50, 60);

	-- Total rows for each menu
	local totalRows = {};

	local buttonPos = Vector(0, 40);

	-- Count amount of items and if are at max enable scrolling
	local itemCount = {};
	local maxItemCount = {};

	for catID, data in pairs(self.CEDAvailableBuildables) do
		local tab = self.Menu:CreateGUI("BUTTON", self.builderBox, "Category");
		if tab_pos[catID] then
			tab:SetPos(tab_pos[catID], 7);
		end
		tab:SetSize(50, 13);
		tab:SetText(catID);
		tab:Color(146);
		tab:OutlineColor(144);
		tab:OutlineThickness(2);
		tab.Selected = false;
		buttons[catID] = {};
		scrolls[catID] = 0;
		totalRows[catID] = 0;
		itemCount[catID] = 0;
		maxItemCount[catID] = 10;

		if self.MenuCurrent == self.menuData[catID] then
			tab.Selected = true;
		end

		tab.Think = function()
			tab:OutlineColor(tab:IsHovered() and 117 or 144);

			if tab.Selected then
				tab:OutlineColor(252);
			end

			if self.MenuCurrent == self.menuData[catID] then
				if itemCount[catID] > maxItemCount[catID] then
					if self.Menu.Controller then
						local go_up = self.Menu.Controller:IsState(Controller.SCROLL_UP);
						local go_down = self.Menu.Controller:IsState(Controller.SCROLL_DOWN);
		
						if go_up then
							scrolls[catID] = math.max(0, scrolls[catID] - 1);
						elseif go_down then
							scrolls[catID] = math.min(totalRows[catID] - maxRows, scrolls[catID] + 1);
						end
					end
					for i, button in ipairs(self.MenuCurrent.Buttons) do
						local pos = buttonPos;
						local row = math.floor((i - 1) / perRow);
						local isVisible = row >= scrolls[catID] and row < scrolls[catID] + maxRows;
						local j = ((i - 1) % perRow);
						pos = pos + Vector(j * buttonDist.X, row * buttonDist.Y);
						button:SetPos(pos.X + 8, pos.Y - scrolls[catID] * buttonDist.Y);
						if button.JustHovered and button:GetVisible() == false then
							if button.IsResearched == true then
								button:OutlineColor(144);
							else
								button:OutlineColor(248);
								button:Color(249);
							end
							button.JustHovered = false;
						end
						button:SetVisible(isVisible);
					end
				end
			end
		end

		tab.OnPress = function(key)
			if key == Controller.PRIMARY_ACTION then
				if self.MenuCurrent ~= self.menuData[catID] then
					for _, btn in ipairs(tabs) do
						btn.Selected = false;
					end
					tab.Selected = true;

					self.sounds.Confirm:Play(-1);

					if itemCount[catID] > maxItemCount[catID] then
						self.menuData[catID].ToScroll = true;
					end
					self:MenuChange(self.menuData[catID], false);
				end
			end
		end

		table.insert(tabs, tab);

		for i = 1, #self.menuData[catID].Items do
			local item = self.menuData[catID].Items[i];
			local itemID = item.ItemID;

			local pos = buttonPos;
			local row = math.floor((i - 1) / perRow);
			local j = ((i - 1) % perRow);
			pos = pos + Vector(j * buttonDist.X, row * buttonDist.Y);

			local button = self.Menu:CreateGUI("BUTTON", self.builderBox, "Buildable");
			button:SetVisible(false);
			button:SetPos(pos.X + 8, pos.Y);
			button:SetSize(40, 45);
			button:SetTextPos(0, 14);
			button:Color(146);
			button:OutlineColor(144);
			button:OutlineThickness(2);
			button.IsResearched = self.UnlockedResearches[itemID] or false;
			button.JustHovered = false;
			button[catID] = { Selected = false, ForcePressed = false };
			local iconPath = item.IconPath;

			if not iconPath or iconPath == "" then
				button:SetText("NO ICON");
				button:SetTextPos(0, 0);
			else
				button:SetText(item.DisplayName);
			end

			button.Think = function()
				button.IsResearched = self.UnlockedResearches[itemID] or false;
				local offset = CameraMan:GetOffset(screen);
				local world_pos = button:GetAbsolutePos();
				local relative_pos = button:GetRelativePos();
				local hasFund = self.Activity:GetTeamFunds(self.Team) >= item.Cost;

				button:Color(hasFund and 146 or 248);

				if button:IsHovered() then
					itemFund = self.Activity:GetTeamFunds(self.Team) >= item.Cost;
					self.tooltip:SetHide(false);
					if button.JustHovered == false then
						local title = item.DisplayName:gsub("\n", ""):gsub(" ", "");
						local pos = Vector(relative_pos.X + button:GetWidth() / 2, relative_pos.Y - 25);
						local tooltipWidth = self.tooltip:GetWidth();
						local desc = item.Description;
						local descHeight = FrameMan:CalculateTextHeight(item.Description, 0, true) + 25;

						self.tooltip:SetPos(pos.X + 25, pos.Y + 24);
						self.tooltip:SetSize(tooltipWidth, descHeight);

						tooltipTitle:SetText(title);
						tooltipTitle:SetPos(3, 3);
						tooltipDesc:SetSize(tooltipWidth, descHeight);
						tooltipDesc:SetText(desc);
						tooltipDesc:SetPos(3, 3);

						CC_TooltipSkin(self.tooltip);
						button.JustHovered = true;
					end

					if button.IsResearched == true then
						button:OutlineColor(itemFund and 117 or 13);
						button:Color(itemFund and 127 or 249);
					else
						button:OutlineColor(13);
						button:Color(249);
					end
				else
					if button.IsResearched == true then
						button:OutlineColor(144);
					else
						button:OutlineColor(248);
						button:Color(249);
					end
					button.JustHovered = false;
				end

				if iconPath and iconPath ~= "" then
					PrimitiveMan:DrawBitmapPrimitive(screen, world_pos + button:GetSize() / 2 + item.IconPos, iconPath, 0);
				end

				if not self.builderBox:IsHovered() and button.Selected then
					local size = (Vector(renderBox.Width, renderBox.Height) / 2);
					renderPos = self.Menu.Cursor;

					if item.SnapToGround then
						renderPos = SceneMan:MovePointToGround(renderPos, 1, 1);
						renderPos.Y = renderPos.Y - (renderBox.Height / 2);

						--If we are floating it's invalid
						if SceneMan:FindAltitude(renderPos, 0, 10) > item.MaxAltitude then
							validPlacement = false;
						end
					else
						validPlacement = true;
					end

					local startPos = renderPos - size;
					local endPos = renderPos + size;
					local totalPixels = (endPos.X - startPos.X + 1) * (endPos.Y - startPos.Y + 1);
					local nonAirPixels = 0;
					validPlacement = true;

					for x = startPos.X, endPos.X do
						for y = startPos.Y, endPos.Y do
							local terraCheck = SceneMan:GetTerrMatter(x, y);
							if terraCheck ~= rte.airID then
								nonAirPixels = nonAirPixels + 1;
							end
						end
					end

					local nonAirRatio = nonAirPixels / totalPixels;
					if nonAirRatio > tolerance then
						validPlacement = false;
					end

					local radius = math.abs(renderBox.Corner.X);
					local foundMO = nil;
					local maxRadius = 20;
					local MOs = MovableMan:GetMOsInRadius(renderPos, radius + maxRadius, -1, false);
					for mo in MOs do
						if mo then
							if mo:IsInGroup("CED - Buildables") then
								foundMO = mo;
							end
							if IsActor(mo) then
								foundMO = mo;
							end
						end
					end

					if foundMO then
						validPlacement = false;
					end

					PrimitiveMan:DrawPrimitives(50, {
						BoxFillPrimitive(screen, renderPos + renderBox.Corner, renderPos + size, validPlacement and 5 or 13),
						BitmapPrimitive(screen, renderPos, item.RenderPath, 0, false, false)
					});

					if self.selectDelayTime:IsPastSimMS(200) then
						if self.Menu.Controller and self.Menu.Controller:IsState(Controller.PRIMARY_ACTION) then
							if validPlacement then
								local createFunc = "Create" .. item.BuildableClassName;
								local buildablePreset = _G[createFunc](item.BuildablePresetName, item.BuildableTechName);
								buildablePreset.Team = self.Team;
								buildablePreset.Pos = renderPos;
								MovableMan:AddParticle(buildablePreset);
								if item.Cost > 0 then
									self.Activity:SetTeamFunds(self.Activity:GetTeamFunds(self.Team) - item.Cost, self.Team);
								end
								self.sounds.Confirm:Play(-1);
								self.selectDelayTime:Reset();
								print("Just placed the following: " .. item.DisplayName);
							else
								self.sounds.Error:Play(-1);
								self.selectDelayTime:Reset();
							end
						end
					end
				end	-- IsHovered
				if self.cancelButton.IsRemoving then
					button.Selected = false;
				end
			end -- Think

			button.OnPress = function(key)
				if key == Controller.PRIMARY_ACTION then
					if button.IsResearched then
						if itemFund then
							if button.Selected == false then
								self.sounds.Confirm:Play(-1);
								self.selectDelayTime:Reset();
								renderBox = item.RenderSize;
								self.cancelButton.IsRemoving = false;
								self.Menu.Cursor_Bitmap = "Data/Base.rte/GUIs/Skins/Cursor.png";
								for _, btn in ipairs(self.MenuCurrent.Buttons) do
									btn.Selected = false;
								end
								button.Selected = true;
							else
								self.sounds.Deselect:Play(-1);
								button.Selected = false;
							end
						end
					else
						self.sounds.Error:Play(-1);
					end
				end
			end

			itemCount[catID] = itemCount[catID] + 1;
			table.insert(buttons[catID], button);
			table.insert(self.menuData[catID].Buttons, button);
		end

		totalRows[catID] = math.ceil(#self.menuData[catID].Buttons / perRow);
	end -- for

	return true;
end

function ThreadedUpdate(self)
	if self:IsPlayerControlled() then
		if self:NumberValueExists("BuilderMenu") and self.Menu:ToOpen(self, Controller.CIM_DISABLED) then
			if not self.menuCreated then
				self.menuCreated = BuilderMenu(self);
			end
			if self.MenuCurrent then
				self:MenuChange(self.MenuCurrent, false);
			end
			self:RemoveNumberValue("BuilderMenu");
		end
	end

	if self.Menu:Update() then
		self.builderBox:Update();
		if self.tooltip:GetHide() == false then
			self.tooltip:Update();
		end
		self.Menu:DrawCursor();
	end
end

function Destroy(self)
	self.Menu:Remove();
end