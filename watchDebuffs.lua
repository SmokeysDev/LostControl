function inControl()
	local wowRet = HasFullControl()
	if(type(wowRet)=="number" and wowRet==0) then return false
	elseif(type(wowRet)=="number" and wowRet==1) then return true
	elseif(type(wowRet)=="boolean" and wowRet==false) then return false
	elseif(type(wowRet)=="boolean" and wowRet==true) then return true
	else return nil end
end


local debuffs = {}

function updateDebuffs()
	debuffs = {}
	for i=1,40 do
		local n,_,_,_,dbType,duration,expires,_,_,_,id = UnitDebuff("player",i)
		if(n ~= nil and expires ~= nil) then
			local desc = GetSpellDescription(id) or ''
			debuffs[#debuffs+1] = {name=n,["type"]=(dbType or 'null'),length=duration,remaining=round(expires-GetTime()),desc=desc,id=id}
		end
	end
end

local function hasDebuffName(spell,who)
	who = who or "player"
	if(type(spell)=='table') then
		local hasOne = false
		for key,value in pairs(spell) do
			if(hasDebuffName(value,who)) then hasOne = true end
		end
		return hasOne
	end
	local debuffFound = false
	for k,d in pairs(debuffs) do
		if(d.name == spell or d.id == spell) then debuffFound = true end
	end
	return debuffFound
end

function lastDebuff()
	local lastName = nil
	local lastExpiry = nil
	local lastDesc = nil
	for i=1,40 do
		local n,_,_,_,_,_,expiry,_,_,_,spellID = UnitAura("player",i,"HARMFUL")
		if(n) then
			lastName = n
			lastExpiry = round(expiry - GetTime()) or 1
			lastDesc = GetSpellDescription(spellID)
		end
	end
	if(lastName ~= nil) then
		if(lastExpiry ~= nil and lastExpiry > 120) then lastExpiry = round(round(lastExpiry,60)/60)..' minutes'
		else lastExpiry = (lastExpiry or 1)..' seconds' end
		if(LCDebugMode) then sendMsg('Last debuff found = '..lastName..' - expiring in '..lastExpiry,true) end
		--sendMsg('Last debuff desc: '..lastDesc,true)
	end
end

local function inDebuffDesc(txt,debuff)
	debuff = debuff or 'all';
	if(debuff == 'all') then
		local oneMatches = false
		for k,debuff in pairs(debuffs) do
			if(string.find(debuff.desc,txt)~=nil) then oneMatches = true end
		end
		return oneMatches;
	else
		if(string.find(debuff.desc,txt)~=nil) then return true end
	end
end

local function hasStunDebuff()
	local found = false;
	for k,debuff in pairs(debuffs) do
		if((inDebuffDesc(' [sS]tun',debuff) or inDebuffDesc('^Stun',debuff)) and inDebuffDesc('[iI]mmun',debuff)==nil) then found = true end
	end
	return found;
end
local function hasFearDebuff()
	local found = false;
	for k,debuff in pairs(debuffs) do
		if((inDebuffDesc(' [fF]ear',debuff) or inDebuffDesc('^Fear',debuff) or inDebuffDesc('[sS]cared',debuff)) and inDebuffDesc('[iI]mmun',debuff)==nil) then found = true end
	end
	return found;
end
local function hasIncapDebuff()
	local found = false;
	for k,debuff in pairs(debuffs) do
		if((inDebuffDesc(' [iI]ncapacitat',debuff) or inDebuffDesc('^Incapacitated',debuff)) and inDebuffDesc('[iI]mmun',debuff)==nil) then found = true end
	end
	return found;
end
local function hasSilenceDebuff()
	local found = false;
	for k,debuff in pairs(debuffs) do
		if((inDebuffDesc(' [sS]ilenced?',debuff) or inDebuffDesc('^Silenced',debuff)) and inDebuffDesc('[iI]mmun',debuff)==nil) then found = true end
	end
	return found;
end
local function hasSlowDebuff()
	local found = false;
	for k,debuff in pairs(debuffs) do
		if((inDebuffDesc(' [sS]low',debuff) or inDebuffDesc('^Slow',debuff) or inDebuffDesc(' [dD]azed?',debuff) or inDebuffDesc('^Dazed?',debuff)) and inDebuffDesc('[iI]mmun',debuff)==nil) then found = true end
	end
	return found;
end


function isStunned(who)
	who = who or "player"
	local hasNamedDebuff = hasDebuffName({'Stun','Stunned','Charge','Stomp'},who)
	local hasDescKeyword = hasFearDebuff()
	return (hasNamedDebuff or hasDescKeyword)
end

function isSlowed(who)
	who = who or "player"
	local hasNamedDebuff = hasDebuffName({'Dazed','Daze','Slow','Slowed','Hamstring','Ice Trap'},who)
	local hasDescKeyword = hasSlowDebuff()
	return (hasNamedDebuff or hasDescKeyword)
end

function isIncap(who)
	who = who or "player"
	local hasNamedDebuff = hasDebuffName({'Polymorph','Freeze','Fear','Hex','Hibernate'},who)
	local hasDescKeyword = hasIncapDebuff()
	return (hasNamedDebuff or hasDescKeyword)
end
function isFeared(who)
	who = who or "player"
	local hasNamedDebuff = hasDebuffName({'Fear','Feared','Psychic Scream'},who)
	local hasDescKeyword = hasFearDebuff()
	return (hasNamedDebuff or hasDescKeyword)
end

function isSilenced(who)
	who = who or "player"
	local hasNamedDebuff = hasDebuffName({'Silence','Silenced','Strangulate','Arcane Torrent'},who)
	local hasDescKeyword = hasSilenceDebuff()
	return (hasNamedDebuff or hasDescKeyword)
end


local lastDebuffMessage = 0
function checkDebuffs()
	updateDebuffs()
	if(#debuffs > 0 and GetTime()-lastDebuffMessage > 8 and LCDebugMode==true) then
		--LCMessage('In control? '..tostring(inControl()),nil,10)
		for k,debuff in pairs(debuffs) do
			local debuffMsg = 'Debuff #'..tostring(k)..':'
			debuffMsg = debuffMsg..' "'..debuff.name..'" '
			debuffMsg = debuffMsg..' ['..debuff.id..'] '
			debuffMsg = debuffMsg..' ('..debuff.type..') '
			debuffMsg = debuffMsg..' '..tostring(debuff.remaining)..' secs remaining.'
			LCMessage(debuffMsg,nil,10);
			local controlMsg = inControl() and 'In Control' or 'Not In Control'
			LCMessage(controlMsg,nil,10);
		end
		lastDebuffMessage = GetTime()
	end
end