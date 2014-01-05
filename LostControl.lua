-- LostControl

-- Notifies party/raid members when you lose control of your character

local addonEnabled = true;
if(addonEnabled==true) then

local LostControlFrame = CreateFrame("FRAME", nil, UIParent);
LostControlFrame:Hide();
local debugMode = false;
local role = nil;
local playerName = UnitName("player");


local function str(val)
	return tostring(val)
end
local function toboolean( value )
  return not not value
end

--Send our message out
local function sendMsg(msg,priv)
	priv = priv or debugMode
	local chan = IsInGroup() and 'PARTY' or (IsInRaid() and 'RAID' or 'SAY')
	if(priv == true) then print(msg)
	else SendChatMessage(msg,chan) end
end

local function updateRole()
	role = string.lower(UnitGroupRolesAssigned("player"));
	if(role == "none") then
		local isLeader, isTank, isHealer, isDPS = GetLFGRoles();
		if(isTank==true) 	then role = 'tank' end
		if(isHealer==true)  then role = 'healer' end
		if(isDPS==true) 	then role = 'dps' end
		if(role=="none") 	then role = 'player' end
	end
	return role
end

local function hasDebuff(spell,who)
	who = who or "player"
	if(type(spell)=='table') then
		local hasOne = false
		for key,value in pairs(spell) do
			if(hasDebuff(value,who)) then hasOne = true end
		end
		return hasOne
	end
	--local aura = UnitAura(who,spell,'HARMFUL')
	local aura = UnitAura(who,spell)
	return aura==spell and true or false
end

function lastDebuff()
	local lastName = nil
	for i=1,40 do
		local n,_,_,_,_,_,expiry = UnitAura("player",i,"HELPFUL|HARMFUL")
		if(n) then sendMsg('found '..n) end
	end
	--sendMsg('last aura = '..lastName)
end

function isStunned(who)
	who = who or "player"
	return hasDebuff({'Stun','Stunned'},who) and true or false
end

function isIncap(who)
	who = who or "player"
	return hasDebuff({'Polymorph','Freeze','Fear','Hex','Hibernate'},who) and true or false
end

function isSilenced(who)
	who = who or "player"
	return hasDebuff({'Silence','Silenced','Strangulate'},who) and true or false
end

local function checkCharSilence(char)
	local silenced = 'null';
	if isSilenced(char) then silenced = 'true' else silenced = 'false' end
	if(silenced == 'true') then sendMsg('Silenced!') end
end

local function announceStateChange(action)
	updateRole();
	local msgStart = role=='dps' and 'A DPS' or 'The '..role
	local msg = msgStart..' ('..playerName..') has '..action
	sendMsg(msg)
	return msg
end

local playerInControl = HasFullControl()==1

local function OnAuraChange()
	checkCharSilence("player");
	local lastCheck = playerInControl;
	playerInControl = HasFullControl()==1
	local stateChanged = playerInControl~=lastCheck
	if(stateChanged and playerInControl==false) then announceStateChange('lost control') end
	if(stateChanged and playerInControl) then announceStateChange('regained control') end
	return false
end

function LostControl_OnEvent(self, event, arg1, arg2, arg3, arg4)
	if(debugMode) then
		sendMsg("Event received: "..event,true)
	end
	if(event == "UNIT_AURA") then OnAuraChange() end -- arg1 == player/target/focus
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
    if total >= 0.5 then
		local falling = IsFalling()
        if(falling and charJumped==0 and fallAnnounced == 0 and UnitAffectingCombat("player")==1) then
			announceStateChange('been sent flying')
			fallAnnounced = 1
		end
		if(falling == nil) then charJumped = 0 end
		if(falling == nil and fallAnnounced == 1) then
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
local function oldOnAuraChange()
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