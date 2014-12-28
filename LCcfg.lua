LCcfgStore = type(LCcfgStore)=='table' and LCcfgStore or {};

LCcfg = {
	get = function(name,ifNil)
		LCcfg.checkPlayerRole();
		local ret = LCcfgStore[LCU.player.role] and LCcfgStore[LCU.player.role][name] or nil;
		if(ret==nil) then return ifNil;
		else return ret; end
	end
	,checkPlayerRole = function()
		if(LCU.player.role == LCLang.get('player')) then LCU.player.updateRole(); end
	end
	,set = function(name,val)
		LCcfg.checkPlayerRole();
		if(LCcfgStore[LCU.player.role]==nil) then LCcfgStore[LCU.player.role] = {}; end
		LCcfgStore[LCU.player.role][name] = val;
	end
	,setDefault = function(name,val)
		if(LCcfg.get(name)==nil) then LCcfg.set(name,val); end
	end
	,disableWatch = function(dbType,val)
		if(LCcfg.get('disabledWatches')==nil) then LCcfg.set('disabledWatches',{slow=true}); end
		LCcfgStore[LCU.player.role]['disabledWatches'][dbType] = val;
	end
	,watching = function(dbType)
		local disabledWatches = LCcfg.get('disabledWatches',{});
		return (disabledWatches[dbType]==nil or disabledWatches[dbType]==false);
	end
	,init = function()
		if(LCcfgStore.disabledWatches ~= nil) then
			local settings = LCU.cloneTable(LCcfgStore);
			LCcfgStore = {};
			LCcfgStore[LCU.player.role] = settings;
		end
		LCcfg.setDefault('instanceChat','PARTY');
		LCcfg.setDefault('raidChat','PARTY');
		LCcfg.setDefault('disabledWatches',{slow=true});
		LCcfg.setDefault('minDebuffTime',2);
	end
}
