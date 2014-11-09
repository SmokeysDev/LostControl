LCLang.loadLang_es = function()
	LCLang.data['English'] = 'Inglés';
	LCLang.data['French'] = 'Francés';
	LCLang.data['Spanish'] = 'Español';
	LCLang.data['is no longer feared'] = 'ya no se teme';
	LCLang.data['is no longer charmed'] = 'ya no es hechizado';
	LCLang.data['is no longer incapacitated'] = 'ya no está incapacitado';
end

if GetLocale() == "esES" then LCLang.loadLang('es') end
