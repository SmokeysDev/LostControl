addonName = "LostControl"
LCDebugMode = false;
role = nil;
playerName = UnitName("player");

function updateRole()
	role = string.lower(UnitGroupRolesAssigned("player"));
	if(role == "none") then
		local isLeader, isTank, isHealer, isDPS = GetLFGRoles();
		if(isTank==true) 	then role = 'tank' end
		if(isHealer==true)  then role = 'healer' end
		if(isDPS==true) 	then role = 'dps' end
		if(role=="none") 	then role = 'player' end
	end
	return role
end

function round(val, decimal)
  local exp = decimal and 10^decimal or 1
  return math.ceil(val * exp - 0.5) / exp
end

function str(val)
	return tostring(val)
end

function toboolean( value )
  return not not value
end

function sendMsg(msg,priv)
	priv = priv or LCDebugMode
	local chan = IsInGroup() and 'PARTY' or (IsInRaid() and 'RAID' or 'SAY')
	if(priv == true) then print(msg)
	else LCMessage(msg,chan,2) end --SendChatMessage(msg,chan) end
end

function announceStateChange(action)
	updateRole();
	local msgStart = role=='dps' and 'A DPS' or 'The '..role
	local msg = msgStart..' ('..playerName..') has '..action
	sendMsg(msg)
	return msg
end


-------------------------------------------------------------------------------
SLASH_LostControl1 = "/lsctrl"
SLASH_LostControl2 = "/lostcontrol"

local SlashCmd = {}
function SlashCmd:help()
	print(addonName, "slash commands:")
	print("    debug (on/off)")
	--print("<unit> can be: player, pet, target, focus, party1 ... party4, arena1 ... arena5")
end
function SlashCmd:debug(value)
	if value == "on" then
		LCDebugMode = true
		print(addonName, "debugging enabled.")
	elseif value == "off" then
		LCDebugMode = false
		print(addonName, "debugging disabled.")
	end
end

SlashCmdList[addonName] = function(cmd)
	local args = {}
	for word in cmd:lower():gmatch("%S+") do
		tinsert(args, word)
	end
	if SlashCmd[args[1]] then
		SlashCmd[args[1]](unpack(args))
	else
		print(addonName, ": Type \"/lc help\" for more options.")
		InterfaceOptionsFrame_OpenToCategory(OptionsPanel)
	end
end