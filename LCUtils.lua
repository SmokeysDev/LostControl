LCU = {};
LCU.addonName = "LostControl"
LCU.addonVer = GetAddOnMetadata("LostControl","Version");
LCU.debugMode = false;
LCU.optionsPanel = nil;
LCU.player = {
	role = nil
	,spec = nil
	,hasControl = true
	,name = UnitName("player")
	,lastInterrupt = nil
	,updateRole = function(who)
		who = who or "player";
		local role = string.lower(UnitGroupRolesAssigned(who));
		if(role == "none" and who == "player") then
			local isLeader, isTank, isHealer, isDPS = GetLFGRoles();
			if(isTank==true) 	then role = LCLang.get('tank') end
			if(isHealer==true)  then role = LCLang.get('healer') end
			if(isDPS==true) 	then role = LCLang.get('dps') end
			if(role=="none") 	then role = LCLang.get('player') end
		end
		LCU.player.role = role;
		LCU.player.name = UnitName(who);
		return role;
	end
	,updateSpec = function()
		local currentSpec = GetSpecialization();
		local currentSpecName = nil;
		local currentSpecRole = nil;
		if(currentSpec ~= nil) then
			currentSpecName = select(2, GetSpecializationInfo(currentSpec));
			currentSpecRole = GetSpecializationRole(currentSpec);
			currentSpecRole = (currentSpecRole~=nil and currentSpecRole~=0) and string.lower(currentSpecRole) or nil;
			if(currentSpecRole=='damager') then currentSpecRole = 'dps'; end
		end
		LCU.player.spec = {
			index = LCU.tern(currentSpec~=nil, currentSpec, nil)
			,name = LCU.tern(currentSpecName~=nil, currentSpecName, nil)
			,role = LCU.tern(currentSpecRole~=nil, currentSpecRole, nil)
		};
		-- Looking out for old config structure
		if(LCcfgStore.disabledWatches ~= nil) then
			local settings = LCU.cloneTable(LCcfgStore);
			LCcfgStore = {};
			LCcfgStore['original'] = LCU.cloneTable(settings);
			LCcfgStore['original'].disabledWatches = {};
			for k,v in pairs(settings.disabledWatches) do
				LCcfgStore['original'].disabledWatches[k] = v;
			end
		end
		-- If we do have configs for 'unknown' but not for our current role - copy unknown to our role specific one
		if(type(LCcfgStore['original'])=='table' and LCU.player.spec.role and type(LCcfgStore[LCU.player.spec.role])~='table') then
			LCcfgStore[LCU.player.spec.role] = LCU.cloneTable(LCcfgStore['original']);
			LCcfgStore[LCU.player.spec.role].disabledWatches = {};
			for k,v in pairs(LCcfgStore['original'].disabledWatches) do
				LCcfgStore[LCU.player.spec.role].disabledWatches[k] = v;
			end
		end
		-- If we found valid spec info, ensure our configs have their defaults set
		if(LCU.player.spec and LCU.player.spec.role) then LCcfg.setDefaults(); end
	end
	,inInstance = nil
	,instanceType = 'none'
	,updateInstanceInfo = function()
		LCU.player.inInstance, LCU.player.instanceType = IsInInstance();
	end
}

LCU.round = function(val, decimal)
  local exp = decimal and 10^decimal or 1;
  return math.ceil(val * exp - 0.5) / exp;
end

LCU.upperFirst = function(str)
	return str:gsub("^%l", string.upper)
end

LCU.str = function(val)
	return tostring(val);
end

LCU.trim = function(s)
	return (LCU.str(s):gsub("^%s*(.-)%s*$", "%1"));
end

LCU.bool = function(val)
  return not not val;
end

LCU.deepcopy = function(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[orig_key] = LCU.deepcopy(orig_value)
        end
        setmetatable(copy, LCU.deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
LCU.cloneTable = function(tbl,deep)
	if(type(deep)~="boolean") then deep = true; end
	if(deep) then
		return LCU.deepcopy(tbl);
	else
		local cloned = {};
		i,v = next(tbl, nil);
		while i do
			cloned[i] = (type(v)=="table") and LCU.cloneTable(v) or v;
			i,v = next(tbl,i);
		end
		return cloned;
	end
end

LCU.tern = function(check,tru,fals)
	if(check) then return tru;
	else return fals; end
end

LCU.sendMsg = function(msg,priv)
	priv = priv or LCU.debugMode
	if(priv == true) then print(msg)
	else LCMessage(msg) end
end

LCU.announcePlayer = function(action)
	LCU.player.updateRole();
	local msgStart = LCU.player.role=='dps' and LCLang.get('A DPS') or LCLang.get('The '..LCU.player.role);
	local msg = msgStart..' ('..LCU.player.name..') '..action
	LCU.sendMsg(msg)
	return msg
end

LCU.foreach = function(tbl,func,useIpairs)
	if(useIpairs) then for k,v in ipairs(tbl) do func(v,k,tbl); end
	else for k,v in pairs(tbl) do func(v,k,tbl); end end
end

LCU.spellSchoolByNum = function(num)
	local spellSchools = {
		[1]		= "Physical",
		[2]		= "Holy",
		[4]		= "Fire",
		[8]		= "Nature",
		[16]	= "Frost",
		[32]	= "Shadow",
		[64]	= "Arcane",

		[3]		= "Holystrike",
		[5]		= "Flamestrike",
		[6]		= "Holyfire",
		[9]		= "Stormstrike",
		[10]	= "Holystorm",
		[12]	= "Firestorm",
		[17]	= "Froststrike",
		[18]	= "Holyfrost",
		[20]	= "Frostfire",
		[24]	= "Froststorm",
		[33]	= "Shadowstrike",
		[34]	= "Shadowlight",
		[36]	= "Shadowflame",
		[40]	= "Shadowstorm",
		[48]	= "Shadowfrost",
		[65]	= "Spellstrike",
		[66]	= "Divine",
		[68]	= "Spellfire",
		[72]	= "Spellstorm",
		[80]	= "Spellfrost",
		[96]	= "Spellshadow",

		[28]	= "Elemental",
		[124]	= "Chromatic",
		[126]	= "Magic",
		[127]	= "Chaos",
	};
	return spellSchools[num];
end

LCU.player.updateInstanceInfo();
LCU.player.updateRole();
LCU.player.updateSpec();

--------------------------------------
--- REGISTERING CHAT SLASH COMMANDS
--------------------------------------
SLASH_LostControl1 = "/lsctrl"
SLASH_LostControl2 = "/lostcontrol"

local SlashCmd = {}
function SlashCmd:help()
	print(LCU.addonName, "slash commands:")
	print('  -  disable [debuff type] (e.g. '..SLASH_LostControl1..' disable silence)')
	print('  -  enable [debuff type] (e.g. '..SLASH_LostControl1..' enable slow)')
	print('  -  status [debuff type] (e.g. '..SLASH_LostControl1..' status incap)')
end
function SlashCmd:debug(value)
	if value == "on" then
		LCU.debugMode = true
		print(LCU.addonName, LCLang.get("debugging enabled")..".")
	elseif value == "off" then
		LCU.debugMode = false
		print(LCU.addonName, LCLang.get("debugging disabled")..".")
	end
end
function SlashCmd:enable(value)
	if(Debuffs and Debuffs.types and Debuffs.types[value]) then
		local prevVal = Debuffs.types[value].enabled;
		Debuffs.types[value].enabled = true;
		LCcfg.disableWatch(value,false);
		if(Debuffs.types[value].enabled and not prevVal) then print('"'..LCU.upperFirst(value)..'" '..LCLang.get('checks have been enabled')); end
	end
end
function SlashCmd:disable(value)
	if(Debuffs and Debuffs.types and Debuffs.types[value]) then
		local prevVal = Debuffs.types[value].enabled;
		Debuffs.types[value].enabled = false;
		LCcfg.disableWatch(value,true);
		if(not Debuffs.types[value].enabled and prevVal) then print('"'..LCU.upperFirst(value)..'" '..LCLang.get('checks have been disabled')); end
	end
end
function SlashCmd:status(value)
	if(type(value)=="string") then
		if(Debuffs and Debuffs.types and Debuffs.types[value]) then
			print('"'..LCU.upperFirst(value)..'" checks are currently '..(Debuffs.types[value].enabled and LCLang.get('enabled') or LCLang.get('disabled')));
		end
	else
		print('--- --- --- --- --- --- --- --- --- --- --- --- --- --- ---');
		for k,v in pairs(Debuffs.types) do
			print('"'..LCU.upperFirst(k)..'" checks are currently '..(LCcfg.watching(k) and LCLang.get('enabled') or LCLang.get('- disabled -')));
		end
		print('--- --- --- --- --- --- --- --- --- --- --- --- --- --- ---');
	end
end
function SlashCmd:instchan(value)
	if(value=="SAY" or value=="PARTY" or value=="INSTANCE_CHAT") then
		LCcfg.set('instanceChat',value);
	end
	if(value=="s" or value=="S" or value=="say") then LCcfg.set('instanceChat','SAY'); end
	if(value=="p" or value=="P" or value=="party") then LCcfg.set('instanceChat','PARTY'); end
	if(value=="i" or value=="I" or value=="instance" or value=="INSTANCE") then LCcfg.set('instanceChat','INSTANCE_CHAT'); end
end
function SlashCmd:raidchan(value)
	if(value=="SAY" or value=="PARTY" or value=="RAID") then
		LCcfg.set('raidChat',value);
	end
	if(value=="s" or value=="S" or value=="say") then LCcfg.set('raidChat','SAY'); end
	if(value=="p" or value=="P" or value=="party") then LCcfg.set('raidChat','PARTY'); end
	if(value=="r" or value=="R" or value=="raid") then LCcfg.set('raidChat','RAID'); end
end

SlashCmdList[LCU.addonName] = function(cmd)
	local args = {}
	for word in cmd:lower():gmatch("%S+") do
		tinsert(args, word)
	end
	if SlashCmd[args[1]] then
		SlashCmd[args[1]](unpack(args))
	else
		print(LCU.addonName, ': Type "'..SLASH_LostControl1..' help" for more options.')
		InterfaceOptionsFrame_OpenToCategory(LCU.optionsPanel or LCU.addonName)
	end
end