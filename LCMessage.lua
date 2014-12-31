--
-- The main function to use this script is at the bottom - LCMessage()
--
-- e.g.   LCMessage("your message","PARTY",5);
-- This will output "your message" to the /p channel, provided it hasn't been done already in the last 5 seconds
--


--
-- Initiate the cache variable
--
local LCMessageLog = {}

--
-- See if the given message exists in the cache
-- for the supplied channel type
-- (boolean)
--
local function messageExists(msg,chan)
	local foundMsg = false
	for c,ms in pairs(LCMessageLog) do
		if(c == chan) then
			for k,v in pairs(ms) do
				if(v.msg == msg) then foundMsg = true end
			end
		end
	end
	if(foundMsg==true) then return true end
	return false
end
--
-- Return the array of data for the given message
-- (table) if found, (nil) if not
--
local function getMessageData(msg,chan)
	for k,v in pairs(LCMessageLog[chan]) do
		if(v.msg == msg) then return v end
	end
	return nil
end

--
-- Ensure a key exists in the cache for the supplied channel
--
local function createChanTable(chan)
	local foundChan = false
	for c,ms in pairs(LCMessageLog) do
		if(c == chan) then
			foundChan = true
		end
	end
	if(foundChan==false) then LCMessageLog[chan] = {} end
end

local usableChans = {
	PARTY = 1
	,SAY = 1
	,INSTANCE_CHAT = 1
	,RAID = 1
};
--
-- Get the channel to use
--
local function getChanName(chan)
	chan = chan or 'nil';
	if(chan ~= 'nil' and usableChans[chan] == nil) then chan = 'nil'; end
	if(chan == 'nil') then
		if(IsInRaid()) then
			if(LCcfg.get('raidChat')=='SAY') then chan = 'SAY'; end
			if(LCcfg.get('raidChat')=='PARTY' and IsInGroup()) then chan = 'PARTY'; end
			if(LCcfg.get('raidChat')=='RAID') then chan = 'RAID'; end
		elseif(IsInGroup()) then
			if(LCcfg.get('instanceChat')=='SAY') then chan = 'SAY'; end
			if(LCcfg.get('instanceChat')=='PARTY' and IsInGroup()) then chan = 'PARTY'; end
			if(LCcfg.get('instanceChat')=='INSTANCE_CHAT') then chan = 'INSTANCE_CHAT'; end
		else
			if(LCcfg.get('instanceChat')=='SAY') then chan = 'SAY'; end
		end
		if(IsInGroup() and LCU.player.inInstance==nil) then chan = 'PARTY' end
	end
	return LCU.str(chan);
end

--
-- Output the message
-- then update cache
--
local function postMsg(msg,chan)
	chan = getChanName(chan);
	createChanTable(chan);
	if(chan=='nil') then print(msg)
	else SendChatMessage(msg,chan) end
	local msgFound = false
	for k,v in pairs(LCMessageLog[chan]) do
		if(v.msg == msg) then
			v.time = GetTime()
			msgFound = true
		end
	end
	if(msgFound == false) then
		LCMessageLog[chan][#LCMessageLog[chan]+1] = {['msg']=msg,['time']=GetTime()}
	end
end

--
-- Main function to be called externally
--
function LCMessage(msg,chan,minTimeBetweenCalls)
	minTimeBetweenCalls = minTimeBetweenCalls or 1.5
	chan = getChanName(chan);
	local alreadyPosted = messageExists(msg,chan)
	if(alreadyPosted==false) then
		postMsg(msg,chan)
	else
		local msgD = getMessageData(msg,chan)
		local tDiff = GetTime() - msgD.time;
		if(tDiff > minTimeBetweenCalls) then postMsg(msg,chan) end
	end
end