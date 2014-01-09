LCU.player.debuffs = {} --debuffs
Debuffs = {
	getByName = function(spellName,who)
		who = who or "player"
		if(type(spellName)=='table') then
			local hasOne = false
			for key,value in pairs(spellName) do
				if(Debuffs.getByName(value,who)) then hasOne = true end
			end
			return hasOne
		end
		local debuffFound = false
		for k,d in pairs(LCU.player.debuffs) do
			if(d.name == spellName) then debuffFound = true end
		end
		return debuffFound
	end
	,getByID = function(spellID,who)
		who = who or "player"
		if(type(spellID)=='table') then
			local hasOne = false
			for key,value in pairs(spellID) do
				if(Debuffs.getByID(value,who)) then hasOne = true end
			end
			return hasOne
		end
		local debuffFound = false
		for k,d in pairs(LCU.player.debuffs) do
			if(d.id == spellID) then debuffFound = true end
		end
		return debuffFound
	end
	,getByDesc = function(txt)
	end
	,update = function()
		local debuffs = {}
		for i=1,40 do
			local n,_,_,_,dbType,duration,expires,_,_,_,id = UnitDebuff("player",i)
			if(n ~= nil and expires ~= nil) then
				local desc = GetSpellDescription(id) or ''
				debuffs[#debuffs+1] = {name=n,["type"]=(dbType or 'null'),length=duration,remaining=LCU.round(expires-GetTime()),desc=desc,id=id}
			end
		end
		LCU.player.debuffs = debuffs;
	end
	,latest = function()
		--Debuffs.update();
		--return LCU.player.debuffs[#LCU.player.debuffs] or false;
		local lastName = nil
		local lastExpiry = nil
		local lastDesc = nil
		for i=1,40 do
			local n,_,_,_,_,_,expiry,_,_,_,spellID = UnitAura("player",i,"HARMFUL")
			if(n) then
				lastName = n
				lastExpiry = LCU.round(expiry - GetTime()) or 1
				lastDesc = GetSpellDescription(spellID)
			end
		end
		if(lastName ~= nil) then
			if(lastExpiry ~= nil and lastExpiry > 120) then lastExpiry = LCU.round(LCU.round(lastExpiry,60)/60)..' minutes'
			else lastExpiry = (lastExpiry or 1)..' seconds' end
			if(LCU.debugMode) then LCU.sendMsg('Last debuff found = '..lastName..' - expiring in '..lastExpiry,true) end
			--LCU.sendMsg('Last debuff desc: '..lastDesc,true)
		end
	end
}

LCU.player.isInControl = function() --inControl()
	local wowRet = HasFullControl()
	if(type(wowRet)=="number" and wowRet==0) then return false
	elseif(type(wowRet)=="number" and wowRet==1) then return true
	elseif(type(wowRet)=="boolean" and wowRet==false) then return false
	elseif(type(wowRet)=="boolean" and wowRet==true) then return true
	else return nil end
end

local function inDebuffDesc(txt,debuff)
	debuff = debuff or 'all';
	if(type(txt)=='table') then
		local ret = false;
		local tmp = '';
		for _,txt2 in pairs(txt) do
			tmp = inDebuffDesc(txt2,debuff)
			if(tmp == true) then ret = true; end
		end
		return ret;
	end
	if(debuff == 'all') then
		local oneMatches = false
		for k,debuff in pairs(LCU.player.debuffs) do
			if(string.find(debuff.desc,txt)~=nil) then oneMatches = true end
		end
		return oneMatches;
	else
		if(string.find(debuff.desc,txt)~=nil) then return true end
	end
end

local function hasStunDebuff()
	local found = false;
	for k,debuff in pairs(LCU.player.debuffs) do
		if(inDebuffDesc({' [sS]tun','^Stun'},debuff) and inDebuffDesc('[iI]mmun',debuff)==nil) then found = true end
	end
	return found;
end
local function hasFearDebuff()
	local found = false;
	for k,debuff in pairs(LCU.player.debuffs) do
		if(inDebuffDesc({' [fF]ear','^Fear','[sS]cared'},debuff) and inDebuffDesc('[iI]mmun',debuff)==nil) then found = true end
	end
	return found;
end
local function hasIncapDebuff()
	local found = false;
	for k,debuff in pairs(LCU.player.debuffs) do
		if(inDebuffDesc({' [iI]ncapacitat','^Incapacitated'},debuff) and inDebuffDesc('[iI]mmun',debuff)==nil) then found = true end
	end
	return found;
end
local function hasSilenceDebuff()
	local found = false;
	for k,debuff in pairs(LCU.player.debuffs) do
		if(inDebuffDesc({' [sS]ilenced?','^Silenced'},debuff) and inDebuffDesc('[iI]mmun',debuff)==nil) then found = true end
	end
	return found;
end
local function hasSlowDebuff()
	local found = false;
	for k,debuff in pairs(LCU.player.debuffs) do
		if(inDebuffDesc({' [sS]low','^Slow',' [dD]azed?','^Dazed?'},debuff) and inDebuffDesc('[iI]mmun',debuff)==nil) then found = true end
	end
	return found;
end


function isStunned(who)
	who = who or "player"
	local hasNamedDebuff = Debuffs.getByName({'Stun','Stunned','Charge','Stomp'},who)
	local hasDescKeyword = hasFearDebuff()
	return (hasNamedDebuff or hasDescKeyword)
end

function isSlowed(who)
	who = who or "player"
	local hasNamedDebuff = Debuffs.getByName({'Dazed','Daze','Slow','Slowed','Hamstring','Ice Trap'},who)
	local hasDescKeyword = hasSlowDebuff()
	return (hasNamedDebuff or hasDescKeyword)
end

function isIncap(who)
	who = who or "player"
	local hasNamedDebuff = Debuffs.getByName({'Polymorph','Freeze','Fear','Hex','Hibernate'},who)
	local hasDescKeyword = hasIncapDebuff()
	return (hasNamedDebuff or hasDescKeyword)
end
function isFeared(who)
	who = who or "player"
	local hasNamedDebuff = Debuffs.getByName({'Fear','Feared','Psychic Scream'},who)
	local hasDescKeyword = hasFearDebuff()
	return (hasNamedDebuff or hasDescKeyword)
end

function isSilenced(who)
	who = who or "player"
	local hasNamedDebuff = Debuffs.getByName({'Silence','Silenced','Strangulate','Arcane Torrent'},who)
	local hasDescKeyword = hasSilenceDebuff()
	return (hasNamedDebuff or hasDescKeyword)
end


local lastDebuffMessage = 0
function checkDebuffs()
	Debuffs.update()
	--if(#debuffs > 0 and GetTime()-lastDebuffMessage > 8 and LCU.debugMode==true) then
	if(#LCU.player.debuffs > 0 and LCU.debugMode==true) then
		--LCMessage('In control? '..tostring(LCU.player.isInControl()),nil,10)
		for k,debuff in pairs(LCU.player.debuffs) do
			local debuffMsg = 'Debuff #'..tostring(k)..':'
			debuffMsg = debuffMsg..' "'..debuff.name..'" '
			debuffMsg = debuffMsg..' ['..debuff.id..'] '
			debuffMsg = debuffMsg..' ('..debuff.type..') '
			debuffMsg = debuffMsg..' '..tostring(debuff.remaining)..' secs remaining.'
			LCMessage(debuffMsg,nil,LCU.round(debuff.remaining/2));
			local controlMsg = LCU.player.isInControl() and 'In Control' or 'Not In Control'
			LCMessage(controlMsg,nil,LCU.round(debuff.remaining/2));
		end
		lastDebuffMessage = GetTime()
	end
	
	if(isStunned()) then LCU.announceStateChange('been stunned')
	elseif(isSlowed()) then LCU.announceStateChange('been slowed')
	elseif(isFeared()) then LCU.announceStateChange('been feared')
	elseif(isSilenced()) then LCU.announceStateChange('been silenced')
	elseif(isIncap()) then LCU.announceStateChange('been incapacitated') end
end