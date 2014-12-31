LCcfgStore = type(LCcfgStore)=='table' and LCcfgStore or {};

LCcfg = {
	get = function(name,ifNil,allowBlankString)
		if(type(allowBlankString)~='boolean') then allowBlankString = true; end
		LCcfg.checkPlayerSpec();
		local role = LCcfg.getPlayerSpecRole();
		local ret = (type(LCcfgStore[role])=='table') and LCcfgStore[role][name] or nil;
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
		LCcfg.checkPlayerSpec();
		local role = LCcfg.getPlayerSpecRole();
		if(role ~= 'unknown') then
			if(LCcfgStore[role]==nil) then LCcfgStore[role] = {}; end
			LCcfgStore[role][name] = val;
		end
	end
	,setDefault = function(name,val)
		if(LCcfg.get(name)==nil) then LCcfg.set(name,val); end
	end
	,disableWatch = function(dbType,val)
		local role = LCcfg.getPlayerSpecRole();
		if(role ~= 'unknown') then
			if(LCcfgStore[role]['disabledWatches']==nil) then LCcfgStore[role]['disabledWatches'] = {slow=true}; end
			LCcfgStore[role]['disabledWatches'][dbType] = val;
		end
	end
	,watching = function(dbType)
		local role = LCcfg.getPlayerSpecRole();
		if(role == 'unknown') then role = 'original'; end
		if(LCcfgStore[role] == nil) then
			return true;
		else
			local disabledWatches = LCU.tern(type(LCcfgStore[role]['disabledWatches'])=='table', LCcfgStore[role]['disabledWatches'], {slow=true});
			return (disabledWatches[dbType]==nil or disabledWatches[dbType]==false);
		end
	end
	,setDefaults = function()
		LCcfg.setDefault('instanceChat','PARTY');
		LCcfg.setDefault('raidChat','PARTY');
		LCcfg.setDefault('disabledWatches',{slow=true});
		LCcfg.setDefault('minDebuffTime',3);
	end
	,init = function()
		LCcfg.setDefaults();
	end
}
