LCLang = {};
LCLang.data = {};
LCLang.currentLang = 0;
LCLang.languages = {
	en = 'English',
	es = 'Spanish',
	fr = 'French',
};
LCLang.loadLang = function(lang)
	LCLang['loadLang_'..lang]();
	LCLang.currentLang = lang;
	if(LCU and LCU.sendMsg) then LCU.sendMsg('LostControl: '..LCLang.get(LCLang.languages[lang]),true); end;
end
LCLang.get = function(key,lang)
	if(LCLang.currentLang==0) then LCLang.loadLang('en'); end
	if(lang ~= nil) then
		local cLang = LCLang.currentLang;
		LCLang.loadLang(lang);
		local ret = LCLang.data[key]~= nil and LCLang.data[key] or key;
		LCLang.loadLang(cLang);
		return ret;
	else
		return LCLang.data[key]~= nil and LCLang.data[key] or key;
	end
end
LCLang.dynaGet = function(key,lang)
	return function() return LCLang.get(key,lang); end;
end
local function defaultFunc(LCLang, key)
	return key;
end
setmetatable(LCLang, {__index=defaultFunc});