LCLang.loadLang_es = function()
	LCLang['English'] = 'Inglés';
	LCLang['French'] = 'Francés';
	LCLang['Spanish'] = 'Español';
	LCLang['is no longer feared'] = 'ya no se teme';
end

if GetLocale() == "esES" then LCLang.loadLang('es') end
