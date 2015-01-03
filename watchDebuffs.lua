LCU.player.debuffs = {};
Debuffs = {
	types = {
		fear = {
			debuff = false
			,enabled = true
			,names = {'Fear','Feared','Scare','Scared','Psychic Scream'}
			,descTerms = {' [fF]ear','^Fear','[sS]cared','flee in terror'}
			,message = LCLang.dynaGet('%REF is feared for [remaining] seconds - {SPELL_LINK}')
			,recoverMessage = LCLang.dynaGet('%REF is no longer feared')
		}
		,charm = {
			debuff = false
			,enabled = true
			,names = {'Charm','Charmed','Mind Control'}
			,descTerms = {'[cC]harmed'}
			,message = LCLang.dynaGet('%REF has been charmed for [remaining] seconds - {SPELL_LINK}')
			,recoverMessage = LCLang.dynaGet('%REF is no longer charmed')
		}
		,incap = {
			debuff = false
			,enabled = true
			,names = {'Polymorph','Freeze','Hex','Hibernate','Choking','Choking Vines'}
			,descTerms = {' [iI]ncapacitat','^Incapacitated','[dD]isoriented','[sS]apped','unable to act','[cC]hoke','[cC]hoking'}
			,message = LCLang.dynaGet('%REF is incapacitated for [remaining] seconds - {SPELL_LINK}')
			,recoverMessage = LCLang.dynaGet('%REF is no longer incapacitated')
		}
		,sleep = {
			debuff = false
			,enabled = true
			,names = {'Sleep'}
			,descTerms = {'[dD]eep slumber','[sS]lumber','[aA]sleep','[sS]leeping'}
			,message = LCLang.dynaGet('%REF is asleep for [remaining] seconds - {SPELL_LINK}')
			,recoverMessage = LCLang.dynaGet('%REF is no longer asleep')
		}
		,root = {
			debuff = false
			,enabled = true
			,names = {'Freeze','Root','Entangling Roots','Charge','Frozen'}
			,descTerms = {' [rR]oot','^Rooted','[fF]rozen','[iI]mmobiliz'}
			,message = LCLang.dynaGet('%REF has been rooted for [remaining] seconds - {SPELL_LINK}')
			,recoverMessage = LCLang.dynaGet('%REF is no longer rooted')
		}
		,silence = {
			debuff = false
			,enabled = true
			,names = {'Silence','Solar Beam','Strangulate','Arcane Torrent','Silencing Shot'}
			,descTerms = {'Silenced',' ?[sS]ilence[ds]?','[cC]annot cast spells','[pP]acified'}
			,message = LCLang.dynaGet('%REF has been silenced for [remaining] seconds - {SPELL_LINK}')
			,recoverMessage = LCLang.dynaGet('%REF is no longer silenced')
		}
		,slow = {
			debuff = false
			,enabled = false
			,names = {'Dazed','Daze','Slow','Slowed','Hamstring','Ice Trap'}
			,descTerms = {' [sS]low','^Slow',' [dD]azed?','^Dazed?','speed reduced'}
			,message = LCLang.dynaGet('%REF has been slowed for [remaining] seconds - {SPELL_LINK}')
			,recoverMessage = LCLang.dynaGet('%REF is no longer slowed')
		}
		,stun = {
			debuff = false
			,enabled = true
			,names = {'Stun','Stunned','Stomp'}
			,descTerms = {' [sS]tun','^Stun'}
			,message = LCLang.dynaGet('%REF has been stunned for [remaining] seconds - {SPELL_LINK}')
			,recoverMessage = LCLang.dynaGet('%REF is no longer stunned')
		}
		,spellLock = { --UNIT_SPELLCAST_INTERRUPTED , UNIT_SPELLCAST_STOP , UNIT_SPELLCAST_FAILED , UNIT_SPELLCAST_FAILED_QUIET
			debuff = false
			,enabled = true
			,names = {}
			,descTerms = {'preventing any spell in that school','preventing any spell from that school'}
			,message = LCLang.dynaGet('%REF has been spell locked (%SCH) for [remaining] seconds - {SPELL_LINK}')
			,recoverMessage = LCLang.dynaGet('%REF is no longer spell locked (%SCH)')
			--[[
			School can be checked with:
			List of one spell for each spell school per class & spec
			Check last interrupted spellID with IsUsableSpell (returns: usable, nomana)
			Check last interrupted spellID isn't on cooldown with GetSpellCooldown (returns: start, duration, enabled)
			(maybe check GetSpellDescription ?)
			--]]
		}
	}
	,addName = function(dbType,name)
		if(Debuffs.types[dbType]==nil) then return false; end
		local found = false;
		for k,v in pairs(Debuffs.types[dbType].names) do
			if(v == name) then found = true; end
		end
		if(found == false) then table.insert(Debuffs.types[dbType].names,name); end
	end
	,addNames = function(dbType,names)
		for k,name in pairs(names) do
			Debuffs.addName(dbType,name);
		end
	end
	,addDesc = function(dbType,desc)
		if(Debuffs.types[dbType]==nil or type(desc)~='string') then return false; end
		local found = false;
		for k,v in pairs(Debuffs.types[dbType].descTerms) do
			if(v == desc) then found = true; end
		end
		if(found == false) then
			table.insert(Debuffs.types[dbType].descTerms,desc);
		end
	end
	,addDescs = function(dbType,descs)
		for k,desc in pairs(descs) do
			Debuffs.addDesc(dbType,desc);
		end
	end
	,getDebuffMessage = function(dbType)
		if(Debuffs.types[dbType]==nil) then return ''; end
		return LCcfg.get('db_message_'..dbType,Debuffs.types[dbType].message);
	end
	,getDebuffRecoverMessage = function(dbType)
		if(Debuffs.types[dbType]==nil) then return ''; end
		return LCcfg.get('db_recovermessage_'..dbType,Debuffs.types[dbType].recoverMessage);
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
		local role = LCcfg.getPlayerSpecRole();
		if(role=='dps') then role = 'DPS';
		else role = LCU.upperFirst(role); end
		local ref = role=='DPS' and LCLang.get('A DPS') or LCLang.get('The '..LCU.player.role);
		ref = ref..' ('..LCU.player.name..')';
		local newMsg = msg;
		newMsg = newMsg:gsub('%[remaining%]',tostring(LCU.round(debuff.remaining)));
		newMsg = newMsg:gsub('%%TR',tostring(LCU.round(debuff.remaining)));
		newMsg = newMsg:gsub('%{SPELL_LINK%}',(GetSpellLink(debuff.id)));
		newMsg = newMsg:gsub('%%SL',(GetSpellLink(debuff.id)));
		newMsg = newMsg:gsub('%%NM',LCU.player.name);
		newMsg = newMsg:gsub('%%RL',role);
		newMsg = newMsg:gsub('%%rl',string.lower(role));
		newMsg = newMsg:gsub('%%REF',ref);
		local spellSchool = '';
		if(LCU.player.lastInterrupt~=nil and LCU.player.lastInterrupt.onSpellSchool) then spellSchool = LCU.player.lastInterrupt.onSpellSchool; end
		newMsg = newMsg:gsub('%%SCH',spellSchool);
		newMsg = newMsg:gsub('%%sch',string.lower(spellSchool));
		return newMsg;
	end
	,checkDebuffs = function()
		local announcedDebuff = false;
		for dbType,info in pairs(Debuffs.types) do
			if(info.debuff ~= false and info.enabled==true) then
				local debuff = info.debuff;
				local lastAnnounce = info.lastAnnounce or 0;
				local theTime = GetTime();
				local timeDiff = theTime - lastAnnounce;
				local repeatLimit = nil;
				if(info.repeatLimit) then
					repeatLimit = info.repeatLimit;
				else
					repeatLimit = 6;
					if(debuff.remaining >= 20) then repeatLimit = 12; end
					if(debuff.remaining >= 30) then repeatLimit = 18; end
					if(debuff.remaining >= 50) then repeatLimit = 18; end
					if(debuff.remaining >= 75) then repeatLimit = 20; end
				end
				local safeToAnnounce = (timeDiff >= repeatLimit and debuff.remaining >= LCcfg.get('minDebuffTime',3)) or lastAnnounce==0;
				if(type(info.extraInfo)=="function") then debuff.extraInfo = info.extraInfo(debuff); end
				local message = Debuffs.getDebuffMessage(dbType);
				if(type(message)=="function") then message = message(debuff); end
				local recoverMessage = Debuffs.getDebuffRecoverMessage(dbType);
				if(type(recoverMessage)=="function") then recoverMessage = recoverMessage(debuff); end
				message = Debuffs.fillMsg(message,debuff);
				recoverMessage = Debuffs.fillMsg(recoverMessage,debuff);
				local stillThere = debuff.type=='test';
				for _,d in pairs(LCU.player.debuffs) do
					if(d.name == debuff.name) then stillThere = true; end
				end
				local announcedRecovery = info.announcedRecovery;
				if(safeToAnnounce and debuff.remaining > 0) then
					LCU.sendMsg(message);
					Debuffs.types[dbType].announcedRecovery = false;
					announcedDebuff = true;
					Debuffs.types[dbType].lastAnnounce = theTime;
				elseif((debuff.remaining<=0.5 or stillThere==false) and announcedRecovery~=true) then
					Debuffs.types[dbType].debuff = false;
					Debuffs.types[dbType].announcedRecovery = true;
					LCU.sendMsg(recoverMessage);
					Debuffs.types[dbType].lastAnnounce = GetTime()-(repeatLimit-2);
				end
			end
		end
		local hadControl = LCU.player.hasControl;
		LCU.player.hasControl = HasFullControl();
		if(LCU.debugMode) then
			if(announcedDebuff == false and (hadControl and not LCU.player.hasControl)) then
				LCU.announcePlayer('has lost control of their character.');
				--[[
				TEMPORARY
				--]]
				if(not LCcfg.get('missingDebuffs')) then LCcfg.set('missingDebuffs',{}); end
				for dbType,info in pairs(Debuffs.types) do
					if(info.debuff ~= false) then
						local debuff = info.debuff;
						local missing = LCcfg.get('missingDebuffs');
						if(LCU.debugMode) then print('Missed: '..debuff.name..' __ '..debuff.description); end
						missing[debuff.name] = debuff.description;
					end
				end
				--[[
				TEMPORARY
				--]]
			elseif(LCU.player.hasControl and not hadControl) then
				LCU.announcePlayer('has regained control of their character.');
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
	,_fakeAura = false
	,addFakeAura = function(type,auraData)
		Debuffs._fakeAura = auraData;
	end
	,getAura = function(who,i,auraType)
		local a = UnitAura(who,i,auraType);
		if(a==nil and Debuffs._fakeAura) then
			local n,rank,_,_,dbType,duration,expires,_,_,_,id;
			local fakeA = Debuffs._fakeAura;
			n = fakeA.name;
			rank = fakeA.rank;
			dbType = fakeA.type;
			duration = fakeA.length;
			expires = GetTime()+fakeA.remaining;
			id = fakeA.id;
			Debuffs._fakeAura = false;
			return n,rank,_,_,dbType,duration,expires,_,_,_,id;
		else
			local n,rank,_,_,dbType,duration,expires,_,_,_,id = UnitAura(who,i,auraType);
			return n,rank,_,_,dbType,duration,expires,_,_,_,id;
		end
	end
	,get = function(who)
		who = who or "player";
		local debuffs = {};
		local scanAuras = true;
		local auraI = 1;
		while(scanAuras==true) do
			local n,rank,_,_,dbType,duration,expires,_,_,_,id = Debuffs.getAura(who,auraI,'HARMFUL');
			if(n ~= nil and expires ~= nil) then
				local desc = GetSpellDescription(id) or '';
				local debuff = {name=n,rank=rank,["type"]=(dbType or ''),length=duration,remaining=LCU.round(expires-GetTime()),desc=desc,id=id,extraInfo=''};
				debuffs[#debuffs+1] = debuff;
				local dbType = Debuffs.getType(debuff);
				--if(dbType==false and LCU.debugMode) then LCU.sendMsg('Couldnt find type for "'..debuff.name..'" = "'..debuff.desc..'"') end
				if(dbType~=false) then
					local currD = Debuffs.types[dbType].debuff;
					if(currD==false or (type(currD)=='table' and not (currD.id ~= debuff.id and debuff.remaining<LCcfg.get('minDebuffTime')))) then
						if(currD==false or currD.remaining < debuff.remaining or (debuff.remaining<currD.remaining and debuff.id==currD.id)) then
							Debuffs.types[dbType].debuff = debuff;
						end
					end
				end
			end
			if(n == nil or auraI >= 40) then scanAuras = false; end
			auraI = auraI+1;
		end
		if(not LCU[who]) then LCU[who] = {}; end
		LCU[who]['debuffs'] = debuffs;
		return debuffs;
	end
	,test = function(dbType)
		local tests = {
			slow = 31589 --Slow
			,fear = 5782 --Fear
			--,charm = 3384 --Mass Charm
			--,incap = 115078 --Paralysis
			,incap = 115877 --Fully Petrified
			,stun = 853 --Hammer of Justice
			,sleep = 31298 --Sleep
			,root = 339 --Entangling Roots
			,silence = 15487 --Silence
			,spellLock = 53550 --Mind Freeze
		}
		if(tests[dbType] and Debuffs.types[dbType].debuff==false) then
			local dbid = tests[dbType];
			local desc = GetSpellDescription(dbid);
			local spName,spRank = GetSpellInfo(dbid);
			local debuff = {name=spName,rank=spRank,["type"]='test',length=9,remaining=8,desc=desc,id=dbid,extraInfo=''};
			Debuffs.addFakeAura('HARMFUL',debuff);
			if(dbType=='spellLock') then
				local intSpellSchool = 8;
				local intSpellSchoolName = LCU.spellSchoolByNum(intSpellSchool);
				LCU.player.lastInterrupt = {
					bySpellID = 53550,
					bySpellName = 'Mind Freeze',
					onSpellID = 61882,
					onSpellName = 'Earthquake',
					onSpellSchool = intSpellSchoolName,
				};
			end
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
	if(Debuffs._fakeAura ~= false) then Debuffs._fakeAura.remaining = Debuffs._fakeAura.remaining-0.25; end
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