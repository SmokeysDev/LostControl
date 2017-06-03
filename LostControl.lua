-- LostControl

-- Notifies party/raid members when you lose control of your character

local addonEnabled = true;
if(addonEnabled==true) then

local LostControlFrame = CreateFrame("FRAME", nil, UIParent);
LostControlFrame:Hide();

function LostControlOptions_OnLoad()
end

function LostControl_OnEvent(self,event,...)
	local args = {...};
	if(event=="ADDON_LOADED" and args[1]==LCU.addonName) then
		LCcfg.init();
		LCU.optionsPanel = LCOptions(LostControlFrame);
	end
	if(event=="PLAYER_ENTERING_WORLD") then
		LCU.player.updateInstanceInfo();
		LCU.player.updateRole();
		LCcfg.init();
	end
	if(event=="LFG_ROLE_UPDATE") then
		LCU.player.updateInstanceInfo();
		LCU.player.updateRole();
		LCcfg.init();
	end
	if(event=="PLAYER_ROLES_ASSIGNED") then
		LCU.player.updateInstanceInfo();
		LCU.player.updateRole();
		LCcfg.init();
	end
	if(event=="ACTIVE_TALENT_GROUP_CHANGED") then
		LCU.player.updateSpec();
	end
	if(event=="PLAYER_LOGOUT") then
		-- Remove 'false' references to watches in cfg.disabledWatches
		local roleWatches = LCU.cloneTable(LCcfg.get('disabledWatches'));
		if(type(roleWatches)=="table") then
			LCcfg.set('disabledWatches',{});
			for db,v in pairs(roleWatches) do
				if(v==true) then LCcfg.disableWatch(db,true); end
			end
		end
	end
	if(event=="COMBAT_LOG_EVENT_UNFILTERED") then
		local event = args[2];
		local srcGUID = args[4];
		local srcName = args[5];
		local srcUnitFlag = args[6];
		local srcUnitFlag2 = args[7];
		local destGUID = args[8];
		local destName = args[9];
		local destUnitFlag = args[10];
		local destUnitFlag2 = args[11];
		local spellId = args[12];
		local spellName = args[13];
		local spellSchool = args[14];
		local spellSchoolName = LCU.spellSchoolByNum(spellSchool);
		if(event=='SPELL_CAST_FAILED' and (destName==LCU.player.name or srcName==LCU.player.name)) then
			local failType = args[15];
			print('Spell fail ('..LCU.str(spellName)..' - '..LCU.str(spellSchoolName)..') because: '..LCU.str(failtype)..'['..LCU.str(srcName)..']['..LCU.str(destName)..']');
		end
		if(event=='SPELL_INTERRUPT' and destName==LCU.player.name) then
			print('Spell interrupt ('..LCU.str(spellName)..' - '..LCU.str(spellSchoolName)..') re: ['..LCU.str(srcName)..']['..LCU.str(destName)..']');
			local intSpellID = args[15];
			local intSpellName = args[16];
			local intSpellSchool = args[17];
			local intSpellSchoolName = LCU.spellSchoolByNum(intSpellSchool);
			local offensiveSpellDesc = GetSpellDescription(args[12]);
			local lockTime = LCU.trim((string.match(offensiveSpellDesc,'for %d%d? sec'):gsub('[a-z]','')));
			print('By '..LCU.str(intSpellName)..' : '..LCU.str(offensiveSpellDesc));
			--local cooldownStart,cooldownTime = GetSpellCooldown(intSpellID);
			--if(cooldownStart <= GetTime() and cooldownTime > 1) then
			if(lockTime > 1 and intSpellSchoolName) then
				--local expires = cooldownStart+cooldownTime;
				local expires = GetTime()+lockTime;
				LCU.player.lastInterrupt = {
					bySpellID = args[12],
					bySpellName = args[13],
					onSpellID = intSpellID,
					onSpellName = intSpellName,
					onSpellSchool = intSpellSchoolName,
				};
				local debuff = {name='Spell Lock',rank='',["type"]='',length=lockTime,remaining=LCU.round(expires-GetTime()),desc=GetSpellDescription(19647),id=19647,extraInfo=''};
				Debuffs.types.spellLock.debuff = debuff;
			else
				print(lockTime..' not greater than 1, from '..offensiveSpellDesc);
				print('or failed checking school name: '..LCU.str(intSpellSchoolName));
			end
			--end
		end
	end
end

LostControlFrame:SetScript("OnEvent",LostControl_OnEvent);
LostControlFrame:RegisterEvent("ADDON_LOADED");
LostControlFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
LostControlFrame:RegisterEvent("LFG_ROLE_UPDATE");
LostControlFrame:RegisterEvent("PLAYER_ROLES_ASSIGNED");
LostControlFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");
LostControlFrame:RegisterEvent("PLAYER_LOGOUT");
LostControlFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");

StaticPopupDialogs["LC_DEBUFF_TEST"] = {
	text = "Which debuff do you want to test?",
	button1 = "Accept",
	button2 = "Cancel",
	OnAccept = function(self)
		local dbType = self.editBox:GetText();
		Debuffs.test(dbType);
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
	hasEditBox = true,
	enterClicksFirstButton = true,
}

local charJumped = 0
local fallAnnounced = 0
local function jumpAscendHook(arg1)
	charJumped = 1
	fallingFrames = 0
end
hooksecurefunc('JumpOrAscendStart',jumpAscendHook)

local total = 0
local fallingFrames = 0;
local function onUpdate(self,elapsed)
    total = total + elapsed
    if total >= 0.25 then
		checkDebuffs()
		local falling = IsFalling()
		if(falling and charJumped==0) then fallingFrames = fallingFrames+1; end
        if(falling and charJumped==0 and fallAnnounced==0 and fallingFrames >= 20) then
			LCU.announcePlayer('is airborne')
			fallAnnounced = 1
		end
		if(falling == nil) then
			charJumped = 0
			fallAnnounced = 0
			if(fallingFrames>15) then LCU.announcePlayer('has landed'); end
			fallingFrames = 0
		end
        total = 0
    end
end

local f = CreateFrame("frame")
f:SetScript("OnUpdate", onUpdate)

end
if(addonEnabled==false) then
	function LostControlOptions_OnLoad()
	end
	function LostControl_OnUpdate()
	end
end