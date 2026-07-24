local classdata = {
	Warrior = {
		skills = {
			"Action Surge",
			"Pommel Strike",
		},
		price = 35,
	},
	LordsTraining = {
		skills = {
			"LordsTraining",
			"Counter",
			"Disarming Strike",
		},
		price = 100,
		requiredclass = "",
	},
	Bard = {
		skills = {
			"Vinifera's Song",
			"Symphony of Horses"
		},
		price = 50
	},
	PoisonMaster = {
		skills = {
			"PoisonMastery",
			"PoisonCrafting",
			"AdvancedPoisons",
			"PoisonImmunity"
		},
		price = 75
	},
	Alchemist = {
		skills = {
			"Herbivore",
			"Green Thumb",
			"Potion Efficiency",
			"Snake Blood"
		},
		price = 75
	},
	Blacksmith = {
		skills = {
			"DoubleOre",
			"IronWeapons",
			"DoubleBars",
			"MythrilWeapons"
		},
		price = 75
	},
	SuperBlacksmith = {
		skills = {
			"Remote Smithing",
		},
		price = 100,
		requiredclass = "",
		class = "SuperBlacksmith",
		ultra = "Lapidarist",
	},
	Chef = {
		skills = {
			"Tasty",
			"Savory",
			"Delicious",
			"Mouth-Watering"
		},
		price = 75
	},
	Spearfisher = {
		skills = {
			"Harpoon",
			"Skewer",
			"Hunter's Focus",
		},
		price = 100,
		requiredclass = "",
		class = "Spearfisher",
		ultra = "Atlas"
	};
	Candence = {
		skills = {
			"Joyous Dance",
			"Song of Lethargy",
			"Sweet Soothing",
		},
		price = 350,
		requiredclass = "",
		class = "Candence",
		isultra = true,
	},
	Greatsword = {
		skills = {
			"Shoulder Bash",
			--"Oust",
		},
		price = 95,
		class = "Greatsword",
		requiredclass = "",
	};
	Abysswalker = {
		skills = {
			"AbyssTraining",
			"Abysswalker",
		},
		price = 350,
		requiredclass = "Greatsword",
		class = "Abysswalker",
		isultra = true,
	};
	EnibrasTeaching = {
		skills = {
			"AbyssTraining",
			"Abysswalker",
			"Abyssal Scream",
			"Wrathful Leap",
		},
		price = 0,
		requiredclass = "Greatsword",
		class = "Abysswalker",
		isultra = true,
	};
	Samurai = {
		skills = {
			"Triple Slash",
			"Blade Flash",
			"Flowing Counter",
			"BuyKatana",
		},
		price = 125,
		requiredclass = "",
		class = "Samurai",
	},
	Ronin = {
		skills = {
			"Sheathe Mastery",
			"Calm Mind",
			"Swallow Reversal",
			"TripleSlashTraining",
			"Samurai",
		},
		price = 250,
		requiredclass = "Samurai",
		class = "Ronin",
		isultra = true,
	},
	Spear = {
		skills = {
			"SpearDash",
			"Triple Strike",
			"Serpent Strike",
		},
		price = 35,
	},
	DragonKnight = {
		skills = {
			"Spear Crusher",
			"Dragon Roar",
			"Dragon Blood",
		},
		price = 100,
		requiredclass = "",
		class = "DragonKnight",
		ultra = "DragonSlayer",
	},
	DragonSlayer = {
		skills = {
			"Wing Soar",
			"Thunder Spear Crash",
			"Dragon Awakening",
			"DragonBloodUpgrade"
		},
		price = 350,
		requiredclass = "DragonKnight",
		class = "DragonSlayer",
		isultra = true,
	},
	Illusionist = {
		skills = {
			"Mirror Image",
			"Mind Break",
			"Hystericus",
			"Observe",
			"MentalBlock",
			"Trickstus"
		},
		price = 150,
		requiredclass = "",
		class = "Illusionist",
		ultra = "MasterIllusionist",
	},
	MasterIllusionist = {
		skills = {
			"Reality Bubble",
			"Phantasmal Bolt",
			"ObserveBlock",
			"IllusionMastery",
			"Veil of Illusion"
		},
		price = 350,
		requiredclass = "Illusionist",
		class = "MasterIllusionist",
		isultra = true,
	},
	ChurchKnight = {
		skills = {
			"Church Knight Helmet",
			"Light Piercer",
			"Impale",
		},
		price = 150,
		requiredclass = "",
		class = "ChurchKnight",
		ultra = "DeepKnight",
	},
	DeepKnight = {
		skills = {
			"Deep Sacrifice",
			"Leviathan Plunge",
			"PrinceBlessing",
			"Chain Pull"
		},
		price = 350,
		requiredclass = "ChurchKnight",
		class = "DeepKnight",
		isultra = true,
	},
	SigilKnight = {
		skills = {
			"Ice Charge",
			"Thunder Charge",
			"Flame Charge",
		},
		price = 65,
		requiredclass = "Warrior",
		class = "SigilKnight",
		ultra = {"SigilKnightCommander","DarkSigilKnight"}
	},
	DarkSigilKnight = {
		skills = {
			"WraithTraining",
			"MasteredRune",
			"ChargeMastery",
			"Dark Flame Burst",
			"Dark Eruption",
			"Dark Sigil Helmet",
		},
		price = 350,
		requiredclass = "SigilKnight",
		class = "DarkSigilKnight",
		isultra = true,
		firstskill = "WraithTraining",
	},
	SigilKnightCommander = {
		skills = {
			"Charged Blow",
			"Hyper Body",
			"ChargeMastery",
		},
		price = 350,
		requiredclass = "SigilKnight",
		class = "SigilKnightCommander",
		isultra = true,
	},
	Monk = {
		skills = {
			"ChiBlock",
			"HolyFire",
			"IronBody",
			"TrainedCombat",
			"Monastic Stance",
		},
		price = 40,
		requiredclass = "",
		class = "Monk",
	},
	DragonSage = {
		skills = {
			"Lightning Elbow",
			"Lightning Drop",
			"DragonDash",
			"ElectricPunch",
			"Electric Smite"
		},
		price = 350,
		requiredclass = "Monk",
		class = "DragonSage",
		isultra = true,
	},
	Atlas = {
		skills = {
			"Ocean's Protection",
			"Tidal Trident",
			"Fisherman's Trap",
		},
		price = 350,
		requiredclass = "Spearfisher",
		class = "Atlas",
		isultra = true,
	};
	Templar = {
		skills = {
			"Titan Body",
			"Cleave",
			"Will O' Wisp",
			"Solan's Blessing",
		},
		price = 1000,
		requiredclass = "Templar",
		class = "Templar",
		isultra = true,
	},
	Vanguard = {
		skills = {
			"Brandish",
			"Blade Crash",
			"Puncture",
			"Azure Ignition",
			"VanguardT",
		},
		price = 350,
		requiredclass = "Greatsword",
		class = "Vanguard",
		isultra = true,
	},
	Wanderer = {
		skills = {
			"Lockout",
			"Focus Slash",
			"Flourish",
			"Tight Pockets"
		},
		price = 350,
		requiredclass = "Spy",
		class = "Wanderer",
		isultra = true,
	},
	Akuma = {
		skills = {
			"Rising Dragon",
			"Leg Breaker",
			"Spin Kick",
			"TrainedCombat",
		},
		price = 60,
		requiredclass = "",
		class = "Akuma",
		ultra = "Oni",
	},
	Oni = {
		skills = {
			"Demon Step",
			"Demon Flip",
			"Axe Kick",
			"Misogi",
		},
		price = 350,
		requiredclass = "Akuma",
		class = "Oni",
		isultra = true,
	},
	Scholar = {
		skills = {
			"WiseCasting",
			"FastCasting",
			"CurseShield",
		},
		price = 80,
	}, --[[ importing druid spear rn itll be at castle sanc]]--
	Botanist = {
		skills = {
			"Life Sense",
			"Barkskin",
			"Fons Vitae",
			"Floresco",
			"Regrowth"
		},
		price = 60,
		requiredclass = "",
		class = "Botanist",
		ultra = "Florist",
	},
	Florist = {
		skills = {
			"Floresco M2",
			"Nature Mastery",
			"ObserveBlock",
			"Fons Vitae M2",
			"Nature's Calling",
			"Thorn Barrage"
		},
		price = 350,
		requiredclass = "Botanist",
		class = "Florist",
		isultra = true,
	},
	Thief = {
		skills = {"Agility","Dagger Throw","Stealth","Lock Manipulation"},
		price = 45,
	},
	Spy = {
		skills = {
			"Moneyguard",
			"FeatherFall",
			"UpgradedAgility",
			"Interrogation",
		},
		price = 60,
		requiredclass = "",
		class = "Spy",
		ultra = "Whisper",
	},
	Whisper = {
		skills = {
			"Needle's Eye",
			"Elegant Slash",
			"Acrobat",
			"Interrogation",
		},
		price = 350,
		requiredclass = "Spy",
		class = "Whisper",
		isultra = true,
	},
	Assassin = {
		skills = {"Bane","UpgradedAgility","Dagger Throw","Lethality","Triple Dagger Throw"},
		price = 45,
		class = "Assassin",
		requiredclass = "",
		ultra = "Faceless",
	},
	Faceless = {
		skills = {
			"UpgradedBane",
			"Shadow Fan",
			"Chain Lethality",
			"Ethereal Strike",
			"ShadowDash"
		},
		price = 350,
		requiredclass = "Assassin",
		class = "Faceless",
		isultra = true,
	},
	Shinobi = {
		skills = {
			"Grapple",
			"Owl Slash",
			"Shadowrush",
			"FeatherFall",
			"ShadowrushAerial",
			"Resurrection",
		},
		price = 350,
		requiredclass = "Assassin",
		class = "Shinobi",
		isultra = true,
	},
	Homeless = {
		skills = {
			"HomelessQuest",
		},
		price = 2000,
		requiredclass = "SigilKnightCommander",
	},
	Necromancer = {
		skills = {
			"Shadow Impale",
			"Dark Meadow",
			"Learned Necromancy",
			"Inferi",
			"Reditus",
			"Vocare",
			"CurseAllow",
			"ShriekerHeal",
		},
		requiredclass = "",
		class = "Necromancer",
		price = 130,
	},
	["Master Necromancer"] = {
		skills = {
			"Necromancer's Grasp",
			"Death's Plague",
			"Demise Cut",
			"Secare",
			"ObserveBlock",
			"Furantur",

		},
		requiredclass = "Necromancer",
		class = "Master Necromancer",
		price = 350,
		isultra = true,
	},
	Lapidarist = {
		skills = {
			"Shardcaster",
			"Moneyguard",
			"Sapphire Shard",
		},
		price = 350,
		class = "Lapidarist",
		requiredclass = "SuperBlacksmith",
		isultra = true,
	},
};

local supers = {
	Samurai = true,
	Akuma = true,
	Monk = true,
	Botanist = true,
	SigilKnight = true,
	Spy = true,
	Assassin = true,
	Spearfisher = true,
	ChurchKnight = true,
	DragonKnight = true,
	Necromancer = true,
	Illusionist = true,
	SuperBlacksmith = true,
	Greatsword = true
}
local ultraclass3 = {
	"Faceless",
	"Oni",
	"Whisper",
	"Shinobi",
	"Candence",
	"DarkSigilKnight",
	"SigilKnightCommander",
	"Ronin",
	"DeepKnight",
	"Lapidarist",
	"AbyssWalker",
	"DragonSlayer",
	"Florist",
	"MasterIllusionist",
	"Master Necromancer",
	"DragonSage",
	"Abysswalker",
	"Wanderer",
	"Templar",
	"Vanguard",
	"Atlas"
}

return {
	classdata = classdata,
	supers = supers,
	ultraclass3 = ultraclass3,
}
