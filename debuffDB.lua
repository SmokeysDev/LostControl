-- Adding descriptions:
-- --------------------
--	(best method if adding multiple)	Debuffs.addDescs([debuff type],{'[string to match]','[another string to match]',....})   -> e.g. Debuffs.addDescs('silence',{'cannot cast','holy locked'})
--	(best method if adding just one)	Debuffs.addDesc([debuff type],'[string to match]')   -> e.g. Debuffs.addDesc('slow','speed reduced')

-- Adding names:
-- --------------
--	(best method if adding multiple)	Debuffs.addNames([debuff type],{'[debuff name]','[debuff name]',....})   -> e.g. Debuffs.addNames('slow',{'Dazed','Hamstring','Ice Trap'})
--	(best method if adding just one)	Debuffs.addName([debuff type],'[debuff name]')   -> e.g. Debuffs.addName('stun','Stunned')

Debuffs.addDescs('incap',{
	'[uU]nable to move or act'
	,'[cC]annot move or act'
});

Debuffs.addDescs('slow',{
	'[rR]educes ?.* movement speed'
	,'[mM]ovement speed reduced'
});

Debuffs.addDesc('stun','teleported you out of the Silver Enclave');

Debuffs.addDescs('silence',{
	'prevent.* from casting spells'
});
