require("Mods.Extensions.ExtensionMan");

function OnGlobalMessage(self, message, research)
	if message == "CED_UnlockResearch" then
		for i = 1, #self.category do
			local tab = self.category[i];
			local name = tab[1];
			local buildableList = tab[2];

			for j = 1, #buildableList do
				self.menuData[name].Buttons[j].IsResearched = research;
			end
		end
	end
end

function OnMessage(self, message, research)
	if message == "CED_UnlockResearch" then
		for i = 1, #self.category do
			local tab = self.category[i];
			local name = tab[1];
			local buildableList = tab[2];

			for j = 1, #buildableList do
				self.menuData[name].Buttons[j].IsResearched = research;
			end
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

	--When a buildable is selected
	self.renderBox = nil;
	self.renderPos = Vector();

	self.cancelButton = self.Menu:CreateGUI("BUTTON", self.builderBox);
	self.cancelButton.Height = 32;
	self.cancelButton:SetPos(5, self.cancelButton:GetParent():GetHeight() - self.cancelButton.Height);
	self.cancelButton:SetSize(26, 26);
	self.cancelButton:SetText("Remove\n  Build");
	self.cancelButton:SetTextPos(0, 1);
	self.cancelButton:Color(146);
	self.cancelButton:OutlineColor(144);
	self.cancelButton:OutlineThickness(2);
	self.cancelButton.isRemoving = false;

	self.cancelButton.Think = function()
		self.cancelButton:OutlineColor(self.cancelButton:IsHovered() and 117 or 144);

		if self.cancelButton.isRemoving then
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
							--Temp cursor snap
							self.Menu.Cursor = mo.Pos;

							--I think it's a good idea to set it once instead of constantly
							if self.renderBox == nil then
								self.renderBox = buildable.RenderSize;
							end
							local size = (Vector(self.renderBox.Width, self.renderBox.Height) / 2);
							self.renderPos = mo.Pos;
							PrimitiveMan:DrawPrimitives(50, {
								BoxFillPrimitive(screen, self.renderPos + self.renderBox.Corner, self.renderPos + size, 13),
							});

							if self.Menu.Controller and self.Menu.Controller:IsState(Controller.PRIMARY_ACTION) then
								self.sounds.Error:Play(-1);
								self.Menu.Cursor_Bitmap = "Data/Base.rte/GUIs/Skins/Cursor.png";
								self.cancelButton.isRemoving = false;
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
			self.Menu.Cursor_Bitmap = "Mods/CED.rte/Actors/Shared/Sprites/Menus/CancelCursor.png";
			self.renderBox = nil;
			self.cancelButton.isRemoving = true;
		end
	end

	self.tooltip = self.Menu:CreateGUI("COLLECTIONBOX", self.builderBox);
	self.tooltip:SetTitle("");
	self.tooltip:SetPos(self.tooltip:GetParent():GetWidth() + 10, 25);
	self.tooltip:SetSize(100, 75);
	self.tooltip:Color(93);
	self.tooltip:OutlineColor(245);
	self.tooltip:OutlineThickness(1);
	self.tooltip:SetVisible(false); --Set to false to prevent flicker
	self.tooltip.Displaying = false;

	self.tooltipDesc = self.Menu:CreateGUI("LABEL", self.tooltip);
	self.tooltipDesc:SetPos(45, (self.tooltip:GetHeight() * 0.5) - 20);
	self.tooltipDesc:SetSmallText(true);
	self.tooltipDesc:SetContentAlignment(1);

	self.tooltip.Think = function()
		self.tooltip:SetVisible(false);
	end

	--Bitmap will be modifed so we need to make sure it's always default
	self.Menu.Cursor_Bitmap = "Data/Base.rte/GUIs/Skins/Cursor.png";

	local categoryRows = 4;
	local tabs = {};
	for i = 1, #self.category do
		local tab = self.category[i];
		local name = tab[1];
		local buildableList = tab[2];
		local tabTemplate = tab[3];

		--local x = self.builderBox:GetPos().X + ((i - 1) % categoryRows) * 65;
		--local y = self.builderBox:GetPos().Y - (math.floor((i - 1) / categoryRows) + 1) * 35;
		local x = 7 + ((i - 1) * 65)

		local tab = self.builderBox:Add("BUTTON");
		tab.BuildList = buildableList;
		tab.Index = i;
		tab:SetPos(x, 7)
		tab:SetSize(50, 13);
		tab:SetText(name);
		tab:Color(146);
		tab:OutlineColor(144);
		tab:OutlineThickness(2);

		tab.Selected = false;
		if self.MenuCurrent == self.menuData[name] then
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
				if table.IsEmpty(tab.BuildList) then
					print("Table is empty!");
					self.sounds.Error:Play(-1);
					return
				end

				for _, btn in ipairs(tabs) do
					btn.Selected = false;
				end
				tab.Selected = true;
				self:MenuChange(self.menuData[name], false);
			end
		end
		table.insert(tabs, tab);
	end

	if self.MenuCurrent then
		self:Populate(self.MenuCurrent, self.MenuCurrent.Scroll);
	end
end

function Create(self)
	self.Menu = require("Mods.Extensions.imenu.core");
	self.Menu:Initialize();

	self.sounds = {
		Confirm = CreateSoundContainer("Confirm", "Base.rte"),
		Error = CreateSoundContainer("Error", "Base.rte"),
	}

	if not self.PieMenu:GetFirstPieSliceByPresetName("BuilderMenu") then
		self.PieMenu:AddPieSlice(CreatePieSlice("BuilderMenu", "CED.rte"), self);
	end

	self.selectDelayTime = Timer();

	self.Activity = ActivityMan:GetActivity();

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

	self.category = {
		{
			"Fortification",
			self.CEDAvailableBuildables.Fortifications,
			{
				Offset = Vector(0, 40),
				DistOffset = Vector(85, 85),
				Rows = 3,
			}
		},
		{
			"Turrets",
			self.CEDAvailableBuildables.Turrets,
			{
				Offset = Vector(0, 40),
				DistOffset = Vector(85, 85),
				Rows = 3,
			}
		},
		{
			"Buildings",
			self.CEDAvailableBuildables.Buildings,
			{
				Offset = Vector(0, 40),
				DistOffset = Vector(85, 85),
				Rows = 3,
			}
		},
		{
			"Utility",
			self.CEDAvailableBuildables.Utility,
			{
				Offset = Vector(0, 40),
				DistOffset = Vector(85, 85),
				Rows = 3,
			}
		}
	};

	self.menuData = {};
	for i = 1, #self.category do
		local tab = self.category[i];
		local name = tab[1];
		local buildableList = tab[2];
		local tabTemplate = tab[3];

		self.menuData[name] = tabTemplate;
		self.menuData[name].TotalRows = 0;
		self.menuData[name].MaxRows = 0;
		self.menuData[name].Scroll = 0;
		self.menuData[name].Buttons = {};

		for j = 1, #buildableList do
			local buildable = buildableList[j];

			table.insert(self.menuData[name].Buttons,
			{
				Buildable = buildable,
				IsResearched = buildable.ResearchName ~= nil and (self.technologyController ~= nil and self.technologyController:NumberValueExists(buildable.ResearchName) or false) or true
			});
		end
	end

	self.menuHistory = {};

	self.MenuCurrent = self:GetStringValue("MenuCurrent") and self.menuData[self:GetStringValue("MenuCurrent")] or self.menuData["Fortification"];

	function self:Populate(menu, scroll)

		local rows = 3;
		local maxHeight = 295;
		local currentHeight = 40;
		local height = 40;

		self.renderBox = nil;
		self.renderPos = Vector();

		local textWidth = 0;
		local textWidth_price = 0;
		local oz_width = 8;
		local textPos = Vector();
		local itemFund = false;

		local validPlacement = false;
		local tolerance = 0.1;

		local buttonpos = Vector(6, 0);

		local perRow = menu.Rows;

		local screen = self.Menu.Screen;

		if (self.buttonBox) then
			self.buttonBox:Remove();
		end

		self.buttonBox = self.builderBox:Add("COLLECTIONBOX");
		self.buttonBox:SetHide(true);

		for i, menuButton in ipairs(menu.Buttons) do
			local pos = menu.Offset;
			local row = math.floor((i - 1) / perRow);
			local j = ((i - 1) % perRow);
			pos = pos + Vector(j * (menu.DistOffset.X or 0), row * (menu.DistOffset.Y or 0));

			local button = self.buttonBox:Add("BUTTON");
			button.Buildable = menuButton.Buildable;
			button.Selected = false;
			button.HasThickness = true;
			button:SetPos(pos.X + 8, pos.Y);
			button:SetSize(50, 45);
			button:SetText(button.Buildable.DisplayName);
			button:SetTextPos(0, 9);
			button:Color(146);
			button:OutlineColor(144);
			button:OutlineThickness(2);
			button:SetHide(false);

			button.Think = function()
				local offset = CameraMan:GetOffset(screen);
				local world_pos = button:GetPos();
				local hasFund = self.Activity:GetTeamFunds(self.Team) >= button.Buildable.Cost;
				button.IsResearched = menuButton.IsResearched;

				if button.IsResearched == true then
					if button.HasThickness == false then
						button:OutlineThickness(2);
						button.HasThickness = true;
					end
				else
					if button.HasThickness == true then
						button:OutlineThickness(0);
						button.HasThickness = false;
					end
				end

				button:Color(hasFund and 146 or 248);

				if button:IsHovered() then
					itemFund = self.Activity:GetTeamFunds(self.Team) >= button.Buildable.Cost;
					self.tooltip:SetVisible(true);

					local title = button.Buildable.DisplayName:gsub("\n", "");
					if self.tooltip.Displaying == false then
						local size = button.Buildable.TooltipSize;
						self.tooltip:SetSize(size.X, size.Y);
						self.tooltip:SetTitle(title);

						textWidth = FrameMan:CalculateTextWidth(title .. " ", true);

						if button.Buildable.Cost > 0 then
							textWidth_price = FrameMan:CalculateTextWidth(tostring(button.Buildable.Cost), true);
						else
							textWidth_price = FrameMan:CalculateTextWidth("FREE", true);
						end
						self.tooltip.Displaying = true;
					end
					textPos = offset + Vector(textWidth, 0) + Vector(self.tooltip:GetPos().X + 10, self.tooltip:GetPos().Y + 25);

					PrimitiveMan:DrawTextPrimitive(screen, textPos, "(", true, 0);
					DisplayNumber(self, screen,
					itemFund and "Green" or "Red",
					textPos + Vector(4, 0),
					button.Buildable.Cost > 0 and tostring(button.Buildable.Cost) or "FREE");

					if button.Buildable.Cost > 0 then
						PrimitiveMan:DrawTextPrimitive(screen, textPos + Vector(4 + textWidth_price, 0), "oz", true, 0);
						PrimitiveMan:DrawTextPrimitive(screen,
						textPos + Vector(4 + textWidth_price + oz_width, 0), ")",
						true,
						0);
					else
						PrimitiveMan:DrawTextPrimitive(screen,
						textPos + Vector(4 + textWidth_price, 0), ")",
						true,
						0);
					end

					if button.IsResearched == true then
						self.tooltipDesc:SetText(button.Buildable.Description);
						button:OutlineColor(itemFund and 117 or 13);
						button:Color(itemFund and 127 or 249);
					else
						self.tooltipDesc:SetText("Research Required: " .. button.Buildable.ResearchName .. "\n" .. button.Buildable.Description);
						button:OutlineColor(13);
						button:Color(249);
					end
				else
					if button.IsResearched == true then
						button:OutlineColor(144);
					else
						button:Color(249);
					end
					self.tooltip.Displaying = false;
				end

				PrimitiveMan:DrawBitmapPrimitive(screen, world_pos + button:GetSize() / 2 + button.Buildable.IconPos, button.Buildable.IconPath, 0);

				if not self.builderBox:IsHovered() and button.Selected then
					local size = (Vector(self.renderBox.Width, self.renderBox.Height) / 2);
					self.renderPos = self.Menu.Cursor;

					if button.Buildable.SnapToGround then
						self.renderPos = SceneMan:MovePointToGround(self.renderPos, 1, 1);
						self.renderPos.Y = self.renderPos.Y - (self.renderBox.Height / 2);

						--If we are floating it's invalid
						if SceneMan:FindAltitude(self.renderPos, 0, 10) > button.Buildable.MaxAltitude then
							validPlacement = false;
						end
					else
						validPlacement = true;
					end

					local startPos = self.renderPos - size;
					local endPos = self.renderPos + size;
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

					local radius = math.abs(self.renderBox.Corner.X);
					local foundMO = nil;
					local maxRadius = 20;
					local MOs = MovableMan:GetMOsInRadius(self.renderPos, radius + maxRadius, -1, false);
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
						BoxFillPrimitive(screen, self.renderPos + self.renderBox.Corner, self.renderPos + size, validPlacement and 5 or 13),
						BitmapPrimitive(screen, self.renderPos, button.Buildable.RenderPath, 0, false, false)
					});

					if self.selectDelayTime:IsPastSimMS(200) then
						if self.Menu.Controller and self.Menu.Controller:IsState(Controller.PRIMARY_ACTION) then
							if validPlacement then
								local createFunc = "Create" .. button.Buildable.BuildableClassName;
								local buildablePreset = _G[createFunc](button.Buildable.BuildablePresetName, button.Buildable.BuildableTechName);
								buildablePreset.Team = self.Team;
								buildablePreset.Pos = self.renderPos;
								MovableMan:AddParticle(buildablePreset);
								if button.Buildable.Cost > 0 then
									self.Activity:SetTeamFunds(self.Activity:GetTeamFunds(self.Team) - button.Buildable.Cost, self.Team);
								end
								self.sounds.Confirm:Play(-1);
								self.selectDelayTime:Reset();
								print("Just placed the following: " .. button.Buildable.DisplayName);
							else
								self.sounds.Error:Play(-1);
								self.selectDelayTime:Reset();
							end
						end
					end
				end	-- CursorInside
				if self.cancelButton.isRemoving then
					button.Selected = false;
				end
			end	-- Think

			button.OnPress = function(key)
				if key == Controller.PRIMARY_ACTION then
					if button.IsResearched then
						if itemFund then
							self.sounds.Confirm:Play(-1);
							self.selectDelayTime:Reset();
							self.renderBox = button.Buildable.RenderSize;
							self.cancelButton.isRemoving = false;
							self.Menu.Cursor_Bitmap = "Data/Base.rte/GUIs/Skins/Cursor.png";
							for _, btn in ipairs(self.buttonBox:GetChildren()) do
								btn.Selected = false;
							end
							button.Selected = true;
						end
					else
						self.sounds.Error:Play(-1);
					end
				end
			end

			currentHeight = pos.Y + menu.DistOffset.Y;
			height = math.min(maxHeight, currentHeight);
		end -- for

		menu.Scroll = scroll or 0;
		menu.TotalRows = math.ceil(#menu.Buttons / menu.Rows);

		self.builderBox.Think = function()
			self.builderBox:SetSize(260, height + self.cancelButton:GetHeight());
			self.buttonBox:SetSize(self.builderBox:GetWidth(), self.builderBox:GetHeight());
			self.cancelButton:SetPos(5, self.builderBox:GetHeight() - self.cancelButton.Height);

			if height == maxHeight then
				local go_up = self.Menu.Controller:IsState(Controller.SCROLL_UP);
				local go_down = self.Menu.Controller:IsState(Controller.SCROLL_DOWN);

				if go_up then
					--Subtracts 1
					menu.Scroll = math.max(0, menu.Scroll - 1);
				elseif go_down then
					--Adds 1
					menu.Scroll = math.min(menu.TotalRows - menu.MaxRows, menu.Scroll + 1);
				end
				for i, button in pairs(self.buttonBox:GetChildren()) do
					local pos = menu.Offset;
					local row = math.floor((i - 1) / menu.Rows);
					local isVisible = row >= menu.Scroll and row < menu.Scroll + menu.MaxRows;
					local j = (i - 1) % menu.Rows;
					pos = pos + Vector(j * (menu.DistOffset.X or 0), row * (menu.DistOffset.Y or 0));
					button:SetPos(pos.X, pos.Y - menu.Scroll * menu.DistOffset.Y);
					button:SetVisible(isVisible);
				end
			end
		end
	end -- func

	function self:MenuChange(newMenu, addToHistory)
		if addToHistory == nil or addToHistory == true then
			table.insert(self.menuHistory, self.MenuCurrent);
		end
		self.MenuCurrent = newMenu;
		self:Populate(newMenu, 0);
	end
end

function DisplayNumber(self, screen, color, pos, text)
	for i = 1, string.len(text) do
		local digit = string.sub(text, i, i);
		PrimitiveMan:DrawBitmapPrimitive(pos + Vector((3 + 1) * (i - 1) + 1, 5),
		"CED.rte/Effects/Font/" .. color .. "/Numbers/" .. digit .. ".png", 0);
	end
end

function ThreadedUpdate(self)
	if self:IsPlayerControlled() then
		if self:NumberValueExists("BuilderMenu") and self.Menu:ToOpen(self, Controller.CIM_DISABLED) then
			BuilderMenu(self);
			self:RemoveNumberValue("BuilderMenu");
		end
	end

	if self.Menu:Update() then
		self.builderBox:Update();
		self.Menu:DrawCursor();
	end
end

function Destroy(self)
	self.Menu:Remove();
end