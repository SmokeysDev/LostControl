LCcfgStore = type(LCcfgStore)=='table' and LCcfgStore or {};

LCcfg = {
	get = function(name,ifNil)
		
		local ret = LCcfgStore[name];
		if(ret==nil) then return ifNil;
		else return ret; end
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
	,init = function()
		LCcfg.setDefault('instanceChat','PARTY');
		LCcfg.setDefault('raidChat','PARTY');
		LCcfg.setDefault('disabledWatches',{slow=true});
		LCcfg.setDefault('minDebuffTime',2);
	end
}
LCcfg.init();