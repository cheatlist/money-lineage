local module = {}

local Classes = {
	["Oni"] = {"Demon Step","Demon Flip","Rising Dragon","Axe Kick","Misogi","Leg Breaker","Spin Kick","TrainedCombat"};
	["Sigil Knight"] = {"Charged Blow","Ice Charge","Thunder Charge","Flame Charge","Action Surge","Pommel Strike"};
	["DragonSage"] = {"TrainedCombat","Lightning Elbow","Lightning Drop","Thundering Leap","ChiBlock","DragonDash","HolyFire","IronBody"};
	["Wraith Knight"] = {"WraithTraining","MasteredRune","ChargeMastery","Dark Flame Burst","Dark Eruption","Dark Sigil Helmet","Action Surge","Pommel Strike"};
	["Druid"] = {"Life Sense","Verdien","Floresco","Nature Mastery","ObserveBlock","Perflora",};
	["Samuri"] = {"Triple Slash","Blade Flash","Flowing Counter","BuyKatana","Sheathe Mastery","Calm Mind","Samurai",};
	["Shinobi"] = {"Bane","UpgradedAgility","Dagger Throw","Lethality","Triple Dagger Throw","Grapple","Owl Slash","Shadowrush","FeatherFall","ShadowrushAerial",};
	["Faceless"] = {"Bane","UpgradedAgility","Dagger Throw","Lethality","Triple Dagger Throw","UpgradedBane","Shadow Fan","Chain Lethality","Ethereal Strike","ShadowDash"};
	["Deep Knight"] = {"SpearDash","Triple Strike","Serpent Strike","Church Knight Helmet","Light Piercer","Impale","Deep Knight Helmet","Chain Pull","Deep Sacrifice","Leviathan Plunge",},
	["Whisper"] = {"Agility","Dagger Throw","Moneyguard","FeatherFall","Needle's Eye","Elegant Slash","Acrobat"},
	["Dragon Slayer"] = {"SpearDash","Triple Strike","Serpent Strike","Spear Crusher","Dragon Roar","Dragon Blood","Wing Soar","Thunder Spear Crash","Dragon Awakening","DragonBloodUpgrade"},
	["Wanderer"] = {"Flourish","Focus Slash","Lockout","Agility","Dagger Throw","Moneyguard","FeatherFall","Tight Pockets"}
}


function module.GetClassSkills(Class)
	
	if Classes[Class] then
		return Classes[Class]
	else
		return nil
	end
	
end

return module
