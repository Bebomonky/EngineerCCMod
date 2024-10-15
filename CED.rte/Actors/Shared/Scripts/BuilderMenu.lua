require("Mods.Extensions.ExtensionMan");

function OnGlobalMessage(self, message, object)
	if message == tostring(self.Team) .. "_Research" then
		for i = 1, #self.category do
			local tab = self.category[i];
			local buildableList = tab[2];
			for j = 1, #buildableList do
				local buildable = buildableList[j];
				if buildable.ResearchName == object then
					self.researchList[i][j] = true;
				end
			end
		end
	end
end

function OnMessage(self, message, object)
	if message == tostring(self.Team) .. "_Research" then
		for i = 1, #self.category do
			local tab = self.category[i];
			local buildableList = tab[2];
			for j = 1, #buildableList do
				local buildable = buildableList[j];
				if buildable.ResearchName ~= nil and buildable.ResearchName == object then
					self.researchList[i][j] = true;
				end
			end
		end
	end
end

function Create(self)
	self.menu = table.Copy(require("Mods.Extensions.imenu.core"));
	self.menu:Initialize();

	self.sounds = {
		Confirm = CreateSoundContainer("Confirm", "Base.rte"),
		Error = CreateSoundContainer("Error", "Base.rte"),
	}

	if not self.PieMenu:GetFirstPieSliceByPresetName("BuilderMenu") then
		self.PieMenu:AddPieSlice(CreatePieSlice("BuilderMenu", "CED.rte"), self);
	end

	self.selectDelayTime = Timer();

	self.activity = ActivityMan:GetActivity();

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

	--TODO Fix offsets, look at code for 10 hours

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
			})
		end
	end

	self.buttons = {};
	self.menuHistory = {};

	self.menuCurrent = self:GetStringValue("MenuCurrent") and self.menuData[self:GetStringValue("MenuCurrent")] or nil;

	function self:Populate(menu, scroll)
		self.buttons = {};

		local rows = 3;
		local maxHeight = 295;
		local currentHeight = 40;
		local height = currentHeight;

		self.renderBox = nil;
		self.renderPos = Vector();

		local textWidth = 0;
		local textWidth_price = 0;
		local oz_width = 0;
		local textPos = Vector();
		local itemFund = false;

		local validPlacement = false;
		local tolerance = 0.1;

		local perRow = menu.Rows;
		for i, menuButton in ipairs(menu.Buttons) do
			local pos = Vector(self.builderBox:GetPos()) + menu.Offset;
			local row = math.floor((i - 1) / perRow);
			local j = ((i - 1) % perRow);
			pos = pos + Vector(j * (menu.DistOffset.X or 0), row * (menu.DistOffset.Y or 0));

			local button = self.menu:CreateGUI("Button");
			button.Buildable = menuButton.Buildable;
			button.Selected = false;
			button.HasThickness = true;
			button:SetPos(pos.X, pos.Y);
			button:SetSize(65, 65);
			button:SetText(button.Buildable.DisplayName);
			button:TextPos(0, 10);
			button:Color(146);
			button:OutlineColor(144);
			button:OutlineThickness(2);

			button.Think = function(entity, screen)
				local offset = CameraMan:GetOffset(screen);
				local world_pos = Vector(button:GetPos()) + offset;
				local hasFund = self.activity:GetTeamFunds(entity.Team) >= button.Buildable.Cost;
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

				if button.IsHovered then
					itemFund = self.activity:GetTeamFunds(entity.Team) >= button.Buildable.Cost;
					self.tooltip:SetVisible(true);

					if self.tooltip.Displaying == false then
						local size = button.Buildable.TooltipSize;
						self.tooltip:SetSize(size.X, size.Y);
						self.tooltip:SetTitle(button.Buildable.DisplayName);

						textWidth = FrameMan:CalculateTextWidth(button.Buildable.DisplayName .. " ", true);
						if button.Buildable.Cost > 0 then
							textWidth_price = FrameMan:CalculateTextWidth(tostring(button.Buildable.Cost), true);
							oz_width = FrameMan:CalculateTextWidth("oz", true);
						else
							textWidth_price = FrameMan:CalculateTextWidth("FREE", true);
						end
						textPos = offset + Vector(textWidth, 0) + Vector(self.tooltip:GetPosX() + 10, self.tooltip:GetPosY() + 25);
						self.tooltip.Displaying = true;
					end

					PrimitiveMan:DrawTextPrimitive(screen, textPos, "(", true, 0)
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

				PrimitiveMan:DrawBitmapPrimitive(screen, world_pos + Vector(button:GetSize()) / 2 + button.Buildable.IconPos, button.Buildable.IconPath, 0);

				if not self.menu:cursor_inside(Vector(self.builderBox:GetPos()) + offset, Vector(self.builderBox:GetSize())) and button.Selected then
					local size = (Vector(self.renderBox.Width, self.renderBox.Height) / 2);
					self.renderPos = self.menu.Cursor;

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
						if self.menu.Controller then
							if self.menu.Controller:IsState(Controller.PRIMARY_ACTION) then
								if validPlacement then
									local createFunc = "Create" .. button.Buildable.BuildableClassName;
									local buildablePreset = _G[createFunc](button.Buildable.BuildablePresetName, button.Buildable.BuildableTechName);
									buildablePreset.Team = entity.Team;
									buildablePreset.Pos = self.renderPos;
									MovableMan:AddParticle(buildablePreset);
									if button.Buildable.Cost > 0 then
										self.activity:SetTeamFunds(self.activity:GetTeamFunds(entity.Team) - button.Buildable.Cost, entity.Team);
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
					end
				end	-- cursor_inside
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
							self.menu.Cursor_Bitmap = "Data/Base.rte/GUIs/Skins/Cursor.png";
							for _, btn in ipairs(self.buttons) do
								btn.Selected = false;
							end
							button.Selected = true;
						end
					else
						self.sounds.Error:Play(-1);
					end
				end
			end

			table.insert(self.buttons, button);

			currentHeight = pos.Y + menu.DistOffset.Y;
			height = math.min(maxHeight, currentHeight);
		end -- for

		menu.Scroll = scroll or 0;
		menu.TotalRows = math.ceil(#menu.Buttons / menu.Rows);

		self.builderBox.Think = function(entity, screen)
			self.builderBox:SetSize(260, height + self.cancelButton:GetHeight());
			self.cancelButton:SetPos(5, self.builderBox:GetHeight() - 20);

			if self.menu.Controller then
				--Without this if statement it will scroll regardless
				if height == maxHeight then
					local go_up = self.menu.Controller:IsState(Controller.SCROLL_UP);
					local go_down = self.menu.Controller:IsState(Controller.SCROLL_DOWN);

					if go_up then
						--Subtracts 1
						menu.Scroll = math.max(0, menu.Scroll - 1);
					elseif go_down then
						--Adds 1
						menu.Scroll = math.min(menu.TotalRows - menu.MaxRows, menu.Scroll + 1);
					end
					for i = 1, #self.Buttons do
						local button = self.Buttons[i];
						if button then
							local pos = Vector(self.builderBox:GetPos()) + menu.Offset;
							local row = math.floor((i - 1) / menu.Rows);
							local isVisible = row >= menu.Scroll and row < menu.Scroll + menu.MaxRows;
							local j = (i - 1) % menu.Rows;
							pos = pos + Vector(j * (menu.DistOffset.X or 0), row * (menu.DistOffset.Y or 0));
							button:SetPos(pos.X, pos.Y - menu.Scroll * menu.DistOffset.Y);
							button:SetVisible(isVisible);
						end
					end
				end
			end
		end
	end -- func

	function self:MenuChange(newMenu, addToHistory)
		if addToHistory == nil or addToHistory == true then
			table.insert(self.menuHistory, self.menuCurrent);
		end
		self.menuCurrent = newMenu;
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

function BuilderMenu(self)
	self.builderBox = self.menu:CreateGUI("CollectionBox");
	self.builderBox:SetTitle("");
	self.builderBox:SetPos(10, 25);
	self.builderBox:SetSize(260, 50);
	self.builderBox:Color(146);
	self.builderBox:OutlineColor(71);
	self.builderBox:OutlineThickness(2);

	--When a buildable is selected
	self.renderBox = nil;
	self.renderPos = Vector();

	self.cancelButton = self.menu:CreateGUI("Button", self.builderBox);
	self.cancelButton:SetPos(5, self.cancelButton:GetParent():GetHeight() - 20);
	self.cancelButton:SetSize(26, 16);
	self.cancelButton:SetText("Remove\nBuild");
	self.cancelButton:TextPos(1, -4);
	self.cancelButton:Color(146);
	self.cancelButton:OutlineColor(144);
	self.cancelButton:OutlineThickness(2);
	self.cancelButton.isRemoving = false;

	self.cancelButton.Think = function(entity, screen)
		self.cancelButton:OutlineColor(self.cancelButton.IsHovered and 117 or 144);

		if self.cancelButton.isRemoving then
			local MOs = MovableMan:GetMOsInRadius(self.menu.Cursor, 15, -1, false);
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
							self.menu.Cursor = mo.Pos;

							--I think it's a good idea to set it once instead of constantly
							if self.renderBox == nil then
								self.renderBox = buildable.RenderSize;
							end
							local size = (Vector(self.renderBox.Width, self.renderBox.Height) / 2);
							self.renderPos = mo.Pos;
							PrimitiveMan:DrawPrimitives(50, {
								BoxFillPrimitive(screen, self.renderPos + self.renderBox.Corner, self.renderPos + size, 13),
							});

							if self.menu.Controller then 
								if self.menu.Controller:IsState(Controller.PRIMARY_ACTION) then
									self.sounds.Error:Play(-1);
									self.menu.Cursor_Bitmap = "Data/Base.rte/GUIs/Skins/Cursor.png";
									self.cancelButton.isRemoving = false;
									mo:SendMessage("CED_CancelBuildable");
								end
							end
						end
					end
				end
			end
		end
	end

	self.cancelButton.OnPress = function(key)
		if key == Controller.PRIMARY_ACTION then
			self.menu.Cursor_Bitmap = "Mods/CED.rte/Actors/Shared/Sprites/Menus/CancelCursor.png";
			self.renderBox = nil;
			self.cancelButton.isRemoving = true;
		end
	end

	self.tooltip = self.menu:CreateGUI("CollectionBox", self.builderBox);
	self.tooltip:SetTitle("");
	self.tooltip:SetPos(self.tooltip:GetParent():GetWidth() + 10, 25);
	self.tooltip:SetSize(100, 75);
	self.tooltip:Color(146);
	self.tooltip:OutlineColor(71);
	self.tooltip:OutlineThickness(2);
	self.tooltip:SetVisible(false); --Set to false to prevent flicker
	self.tooltip.Displaying = false;

	self.tooltipDesc = self.menu:CreateGUI("Label", self.tooltip);
	self.tooltipDesc:SetPos(10, 10);
	self.tooltipDesc:SmallText(true);
	self.tooltipDesc:SetContentAlignment(1);

	self.tooltip.Think = function(entity, screen)
		self.tooltip:SetVisible(false)
	end

	--Bitmap will be modifed so we need to make sure it's always default
	self.menu.Cursor_Bitmap = "Data/Base.rte/GUIs/Skins/Cursor.png";

	local categoryRows = 4
	for i = 1, #self.category do
		local tab = self.category[i];
		local name = tab[1];
		local buildableList = tab[2];
		local tabTemplate = tab[3];

		local x = self.builderBox:GetPosX() + ((i - 1) % categoryRows) * 65;
		local y = self.builderBox:GetPosY() - (math.floor((i - 1) / categoryRows) + 1) * 35;

		local tab = self.menu:CreateGUI("Button", self.builderBox);
		tab.BuildList = buildableList;
		tab.Index = i;
		tab:SetPos(x - 3, y + 13);
		tab:SetSize(50, 13);
		tab:SetText(name);
		tab:Color(146);
		tab:OutlineColor(144);
		tab:OutlineThickness(2);

		tab.Think = function(entity, screen)
			tab:OutlineColor(tab.IsHovered and 117 or 144);
		end

		tab.OnPress = function(key)
			if key == Controller.PRIMARY_ACTION then
				if table.IsEmpty(tab.BuildList) then
					print("Table is empty!");
					self.errorSound:Play(-1);
					return;
				end

				self:MenuChange(self.menuData[name], false);
			end
		end
	end

	if self.menuCurrent then
		self:Populate(self.menuCurrent, self.menuCurrent.Scroll);
	end
end

function ThreadedUpdate(self)
	if self:IsPlayerControlled() then
		if self:NumberValueExists("BuilderMenu") then
			self.menu:New(self, BuilderMenu);
			self:RemoveNumberValue("BuilderMenu");
		end
	else
		self.menu:Remove();
	end
	if self.menu:Update(self) then
		self.builderBox:Update(self, {Cursor = self.menu.Cursor});
		if self.menuCurrent then
			for i = 1, #self.buttons do
				local button = self.buttons[i];
				if button then
					button:Update(self, {Cursor = self.menu.Cursor});
				end
			end
		end
	    self.menu:DrawCursor(self.menu.Screen);
	end
end

function Destroy(self)
	self.menu:Remove();
end