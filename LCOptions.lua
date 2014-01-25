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

local function AddText(text,parent,font,locx,locy,relTo)
	local textEl = parent:CreateFontString(nil,"ARTWORK",font);
	textEl:SetText(text);
	if(relTo) then textEl:SetPoint("TOPLEFT",relTo,"BOTTOMLEFT",locx,locy);
	else textEl:SetPoint("TOPLEFT",locx,locy); end
	return textEl;
end

function LCOptions(LostControlFrame)
	local O = LCU.addonName .. "OptionsPanel";
	local OptionsPanel = CreateFrame("Frame", O);
	OptionsPanel.name = LCU.addonName;
	OptionsPanel.elements = {};

	OptionsPanel.elements.title = AddText(LCU.addonName,OptionsPanel,"GameFontNormalLarge",16,-16);
	local notes = GetAddOnMetadata(LCU.addonName,"Notes");
	OptionsPanel.elements.subTitle = AddText(notes,OptionsPanel,"GameFontHighlightSmall",0,-8,OptionsPanel.elements.title);
	OptionsPanel.elements.watchTypesTitle = AddText('Watch debuff types:',OptionsPanel,"GameFontNormal",0,-20,OptionsPanel.elements.subTitle);

	local lastEl = OptionsPanel.elements.watchTypesTitle;
	-- Loop through debuff types and create watch checkboxes for them
	for dbType in pairs(Debuffs.types) do
		local elKey = 'watch'..LCU.upperFirst(dbType);
		OptionsPanel.elements[elKey] = CreateCheckButton(OptionsPanel, "LCO_"..elKey, 0, -8, LCU.upperFirst(dbType), 'Enable watching for '..dbType..' effects', lastEl);
		OptionsPanel.elements[elKey]:SetChecked(LCcfg.watching(dbType));
		OptionsPanel.elements[elKey]:SetScript("OnClick",
			function()
				if(OptionsPanel.elements[elKey]:GetChecked() == 1) then LCcfg.disableWatch(dbType,false);
				else LCcfg.disableWatch(dbType,true); end
			end
		);
		lastEl = OptionsPanel.elements[elKey];
	end

	OptionsPanel.elements.instChat = CreateFrame("Frame", "LCO_instChat", OptionsPanel, "UIDropDownMenuTemplate")
	OptionsPanel.elements.instChat:SetPoint("TOPLEFT", OptionsPanel.elements.subTitle, "BOTTOMLEFT", 150, -20)
	OptionsPanel.elements.instChat.initialize = function()
		local info = {};
		local values = {"PARTY", "INSTANCE_CHAT"}
		local names = {"Party (/p)", "Instance (/i)"}
		for i, val in next, values do
			info.text = names[i]
			info.value = val
			info.func = function(self)
				LCcfg.set('instanceChat',self.value);
			end
			info.checked = val == LCcfg.get('instanceChat');
			UIDropDownMenu_AddButton(info)
		end
	end
	getglobal(OptionsPanel.elements.instChat:GetName() .. 'Text'):SetText("5-Man Channel")

	OptionsPanel.elements.raidChat = CreateFrame("Frame", "LCO_raidChat", OptionsPanel, "UIDropDownMenuTemplate")
	OptionsPanel.elements.raidChat:SetPoint("TOPLEFT", OptionsPanel.elements.instChat, "TOPRIGHT", 120, 0)
	OptionsPanel.elements.raidChat.initialize = function()
		local info = {};
		local values = {"PARTY", "RAID"}
		local names = {"Party (/p)", "Raid (/r)"}
		for i, val in next, values do
			info.text = names[i]
			info.value = val
			info.func = function(self)
				LCcfg.set('raidChat',self.value);
			end
			info.checked = val == LCcfg.get('raidChat');
			UIDropDownMenu_AddButton(info)
		end
	end
	getglobal(OptionsPanel.elements.raidChat:GetName() .. 'Text'):SetText("Raid Channel")

	InterfaceOptions_AddCategory(OptionsPanel);
	return OptionsPanel;
end