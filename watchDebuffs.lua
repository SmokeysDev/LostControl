LCU.player.debuffs = {} --debuffs
Debuffs = {
	getByName = function(spellName,who)
		who = who or "player"
		if(type(spellName)=='table') then
			for key,value in pairs(spellName) do
				local getD = Debuffs.getByName(value,who);
				if(getD ~= false) then return getD; end
			end
			return false;
		end
		for k,d in pairs(LCU[who].debuffs) do
			if(d.name == spellName) then return d; end
		end
		return false;
	end
	,getDebuffByNameOrDesc = function(names,descs,who)
		local namedDebuff = Debuffs.getByName(names,who);
		if(namedDebuff ~= false) then
			return namedDebuff;
		else
			for k,debuff in pairs(LCU[who].debuffs) do
				if(Debuffs.getByDesc(descs,debuff,who) and Debuffs.getByDesc('[iI]mmun',debuff,who)==nil) then return debuff; end
			end
			return false;
		end
	end
	,_getFearDebuff = function(who)
		return Debuffs.getDebuffByNameOrDesc({'Fear','Feared','Scare','Scared','Psychic Scream'},{' [fF]ear','^Fear','[sS]cared'},who);
	end
	,_getIncapDebuff = function(who)
		return Debuffs.getDebuffByNameOrDesc({'Polymorph','Freeze','Fear','Hex','Hibernate'},{' [iI]ncapacitat','^Incapacitated',''},who);
	end
	,_getRootDebuff = function(who)
		return Debuffs.getDebuffByNameOrDesc({'Freeze','Root','Entangling Roots','Frozen'},{' [rR]oot','^Rooted','[fF]rozen'},who);
	end
	,_getSilenceDebuff = function(who)
		return Debuffs.getDebuffByNameOrDesc({'Silence','Solar Beam','Strangulate','Arcane Torrent','Silencing Shot'},{' [sS]ilenced?','^Silenced'},who);
	end
	,_getSlowDebuff = function(who)
		local debuff = Debuffs.getDebuffByNameOrDesc({'Dazed','Daze','Slow','Slowed','Hamstring','Ice Trap'},{' [sS]low','^Slow',' [dD]azed?','^Dazed?'},who);
		if(debuff ~= false) then
			local extraInfo = string.match(debuff.desc,'reduced by %d%d%%'); --get perc slowed
			--print('slow desc = '..tostring(debuff.desc)); --"speed by $s1%"
			--print('slow match = '..tostring(extraInfo));
			extraInfo = extraInfo and string.gsub(extraInfo,'reduced ',' ') or '';
			debuff.extraInfo = extraInfo;
			return debuff;
		else
			return false;
		end
	end
	,_getStunDebuff = function(who)
		return Debuffs.getDebuffByNameOrDesc({'Stun','Stunned','Charge','Stomp'},{' [sS]tun','^Stun','[iI]mmobili[sz]ed'},who);
	end
	,getByType = function(debuffType,who)
		who = who or "player";
		local funcName = '_get'..LCU.upperFirst(debuffType)..'Debuff'
		if(type(Debuffs[funcName])=="function") then
			return Debuffs[funcName](who);
		end
		return false;
	end
	,getByDesc = function(txt,debuff,who)
		who = who or "player";
		debuff = debuff or 'all';
		if(type(txt)=='table') then
			local ret = false;
			local tmp = '';
			for _,txt2 in pairs(txt) do
				tmp = Debuffs.getByDesc(txt2,debuff)
				if(tmp == true) then ret = true; end
			end
			return ret;
		end
		if(debuff == 'all') then
			for k,debuff in pairs(LCU[who].debuffs) do
				if(string.find(debuff.desc,txt)~=nil) then oneMatches = true end
			end
			return oneMatches;
		else
			if(string.find(debuff.desc,txt)~=nil) then return true end
		end
	end
	,get = function(who)
		who = who or "player";
		local debuffs = {}
		for i=1,40 do
			local n,_,_,_,dbType,duration,expires,_,_,_,id = UnitDebuff(who,i)
			if(n ~= nil and expires ~= nil) then
				local desc = GetSpellDescription(id) or ''
				debuffs[#debuffs+1] = {name=n,["type"]=(dbType or 'null'),length=duration,remaining=LCU.round(expires-GetTime()),desc=desc,id=id,extraInfo=''}
			end
		end
		LCU[who]['debuffs'] = debuffs;
		return debuffs;
	end
	,latest = function()
		--Debuffs.get();
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


function fearCheck(who)
	who = who or "player"
	local theDebuff = Debuffs.getByType('fear');
	if(theDebuff and theDebuff.remaining%2==0 and theDebuff.remaining > 0) then LCU.announceStateChange('been feared'..theDebuff.extraInfo..' for '..theDebuff.remaining..' seconds');
	elseif(theDebuff and theDebuff.remaining==0) then LCU.announceStateChange('recovered from the fear effect'); end
end
function incapCheck(who)
	who = who or "player"
	local theDebuff = Debuffs.getByType('incap');
	if(theDebuff and theDebuff.remaining%2==0 and theDebuff.remaining > 0) then LCU.announceStateChange('been incapacitated'..theDebuff.extraInfo..' for '..theDebuff.remaining..' seconds');
	elseif(theDebuff and theDebuff.remaining==0) then LCU.announceStateChange('recovered from the incapacitation effect'); end
end
function rootCheck(who)
	who = who or "player"
	local theDebuff = Debuffs.getByType('root');
	if(theDebuff and theDebuff.remaining%2==0 and theDebuff.remaining > 0) then LCU.announceStateChange('been rooted'..theDebuff.extraInfo..' for '..theDebuff.remaining..' seconds');
	elseif(theDebuff and theDebuff.remaining==0) then LCU.announceStateChange('recovered from the root effect'); end
end
function silenceCheck(who)
	who = who or "player"
	local theDebuff = Debuffs.getByType('silence');
	if(theDebuff and theDebuff.remaining%2==0 and theDebuff.remaining > 0) then LCU.announceStateChange('been silenced'..theDebuff.extraInfo..' for '..theDebuff.remaining..' seconds');
	elseif(theDebuff and theDebuff.remaining==0) then LCU.announceStateChange('recovered from the silence effect'); end
end
function slowCheck(who)
	who = who or "player"
	local theDebuff = Debuffs.getByType('slow');
	if(theDebuff and theDebuff.remaining%2==0 and theDebuff.remaining > 0) then LCU.announceStateChange('been slowed'..theDebuff.extraInfo..' for '..theDebuff.remaining..' seconds');
	elseif(theDebuff and theDebuff.remaining==0) then LCU.announceStateChange('recovered from the slow effect'); end
end
function stunCheck(who)
	who = who or "player"
	local theDebuff = Debuffs.getByType('stun');
	if(theDebuff and theDebuff.remaining%2==0 and theDebuff.remaining > 0) then LCU.announceStateChange('been stunned for '..theDebuff.remaining..' seconds');
	elseif(theDebuff and theDebuff.remaining==0) then LCU.announceStateChange('recovered from the stun effect'); end
end



local lastDebuffMessage = 0
function checkDebuffs()
	Debuffs.get()
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
	
	fearCheck();
	incapCheck();
	rootCheck();
	silenceCheck();
	slowCheck();
	stunCheck();
end