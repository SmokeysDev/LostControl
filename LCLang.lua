LCLang = {};
LCLang.currentLang = 'en';
LCLang.languages = {
	en = 'English',
	es = 'Spanish',
	fr = 'French',
};
LCLang.loadLang = function(lang)
	LCLang['loadLang_'..lang]();
	LCLang.currentLang = lang;
	LCU.sendMsg('LostControl: '..LCLang.get(LCLang.languages[lang]),true);
end
LCLang.get = function(key,lang)
	if(lang ~= nil) then
		local cLang = LCLang.currentLang;
		LCLang.loadLang(lang);
		local ret = LCLang[key];
		LCLang.loadLang(cLang);
		return ret;
	else
		return LCLang[key];
	end
end
LCLang.dynaGet = function(key,lang)
	return function() return LCLang.get(key,lang); end;
end
local function defaultFunc(LCLang, key)
	return key;
end
setmetatable(LCLang, {__index=defaultFunc});