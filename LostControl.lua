-- LostControl

-- Notifies party/raid members when you lose control of your character

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

local playerInControl = LCU.player.isInControl()

local function checkInControl()
	local lastCheck = playerInControl;
	playerInControl = LCU.player.isInControl()
	local stateChanged = playerInControl~=lastCheck
	if(stateChanged and playerInControl==false) then
		local msg = 'lost control'
		if(isStunned()) then msg = msg .. ' (stunned)' end
		if(isFeared()) then msg = msg .. ' (feared)' end
		LCU.announceStateChange(msg)
	end
	if(stateChanged and playerInControl) then LCU.announceStateChange('regained control') end
	return false
end

function LostControl_OnEvent(self, event, arg1, arg2, arg3, arg4)
	if(LCU.debugMode) then
		LCU.sendMsg("Event received: "..event,true)
	end
	if(event == "UNIT_AURA" and arg1 == "player") then checkInControl() end -- arg1 == player/target/focus
	if(event == "PLAYER_CONTROL_LOST") then LCU.announceStateChange('lost control') end
	if(event == "PLAYER_CONTROL_GAINED") then LCU.announceStateChange('regained control') end
	if(event == "PLAYER_DEAD") then LCU.announceStateChange('died') end
end

LostControlFrame:SetScript("OnEvent", LostControl_OnEvent)
--LostControlFrame:RegisterEvent("PLAYER_AURAS_CHANGED")
LostControlFrame:RegisterEvent("UNIT_AURA")
LostControlFrame:RegisterEvent("PLAYER_CONTROL_LOST")
LostControlFrame:RegisterEvent("PLAYER_CONTROL_GAINED")
LostControlFrame:RegisterEvent("PLAYER_DEAD")

function LostControlOptions_OnLoad()
	LCU.player.updateRole();
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
	Debuffs.latest();
    if total >= 0.25 then
		checkInControl()
		Debuffs.update()
		checkDebuffs()
		local falling = IsFalling()
        if(falling and charJumped==0 and fallAnnounced==0 and UnitAffectingCombat("player")==1) then
			LCU.announceStateChange('been sent flying')
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
	--LCU.sendMsg(playerIsMoving,"SAY")
	--LCU.sendMsg('moving: ' .. playerIsMoving,true);
	--LCU.sendMsg('silenced: ' .. silenced,true);
	--LCU.sendMsg('stunned: ' .. stunned,true);
	--LCU.sendMsg('incapacitated: ' .. LCU.str(isIncap()),true);
	--if(hasDebuff('Blessing of Kings')) then LCU.sendMsg('BoK is on')
	--else LCU.sendMsg('BoK is off') end
	if(stunned == 'true') then LCU.sendMsg('Stunned!') end
	if(incap == 'true') then LCU.sendMsg('Incapacitated!') end
	if(HasFullControl() == 0) then LCU.sendMsg('Lost control') end
	--if(HasFullControl() == 1) then LCU.sendMsg('In control') end
end

end
if(addonEnabled==false) then
	function LostControlOptions_OnLoad()
	end
	function LostControl_OnUpdate()
	end
end