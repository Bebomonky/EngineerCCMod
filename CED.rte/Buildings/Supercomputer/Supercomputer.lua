require("Mods.Extensions.ExtensionMan");
require("MasterList");

function Create(self)
	self.Menu = require("Mods.Extensions.imenu.core");
	self.Menu:Initialize();
	self.menuCreated = false;

	self.sounds = {
		Confirm = CreateSoundContainer("Confirm", "Base.rte"),
		Error = CreateSoundContainer("Error", "Base.rte"),
		Click = CreateSoundContainer("Geiger Click", "Base.rte")
	};

	self.Activity = ActivityMan:GetActivity();

	self.saveLoadHandler = require("Activities/Utility/SaveLoadHandler");
	self.saveLoadHandler:Initialize(false);

	if self:StringValueExists("CEDSupercomputerResearch") then
		self.Researches = self.saveLoadHandler:DeserializeTable(self:GetStringValue("CEDSupercomputerResearch"), "CEDSupercomputerResearch");
		self:RemoveStringValue("CEDSupercomputerResearch");
	else
		self.Researches = {};
	end

	if self:StringValueExists("CEDSupercomputerQueue") then
		self.Queue = self.saveLoadHandler:DeserializeTable(self:GetStringValue("CEDSupercomputerQueue"), "CEDSupercomputerQueue");
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

		for i = 1, #self.menuData[techID].Items do
			local item = self.menuData[techID].Items[i].Item;
			local itemID = self.menuData[techID].Items[i].ItemID;
			item.IsResearched = false;
			if type(item.RequiredTech) == "table" then
				for _, name in pairs(item.RequiredTech) do
					if self.Researches[name] then
						item.IsResearched = true;
					end
				end
			else
				if item.RequiredTech == "None" then
					item.IsResearched = true;
				end
				if self.Researches[item.RequiredTech] then
					item.IsResearched = true;
				end
			end
			if self.Queue[itemID] then
				
			end
			--item.IsResearched = researchTech and true or false;
			--item.InProgress = researchItem.InProgress or false;
			--item.ElapsedSimTimeMS = researchItem.ElapsedSimTimeMS or 0;
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

		--Set all previous buttons visibility to false
		if self.MenuCurrent then
			for i, button in ipairs(self.MenuCurrent.Buttons) do
				button:SetVisible(false);
			end
		end

		self.MenuCurrent = newMenu;

		--Set all new buttons visibility to true
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
		PrimitiveMan:DrawBitmapPrimitive(screen, pos, path, 0);
		x = x + spriteWidth;
	end
end

function itemDescription(desc, size_x)
	if desc == nil then
		desc = "Description not set";
	end
	local newDesc = "";
	local words = {};
	for word in string.gmatch(desc, "%S+") do
		table.insert(words, word);
	end
	local line = "";
	for i = 1, #words do
		local word = words[i];
		local newLine = line .. (line ~= "" and " " or "") .. word;
		local descWidth = FrameMan:CalculateTextWidth(newLine, true) + 5;
		if descWidth > size_x then
			if line ~= "" then
				newDesc = newDesc .. line .. "\n";
			end
			line = word;
		else
			line = newLine;
		end
	end
	if line ~= "" then
		newDesc = newDesc .. line;
	end
	return newDesc;
end

function CC_TooltipSkin(parent, new)
	new = new or false;
	local w = parent:GetWidth();
	local h = parent:GetHeight();
	local outlines = {
		{Vector(w + 1, 0), Vector(1, h + 2), false, 21},
		{Vector(0, h + 1), Vector(w + 2, 1), false, 21},
		{Vector(0, 0), Vector(1, h), true, 21},
		{Vector(0, 0), Vector(w, 1), true, 21},
		{Vector(w - 1, 1), Vector(1, h - 1), true, 59},
		{Vector(1, h - 1), Vector(w - 1, 1), true, 59},
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

function ResearchMenu(self)
	self.researchBox = self.Menu:CreateGUI("COLLECTIONBOX");
	self.researchBox:SetTitle("");
	self.researchBox:SetPos(10, 25);
	self.researchBox:SetSize(400, 300);
	self.researchBox:Color(146);
	self.researchBox:OutlineColor(71);
	self.researchBox:OutlineThickness(2);
	self.researchBox.LinePos = Vector(80, 0);
	local screen = self.researchBox:GetScreen();

	self.researchBox.Think = function()
		local world_pos = self.researchBox:GetAbsolutePos() + self.researchBox.LinePos;
		PrimitiveMan:DrawLinePrimitive(screen, world_pos, world_pos + Vector(0, self.researchBox:GetHeight()), 71, 2);
	end

	--This is literally so it just draws behind everything except the researchBox
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
	self.tooltip:SetHide(true);
	self.tooltip:SetTitle("");
	self.tooltip.Displaying = false;
	CC_TooltipSkin(self.tooltip, true);
	self.tooltip.Think = function()
		self.tooltip:SetHide(true);
	end

	self.tooltipTitle = self.Menu:CreateGUI("LABEL", self.tooltip);
	self.tooltipTitle:SetSmallText(true);

	self.tooltipDesc = self.Menu:CreateGUI("LABEL", self.tooltip);
	self.tooltipDesc:SetSmallText(true);
	self.tooltipDesc:SetContentAlignment(5);

	self.researchTooltip = self.Menu:CreateGUI("COLLECTIONBOX");
	self.researchTooltip:SetTitle("");
	self.researchTooltip:SetHide(true);
	self.researchTooltip:SetPos(560, 290);
	self.researchTooltip.Displaying = false;
	self.researchTooltip.DisplayCost = false;
	CC_TooltipSkin(self.researchTooltip, true);
	self.researchTooltip.Think = function()
		self.researchTooltip:SetHide(true);
		if self.researchBox.Displaying then
			local hasFund = self.Activity:GetTeamFunds(self.Team) >= self.infoBox.Data.Cost;
			local pos = self.researchTooltip:GetAbsolutePos();
			local textWidth = FrameMan:CalculateTextWidth("Cost: ", false);
			local text_pos = pos + Vector(2, -1);
			PrimitiveMan:DrawTextPrimitive(screen, text_pos, "Cost: ", false, 0);
			DisplayNumber(screen, text_pos + Vector(textWidth, 0), tostring(self.infoBox.Data.Cost), false, hasFund and "Green" or "Red");
		end
	end

	--self.researchTooltipDesc = self.Menu:CreateGUI("LABEL", self.researchTooltip);
	--self.researchTooltipDesc:SetSmallText(true);
	--self.researchTooltipDesc:SetContentAlignment(5);

	self.infoBox = self.Menu:CreateGUI("COLLECTIONBOX");
	self.infoBox:SetTitle("");
	self.infoBox:SetPos(self.researchBox:GetWidth() + 20, 25);
	self.infoBox:SetSize(150, 300);
	self.infoBox:Color(146);
	self.infoBox:OutlineColor(71);
	self.infoBox:OutlineThickness(2);
	self.infoBox.Data = {
		Cost = 0,
		Primitives = {
			{Pos = Vector(4, 100), Text = "", isSmall = true}, --Action
			{Pos = Vector(68, 100), Text = "", isSmall = false}, --RPM
			{Pos = Vector(118, 100), Text = "", isSmall = false}, --MAG
			{Pos = Vector(1, 125), Text = "", isSmall = true}, --Description
		}
	};
	self.infoBox.Think = function()
		if self.clickedCategory == false then
			local world_pos = self.infoBox:GetAbsolutePos() + self.infoBox:GetSize() * 0.5
			PrimitiveMan:DrawBitmapPrimitive(screen, world_pos, "CED.rte/Buildings/Supercomputer/infoBox.png", 0);
			for i = 1, #self.infoBox.Data.Primitives do
				local data = self.infoBox.Data.Primitives[i];
				PrimitiveMan:DrawTextPrimitive(screen, self.infoBox:GetAbsolutePos() + data.Pos, data.Text, data.isSmall, 0);
			end
			if self.researchFrame > -1 then
				local world_pos = self.infoBox:GetAbsolutePos() + self.infoBox:GetSize() * 0.5 + Vector(0, 120);
				PrimitiveMan:DrawBitmapPrimitive(screen, world_pos, "CED.rte/Buildings/Supercomputer/research00" .. self.researchFrame .. ".png", 0);
			end
		end
	end

	local researchButton = self.Menu:CreateGUI("BUTTON", self.infoBox);
	researchButton:SetText("");
	researchButton:SetPos(11, 258);
	researchButton:SetSize(127, 25);
	researchButton:SetHide(true);
	researchButton:SetClickable(false);
	researchButton.Think = function()
		if self.researchFrame > -1 then
			if self.researchinProgress then
			
			else
				if researchButton:IsHovered() then
					self.researchTooltip:SetHide(false);
					if not self.researchBox.Displaying then
						local totalWidth = FrameMan:CalculateTextWidth("Cost: " .. tostring(self.infoBox.Data.Cost), false);
						self.researchTooltip:SetSize(totalWidth + 5, 15);
						CC_TooltipSkin(self.researchTooltip);
						self.researchBox.Displaying = true;
					end
					self.researchFrame = 2;
				else
					self.researchTooltip.Displaying = false;
					self.researchFrame = 3;
				end
			end
		end
	end

	researchButton.OnPress = function(key)
		if key == Controller.PRIMARY_ACTION then
			local hasFund = self.Activity:GetTeamFunds(self.Team) >= self.infoBox.Data.Cost;
			if hasFund then
				self.sounds.Confirm:Play(-1);
			else
				self.sounds.Error:Play(-1);
			end
		end
	end


	local tabs = {};
	local i = 1;
	local totalWidth = 0;
	local width = 50;
	local height = 40;
	local spacing = 30;
	local totalWidth = (3 * width) + (spacing * (3 - 1));
	local mainWidth = self.researchBox:GetWidth() + 80;
	local emptySpace = mainWidth - totalWidth;
	local padding = emptySpace / 2;

	for techID, faction in SortedPairs(CEDMasterList.Technology) do
		local x = padding + (i - 1) * (width + spacing);
		local tab = self.Menu:CreateGUI("BUTTON", self.researchBox, "Category");
		tab:SetPos(x, 10);
		tab:SetSize(width, height);
		tab:SetText(techID);
		tab:Color(146);
		tab:OutlineColor(144);
		tab:OutlineThickness(2);
		tab.Selected = false;
		if self.MenuCurrent == self.menuData[techID] then
			tab.Selected = true;
		end
		tab.Nodes = {};
		tab.Think = function()
			tab:OutlineColor(tab:IsHovered() and 117 or 144);

			if tab.Selected then
				tab:OutlineColor(252);
			end
		end

		tab.OnPress = function(key)
			if key == Controller.PRIMARY_ACTION then
				if table.IsEmpty(faction) then
					print("Table is empty!");
					self.sounds.Error:Play(-1);
					return;
				end

				for _, btn in ipairs(tabs) do
					btn.Selected = false;
				end
				self.researchFrame = -1;
				self.clickedCategory = true;
				tab.Selected = true;
				self.sounds.Confirm:Play(-1);
				self:MenuChange(self.menuData[techID], false);
			end
		end
		table.insert(tabs, tab);
		i = i + 1;

		for i = 1, #self.menuData[techID].Items do
			local item = self.menuData[techID].Items[i].Item;
			local button = self.Menu:CreateGUI("BUTTON", self.researchBox, "Node");
			button:SetVisible(false);
			button:SetPos(item.Pos.X, item.Pos.Y);
			button:SetSize(40, 25);
			button:SetText("");
			button:Color(146);
			button:OutlineColor(144);
			button:OutlineThickness(2);
			button.Researched = false;
			button.RequiredTech = item.RequiredTech;
			button:SetSize(25, 25);
			button.Think = function()
				local world_pos = button:GetAbsolutePos();
				button:OutlineColor(button:IsHovered() and 117 or 144);
				if button:IsHovered() then
					self.tooltip:SetHide(false);
					if self.tooltip.Displaying == false then
						local title = item.DisplayName;
						local pos = Vector((item.Pos.X + button:GetWidth()), item.Pos.Y);
						local size = item.TooltipSize;

						self.tooltip:SetPos(pos.X + 15, pos.Y + 24);
						self.tooltip:SetSize(size.X, size.Y);

						self.tooltipTitle:SetText(title);
						self.tooltipTitle:SetPos(3, 3);
						self.tooltipDesc:SetSize(size.X, size.Y);
						local desc = itemDescription(item.Description, size.X);
						self.tooltipDesc:SetText(desc);
						self.tooltipDesc:SetPos(3, 3);
						CC_TooltipSkin(self.tooltip);
						self.tooltip.Displaying = true;
					end
				else
					self.tooltip.Displaying = false;
				end

				button.OnPress = function(key)
					if key == Controller.PRIMARY_ACTION then
						self.clickedCategory = false;
						self.infoBox.Data.Cost = item.Cost;
						self.infoBox.Data.Primitives[1].Text = tostring(item.Action);
						self.infoBox.Data.Primitives[2].Text = tostring(item.RPM);
						self.infoBox.Data.Primitives[3].Text = tostring(item.MAG);
						self.infoBox.Data.Primitives[4].Text = itemDescription(item.InfoBoxDescription, self.infoBox:GetWidth());
						self.researchFrame = 1;
						researchButton:SetClickable(true);
						self.sounds.Confirm:Play(-1);
					end
				end
				--PrimitiveMan:DrawBitmapPrimitive(screen, world_pos + button:GetSize() / 2, item.IconPath, 0);
			end
			table.insert(tab.Nodes, button);
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
		self.Menu:DrawCursor();
	end
end

function Destroy(self)
	self.Menu:Remove();
end

function OnSave(self)
	self:SetStringValue("CEDSupercomputerResearch", self.saveLoadHandler:SerializeTable(self.Researches));
end