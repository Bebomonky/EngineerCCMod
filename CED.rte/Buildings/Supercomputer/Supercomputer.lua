require("Mods.Extensions.ExtensionMan");
require("MasterList");

function Create(self)
	self.Menu = require("Mods.Extensions.imenu.core");
	self.Menu:Initialize();
	self.menuCreated = false;

	self.sounds = {
		Confirm = CreateSoundContainer("Confirm", "Base.rte"),
		Error = CreateSoundContainer("Error", "Base.rte"),
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

	self.menuData = {
		Main = {
			Buttons = {}
		};
	};

	for techID, faction in pairs(CEDMasterList.Technology) do
		self.menuData[techID] = {
			Buttons = {}
		};
	end

	self.menuHistory = {};

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
	--[[
	self.TechProgress = {}

	self.ActivePBar = 0
	for i = 1, #self.CEDAvailableTechnology do
		local tech = self.CEDAvailableTechnology[i]
		self.TechProgress[i] =
		{
			Timer = Timer(),
			SavedElapsedSimTimeMS = 0,
			InProgress = false,
			IsResearched = self.technologyController:NumberValueExists(tech.ResearchName) and true or false,
			PBarActive = false,
			PBarVisible = false,
			PBarFraction = 0,
			ButtonText = self.technologyController:NumberValueExists(tech.ResearchName) and tech.DisplayName:gsub("^%w+", "Researched!") or tech.DisplayName,
			PBar = nil,
			Button = nil
		}
	end

	self.ActiveResearch = false
	]]
end

function DisplayNumber(self, screen, color, pos, text)
	for i = 1, string.len(text) do
		local digit = string.sub(text, i, i);
		PrimitiveMan:DrawBitmapPrimitive(screen, pos + Vector((3 + 1) * (i - 1) + 1, 5),
		"CED.rte/Effects/Font/" .. color .. "/Numbers/" .. digit .. ".png",
		0);
	end
end

local function CC_TooltipSkin(gui)
	gui:Color(93);
	gui:OutlineColor(70);
	gui:OutlineThickness(1);
	local w = gui:GetWidth();
	local h = gui:GetHeight();
	local outlines = {
		{Vector(w + 2, 0), Vector(0, h + 2), false, 21},
		{Vector(0, h + 2), Vector(w + 2, 0), false, 21},
		{Vector(0, 0), Vector(0, h), true, 21},
		{Vector(0, 0), Vector(w, 0), true, 21},
		{Vector(w, 1), Vector(0, h - 1), true, 59},
		{Vector(1, h), Vector(w - 1, 0), true, 59},
	};

	for i = 1, #outlines do
		local pos = outlines[i][1];
		local size = outlines[i][2];
		local drawAfterParent = outlines[i][3];
		local color = outlines[i][4];
		local outline = gui:Add("COLLECTIONBOX");
		outline:SetTitle("");
		outline:SetPos(pos.X, pos.Y);
		outline:SetSize(size.X, size.Y)
		outline:Color(color);
		outline:DrawAfterParent(drawAfterParent);
		outline:OutlineThickness(0);
		outline.Think = function()
			outline:SetPos(pos.X, pos.Y);
			outline:SetSize(size.X, size.Y)
		end
	end
end

function ResearchMenu(self)
	self.researchBox = self.Menu:CreateGUI("COLLECTIONBOX")
	self.researchBox:SetTitle("");
	self.researchBox:SetPos(10, 25);
	self.researchBox:SetSize(400, 300);
	self.researchBox:Color(146);
	self.researchBox:OutlineColor(71);
	self.researchBox:OutlineThickness(2);
	local screen = self.researchBox:GetScreen();

	self.tooltip = self.Menu:CreateGUI("COLLECTIONBOX");
	self.tooltip:SetHide(true);
	self.tooltip:SetTitle("");
	self.tooltip.Displaying = false;
	self.tooltip.Timer = Timer();
	self.tooltip.Timer:SetSimTimeLimitMS(100);
	CC_TooltipSkin(self.tooltip);
	self.tooltip.Think = function()
		if not self.tooltip.Displaying then
			self.tooltip:SetHide(true);
			self.tooltip.Timer:Reset();
		end
	end

	local tabs = {};
	local i = 1;
	local totalWidth = 0;
	local width = 50;
	local height = 40;
	local spacing = 65;
	for techID, faction in SortedPairs(CEDMasterList.Technology) do
		local totalWidth = (i * width) + spacing * 3;
		local x = (self.researchBox:GetWidth() - totalWidth) / 2;
		local tab = self.researchBox:Add("BUTTON");
		tab:SetName("Category " .. i);
		tab:SetPos(x + (i - 1) * (width + spacing), 10);
		tab:SetSize(width, height);
		tab:SetText(techID);
		tab:Color(146);
		tab:OutlineColor(144);
		tab:OutlineThickness(2);
		tab.Faction = faction;
		tab.Selected = false;

		tab.Think = function()
			tab:OutlineColor(tab:IsHovered() and 117 or 144);

			if tab.Selected then
				tab:OutlineColor(252);
			end
		end

		tab.OnPress = function(key)
			if key == Controller.PRIMARY_ACTION then
				if table.IsEmpty(tab.Faction) then
					print("Table is empty!");
					self.sounds.Error:Play(-1);
					return
				end

				for _, btn in ipairs(tabs) do
					btn.Selected = false;
				end
				tab.Selected = true;
				self:MenuChange(self.menuData[techID], false);
			end
		end
		table.insert(tabs, tab);
		i = i + 1;

		for itemID, item in SortedPairs(faction) do
			local pos = Vector();
			local button = self.researchBox:Add("BUTTON");
			button.Faction = faction;
			button:SetVisible(false);
			button:SetPos(pos.X + 100, pos.Y + 50);
			button:SetSize(40, 25);
			button:SetText("");
			button:Color(146);
			button:OutlineColor(144);
			button:OutlineThickness(2);
			button.Researched = false;
			--! TEMPORARY, WILL BE REPLACED WITH BUY ICONS
			button.Item = item;
			local itemPreset = _G["Create" .. button.Item.ItemClassName](button.Item.ItemPresetName, button.Item.ItemTechName);
			local width = ToMOSprite(itemPreset):GetSpriteWidth();
			local height = ToMOSprite(itemPreset):GetSpriteHeight();
			button:SetSize(width, height);
			itemPreset = nil; --No longer need it since we just wanted the sprite size
			button.Think = function()
				local world_pos = button:GetAbsolutePos();
				if button:IsHovered() then
					if self.tooltip.Displaying == false then
						local x = (pos.X + button:GetWidth()) + 125;
						local y = pos.Y + 75;
						self.tooltip:SetPos(x, y);
					end
					if self.tooltip.Timer:IsPastSimTimeLimit() then
						self.tooltip:SetHide(false);
					end
					self.tooltip.Displaying = true;
				else
					self.tooltip.Displaying = false;
				end
				PrimitiveMan:DrawBitmapPrimitive(screen, world_pos + button:GetSize() / 2, button.Item.IconPath, 0);
			end
			table.insert(self.menuData[techID].Buttons, button);
		end
	end

	if self.MenuCurrent then
		self:MenuChange(self.MenuCurrent, false);
	end

	return true;
end
--[[
function SupercomputerTechMenu(self)
	self.Main.Box = self.Menu:CreateGUI("CollectionBox")
	self.Main.Box:SetTitle("")
	self.Main.Box:SetPos(10, 25)
	self.Main.Box:SetSize(260, 50)
	self.Main.Box:Color(146)
	self.Main.Box:OutlineColor(71)
	self.Main.Box:OutlineThickness(2)

	local rows = 3
	local maxHeight = 295
	local height = 0
	local posMultiplier = 85

	local textWidth = 0
	local textWidth_price = 0
	local oz_width = 0
	local textPos = Vector()
	local itemFund = false

	local function drawMenu()

		local currentHeight = 40
		height = math.max(height, currentHeight)

		local scroll = 0
		local totalRows = math.ceil(#self.CEDAvailableTechnology / rows)

		local tooltip_bar = self.Menu:CreateGUI("CollectionBox", self.Main.Box)
		tooltip_bar:SetTitle("")
		tooltip_bar:SetPos(tooltip_bar:GetParent():GetWidth() + 10, 25)
		tooltip_bar:SetSize(100, 75)
		tooltip_bar:Color(146)
		tooltip_bar:OutlineColor(71)
		tooltip_bar:OutlineThickness(2)
		tooltip_bar:SetVisible(false) --Set to false to prevent flicker
	
		local desc = self.Menu:CreateGUI("Label", tooltip_bar)
		desc:SmallText(true)
		desc:SetContentAlignment(1)
		desc:SetPos(desc:GetPosX() + 10, desc:GetPosY() + 10)
		desc:SetVisible(false)
	
		desc.Think = function(entity, screen)
			desc:SetVisible(false)
		end
	
		tooltip_bar.Think = function(entity, screen)
			tooltip_bar:SetVisible(false)
		end

		local buttons = {}
		for i = 1, #self.CEDAvailableTechnology do
			local x = 0 + self.Main.Box:GetPosX() + ((i - 1) % rows + 1 - 1) * posMultiplier
			local y = 10 + (math.floor((i - 1) / rows ) + 1 - 1) * posMultiplier

			self.TechProgress[i].Button = self.Menu:CreateGUI("Button", self.Main.Box)
			self.TechProgress[i].Button.Technology = self.CEDAvailableTechnology[i]
			self.TechProgress[i].Button.InProgress = self.TechProgress[i].InProgress
			self.TechProgress[i].Button:SetPos(x, y)
			self.TechProgress[i].Button:SetSize(65, 65)
			self.TechProgress[i].Button:SetText(self.TechProgress[i].ButtonText)
			self.TechProgress[i].Button:TextPos(0, 10)
			self.TechProgress[i].Button:Color(146)
			self.TechProgress[i].Button:OutlineColor(144)
			self.TechProgress[i].Button:OutlineThickness(2)

			self.TechProgress[i].PBar = self.Menu:CreateGUI("ProgressBar", self.TechProgress[i].Button)
			self.TechProgress[i].PBar.IsProgressBar = true
			self.TechProgress[i].PBar:SetPos(14, 30)
			self.TechProgress[i].PBar:SetSize(self.TechProgress[i].Button:GetWidth() - 8, 10)
			self.TechProgress[i].PBar:BGColor(146)
			self.TechProgress[i].PBar:FGColor(117)
			self.TechProgress[i].PBar:OutlineColor(144)
			self.TechProgress[i].PBar:DrawAfterParent(true)
			self.TechProgress[i].PBar:SetVisible(self.TechProgress[i].PBarVisible)
			self.TechProgress[i].PBar.Timer = Timer()
			self.TechProgress[i].PBar.Timer.ElapsedSimTimeMS = self.TechProgress[i].SavedElapsedSimTimeMS
			self.TechProgress[i].PBar.Active = self.TechProgress[i].PBarActive
			self.TechProgress[i].PBar:SetFraction(self.TechProgress[i].PBarFraction)
			self.TechProgress[i].PBar.Delay = self.TechProgress[i].Button.Technology.Delay

			--This is the greatest isUpdated of all time
			--This is to prevent a visual bug for the Progessbar when it doesn't show for the first time (while in progress)
			local isUpdated = false
			self.TechProgress[i].PBar.Think = function(entity, screen)
				if not isUpdated then
					self.TechProgress[i].PBar:SetFraction(self.TechProgress[i].PBarFraction)
					isUpdated = true
				end
			end

			self.TechProgress[i].Button.Think = function(entity, screen)
				local offset = CameraMan:GetOffset(screen)
				local hasFund = self.Activity:GetTeamFunds(entity.Team) >= self.TechProgress[i].Button.Technology.Cost

				self.TechProgress[i].Button:Color(hasFund and 146 or 248)

				if self.TechProgress[i].Button.IsHovered then
					itemFund = self.Activity:GetTeamFunds(entity.Team) >= self.TechProgress[i].Button.Technology.Cost
					tooltip_bar:SetVisible(true)
					desc:SetVisible(true)
					if tooltip_bar:GetTitle() ~= self.TechProgress[i].Button.Technology.DisplayName then
						local size = self.TechProgress[i].Button.Technology.TooltipSize
						tooltip_bar:SetSize(size.X, size.Y)
						desc:SetSize(size.X, size.Y)
						desc:SetText(self.TechProgress[i].Button.Technology.Description)
						tooltip_bar:SetTitle(self.TechProgress[i].Button.Technology.ResearchName)

						textWidth = FrameMan:CalculateTextWidth(self.TechProgress[i].Button.Technology.ResearchName .. " ", true)
						textWidth_price = FrameMan:CalculateTextWidth(tostring(self.TechProgress[i].Button.Technology.Cost), true)
						oz_width = FrameMan:CalculateTextWidth("oz", true)
						textPos = offset + Vector(textWidth, 0) + Vector(tooltip_bar:GetPosX() + 10, tooltip_bar:GetPosY() + 25)
					end

					PrimitiveMan:DrawTextPrimitive(screen, textPos, "(", true, 0)
					DisplayNumber(self, screen,
					itemFund and "Green" or "Red",
					textPos + Vector(4, 0),
					tostring(self.TechProgress[i].Button.Technology.Cost))

					PrimitiveMan:DrawTextPrimitive(screen, textPos + Vector(4 + textWidth_price, 0), "oz", true, 0)
					PrimitiveMan:DrawTextPrimitive(screen,
					textPos + Vector(4 + textWidth_price + oz_width, 0), ")",
					true,
					0)

					if self.TechProgress[i].IsResearched == true then
						self.TechProgress[i].Button:Color(249)
					else
						self.TechProgress[i].Button:OutlineColor(itemFund and 117 or 13)

						self.TechProgress[i].Button:Color(itemFund and 127 or 249)
					end
				else
					if self.TechProgress[i].IsResearched == true then
						self.TechProgress[i].Button:Color(249)
					else
						self.TechProgress[i].Button:OutlineColor(144)
					end
				end
				if self.TechProgress[i].Button.InProgress then
					self.TechProgress[i].SavedElapsedSimTimeMS = self.TechProgress[i].PBar.Timer.ElapsedSimTimeMS
				end
			end

			self.TechProgress[i].Button.OnPress = function(key)
				if key == Controller.PRIMARY_ACTION then
					if self.ActiveResearch == true then
						self.ErrorSound:Play(-1)
					else
						if itemFund then
							if self.TechProgress[i].IsResearched == false and self.TechProgress[i].Button.InProgress == false then
								self.Activity:SetTeamFunds(self.Activity:GetTeamFunds(self.Team) - self.TechProgress[i].Button.Technology.Cost, self.Team)
								self.ConfirmSound:Play(-1)
								self.TechProgress[i].PBar:SetVisible(true)
								self.TechProgress[i].PBar.Timer:Reset()
								self.TechProgress[i].PBar.Active = true
								self.ActivePBar = i
								self.ActiveResearch = true
								self.TechProgress[i].InProgress = true
								self.TechProgress[i].PBarActive = true
								self.TechProgress[i].PBarVisible = true
								self.TechProgress[i].Button.InProgress = true
							else
								self.ErrorSound:Play(-1)
							end
						else
							self.ErrorSound:Play(-1)
						end
					end
				end
			end

			currentHeight = y + posMultiplier
			height = math.min(maxHeight, currentHeight)
		end

		self.cancel_button = self.Menu:CreateGUI("Button", self.Main.Box)
		self.cancel_button:SetPos(5, self.cancel_button:GetParent():GetHeight() - 20)
		self.cancel_button:SetSize(26, 16)
		self.cancel_button:SetText("Cancel\nResearch")
		self.cancel_button:TextPos(1, -4)
		self.cancel_button:Color(146)
		self.cancel_button:OutlineColor(144)
		self.cancel_button:OutlineThickness(2)

		self.cancel_button.Think = function(entity, screen)
			self.cancel_button:OutlineColor(self.cancel_button.IsHovered and 117 or 144)
		end

		self.cancel_button.OnPress = function(key)
			if key == Controller.PRIMARY_ACTION then
				for i = 1, #self.TechProgress do
					local button = self.TechProgress[i].Button
					local pBar = self.TechProgress[i].PBar
					if button.InProgress then
						self.Activity:SetTeamFunds(self.Activity:GetTeamFunds(self.Team) + button.Technology.Cost, self.Team)
						pBar:SetVisible(false)
						pBar.Active = false
						self.ActiveResearch = false
						self.TechProgress[i].InProgress = false
						self.TechProgress[i].PBarActive = false
						self.TechProgress[i].PBarVisible = false
						self.TechProgress[i].PBarFraction = 0
						pBar:SetFraction(0)
						pBar:SetText("")
						button.InProgress = false
					end
				end
			end
		end

		self.Main.Box.Think = function(entity, screen)
			for i = 1, #self.TechProgress do
				if self.TechProgress[i].IsResearched == true then
					self.TechProgress[i].Button:SetText(self.TechProgress[i].ButtonText)
					if self.TechProgress[i].InProgress == true then
						self.TechProgress[i].ButtonText = self.TechProgress[i].Button:GetText():gsub("^%w+", "Researched!")
						self.TechProgress[i].Button:OutlineThickness(0)
						self.TechProgress[i].PBarVisible = false
						self.TechProgress[i].PBar:SetVisible(false)
						self.TechProgress[i].InProgress = false
					end
				end
			end
			self.Main.Box:SetSize(260, height + self.cancel_button:GetHeight())
			self.cancel_button:SetPos(5, self.Main.Box:GetHeight() - 20)

			if self.Menu.Controller then
				--Without this if statement it will scroll regardless
				if height == maxHeight then
					local go_up = self.Menu.Controller:IsState(Controller.SCROLL_UP)
					local go_down = self.Menu.Controller:IsState(Controller.SCROLL_DOWN)

					if go_up then
						--Subtracts 1
						scroll = math.max(0, scroll - 1)
					elseif go_down then
						--Adds 1
						scroll = math.min(totalRows - rows, scroll + 1)
					end

					for i = 1, #self.CEDAvailableTechnology do
						local row = math.floor((i - 1) / rows) + 1
						local isVisible = row >= scroll + 1 and row < scroll + 1 + rows
						--Everything that is parented to self.Main.Box is a key string
						local button = self.TechProgress[i].Button
						if button then --If it somehow doesn't exist wtf

							local x = 0 + self.Main.Box:GetPosX() + ((i - 1) % rows + 1 - 1) * posMultiplier
							local y = 10 + (math.floor((i - 1) / rows ) + 1 - 1) * posMultiplier
							button:SetPos(x, y - scroll * posMultiplier)
							button:SetVisible(isVisible)
						end
					end
				end
			end
		end
	end

	drawMenu()
end
]]

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
		self.tooltip:Update();
		self.Menu:DrawCursor();
	end

	--[[
	if self:IsPlayerControlled() then
		if not self.Menu.Open then
			self.Main = {};
			self.Menu:New(self, self.MenuFunc[1]);
		end
	else
		self.Menu:Remove()
	end

	if self.ActiveResearch == true then
		for i = 1, #self.CEDAvailableTechnology do
			if i == self.ActivePBar then
				local pBar = self.TechProgress[i].PBar
				if pBar and pBar.IsProgressBar then --goofy ahhh check
					if self.TechProgress[i].PBarActive == true then
						if pBar.Timer:IsPastSimMS(pBar.Delay) then
							self.TechProgress[i].PBarFraction = self.TechProgress[i].PBarFraction + 0.05
							pBar:SetFraction(self.TechProgress[i].PBarFraction)
							pBar.Timer:Reset()
						end
						pBar:SetText(string.format("%.0f%%", self.TechProgress[i].PBarFraction * 100))

						if self.TechProgress[i].PBarFraction >= 0.99 then
							pBar.Active = false
							self.TechProgress[i].PBarActive = false
							self.TechProgress[i].IsResearched = true
							self.technologyController:SendMessage("CED_UnlockTechnology", self.TechProgress[i].Button.Technology.ResearchName)
							self.ActiveResearch = false
							self.TechProgress[i].PBarFraction = 0
						end
					end
				end
			end
		end
	end

	--This is to prevent menu resize bugs
	local dontUpdateMenu = false
	for _, input in pairs({Controller.SECONDARY_ACTION, Controller.ACTOR_NEXT_PREP, Controller.ACTOR_PREV_PREP}) do
		if self:GetController():IsState(input) then
			dontUpdateMenu = true
			break
		end
	end
	if dontUpdateMenu == false then
		if self.Menu:Update(self) then
			for k, gui in pairs(self.Main) do
				gui:Update(self, {Cursor = self.Menu.Cursor})
			end
			self.Menu:DrawCursor(self.Menu.Screen)
		end
	end
	]]
end

function Destroy(self)
	self.Menu:Remove();
end

function OnSave(self)
	self:SetStringValue("CEDSupercomputerResearch", self.saveLoadHandler:SerializeTable(self.Researches));
end