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
	LCU.optionsPanel = CreateFrame("Frame", O);
	local OptionsPanel = LCU.optionsPanel;
	OptionsPanel.name = LCU.addonName;
	OptionsPanel.elements = {};

	LCU.player.updateSpec();

	OptionsPanel.elements.title = AddText(LCU.addonName..' - '..LCcfg.getPlayerSpecRole()..' settings ('..LCcfg.getPlayerSpecName()..')',OptionsPanel,"GameFontNormalLarge",16,-16);
	OptionsPanel:SetScript("OnShow", function()
		LCU.player.updateSpec();
		OptionsPanel.elements.title:SetText(LCU.addonName..' - '..LCcfg.getPlayerSpecRole()..' settings ('..LCcfg.getPlayerSpecName()..')');
	end);
	local notes = GetAddOnMetadata(LCU.addonName,"Notes");
	OptionsPanel.elements.subTitle = AddText(notes,OptionsPanel,"GameFontHighlightSmall",0,-8,OptionsPanel.elements.title);
	OptionsPanel.elements.watchTypesTitle = AddText('Watch debuff types:',OptionsPanel,"GameFontNormal",0,-20,OptionsPanel.elements.subTitle);
	OptionsPanel.elements.chanDropsTitle = AddText('Channel Selections:',OptionsPanel,"GameFontNormal",180,12,OptionsPanel.elements.watchTypesTitle);

	local lastEl = OptionsPanel.elements.watchTypesTitle;
	-- Loop through debuff types and create watch checkboxes for them
	local i = 0;
	local debuffNames = {}
	for dbType in pairs(Debuffs.types) do table.insert(debuffNames,dbType); end
	table.sort(debuffNames);
	for _,dbType in ipairs(debuffNames) do
		local elKey = 'watch'..LCU.upperFirst(dbType);
		local locY = i==0 and -12 or -5;
		OptionsPanel.elements[elKey] = CreateCheckButton(OptionsPanel, "LCO_"..elKey, 0, locY, LCU.upperFirst(dbType), 'Enable watching for '..dbType..' effects', lastEl);
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
	end

	OptionsPanel.elements.debuffTime = AddDropdown(OptionsPanel,"debuffTime","Min Debuff Time",
		{
			{"Any",0}
			,{"2 sec",2}
			,{"3 sec",3}
			,{"4 sec",4}
			,{"5 sec",5}
		}
		,(function(self) LCcfg.set('minDebuffTime',self.value) end)
		,(function(val) return val==LCcfg.get('minDebuffTime',3) end)
		,-15,-40,lastEl);

	OptionsPanel.elements.instChat = AddDropdown(OptionsPanel,"instChat","5-Man Channel",
		{
			{"Say (/s)","SAY"}
			,{"Party (/p)","PARTY"}
			,{"Instance (/i)","INSTANCE_CHAT"}
		}
		,(function(self) LCcfg.set('instanceChat',self.value) end)
		,(function(val) return val==LCcfg.get('instanceChat','PARTY') end)
		,-20,-28,OptionsPanel.elements.chanDropsTitle);

	OptionsPanel.elements.raidChat = AddDropdown(OptionsPanel,"raidChat","Raid Channel",
		{
			{"Say (/s)","SAY"}
			,{"Party (/p)","PARTY"}
			,{"Raid (/r)","RAID"}
		}
		,(function(self) LCcfg.set('raidChat',self.value) end)
		,(function(val) return val==LCcfg.get('raidChat','PARTY') end)
		,0,-35,OptionsPanel.elements.instChat);

	InterfaceOptions_AddCategory(OptionsPanel);
	return OptionsPanel;
end