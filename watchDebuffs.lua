Debuffs = {
	locEffectTypeMap = {
		CONFUSE = 'incap',
		STUN_MECHANIC = 'stun',
		STUN = 'stun',
		SILENCE = 'silence',
		PACIFYSILENCE = 'silence',
		PACIFY = 'silence',
		FEAR_MECHANIC = 'fear',
		FEAR = 'fear',
		CHARM = 'charm',
		POSSESS = 'charm',
		DISARM = 'disarm',
		ROOT = 'root',
		SCHOOL_INTERRUPT = 'interrupt'
	},
	getByLocAPI = function(who)
		local who = who or "player";
		local debuffs = {};
		local locEvents = 0;
		if (who == 'player') then
			locEvents = C_LossOfControl.GetActiveLossOfControlDataCount();
		else
			locEvents = C_LossOfControl.GetActiveLossOfControlDataCountByUnit(who) or 0;
		end
		for i=1, locEvents, 1
		do
			local ev = nil;
			if (who == 'player') then
				ev = C_LossOfControl.GetActiveLossOfControlData(i);
			else
				ev = C_LossOfControl.GetActiveLossOfControlDataByUnit(who, i);
			end

			-- SILENCE, SCHOOL_INTERRUPT
			-- FEAR_MECHANIC, FEAR, STUN_MECHANIC, STUN, PACIFYSILENCE, PACIFY, CHARM, DISARM, ROOT, CONFUSE, POSSESS
			-- missing = slow, incapacitated, sleep
			-- confuse = polymorph (incap?)

			local dbType = Debuffs.locEffectTypeMap[ev.locType];
			if (dbType ~= nil) then
				local debuff = {
					name = ev.displayText,
					icon = nil,
					["type"] = dbType,
					length = ev.duration,
					remaining = LCU.round(ev.timeRemaining),
					desc = desc,
					id = ev.spellID,
					source = 'api',
					extraInfo = ''
				};
				local desc = GetSpellDescription(ev.spellID);
				if (dbType == 'interrupt') then
					if (ev.lockoutSchool == 0) then
						debuff.type = nil;
					else
						local schoolName = GetSchoolString(ev.lockoutSchool);
						if (schoolName == 'Unknown') then
							debuff.type = nil;
						else
							debuff.type = 'spellLock';
							debuff.extraInfo = schoolName;
						end
					end
				end
				if (debuff.remaining == nil) then
					debuff.remaining = 999;
				end
				if (debuff.type ~= nil and debuff.remaining > 0) then
					local currDb = Debuffs.types[debuff.type].debuff;
					if (currDb == false) then
						debuffs[debuff.type] = debuff;
					elseif (debuff.remaining > currDb.remaining or currDb.id == debuff.id) then
						debuffs[debuff.type] = debuff;
					end
				end
			-- else
			-- 	LCMessage('unknown effect ' .. i .. ' - ' .. ev.locType .. ev.displayText .. LCU.str(ev.timeRemaining) .. GetSpellLink(ev.spellID), 'PRINT', LCU.round(ev.timeRemaining/2))
			end
		end
		return debuffs;
	end
	,getByDebuffs = function(who)
		who = who or 'player';
		local debuffs = {};
		local scanAuras = true;
		local auraI = 1;
		while(scanAuras==true) do
			local n,icon,_,dbType,duration,expires,_,_,_,id = Debuffs.getAura(who,auraI,'HARMFUL');
			if(n ~= nil and expires ~= nil) then
				local desc = GetSpellDescription(id) or '';
				local debuff = {
					name = n,
					icon = icon,
					["type"] = (dbType or ''),
					length = duration,
					remaining = LCU.round(expires-GetTime()),
					desc = desc,
					id = id,
					extraInfo = '',
					source = 'debuff'
				};
				local dbType = Debuffs.getType(debuff);
				if(dbType==false and LCU.debugMode) then LCU.sendMsg('Couldnt find type for "'..debuff.name..'" = "'..debuff.desc..'"') end
				if(dbType~=false) then
					debuffs[dbType] = debuff;
				end
			end
			if(n == nil or auraI >= 40) then scanAuras = false; end
			auraI = auraI+1;
		end
		return debuffs;
	end
	,types = {
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
		,disarm = {
			debuff = false
			,enabled = true
			,names = {'Disarm','Disarmed'}
			,descTerms = {'[dD]isarm'}
			,message = LCLang.dynaGet('%REF has been disarmed for [remaining] seconds - {SPELL_LINK}')
			,recoverMessage = LCLang.dynaGet('%REF is no longer disarmed')
		}
		,incap = {
			debuff = false
			,enabled = true
			,names = {'Polymorph','Freeze','Hex','Hibernate','Choking','Choking Vines'}
			,ignoreNames = {'Unbreakable Will'}
			,descTerms = {' [iI]ncapacitat','^Incapacitated','[dD]isorient','[sS]apped','unable to act','[cC]hoke','[cC]hoking'}
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
		,oom = {
			debuff = false
			,enabled = true
			,names = {}
			,descTerms = {}
			,message = LCLang.dynaGet('%REF is out of mana!')
			,recoverMessage = LCLang.dynaGet('%REF has mana again')
		}
		,root = {
			debuff = false
			,enabled = true
			,names = {'Freeze','Root','Entangling Roots','Frozen'}
			,descTerms = {' [rR]oot','^Rooted','[fF]rozen','[iI]mmobiliz'}
			,message = LCLang.dynaGet('%REF has been rooted for [remaining] seconds - {SPELL_LINK}')
			,recoverMessage = LCLang.dynaGet('%REF is no longer rooted')
		}
		,silence = {
			debuff = false
			,enabled = true
			,names = {'Silence','Solar Beam','Strangulate','Arcane Torrent','Silencing Shot'}
			,ignoreNames = {'Unstable Afflication'}
			,descTerms = {'Silenced',' ?[sS]ilence[ds]?','[cC]annot cast spells','[pP]acified'}
			,message = LCLang.dynaGet('%REF has been silenced for [remaining] seconds - {SPELL_LINK}')
			,recoverMessage = LCLang.dynaGet('%REF is no longer silenced')
		}
		,slow = {
			debuff = false
			,enabled = true
			,names = {'Dazed','Daze','Slow','Slowed','Hamstring','Ice Trap'}
			,descTerms = {' [sS]low','^Slow',' [dD]azed?','^Dazed?','movement speed reduced'}
			,message = LCLang.dynaGet('%REF has been slowed for [remaining] seconds - {SPELL_LINK}')
			,recoverMessage = LCLang.dynaGet('%REF is no longer slowed')
		}
		,stun = {
			debuff = false
			,enabled = true
			,names = {'Stun','Stunned','Stomp'}
			,ignoreNames = {'Rake'}
			,descTerms = {' [sS]tun','^Stun'}
			,message = LCLang.dynaGet('%REF has been stunned for [remaining] seconds - {SPELL_LINK}')
			,recoverMessage = LCLang.dynaGet('%REF is no longer stunned')
		}
		,spellLock = { --UNIT_SPELLCAST_INTERRUPTED , UNIT_SPELLCAST_STOP , UNIT_SPELLCAST_FAILED , UNIT_SPELLCAST_FAILED_QUIET
			debuff = false
			,enabled = true
			,names = {}
			,descTerms = {'preventing any spell in that school','preventing any spell from that school'}
			,message = LCLang.dynaGet('%REF has been %sch locked for [remaining] seconds - {SPELL_LINK}')
			,recoverMessage = LCLang.dynaGet('%REF is no longer %sch locked')
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
		local ret = false;
		for k,v in pairs(Debuffs.types[dbType].names) do
			if(debuff.name == v) then ret = true; end
		end
		-- These are basic protection against unwanted matches where effects say "At 5 stacks they are stunned"/"if dispelled"
		local excludeTerms = {'[dD]ispel','stack','application'};
		for k,v in pairs(Debuffs.types[dbType].descTerms) do
			if(string.match(debuff.desc,v)~=nil and string.match(debuff.desc,'stack')==nil) then
				ret = true;
				for i,term in pairs(excludeTerms) do
					if(ret == true and string.match(debuff.desc,term)~=nil) then
						ret = false;
					end
				end
			end
		end
		if(ret == true) then
			for k,v in pairs(Debuffs.types[dbType].ignoreNames or {}) do
				if(debuff.name == v) then ret = false; end
			end
		end
		return ret;
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
		local ref = role=='DPS' and LCLang.get('A DPS') or LCLang.get('The '..role);
		ref = ref..' ('..LCU.player.name..')';
		local newMsg = msg;
		if(debuff.remaining == nil or debuff.remaining > 100) then
			newMsg = newMsg:gsub(' for %[remaining%] seconds', '');
		end
		newMsg = newMsg:gsub('%[remaining%]',tostring(LCU.round(debuff.remaining)));
		newMsg = newMsg:gsub('%%TR',tostring(LCU.round(debuff.remaining)));
		newMsg = newMsg:gsub('%{SPELL_LINK%}',(GetSpellLink(debuff.id) or ''));
		newMsg = newMsg:gsub('%%SL',(GetSpellLink(debuff.id) or ''));
		newMsg = newMsg:gsub('%%NM',LCU.player.name);
		newMsg = newMsg:gsub('%%RL',role);
		newMsg = newMsg:gsub('%%rl',string.lower(role));
		newMsg = newMsg:gsub('%%REF',ref);
		newMsg = newMsg:gsub('%%SCH',debuff.extraInfo);
		newMsg = newMsg:gsub('%%sch',string.lower(debuff.extraInfo));
		return newMsg;
	end
	,checkDebuffs = function(debuffs, who)
		who = who or 'player';
		if (type(LCU.debuffs[who]) ~= 'table') then
			LCU.debuffs[who] = {};
		end
		local announcedDebuff = false;
		for dbType,info in pairs(Debuffs.types) do
			if(LCcfg.watching(dbType) and (LCU.debuffs[who][dbType] ~= nil or debuffs[dbType] ~= nil)) then
				local currDebuff = LCU.debuffs[who][dbType];
				local debuff = debuffs[dbType];
				local hasGone = false;
				if(debuff == nil) then
					debuff = currDebuff;
					hasGone = true;
				end
				local lastAnnounce = info.lastAnnounce or 0;
				local theTime = GetTime();
				local timeDiff = theTime - lastAnnounce;
				local repeatLimit = nil;
				if(info.repeatLimit) then
					repeatLimit = info.repeatLimit;
				elseif(hasGone == false) then
					repeatLimit = 6;
					if(debuff.remaining >= 20) then repeatLimit = 12; end
					if(debuff.remaining >= 30) then repeatLimit = 18; end
					if(debuff.remaining >= 50) then repeatLimit = 18; end
					if(debuff.remaining >= 75) then repeatLimit = 20; end
				else
					repeatLimit = 9;
				end
				local minDebuffTime = LCcfg.getMinDebuffTime(dbType);
				local safeToAnnounce = (timeDiff >= repeatLimit or lastAnnounce==0) and debuff.remaining >= minDebuffTime;
				if(LCU.debugMode and debuff.remaining > 0 and debuff.remaining < minDebuffTime) then print(dbType .. ' warning stopped due to min debuff time config: ' .. debuff.remaining .. ' < ' .. minDebuffTime); end
				if(type(info.extraInfo)=="function") then debuff.extraInfo = info.extraInfo(debuff); end
				local message = Debuffs.getDebuffMessage(dbType);
				if(type(message)=="function") then message = message(debuff); end
				local recoverMessage = Debuffs.getDebuffRecoverMessage(dbType);
				if(type(recoverMessage)=="function") then recoverMessage = recoverMessage(debuff); end
				message = Debuffs.fillMsg(message,debuff);
				recoverMessage = Debuffs.fillMsg(recoverMessage,debuff);
				if(safeToAnnounce and debuff.remaining > 0 and hasGone == false) then
					if info.announcedDebuff == false or debuff.remaining > 0.75 then
						LCU.sendMsg(message);
					end
					info.announcedRecovery = false;
					info.announcedDebuff = true;
					announcedDebuff = true;
					info.lastAnnounce = theTime;
				elseif(info.announcedDebuff == true and (debuff.remaining<=0.2 or hasGone==true) and info.announcedRecovery~=true) then
					debuffs[dbType] = nil;
					info.announcedRecovery = true;
					info.announcedDebuff = false;
					if(recoverMessage ~= '-') then
						LCU.sendMsg(recoverMessage);
					end
					info.lastAnnounce = GetTime()-(repeatLimit-2);
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
						if(LCU.debugMode) then print('Missed: '..debuff.name..' __ '..(debuff.description or '(no description)')); end
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
			local name = GetSpellInfo(debuff);
			debuff = {id=debuff,name=name};
		end
		return GetSpellLink(debuff.id);
	end
	,_fakeAura = false
	,addFakeAura = function(type,auraData)
		Debuffs._fakeAura = auraData;
	end
	,getAura = function(who,i,auraType)
		local a = UnitAura(who,i,auraType);
		if(a==nil and Debuffs._fakeAura) then
			local n,icon,_,dbType,duration,expires,_,_,_,id;
			local fakeA = Debuffs._fakeAura;
			n = fakeA.name;
			icon = fakeA.icon;
			dbType = fakeA.type;
			duration = fakeA.length;
			expires = GetTime()+fakeA.remaining;
			id = fakeA.id;
			if (fakeA.remaining <= 0.1) then
				Debuffs._fakeAura = false;
			end
			return n,icon,_,dbType,duration,expires,_,_,_,id;
		else
			local n,icon,_,dbType,duration,expires,_,_,_,id = UnitAura(who,i,auraType);
			return n,icon,_,dbType,duration,expires,_,_,_,id;
		end
	end
	,test = function(dbType)
		local tests = {
			slow = 31589 --Slow
			,fear = 5782 --Fear
			--,charm = 3384 --Mass Charm
			--,incap = 115078 --Paralysis
			--,incap = 115877 --Fully Petrified
			,disarm = 236077
			,incap = 182234 --Unbreakable will
			,stun = 853 --Hammer of Justice
			,sleep = 31298 --Sleep
			,root = 339 --Entangling Roots
			,silence = 15487 --Silence
			,spellLock = 53550 --Mind Freeze
		}
		if(tests[dbType] and Debuffs.types[dbType].debuff==false) then
			local dbid = tests[dbType];
			local desc = GetSpellDescription(dbid);
			local spName = GetSpellInfo(dbid);
			local debuff = {name=spName,["type"]='test',length=9,remaining=3,desc=desc,id=dbid,extraInfo=''};
			if(dbType=='spellLock') then
				debuff.extraInfo = 'Nature';
				Debuffs.addFakeAura('HARMFUL',debuff);
			else
				Debuffs.addFakeAura('HARMFUL',debuff);
			end
		end
	end
}

local lastDebuffMessage = 0
function checkDebuffs()
	local who = 'player';
	local apiDbs = Debuffs.getByLocAPI(who);
	local dbDbs = Debuffs.getByDebuffs(who);
	local debuffs = {};

	if (type(LCU.debuffs[who]) ~= 'table') then
		LCU.debuffs[who] = {};
	end

	for dbType,_ in pairs(Debuffs.types) do
		debuffs[dbType] = nil;
		local dbVal = dbDbs[dbType];
		local apiVal = apiDbs[dbType];
		if (dbVal ~= nil or apiVal ~= nil) then
			if (type(dbVal)=='table') then
				debuffs[dbType] = dbVal;
			end
			if (type(apiVal)=='table' and (debuffs[dbType] == nil or debuffs[dbType].remaining < apiVal.remaining + 0.1)) then
				debuffs[dbType] = apiVal;
			end
		end
	end

	-- check for debuff found debuff, matching a spell on a different type by the api
	-- debuff description matching probs more accurate, so drop api version of same spell id
	for dbType,db in pairs(debuffs) do
		if (db ~= nil) then
			for dbType2,db2 in pairs(debuffs) do
				if (db2 ~= nil and dbType2 ~= dbType and db2.id == db.id) then
					if (db.source == 'api' and db2.source == 'debuff') then
						debuffs[dbType] = nil;
					elseif (db.source == 'debuff' and db2.source == 'api') then
						debuffs[dbType2] = nil;
					end
				end
			end
		end
	end

	local maxMana = UnitPowerMax(who, Enum.PowerType.Mana) or 0;
	if (maxMana > 0) then
		local mana = UnitPower(who, Enum.PowerType.Mana);
		local perc = (mana / maxMana) * 100;
		if (perc < tonumber(LCcfg.get('oomBreakpoint', 15, false))) then
			debuffs.oom = {
				name = 'Out of mana',
				icon = nil,
				["type"] = 'oom',
				length = 10,
				remaining = 10,
				desc = 'Out of mana',
				id = 0,
				extraInfo = '',
				source = 'oom'
			};
		end
	end

	Debuffs.checkDebuffs(debuffs, who);

	for dbType,_ in pairs(Debuffs.types) do
		LCU.debuffs[who][dbType] = debuffs[dbType];
	end

	if(Debuffs._fakeAura ~= false) then
		Debuffs._fakeAura.remaining = Debuffs._fakeAura.remaining-0.25;
	end

	if(#LCU.debuffs[who] > 0 and GetTime()-lastDebuffMessage >= 8 and LCU.debugMode==true) then
		for k,debuff in pairs(LCU.debuffs[who]) do
			local debuffMsg = 'Debuff #'..tostring(k)..':'
			debuffMsg = debuffMsg .. GetSpellLink(debuff.id)
			debuffMsg = debuffMsg..' ['..debuff.id..'] '
			debuffMsg = debuffMsg..' ('..debuff.type..') '
			debuffMsg = debuffMsg..' '..tostring(debuff.remaining)..' secs remaining.'
			LCMessage(debuffMsg,'PRINT',LCU.round(debuff.remaining/2));
		end
		lastDebuffMessage = GetTime()
	end
end
