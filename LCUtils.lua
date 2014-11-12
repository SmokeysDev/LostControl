LCU = {};
LCU.addonName = "LostControl"
LCU.addonVer = GetAddOnMetadata("LostControl","Version");
LCU.debugMode = false;
LCU.player = {
	role = nil
	,name = UnitName("player")
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
	,inInstance = nil
	,instanceType = 'none'
	,updateInstanceInfo = function()
		LCU.player.inInstance, LCU.player.instanceType = IsInInstance();
	end
}
LCU.player.updateInstanceInfo();
LCU.player.updateRole();
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

LCU.bool = function(val)
  return not not val;
end

LCU.sendMsg = function(msg,priv)
	priv = priv or LCU.debugMode
	if(priv == true) then print(msg)
	else LCMessage(msg) end
end

LCU.announceStateChange = function(action)
	LCU.player.updateRole();
	local msgStart = LCU.player.role=='dps' and LCLang.get('A DPS') or LCLang.get('The '..LCU.player.role);
	local msg = msgStart..' ('..LCU.player.name..') has '..action
	LCU.sendMsg(msg)
	return msg
end

LCU.announcePlayer = function(action)
	LCU.player.updateRole();
	local msgStart = LCU.player.role=='dps' and LCLang.get('A DPS') or LCLang.get('The '..LCU.player.role);
	local msg = msgStart..' ('..LCU.player.name..') '..action
	LCU.sendMsg(msg)
	return msg
end

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