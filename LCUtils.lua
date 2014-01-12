LCU = {};
LCU.addonName = "LostControl"
LCU.addonVer = GetAddonMetadata("LostControl","Version");
LCU.debugMode = false;
LCU.player = {
	role = nil
	,name = UnitName("player")
	,updateRole = function()
		local role = string.lower(UnitGroupRolesAssigned("player"));
		if(role == "none") then
			local isLeader, isTank, isHealer, isDPS = GetLFGRoles();
			if(isTank==true) 	then role = 'tank' end
			if(isHealer==true)  then role = 'healer' end
			if(isDPS==true) 	then role = 'dps' end
			if(role=="none") 	then role = 'player' end
		end
		LCU.player.role = role;
		return role;
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
	print("    debug (on/off)")
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

SlashCmdList[LCU.addonName] = function(cmd)
	local args = {}
	for word in cmd:lower():gmatch("%S+") do
		tinsert(args, word)
	end
	if SlashCmd[args[1]] then
		SlashCmd[args[1]](unpack(args))
	else
		print(LCU.addonName, ": Type \"/lc help\" for more options.")
		InterfaceOptionsFrame_OpenToCategory(OptionsPanel)
	end
end