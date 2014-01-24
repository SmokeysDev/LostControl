LCcfg = type(LCcfg)=='table' and LCcfg or {};
if(LCcfg.instanceChat==nil) then LCcfg.instanceChat = 'PARTY'; end
if(LCcfg.raidChat==nil) then LCcfg.raidChat = 'PARTY'; end
if(LCcfg.disabledWatches==nil) then LCcfg.disabledWatches = {slow=true}; end
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
			if(isTank==true) 	then role = 'tank' end
			if(isHealer==true)  then role = 'healer' end
			if(isDPS==true) 	then role = 'dps' end
			if(role=="none") 	then role = 'player' end
		end
		LCU.player.role = role;
		LCU.player.name = UnitName(who);
		return role;
	end
}
LCU.player.inInstance, LCU.player.instanceType = IsInInstance();
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
	local chan = IsInGroup() and 'PARTY' or (IsInRaid() and 'RAID' or 'SAY')
	if(priv == true) then print(msg)
	else LCMessage(msg,chan,2) end
end

LCU.announceStateChange = function(action)
	LCU.player.updateRole();
	local msgStart = LCU.player.role=='dps' and 'A DPS' or 'The '..LCU.player.role
	local msg = msgStart..' ('..LCU.player.name..') has '..action
	LCU.sendMsg(msg)
	return msg
end

LCU.announcePlayer = function(action)
	LCU.player.updateRole();
	local msgStart = LCU.player.role=='dps' and 'A DPS' or 'The '..LCU.player.role
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
	print('  -  debug [on/off]')
	print('  -  disable [debuff type] (e.g. '..SLASH_LostControl1..' disable silence)')
	print('  -  enable [debuff type] (e.g. '..SLASH_LostControl1..' enable slow)')
	print('  -  status [debuff type] (e.g. '..SLASH_LostControl1..' status incap)')
	--print("<unit> can be: player, pet, target, focus, party1 ... party4, arena1 ... arena5")
end
function SlashCmd:debug(value)
	if value == "on" then
		LCU.debugMode = true
		print(LCU.addonName, "debugging enabled.")
	elseif value == "off" then
		LCU.debugMode = false
		print(LCU.addonName, "debugging disabled.")
	end
end
function SlashCmd:enable(value)
	if(Debuffs and Debuffs.types and Debuffs.types[value]) then
		local prevVal = Debuffs.types[value].enabled;
		Debuffs.types[value].enabled = true;
		LCcfg.disabledWatches[value] = false;
		if(Debuffs.types[value].enabled and not prevVal) then print('"'..LCU.upperFirst(value)..'" checks have been enabled'); end
	end
end
function SlashCmd:disable(value)
	if(Debuffs and Debuffs.types and Debuffs.types[value]) then
		local prevVal = Debuffs.types[value].enabled;
		Debuffs.types[value].enabled = false;
		LCcfg.disabledWatches[value] = true;
		if(not Debuffs.types[value].enabled and prevVal) then print('"'..LCU.upperFirst(value)..'" checks have been disabled'); end
	end
end
function SlashCmd:status(value)
	if(type(value)=="string") then
		if(Debuffs and Debuffs.types and Debuffs.types[value]) then
			print('"'..LCU.upperFirst(value)..'" checks are currently '..(Debuffs.types[value].enabled and 'enabled' or 'disabled'));
		end
	else
		for k,v in pairs(Debuffs.types) do
			print('"'..LCU.upperFirst(k)..'" checks are currently '..(v.enabled and 'enabled' or '- disabled -'));
		end
	end
end
function SlashCmd:instchan(value)
	if(value=="PARTY" or value=="INSTANCE_CHAT") then
		LCcfg.instanceChat = value;
	end
	if(value=="p" or value=="P" or value=="party") then LCcfg.instanceChat = 'PARTY'; end
	if(value=="i" or value=="I" or value=="instance" or value=="INSTANCE") then LCcfg.instanceChat = 'INSTANCE_CHAT'; end
end
function SlashCmd:raidchan(value)
	if(value=="PARTY" or value=="RAID") then
		LCcfg.instanceChat = value;
	end
	if(value=="p" or value=="P" or value=="party") then LCcfg.instanceChat = 'PARTY'; end
	if(value=="r" or value=="R" or value=="raid") then LCcfg.instanceChat = 'RAID'; end
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
	end
end