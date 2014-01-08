-- LostControl

-- Notifies party/raid members when you lose control of your character

addonName = "LostControl"
local addonEnabled = true;
if(addonEnabled==true) then

local LostControlFrame = CreateFrame("FRAME", nil, UIParent);
LostControlFrame:Hide();

local function _hasDebuff_(spell,who)
	who = who or "player"
	if(type(spell)=='table') then
		local hasOne = false
		for key,value in pairs(spell) do
			if(hasDebuff(value,who)) then hasOne = true end
		end
		return hasOne
	end
	--local aura = UnitAura(who,spell,'HARMFUL')
	local aura = UnitAura(who,spell,'HARMFUL')
	return aura==spell and true or false
end


local function checkCharSilence(char)
	local silenced = 'null';
	if isSilenced(char) then silenced = 'true' else silenced = 'false' end
	if(silenced == 'true') then sendMsg('Silenced!') end
end

function inControl()
	local wowRet = HasFullControl()
	if(type(wowRet)=="number" and wowRet==0) then return false
	elseif(type(wowRet)=="number" and wowRet==1) then return true
	elseif(type(wowRet)=="boolean" and wowRet==false) then return false
	elseif(type(wowRet)=="boolean" and wowRet==true) then return true
	else return nil end
end

local playerInControl = inControl()

local function checkInControl()
	checkCharSilence("player");
	local lastCheck = playerInControl;
	playerInControl = inControl()
	local stateChanged = playerInControl~=lastCheck
	if(stateChanged and playerInControl==false) then
		local msg = 'lost control'
		if(isStunned()) then msg = msg .. ' (stunned)' end
		if(isFeared()) then msg = msg .. ' (feared)' end
		announceStateChange(msg)
	end
	if(stateChanged and playerInControl) then announceStateChange('regained control') end
	return false
end

function LostControl_OnEvent(self, event, arg1, arg2, arg3, arg4)
	if(LCDebugMode) then
		sendMsg("Event received: "..event,true)
	end
	if(event == "UNIT_AURA" and arg1 == "player") then checkInControl() end -- arg1 == player/target/focus
	if(event == "PLAYER_CONTROL_LOST") then announceStateChange('lost control') end
	if(event == "PLAYER_CONTROL_GAINED") then announceStateChange('regained control') end
	if(event == "PLAYER_DEAD") then announceStateChange('died') end
end

LostControlFrame:SetScript("OnEvent", LostControl_OnEvent)
--LostControlFrame:RegisterEvent("PLAYER_AURAS_CHANGED")
LostControlFrame:RegisterEvent("UNIT_AURA")
LostControlFrame:RegisterEvent("PLAYER_CONTROL_LOST")
LostControlFrame:RegisterEvent("PLAYER_CONTROL_GAINED")
LostControlFrame:RegisterEvent("PLAYER_DEAD")

function LostControlOptions_OnLoad()
	updateRole();
end


local charJumped = 0
local fallAnnounced = 0
local function jumpAscendHook(arg1)
	charJumped = 1
end
hooksecurefunc('JumpOrAscendStart',jumpAscendHook)

local total = 0
local function onUpdate(self,elapsed)
    total = total + elapsed
	lastDebuff()
    if total >= 0.25 then
		checkInControl()
		updateDebuffs()
		checkDebuffs()
		local falling = IsFalling()
        if(falling and charJumped==0 and fallAnnounced==0 and UnitAffectingCombat("player")==1) then
			announceStateChange('been sent flying')
			fallAnnounced = 1
		end
		if(falling == nil) then
			charJumped = 0
			fallAnnounced = 0
		end
        total = 0
    end
end

local f = CreateFrame("frame")
f:SetScript("OnUpdate", onUpdate)


---
--- GRAVEYARD
---
local function oldcheckInControl()
	local stunned = 'null';
	if isStunned() then stunned = 'true' else stunned = 'false' end
	local incap = 'null';
	if isIncap() then incap = 'true' else incap = 'false' end
	local playerIsMoving = GetUnitSpeed("player") > 0 and 'true' or 'false'
	--sendMsg(playerIsMoving,"SAY")
	--sendMsg('moving: ' .. playerIsMoving,true);
	--sendMsg('silenced: ' .. silenced,true);
	--sendMsg('stunned: ' .. stunned,true);
	--sendMsg('incapacitated: ' .. str(isIncap()),true);
	--if(hasDebuff('Blessing of Kings')) then sendMsg('BoK is on')
	--else sendMsg('BoK is off') end
	if(stunned == 'true') then sendMsg('Stunned!') end
	if(incap == 'true') then sendMsg('Incapacitated!') end
	if(HasFullControl() == 0) then sendMsg('Lost control') end
	--if(HasFullControl() == 1) then sendMsg('In control') end
end

end
if(addonEnabled==false) then
	function LostControlOptions_OnLoad()
	end
	function LostControl_OnUpdate()
	end
end