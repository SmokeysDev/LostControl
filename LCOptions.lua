local function CreateCheckButton(parent, checkBoxName, posX, posY, displayText, hoverDesc, relativeTo)
	local checkButton = CreateFrame("CheckButton", checkBoxName, parent, "InterfaceOptionsCheckButtonTemplate");
	if(relativeTo == nil) then checkButton:SetPoint("TOPLEFT", posX, posY);
	else checkButton:SetPoint("TOPLEFT",relativeTo,"BOTTOMLEFT",posX,posY); end
	checkButton:SetWidth(25)
	checkButton:SetHeight(25)
	checkButton.label = getglobal(checkButton:GetName() .. 'Text');
	checkButton.label:SetText(displayText);
	checkButton.tooltipText = displayText;
	checkButton.tooltipRequirement = hoverDesc;
	return checkButton;
end

local function CreateEditBox(parent, editBoxName, posX, posY, relativeTo, width, height)
	local editBox = CreateFrame("EditBox", editBoxName, parent, "InputBoxTemplate");
	if(relativeTo == nil) then editBox:SetPoint("TOPLEFT", posX, posY);
	else editBox:SetPoint("TOPLEFT",relativeTo,"BOTTOMLEFT",posX,posY); end
	if(type(width)~='number') then
		width = 150;
	end
	if(type(height)~='number') then
		height = 30;
	end
	editBox:SetWidth(width)
	editBox:SetHeight(height)
	return editBox;
end

local function CreateNumberInput(parent, editBoxName, posX, posY, relativeTo, width, height)
	local editBox = CreateFrame("EditBox", editBoxName, parent, "NumericInputSpinnerTemplate");
	if(relativeTo == nil) then editBox:SetPoint("TOPLEFT", posX, posY);
	else editBox:SetPoint("TOPLEFT",relativeTo,"BOTTOMLEFT",posX,posY); end
	if(type(width)~='number') then
		width = 150;
	end
	if(type(height)~='number') then
		height = 30;
	end
	editBox:SetWidth(width)
	editBox:SetHeight(height)
	return editBox;
end

local function CreateSliderInput(parent, editBoxName, posX, posY, relativeTo, width, height, min, max)
	local editBox = CreateFrame("SLIDER", editBoxName, parent, "HorizontalSliderTemplate");
	if(relativeTo == nil) then editBox:SetPoint("TOPLEFT", posX, posY);
	else editBox:SetPoint("TOPLEFT",relativeTo,"BOTTOMLEFT",posX,posY); end
	if(type(width)~='number') then
		width = 100;
	end
	if(type(height)~='number') then
		height = 30;
	end
	editBox:SetWidth(width)
	editBox:SetHeight(height)
	editBox:SetMinMaxValues(min, max)
	return editBox;
end

local function AddText(text,parent,font,locx,locy,relTo)
	local textEl = parent:CreateFontString(nil,"ARTWORK",font);
	textEl:SetText(text);
	if(relTo) then textEl:SetPoint("TOPLEFT",relTo,"BOTTOMLEFT",locx,locy);
	else textEl:SetPoint("TOPLEFT",locx,locy); end
	return textEl;
end

local function AddDropdown(parent,name,title,data,selFunc,checkedFunc,locx,locy,relTo)
	local dropDown = CreateFrame("Frame", "LCO_"..name, parent, "UIDropDownMenuTemplate")
	UIDropDownMenu_SetWidth(dropDown, 90);
	if(relTo) then dropDown:SetPoint("TOPLEFT", relTo, "TOPLEFT", locx, locy)
	else dropDown:SetPoint("TOPLEFT", locx, locy) end
	local dropDownValue = AddText("", parent, "GameFontHighlight", 128, 25, dropDown);
	dropDown.setLabel = function(text)
		getglobal(dropDown:GetName() .. 'Text'):SetText(text);
	end
	dropDown.showCurrentValue = function(text)
		dropDownValue:SetText("= "..text);
	end
	dropDown.setLabel(title);

	local updateCurrentValue = function()
		for k,d in ipairs(data) do
			local text = d[1];
			local value = d[2];
			if (checkedFunc(value) == true) then
				dropDown.showCurrentValue(text);
				return;
			end
		end
	end
	dropDown:SetScript("OnShow", function(self)
		updateCurrentValue();
	end);
	dropDown.initialize = function()
		local info = {};
		for k,d in ipairs(data) do
			info.text = d[1];
			info.value = d[2];
			info.func = function(self)
				selFunc(self);
				updateCurrentValue();
			end
			info.checked = checkedFunc(d[2]);
			UIDropDownMenu_AddButton(info);
		end
	end
	return dropDown;
end

function LCOptions(LostControlFrame)
	local O = LCU.addonName .. "OptionsPanel";
	LCU.optionsPanel = CreateFrame("Frame", O);
	local OptionsPanel = LCU.optionsPanel;
	OptionsPanel.name = LCU.addonName;
	OptionsPanel.elements = {};

	LCU.player.updateSpec();

	OptionsPanel.elements.title = AddText(LCU.addonName..' - '..LCcfg.getPlayerSpecRole()..' settings',OptionsPanel,"GameFontNormalLarge",16,-16);
	OptionsPanel:SetScript("OnShow", function()
		LCU.player.updateSpec();
		OptionsPanel.elements.title:SetText(LCU.addonName..' - '..LCcfg.getPlayerSpecRole()..' settings');
	end);
	local notes = GetAddOnMetadata(LCU.addonName,"Notes");
	OptionsPanel.elements.subTitle = AddText(notes,OptionsPanel,"GameFontHighlightSmall",0,-8,OptionsPanel.elements.title);
	OptionsPanel.elements.watchTypesTitle = AddText('Watch debuff types:',OptionsPanel,"GameFontNormal",0,-20,OptionsPanel.elements.subTitle);
	OptionsPanel.elements.chanDropsTitle = AddText('Channel Selections:',OptionsPanel,"GameFontNormal",310,12,OptionsPanel.elements.watchTypesTitle);
	OptionsPanel.elements.chanDropsNotice = AddText('AddOns can no longer SAY / YELL outside instances',OptionsPanel,"GameFontHighlightSmall",0,-8,OptionsPanel.elements.chanDropsTitle);

	local lastEl = OptionsPanel.elements.watchTypesTitle;
	-- Loop through debuff types and create watch checkboxes for them
	local i = 0;
	local debuffNames = {}
	for dbType in pairs(Debuffs.types) do table.insert(debuffNames,dbType); end
	table.sort(debuffNames);
	for _,dbType in ipairs(debuffNames) do
		local isOom = dbType == 'oom';
		local typeName = LCU.upperFirst(dbType);
		local elKey = 'watch'..typeName;
		local typeDesc = dbType..' effects';
		if(isOom) then
			typeName = 'OOM';
			typeDesc = 'OOM';
		end
		if(typeName == 'SpellLock') then
			typeName = 'Spell lock';
		end
		local locY = i==0 and -12 or -5;
		OptionsPanel.elements[elKey] = CreateCheckButton(OptionsPanel, "LCO_"..elKey, 0, locY, typeName, 'Enable watching for '..typeDesc, lastEl);
		if(isOom) then
			OptionsPanel.elements[elKey].tooltipText = 'Out Of Mana';
			OptionsPanel.elements[elKey].tooltipRequirement = OptionsPanel.elements[elKey].tooltipRequirement..'\nUse slider to select breakpoint';
			local extraElKey = 'oomBreakpoint';
			OptionsPanel.elements[extraElKey] = CreateSliderInput(OptionsPanel, "LCO_"..extraElKey, 125, -4, lastEl, 85, 25, 1, 99);
			local getCurrVal = function()
				return tonumber(LCcfg.get(extraElKey, 15, false));
			end
			local currValue = getCurrVal();
			local sliderLabel = AddText(currValue, OptionsPanel, 'GameFontHighlight', 96, -10, lastEl);
			OptionsPanel.elements[extraElKey]:SetValue(currValue);
			OptionsPanel.elements[extraElKey]:SetScript("OnShow", function(self)
				currValue = getCurrVal();
				self:SetValue(currValue);
				sliderLabel:SetText(currValue..'%');
			end);
			local updateValue = function(self, value)
				local old = LCcfg.get(extraElKey,nil,false);
				if(value == nil and old==nil) then
					return nil;
				else
					if(value == nil or value == 'nil') then
						value = nil;
					else
						value = tonumber(value);
					end
					value = LCU.round(value);
					if (tonumber(old) ~= value) then
						sliderLabel:SetText(value..'%');
						LCcfg.set(extraElKey,LCU.str(value));
					end
				end
			end
			OptionsPanel.elements[extraElKey]:SetScript("OnValueChanged",updateValue);
		end
		OptionsPanel.elements[elKey]:SetChecked(LCcfg.watching(dbType));
		OptionsPanel.elements[elKey]:SetScript("OnShow", function()
			OptionsPanel.elements[elKey]:SetChecked(LCcfg.watching(dbType));
		end);
		OptionsPanel.elements[elKey]:SetScript("OnClick",
			function()
				if(OptionsPanel.elements[elKey]:GetChecked()) then LCcfg.disableWatch(dbType,false);
				else LCcfg.disableWatch(dbType,true); end
			end
		);
		lastEl = OptionsPanel.elements[elKey];
		i = i+1;

		-- Add the min debuff dropdown
		if (not isOom) then
			local dbTimeElKey = elKey..'_minDebuffTime';
			OptionsPanel.elements[dbTimeElKey] = AddDropdown(OptionsPanel, 'LCO_'..dbTimeElKey, "Min length",
			{
				{"Global",nil}
				,{"Any",0}
				,{"2 sec",2}
				,{"3 sec",3}
				,{"4 sec",4}
				,{"5 sec",5}
			}
			,(function(self) LCcfg.setMinDebuffTime(self.value, dbType) end)
			,(function(val) return val==LCcfg.getMinDebuffTime(dbType, false) end)
			,85,2,lastEl);
		end
	end

	local watchFallingKey = 'watchFalling';
	OptionsPanel.elements[watchFallingKey] = CreateCheckButton(OptionsPanel, "LCO_"..watchFallingKey, 0, -5, 'Falling alert', 'Enable watching for your player falling', lastEl);
	OptionsPanel.elements[watchFallingKey]:SetChecked(LCcfg.watching('falling'));
	OptionsPanel.elements[watchFallingKey]:SetScript("OnShow", function()
		OptionsPanel.elements[watchFallingKey]:SetChecked(LCcfg.watching('falling'));
	end);
	OptionsPanel.elements[watchFallingKey]:SetScript("OnClick",
		function()
			if(OptionsPanel.elements[watchFallingKey]:GetChecked()) then LCcfg.disableWatch('falling',false);
			else LCcfg.disableWatch('falling',true); end
		end
	);
	lastEl = OptionsPanel.elements[watchFallingKey];

	OptionsPanel.elements.globalDebuffTimeLabel = AddText("Global", OptionsPanel,"GameFontHighlight",0,-20,lastEl);
	OptionsPanel.elements.debuffTime = AddDropdown(OptionsPanel,"debuffTime","Min length",
		{
			{"Any",0}
			,{"2 sec",2}
			,{"3 sec",3}
			,{"4 sec",4}
			,{"5 sec",5}
		}
		,(function(self) LCcfg.setMinDebuffTime(self.value) end)
		,(function(val) return val==LCcfg.getMinDebuffTime() end)
		, 40, 8, OptionsPanel.elements.globalDebuffTimeLabel);

	OptionsPanel.elements.instChat = AddDropdown(OptionsPanel,"instChat","Instances",
		{
			{"Say (/s)","SAY"}
			,{"Yell (/yell)","YELL"}
			,{"Party (/p)","PARTY"}
			,{"Instance (/i)","INSTANCE_CHAT"}
		}
		,(function(self) LCcfg.set('instanceChat',self.value) end)
		,(function(val) return val==LCcfg.get('instanceChat','PARTY') end)
		,-20,-25,OptionsPanel.elements.chanDropsNotice);

	OptionsPanel.elements.raidChat = AddDropdown(OptionsPanel,"raidChat","Raids",
		{
			{"Say (/s)","SAY"}
			,{"Yell (/yell)","YELL"}
			,{"Party (/p)","PARTY"}
			,{"Raid (/r)","RAID"}
		}
		,(function(self) LCcfg.set('raidChat',self.value) end)
		,(function(val) return val==LCcfg.get('raidChat','PARTY') end)
		,0,-35,OptionsPanel.elements.instChat);

	OptionsPanel:Hide();
	InterfaceOptions_AddCategory(OptionsPanel);

	OptionsPanel.childCategories = {};

	OptionsPanel.childCategories.messages = nil;

	local messageOptionsPanel = CreateFrame("Frame",LCU.addonName..'MessagesOptionsPanel');
	messageOptionsPanel.name = 'Custom Announcements';
	messageOptionsPanel.parent = LCU.addonName;
	messageOptionsPanel.elements = {};

	messageOptionsPanel.elements.title = AddText(LCU.addonName..' - Custom Announcements ('..LCcfg.getPlayerSpecRole()..')',messageOptionsPanel,"GameFontNormalLarge",16,-16);
	messageOptionsPanel:SetScript("OnShow", function()
		LCU.player.updateSpec();
		messageOptionsPanel.elements.title:SetText(LCU.addonName..' - Custom Announcements ('..LCcfg.getPlayerSpecRole()..')');
	end);
	messageOptionsPanel.elements.subTitle = AddText('Use the inputs below to customise the announcements. Leave blank to use the defaults.',messageOptionsPanel,"GameFontHighlightSmall",0,-8,messageOptionsPanel.elements.title);
	messageOptionsPanel.elements.subTitle2 = AddText('%TR = time remaining | %SL = spell link | %NM = char name | %RL = role',messageOptionsPanel,"GameFontHighlightSmall",0,-8,messageOptionsPanel.elements.subTitle);
	messageOptionsPanel.elements.subTitle3 = AddText('%REF = role and name e.g. "A DPS (charName)" or "The tank (charname)"',messageOptionsPanel,"GameFontHighlightSmall",0,-4,messageOptionsPanel.elements.subTitle2);

	lastEl = messageOptionsPanel.elements.subTitle3;

	messageOptionsPanel.elements.labelsColTitle = AddText('Debuff type',messageOptionsPanel,"GameFontNormal",0,-20,lastEl);
	messageOptionsPanel.elements.messageColTitle = AddText('Warn message',messageOptionsPanel,"GameFontNormal",100,-20,lastEl);
	messageOptionsPanel.elements.recoverMessageColTitle = AddText('Recover message',messageOptionsPanel,"GameFontNormal",300,-20,lastEl);
	messageOptionsPanel.elements.recoverMessageHint = AddText('Enter a dash (-) to disable',messageOptionsPanel,"GameFontHighlightSmall",420,-22,lastEl);

	lastEl = messageOptionsPanel.elements.labelsColTitle;

	-- Loop through debuff types and create watch checkboxes for them
	local i = 0;
	local debuffNames = {}
	for dbType in pairs(Debuffs.types) do table.insert(debuffNames,dbType); end
	table.sort(debuffNames);
	for _,dbType in ipairs(debuffNames) do
		local elKey = dbType..'Message';
		local locY = i==0 and -15 or -15;

		local labelText = LCU.upperFirst(dbType);
		if(labelText == 'Oom') then
			labelText = 'OOM';
		end
		if(labelText == 'SpellLock') then
			labelText = 'Spell lock';
		end
		messageOptionsPanel.elements[elKey..'Label'] = AddText(labelText,messageOptionsPanel,"GameFontHighlight",0,locY,lastEl);
		lastEl = messageOptionsPanel.elements[elKey..'Label'];

		messageOptionsPanel.elements[elKey] = CreateEditBox(messageOptionsPanel, "LCO_"..elKey, 105, 20, lastEl);
		messageOptionsPanel.elements[elKey]:SetText(LCU.str(LCcfg.get('db_message_'..dbType),''));
		messageOptionsPanel.elements[elKey]:SetScript("OnShow", function(self)
			self:SetText(LCU.str(LCcfg.get('db_message_'..dbType,'',false)));
		end);
		local updateValue = function(self)
			local theText = self:GetText();
			theText = LCU.trim(theText);
			local old = LCcfg.get('db_message_'..dbType,nil,false);
			if(theText == '' and old==nil) then
				return nil;
			else
				if(theText == '' or theText == 'nil') then theText = nil; end
				LCcfg.set('db_message_'..dbType,theText);
			end
		end
		messageOptionsPanel.elements[elKey]:SetScript("OnChar",updateValue);
		messageOptionsPanel.elements[elKey]:SetScript("OnHide",updateValue);
		messageOptionsPanel.elements[elKey]:SetScript("OnEditFocusLost",updateValue);

		elKey = dbType..'RecoverMessage';
		messageOptionsPanel.elements[elKey] = CreateEditBox(messageOptionsPanel, "LCO_"..elKey, 305, 20, lastEl);
		messageOptionsPanel.elements[elKey]:SetText(LCU.str(LCcfg.get('db_recovermessage_'..dbType),''));
		messageOptionsPanel.elements[elKey]:SetScript("OnShow", function(self)
			self:SetText(LCU.str(LCcfg.get('db_recovermessage_'..dbType,'',false)));
		end);
		local updateValue = function(self)
			local theText = self:GetText();
			theText = LCU.trim(theText);
			local old = LCcfg.get('db_recovermessage_'..dbType,nil,false);
			if(theText == '' and old==nil) then
				return nil;
			else
				if(theText == '' or theText == 'nil') then theText = nil; end
				LCcfg.set('db_recovermessage_'..dbType,theText);
			end
		end
		messageOptionsPanel.elements[elKey]:SetScript("OnChar",updateValue);
		messageOptionsPanel.elements[elKey]:SetScript("OnHide",updateValue);
		messageOptionsPanel.elements[elKey]:SetScript("OnEditFocusLost",updateValue);

		i = i+1;
	end

	messageOptionsPanel.elements.defaultFormatNote = AddText('An example format from the defaults (fear): %REF is feared for %TR seconds - %SL',messageOptionsPanel,"GameFontHighlightSmall",0,-25,lastEl);

	messageOptionsPanel:Hide();

	OptionsPanel.childCategories.messages = messageOptionsPanel;
	InterfaceOptions_AddCategory(OptionsPanel.childCategories.messages);
	return OptionsPanel;
end