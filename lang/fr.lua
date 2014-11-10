LCLang.loadLang_fr = function()
	LCLang.data['English'] = 'Anglais';
	LCLang.data['French'] = 'Français';
	LCLang.data['Spanish'] = 'Espagnol';
	LCLang.data['is no longer feared'] = "ne craignait plus";
	LCLang.data['is no longer charmed'] = "ne est plus envoûté";
	LCLang.data['is no longer incapacitated'] = "ne est plus frappé d'incapacité";
end

if GetLocale() == "frFR" then LCLang.loadLang('fr') end
