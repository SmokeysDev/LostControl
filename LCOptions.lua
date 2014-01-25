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

local function AddDropdown(parent,name,title,data,selFunc,checkedFunc,locx,locy,relTo)
	local dropDown = CreateFrame("Frame", "LCO_"..name, parent, "UIDropDownMenuTemplate")
	if(relTo) then dropDown:SetPoint("TOPLEFT", relTo, "TOPLEFT", locx, locy)
	else dropDown:SetPoint("TOPLEFT", locx, locy) end
	dropDown.initialize = function()
		local info = {};
		for k,d in ipairs(data) do
			info.text = d[1];
			info.value = d[2];
			info.func = selFunc;
			info.checked = checkedFunc(d[2]);
			UIDropDownMenu_AddButton(info);
		end
	end
	getglobal(dropDown:GetName() .. 'Text'):SetText(title)
	return dropDown;
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

	OptionsPanel.elements.instChat = AddDropdown(OptionsPanel,"instChat","5-Man Channel",
		{
			{"Party (/p)","PARTY"}
			,{"Instance (/i)","INSTANCE_CHAT"}
		}
		,(function(self) LCcfg.set('instanceChat',self.value) end)
		,(function(val) return val==LCcfg.get('instanceChat') end)
		,150,-30,OptionsPanel.elements.subTitle);

	OptionsPanel.elements.raidChat = AddDropdown(OptionsPanel,"raidChat","Raid Channel",
		{
			{"Party (/p)","PARTY"}
			,{"Raid (/r)","RAID"}
		}
		,(function(self) LCcfg.set('raidChat',self.value) end)
		,(function(val) return val==LCcfg.get('raidChat') end)
		,180,0,OptionsPanel.elements.instChat);

	InterfaceOptions_AddCategory(OptionsPanel);
	return OptionsPanel;
end