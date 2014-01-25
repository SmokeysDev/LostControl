LCcfgStore = type(LCcfgStore)=='table' and LCcfgStore or {};

LCcfg = {
	get = function(name)
		return LCcfgStore[name];
	end
	,set = function(name,val)
		LCcfgStore[name] = val;
	end
	,setDefault = function(name,val)
		if(LCcfgStore[name]==nil) then LCcfg.set(name,val); end
	end
	,disableWatch = function(dbType,val)
		LCcfgStore.disabledWatches[dbType] = val;
	end
	,watching = function(dbType)
		return (LCcfgStore.disabledWatches[dbType]==nil or LCcfgStore.disabledWatches[dbType]==false);
	end
}

LCcfg.setDefault('instanceChat','PARTY');
LCcfg.setDefault('raidChat','PARTY');
LCcfg.setDefault('disabledWatches',{slow=true});
