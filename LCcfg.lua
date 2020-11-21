LCcfgStore = type(LCcfgStore)=='table' and LCcfgStore or {};

local defaultDisabledWatches = {
	slow = true,
	falling = true
}

local defaultCfgs = {
	instanceChat = 'INSTANCE_CHAT',
	oomBreakpoint = 15,
	raidChat = 'RAID',
	minDebuffTime = 3
}

LCcfg = {
	get = function(name,ifNil,allowBlankString)
		if(type(allowBlankString)~='boolean') then allowBlankString = true; end
		local role = LCcfg.getPlayerSpecRole();
		local ret = (type(LCcfgStore[role])=='table') and LCcfgStore[role][name] or nil;
		if(ret==nil) then ret = defaultCfgs[name]; end
		if(ret==nil or (type(ret)=='string' and allowBlankString==false and LCU.trim(ret)=='')) then return ifNil;
		else return ret; end
	end
	,checkPlayerSpec = function()
		if(LCU.player.spec==nil or LCU.player.spec.name==nil or LCU.player.spec.role==nil) then LCU.player.updateSpec(); end
	end
	,getPlayerSpecName = function()
		LCcfg.checkPlayerSpec();
		return (LCU.player.spec and LCU.player.spec.name) and LCU.player.spec.name or 'unknown';
	end
	,getPlayerSpecRole = function()
		LCcfg.checkPlayerSpec();
		return (LCU.player.spec and LCU.player.spec.role) and LCU.player.spec.role or 'unknown';
	end
	,set = function(name,val)
		local role = LCcfg.getPlayerSpecRole();
		if(role ~= 'unknown') then
			if(LCcfgStore[role]==nil) then LCcfgStore[role] = {}; end
			LCcfgStore[role][name] = val;
		end
	end
	,setDefault = function(name,val)
		if(LCcfg.get(name)==nil) then LCcfg.set(name,val); end
	end
	,getDisabledWatches = function()
		local disabledWatches = LCcfg.get('disabledWatches');
		if(disabledWatches == nil) then
			disabledWatches = LCU.cloneTable(defaultDisabledWatches);
			LCcfg.set('disabledWatches', disabledWatches);
		end
		return disabledWatches;
	end
	,disableWatch = function(dbType,val)
		LCcfg.getDisabledWatches()[dbType] = LCU.tern(val == true, true, nil);
	end
	,watching = function(dbType)
		return LCcfg.getDisabledWatches()[dbType] ~= true;
	end
	,setDefaults = function()
	end
	,init = function()
		LCcfg.setDefaults();
	end
}
