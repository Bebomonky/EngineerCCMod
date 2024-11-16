require("Mods.Extensions.ExtensionMan");
require("MasterList");

function Create(self)
	self.Menu = table.Copy(require("Mods.Extensions.imenu.core"));
	self.Menu:Initialize();
	self.menuCreated = false;

	self.sounds = {
		Confirm = CreateSoundContainer("Confirm", "Base.rte"),
		XarixTree = CreateSoundContainer("Confirm", "Base.rte"),
		KhrabarovskTree = CreateSoundContainer("Confirm", "Base.rte"),
		VossbergTree = CreateSoundContainer("Confirm", "Base.rte"),
		ResearchStarted = CreateSoundContainer("Confirm", "Base.rte"),
		ResearchCompleted = CreateSoundContainer("Confirm", "Base.rte"),
		ResearchCanceled = CreateSoundContainer("Confirm", "Base.rte"),
		ResearchItemSelect = CreateSoundContainer("Confirm", "Base.rte"),
		Error = CreateSoundContainer("Error", "Base.rte"),
		Click = CreateSoundContainer("Geiger Click", "Base.rte")
	};

	self.Activity = ActivityMan:GetActivity();

	self.saveLoadHandler = require("Activities/Utility/SaveLoadHandler");
	self.saveLoadHandler:Initialize(false);

	if self:StringValueExists("CEDSupercomputerResearch") then
		self.Researches = self.saveLoadHandler:DeserializeTable(self:GetEncodedStringValue("CEDSupercomputerResearch"), "CEDSupercomputerResearch");
		self:RemoveStringValue("CEDSupercomputerResearch");
	else
		self.Researches = {};
	end

	if self:StringValueExists("CEDSupercomputerQueue") then
		self.Queue = self.saveLoadHandler:DeserializeTable(self:GetEncodedStringValue("CEDSupercomputerQueue"), "CEDSupercomputerQueue");
		self:RemoveStringValue("CEDSupercomputerQueue");
	else
		self.Queue = {};
	end

	-- SaveLoadHandler could help with this here, but this is unique per-team so this also works Just Fine
	for mo in MovableMan.Particles do
		if mo.PresetName == "CED Technology Controller" and mo.Team == self.Team then
			self.technologyController = mo;
		end
	end
	for mo in MovableMan.AddedParticles do
		if mo.PresetName == "CED Technology Controller" and mo.Team == self.Team then
			self.technologyController = mo;
		end
	end

	if not self.technologyController then
		self.technologyController = CreateMOSRotating("CED Technology Controller", "CED.rte");
		self.technologyController.Pos = self.Pos;
		self.technologyController.Team = self.Team;
		MovableMan:AddParticle(self.technologyController);
	end

	self.menuData = {};
	for techID, faction in pairs(CEDMasterList.Technology) do
		self.menuData[techID] = {
			Items = {},
			Buttons = {}
		};

		for itemID, item in pairs(faction) do
			table.insert(self.menuData[techID].Items, {
				ItemID = itemID,
				Item = item,
			});
		end
	end

	self.menuData["Xarix"].Bitmap = "CED.rte/Buildings/Supercomputer/ResearchTree/XarixTree.png";
	self.menuData["Khrabarovsk"].Bitmap = "CED.rte/Buildings/Supercomputer/ResearchTree/KhrabarovskTree.png";
	self.menuData["Vossberg"].Bitmap = "CED.rte/Buildings/Supercomputer/ResearchTree/VossbergTree.png";

	self.menuHistory = {};
	self.MenuCurrent = nil;

	function self:MenuChange(newMenu, addToHistory)
		if addToHistory == nil or addToHistory == true then
			table.insert(self.menuHistory, self.MenuCurrent);
		end

		-- Set all previous buttons visibility to false
		if self.MenuCurrent then
			for i, button in ipairs(self.MenuCurrent.Buttons) do
				button:SetVisible(false);
			end
		end

		self.MenuCurrent = newMenu;

		-- Set all new buttons visibility to true
		for i, button in ipairs(newMenu.Buttons) do
			button:SetVisible(true);
		end
	end

	self.researchFrame = -1; -- -1 blank | 0 Red | 1 Blue | 2 Yellow | 3 Gray
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

function MultiLineStringToTable(txt)
	local lines = {};
	for line in string.gmatch(txt, "([^\n]*)\n") do
		table.insert(lines, line);
	end

	return lines;
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

-- This is the greatest AddQueue of all time
function AddQueue(self, techController, panel, queueData)
	local isInQueue = false;
	local itemID = queueData.ItemID;
	for k, panel in ipairs(panel:GetChildren()) do
		if panel:GetName() == itemID then
			self.sounds.Error:Play(-1);
			isInQueue = true;
			break;
		end
	end

	if isInQueue then
		return;
	end

	local displayName = queueData.DisplayName;
	local queueIcon = queueData.QueueIcon;
	local queueIconWidth = queueData.QueueIconWidth;
	local researchTime = queueData.ResearchTime;
	local elapsedSimTimeMS = queueData.ElapsedSimTimeMS or 0;

	if not self.Queue[itemID] then
		self.Queue[itemID] = {
			DisplayName = queueData.DisplayName,
			QueueIcon = queueData.QueueIcon,
			QueueIconWidth = queueData.QueueIconWidth,
			ResearchTime = queueData.ResearchTime,
			ElapsedSimTimeMS = queueData.ElapsedSimTimeMS or 0
		};
	end

	local screen = panel:GetScreen();
	local queueItem = panel:Add("COLLECTIONBOX");
	queueItem:SetTitle(displayName);
	queueItem:SetName(itemID);
	queueItem:SetSize(queueItem:GetParent():GetWidth(), 40);

	local i = table.Count(panel:GetChildren());
	queueItem:SetPos(0, 40 * (i - 1));
	queueItem.Position = i;

	local progressBar = queueItem:Add("PROGRESSBAR");
	progressBar:SetName("RESEARCHBAR");
	progressBar:SetPos(5, progressBar:GetParent():GetHeight() - 15);
	progressBar:SetSize(50, 10);
	progressBar:BGColor(245);
	progressBar.IsRunning = false;
	progressBar:SetFraction(0);

	local function updateList()
		for i, queuePanel in ipairs(panel:GetChildren()) do
			queuePanel:SetPos(0, 40 * (i - 1));
			queuePanel.Position = i;
			local researchPanel = queuePanel:GetChildren()[1];
			local cancelPanel = queuePanel:GetChildren()[2];
			if researchPanel:GetName("RESEARCHBAR") then
				researchPanel:SetPos(5, queuePanel:GetHeight() - 15);
			end
			if cancelPanel:GetName("CANCELRESEARCH") then
				cancelPanel:SetPos(queuePanel:GetWidth() - cancelPanel:GetWidth(), 0);
			end
		end
	end

	progressBar.OnComplete = function()
		self.sounds.ResearchCompleted:Play(-1);
		self.Queue[itemID] = nil;
		self.Researches[itemID] = true;
		self.technologyController:SendMessage("CED_UnlockTechnology", itemID);
		progressBar:GetParent():Remove();
		updateList();
	end

	local cancelButton = queueItem:Add("BUTTON");
	cancelButton:SetText("X");
	cancelButton:SetName("CANCELRESEARCH");
	cancelButton:SetSmallText(false);
	cancelButton:SetSize(10, 10);
	cancelButton:SetPos(cancelButton:GetParent():GetWidth() - cancelButton:GetWidth(), 0);

	cancelButton.Think = function()
		cancelButton:Color(cancelButton:IsHovered() and 13 or 144);
	end

	cancelButton.OnPress = function(key)
		if key == Controller.PRIMARY_ACTION then
			self.sounds.ResearchCanceled:Play(-1);
			self.Queue[itemID] = nil;
			cancelButton:GetParent():Remove();
			updateList();
		end
	end

	progressBar.Think = function()
		local parent = progressBar:GetParent();

		if parent.Position == 1 then
			if progressBar.IsRunning == true then
				local timeLeft = progressBar.Timer.ElapsedSimTimeMS / progressBar.TotalTime;
				progressBar:SetFraction(timeLeft);
			elseif progressBar.IsRunning == false then
				progressBar.Timer = Timer();
				progressBar.TotalTime = researchTime;
				progressBar.Timer.ElapsedSimTimeMS = elapsedSimTimeMS;
				progressBar.IsRunning = true;
			end
		end

		progressBar:SetText(string.format("%.0f%%", progressBar:GetFraction() * 100));
		local world_pos = parent:GetAbsolutePos();
		PrimitiveMan:DrawBitmapPrimitive(screen, world_pos + Vector(queueIconWidth, 15), queueIcon, 0);

		if progressBar.Timer then
			self.Queue[itemID].ElapsedSimTimeMS = progressBar.Timer.ElapsedSimTimeMS;
		end
	end
end

function ResearchMenu(self)
	self.researchBox = self.Menu:CreateGUI("COLLECTIONBOX");
	self.researchBox:SetTitle("");
	self.researchBox:SetPos(10, 25);
	self.researchBox:SetSize(400, 300);
	self.researchBox:Color(146);
	self.researchBox:OutlineColor(71);
	self.researchBox:OutlineThickness(2);
	local screen = self.researchBox:GetScreen();

	local queueBox = self.Menu:CreateGUI("COLLECTIONBOX", self.researchBox);
	queueBox:SetTitle("");
	queueBox:SetPos(0, 0);
	queueBox:SetSize(90, 300);
	queueBox:Color(146);
	queueBox:OutlineColor(71);
	queueBox:OutlineThickness(2);

	local bitmapList = {
		InfoBox = "CED.rte/Buildings/Supercomputer/infoBox.png",
		ArrowDown = "CED.rte/Effects/Menus/ArrowDown.png",
		ArrowUp = "CED.rte/Effects/Menus/ArrowUp.png",
		researchFrame = "CED.rte/Buildings/Supercomputer/research00"
	};

	-- This is literally so it just draws behind everything except the researchBox
	local treeBox = {};
	treeBox._name = "TREEBOX";
	treeBox._drawAfterParent = true;
	treeBox.Update = function()
		if self.MenuCurrent and self.MenuCurrent.Bitmap then
			local world_pos = (self.researchBox:GetAbsolutePos() + Vector(self.researchBox:GetWidth() + 80, self.researchBox:GetHeight()) * 0.5);
			PrimitiveMan:DrawBitmapPrimitive(screen, world_pos, self.MenuCurrent.Bitmap, 0);
		end
	end
	table.insert(self.researchBox:GetChildren(), treeBox);

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

	-- Position of researchTooltip, researchButton and bitmapList.researchFrame
	local researchButtonTotalPos = Vector(0, 123);

	self.researchTooltip = self.Menu:CreateGUI("COLLECTIONBOX");
	self.researchTooltip:SetTitle("");
	self.researchTooltip:SetHide(true);
	self.researchTooltip:SetPos(560, researchButtonTotalPos.Y + 160);
	self.researchTooltip.Displaying = false;
	self.researchTooltip.DisplayCost = false;
	self.researchTooltip.Requirements = "";
	CC_TooltipSkin(self.researchTooltip, true);

	self.researchTooltip.Think = function()
		self.researchTooltip:SetHide(true);
		if self.researchTooltip.Displaying then
			local world_pos = self.researchTooltip:GetAbsolutePos();
			local hasFund = self.Activity:GetTeamFunds(self.Team) >= self.infoBox.Data.Cost;
			local enoughGold = hasFund and "Can be purchased" or "Not enough gold";
			if self.researchTooltip.Requirements ~= "" then
				PrimitiveMan:DrawTextPrimitive(screen, world_pos + Vector(3, 1), enoughGold .. "\nRequired: \n" .. self.researchTooltip.Requirements, true, 0);
			else
				PrimitiveMan:DrawTextPrimitive(screen, world_pos + Vector(3, 3), enoughGold, true, 0);
			end
		end
	end

	self.infoBox = self.Menu:CreateGUI("COLLECTIONBOX");
	self.infoBox:SetTitle("");
	self.infoBox:SetPos(self.researchBox:GetWidth() + 20, 25);
	self.infoBox:SetSize(150, 300);
	self.infoBox:Color(146);
	self.infoBox:OutlineColor(71);
	self.infoBox:OutlineThickness(2);
	self.infoBox.ArrowAnimation = Timer();
	local arrowRunTime = 150;
	local arrowDelay = 600;
	self.infoBox.TextScroll = 0;
	self.infoBox.LastScroll = 0;
	self.infoBox.TextScrollMaxLines = 12;
	self.infoBox.Popup = false;
	self.infoBox.Data = {
		ItemID = "",
		DisplayName = "",
		QueueIcon = "",
		QueueIconWidth = 0,
		Cost = 0,
		Action = "",
		RPM = "",
		MAG = "",
		Description = ""
	};

	self.infoBox.Think = function()
		local world_pos = self.infoBox:GetAbsolutePos();
		if self.infoBox.Popup == true then
			local hasFund = self.Activity:GetTeamFunds(self.Team) >= self.infoBox.Data.Cost;

			PrimitiveMan:DrawBitmapPrimitive(screen, world_pos + self.infoBox:GetSize() * 0.5, bitmapList.InfoBox, 0);

			-- Action
			PrimitiveMan:DrawTextPrimitive(screen, world_pos + Vector(5, 100), self.infoBox.Data.Action, true, 0);
			-- RPM
			PrimitiveMan:DrawTextPrimitive(screen, world_pos + Vector(51, 100), self.infoBox.Data.RPM, false, 0);
			-- MAG
			PrimitiveMan:DrawTextPrimitive(screen, world_pos + Vector(100, 100), self.infoBox.Data.MAG, false, 0);
			-- Description
			local scroll = 0;
			if self.Menu.Controller then
				local go_up = self.Menu.Controller:IsState(Controller.SCROLL_UP);
				local go_down = self.Menu.Controller:IsState(Controller.SCROLL_DOWN);

				scroll = go_up and -1 or go_down and 1 or 0;
			end

			local description = self.infoBox.Data.Description;
			local maxTextScroll = math.max(#description - self.infoBox.TextScrollMaxLines, 0);

			if self.infoBox.LastScroll ~= scroll then
				self.infoBox.LastScroll = scroll;

				self.infoBox.TextScroll = math.max(0, math.min(self.infoBox.TextScroll + scroll, maxTextScroll));
			end

			local lines = {};
			for i, line in ipairs(description) do
				if i > self.infoBox.TextScroll and #lines < self.infoBox.TextScrollMaxLines then
					table.insert(lines, line);
				end
			end

			for i, line in ipairs(lines) do
				PrimitiveMan:DrawTextPrimitive(screen, world_pos + Vector(2, 125 + (10 * (i - 1))), line, true, 0);
			end

			local arrow_movement = 129;

			if self.infoBox.ArrowAnimation:IsPastSimMS(arrowRunTime) then
				if self.infoBox.ArrowAnimation:IsPastSimMS(arrowRunTime + arrowDelay) then
					self.infoBox.ArrowAnimation:Reset();
				else
					local timeElapsed = self.infoBox.ArrowAnimation.ElapsedSimTimeMS - arrowRunTime;
					local isDirection = (#lines < self.infoBox.TextScrollMaxLines) and 1 or 0;
					if isDirection == 0 then -- Down
						arrow_movement = arrow_movement + (timeElapsed / arrowDelay) * 2;
					elseif isDirection == 1 then -- Up
						arrow_movement = arrow_movement - (timeElapsed / arrowDelay) * -2;
					end
				end
			end

			local arrowPos = world_pos + Vector(self.infoBox:GetWidth() + 7, arrow_movement);
			if self.infoBox.TextScroll >= 0 and self.infoBox.TextScroll ~= maxTextScroll then
				PrimitiveMan:DrawBitmapPrimitive(screen, arrowPos, bitmapList.ArrowDown, 0);
			elseif self.infoBox.TextScroll ~= 0 and self.infoBox.TextScroll == maxTextScroll then
				PrimitiveMan:DrawBitmapPrimitive(screen, arrowPos, bitmapList.ArrowUp, 0);
			end

			if self.researchFrame > -1 then
				PrimitiveMan:DrawBitmapPrimitive(screen,
				world_pos + self.infoBox:GetSize() * 0.5 + researchButtonTotalPos - Vector(0, 6),
				bitmapList.researchFrame .. self.researchFrame .. ".png",
				0);
			end

			local textWidth = FrameMan:CalculateTextWidth("Cost: ", false);
			PrimitiveMan:DrawTextPrimitive(screen, world_pos + Vector(2, self.infoBox:GetHeight() - 15), "Cost: ", false, 0);
			DisplayNumber(screen, world_pos + Vector(textWidth, self.infoBox:GetHeight() - 15),
			tostring(self.infoBox.Data.Cost), false, hasFund and "Green" or "Red");
		end
	end

	local researchButton = self.Menu:CreateGUI("BUTTON", self.infoBox);
	researchButton:SetText("");
	researchButton:SetPos(researchButtonTotalPos.X + 11, researchButtonTotalPos.Y + 132);
	researchButton:SetSize(127, 25);
	researchButton:SetHide(true);
	researchButton:SetClickable(false);
	local isClickable = false;
	researchButton.Think = function()

		isClickable = false;
		local hasFund = self.Activity:GetTeamFunds(self.Team) >= self.infoBox.Data.Cost;

		if researchButton:GetClickable() == true then
			if researchButton:IsHovered() then
				self.researchTooltip:SetHide(false);
				if not self.researchTooltip.Displaying then

					local tech = type(self.infoBox.Data.RequiredTech) == "table" and
					table.concat(self.infoBox.Data.RequiredTech, " ") or self.infoBox.Data.RequiredTech;
					local requirements = {};
					if tech ~= "None" then
						for i = 1, #self.MenuCurrent.Items do
							local item = self.MenuCurrent.Items[i].Item;
							local itemID = self.MenuCurrent.Items[i].ItemID;

							if string.find(tech, itemID) then
								table.insert(requirements, item.DisplayName);
							end
						end
						local requiredTech = table.concat(requirements, ",\n");
						local maxHeight = FrameMan:CalculateTextHeight(requiredTech, 0, true) + 25;
						local maxWidth = FrameMan:CalculateTextWidth(requiredTech, true);
						self.researchTooltip.Requirements = requiredTech;

						self.researchTooltip:SetSize(70, maxHeight);
					else
						self.researchTooltip.Requirements = "";
						self.researchTooltip:SetSize(70, 15);
					end
					CC_TooltipSkin(self.researchTooltip);
					self.researchTooltip.Displaying = true;
				end

				if self.Researches[self.infoBox.Data.ItemID] then
					self.researchFrame = 3; -- Gray
				else
					if self.Queue[self.infoBox.Data.ItemID] then
						self.researchFrame = 3; -- Gray
					elseif hasFund and not self.Queue[self.infoBox.Data.ItemID] then
						if type(self.infoBox.Data.RequiredTech) == "table" then
							local failCount = #self.infoBox.Data.RequiredTech;
							for _, name in pairs(self.infoBox.Data.RequiredTech) do
								if self.Researches[name] then
									failCount = failCount - 1;
								end
								if failCount == 0 then
									isClickable = true;
									self.researchFrame = 2; -- Yellow
								else
									self.researchFrame = 3; -- Gray
								end
							end
						else
							if self.infoBox.Data.RequiredTech == "None" then
								isClickable = true;
								self.researchFrame = 2; -- Yellow
							else
								if self.Researches[self.infoBox.Data.RequiredTech] then
									isClickable = true;
									self.researchFrame = 2; -- Yellow
								else
									self.researchFrame = 3; -- Gray
								end
							end
						end
					elseif not hasFund then
						self.researchFrame = 3; -- Gray
					end
				end
			else
				if self.Researches[self.infoBox.Data.ItemID] then
					self.researchFrame = 3; -- Gray
				else
					if self.Queue[self.infoBox.Data.ItemID] then
						self.researchFrame = 0; -- Red
					elseif hasFund and not self.Queue[self.infoBox.Data.ItemID] then
						if type(self.infoBox.Data.RequiredTech) == "table" then
							local failCount = #self.infoBox.Data.RequiredTech;
							for _, name in pairs(self.infoBox.Data.RequiredTech) do
								if self.Researches[name] then
									failCount = failCount - 1;
								end
								if failCount == 0 then
									self.researchFrame = 1; -- Blue
								else
									self.researchFrame = 0; -- Red
								end
							end
						else
							if self.infoBox.Data.RequiredTech == "None" then
								self.researchFrame = 1; -- Blue
							else
								if self.Researches[self.infoBox.Data.RequiredTech] then
									self.researchFrame = 1; -- Blue
								else
									self.researchFrame = 0; -- Red
								end
							end
						end
					elseif not hasFund then
						self.researchFrame = 0; -- Red
					end
				end
				self.researchTooltip.Displaying = false;
			end
		end
	end

	researchButton.OnPress = function(key)
		if key == Controller.PRIMARY_ACTION then
			if isClickable then
				local queue = AddQueue(self, self.technologyController, queueBox, self.infoBox.Data);
				self.sounds.ResearchStarted:Play(-1);
			else
				self.sounds.Error:Play(-1);
			end
		end
	end


	local tabs = {};
	local buttons = {};
	local tab_pos = {
		["Xarix"] = 135,
		["Khrabarovsk"] = 215,
		["Vossberg"] = 295
	};

	if not table.IsEmpty(self.Queue) then
		for itemID, data in pairs(self.Queue) do
			local queueData = data;
			queueData.ItemID = itemID;
			AddQueue(self, self.technologyController, queueBox, queueData);
		end
	end

	for techID, faction in pairs(CEDMasterList.Technology) do
		local tab = self.Menu:CreateGUI("BUTTON", self.researchBox, "Category");
		if tab_pos[techID] then
			tab:SetPos(tab_pos[techID], 10);
		end
		tab:SetSize(50, 40);
		tab:SetText(techID);
		tab:Color(146);
		tab:OutlineColor(144);
		tab:OutlineThickness(2);
		tab.Selected = false;
		buttons[techID] = {};

		if self.MenuCurrent == self.menuData[techID] then
			tab.Selected = true;
		end

		tab.Think = function()
			tab:OutlineColor(tab:IsHovered() and 117 or 144);

			if tab.Selected then
				tab:OutlineColor(252);
			end
		end

		tab.OnPress = function(key)
			if key == Controller.PRIMARY_ACTION then
				if self.MenuCurrent ~= self.menuData[techID] then
					for _, btn in ipairs(tabs) do
						btn.Selected = false;
					end
					tab.Selected = true;
					self.researchFrame = -1;
					self.infoBox.Popup = false;
					self.sounds[techID .. "Tree"]:Play(-1);
					researchButton:SetClickable(false);
					self:MenuChange(self.menuData[techID], false);
				end
			end
		end
		table.insert(tabs, tab);

		for i = 1, #self.menuData[techID].Items do
			local item = self.menuData[techID].Items[i].Item;
			local itemID = self.menuData[techID].Items[i].ItemID;
			local button = self.Menu:CreateGUI("BUTTON", self.researchBox, itemID);
			button:SetVisible(false);
			button:SetPos(item.Pos.X, item.Pos.Y);
			button:SetSize(40, 25);
			button:Color(146);
			button:OutlineColor(144);
			button:OutlineThickness(2);
			button.JustHovered = false;
			button[techID] = { Selected = false, ForcePressed = false };

			local iconSize = item.IconSize;
			local iconPath = item.IconPath;
			local action = item.Action or "N/A";
			local rpm = item.RPM or "N/A";
			local mag = item.MAG or "N/A";
			local description = item.InfoBoxDescription;

			if not description or description == "" then
				description = "Description not set";
			end
			if iconSize then
				button:SetSize(iconSize.X, iconSize.Y);
			else
				button:SetSize(25, 25);
			end
			if not iconPath or iconPath == "" then
				button:SetText("NO\nICON");
			else
				button:SetText("");
			end

			button.Think = function()
				button.IsResearched = self.Researches[itemID] or false;
				local world_pos = button:GetAbsolutePos();
				button:OutlineColor(button:IsHovered() and 117 or 144);
				if button.IsResearched then
					button:OutlineColor(5);
				end
				if button[techID].Selected then
					button:OutlineColor(252);
					-- This is so that we go to the last pressed button of that category
					if not self.infoBox.Popup then
						button[techID].ForcePressed = true;
						button.OnPress(Controller.PRIMARY_ACTION);
						button[techID].ForcePressed = false;
					end
				end
				if button:IsHovered() then
					self.tooltip:SetHide(false);
					if button.JustHovered == false then
						local title = item.DisplayName;
						local pos = Vector((item.Pos.X + button:GetWidth()), item.Pos.Y);
						local tooltipWidth = self.tooltip:GetWidth();
						local desc, descHeight = itemDescription(item.Description, true, tooltipWidth);

						self.tooltip:SetPos(pos.X + 15, pos.Y + 24);
						self.tooltip:SetSize(tooltipWidth, descHeight);

						tooltipTitle:SetText(title);
						tooltipTitle:SetPos(3, 3);
						tooltipDesc:SetSize(tooltipWidth, descHeight);
						tooltipDesc:SetText(desc);
						tooltipDesc:SetPos(3, 3);
						CC_TooltipSkin(self.tooltip);
						button.JustHovered = true;
					end
				else
					button.JustHovered = false;
				end

				button.OnPress = function(key)
					if key == Controller.PRIMARY_ACTION then
						if button[techID].Selected == false then
							for _, btn in ipairs(buttons[techID]) do
								btn[techID].Selected = false;
							end
							button[techID].Selected = true;
							self.infoBox.Popup = true;

							self.infoBox.Data.ItemID = itemID;
							self.infoBox.Data.TechID = techID;
							self.infoBox.Data.Type = item.Type;
							self.infoBox.Data.RequiredTech = item.RequiredTech;
							self.infoBox.Data.DisplayName = item.DisplayName;
							self.infoBox.Data.Description = MultiLineStringToTable(description);
							self.infoBox.Data.Action = action;
							self.infoBox.Data.RPM = rpm;
							self.infoBox.Data.MAG = mag;
							self.infoBox.Data.QueueIcon = item.IconPath;
							self.infoBox.Data.QueueIconWidth = item.IconSize.X / 2;
							self.infoBox.Data.ResearchTime = item.ResearchTime;
							self.infoBox.Data.Cost = item.Cost;

							researchButton:SetClickable(true);
							self.infoBox.ArrowAnimation:Reset();
							self.infoBox.TextScroll = 0;
							self.infoBox.LastScroll = 0;
							if not button[techID].ForcePressed then
								self.sounds.ResearchItemSelect:Play(-1);
							end
						end
					end
				end
				if iconPath and iconPath ~= "" then
					PrimitiveMan:DrawBitmapPrimitive(screen, world_pos + button:GetSize() / 2, iconPath, 0);
				end
			end
			table.insert(buttons[techID], button);
			table.insert(self.menuData[techID].Buttons, button);
		end
	end

	if self.MenuCurrent then
		self:MenuChange(self.MenuCurrent, false);
	end

	return true;
end

function ThreadedUpdate(self)
	if self:IsPlayerControlled() then
		local hideMenu = false;
		for _, input in pairs({Controller.SECONDARY_ACTION, Controller.ACTOR_NEXT_PREP, Controller.ACTOR_PREV_PREP}) do
			if self:GetController():IsState(input) then
				hideMenu = true;
			end
		end
		if hideMenu == false and self.Menu:ToOpen(self, Controller.CIM_DISABLED) then
			if not self.menuCreated then
				self.menuCreated = ResearchMenu(self);
			end
		end
	end

	if self.Menu:Update() then
		self.researchBox:Update();
		self.infoBox:Update();
		if self.tooltip:GetHide() == false then
			self.tooltip:Update();
		end
		if self.researchTooltip:GetHide() == false then
			self.researchTooltip:Update();
		end
		self.Menu:DrawCursor();
	end
end

function Destroy(self)
	self.Menu:Remove();
end

function OnSave(self)
	self:SetEncodedStringValue("CEDSupercomputerResearch", self.saveLoadHandler:SerializeTable(self.Researches));
	self:SetEncodedStringValue("CEDSupercomputerQueue", self.saveLoadHandler:SerializeTable(self.Queue));
end