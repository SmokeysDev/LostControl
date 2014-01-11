-- LostControl

-- Notifies party/raid members when you lose control of your character

local addonEnabled = true;
if(addonEnabled==true) then

local LostControlFrame = CreateFrame("FRAME", nil, UIParent);
LostControlFrame:Hide();

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

end
if(addonEnabled==false) then
	function LostControlOptions_OnLoad()
	end
	function LostControl_OnUpdate()
	end
end