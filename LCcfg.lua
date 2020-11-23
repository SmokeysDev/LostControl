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

local getDebuffTimeKey = function(dbType)
	local key = 'minDebuffTime';
	if (dbType == nil or dbType == '') then
		return key;
	end
	return key..'_'..LCU.str(dbType);
end

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
	,setMinDebuffTime = function(value, dbType)
		if (dbType == nil or dbType == '') then
			if (type(value)~='number') then
				value = defaultCfgs.minDebuffTime;
			end
			LCcfg.set(getDebuffTimeKey(), value);
		end
		if (string.lower(LCU.str(value)) == 'global') then
			value = nil;
		end
		dbType = LCU.str(dbType);
		LCcfg.set(getDebuffTimeKey(dbType), value);
	end
	,getMinDebuffTime = function(dbType, globalFallback)
		local globalCfg = LCcfg.get(getDebuffTimeKey(), 3);
		if (dbType == nil or dbType == '') then
			return globalCfg;
		end
		dbType = LCU.str(dbType);
		local typeCfg = LCcfg.get(getDebuffTimeKey(dbType), nil);
		if (typeCfg ~= nil or globalFallback == false) then
			return typeCfg;
		elseif (globalFallback ~= false) then
			return globalCfg;
		end
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
