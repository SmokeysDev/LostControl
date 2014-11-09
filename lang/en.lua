LCLang.loadLang_en = function()
	LCLang['English'] = 'English';
	LCLang['French'] = 'French';
	LCLang['Spanish'] = 'Spanish';
	LCLang['is no longer feared'] = 'is no longer feared';
end

if (GetLocale() == "enUS" and GetLocale() == "enGB") then LCLang.loadLang('en') end
