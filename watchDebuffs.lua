LCU.player.debuffs = {} --debuffs
Debuffs = {
	types = {
		fear = {
			debuffs = {}
			,names = {'Fear','Feared','Scare','Scared','Psychic Scream'}
			,descTerms = {' [fF]ear','^Fear','[sS]cared','flee in terror'}
			,message = 'is feared for [remaining] seconds'
			,recoverMessage = 'is no longer feared'
		}
		,incap = {
			debuffs = {}
			,names = {'Polymorph','Freeze','Fear','Hex','Hibernate'}
			,descTerms = {' [iI]ncapacitat','^Incapacitated','Disoriented'}
			,message = 'is incapacitated for [remaining] seconds ({SPELL_LINK})'
			,recoverMessage = 'is no longer incapacitated'
		}
		,root = {
			debuffs = {}
			,names = {'Freeze','Root','Entangling Roots','Frozen'}
			,descTerms = {' [rR]oot','^Rooted','[fF]rozen','[iI]mmobili[sz]ed'}
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
			,descTerms = {' [sS]tun','^Stun'}
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
				local lastAnnounce = info.lastAnnounce or 0;
				local theTime = GetTime();
				local repeatLimit = info.repeatLimit or 2;
				local safeToAnnounce = (theTime - lastAnnounce >= repeatLimit or lastAnnounce==0);
				if(type(info.extraInfo)=="function") then debuff.extraInfo = info.extraInfo(); end
				if(type(message)=="function") then message = message(debuff); end
				local recoverMessage = info.recoverMessage;
				if(type(recoverMessage)=="function") then recoverMessage = recoverMessage(debuff); end
				message = Debuffs.fillMsg(message,debuff);
				recoverMessage = Debuffs.fillMsg(recoverMessage,debuff);
				if(debuff.remaining>0 and debuff.remaining%2==0 and safeToAnnounce) then LCU.announcePlayer(message);
				elseif(debuff.remaining==0) then LCU.announcePlayer(recoverMessage) end
				Debuffs.types[dbType].lastAnnounce = theTime;
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

local lastDebuffMessage = 0
function checkDebuffs()
	Debuffs.get()
	Debuffs.checkDebuffs()
	--if(#LCU.player.debuffs > 0 and LCU.debugMode==true) then
	if(#LCU.player.debuffs > 0 and GetTime()-lastDebuffMessage > 8 and LCU.debugMode==true) then
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
end