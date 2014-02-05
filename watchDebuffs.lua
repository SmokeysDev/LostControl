LCU.player.debuffs = {};
Debuffs = {
	types = {
		fear = {
			debuff = false
			,enabled = true
			,names = {'Fear','Feared','Scare','Scared','Psychic Scream'}
			,descTerms = {' [fF]ear','^Fear','[sS]cared','flee in terror'}
			,message = 'is feared for [remaining] seconds - {SPELL_LINK}'
			,recoverMessage = 'is no longer feared'
		}
		,incap = {
			debuff = false
			,enabled = true
			,names = {'Polymorph','Freeze','Fear','Hex','Hibernate'}
			,descTerms = {' [iI]ncapacitat','^Incapacitated','Disoriented'}
			,message = 'is incapacitated for [remaining] seconds - {SPELL_LINK}'
			,recoverMessage = 'is no longer incapacitated'
		}
		,sleep = {
			debuff = false
			,enabled = true
			,names = {'Sleep'}
			,descTerms = {'[dD]eep slumber','[sS]lumber','[aA]sleep','[sS]leeping'}
			,message = 'is asleep for [remaining] seconds - {SPELL_LINK}'
			,recoverMessage = 'is no longer asleep'
		}
		,root = {
			debuff = false
			,enabled = true
			,names = {'Freeze','Root','Entangling Roots','Frozen'}
			,descTerms = {' [rR]oot','^Rooted','[fF]rozen','[iI]mmobiliz'}
			,message = 'has been rooted for [remaining] seconds - {SPELL_LINK}'
			,recoverMessage = 'is no longer rooted'
		}
		,silence = {
			debuff = false
			,enabled = true
			,names = {'Silence','Solar Beam','Strangulate','Arcane Torrent','Silencing Shot'}
			,descTerms = {' [sS]ilenced?','^Silenced'}
			,message = 'has been silenced for [remaining] seconds - {SPELL_LINK}'
			,recoverMessage = 'is no longer silenced'
		}
		,slow = {
			debuff = false
			,enabled = false
			,names = {'Dazed','Daze','Slow','Slowed','Hamstring','Ice Trap'}
			,descTerms = {' [sS]low','^Slow',' [dD]azed?','^Dazed?','speed reduced'}
			,message = 'has been slowed for [remaining] seconds - {SPELL_LINK}'
			,recoverMessage = 'is no longer slowed'
		}
		,stun = {
			debuff = false
			,enabled = true
			,names = {'Stun','Stunned','Charge','Stomp'}
			,descTerms = {' [sS]tun','^Stun'}
			,message = 'has been stunned for [remaining] seconds - {SPELL_LINK}'
			,recoverMessage = 'is no longer stunned'
		}
	}
	,emptyTypeCache = function()
		for type,info in pairs(Debuffs.types) do
			Debuffs.types[type].debuffs = {}
		end
	end
	,isType = function(debuff,dbType)
		if(Debuffs.types[dbType]==nil or not LCcfg.watching(dbType)) then return false; end
		for k,v in pairs(Debuffs.types[dbType].names) do
			if(debuff.name == v) then return true; end
		end
		for k,v in pairs(Debuffs.types[dbType].descTerms) do
			if(string.match(debuff.desc,v)~=nil) then return true; end
		end
		return false;
	end
	,getType = function(debuff)
		for dbType in pairs(Debuffs.types) do
			if(Debuffs.isType(debuff,dbType)) then return dbType; end
		end
		return false;
	end
	,fillMsg = function(msg,debuff)
		local ret = msg;
		ret = ret:gsub('%[remaining%]',tostring(LCU.round(debuff.remaining)));
		ret = ret:gsub('%{SPELL_LINK%}',(GetSpellLink(debuff.id)));
		return ret;
	end
	,checkDebuffs = function()
		local auraType = LCU.debugMode and 'HELPFUL' or 'HARMFUL';
		for dbType,info in pairs(Debuffs.types) do
			if(info.debuff ~= false) then
				local debuff = info.debuff;
				local lastAnnounce = info.lastAnnounce or 0;
				local theTime = GetTime();
				local repeatLimit = info.repeatLimit or 5;
				local safeToAnnounce = (theTime - lastAnnounce >= repeatLimit or lastAnnounce==0);
				if(type(info.extraInfo)=="function") then debuff.extraInfo = info.extraInfo(debuff); end
				local message = info.message;
				if(type(message)=="function") then message = message(debuff); end
				local recoverMessage = info.recoverMessage;
				if(type(recoverMessage)=="function") then recoverMessage = recoverMessage(debuff); end
				message = Debuffs.fillMsg(message,debuff);
				recoverMessage = Debuffs.fillMsg(recoverMessage,debuff);
				local stillThere = debuff.type=='test';
				for _,d in pairs(LCU.player.debuffs) do
					if(d.name == debuff.name) then stillThere = true; end
				end
				if(debuff.remaining>0 and safeToAnnounce) then
					LCU.announcePlayer(message);
					Debuffs.types[dbType].lastAnnounce = theTime;
				elseif(debuff.remaining<=0 or stillThere==false) then
					LCU.announcePlayer(recoverMessage);
					Debuffs.types[dbType].lastAnnounce = 0;
					Debuffs.types[dbType].debuff = false;
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
				if(dbType==false and LCU.debugMode) then LCU.sendMsg('Couldnt find type for "'..debuff.name..'" = "'..debuff.desc..'"') end
				if(dbType~=false) then
					local currD = Debuffs.types[dbType].debuff;
					if(type(currD)=='table' and not (currD.id ~= debuff.id and debuff.remaining<LCcfg.get('minDebuffTime'))) then
						if(currD==false or currD.remaining < debuff.remaining or (debuff.remaining<currD.remaining and debuff.id==currD.id)) then
							Debuffs.types[dbType].debuff = debuff;
						end
					end
				end
			end
		end
		if(not LCU[who]) then LCU[who] = {}; end
		LCU[who]['debuffs'] = debuffs;
		return debuffs;
	end
	,test = function(dbType)
		local tests = {
			slow = 31589 --Slow
			,fear = 5782 --Fear
			,incap = 115078 --Paralysis
			,stun = 853 --Hammer of Justice
			,sleep = 31298 --Sleep
			,root = 339 --Entangling Roots
			,silence = 15487 --Silence
		}
		if(tests[dbType] and Debuffs.types[dbType].debuff==false) then
			local dbid = tests[dbType];
			local desc = GetSpellDescription(dbid);
			local spName,spRank = GetSpellInfo(dbid);
			local debuff = {name=spName,rank=spRank,["type"]='test',length=9,remaining=8,desc=desc,id=dbid,extraInfo=''};
			Debuffs.types[dbType].debuff = debuff;
		end
	end
}

local lastDebuffMessage = 0
function checkDebuffs()
	local who = 'player';
	Debuffs.get(who)
	Debuffs.checkDebuffs()
	for dbType,db in pairs(Debuffs.types) do
		if(db.debuff and db.debuff.type == 'test') then db.debuff.remaining = db.debuff.remaining-0.25; end
	end
	if(#LCU.player.debuffs > 0 and GetTime()-lastDebuffMessage >= 8 and LCU.debugMode==true) then
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