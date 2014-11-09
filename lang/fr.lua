LCLang.loadLang_fr = function()
	LCLang['English'] = 'Anglais';
	LCLang['French'] = 'Français';
	LCLang['Spanish'] = 'Espagnol';
	LCLang["is no longer feared"] = "ne craignait plus";
end

if GetLocale() == "frFR" then LCLang.loadLang('fr') end
