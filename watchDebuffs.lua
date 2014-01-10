LCU.player.debuffs = {} --debuffs
Debuffs = {
	types = {
		fear = {
			debuffs = {}
			,names = {'Fear','Feared','Scare','Scared','Psychic Scream'}
			,descTerms = {' [fF]ear','^Fear','[sS]cared'}
			,message = 'is feared for [remaining] seconds	'
			,recoverMessage = 'is no longer feared'
		}
		,incap = {
			debuffs = {}
			,names = {'Polymorph','Freeze','Fear','Hex','Hibernate'}
			,descTerms = {' [iI]ncapacitat','^Incapacitated'}
			,message = 'is incapacitated for [remaining] seconds ({SPELL_LINK})'
			,recoverMessage = 'is no longer incapacitated'
		}
		,root = {
			debuffs = {}
			,names = {'Freeze','Root','Entangling Roots','Frozen'}
			,descTerms = {' [rR]oot','^Rooted','[fF]rozen'}
			,message = 'has been rooted for [remaining] seconds ({SPELL_LINK})'
			,recoverMessage = 'is no longer rooted'
		}
		,silence = {
			debuffs = {}
			,names = {'Silence','Solar Beam','Strangulate','Arcane Torrent','Silencing Shot'}
			,descTerms = {' [sS]ilenced?','^Silenced'}
			,message = 'has been silenced for [remaining] seconds ({SPELL_LINK})'
			,recoverMessage = 'is no longer silenced'
		}
		,slow = {
			debuffs = {}
			,names = {'Dazed','Daze','Slow','Slowed','Hamstring','Ice Trap'}
			,descTerms = {' [sS]low','^Slow',' [dD]azed?','^Dazed?','speed reduced'}
			,extraInfo = function(debuff)
				local extraInfo = string.match(debuff.desc,'reduced by %d%d%%'); --get perc slowed
				--print('slow desc = '..tostring(debuff.desc)); --"speed by $s1%"
				--print('slow match = '..tostring(extraInfo));
				extraInfo = extraInfo and string.gsub(extraInfo,'reduced ',' ') or '';
				return extraInfo;
			end
			,message = function(debuff)
				return 'has been slowed'..debuff.extraInfo..' for [remaining] seconds';
			end
			,recoverMessage = 'is no longer slowed'
		}
		,stun = {
			debuffs = {}
			,names = {'Stun','Stunned','Charge','Stomp'}
			,descTerms = {' [sS]tun','^Stun','[iI]mmobili[sz]ed'}
			,message = 'has been stunned for [remaining] seconds ({SPELL_LINK})'
			,recoverMessage = 'is no longer stunned'
		}
		,friendly = {
			debuffs = {}
			,names = {'Mark of the Wild','Blessing of Kings'}
			,descTerms = {'increased by'}
			,message = 'is buffed by {SPELL_LINK}'
			,recoverMessage = 'has lost his buff'
		}
	}
	,emptyTypeCache = function()
		for type,info in pairs(Debuffs.types) do
			Debuffs.types[type].debuffs = {}
		end
	end
	,isType = function(debuff,type)
		if(Debuffs.types[type]==nil) then return false; end
		for k,v in pairs(Debuffs.types[type].names) do
			if(debuff.name == v) then return true; end
		end
		for k,v in pairs(Debuffs.types[type].descTerms) do
			if(string.find(debuff.desc,v)~=nil) then return true; end
		end
		return false;
	end
	,getType = function(debuff)
		for type in pairs(Debuffs.types) do
			if(Debuffs.isType(debuff,type)) then return type; end
		end
		return false;
	end
	,fillMsg = function(msg,debuff)
		local ret = msg;
		ret = ret:gsub('%[remaining%]',tostring(debuff.remaining));
		ret = ret:gsub('%{SPELL_LINK%}',Debuffs.getLink(debuff));
		return ret;
	end
	,checkDebuffs = function()
		for dbType,info in pairs(Debuffs.types) do
			if(#info.debuffs >= 1) then
				local debuff = info.debuffs[1];
				local message = info.message;
				local lastAnnounce = info.lastAnnounce or -10;
				local theTime = GetTime();
				local repeatLimit = info.repeatLimit or 3;
				if(theTime - lastAnnounce >= repeatLimit) then
					if(type(message)=="function") then message = message(debuff); end
					local recoverMessage = info.recoverMessage;
					if(type(recoverMessage)=="function") then recoverMessage = recoverMessage(debuff); end
					message = Debuffs.fillMsg(message,debuff);
					recoverMessage = Debuffs.fillMsg(recoverMessage,debuff);
					if(debuff.remaining>0 and debuff.remaining%2==0) then LCU.announcePlayer(message);
					elseif(debuff.remaining==0) then LCU.announcePlayer(recoverMessage) end
					Debuffs.types[dbType].lastAnnounce = theTime;
				end
			end
		end
	end
	,getLink = function(debuff)
		if(type(debuff)=="number") then
			local name,rank = GetSpellInfo(debuff);
			debuff = {id=debuff,name=name,rank=rank};
		end
		if(debuff.rank~='') then debuff.rank = ' '..tostring(debuff.rank); end
		return "|Hspell:" .. debuff.id .."|h|r|cff71d5ff[" .. debuff.name .. debuff.rank .. "]|r|h";
	end
	,getByName = function(spellName,who)
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
		return Debuffs.getDebuffByNameOrDesc({'Polymorph','Freeze','Fear','Hex','Hibernate'},{' [iI]ncapacitat','^Incapacitated'},who);
	end
	,_getRootDebuff = function(who)
		return Debuffs.getDebuffByNameOrDesc({'Freeze','Root','Entangling Roots','Frozen'},{' [rR]oot','^Rooted','[fF]rozen'},who);
	end
	,_getSilenceDebuff = function(who)
		return Debuffs.getDebuffByNameOrDesc({'Silence','Solar Beam','Strangulate','Arcane Torrent','Silencing Shot'},{' [sS]ilenced?','^Silenced'},who);
	end
	,_getSlowDebuff = function(who)
		local debuff = Debuffs.getDebuffByNameOrDesc({'Dazed','Daze','Slow','Slowed','Hamstring','Ice Trap'},{' [sS]low','^Slow',' [dD]azed?','^Dazed?','speed reduced'},who);
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
		Debuffs.emptyTypeCache();
		local auraType = LCU.debugMode and 'HELPFUL' or 'HARMFUL';
		for i=1,40 do
			local n,rank,_,_,dbType,duration,expires,_,_,_,id = UnitAura(who,i,auraType);
			if(n ~= nil and expires ~= nil) then
				local desc = GetSpellDescription(id) or '';
				local debuff = {name=n,rank=rank,["type"]=(dbType or 'null'),length=duration,remaining=LCU.round(expires-GetTime()),desc=desc,id=id,extraInfo=''};
				debuffs[#debuffs+1] = debuff;
				local dbType = Debuffs.getType(debuff);
				if(dbType~=false) then table.insert(Debuffs.types[dbType].debuffs,debuff); end
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
	Debuffs.checkDebuffs()
	--if(#LCU.player.debuffs > 0 and LCU.debugMode==true) then
	if(#LCU.player.debuffs > 0 and GetTime()-lastDebuffMessage > 8 and LCU.debugMode==true) then
		--LCMessage('In control? '..tostring(LCU.player.isInControl()),nil,10)
		for k,debuff in pairs(LCU.player.debuffs) do
			local debuffMsg = 'Debuff #'..tostring(k)..':'
			debuffMsg = debuffMsg..' "'..debuff.name..'" '
			debuffMsg = debuffMsg..' ['..debuff.id..'] '
			debuffMsg = debuffMsg..' ('..debuff.type..') '
			debuffMsg = debuffMsg..' '..tostring(debuff.remaining)..' secs remaining.'
			LCMessage(debuffMsg,nil,LCU.round(debuff.remaining/2));
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