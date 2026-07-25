local commands = require(game.ServerScriptService.Modules.Commands)
local requests = game.ServerStorage:WaitForChild("Requests")
local respawn = requests:WaitForChild("Respawn")
local playerdata = game.ServerStorage.PlayerData
local marketplaceservice = game:GetService("MarketplaceService")
local randomize_ = require(game.ServerScriptService.WorldHandler.GameLoaded.Randomize)
local random_name1,random_name2,random_name3

local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local rolling = {
	["Scroll of Ignis"] = 500,
	["Scroll of Celeritas"] = 500,
	["Scroll of Sagitta Sol"] = 500,
	["Scroll of Tenebris"] = 500,
	["Scroll of Viribus"] = 500,
	["Scroll of Telorum"] = 500,
	["Scroll of Nocere"] = 500,
	["Ice Essence"] = 350,

	["Scroll of Manus Dei"] = 150,
	["Scroll of Fimbulvetr"] = 150,
	["Scroll of Snarvindur"] = 75,
	["Scroll of Percutiens"] = 50,
}
local rollingtal = {
	["Scroll of Ignis"] = 500,
	["Scroll of Celeritas"] = 500,
	["Scroll of Sagitta Sol"] = 500,
	["Scroll of Tenebris"] = 500,
	["Scroll of Viribus"] = 500,
	["Scroll of Telorum"] = 500,
	["Scroll of Nocere"] = 500,
}
local magerolling = {
	["Scroll of Ignis"] = 400,
	["Scroll of Celeritas"] = 400,
	["Scroll of Sagitta Sol"] = 400,
	["Scroll of Tenebris"] = 400,
	["Scroll of Viribus"] = 400,
	["Scroll of Telorum"] = 400,
	["Scroll of Nocere"] = 400,
	["Ice Essence"] = 350,

	["Scroll of Manus Dei"] = 650,
	["Scroll of Fimbulvetr"] = 650,
	["Scroll of Hoppa"] = 550,
	["Scroll of Contrarium"] = 550,
	["Scroll of Snarvindur"] = 575,
	["Scroll of Percutiens"] = 600,
}
local gemrolling = {
	["Sulfurite"] = 1,
	["Bloodprism"] = 1,
	["Deathstone"] = 1,
	["Essence Gem"] = 1,
}
local function create(name,deletetime,parent)
	if not parent then
		return
	end
	local i = Instance.new("Accessory")
	i.Name = name
	i.Parent = parent
	game.Debris:AddItem(i,deletetime)
	return i
end
local ClassData = require(game.ServerScriptService.WorldHandler.ClassData)
local classdata = ClassData.classdata
local supers = ClassData.supers
local ultraclass3 = ClassData.ultraclass3
local function teachskill(p,info,firstcheck)
	local data = game.ServerStorage.PlayerData[p.Name]
	local hybridcheck = false
	local prioritize = 1
	if info.isultra then
		prioritize = 3
	end
	if (not info.isultra) and supers[info.class] then
		prioritize = 2
	end

	local selfproir = 1
	if table.find(ultraclass3, data.Class.Value) then
		selfproir = 3
	end
	if supers[data.Class.Value] then
		selfproir = 2
	end


	if prioritize == 3 then
		if ((info.requiredclass ~= "" and data.Class.Value ~= info.requiredclass) or data.Hybrid.Value ~= "") and data.Class.Value ~= info.class then
			return "no"
		end
	end
	if prioritize == 2 and selfproir == 2 then
		if (data.Hybrid.Value ~= "" and data.Hybrid.Value ~= info.class) and data.Class.Value ~= info.class then
			return "no"
		end
	end
	if prioritize == 2 and selfproir ~= 2 and selfproir ~= 3 then
		if table.find(ultraclass3, data.Class.Value) or (supers[data.Class.Value] and data.Class.Value ~= info.class) or (supers[data.Hybrid.Value] and data.Hybrid.Value ~= info.class) then
			return "no"
		end
	end
	if prioritize == 2 and selfproir == 3 then
		local superofult = classdata[data.Class.Value] and classdata[data.Class.Value].requiredclass
		if info.class ~= superofult or (not superofult) or data.Hybrid.Value ~= "" then
			return "no"
		end
	end
	local chosenskill = info.skills[math.random(1,#info.skills)]

	local skills = string.split(data.Skills.Value,",")
	local ownedskills = 0
	for i = 1,#info.skills do
		if table.find(skills,info.skills[i])then
			ownedskills+=1
		end
	end
	if ownedskills < #info.skills then
		if firstcheck then
			return"notmax"
		end
		if commands.ChangeMoney(p,data,-info.price)then
			if table.find(skills,chosenskill)then
				repeat
					chosenskill = info.skills[math.random(1,#info.skills)]
				until not(table.find(skills,chosenskill))
			end
			if info.class then
				if prioritize > selfproir then
					data.Class.Value = info.class
				elseif prioritize == selfproir and selfproir == 2 and info.class ~= data.Class.Value then
					if data.Hybrid.Value == "" then
						data.Hybrid.Value = info.class
					end
				end
				if info.isultra then
					data.IsUltra.Value = true
				end
			end
			table.insert(skills,chosenskill)
			data.Skills.Value = table.concat(skills,",")
			commands.Learn(p)
			if info.ultra and not info.isultra then
				game:GetService("BadgeService"):AwardBadge(p.UserId, 2127508833)
			end
			if info.isultra then
				game:GetService("BadgeService"):AwardBadge(p.UserId, 2127508836)
			end
			return"gotskill"
		else
			return"poor"
		end
	elseif ownedskills == #info.skills then
		return"max"
	end
	return"poor"
end
local dialogues = {
	Snowman = {
		p1 = {
			speaker = "???";
			msg = "Present to him this {letter}, do not lose it no matter what.";
			endchoice = "Bye";
		};
		p2 = {
			speaker = "???";
			msg = "...";
			endchoice = "Bye";
		};
		wrong_npc = {
			speaker = "???";
			msg = "*{WON DEMOOD LLA ER'EW}*";
			endchoice = "Bye";
		};
	};
	Adralik = {
		p1 = {
			speaker = "Adralik";
			msg = "Now... What can I do to get out of here?";
			choices = {"You're Adralik?"};
			endchoice = "...";	
		};
		p2 = {
			speaker = "Adralik";
			msg = "That's right, what might you need?";
			choices = {"I've been told to seek you out"};
			endchoice = "...";	
		};
		p3 = {
			speaker = "Adralik";
			msg = "Oh... I am guessing As'endo is the one that has sent you.";
			choices = {"That's correct"};
			endchoice = "...";	
		};
		p4 = {
			speaker = "Adralik";
			msg = "Would that mean that you also know what these obelisks are for? Surely, you've seen some standing around during your adventure.";
			choices = {"Uh... No"};
			endchoice = "...";	
		};
		p5 = {
			speaker = "Adralik";
			msg = "Well, they're all a part of a giant obelisk network, which has been disabled for the longest of times.";
			choices = {"It's my job to enable it?"};
			endchoice = "...";	
		};
		p6 = {
			speaker = "Adralik";
			msg = "Bingo! If you can power-up the network you can bring forth power beyond your wildest comprehension. Are you up to the task? _(Accepting the quest will disable the Gate spell until completed)_";
			choices = {"Alright"};
			endchoice = "I'll think about it";	
		};
		p7 = {
			speaker = "Adralik";
			msg = "Splendid! I might finally be able to get out of here! I've linked you to the obelisk network, now, listen very carefully.";
			choices = {"..."};
		};
		p8 = {
			speaker = "Adralik";
			msg = "Your objective now is to connect the entire obelisk network together, if your soul cracks, you have to return and start all over due to the connection being faint. Good luck.";
			endchoice = "I will do it";
		};
		returnnofinished = {
			speaker = "Adralik";
			msg = "Oh... You're back. The network isn't completed still, so, get to work.";
			endchoice = "...";
		};
		returnfinished = {
			speaker = "Adralik";
			msg = "Welcome back! The network is now accessible, but, the output isn't at the level that I had expected... To fix this I will need a _Rift Gem_, it will be the catalyst, and will power the obelisk network.";
			choices = {"Here you go"};
			endchoice = "...";
		};
		returnriftgem = {
			speaker = "Adralik";
			msg = "... You're back. I'm hoping you've found the _Rift Gem_.";
			choices = {"Here you go"};
			endchoice = "...";
		};
		noriftgem = {
			speaker = "Adralik";
			msg = "... What a joke, friend.";
			endchoice = "...";
		};
		riftgem = {
			speaker = "Adralik";
			msg = "AMAZING WORK!!! I may finally have a chance at getting out of here after all!";
			choices = {"My Ascension?"};
		};
		riftgem2 = {
			speaker = "Adralik";
			msg = "Oh yeah, about that... I have no idea what you've been talking about buddy, you should go back to _As'endo_ for that, Kind Sir.";
			endchoice = "A waste of time..."
		};
		notquest = {
			speaker = "Adralik";
			msg = "Now that the network is back up and running again, I might have a chance to get out of this backwater plane.";
			endchoice = "Bye";	
		};
	};
	BMObelisk = {
		bmquest = {
			speaker = "???";
			msg = "The Obelisk radiates a great power.";
			choices = {"Offer yourself"};
			endchoice = "..."
		};
		offerdone = {
			speaker = "???";
			msg = "With this being the end. You offer yourself.";
			endchoice = "..."
		};
		notquest = {
			speaker = "???";
			msg = "The Obelisk radiates a great power.";
			endchoice = "..."
		}
	};
	ObeliskBlade1 = {};
	ObeliskBlade2 = {};
	ObeliskBlade3 = {};
	ObeliskBlade4 = {};
	Oliver = {
		combat = {
			speaker = "Oliver";
			msg = "Come back when you're not in danger.";
			endchoice = "Bye";
		};
		alreadyrerolled = {
			speaker = "Oliver";
			msg = "Sadly, I can only perform this magic on you once per lineage.";
			endchoice = "Bye";
		};
		p1 = {
			speaker = "Oliver";
			msg = "So, you've come to me to redecide yourself? What do you desire?";
			choices = {"Rare", "Uncommon", "Common"};
			endchoice = "Bye";
		};
		rare = {
			speaker = "Oliver";
			msg = "...";
			choices = {"Dzin","Vind","Fischeran","Dinakeri","Morvid","LesserNavaran","Azael","Metascroom","Dullahan"};
			endchoice = "Bye";
		};
		uncommon = {
			speaker = "Oliver";
			msg = "...";
			choices = {"Madrasian","Gaian","Scroom","Kasparan","Construct"};
			endchoice = "Bye";
		};
		common = {
			speaker = "Oliver";
			msg = "...";
			choices = {"Castellan","Ashiin","Rigan","Haselda"};
			endchoice = "Bye";
		};
		bye = {
			speaker = "Oliver";
			msg = "Very well...";
			endchoice = "Bye";
		};
	};
	Isaiah = {
		normal1 = {
			speaker = "Isaiah";
			msg = "Welcome, what may I do for you?";
			choices = {"I've heard you're able to reset my artifact.", "I've heard you're able to reset my subclass."};
			endchoice = "Bye";
		};
		noartifact = {
			speaker = "Isaiah";
			msg = "I can't do that for you, I'm afraid.";
			endchoice = "Bye";
		};
		canreset = {
			speaker = "Isaiah";
			msg = "Of course...";
			choices = {"Reset Artifact"};
			endchoice = "Bye";
		};
		canresetsub = {
			speaker = "Isaiah";
			msg = "Of course...";
			choices = {"Reset Subclass"};
			endchoice = "Bye";
		};
		reset = {
			speaker = "Isaiah";
			msg = "Come again anytime.";
			endchoice = "Bye";
		};
	};
	Ethel = {

	};
	SpellChange = {

	};
	Dorgza = {

	};
	Dorgan = {
		p1 = {
			speaker = "Dorgan";
			msg = "Want some meat? (4 Money)";
			choices = {"Alright.","3 Meat.", "50 MEATS!!!"};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Dorgan";
			msg = "Enjoy Dorgan's meat!";
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Dorgan";
			msg = "You poor, Dorgon no sell meat to poor man.";
			endchoice = "Bye";
		};
	};
	Dorgoth = {
		p1 = {
			speaker = "Dorgoth";
			msg = "Would you like to buy a turnip? (4 Money)";
			choices = {"Alright.","3 Turnips."};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Dorgoth";
			msg = "Enjoy Dorgoth's turnips!";
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Dorgoth";
			msg = "You poor, Dorgoth no sell turnip to poor man.";
			endchoice = "Bye";
		};
	};
	Yeti = {
		take = {
			speaker = "Yeti";
			msg = "Oh, hello! I don't want my baby playing with this, can you take it away?";
			choices = {"Sure."};
			endchoice = "Bye"
		};
		thanks = {
			speaker = "Yeti";
			msg = "Thank you. I have a lot of these, so come back if you want more.";
			endchoice = "Bye"
		};
		alreadyhas = {
			speaker = "Yeti";
			msg = "I've heard that these feathers belong to some kind of %Eagle%. Strange, isn't it?";
			endchoice = "Bye"
		};
	};
	Owl = {
		p1 = {
			speaker = "Owl";
			msg = "Sharp Eyes, you lack resolve, though.";
			choices = {"Here is 350 Money."};
			endchoice = "Bye";
		};
		gotskill = {
			speaker = "Owl";
			msg = "Walk with the shadows...";
			endchoice = "Bye";
		};
		max = {
			speaker = "Owl";
			msg = "Strike from above so that your prey may never see you coming.";
			endchoice = "Bye";
		};
		poor = {
			speaker = "Owl";
			msg = "You can't afford this.";
			endchoice = "Bye";
		};
	};
	Tai = {
		p1 = {
			speaker = "Tai";
			msg = "I guess I could help you... Assuming you give me that %letter%...";
			choices = {"Alright."};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Tai";
			msg = "This lesson isn't free. If you really want to learn bring me an *{extraordinary pink gem.}*";
			choices = {"Sure."};
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Tai";
			msg = "{...Do you think this is a joke? This is not what I asked for.}";
			endchoice = "Bye";
		};
		gotskill = {
			speaker = "Tai";
			msg = "{...}";
			endchoice = "Bye";
		};
		waste = {
			speaker = "Tai";
			msg = "Don't you ever waste my time again, you *{layabout.}*";
			endchoice = "Bye";
		};
		no_note = {
			speaker = "Tai";
			msg = "Nothing you have is of any interest to me, get out my sight. *{FOOL.}*";
			endchoice = "Bye";
		};
	};
	TalNew = {
		p1 = {
			speaker = "Tal";
			msg = "Hey! Would you like some _magic_?";
			choices = {"Weren't you in those ruins?"};
			endchoice = "Leave me alone, please";
		};
		p2 = {
			speaker = "Tal";
			msg = "Don't know what you're talking about, friend. So, would you like a scroll?";
			choices = {"Sure (20 Money)"};
			endchoice = "I'm good";
		};
		p3 = {
			speaker = "Tal";
			msg = "Here you go!";
			endchoice = "Bye";
		};
		poor = {
			speaker = "Tal";
			msg = "I don't envy your situation, friend.";
			endchoice = "...";
		};
		
	};
	Tal = {
		p1 = {
			speaker = "???";
			msg = "_A young man sits before you_";
			choices = {"Hey."};
			endchoice = "...";
		};
		p2 = {
			speaker = "Tal";
			msg = "Oh, hello! I've been expecting you here!";
			choices = {"I'm sorry?"};
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Tal";
			msg = "You really shouldn't be! I am clairvoyant they say!";
			choices = {"..."};
			endchoice = "Bye";
		};
		p4 = {
			speaker = "Tal";
			msg = "After I've seen these ghosts, I've not been the same! If your interest has peaked: from what I remember, the first one I've seen was in the Cliffside Cavern.";
			endchoice = "Very well";
		};
		Cameback = {
			speaker = "Tal";
			msg = "You come back, but with nothing to bring?";
			endchoice = "...";
		};
		DifferentFace = {
			speaker = "Tal";
			msg = "Ohoh, your face, it already looks of one who has seen!";
			endchoice = "...";
		};
		SeerUser = {
			speaker = "???";
			msg = "_A young man sits before you, yet you somehow feel the need to not approach him_";
			endchoice = "...";
		};
	};
	Ghost = {
		p1 = {
			speaker = "???";
			msg = "Oh... Who might you be?";
			choices = {"I am seeking Clairvoyance"};
			endchoice = "..."
		};
		p2 = {
			speaker = "???";
			msg = "Clairvoyance comes at a price... Perhaps my brethren in the Sanctuary within the Deepforest may be of more help...";
			endchoice = "..."
		};
		notquest = {
			speaker = "???";
			msg = "_You have a feeling it would be unwise to engage in a conversation with the ghoul_";
			endchoice = "..."
		};
		forgot = {
			speaker = "???";
			msg = "Hm? You're back? I am glad to see you once again, but I can see that you've forgotten. My brethren in the Sanctuary within the Deepforest, may be of some use for your quest...";
			endchoice = "..."	
		};
		past = {
			speaker = "???";
			msg = "_The ghost that has once aided you seems to not be one for conversation_";
			endchoice = "...";
		};
	};
	Ghost2 = {
		p1 = {
			speaker = "???";
			msg = "_A mysterious ghost appears before you_";
			choices = {"What's the price of Clairvoyance?"};
			endchoice = "..."
		};
		p2 = {
			speaker = "???";
			msg = "Our fellow seers have paid dearly for the ability of foresight. Wondering once, a brother had ventured to the tundra to find a deeper meaning for our power...";
			endchoice = "..."
		};
		notquest = {
			speaker = "???";
			msg = "_A mysterious ghost appears before you_";
			endchoice = "..."
		};
		forgot = {
			speaker = "???";
			msg = "I can see that your _third_ eye has not awoken yet. Seek out our brother within the tundra.";
			endchoice = "..."	
		};
		past = {
			speaker = "???";
			msg = "_The ghost that has once aided you seems to not be one for conversation_";
			endchoice = "...";
		}
	};
	Ghost3 = {
		p1 = {
			speaker = "???";
			msg = "You are what I saw when I came here.";
			choices = {"You knew about me?"};
			endchoice = "..."
		};
		p2 = {
			speaker = "???";
			msg = "That's right, I've watched you on your quest, and have been expecting you to come here for the longest. We were two brothers adventuring together, however, he had seen what I couldn't.";
			choices = {"Where is this brother?"};
			endchoice = "..."
		};
		p3 = {
			speaker = "???";
			msg = "That, I do not know, however, finding him might be exactly what you need to find the truth within.";
			endchoice = "Thank you"
		};
		notquest = {
			speaker = "???";
			msg = "_Ominously sitting by the campfire, you feel the need to not conversate with the ghostly being_";
			endchoice = "..."
		};
		forgot = {
			speaker = "???";
			msg = "Seek out the Brother.";
			endchoice = "..."	
		};
		past = {
			speaker = "???";
			msg = "_The ghost that has once aided you seems to not be one for conversation_";
			endchoice = "...";
		};
	};
	Ghost4 = {
		p1 = {
			speaker = "???";
			msg = "...";
			choices = {"Could you be the one with the third eye?"};
			endchoice = "..."
		};
		p2 = {
			speaker = "???";
			msg = "You must find the _Oracle_, for I have seen it, and the location of which could be found through the decrepit contraption.";
			endchoice = "Very well"
		};
		notquest = {
			speaker = "???";
			msg = "_You feel as if you had seen what you shouldn't have_";
			endchoice = "..."
		};
		forgot = {
			speaker = "???";
			msg = "The _Oracle_ must be found. The decrepit contraption may give you the answer that you seek.";
			endchoice = "..."	
		};
	};
	SeerPuzzle = {
		notquest = {
			speaker = "Mysterious Contraption";
			msg = "_You feel it is un-wise to mess with the Mysterious Contraption_";
			endchoice = "..."
		};
		moved = {
			speaker = "Mysterious Contraption";
			msg = "_The contraption stirs_";
			endchoice = "..."
		};
	};
	SeerPuzzle1 = {
		move = {
			speaker = "Mysterious Contraption";
			msg = "_Would you like to move the Outer Circle?_";
			choices = {"Move it"};
			endchoice = "Nevermind"
		};
	};
	SeerPuzzle2 = {
		move = {
			speaker = "Mysterious Contraption";
			msg = "_Would you like to move the Middle Circle?_";
			choices = {"Move it"};
			endchoice = "Nevermind"
		};
	};
	SeerPuzzle3 = {
		move = {
			speaker = "Mysterious Contraption";
			msg = "_Would you like to move the Inner Circle?_";
			choices = {"Move it"};
			endchoice = "Nevermind"
		};
	};
	GateMaster = {
		p1 = {
			speaker = "???";
			msg = "{Do you confirm your choices?}";
			choices = {"Open the gate"};
			endchoice = "Nevermind"
		};
		p2 = {
			speaker = "???";
			msg = "{Your wish is my command}";
			endchoice = "..."
		};
		notquest = {
			speaker = "???";
			msg = "_You'd prefer not to_";
			endchoice = "Walk away"
		};
	};
	MistyGate = {
		p1 = {
			speaker = "Mist Gate";
			msg = "_Take the plunge?_";
			choices = {"Go in"};
			endchoice = "..."
		};
		p2 = {
			speaker = "Mist Gate";
			msg = "_You enter the mist gate_";
			endchoice = "..."
		};
		notquest = {
			speaker = "Mist Gate";
			msg = "_A powerful wind, stops you in your tracks_";
			endchoice = "..."
		};
	};
	Brother = {
		p1 = {
			speaker = "???";
			msg = "Who are you..?";
			choices = {"..."};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "???";
			msg = "I'm guessing %{Yaal'da}% sent you didn't he? ";
			choices = {"Yes."};
			endchoice = "Bye";
		};
		p3 = {
			speaker = "???";
			msg = "I see you need guidance to get this %ancient% power, I'll help you at a cost of 200 Money and the %ancient% power that resides, I've heard that one of %Big Hoss's% students has one...";
			choices = {"Alright."};
			endchoice = "Bye";
		};
		alreadyhas = {
			speaker = "???";
			msg = "Well then...";
			endchoice = "Bye";
		};
		waste = {
			speaker = "Tal";
			msg = "I thought I told you what I %needed%...";
			endchoice = "Bye";
		};
	};
	PasswordChecker = {
		p1 = {
			speaker = "Door";
			msg = "...";
			choices = {"Nueris Lopt"};
			endchoice = "Bye";
		};
		noquest = {
			speaker = "Door";
			msg = "...";
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Door";
			msg = "_The door opens to your words._";
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Door";
			msg = "_The door has already responded to your words.._";
			endchoice = "Bye";
		};
	};

	Shero = {
		p1 = {
			speaker = "Shero";
			msg = "Do you have the eyes?";
			choices = {"Yes."};
			endchoice = "Bye.";
		};
		p2 = {
			speaker = "Shero";
			msg = "Excellent.";
			endchoice = "...";
		};
		p3 = {
			speaker = "Shero";
			msg = "...";
			endchoice = "...";
		};

	};
	["Bounty Officer"]  = {
		p1 = {
			speaker = "Bounty Officer";
			msg = "Are you looking for a job?";
			choices = {"Yeah."};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Bounty Officer";
			msg = "I have no jobs for you currently.";
			endchoice = "Bye";
		};


	};
	["Master Assassin"]  = {
		p1 = {
			speaker = "Master Assassin";
			msg = "What do you want?";
			choices = {"I'm looking for a job"};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Master Assassin";
			msg = "I have no jobs for you currently.";
			endchoice = "Bye";
		};


	};
	Soma = {
		p1 = {
			speaker = "Soma";
			msg = "Came to learn how to cook?";
			choices = {"Yes."};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Soma";
			msg = "It won't be for cheap then (75 Money)";
			choices = {"Alright."};
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Soma";
			msg = "Get lost.";
			endchoice = "Bye";
		};
		p4 = {
			speaker = "Soma";
			msg = "...";
			endchoice = "Bye";
		};
		p5 = {
			speaker = "Soma";
			msg = "You're poor.";
			endchoice = "Bye";
		};
	},

	Lakelis = {

	},
	["Mother of Whispers"] = {

	},
	Rem = {

	},
	Vine = {

	},
	Fanari = {
		p1 = {
			speaker = "Fanari";
			msg = "Hey, could you do me a favor?";
			choices = {"What is it?"};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Fanari";
			msg = "Just bring this flower with you and give it to Ria if you happen upon her in your travels. Don't worry, it won't wilt";
			choices = {"Sure."};
			endchoice = "Bye";
		};
		saidsure = {
			speaker = "Fanari";
			msg = "Thank you.";
			endchoice = "Bye";

		};
		endofquest = {
			speaker = "Fanari";
			msg = "...Thank you for your help.";
			endchoice = "Bye";
		};
	};
	["SolanBall"] = {
		p1 = {
			speaker = "Voice of Solan";
			msg = "{Disappointing, aren't you?}";
			choices = {"..."};
		};
		p2 = {
			speaker = "Voice of Solan";
			msg = "{I will give you another chance to redeem yourself... Unless you wish to give up.}";
			choices = {"I need another chance", "I give up"}
		};
		lostwar = {
			speaker = "Voice of Solan";
			msg = "{You've lost the battle, but not the war. Your spirit will move on as a soul of another, and in the end, it will not have mattered at all.}";
			choices = {"Very well then"}
		};
		done = {
			speaker = "Voice of Solan";
			msg = "{Very well then}";
			endchoice = "..."
		};
		haslife = {
			speaker = "Voice of Solan";
			msg = "{So... you've finally seen me}";
			choices = {"I'm lost"};
		};
		cameop1 = {
			speaker = "Voice of Solan";
			msg = "{Even with heretical strength, you still crawl back here?}";
			choices = {"..."}
		};
		cameop2 = {
			speaker = "Voice of Solan";
			msg = "{When facing a foe bigger than oneself, what have you managed to achieve, besides being a plague upon this world? Your soul is one that is fragile in itself, even with an immortal body as your own.}";
			choices = {"I need another chance", "Forgive me"}
		};
		forgiven = {
			speaker = "Voice of Solan";
			msg = "{Your kin will be the one for redemption.}";
			endchoice = "...";
		};
		theend = {
			speaker = "Voice of Solan";
			msg = "{This is where you end. Farewell.}";
			endchoice = "...";
		};
	};
	["Mysterious Stranger"]  = {
		p1 = {
			speaker = "Mysterious Stranger";
			msg = "Would you like your weapon back?";
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Mysterious Stranger";
			msg = "You're poor.";
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Mysterious Stranger";
			msg = "...";
			endchoice = "Bye";
		};
	};
	Edict = { dia = {speaker = "???",
		msg = "You feel that your soul has been strengthened.",
		endchoice = "Bye."
	}

	},
	
	["VoiceFromAbove"] = {
		notfulfilled = {
			speaker = "";
			msg = "_Your mental fortitude was not enough to withstand the cold. You freeze to death._";
			endchoice = "...";
		},
		part1 = {
			speaker = "";
			msg = "_The excruciating cold beckons you, yet, you do not give up. You can hear a voice compelling you to choose your path._";
			choices = {"I roar like a thunderstorm", "I am the calm before the storm", "I am as quick as lightning"};
			endchoice = "...";
		},
		thunderstorm = {
			speaker = "";
			msg = "_Your conviction is true. Nothing stands before the thunder storm._";
			endchoice = "...";
		},
		calmofthestorm = {
			speaker = "";
			msg = "_Your conviction is true. The calmness of your mind is but yet another miracle of your soul._";
			endchoice = "...";
		},
		lightningquick = {
			speaker = "";
			msg = "_Your conviction is true. Your heart resonates - heat enough to burn. Your blood is razor sharp. Truly you are lightning fast._";
			endchoice = "...";
		},
		imageofthemind = {
			speaker = "";
			msg = "_Alas, it was yet just another image of your mind. You freeze to death._";
			endchoice = "...";
		},
		alreadydone = {
			speaker = "";
			msg = "_Your conviction stands strong. Nothing may stand before you any longer, the teachings of the Dragon Sage are engraved within your body and soul._";
			endchoice = "...";
		}
	},
	["Heretic"] = {
		notfulfilled = {
			speaker = "";
			msg = "_A slight wheeze comes out of the helmet of the corpse._";
			endchoice = "...";
		},
		part1 = {
			speaker = "";
			msg = "_Approaching the corpse of a heretic, you notice runic symbols engraved on it, which soul do you absorb?_";
			choices = {"Soul of the Runemaster", "Soul of the Cursed Flame", "Soul of the Cursed Swordsman"};
			endchoice = "...";
		},
		runemaster = {
			speaker = "";
			msg = "_Power surges within. Souls are but a tool for you to utilize._";
			endchoice = "...";
		},
		cursedflame = {
			speaker = "";
			msg = "_Power surges within. You picture the world burning by your hand.";
			endchoice = "...";
		},
		cursedswordsman = {
			speaker = "";
			msg = "_Power surges within. A voice acknowledges your unrivaled skill. You both agree on you being the greatest._";
			endchoice = "...";
		},
		death = {
			speaker = "";
			msg = "_Your vessel was too weak to withstand the power. You were absorbed into the corpse, as another soul, eternally stuck within._";
			endchoice = "...";
		},
		alreadydone = {
			speaker = "";
			msg = "_The heretic lays still - absorbing any of those who dare to approach it._";
			endchoice = "...";
		}
	},
	Kalazar  = {
		begin = {
			speaker = "Kalazar";
			msg = "Cleanse the mind.";
			choices = {"Mhm."};
			endchoice = "Bye";
		};
		getskill = {
			speaker = "Kalazar";
			msg = "Excellent.";
			endchoice = "...";
		};
		max = {
			speaker = "Kalazar";
			msg = "I've taught you all I can.";
			endchoice = "...";
		};
		notread = {
			speaker = "Kalazar";
			msg = "You're not yet ready.";
			endchoice = "...";
		};
		poor = {
			speaker = "Kalazar";
			msg = "You're poor.";
			endchoice = "...";
		};

	};
	Rehagan  = {
		begin = {
			speaker = "Rehagan";
			msg = "Have you come to further your studies?";
			choices = {"Yes."};
			endchoice = "Bye";
		};
		getskill = {
			speaker = "Rehagan";
			msg = "Crack the mind.";
			endchoice = "...";
		};
		max = {
			speaker = "Rehagan";
			msg = "I've taught you all I can.";
			endchoice = "...";
		};
		notread = {
			speaker = "Rehagan";
			msg = "You're not yet ready.";
			endchoice = "...";
		};
		poor = {
			speaker = "Rehagan";
			msg = "You're poor.";
			endchoice = "...";
		};

	};
	Xenyari = {
		p1 = {
			speaker = "Xenyari";
			msg = "Would you like to buy a scroll for 250 Money?";
			choices = {"Sure, I'll pay."};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Xenyari";
			msg = "This is a fine one!";
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Xenyari";
			msg = "You can't afford this.";
			endchoice = "Bye";
		};
		p4 = {
			speaker = "Xenyari";
			msg = "You should examine the scroll more thoroughly before coming back.";
			endchoice = "Bye";
		};

	};

	["Ya'alda"] = {
		p1 = {
			speaker = "YA'ALDA",
			title = "THE GOD NEEDLE",
			msg = "{OH, ANOTHER LOST FOOL?}",
			choices = {"..."}
		},
		p2 = {
			speaker = "YA'ALDA",
			title = "THE GOD NEEDLE",
			msg = "{HAVEN'T YOU REALIZED IT BY NOW?}",
			choices = {"..."}
		},
		p3 = {
			speaker = "YA'ALDA",
			title = "THE GOD NEEDLE",
			msg = "{THIS WORLD IS FALSE, YOU ARE FALSE, YOU AREN'T MEANT TO EXIST.}",
			choices = {"..."}
		},
		p4 = {
			speaker = "YA'ALDA",
			title = "THE GOD NEEDLE",
			msg = "{YOU ARE A HOLLOW AND A PATHETIC IMITATION.}",
			choices = {"..."}
		},
		p5 = {
			speaker = "YA'ALDA",
			title = "THE GOD NEEDLE",
			msg = "{THERE IS A TRUE WORLD, THIS WORLD HAS BLOSSOMED FROM ITS ROTTEN REMAINS.}",
			choices = {"..."}
		},
		p6 = {
			speaker = "YA'ALDA",
			title = "THE GOD NEEDLE",
			msg = "{YOU ARE GOING TO HELP ME CREATE THAT ROT.}",
			choices = {"..."}
		},
		p7 = {
			speaker = "YA'ALDA",
			title = "THE GOD NEEDLE",
			msg = "{THIS WORLD WILL DIE SOON, YOUR GUARDIAN'S SUCCESSION IS NIGH.}",
			choices = {"..."}
		},
		p8 = {
			speaker = "YA'ALDA",
			title = "THE GOD NEEDLE",
			msg = "{HE IS YOUR CREATION, YOUR PROTECTION, AND YOUR ANNIHILATION.}",
			choices = {"..."}
		},
		p9 = {
			speaker = "YA'ALDA",
			title = "THE GOD NEEDLE",
			msg = "{THIS WORLD WILL BE FUEL FOR ITS OWN PYRE, HOW PATHETIC.}",
			choices = {"..."}
		},
		p10 = {
			speaker = "YA'ALDA",
			title = "THE GOD NEEDLE",
			msg = "{IF ONLY YOU KNEW.}",
			endchoice = {"R͗ͥ͐Ȍ̿͆Tͨ̑̚ ͋͊ͧWͪͨͮĬ̒̃҉͙̬͔T̈̾ͩ҉̬͈̱H̐̍̈́ ͊̀̂Tͥ̾̾Hͭ̇ͨIͩ͑̏Sͩ̽ͬ ͩͩ̓Wͯ̂̽O͑ͤ͐R̈ͯ̐L̽͂͊D̈́͂͒,͐̄ͨ ͯ̔̐Wͥ̈́͂Oͮ̏̓Nͮ͊ͥ'ͬ̒͂T̿̅̓ ̐̿̉Yͬ̂̓Ǒ̐͐U̿ͫ͂҉̗͡͝?͌͌̾"}
		},
		requirement = {
			speaker = "YA'ALDA",
			title = "THE GOD NEEDLE",
			msg = "{OH. ANOTHER LOST FOOL?}",
			endchoice = {"..."}
		},
	},

	Oracle = {
		p1 = {
			speaker = "Oracle",
			title = "The Seer",
			msg = "{Entering the mist gate, what did you see?}",
			choices = {"..."}
		};
		p2 = {
			speaker = "Oracle",
			title = "The Seer",
			msg = "{As it will be, for us, Seers, that even after seeing what might happen, the ending is unchangable.}",
			choices = {"..."}
		};
		p3 = {
			speaker = "Oracle",
			title = "The Seer",
			msg = "{Now then. With your quest having reached its end, what have you expected to achieve?}",
			choices = {"The answer to clairvoyance"}
		};
		p4 = {
			speaker = "Oracle",
			title = "The Seer",
			msg = "{Very well then, if you have Seen the end, and accepted it with pride, you will gladly give your life to the cycle.}",
			choices = {"???"}
		};
		p5 = {
			speaker = "???",
			msg = "_Having been transported out of the realm, you could only think to yourself 'I Have Seen'_",
			choices = {"..."}
		};
		lost = {
			speaker = "???",
			msg = "{Oh...}",
			choices = {"..."}
		};
		seerp1 = {
			speaker = "Oracle",
			title = "The Seer",
			msg = "{With the mark of the seer, you have returned.}",
			choices = {"..."}
		};
		seerp2 = {
			speaker = "Oracle",
			title = "The Seer",
			msg = "{Isn't it unbelievable that even beyond death, you could still see me?.}",
			choices = {"What are you talking about?"}
		};
		seerp3 = {
			speaker = "Oracle",
			title = "The Seer",
			msg = "{It is simple by Intent, that you could find me. Otherwise, nothing would've guided you to me.}",
			choices = {"..."}
		};
		seerp4 = {
			speaker = "Oracle",
			title = "The Seer",
			msg = "{It seems as though you are still confused. Very well then. 10 Seers of the past have appeared around the realm. Find them and then return to me once more.}",
			choices = {"..."}
		};
		seerp5 = {
			speaker = "???",
			msg = "_Transported out of the realm, you faintly see images of such an occurence happening to ones from before._",
			endchoice = "...",
		};
	};

	["As'endo"] = {
		notquest = {
			speaker = "???",
			msg = "{Oh? Interesting specimen.}",
			endchoice = "...",
		};
		noobtainmentrace = {
			speaker = "???",
			msg = "{Hmm... You're simply not cut out for ascension. Pity, isn't it?}",
			endchoice = "...",
		};
		started = {
			speaker = "???",
			msg = "_A new path opens forward: what might this adventure bring, you are left wondering._",
			endchoice = "...",
		},
	};

	["As'endoHaseldan"] = {
		startedp1 = "As'endo",
		msg = "{Ah, a Haseldan seeking the path of ascension. I am As'endo, Keeper of the Infernal Secrets. Not often does a commoner like you intercept my realm. What brings you here, daring soul?}",
		choices = {"I'm seeking the Ascencion Trial"},
		endchoice = "...",
	},
	startedp2 = {
		speaker = "As'endo",
		msg = "{Ah, the fire of determination burns brightly within you. As a Haseldan, Rage burns deeply within you. Your journey begins with Adralik. They hold the key to your first trial.}",
		choices = {"Where can he be found?"},
		endchoice = "...",
	},
	startedp3 = {
		speaker = "As'endo",
		msg = "{Oh, don't get ahead of yourself, there is a reason that it's called a Trial. Remember, as an Azael, you carry the strength of our kind. Go now, and let the flames guide your way.}",
		choices = {"I will not fail"},
		endchoice = "...",
	},

	["As'endoAzael"] = {
		startedp1 = {
			speaker = "As'endo",
			msg = "{Ah, a fellow Azael seeking the path of ascension. I am As'endo, Keeper of the Infernal Secrets. It is not often I meet one of my own. What brings you here, daring soul?}",
			choices = {"I'm seeking the Ascencion Trial"},
			endchoice = "...",
		},
		startedp2 = {
			speaker = "As'endo",
			msg = "{Ah, the fire of determination burns brightly within you. As an Azael, you are already acquainted with the power of flames. Our shared bloodline compels me to guide you. Your journey begins with Adralik. They hold the key to your first trial.}",
			choices = {"Where can he be found?"},
			endchoice = "...",
		},
		startedp3 = {
			speaker = "As'endo",
			msg = "{Oh, don't get ahead of yourself, there is a reason that it's called a Trial. Remember, as an Azael, you carry the strength of our kind. Go now, and let the flames guide your way.}",
			choices = {"I will not fail"},
			endchoice = "...",
		},
		cameback = {
			speaker = "As'endo",
			msg = "{You're back. What have you learned?}",
			choices = {"You tricked me"},
			endchoice = "...",
		},
		cameback2 = {
			speaker = "As'endo",
			msg = "{Did I? It seems to me that you got exactly what you wanted.}",
			choices = {"What!?"},
			endchoice = "...",
		},
		cameback3 = {
			speaker = "As'endo",
			msg = "{The Obelisk Network is a piece of technology that us Azaels can take advantage of to gain Immense power. You coming here, got exactly what you wanted.}",
			choices = {"..."},
		},
		cameback4 = {
			speaker = "As'endo",
			msg = "{Say, don't you want to ascend?}",
			choices = {"I don't have any other choice"},
		},
		cameback5 = {
			speaker = "As'endo",
			msg = "{Very well then! I will need some of your knowledge though. (20 insight)}",
			choices = {"Let's do it"},
			endchoice = "I'll think about it",
		},
		noinsight = {
			speaker = "As'endo",
			msg = "{It's amazing how far you've come with an intellect such as yours.}",
			endchoice = "...",
		},
		ascended = {
			speaker = "As'endo",
			msg = "{Well then... Off you go, Ruler of Fire.}",
			endchoice = "...",
		},
		camebackinsight = {
			speaker = "As'endo",
			msg = "{Oh, you're back. Have you come back a bit smarter?}",
			choices = {"Let's do it"},
			endchoice = "...",
		},
		ruleroffire = {
			speaker = "As'endo",
			msg = "{Ruler of Fire, use your enhanced abilities only for yourself.}",
			endchoice = "My will is Absolute",
		}
	};

	OtherSeer = {
		p1 = {
			speaker = "Otherwordly Seer",
			msg = "_A ghastly being with the memories of a Seer._",
			choices = {"Attune"},
			endchoice = "...",
		};
		p2 = {
			speaker = "???",
			msg = "_Your Seer abilities have been heightened_",
			endchoice = "...",
		};
		notquest = {
			speaker = "???",
			msg = "_As if peering at you, the ghastly being seems one to not be messed with_",
			endchoice = "...",
		};
	};

	Tanari = {
		p1 = {
			speaker = "Tanari";
			msg = "Have you come to learn advanced smithing?";
			choices = {"Yes"};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Tanari";
			msg = "That'll be 350 Money.";
			choices = {"I'll pay"};
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Tanari";
			msg = "Great.";
			endchoice = "Bye";
		};
		max = {
			speaker = "Tanari";
			msg = "You're almost as good as me.";
			endchoice = "Bye";
		};
		no = {
			speaker = "Tanari";
			msg = "You're not ready to learn.";
			endchoice = "Bye";
		};
		poor = {
			speaker = "Tanari";
			msg = "You cannot afford my lessons.";
			endchoice = "Bye";
		};
	};
	Fallion = {
		p1 = {
			speaker = "Fallion";
			msg = "...You are truly a special case, aren't you? I would be honored to teach you - would you like to learn some ways to enhance your casting?";
			choices = {"Yes."};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Fallion";
			msg = "...Hm, I suppose I could teach you for %80 Money%.";
			choices = {"I'll pay."};
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Fallion";
			msg = "Continue with your studies.";
			endchoice = "Bye";
		};
		poor = {
			speaker = "Fallion";
			msg = "Come back when you can afford my lessons.";
			endchoice = "Bye";
		};
		max = {
			speaker = "Fallion";
			msg = "Maybe one day we will discover all the secrets of this world.";
			endchoice = "Bye";
		};
		no = {
			speaker = "Fallion";
			msg = "...";
			endchoice = "Bye";
		};
	};
	["Witch Malady"] = {
		p1 = {
			speaker = "Witch Malady";
			msg = "What do you want, little kid?";
			choices = {"I have some Candy.","I'd like to redeem my Candy Points."};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Witch Malady";
			msg = "What are you interested in receiving?";
			choices = {"Equipment.","Spells.","Anything special?"};
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Witch Malady";
			msg = "Indeed. I can transform you into a Dullahan for 150 candy if you'd like.";
			choices = {"I'll pay."};
			endchoice = "Bye";
		};
		equipment = {
			speaker = "Witch Malady";
			msg = "I have a Broom Sword, a Broom Spear, an Orange Cowl, a Purple Cowl, and three different chairs carved from my pumpkins. Which would you like?";
			choices = {"Broom Sword","Broom Spear","Orange Cowl","Purple Cowl","Jack o'Lantern Chair","Jack o'Lantern Chair Green","Jack o'Lantern Chair Purple"};
			endchoice = "Bye";
		};
		-- A cloth dyed in pumpkin blood... It will cost you 15 Candy Points; you currently have Candy Points.
		-- A hood pulled from the abyss itself... It will cost you 15 Candy Points; you currently have Candy Points.
		-- A sword made of rare wood that is as sturdy as Mythril. It will cost you 25 Candy Points; you currently have Candy Points.
		-- A spear made of rare wood that is as sturdy as Mythril. It will cost you 25 Candy Points; you currently have Candy Points.
		spells = {
			speaker = "Witch Malady";
			msg = "I know two spells that may interest you: Nosferatus and Gourdus.";
			choices = {"Nosferatus","Gourdus",};
			endchoice = "Bye";
		};
		-- Satiate your hunger every hour with pumpkins. It will cost you 250 Candy Points; you currently have _Candy Points._
		-- Summon a Vampire to siphon the blood of your enemies. It will cost you 250 Candy Points; you currently have _Candy Points._
		bye = {
			speaker = "Witch Malady";
			msg = "Have fun.";
			endchoice = "Bye";
		};
		alreadyowned = {
			speaker = "Witch Malady";
			msg = "You already own this.";
			endchoice = "Bye";
		};
		poor = {
			speaker = "Witch Malady";
			msg = "Come back when you have enough.";
			endchoice = "Bye";
		};
	};
	Dummy = {
		p1 = {
			speaker = "Your head";
			msg = "_Punch me please!_";
			endchoice = "(!?)";
		};
	};


	Aptorgath = {
		p1 = {
			speaker = "Aptorgath";
			msg = "Have you come to learn how to play the trumpet?";
			choices = {"Yes"};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Aptorgath";
			msg = "That'll be 350 Money.";
			choices = {"I'll pay"};
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Aptorgath";
			msg = "Great.";
			endchoice = "Bye";
		};
		max = {
			speaker = "Aptorgath";
			msg = "You're almost as good as me, my student.";
			endchoice = "Bye";
		};
		no = {
			speaker = "Aptorgath";
			msg = "You're not ready to learn.";
			endchoice = "Bye";
		};
		poor = {
			speaker = "Aptorgath";
			msg = "You cannot afford my lessons.";
			endchoice = "Bye";
		};
	};

	Banker = {
		p1 = {
			speaker = "Banker";
			msg = "Need something looking after?";
			choices = {"Yes."};
			endchoice = "Bye";
		};
		no = {
			speaker = "Banker";
			msg = "Hm. Nothing you have is worth looking after, I'm afraid.";
			endchoice = "Bye";
		};
	};
	Doctor = {
		p1 = {
			speaker = "Doctor";
			msg = "Would you like a check-up? (1 Money)";
			choices = {"Sure"};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Doctor";
			msg = "There, I've done my best.";
			endchoice = "Bye";
		};
		poor = {
			speaker = "Doctor";
			msg = "You can't afford this.";
			endchoice = "Bye";
		};
		no = {
			speaker = "Doctor";
			msg = "Well, you don't have any injuries that I can remedy.";
			endchoice = "Bye";
		};
		gaian = {
			speaker = "Doctor";
			msg = "Machines aren't really my expertise... Sorry...";
			endchoice = "Bye";
		};
	};

	["The Eagle"] = {
		p1 = {
			speaker = "Strange Eagle Statue";
			msg = "_The Eagle resonates with the feather you hold._";
			choices = {"Send me in."};
			endchoice = "Bye";
		};
		no = {
			speaker = "The Eagle";
			msg = "It doesn't speak.";
			endchoice = "Bye";
		};
	};

	ObeliskDesert = {};
	ObeliskDeepForest = {};
	ObeliskForest = {};
	ObeliskShore = {};
	ObeliskSigil = {};
	ObeliskSkyCastle = {};
	ObeliskSnail = {};
	ObeliskTundra = {};

	Obelisk = {
		p1 = {
			speaker = "...";
			msg = "_The Obelisk attempts to commune with your soul._";
			choices = {"Resonate"};
			endchoice = "Bye";
		};

		p2 = {
			speaker = "...";
			msg = "Your soul resonates with the Obelisk.";
			endchoice = "Bye";
		};

		p3 = {
			speaker = "...";
			msg = "_The Obelisk stands proud_";
			endchoice = "Bye";
		};

		ascended = {
			speaker = "...";
			msg = "_The Obelisk stands proud_";
			choices = {"Attune Skill"};
			endchoice = "Bye";
		};

		Resonated = {
			speaker = "...";
			msg = "_The Great Power emanating from the Obelisk compels you to not gawk at it for any longer_";
			endchoice = "Bye";
		};

	},

	Wayfinder = {
		p1 = {
			speaker = "Wayfinder";
			msg = "Your soul contains something, will you purge it?";
			choices = {"Yes. (Wipe edict)"};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Wayfinder";
			msg = "Very well then, idiot.";
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Wayfinder";
			msg = "Your soul has potential, will you draw it out?";
			endchoice = "Bye";
		}
	},
	Igor = {
		hasArtifact = {
			speaker = "Igor";
			msg = "_The soul contained within the statue whispers to you._ hey, hey you, i see you , grabbed an artifact. i can take it, for a nice 5000 coins. i collect them, you hear me, man? give it, but not for free";
			choices = {"Sure."};
			endchoice = "Bye";
		};
		doesntHave = {
			speaker = "";
			msg = '_The statue is inscribed with the title "Igor, The Fool"_';
			endchoice = "Bye";
		};
		broke = {
			speaker = "Igor";
			msg = '_The soul contained within the statue whispers to you._ dont cheap out on me man im igor, igor the fool, i want money, get me the money first';
			endchoice = "Bye";
		};
		success = {
			speaker = "Igor";
			msg = '_The soul contained within the statue whispers to you._ alright man badda bing badda boom skadoosh biggly boogly ur artifacts gone man thanks man i appreciate it man goodbye';
			endchoice = "Bye";
		}
	},
	ObeliskNorpa = {
		p1 = {
			speaker = "";
			msg = "_The Obelisk attempts to commune with your soul._";
			choices = {"Resonate"};
			endchoice = "Bye";
		};

		p2 = {
			speaker = "";
			msg = "Your soul resonates with the Obelisk.";
			endchoice = "Bye";
		};

		p3 = {
			speaker = "";
			msg = "_The Obelisk radiates a great power._";
			endchoice = "Bye";
		},
		p4 = {
			speaker = "";
			msg = "_Control obelisk. It is off._";
			choices = {"Enable","Friendly Fire Turrets","Toggle Turrets"};
			endchoice = "Bye";
		},
		p5 = {
			speaker = "";
			msg = "_Control obelisk. It is on._";
			choices = {"Disable", "Friendly Fire Turrets","Toggle Turrets"};
			endchoice = "Bye";
		},
		p6 = {
			speaker = "";
			msg = "_Status Changed to On_";
			endchoice = "Bye";
		},
		p8 = {
			speaker = "";
			msg = "_Status Changed to Off_";
			endchoice = "Bye";
		},

		p7 = {
			speaker = "";
			msg = "_An ancient power holds you back from interacting with the obelisk_";
			endchoice = "Bye";
		}

	},
	Ferryman = {
		choices = {
			speaker = "The Ferryman";
			msg = "So soon? Did you miss me?";
			choices = {"New Character\n(free)","Same Character\n(20 R$)","New Lineage\n(10 R$)"};
			endchoice = "Bye";
		};
		genderchoice = {
			speaker = "The Ferryman";
			msg = "Will your next form be as your son, or as your daughter?";
			choices = {"My Son.","My Daughter."};
			endchoice = "Bye";
		};
		goodbye = {
			speaker = "The Ferryman";
			msg = "So be it. Goodbye for now.";
			endchoice = "Bye";	
		};
		haslife = {
			speaker = "The Ferryman";
			msg = "How did you get here?";
			choices = {"Can you send me back?"};
			endchoice = "Bye";
		};
		newlineage = {
			speaker = "The Ferryman";
			msg = "The end of a lineage, then?";
			endchoice = "Bye";
		};
		samecharacter = {
			speaker = "The Ferryman";
			msg = "So, you desire resurrection?";
			endchoice = "Bye";
		};
		nolastwind = {
			speaker = "The Ferryman";
			msg = "I'm afraid I can only resurrect you once.";
			endchoice = "Bye";
		};
	};
	Merchant = {
		p1 = {
			speaker = "Merchant";
			msg = "Need something appraised?";
			choices = {"Could you appraise this for me?","Can I sell in bulk?"};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Merchant";
			msg = "Sure, what would you like to sell?";
			choices = {"Ingredients.","Trinkets."};
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Merchant";
			msg = "I don't want that.";
			endchoice = "Bye";
		};
		p4 = {
			speaker = "Merchant";
			msg = "Pleasure doing business.";
			endchoice = "Bye";
		};
	};
	Fungchant = {
		p1 = {
			speaker = "Fungchant";
			msg = "Need something appraised?";
			choices = {"Could you appraise this for me?","Can I sell in bulk?"};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Fungchant";
			msg = "Sure, what would you like to sell?";
			choices = {"Ingredients.","Trinkets."};
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Fungchant";
			msg = "I don't want that.";
			endchoice = "Bye";
		};
		p4 = {
			speaker = "Fungchant";
			msg = "Pleasure doing business.";
			endchoice = "Bye";
		};
		noscroom = {
			speaker = "Fungchant";
			msg = "...";
			endchoice = "Bye";
		};
	};
	Engineer = {
		gaian = {
			p1 = {
				speaker = "Engineer";
				msg = "Do you want me to upgrade your body for 500 Money?";
				choices = {"Alright."};
				endchoice = "Bye";
			};
			p2 = {
				speaker = "Engineer";
				msg = "There, I've done my best.";
				endchoice = "Bye";
			};
			p3 = {
				speaker = "Engineer";
				msg = "...";
				endchoice = "Bye";
			};
			injuries = {
				speaker = "Engineer";
				msg = "Would you like me to fix your injuries? (30 Money)";
				choices = {"Alright."};
				endchoice = "Bye";
			};
			fixed = {
				speaker = "Engineer";
				msg = "There, I've done my best.";
				endchoice = "Bye";
			};
		};
		human = {
			p1 = {
				speaker = "Engineer";
				msg = "What do you need?";
				choices = {"I heard you can make prosthetic arms."};
				endchoice = "Bye";
			};
			p2 = {
				speaker = "Engineer";
				msg = "I can make you a prosthetic for around 500 Money.";
				choices = {"Patch me up."};
				endchoice = "Bye";
			};
			p3 = {
				speaker = "Engineer";
				msg = "Want your arm back? That'll be 1000 Money.";
				choices = {"Patch me up."};
				endchoice = "Bye";
			};
			p4 = {
				speaker = "Engineer";
				msg = "There, I've done my best.";
				endchoice = "Bye";
			};
		};
		poor = {
			speaker = "Engineer";
			msg = "You don't have enough Money.";
			endchoice = "Bye";
		};
	};
	Ezlo = {
		p1 = {
			speaker = "Ezlo";
			msg = "Hey! Wanna see a magic {trick}";
			choices = {"Alright."};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Ezlo";
			msg = "I'd be happy to! Bring me any %gem% you can find. Then, I shall show you my trick.";
			endchoice = "Bye";
		};
		exit = {
			speaker = "Ezlo";
			msg = "ok!";
			endchoice = "Bye";
			exit = true;
		};
	};
	Willow = {
		p1 = {
			speaker = "...";
			msg = "Huh? Oh, hello. I can drop you back to your inn, if you wish.";
			choices = {"Take me away."};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "...";
			msg = "Very well.";
			endchoice = "Bye";
		};
		exit = {
			speaker = "...";
			msg = "...";
			endchoice = "Bye";
			exit = true;
		};
	};
	Timothy = {
		p1 = {
			speaker = "Timothy";
			msg = "Hey buddy, the merchandise is down there, get down from here!";
			endchoice = "Bye",
		}
	};
	Golis = {
		p1 = {
			speaker = "Golis";
			msg = "Ah! Hello fellow traveler, do you want one of my fine chairs?";
			choices = {"Sure."};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Golis";
			msg = "I hope you make good use of my chairs!";
			endchoice = "Bye";
		};
		exit = {
			speaker = "Golis";
			msg = "...";
			endchoice = "Bye";
			exit = true;
		};
	};
	Feltr = {
		p1 = {
			speaker = "Feltr";
			msg = "Do any of my wares interest you?";
			endchoice = "Bye";
		};
	};
	Ferin = {
		p1 = {
			speaker = "Ferin";
			msg = "Do any of my wares interest you?";
			endchoice = "Bye";
		};
	};
	["Inn Keeper"] = {
		p1 = {
			speaker = "Inn Keeper";
			msg = "Do you want to set your spawn here?";
			choices = {"Alright."};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Inn Keeper";
			msg = "Enjoy your stay.";
			endchoice = "Bye";
		};
	};

	["Fungkeeper"] = {
		p1 = {
			speaker = "Fung Keeper";
			msg = "Do you want to set your spawn here?";
			choices = {"Alright."};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Fung Keeper";
			msg = "Enjoy your stay.";
			endchoice = "Bye";
		};
		noscroom = {
			speaker = "Fung Keeper";
			msg = "...";
			endchoice = "Bye";
		}
	};
	["Fungorian"] = {
		p1 = {
			speaker = "Fungorian";
			msg = "I want to eat a Scroom.";
			endchoice = "Alright.";
		};
		noscroom = {
			speaker = "Fungorian";
			msg = "...";
			endchoice = "Bye";
		}
	};
	["Fungtor"] = {
		p1 = {
			speaker = "Fungtor";
			msg = "What are you doing up here? Did Fungorian send you? Don't eat me!";
			endchoice = "...";
		};
		noscroom = {
			speaker = "Fungtor";
			msg = "...";
			endchoice = "Bye";
		}
	};
	["Gerich"] = {
		p1 = {
			speaker = "Gerich";
			msg = "Hello, would you like some vint? (6 Money)";
			choices = {"Sure"};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Gerich";
			msg = "Great doing business with you!";
			endchoice = "Bye";
		};
		nomoney = {
			speaker = "Gerich";
			msg = "Get out of here!";
			endchoice = "Bye";
		};
	};
	["Vincent"] = {
		p1 = {
			speaker = "Vincent";
			msg = "Hello, would you like some vint? (6 Money)";
			choices = {"Sure"};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Vincent";
			msg = "Great doing business with you!";
			endchoice = "Bye";
		};
		nomoney = {
			speaker = "Vincent";
			msg = "Get out of here!";
			endchoice = "Bye";
		};
	};
	["Johann"] = {
		p1 = {
			speaker = "Johann";
			msg = "Hello, would you like some vint? (6 Money)";
			choices = {"Sure"};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Johann";
			msg = "Great doing business with you!";
			endchoice = "Bye";
		};
		nomoney = {
			speaker = "Johann";
			msg = "Get out of here!";
			endchoice = "Bye";
		};
	};
	-- Hidden Hall
	Sevier = {
		p1 = {
			speaker = "Sevier";
			msg = "Do you want to set your spawn here?";
			choices = {"Alright."};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Sevier";
			msg = "Enjoy your stay.";
			endchoice = "Bye";
		};
	};

	-- Central Sanctuary/Sigil tree
	Orodin = {
		p1 = {
			speaker = "Orodin";
			msg = "Do you want to set your spawn here?";
			choices = {"Alright."};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Orodin";
			msg = "Enjoy your stay.";
			endchoice = "Bye";
		};
	};

	Squeltch = {
		p1 = {
			speaker = "Squeltch";
			msg = "Do you want to end up like me? Pushed away from society because of my name... {SQUELTCH?!} Give me 4000 Money and I'll do some of my _magic_ to change your name.";
			choices = {"Alright."};
			endchoice = "Bye";
		};
		bought = {
			speaker = "Squeltch";
			msg = "Good business.";
			endchoice = "Bye";
		};
		poor = {
			speaker = "Squeltch";
			msg = "You're broke.";
			endchoice = "Bye";
		};
	};


	Kyley = {
		p1 = {
			speaker = "Kyley";
			msg = "Hey!, I've heard alot about you recently to be kind I would like to give you this helmet my brother left me.";
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Kyley";
			msg = "It seems I can't give you this..";
			endchoice = "Bye";
		};
	};
	["Bounty Hunter"] = {
		p1 = {
			speaker = "Bounty Hunter";
			msg = "What do you want?";
			endchoice = "Bye"			
		};
		p2 = {
			speaker = "Master";
			msg = "Looks like you're out of luck... There aren't any suitable criminals around today...";
			endchoice = "Bye";
		};
	};
	Kai =  {

	};
	Ethan = {
		p1 = {
			speaker = "Ethan";
			msg = "No skill? No problem, gimme 60.";
			choices = {"Alright."};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Ethan";
			msg = "It's the worm squirm, baby.";
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Ethan";
			msg = "Small Wallet? Big Problem.";
			endchoice = "Bye";
		};
		no = {
			speaker = "Ethan";
			msg = "Can't hold F?";
			endchoice = "Bye";
		};
		max = {
			speaker = "Ethan";
			msg = "I've taught you all I can.";
			endchoice = "Bye";
		};
	};
	Gurn = {
		p1 = {
			speaker = "Gurn";
			msg = "I can enchance your knowledge of the Katana for 125 Money.";
			choices = {"Alright."};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Gurn";
			msg = "Ballin'";
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Gurn";
			msg = "#####";
			endchoice = "Bye";
		};
		no = {
			speaker = "Gurn";
			msg = "...";
			endchoice = "Bye";
		};
		max = {
			speaker = "Gurn";
			msg = "I have already taught you everything I know.";
			endchoice = "Bye";
		};
	};
	Eliwood = {
		p1 = {
			speaker = "Eliwood";
			msg = "Another impoverished brigand... Looking to learn something about _true_ swordsmanship?";
			choices = {"Yes."};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Eliwood";
			msg = "You seem to understand the basics... We'll get started for _100 Money_";
			choices = {"I'll pay."};
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Eliwood";
			msg = "Your footwork is sloppy... But I suppose if you keep paying me you'll get there eventually.";
			endchoice = "Bye";
		};
		poor = {
			speaker = "Eliwood";
			msg = "As expected... Someone with no respect.";
			endchoice = "Bye";
		};
		max = {
			speaker = "Eliwood";
			msg = "Still here? I'm sure you can find someone else to bother.";
			endchoice = "Bye";
		};
		no = {
			speaker = "Eliwood";
			msg = "You wield your sword like a farming tool, get out of my sight.";
			endchoice = "Bye";
		};
	};
	Linari = {
		p1 = {
			speaker = "Linari";
			msg = "I can teach you the way of the Katana for 250 Money.";
			choices = {"Alright."};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Linari";
			msg = "Ballin'";
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Linari";
			msg = "######";
			endchoice = "Bye";
		};
		no = {
			speaker = "Linari";
			msg = "It seems I can't teach you this.";
			endchoice = "Bye";
		};
		max = {
			speaker = "Linari";
			msg = "I've taught you all I can, my student.";
			endchoice = "Bye";
		};
	};
	Dormin = {
		p1 = {
			speaker = "Dormin";
			msg = "...";
			choices = {"Need any help?"};
			endchoice = "...";
		};
		p2 = {
			speaker = "Dormin";
			msg = "Huh? Yeah, I could really go for some vint right now.";
			choices = {"..."};
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Dormin";
			msg = "Listen, if you aren't going to give me some vint, get out of here.";
			choices = {"Alright"};
			endchoice = "Bye";
		};
		no = {
			speaker = "Dormin";
			msg = "Will you stop bothering me?";
			endchoice = "...";
		};
		cameback = {
			speaker = "Dormin";
			msg = "Back to bother me?";
			choices = {"Here's your vint"};
			endchoice = "...";
		};
		ofc = {
			speaker = "Dormin";
			msg = "Thanks, kid.";
			endchoice = "Bye";
		};
		healerdone = {
			speaker = "Dormin";
			msg = "Thanks, kid.";
			choices = {"Bye"};
		};
		cooldown = {
			speaker = "Dormin";
			msg = "...";
			endchoice = "Bye";
		};
	};
	["Church Knight"] = {
		p1 = {
			speaker = "The Sanctum Spear";
			msg = "The Prince speaks to you.";
			choices = {"Please grant me strength..."};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "The Sanctum Spear";
			msg = "The Prince requires you offer Money to the spear.";
			choices = {"Offer"};
			endchoice = "Bye";
		};
		max = {
			speaker = "The Sanctum Spear";
			msg = "The pain leaves you, and you can feel that the Prince is pleased.";
			endchoice = "Bye";
		};
		no = {
			speaker = "The Sanctum Spear";
			msg = "The Prince does not speak.";
			endchoice = "Bye";
		};
		gotskill = {
			speaker = "The Sanctum Spear";
			msg = "The Prince grants you power.";
			endchoice = "Bye";
		};
	};
	Ishikk = {
		p1 = {
			speaker = "Ishikk";
			msg = "Oh so you've learnt the ways of the chef, would you like to perhaps advance your knowledge and become a Spearfisher?";
			choices = {"Yes."};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Ishikk";
			msg = "Great, that'll be _%100 Money%_.";
			choices = {"I'll pay."};
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Ishikk";
			msg = "Haha!";
			endchoice = "Bye";
		};
		poor = {
			speaker = "Ishikk";
			msg = "You don't have enough Money.";
			endchoice = "Bye";
		};
		no = {
			speaker = "Ishikk";
			msg = "...";
			endchoice = "Bye";
		};
		max = {
			speaker = "Ishikk";
			msg = "I've taught you all I can.";
			endchoice = "Bye";
		};
	};
	Tiger = {
		p1 = {
			speaker = "Tiger";
			msg = "Oh, it's you, I've been told about you, do you wish to become a dragon knight?";
			choices = {"Yes, Teach me. (100 Money)"};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Tiger";
			msg = "Haha!";
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Tiger";
			msg = "You don't have enough Money.";
			endchoice = "Bye";
		};
		no = {
			speaker = "Tiger";
			msg = "...";
			endchoice = "Bye";
		};
		max = {
			speaker = "Tiger";
			msg = "I've taught you all I can.";
			endchoice = "Bye";
		};
	};
	Fabiana = {
		p1 = {
			speaker = "Fabiana";
			msg = "Well friend, that'll be 35 Money.";
			choices = {"Alright"};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Fabiana";
			msg = "Coin coin coin.";
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Fabiana";
			msg = "No Money, no training.";
			endchoice = "Bye";
		};
		no = {
			speaker = "Fabiana";
			msg = "...";
			endchoice = "Bye";
		};
		max = {
			speaker = "Fabiana";
			msg = "I have already taught you everything I know.";
			endchoice = "Bye";
		};
	};
	Alfric = {
		p1 = {
			speaker = "Alfric";
			msg = "What's yer business? _Y'here to learn how to defend yerself?_	";
			choices = {"Yeah."};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Alfric";
			msg = "Alright kid, that'll be _%35 Money.%_";
			choices = {"I'll pay."};
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Alfric";
			msg = "Good work, kid.";
			endchoice = "Bye";
		};
		p4 = {
			speaker = "Alfric";
			msg = "I don't work for free, kid. *{Scram}*!";
			endchoice = "Bye";
		};
		max = {
			speaker = "Alfric";
			msg = "Heheh. I'm sure you'll put what I've taught you to good use, kid.";
			endchoice = "Bye";
		};
	};
	Chalphy = {
		p1 = {
			speaker = "Chalphy";
			msg = "You should watch out. This path gives me some bad vibes...";
			choices = {"What about it?"};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Chalphy";
			msg = "The weight of the air in there is heavy. Must be due to the nearby Burial Grounds.";
			choices = {"The Burial Grounds?"};
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Chalphy";
			msg = "You don't know? Perhaps you should think about what was buried there...";
			endchoice = "Bye";
		};
	};
	Dockmaster = {
		p1 = {
			speaker = "Dockmaster";
			msg = "I'm the $Dockmaster$ 'ere. But times have hit me 'ard, so I gone and done ran outta seaworthy vessels...";
			endchoice = "Bye";
		};
	};
	Delia = {
		p1 = {
			speaker = "Delia";
			msg = "Hello.";
			choices = {"I've heard I can get my hands on a tome here."};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Delia";
			msg = "A tome? I don't know what you are talking about.";
			endchoice = "Bye";
		};
	};

	Vinifera = {
		p1 = {
			speaker = "Vinifera";
			msg = "Would you like to learn the lute?";
			choices = {"Yeah."};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Vinifera";
			msg = "50 Money should cover the costs.";
			choices = {"I'll pay."};
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Vinifera";
			msg = "Use your whole hand to play, good.";
			endchoice = "Bye";
		};
		p4 = {
			speaker = "Vinifera";
			msg = "I cant teach you anything, sorry";
			endchoice = "Bye";
		};
		max = {
			speaker = "Vinifera";
			msg = "Spead music around Gaia, my student.";
			endchoice = "Bye";
		};
	};

	GetOut = {
		p1 = {
			speaker = "...";
			msg = "...";
			endchoice = "...";
		}
	};
	Grendel = {
		p1 = {
			speaker = "Grendel";
			msg = "Would you like to be an alchemist?";
			choices = {"Yeah."};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Grendel";
			msg = "75 Money should cover the costs.";
			choices = {"I'll pay."};
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Grendel";
			msg = "Alchemy is the nature of life.";
			endchoice = "Bye";
		};
		p4 = {
			speaker = "Grendel";
			msg = "I cant teach you anything, sorry";
			endchoice = "Bye";
		};
		max = {
			speaker = "Grendel";
			msg = "Wise man.";
			endchoice = "Bye";
		};
	};

	GetOuthere = {
		p1 = {
			speaker = "...";
			msg = "...";
			endchoice = "...";
		}
	};
	Frey = {
		p1 = {
			speaker = "Knight Captain Frey";
			msg = "Ah. Need something?";
			choices = {"Is there anything you can teach me?"};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Knight Captain Frey";
			msg = "Looking to strengthen your bond to our order? I'll need 65 Money to get us the supplies.";
			choices = {"I'll pay."};
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Knight Captain Frey";
			msg = "Let us begin.";
			endchoice = "Bye";
		};
		p4 = {
			speaker = "Knight Captain Frey";
			msg = "You don't have enough Money.";
			endchoice = "Bye";
		};
		no = {
			speaker = "Knight Captain Frey";
			msg = "You aren't ready for this.";
			endchoice = "Bye";
		};
		max = {
			speaker = "Knight Captain Frey";
			msg = "You've done well, my young Sigil Knight. Seek out Castle Sanctuary in the North to continue your training.";
			endchoice = "Bye";
		};
	};
	Jafar = {
		p1 = {
			speaker = "Jafar";
			msg = "Ah, need something?";
			choices = {"Is there anything you can teach me?"};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Jafar";
			msg = "Hoping to end up in a cozy cell like me? Well, that'll be 80 Money.";
			choices = {"I'll pay."};
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Jafar";
			msg = "Excellent.";
			endchoice = "Bye";
		};
		p4 = {
			speaker = "Jafar";
			msg = "Pay up kid.";
			endchoice = "Bye";
		};
		no = {
			speaker = "Jafar";
			msg = "Naw.";
			endchoice = "Bye";
		};
		max = {
			speaker = "Jafar";
			msg = "Heh... Maybe next time, friend...";
			endchoice = "Bye";
		};
	};
	Knight = {
		p1 = {
			speaker = "Faceless One";
			msg = "...Does one see through me?";
			choices = {"Teach me the ways to hide myself."};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Faceless One";
			msg = "Discard your identity and possessions.";
			choices = {"Here is 350 Money."};
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Faceless One";
			msg = "...";
			endchoice = "Bye";
		};
		p4 = {
			speaker = "Faceless One";
			msg = "...";
			endchoice = "Bye";
		};
		no = {
			speaker = "Faceless One";
			msg = "...";
			endchoice = "Bye";
		};
		max = {
			speaker = "Shadow";
			msg = "Who are you?";
			endchoice = "Bye";
		};
		pathdone = {
			speaker = "Shadow";
			msg = "The rot has already taken root in you. It does not spread twice.";
			endchoice = "Bye";
		};
		pathoffer = {
			speaker = "Shadow";
			msg = "You linger still. Good. Let it be known - some deaths take time. Will you let the rot do your killing for you? Would you rather they never see the blade at all? Or... do you no longer need my name at all?";
			choices = {"I embrace the venom.", "Show me the blade.", "I am beyond a name."};
			endchoice = "...";
		};
		venomembrace = {
			speaker = "Shadow";
			msg = "Then strike softly, and let them rot from the inside. Slowly.";
			endchoice = "Bye";
		};
		bladeembrace = {
			speaker = "Shadow";
			msg = "Two blades, faster than they can follow. Buy the fangs, and disappear between the strikes.";
			endchoice = "Bye";
		};
		masterembrace = {
			speaker = "Shadow";
			msg = "Then there is nothing left to teach. You were never Faceless. You are the Faceless.";
			endchoice = "Bye";
		};
	};
	Isaac = {
		p1 = {
			speaker = "Isaac";
			msg = "Ah, greetings, enlightened one.";
			choices = {"Please teach me your ways."};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Isaac";
			msg = "Alright kid, that'll be 40 Money.";
			choices = {"I'll pay."};
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Isaac";
			msg = "Impressive work, my child.";
			endchoice = "Bye";
		};
		p4 = {
			speaker = "Isaac";
			msg = "You poor.";
			endchoice = "Bye";
		};
		no = {
			speaker = "Isaac";
			msg = "Sorry, my child, but you do not seem fit enough for training.";
			endchoice = "Bye";
		};
		max = {
			speaker = "Isaac";
			msg = "I have taught you all I can, my student.";
			endchoice = "Bye";
		};
	};
	["Ragash Al'vul"] = {
		p1 = {
			speaker = "Ragash Al'vul";
			msg = "Hm...";
			choices = {"I desire to learn the secrets of dragons."};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Ragash Al'vul";
			msg = "Hm... ok";
			choices = {"Here is 350 Money."};
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Ragash Al'vul";
			msg = "Good luck, young dragon.";
			endchoice = "Bye";
		};
		p4 = {
			speaker = "Ragash Al'vul";
			msg = "...";
			endchoice = "Bye";
		};
		no = {
			speaker = "Ragash Al'vul";
			msg = "Sorry, young dragon, but you do not seem fit enough for training.";
			endchoice = "Bye";
		};
		max = {
			speaker = "Ragash Al'vul";
			msg = "Continue walking the path, young dragon.";
			endchoice = "Bye";
		};
		nodragonspeech = {
			speaker = "Ancient Dragon";
			msg = "_The sleeping dragon does not respond to your words_";
			endchoice = "...";
		}
	};
	Gilderoy = {
		p1 = {
			speaker = "Gilderoy";
			msg = "Want a dye packet? (15 Money)";
			choices = {"I'll pay"};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Gilderoy";
			msg = "Please doing business.";
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Gilderoy";
			msg = "You don't have enough Money.";
			endchoice = "Bye";
		};
	};
	Ria = {
		p1 = {
			speaker = "Ria";
			msg = "Want a dye packet? (15 Money)";
			choices = {"I'll pay"};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Ria";
			msg = "Pleasure doing business.";
			endchoice = "Bye";
		};
		questfanari = {
			speaker = "Ria";
			msg = "Huh? Oh, from Fanari...? ...Thank you.";
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Ria";
			msg = "You don't have enough Money.";
			endchoice = "Bye";
		};
	};
	Fallen = {
		p1 = {
			speaker = "???";
			msg = "Wanna make a house?";
			choices = {"ok!"};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "???";
			msg = "...";
			endchoice = "Bye";
		};
		p3 = {
			speaker = "???";
			msg = "You aren't ready for this...";
			choices = {"Bye"};
		};
		p4 = {
			speaker = "???";
			msg = "Do you want to disband your house?";
			choices = {"Yes"};
			endchoice = "Bye";
		};
		p5 = {
			speaker = "???";
			msg = "Do you want to leave your house?";
			choices = {"Yes"};
			endchoice = "Bye";
		};
	};
	["Enibras "] = {
		p1 = {
			speaker = "Enibras";
			msg = "Is there anything you need?";
			choices = {"I want training."};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Enibras";
			msg = "This is how you do it.";
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Enibras";
			msg = "yessir.";
			endchoice = "Bye";
		};
		max = {
			speaker = "Enibras";
			msg = "go grip sum freshies.";
			endchoice = "Bye";
		};
		no = {
			speaker = "Enibras";
			msg = "How did you get here?";
			endchoice = "Bye";
		};
		poor = {
			speaker = "Enibras";
			msg = "you poor.";
			endchoice = "Bye";
		};
		askgate = {
			speaker = "Enibras";
			msg = "Is there anything you need?";
			choices = {"I want to leave this place."};
			enchoice = "Bye";
		};
	};
	Enibras = {
		p1 = {
			speaker = "Enibras";
			msg = "Would you like to serve under the _Abysswalker_ legion?";
			choices = {"..."};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Enibras";
			msg = "Go to the huge pit that the commonfolk refer to as _The Void_, after jumping in we will proceed with your training there.";
			choices = {"I want to become an Abysswalker."};
			endchoice = "Bye";
		};
		gotskill = {
			speaker = "Enibras";
			msg = "...";
			endchoice = "Bye";
		};
		max = {
			speaker = "Enibras";
			msg = "Go, head for _Ardors_ calls...";
			endchoice = "...";
		};
		no = {
			speaker = "Enibras";
			msg = "Wasted potential.";
			endchoice = "Bye";
		};
	};
	Regnier = {
		p1 = {
			speaker = "Regnier";
			msg = "Ah... You seem fit for training under the greatsword.";
			choices = {"Yes"};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Regnier";
			msg = "100 Money or _SCRAM_!";
			choices = {"I'll pay"};
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Regnier";
			msg = "Let's get started.";
			endchoice = "Bye";
		};
		max = {
			speaker = "Regnier";
			msg = "You seem fit to me.";
			endchoice = "Bye";
		};
		no = {
			speaker = "Regnier";
			msg = "Go play around somewhere else, pup.";
			endchoice = "Bye";
		};
		poor = {
			speaker = "Regnier";
			msg = "Do some slaying and return with the required money.";
			endchoice = "Bye";
		};
		sigilknight = {
			speaker = "Regnier";
			msg = "So... Jahovan sent you? Hmph. I guess you have the potential to learn a thing or two. Let's start from the basics.";
			choices = {"Teach me."};
			endchoice = "Bye";
		}
	};
	Jahovan = {
		firstmeet = {
			speaker = "Jahovan";
			msg = "Greetings, Sigil Knight.";
			choices = {"Who are you?"};
			endchoice = "Bye";
		};
		firstmeet2 = {
			speaker = "Jahovan";
			msg = "I am a Sigil Knight, I use various incantations to imbue magic on the Sword.";
			choices = {"I want to become a Vanguard."};
			endchoice = "...";
		};
		buy1 = {
			speaker = "Jahovan";
			msg = "Very well, the training will cost _350 Money_";
			choices = {"Alright"};
			endchoice = "Nevermind";
		};
		firstmeet3 = {
			speaker = "Jahovan";
			msg = "Seek out Regnier to gain groundwork for your training, and then return afterwards.";
			endchoice = "Bye";
		};
		returned = {
			speaker = "Jahovan";
			msg = "So, you've returned. You look bulkier than before.";
			choices = {"Please train me."};
			endchoice = "Bye";
		};
		firstquest = {
			speaker = "Jahovan";
			msg = "Hmm... The science district have been researching various monsters. Can you bring me a _Shrieker Eye_?";
			choices = {"Here you go."};
			endchoice = "Bye";
		};
		secondquest = {
			speaker = "Jahovan";
			msg = "This time, bring me a _Howler Fang_.";
			choices = {"Here you go."};
			endchoice = "Bye";
		};
		thirdquest = {
			speaker = "Jahovan";
			msg = "You've been doing great work so far. Return to me with an _Evil Eye_.";
			choices = {"Here you go."};
			endchoice = "Bye";
		};
		finalquest = {
			speaker = "Jahovan";
			msg = "This is the last step to your training. Return to me with a _Serpent Fang_.";
			choices = {"Here you go."};
			endchoice = "Bye";
		};
		goodjob = {
			speaker = "Jahovan";
			msg = "Great job coming back with what i asked for. You already know how expensive exports to the castle all the way over here are. _1000_ Money should be enough to cover the costs.";
			choices = {"Let's begin."};
			endchoice = "Bye";
		};
		poor = {
			speaker = "Jahovan";
			msg = "Training isn't cheap, young Vanguard.";
			endchoice = "...";
		};
		nothave = {
			speaker = "Jahovan";
			msg = "Return to me once you have what I need.";
			endchoice = "...";
		};
		no = {
			speaker = "Jahovan";
			msg = "Greetings.";
			endchoice = "Bye";
		};
		training = {
			speaker = "Jahovan";
			msg = "A quick learner, aren't you?";
			endchoice = "...";
		};
		max = {
			speaker = "Jahovan";
			msg = "Vanguard, your training is done, although, your work isn't over. There are many evils on this world of Gaia and it is your job to purge them.";
			endchoice = "...";
		};
	};
	Gawain = {
		p1 = {
			speaker = "Gawain";
			msg = "Want me to teach how to really handle a greatsword?";
			choices = {"Yes."};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Gawain";
			msg = "It'll cost you. (350 Silver)";
			choices  = {"I'll pay."};
			endchoice = "Bye";
		};
		no = {
			speaker = "Gawain";
			msg = "...";
			endchoice = "Bye"
		};
		poor = {
			speaker = "Gawain";
			msg = "Broke.";
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Gawain";
			msg = "There you go.";
			endchoice = "Bye"
		};
		max = {
			speaker = "Gawain";
			msg = "Find those scourges from altum, and eradicate them.";
			endchoice = "Bye"
		}
	};
	Source = {
		p1 = {
			speaker = "Hand of the source";
			msg = "Does one wish to offer to gather from the source?";
			choices = {"Sure, I will."};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Hand of the source";
			msg = "That is an impressive piece.";
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Hand of the source";
			msg = "Come back with a more dignitous contribution.";
			endchoice = "Bye";
		};
		p4 = {
			speaker = "Hand of the source";
			msg = "It's not been long enough, wait for the source's repletion.";
			endchoice = "Bye";
		};

	};
	Jagen = {
		p1 = {
			speaker = "Jagen";
			msg = "Welcome to the training hall.";
			choices = {"Please teach me."};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Jagen";
			msg = "You indeed look like one capable of receiving my lessons. I doubt I have to tell you that it comes at a high price, due to how expensive imports all the way to this castle are.";
			choices = {"Here is 350 Money."};
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Jagen";
			msg = "Excellent. Then we shall commence our training.";
			endchoice = "Bye";
		};
		p4 = {
			speaker = "Jagen";
			msg = "You don't have enough Money for me to train you.";
			endchoice = "Bye";
		};
		no = {
			speaker = "Jagen";
			msg = "You aren't ready for this.";
			endchoice = "Bye";
		};
		max = {
			speaker = "Jagen";
			msg = "Your work as a Sigil Knight is not yet over. You are responsible for upholding the order of this land!";
			endchoice = "Bye";
		};
		chargemastery = {
			speaker = "Jagen";
			msg = "It seems you don't know how to use your charge properly. Let me show you how it is done.";
			endchoice = "..."
		}
	};
	Rorschach = {
		p1 = {
			speaker = "Rorschach";
			msg = "I can offer you further education... Itl'll be 350 Money for these lessons.";
			choices = {"I'll pay."};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Rorschach";
			msg = "Listen for her call...";
			endchoice = "Bye";
		};
		poor = {
			speaker = "Rorschach";
			msg = "You lack the Money.";
			endchoice = "Bye";
		};
		no = {
			speaker = "Rorschach";
			msg = "You aren't ready for this.";
			endchoice = "Bye";
		};
		max = {
			speaker = "Rorschach";
			msg = "Serve our Mother' will faithfully.";
			endchoice = "Bye";
		};
	};
	Frank = {
		p1 = {
			speaker = "Frank";
			msg = "It seems you are bestowed upon with the brand of Freedom. I can teach you techniques of Our Freedom.";
			choices = {"..."};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Frank";
			msg = "Stay vigilant our free child.";
			endchoice = "...";
		};
		poor = {
			speaker = "Frank";
			msg = "Freedom comes at a price.";
			endchoice = "...";
		};
		no = {
			speaker = "Frank";
			msg = "Don't bother me.";
			endchoice = "...";
		};
		max = {
			speaker = "Frank";
			msg = "Go on then, that's all I've got for you.";
			endchoice = "...";
		};
	};
	Eldin = {
		p1 = {
			speaker = "Eldin";
			msg = "You seem worthy of my training, are you here for that? (350 Money)";
			choices = {"I'll pay."};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Eldin";
			msg = "...";
			endchoice = "Bye";
		};
		no = {
			speaker = "Eldin";
			msg = "You don't have enough Money.";
			endchoice = "Bye";
		};
	};
	Dreadhead = {
		p1 = {
			speaker = "Dreadhead";
			msg = "What... are you doing here, Vile creature..?";
			choices = {"Who are you, where am I?!"};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Dreadhead";
			msg = "You dare enter my home? Prepare to die.";
			endchoice = "Bye";
		};
	};
	Draug = {};
	Drake = {
		p1 = {
			speaker = "Drake";
			msg = "For _%60 Money%_, I can teach you everything about spying.";
			choices = {"I'll pay."};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Drake";
			msg = "Excellent.";
			endchoice = "Bye";
		};
		poor = {
			speaker = "Drake";
			msg = "If you do not have the money, I cannot help you.";
			endchoice = "Bye";
		};
		no = {
			speaker = "Drake";
			msg = "You aren't ready for this.";
			endchoice = "Bye";
		};
		max = {
			speaker = "Drake";
			msg = "Excellent work in training. You should seek out our _%Mother%_, she favours her more _well-behaved_ children.";
			endchoice = "Bye";
		};
		maxfreedom = {
			speaker = "Drake";
			msg = "Excellent work in training. You should seek out our _%Mother%_, she favours her more _well-behaved_ children.";
			choices = {"I disobeyed the mother."};
			endchoice = "Bye";
		};
		freedom = {
			speaker = "Drake";
			msg = "... Tales spoken of an order of spies hiding within the depths of the _Sunken Passage_.";
			choices = {"Where can i find them?"};
			endchoice = "Bye";
		};
		freedom2 = {
			speaker = "Drake";
			msg = "Only having heard rumors, they have taken over the Fortress of Lights, and have been hiding within it's cracks. I'm afraid that's all I can help with.";
			endchoice = "Thank you";
		}
	};
	["Lab Assistant"] = {
		p1 = {
			speaker = "Lab Assistant";
			msg = "Oh hello! You came from the wastes above then?";
			choices = {"Yes, what is this place?"};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Lab Assistant";
			msg = "Oh, just a humble place of study. Would you like to participate in a experiment?";
			choices = {"Yes"};
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Lab Assistant";
			msg = "Wonderful! Are you ready to begin?";
			choices = {"I am ready."};
			endchoice = "Bye";
		};
		no = {
			speaker = "Lab Assistant";
			msg = "It seems you aren't what I am looking for...";
			endchoice = "Bye";
		};
		max = {
			speaker = "Lab Assistant";
			msg = "Wonderful... A Perfect Construct...";
			endchoice = "Bye";
		};
	};
	Cu = {
		p1 = {
			speaker = "Cu";
			msg = "Only snakes survive in the fightning pits... Are you here to learn? (45 Money)";
			choices = {"Yeah."};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Cu";
			msg = "Deflect, then strike!";
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Cu";
			msg = "I don't work for free, friend.";
			endchoice = "Bye";
		};
		max = {
			speaker = "Cu";
			msg = "I think you're ready for the pits.";
			endchoice = "Bye";
		};
		no = {
			speaker = "Cu";
			msg = "...";
			endchoice = "Bye";
		};
	};
	["Big Hoss"] = {
		p1 = {
			speaker = "Big Hoss";
			msg = "Not half bad, I'll need 350 Money for a McChicken though.";
			choices = {"Alright."};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Big Hoss";
			msg = "I'll go to McDonald's later.";
			endchoice = "Bye";
		};
		no = {
			speaker = "Big Hoss";
			msg = "Garbage.";
			endchoice = "Bye";
		};
		beads = {
			speaker = "Big Hoss";
			msg = "_That's all I've got for you, take these beads to remember your training._";
			endchoice = "Thanks"
		};
		max = {
			speaker = "Big Hoss";
			msg = "No skills? No problem.";
			endchoice = "Bye";
		};
	};
	Atlas = {
		p1 = {
			speaker = "Atlas";
			msg = "Hmm... we don't get very many newcomers around these parts... Were you interested in learning a few tricks?";
			choices = {"Yes."};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Atlas";
			msg = "Great, that'll be _%350 silver%_.";
			choices = {"I'll pay."};
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Atlas";
			msg = "Perfect!";
			endchoice = "Bye";
		};
		poor = {
			speaker = "Atlas";
			msg = "Hey man, even the ocean has low tides sometime.";
			endchoice = "Bye";
		};
		no = {
			speaker = "Atlas";
			msg = "I don't think you can handle the weight of the ocean, my friend.";
			endchoice = "Bye";
		};
		max = {
			speaker = "Atlas";
			msg = "You're a natural!";
			endchoice = "Bye";
		};
	};
	Fang = {
		p1 = {
			speaker = "Fang";
			msg = "Not half bad, I'll need 350 Money for a McChicken though.";
			choices = {"Alright."};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Fang";
			msg = "I'll go to McDonald's later.";
			endchoice = "Bye";
		};
		no = {
			speaker = "Fang";
			msg = "Garbage.";
			endchoice = "Bye";
		};
		max = {
			speaker = "Fang";
			msg = "No skills? No problem.";
			endchoice = "Bye";
		};
		pathdone = {
			speaker = "Fang";
			msg = "You already picked your dragon's flavor. Don't get greedy.";
			endchoice = "Bye";
		};
		pathoffer = {
			speaker = "Fang";
			msg = "Alright, you've learned everything I know how to teach. One more thing though - what's your dragon's flavor?";
			choices = {"I embrace the storm", "I embrace the ember", "I embrace the abyss"};
			endchoice = "...";
		};
		stormherald = {
			speaker = "Fang";
			msg = "Ha! Lightning breath. Try not to zap yourself.";
			endchoice = "Bye";
		};
		emberwyrm = {
			speaker = "Fang";
			msg = "Fire, huh? Bold. Try not to burn the McChicken.";
			endchoice = "Bye";
		};
		abyssalwyrm = {
			speaker = "Fang";
			msg = "The abyss. Edgy. I respect it.";
			endchoice = "Bye";
		};
	};
	["Soul Master"] = {
		p1 = {
			speaker = "Soul Master";
			msg = "Do you wish to enter the depths of your own soul?";
			choices = {"Please teach me."};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Soul Master";
			msg = "Not half bad, I'll need 1000 Money and a piece of your soul for a McChicken though...";
			choices = {"Let's begin."};
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Soul Master";
			msg = "You can't afford this..";
			endchoice = "Bye";
		};
		max = {
			speaker = "Soul Master";
			msg = "Naww Jit Trippin'";
			endchoice = "Bye";
		};
	};
	Blacksmith = {
		p1 = {
			speaker = "Blacksmith";
			msg = "Need anything?";
			choices = {"Can you enchant my weapon?", "Can you add a second, permanent enchant?"};
			endchoice = "Bye";
		};
		p1nosecond = {
			speaker = "Blacksmith";
			msg = "Need anything?";
			choices = {"Can you enchant my weapon?"};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Blacksmith";
			msg = "I can enhance your weapon for 100 Money and a gem.";
			choices = {"Here."};
			endchoice = "Bye";
		};
		p2second = {
			speaker = "Blacksmith";
			msg = "A second enchant is permanent, it can never be removed or replaced. I'll need a Ruby, Opal, Emerald, Sapphire, or Diamond, plus 1,000 Money.";
			choices = {"Add it."};
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Blacksmith";
			msg = "Enchanted yo musty weapon.";
			endchoice = "Bye";
		};
		p3second = {
			speaker = "Blacksmith";
			msg = "There. That second enchant is bonded to you for good now.";
			endchoice = "Bye";
		};
		poor = {
			speaker = "Blacksmith";
			msg = "You can't afford this.";
			endchoice = "Bye";
		};
		no = {
			speaker = "Blacksmith";
			msg = "SHOW GEM";
			endchoice = "Bye";
		};
		wronggem = {
			speaker = "Blacksmith";
			msg = "That won't work for a second enchant. I need a Ruby, Opal, Emerald, Sapphire, or Diamond.";
			endchoice = "Bye";
		};
	};
	BlacksmithAdvanced = {
		p2 = {
			speaker = "Blacksmith";
			msg = "I can enhance your weapon for 30,000 Money, however, you will not lose the enchantment gem.";
			choices = {"Here."};
			endchoice = "Bye";
		};
	};
	Steve = {
		p1 = {
			speaker = "Steve";
			msg = "Do you want to pass through? That'll be 10 Money.";
			choices = {"I'll pay."};
			endchoice = "Bye";
		};
		bought = {
			speaker = "Steve";
			msg = "Very well, I wish you the best luck on your journey.";
			endchoice = "Bye";
		};
		poor = {
			speaker = "Steve";
			msg = "You don't have enough Money";
			endchoice = "Bye";
		};
		no = {
			speaker = "Steve";
			msg = "...";
			endchoice = "Bye";
		};
	};
	Quinno = {
		p1 = {
			speaker = "Quinno";
			msg = "Would you like to learn an advanced version of your spell?";
			choices = {"Yes, please advance my knowledge of magic."};
			endchoice = "Bye";
		};

	};
	Pawnbroker = {};
	Tlachta = {
		p1 = {
			speaker = "Tlachta";
			msg = "Would you like to learn how to enhance your nature magic?";
			choices = {"Yes"};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Tlachta";
			msg = "Magnificent.";
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Tlachta";
			msg = "My teachings come at a price.";
			endchoice = "Bye";
		};
		no = {
			speaker = "Tlachta";
			msg = "A waste.";
			endchoice = "Bye";
		};
		max = {
			speaker = "Tlachta";
			msg = "I've taught you all I can.";
			endchoice = "Bye";
		};
	};
	Fungratia = {
		p1 = {
			speaker = "Fungratia";
			msg = "...Oh? Have you come to learn? To become a florist?";
			choices = {"Yes."};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Fungratia";
			msg = "Very well.";
			endchoice = "Bye";
		};
		no = {
			speaker = "Fungratia";
			msg = "...";
			endchoice = "Bye";
		};
		beads = {
			speaker = "Fungratia";
			msg = "Exquisite...";
			endchoice = "Bye"
		};
		max = {
			speaker = "Fungratia";
			msg = "Spread beauty across the lands...";
			endchoice = "Bye";
		};
	};
	Grimtooth ={
		p1 = {
			speaker = "Grimtooth";
			msg = "Hm? Oh... It seems my humble abode has a new visitor. Welcome!";
			choices = {"What is this place?"};
			endchoice = "...";
		};
		p2 = {
			speaker = "Grimtooth";
			msg = "It is but an unassuming place of study.";
			choices = {"What are you doing here?"};
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Grimtooth";
			msg = "I'm researching _Howlers_. The best I could do so far is to transform myself into one.";
			choices = {"Could you transform me?"};
			endchoice = "Bye";
		};
		p4 = {
			speaker = "Grimtooth";
			msg = "Sure, if you insist. Bring me a _Lannis Amulet_, and a _Howler Friend_.";
			endchoice = "Very well.";
		};
		howler = {
			speaker = "Grimtooth";
			msg = "Fellow Howler, spread carnage upon this world.";
			endchoice = "Very well.";
		};
		back = {
			speaker = "Grimtooth";
			msg = "Welcome back. Have you found a _Lannis Amulet_ or a _Howler Friend_?";
			choices = {"Here"};
			endchoice = "...";
		};
		noitem = {
			speaker = "Grimtooth";
			msg = "You aren't holding anything...";
			endchoice = "...";
		};
		backhf = {
			speaker = "Grimtooth";
			msg = "Welcome back. Have you found a _Lannis Amulet_ yet?";
			choices = {"Here"};
			endchoice = "...";
		};
		backlannis = {
			speaker = "Grimtooth";
			msg = "Welcome back. Have you found a _Howler Friend_ yet?";
			choices = {"Here"};
			endchoice = "...";
		};
		turnedinlannis = {
			speaker = "Grimtooth";
			msg = "Great! Now I just need a _Howler Friend_.";
			endchoice = "Very well.";
		};
		turnedinhowler = {
			speaker = "Grimtooth";
			msg = "Great! Now I just need a _Lannis Amulet_.";
			endchoice = "Very well.";
		};
		finishedpart1 = {
			speaker = "Grimtooth";
			msg = "Amazing work. I'm afraid to say this, but the transformation comes at a cost of Knowledge. _(10 insight)_";
			choices = {"Very well"};
			endchoice = "Bye";
		};
		noinsight = {
			speaker = "Grimtooth";
			msg = "If you aren't on the bright side, you could've just said so.";
			endchoice = "...";
		};
		finishedpart2 = {
			speaker = "Grimtooth";
			msg = "Now you're a fellow howler!";
			endchoice = "...";
		};
		gottensmarter = {
			speaker = "Grimtooth";
			msg = "Oh... You're back. Have you gotten any smarter? (10 insight)";
			choices = {"Yes"};
			endchoice = "...";
		}
	};

	Eslaf = {
		p1 = {
			speaker = "Eslaf";
			msg = "Oh, hello!";
			choices = {"Who are you?","What is this place?"};
			endchoice = "Bye";
		};
		whoru = {
			speaker = "Eslaf";
			msg = "Ah, just a priest to our lord, the Flame. Perhaps you seek redemption?";
			choices = {"Redemption?"};
			endchoice = "Bye";
		};
		whatdisplace = {
			speaker = "Eslaf";
			msg = "The Temple of the Flame, perhaps you seek redemption?";
			choices = {"Redemption?"};
			endchoice = "Bye";
		};
		redemption = {
			speaker = "Eslaf";
			msg = "Yes, redemption... Throw yourself into the flames, accept judgement, and begin anew...";
			endchoice = "Bye";
		};
	};


	Dasher = {
		p1 = {
			speaker = "Dasher";
			msg = "Found your way up here, huh? You must really know your way around.";
			choices = {"Who are you?"};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Dasher";
			msg = "The name's Dasher. I recently figured out the layout to this strange place.";
			choices = {"What are you doing up here?"};
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Dasher";
			msg = "Rumors of the treasures hiding in this mountain castle have echoed all the way to the town that I came from. After hearing about it, I couldn't help but come see for myself.";
			choices = {"...So you're a thief, then?"};
			endchoice = "Bye";
		};
		p4 = {
			speaker = "Dasher";
			msg = "You got it. Back home, we're the poorest family in the village. It was a stressful life, until I decided to set out on an adventure and leave it all behind.";
			choices = {"Can you teach me some thief tricks?","Anything I should know about this"};
			endchoice = "Bye";
		};
		thieftricks = {
			speaker = "Dasher";
			msg = "'Fraid not. I can hardly say I'm good at what I do. if you're looking to learn, I last saw Fabiana in the mountains north of this town.";
			endchoice = "Bye";
		};
		knowabout = {
			speaker = "Dasher";
			msg = "Sure. Are you proud of finding the way up here? You shouldn't be, friend. The real secrets lie down below.";
			endchoice = "Bye";
		};
	};

	Currin = {
		p1 = {
			speaker = "Currin";
			msg = "Here for a sword or a spear, eh? Have a look around, then...";
			choices = {"Are you alright?"};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Currin";
			msg = "I haven't been able to keep a straight mind at work recently, is all.";
			choices = {"Did something happen?"};
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Currin";
			msg = "I was venturing into the Sunken Passage and saw something unforgettable. It was disgusting, crazy. The mere sight of it made me sick to my stomach immediately.";
			choices = {"Such a thing exists in this place?"};
			endchoice = "Bye";
		};
		p4 = {
			speaker = "Currin";
			msg = "Yes... Before, I had only heard rumors of them. I foolishly believed that my luck was too high to run into one, but...";
			choices = {"Them?"};
			endchoice = "Bye";
		};
		p5 = {
			speaker = "Currin";
			msg = "These crawling, one-eyed monsters... If you plan to travel deep into this forest, I would stay on my guard if I were you.";
			endchoice = "Bye";
		};
	};

	Eil = {
		p1 = {
			speaker = "Eil";
			msg = "Oh? Does one seek healing?";
			choices = {"Yes.","No.","What is this place?"};
			endchoice = "Bye";
		};
		no = {
			speaker = "Eil";
			msg = "Ah, then perhaps one does not understand that all must be healed.";
			endchoice = "Bye";
		};
		yes = {
			speaker = "Eil";
			msg = "Then one must find our savior. The Prince is currently off performing miracles elsewhere.";
			endchoice = "Bye";
		};
		whatisthisplace = {
			speaker = "Eil";
			msg = "A place to give thanks to our holy patron. This holy ground was once protected by the Church Knights... Alas, they have all but disappeared.";
			choices = {"Church Knights? What are those?"};
			endchoice = "Bye";
		};
		whatarethose = {
			speaker = "Eil";
			msg = "A holy order of divine justice, these knights would strike down any heretic of our holy church. Sadly, the Sanctum Spear, the symblom of order, was lost... Perhaps if it were found, the order could be reforged... Yes... Hehe...";
			endchoice = "Bye";
		};
	};

	Mirror = {
		p1 = {
			speaker = "The Prince";
			msg = "...";
			choices = {"Look closely"};
			endchoice = "Leave";
		};
		reqsmet = {
			speaker = "The Prince";
			msg = "Child of mine. You distinguish yourself from the flock of your fellows. Lay your mind and blade to me, become my voice.";
			choices = {"Offer your mind","Offer your blade","Offer your soul"};
			endchoice = "Leave";
		};
		reqsnotmet = {
			speaker = "The Prince";
			msg = "...";
			endchoice = "Leave";
		};
		gotthing = {
			speaker = "The Prince";
			msg = "When the time comes for you to draw your last breath, your soul will rejoice with mine.";
			endchoice = "Leave";
		};
	};


	Dirbys = {
		Normal1 = {
			speaker = "Dirbys";
			msg = "I will not be selling anything as I am still setting up my wares. But do any of them catch your eye?";
			choices = {"The bust.","The tower.","The skull.","The figurine."};
			endchoice = "Bye";
		};
		TheBust = {
			speaker = "Dirbys";
			msg = "I found this at the ruins nearby. I date it to be around four hundred years old based on the wearing of the details.";
			endchoice = "Bye";
		};
		TheTower = {
			speaker = "Dirbys";
			msg = "I purchased this from a skilled artisan at Sentinel. I hear that it's modelled after a real tower near the Sea of Dust.";
			endchoice = "Bye";
		};
		TheSkull = {
			speaker = "Dirbys";
			msg = "You've a good eye, I carved this myself, for practice. However, I'm still working on it, so for now, it will not be sold. ";
			endchoice = "Bye";
		};
		TheFigurine = {
			speaker = "Dirbys";
			msg = "A... woodworking friend of mine created this. Before his untimely death, I heard that his creations became increasingly grotesque. This is one of them.";
			endchoice = "Bye";
		};
	};

	Monk = {
		p1 = {
			speaker = "Monk";
			msg = "Hmm? What might you need?";
			choices = {"How do I get stronger?","How can I earn Money?"};
			endchoice = "Bye";
		};
		earnMoney = {
			speaker = "Monk";
			msg = "Money... You can ask around and see if anyone needs help, they'll often reward you with Money. Other than that, you could try your luck at treasure hunting and selling your gains to Merchants and Pawnbrokers at towns.";
			choices = {"Any other options?","How do I get stronger?"};
			endchoice = "Bye";
		};
		anyotheroptions = {
			speaker = "Monk";
			msg = "Well, you can also try your hand at Bounty Hunting, turning in criminals to Bounty Hunters at most towns. Naturally, this is a more dangerous option.";
			choices = {"That's all for now."};
			endchoice = "Bye";
		};
		stronger = {
			speaker = "Monk";
			msg = "Stonger? Generally, you'll have to hone yourself be engaging in combat with others. When you're experienced enough, seek training from experts of your chosen caft to further yourself.";
			choices = {"Anything else?","How can I earn Money?"};
			endchoice = "Bye";
		};
		anythinelse1 = {
			speaker = "Monk";
			msg = "At a certain level, mere skill won't be enough. Most masters won't bother you unless you're of great renown, Aligning with their ideals.";
			choices = {"How can I get them to acknowledge me?"};
			endchoice = "Bye";
		};
		acknolwedgeme = {
			speaker = "Monk";
			msg = "For Orderly masters, you'll gain a good reputation by purging the land of monsters or hunting criminals.";
			choices = {"Αnything else?","That's all for now."};
			endchoice = "Bye";
		};
		anythinelse2 = {
			speaker = "Monk";
			msg = ".....For Chaotic masters, you'll have to... kill people.. Naturally, I hope for you to pursue the Orderly path. Is there anything else you'd like to know?";
			choices = {"That's all for now."};
			endchoice = "Bye";
		};
		thatsit = {
			speaker = "Monk";
			msg = "Any time.";
			endchoice = "Bye";
		};
	};

	["Baby Yeti"] = {
		p1 = {
			speaker = "Baby Yeti";
			msg = "Mungo!";
			endchoice = "Bye";
		};
	};

	Nero = {
		p1 = {
			speaker = "Nero";
			msg = "Hmm... Ah, I see now...";
			choices = {"Hey, need any help?"};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Nero";
			msg = "Oh, hey. Yeah, I've been doing some research, and I've run out of materials. If you can get me a _Desert Mist_, I'd greatly appreciate it.";
			choices = {"I got you"};
			endchoice = "Bye";
		};
		accepted = {
			speaker = "Nero";
			msg = "Alright. I'll be waiting right here.";
			endchoice = "Alright";
		};
		returnednodesertmist = {
			speaker = "Nero";
			msg = "Oh, hey. Have you found the Desert Mist?";
			endchoice = "No, sorry";
		};
		returneddesertmist = {
			speaker = "Nero";
			msg = "Oh, hey. Have you found the Desert Mist?";
			choices = {"Here you go"};
			endchoice = "Bye";
		};
		thankyou = {
			speaker = "Nero";
			msg = "Great, thank you so much!";
			endchoice = "Anytime";
		};
		healerdone = {
			speaker = "Nero";
			msg = "Great, thank you so much!";
			choices = {"Anytime"};
		};
		tysm = {
			speaker = "Nero";
			msg = "Hey, thanks for the Desert Mist earlier.";
			endchoice = "No problem";
		};
		notquest = {
			speaker = "Nero";
			msg = "Hmm... Ah, I see now... Huh? Please don't disturb me.";
			endchoice = "Bye";
		};
		confused = {
			speaker = "Nero";
			msg = "...";
			endchoice = "...";
		};
	};

	Laputa = {
		p1 = {
			speaker = "Laputa";
			msg = "Welcome to the Castle in the Sky.";
			choices ={"What is this place?"};
			endchoice = "Bye";
		};
		whatthisplaceagin = {
			speaker = "Laputa";
			msg = "Sit upon the Throne and you may summon a fellow house member by calling their full name.";
			endchoice = "Bye";
		};
	};

	Lerase = {
		p1 = {
			speaker = "Lerase";
			msg = "Hmm...";
			endchoice = "Bye";
		};
	};

	["Monster Officer"] = {
		p1 = {
			speaker = "Monster Officer";
			msg = "Ah hello.. Looking to your hands dirty?";
			choices ={"I'm looking for a job."};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Monster Officer";
			msg = "Go check out the Crypt near Sentinel. But be prepared...";
			endchoice = "Bye";
		};
	};

	Rita = {
		p1 = {
			speaker = "Rita";
			msg = "...";
			endchoice = "Bye";
		};
	};

	Reneri = {
		p1 = {
			speaker = "Reneri";
			msg = "...";
			endchoice = "Bye";
		};
	};

	TransFlag = {
		p1 = {
			speaker = "";
			msg = "Trans rights are human rights.";
			endchoice = "Bye";
		};
	};

	Silas = {
		p1 = {
			speaker = "Silas";
			msg = "Here to peruse some of my fine cowls?";
			endchoice = "Bye";
		};
	};

	Mitch = {
		p1 = {
			speaker = "Mitch";
			msg = "Hey! Listen, that food shop, man. It's good. It's really good.";
			choices = {"Oh, Dorgan's?"};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Mitch";
			msg = "Yeah, Dorgan's. The one run by the lizard.";
			choices = {"I'll give it a try."};
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Mitch";
			msg = "You definitely should! The food is crazy good. I wonder what ingredients Dorgan keeps back in that kitchen of his?";
			endchoice = "Bye";
		};
	};

	Hendrick = {
		p1 = {
			speaker = "Hendrick";
			msg = "I wonder what a Turnip tastes like...";
			endchoice = "Bye";
		};
	};

	Dew = {
		p1 = {
			speaker = "Dew";
			msg = "My father owns this Speakeasy.";
			choices = {"He's weak"};
			endchoice = "Bye";
		};
		heaint = {
			speaker = "Dew";
			msg = "No he's not!";
			choices = {"hes TRASH"};
			endchoice = "Bye";
		};
		stopbullu = {
			speaker = "Dew";
			msg = "stop bullying ):";
			endchoice = "Bye";

		};
	};

	Hespe = {
		notquest = {
			speaker = "Hespe";
			msg = "Welcome to the Tower on the Wall.";
			endchoice = "Bye";
		};
		p1 = {
			speaker = "Hespe";
			msg = "Welcome to the Tower on the Wall.";
			choices = {"A man told me to bring this to you."};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Hespe";
			msg = "... Thank you";
			endchoice = "...";
		};
		healerdone = {
			speaker = "Hespe";
			msg = "... Thank you";
			choices = {"..."};
		};
		finishedquest = {
			speaker = "Hespe";
			msg = "...";
			endchoice = "...";
		};
	};

	Fir = {
		p1 = {
			speaker = "Fir";
			msg = "Ugh... where is it at? It was supposed to arrive this morning...";
			choices = {"What's wrong?"};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Fir";
			msg = "It's never taken this long for a shipment to arrive before. I'm getting impatient!";
			endchoice = "Bye";
		};
		withquestp2 = {
			speaker = "Fir";
			msg = "It's never taken this long for a shipment to arrive before. I'm getting impatient!";
			choices = {"Do you mean Brom?"};
			endchoice = "Bye";
		};
		withquestp3 = {
			speaker = "Fir";
			msg = "What? Is that the man in charge of the shipment? Do you know something?";
			choices = {"Yeah, I saw him earlier."};
			endchoice = "Bye";
		};
		withquestp4 = {
			speaker = "Fir";
			msg = "Are you sure? I've been waiting on that shipment all day! Where in the world is he?!";
			choices = {"I saw him napping on the job.","He broke down. There will be a delay."};
			endchoice = "Bye";
		};
		withquestp5 = {
			speaker = "Fir";
			msg = "Is that what's going on? It's frustrating, but I guess it can't be helped. The path that leads to this village can be trouble for heavy loads. Thanks for passing on the message!";
			endchoice = "Bye";
		};
		afterquest = {
			speaker = "Fir";
			msg = "Brom, hm? I hope he arrives soon.";
			endchoice = "Bye";
		};
		nappingonjob = {
			speaker = "Fir";
			msg = "He's {NAPPING}? I'M MAKING SURE TO TELL HIS BOSS AHHH I HATE BROM!";
			endchoice = "Bye";
		};
	};


	Brom = {
		p1 = {
			speaker = "Brom";
			msg = "This rocky terrain is nearly impassable for a carriage! How do they expect me to reach town?";
			choices = {"You're a merchant?"};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Brom";
			msg = "Yeah, name's Brom. If you see a lady named Fir, can you tell her the shipment is gonna be a little late?";
			choices = {"If I see her."};
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Brom";
			msg = "Thanks. I owe you one!";
			endchoice = "Bye";
		};
		questalreadytaken = {
			speaker = "Brom";
			msg = "Fir should be in the town up ahead. If you see her, make sure to let her know I broke down!";
			endchoice = "Bye";
		};
		finishedquest = {
			speaker = "Brom";
			msg = "You told her? Great!";
			endchoice = "Bye";
		};
	};

	Lachesis = {
		p1 = {
			speaker = "Lachesis";
			msg = "_Ugh!_ I just can't remember anything today, and I'm running out of time!";
			choices = {"What's the matter?"};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Lachesis";
			msg = "Oh! N-No.. I'm sorry. I didin't mean to get in your way."; 
			choices = {"It's no problem. Can I help?"};
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Lachesis";
			msg = "It's the Tespian Elixir. I can't recall the last ingredient in the recipe! How did it go again? Let's see... Moss Plant, Moss Plant, Lava Flower, and...";
			choices = {"Is it a Scroom?"};
			endchoice = "Bye";
		};
		p4 = {
			speaker = "Lachesis";
			msg = "A Scroom! Yes, that's it! I was forgetting the Scroom!";
			choices = {"Glad to help."};
			endchoice = "Bye";
		};
		p5 = {
			speaker = "Lachesis";
			msg = "Thank you so much! Thanks to you, I might actually be able to prepare it before my mother's birthday.";
			endchoice = "Bye";
		};
		questfinished = {
			speaker = "Lachesis";
			msg = "Thanks for the help earlier.";
			endchoice = "Bye";

		};
	};

	Rowan = {
		p1 = {
			speaker = "Rowan";
			msg = "Why, hello there. I didin't expect to find another visitor here.";
			choices = {"What's this place?"};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Rowan";
			msg = "I'm not sure myself, but it seems like a fort abandoned long ago. Perfect.";
			choices = {"Why was it abandoned?"};
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Rowan";
			msg = "Did you see the path up to this place? Shattered, completely. It's unviable for habitation. What is this fort even guarding? Was it meant to guard something?";
			choices = {"Sounds like a mystery to me."};
			endchoice = "Bye";

		};
		p4 = {
			speaker = "Rowan";
			msg = "Right? There has to be more to this place.";
			choices = {"So.. what are you doing here?"};
			endchoice = "Bye";
		};
		p5 = {
			speaker = "Rowan";
			msg = "Heh, just scouting out some new areas to possibly hide out in. Society doesn't take kindly to those with red eyes...";
			endchoice = "Bye";
		};
	};

	Yaalda = {
		p1 = {
			speaker = "Koris";
			msg = "Ah, looking to become a smith? Help your friends and make Money doing it! Haha!";
			choices ={"Yeah."};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Koris";
			msg = "Experiment by yourself a little more with Bronze, little rookie!";
			endchoice = "Bye";
		};
	};
	Koris = {
		Normal1 = {
			speaker = "Koris";
			msg = "Ah, looking to become a smith? Help your friends and make Money doing it! Haha!";
			choices ={"Yeah."};
			endchoice = "Bye";
		};
		NotEnoughBronzeWeapons = {
			speaker = "Koris";
			msg = "Experiment by yourself a little more with Bronze, little rookie!";
			endchoice = "Bye";
		};
	};

	Healer = {
		healerstep1done = {
			speaker = "...";
			msg = "_You feel overflowing with kindness!_";
			endchoice = "...";
		};
	};

	Alana = {
		p1 = {
			speaker = "Alana";
			msg = "Oh, Ellie...";
			choices = {"What's wrong?"};
			EndChoice = "Bye";
		};
		whatswrong = {
			speaker = "Alana";
			msg = "Who are you and what are you doing in my house?";
			choices = {"I'm here to help."};
			endchoice = "Bye";
		};
		whatswrongnoquest = {
			speaker = "Alana";
			msg = "Who are you and what are you doing in my house?";
			endchoice = "My apologies";
		};
		imheretohelp = {
			speaker = "Alana";
			msg = "...Well, I'm Alana and this is my daughter, Ellie. She's recently fallen sick - I fear she may die soon.";
			choices ={"I'm sorry to hear that."};
			endchoice = "Bye";
		};
		srytohear = {
			speaker = "Alana";
			msg = "...It pains me to ask this of someone I've just met, but would you be willing to look for help in my stead? I-I can't leave her side.";
			choices ={"Of course."};
			endchoice = "Bye";
		};
		ty = {
			speaker = "Alana";
			msg = "Oh, thank you so much! I'll be waiting.";
			endchoice = "Bye";
		};

		No = {
			speaker = "Alana";
			msg = "...I understand.";
			endchoice = "Bye";
		};

		nopleasehelp = {
			speaker = "Alana";
			msg = "Ellie's condition has been worsening... Please. Won't you help?";
			choices ={"Οf course."};
			endchoice = "Bye";
		};
		anynewsnopot = {
			speaker = "Alana";
			msg = "Hello again. Any news?";
			endchoice = "Not yet";
		};
		anynewswithhealthpot = {
			speaker = "Alana";
			msg = "Hello again. Any news?";
			choices ={"Would this potion be of any use?"};
			endchoice = "Bye";
		};
		questdonehealthpotion = {
			speaker = "Alana";
			msg = "Is that a _Health Potion_? Oh, bless your soul! Ellie will surely get better.";
			endchoice = "Any time";
		};
		healerdone = {
			speaker = "Alana";
			msg = "Is that a _Health Potion_? Oh, bless your soul! Ellie will surely get better.";
			choices = {"Any time"};
		};

		hurryplz = {
			speaker = "Alana";
			msg = "Please, hurry... Ellies condition seems to be worsening.";
			endchoice = "Bye";
		};
		tysm = {
			speaker = "Alana";
			msg = "Thanks for the help earlier";
			endchoice = "Bye";
		};
	};

	Reynauld = {
		p1 = {
			speaker = "...";
			msg = "_A man lays - barely breathing_";
			choices = {"Give a Health Potion"};
			endchoice = "..."
		};
		p2 = {
			speaker = "...";
			msg = "Please... Give Hespe my dagger... My name is... Reynauld...";
			choices = {"I will return it"};
			endchoice = "..."
		};
		p3 = {
			speaker = "Reynauld";
			msg = "Thank... you... _dies_";
			endchoice = "..."
		};
		no = {
			speaker = "...";
			msg = "_A man lays - barely breathing_";
			endchoice = "..."
		};
	};

	Ellie = {
		p1 = {
			speaker = "Ellie";
			msg = "...";
			endchoice = "Bye";
		};
	};

	Naimere = {
		notallowed = {
			speaker = "???";
			msg = "...";
			endchoice = "Nevermind"
		};
		bmquest = {
			speaker = "???";
			msg = "You have True Strength.";
			choices = {"What?"};
			endchoice = "..."
		};
		bmquest1 = {
			speaker = "Naimere";
			msg = "I am Naimere. I used to be a warrior just like you, but with times passing - I've given up on that life.";
			choices = {"Alright?"};
			endchoice = "..."
		};
		bmquest2 = {
			speaker = "Naimere";
			msg = "Simply put, I see potential in you. As far as I can tell, you are pretty lost on what to do next.";
			choices = {"..."};
		};
		bmquest3 = {
			speaker = "Naimere";
			msg = "If you are willing to give yourself up for more power, I'd recommend by looking for obelisks around Gaia. Usually, they are completely useless to an average person, but, someone of your stature may be able to find a use for them?";
			choices = {"Understood"};
			endchoice = "I'll think about it more";
		};
		bmquest4 = {
			speaker = "Naimere";
			msg = "Great! I saw one in the emerald cliffs' cave, that should get you started. As far as I know there are 4 of these obelisks around Gaia, so, good luck! Oh, also, these obelisks are only in the Desert and Forest areas of the world.";
			endchoice = "Thanks";
		};
		notfinished = {
			speaker = "Naimere";
			msg = "Are you lost? Aren't you seeking power? Go find the obelisks. They are only in the Desert and Forest areas of the world.";
			endchoice = "...";
		};
		finished = {
			speaker = "Naimere";
			msg = "Now you look like one with a purpose! I believe you should die by the sword, just as you live by it. Give yourself up.";
			endchoice = "...";
		};
		notfinished2 = {
			speaker = "Naimere";
			msg = "Are you scared? Don't you think with power comes a sense of sacrifice of self?";
			endchoice = "...";
		};
		finishededict = {
			speaker = "Naimere";
			msg = "A true warrior...";
			endchoice = "...";
		}
	};

	["Miner John"] = {
		Normal1 = {
			speaker = "Miner John";
			msg = "Some Rigan punks rank away from me earlier after stealing my loot... Say, need any stones?";
			choices ={"...Stones?"};
			endchoice = "Bye";
		};
		whatstones = {
			speaker = "Miner John";
			msg = "Stones! (_10 Money_)";
			choices ={"I'll take some stones."};
			endchoice = "Bye";
		};
		iwilltake = {
			speaker = "Miner John";
			msg = "A stone a day keeps the loggers away!";
			endchoice = "Bye";
		};
		poor = {
			speaker = "Miner John";
			msg = "THIS IS A PEBBLE SHOP NOT A CHARITY!";
			endchoice = "Bye";
		};
	};

	Informant = {
		p1 = {
			speaker = "Informant";
			msg = "...";
			endchoice = "Bye";
		};
	};

	["Old Man"] = {
		p1 = {
			speaker = "Old Man";
			msg = "I could really use some grog...";
			choices = {"Need any help?"};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Old Man";
			msg = "Me? No... I am not one deserving of help. I once had a dream...";
			choices = {"A dream?"};
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Old Man";
			msg = "Yes, a dream... It is one of kindness. I don't want to share too much about it, kid.";
			choices = {"Please? I'm interested"};
			endchoice = "Bye";
		};
		p4 = {
			speaker = "Old Man";
			msg = "I can feel that you are one that is not kind. If you can prove your kindness to me by spreading charitable acts, I will let you in on my secret.";
			endchoice = "Very well";
		};
		notquest = {
			speaker = "???";
			msg = "_The old man sits eerily, minding his own business..._";
			endchoice = "...";
		};
		cameback = {
			speaker = "Old Man";
			msg = "You're showing your face to me so soon - expecting something new? That's how I know that you are still not kind enough. Go.";
			endchoice = "...";
		};
		step1done = {
			speaker = "Old Man";
			msg = "You're back. With a kinder look as well.";
			choices = {"I feel born anew"};
			endchoice = "...";
		};
		cleanyourself = {
			speaker = "Old Man";
			msg = "Great! You should go ahead and actually be born a new!";
			choices = {"What?"};
			endchoice = "...";
		};
		youheardmeright = {
			speaker = "Old Man";
			msg = "You heard me right. To become a helpful soul, it's only fair that you seek cleansing.";
			endchoice = "...";
		};
		cleansing = {
			speaker = "Old Man";
			msg = "Hmm... You're not fooling anyone, you still have a putrid scent.";
			endchoice = "...";
		};
		bornanew = {
			speaker = "Old Man";
			msg = "You're still alive? Seems like those flames aren't all that, huh?";
			endchoice = "...";
		};
	};

	Cedric = {
		p1 = {
			speaker = "Cedric";
			msg = "Hey there. Apologies, but I'm still setting up my restaurant. But I hope for your patronage in the near future.";
			choices = {"Need any help?"};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Cedric";
			msg = "Oh, no not really, thank you anyways.";
			choices = {"Please, I'd love to help."};
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Cedric";
			msg = "Well... I've been in a shortage for money recently, and it's been difficult to set up shop because of it.";
			choices = {"How much money do you need?"};
			endchoice = "Bye";
		};
		p4 = {
			speaker = "Cedric";
			msg = "To cover everything it should cost around 2000 money.";
			choices = {"Alright"};
			endchoice = "Bye";
		};
		p5 = {
			speaker = "Cedric";
			msg = "Thank you so much!";
			endchoice = "No problem";
		};
		healerdone = {
			speaker = "Cedric";
			msg = "Thank you so much!";
			choices = {"No problem"};
		};
		cameback = {
			speaker = "Cedric";
			msg = "Oh hello, nice to see you again!";
			choices = {"I have the money you needed (2000 Money)"};
			endchoice = "...";
		};
		nomoney = {
			speaker = "Cedric";
			msg = "If you don't have the money right now, come back another time.";
			endchoice = "...";
		};
		notquest = {
			speaker = "Cedric";
			msg = "Hey there. Apologies, but I'm still setting up my restaurant. But I hope for your patronage in the near future.";
			endchoice = "Bye";
		};
		tysm = {
			speaker = "Cedric";
			msg = "Hey! Thanks for the help earlier. Would you like to buy a Health Potion?";
			choices = {"Sure (50 Money)"};
			endchoice = "Bye";
		};
		tysm2 = {
			speaker = "Cedric";
			msg = "Hope you enjoy it!";
			endchoice = "Bye";
		};

	};

	Cosere = {
		p1 = {
			speaker = "Cosere";
			msg = "Zzzz....";
			endchoice = "Bye";
		};
	};

	Corpse = {
		p1 = {
			speaker = "...";
			msg = "_Staring at the corpse, you feel an ominous presence._";
			choices = {"Reach in"};
			endchoice = "..."
		};
		vamplich = {
			speaker = "...";
			msg = "_A voice inside welcomes you._ {My child, what might you need?}";
			choices = {"I require power", "I require a new form"};
			endchoice = "..."
		};
		vampnodays = {
			speaker = "...";
			msg = "{You are but a baby, my child. Gain more experience and return when you are wiser.}";
			endchoice = "..."
		};
		vampstep1 = {
			speaker = "...";
			msg = "{... Have you the strength to withstand such a condition?}";
			choices = {"Yes"};
			endchoice = "..."
		};
		vampstep1no = {
			speaker = "...";
			msg = "{Ahh... You are a weakling, and yet, have still so much left to learn. Feed on those below you.}";
			endchoice = "..."
		};
		vampstep1yes = {
			speaker = "...";
			msg = "{Truly you have the strength deserving of power. Very well then - I bestow upon you greater resuscitation.}";
			endchoice = "..."
		};
		vampstep2 = {
			speaker = "...";
			msg = "{... Have you the resolve to withstand such a condition?}";
			choices = {"Yes"};
			endchoice = "..."
		};
		vampstep2no = {
			speaker = "...";
			msg = "{No... No... No... You must annihilate those weaker than you. You must prove you are the Strongest child.}";
			endchoice = "..."
		};
		vampstep2yes = {
			speaker = "...";
			msg = "{It seems you are the strongest. Very well then - I bestow upon you resistance to the bane of your existence, the sun.}";
			endchoice = "..."
		};
		vampstep3 = {
			speaker = "...";
			msg = "{... Have you the mental to withstand such a condition?}";
			choices = {"Yes"};
			endchoice = "..."
		};
		vampstep3no = {
			speaker = "...";
			msg = "{You do not have the eyes of one who has starved... Starve yourself and resist the urges to sate your hunger, only then will you grow.}";
			endchoice = "..."
		};
		vampstep3yes = {
			speaker = "...";
			msg = "{Ahh... Truly beautiful... You've become the strongest child... You are deservant of immeasurable power.}";
			endchoice = "..."
		};
		lichreqsnotfulfilled = {
			speaker = "...";
			msg = "_A voice inside commands you to make a generous donation - the souls of others from before beckon you._";
			choices = {"Give in to the voices"};
			endchoice = "..."
		};
		lichreqsfulfilled = {
			speaker = "...";
			msg = "_A voice inside commands you to make a generous donation - the souls of others from before beckon you._";
			choices = {"Resist the voices"};
			endchoice = "..."
		};
		lichattained1 = {
			speaker = "...";
			msg = "_A voice inside welcomes you._ {Ah... You aren't like the rest. What might you require?}";
			choices = {"I feel hollow within"};
			endchoice = "..."
		};
		lichattained2 = {
			speaker = "...";
			msg = "{Perhaps you are just what you say to be. If you require so, for a bit of your knowledge, I will transform you to one able to bring out souls of the undead for your own gain.}";
			choices = {"Very well (10 Insight)"};
			endchoice = "..."
		};
		lichobtained = {
			speaker = "...";
			msg = "_The voice is gone._";
			endchoice = "..."
		};
		lichcompleted = {
			speaker = "...";
			msg = "_Staring at the corpse, you feel hollow inside._";
			endchoice = "..."
		};
	};

	Merrith = {
		p1 = {
			speaker = "Merrith";
			msg = "...Ahahahaha...";
			choices = {"Whats happened here?"};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Merrith";
			msg = "Those, those, Eyes! How? How? How?";
			choices = {"Are you the only one left?"};
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Merrith";
			msg = "Maybe... Maybe Valda? In the cells...";
			choices = {"What about you?"};
			endchoice = "Bye";
		};
		p4 = {
			speaker = "Merrith";
			msg = ".....";
			endchoice = "Bye";
		};
		FinishedQuest = {
			speaker = "Merrith";
			msg = "...";
			endchoice = "Bye";
		};
	};

	Valda = {
		p1 = {
			speaker = "...";
			msg = "...";
			choices = {"Search the corpse"};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "...";
			msg = "_You find a piece of paper scrawled with arcane symbols._";
			endchoice = "Bye";
		};
		doensthavequestorfinished = {
			speaker = "...";
			msg = "...";
			endchoice = "Bye";
		};
	};

	Lilin = {
		noquest = {
			speaker = "Lilin";
			msg = "Hello! I'm writing something special right now. Hehe...";
			endchoice = "Bye";
		};
		p1 = {
			speaker = "Lilin";
			msg = "Ehh, I think I'll scrap this one. I just can't find the words for it!";
			choices = {"Are you okay?"};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Lilin";
			msg = "Yeah, just... Get rid of it. Get this letter out of here! And don't read it!";
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Lilin";
			msg = "Did you trash it?";
			endchoice = "Bye";
		};
		p4 = {
			speaker = "Lilin";
			msg = "...";
			endchoice = "Bye";
		};
	};

	["Toilet Hand"] = {
		p1 = {
			speaker = "Toilet Hand";
			msg = "OoOOooOooo... Paaaaaper, _pleeasee..._";
			choices = {"...?"};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Toilet Hand";
			msg = "Please... I need paper, very, very, desperately";
			endchoice = "Bye";
		};
		p3 = {
			speaker = "Toilet Hand";
			msg = "_This isnt what i asked for..._";
			endchoice = "Bye";
		};
		p4 = {
			speaker = "Toilet Hand";
			msg = "_Yes..._";
			endchoice = "Bye";
		};
		p5 = {
			speaker = "Toilet Hand";
			msg = "_Paaaaaper...._";
			choices = {"Here."};
			endchoice = "Bye";
		};
		done = {
			speaker = "Toilet Hand";
			msg = "...";
			endchoice = "Bye";
		};
		p6 = {
			speaker = "Toilet Hand";
			msg = "_What is this..._";
			endchoice = "Bye";
		};
	};

	Gharnef = {
		p1 = {
			speaker = "Gharnef";
			msg = "Hmm, what might you want?";
			choices = {"Is there anything you can teach me?"};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Gharnef";
			msg = "You wish to learn the secerts of the dead? These secrets will cost you _%130 Money.%_";
			choices = {"I'll pay"};
			endchoice = "Bye";
		};
		gotskill = {
			speaker = "Gharnef";
			msg = "Excellent.";
			endchoice = "Bye";
		};
		poor = {
			speaker = "Gharnef";
			msg = "Do not waste my time.";
			endchoice = "Bye";
		};
		max = {
			speaker = "Gharnef";
			msg = "I have no secrets left to impart to you.";
			endchoice = "Bye";
		};
		no = {
			speaker = "Gharnef";
			msg = "You are not ready for my training.";
			endchoice = "Bye";
		};
	},
	Charles = {
		p1 = {
			speaker = "Charles";
			msg = "...";
			choices = {"Is there anything you can teach me?"};
			endchoice = "Bye";
		};
		p2 = {
			speaker = "Charles";
			msg = "I might have something to show you... If you have some spare _%Money%_";
			choices = {"Here is 350 Money."};
			endchoice = "Bye";
		};
		gotskill = {
			speaker = "Charles";
			msg = "Perfect. Here is what I learned...";
			endchoice = "Bye";
		};
		poor = {
			speaker = "Charles";
			msg = "I thought I told you that I need Money...";
			endchoice = "Bye";
		};
		max = {
			speaker = "Charles";
			msg = "I've taught you all I can. The rest is up to your own... experimentation";
			endchoice = "Bye";
		};
		no = {
			speaker = "Charles";
			msg = "You are not ready for my training.";
			endchoice = "Bye";
		};
	},
	["Dungeon Gate"] = {
		p1 = {
			speaker = "???";
			msg = "You see it standing there, bring it an artifact from the needle god.";
			endchoice = "Bye";
		}
	};
	["Dungeon Gate2"] = {
		p1 = {
			speaker = "???";
			msg = "...";
			endchoice = "Bye";
		}
	};
	["Dungeon Gate3"] = {
		p1 = {
			speaker = "???";
			msg = "...";
			endchoice = "Bye";
		}
	};
	cantbuy = {
		speaker = "???";
		msg = "You can't buy this yet.";
		endchoice = "Bye";
	};
	bought = {
		speaker = "???";
		msg = "Good doing business with you.";
		endchoice = "Bye";
	};
	exit = {
		speaker = "???";
		msg = "...";
		endchoice = "Bye";
		exit = true;
	};
};

local function checkhealerdone(storymarker)
	if storymarker["StartedHealer"]["Alana"] and 
		storymarker["StartedHealer"]["Alana"] == true and 
		storymarker["StartedHealer"]["Dormin"] and
		storymarker["StartedHealer"]["Dormin"] == true and
		storymarker["StartedHealer"]["Nero"] and
		storymarker["StartedHealer"]["Nero"] == true and
		storymarker["StartedHealer"]["Reynauld"] and
		storymarker["StartedHealer"]["Reynauld"] == true and
		storymarker["StartedHealer"]["Cedric"] and
		storymarker["StartedHealer"]["Cedric"] == true then
		return true
	else
		return false
	end
end

local gateopening = false
local gateClosed = CFrame.new(4010.356, 485.778, -1101.255)
local gateOpen = CFrame.new(4010.356, 380.778, -1101.255)

local gateClosed1 = CFrame.new(3908.068, 465.579, -1360.218)
local gateOpen1 = CFrame.new(3908.068, 380.579, -1360.218)

local gateClosed2 = CFrame.new(3839.496, 465.579, -1661.604)
local gateOpen2 = CFrame.new(3839.496, 380.579, -1661.604)

local function subclasscheck(p, data, name)
	local skills = data.skills
	local playerdata = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	local subclass = playerdata:FindFirstChild("SubClass")
	local playerskills = string.split(playerdata:FindFirstChild("Skills").Value, ",")

	if subclass.Value ~= name and subclass.Value ~= "" then
		return "got"
	end

	local totalskills = #skills
	local count = 0

	for _, skill in next, playerskills do
		if table.find(skills, skill) then
			count += 1
		end
	end

	if count == totalskills then
		return "max"
	else
		return "notmax"
	end
end

local function subclassteachskill(p, data, name)
	local skills = data.skills
	local price = data.price
	local playerdata = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	local Money = playerdata:FindFirstChild("Money")

	if Money.Value < price then
		return "poor"
	end

	local subclass = playerdata:FindFirstChild("SubClass")
	local playerskills = string.split(playerdata:FindFirstChild("Skills").Value, ",")

	local alreadyhas = {}


	for _, skill in next, playerskills do
		if table.find(skills, skill) then
			table.insert(alreadyhas, skill)
		end
	end

	local skilltoteach

	for _, a in next, skills do
		if not table.find(alreadyhas, a) then
			skilltoteach = (","..a)
		end
	end

	playerdata.Skills.Value ..= skilltoteach
	subclass.Value = name
	commands["ChangeMoney"](p, playerdata, -price)
	return "gotskill"
end
local HS = game:GetService("HttpService")
local function CheckAzaelAscension(p)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	local StoryMarker = HS:JSONDecode(data.StoryMarker.Value)
	if StoryMarker["Obelisks"] then
		if table.find(StoryMarker["Obelisks"], "Desert") and 
			table.find(StoryMarker["Obelisks"], "Deepforest") and
			table.find(StoryMarker["Obelisks"], "Forest") and
			table.find(StoryMarker["Obelisks"], "Shore") and
			table.find(StoryMarker["Obelisks"], "Sigil") and
			table.find(StoryMarker["Obelisks"], "Skycastle") and
			table.find(StoryMarker["Obelisks"], "Snail") and
			table.find(StoryMarker["Obelisks"], "Tundra")
		then
			return true
		else
			return false
		end
	end
end

local learner = false
dialogues.SpellChange.v1 = function(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	local lastspell = data.LastScroll.Value
	if not data then
		return
	end
	local allski = string.split(data.Spells.Value, ",")
	local choices = {}
	for i,v in pairs(allski)do
		if v ~= "" then
			table.insert(choices,v)
		end
	end
	if v.page == 1 then
		return {
			speaker = "...",
			msg = "Which spell would you like to replace for "..lastspell,
			choices = choices,
			endchoice = "Cancel"
		}
	elseif v.page == 2 then
		data.LastScroll.Value = ""
		data.Spells.Value = ""
		data.Spells.Value = lastspell..","..data.Spells.Value
		learner = true
		if learner then
			table.remove(allski,table.find(allski,v.choice))
			for i,v in pairs(allski) do
				if v ~= "" then
					data.Spells.Value = data.Spells.Value..""..v..","
				end
			end
			commands.Learn(p)
			p.Character.Humanoid:UnequipTools()
			for _,abc in pairs(p.Backpack:GetChildren())do
				if abc.Name == v.choice then
					create("DestroySkill",false,abc)
				end
			end
			commands.UpdateSpells(p)
			return{
				speaker = "...",
				msg = "You have replaced %'"..v.choice.."'% for %'"..lastspell.."'%",
				endchoice = "...",
			};
		end
	end
end

dialogues.Ethel.v1 = function(p, v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data then
		return
	end
	if data.Race.Value ~= "Ashiin" then
		return {speaker = "Ethel",
			msg = "Scram.",
			endchoice = "Bye."
		}
	end
	if data.Skills.Value:find("Shoulder Throw") then
		return {speaker = "Ethel",
			msg = "I have taught you all I can.",
			endchoice = "Bye."
		}
	end
	if v.page == 1 then
		if data.Class.Value == "" then
			return {speaker = "Ethel",
				msg = "You're not yet ready for these techniques.",
				endchoice = "Bye."
			}
		end
		return {speaker = "Ethel",
			msg = "Would you like to learn advanced techniques?",
			choices = {"Yes!"},
			endchoice = "Bye."
		}
	elseif v.page == 2 then
		data.Skills.Value ..= ",Shoulder Throw"
		game:GetService("ServerStorage").RacialAbilities["Shoulder Throw"]:Clone().Parent = p.Backpack
		commands.Learn(p)
		return {speaker = "Ethel",
			msg = "Enjoy.",
			endchoice = "Bye."
		}
	end
end
dialogues["Dungeon Gate3"].v1 = function(p, v)
	local character = p.Character

	local foundHowler = false

	for _, shrieker in pairs(workspace.Live:GetChildren()) do
		if string.find(shrieker.Name, ".Howler") then
			if (shrieker.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude < 500 then
				foundHowler = true
			end
		end
	end


	if v.page == 1 then

		if foundHowler == true then
			return {
				speaker = "???";
				msg = "Finish them.";
				endchoice = "Bye";
			}
		else
			return {
				speaker = "???";
				msg = "...",
				choices = {"..."},
				endchoice = "Bye";
			}
		end
	elseif v.page == 2 then
		if foundHowler == false then

			workspace.NPCs["Dungeon Gate"].Open:Play()

			for _, gate in pairs(workspace.NPCs["Dungeon Gate3"]:GetChildren()) do
				if not gate:IsA("BasePart") then continue end
				game:GetService("TweenService"):Create(gate, TweenInfo.new(3), {
					CFrame = gateOpen2
				}):Play()

			end


			task.spawn(function()
				task.wait(3)

				workspace.NPCs["Dungeon Gate"].Open:Stop()

				task.wait(3)

				workspace.NPCs["Dungeon Gate"].Open:Play()

				for _, gate in pairs(workspace.NPCs["Dungeon Gate3"]:GetChildren()) do
					if not gate:IsA("BasePart") then continue end
					game:GetService("TweenService"):Create(gate, TweenInfo.new(3), {
						CFrame = gateClosed2
					}):Play()
				end

				task.wait(5)

				workspace.NPCs["Dungeon Gate"].Open:Stop()

				workspace.NPCs["Dungeon Gate"].Close:Play()
			end)

			return {
				speaker = "???";
				msg = "It opens for you.",
				endchoice = "Bye";
			}
		end

	end
end

dialogues["Dungeon Gate2"].v1 = function(p, v)
	local character = p.Character

	local foundShrieker = false

	for _, shrieker in pairs(workspace.Live:GetChildren()) do
		if string.find(shrieker.Name, ".Shrieker") then
			if (shrieker.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude < 500 then
				foundShrieker = true
			end
		end
	end


	if v.page == 1 then

		if foundShrieker == true then
			return {
				speaker = "???";
				msg = "Finish them.";
				endchoice = "Bye";
			}
		else
			return {
				speaker = "???";
				msg = "...",
				choices = {"..."},
				endchoice = "Bye";
			}
		end
	elseif v.page == 2 then
		if foundShrieker == false then

			workspace.NPCs["Dungeon Gate"].Open:Play()

			for _, gate in pairs(workspace.NPCs["Dungeon Gate2"]:GetChildren()) do
				if not gate:IsA("BasePart") then continue end
				game:GetService("TweenService"):Create(gate, TweenInfo.new(3), {
					CFrame = gateOpen1
				}):Play()

			end


			task.spawn(function()
				task.wait(3)

				workspace.NPCs["Dungeon Gate"].Open:Stop()

				task.wait(3)

				workspace.NPCs["Dungeon Gate"].Open:Play()

				for _, gate in pairs(workspace.NPCs["Dungeon Gate2"]:GetChildren()) do
					if not gate:IsA("BasePart") then continue end
					game:GetService("TweenService"):Create(gate, TweenInfo.new(3), {
						CFrame = gateClosed1
					}):Play()
				end

				task.wait(5)

				workspace.NPCs["Dungeon Gate"].Open:Stop()

				workspace.NPCs["Dungeon Gate"].Close:Play()
			end)

			return {
				speaker = "???";
				msg = "It opens for you.",
				endchoice = "Bye";
			}
		end

	end
end

dialogues["Dungeon Gate"].v1 = function(p, v)
	local character = p.Character

	if v.page == 1 then
		if not p.Backpack:FindFirstChild("???") then
			return dialogues["Dungeon Gate"].p1
		else
			return {
				speaker = "???";
				msg = dialogues["Dungeon Gate"].p1.msg,
				choices = {"..."},
				endchoice = "Bye";
			}
		end
	elseif v.page == 2 then
		if p.Backpack:FindFirstChild("???") then
			if gateopening == false then


				workspace.NPCs["Dungeon Gate"].Open:Play()

				for _, gate in pairs(workspace.NPCs["Dungeon Gate"]:GetChildren()) do
					if not gate:IsA("BasePart") then continue end
					game:GetService("TweenService"):Create(gate, TweenInfo.new(3), {
						CFrame = gateOpen
					}):Play()

				end



				task.spawn(function()
					task.wait(3)

					workspace.NPCs["Dungeon Gate"].Open:Stop()

					task.wait(3)

					workspace.NPCs["Dungeon Gate"].Open:Play()

					for _, gate in pairs(workspace.NPCs["Dungeon Gate"]:GetChildren()) do
						if not gate:IsA("BasePart") then continue end
						game:GetService("TweenService"):Create(gate, TweenInfo.new(3), {
							CFrame = gateClosed
						}):Play()
					end

					task.wait(5)

					workspace.NPCs["Dungeon Gate"].Open:Stop()

					workspace.NPCs["Dungeon Gate"].Close:Play()
				end)

				return {
					speaker = "???";
					msg = "It opens for you.",
					endchoice = "Bye";
				}

			end
		end
	end
end

function dialogues.Eslaf.v1(p,v)
	if v.page == 1 then
		return dialogues.Eslaf.p1
	elseif v.choice == "Who are you?" then
		return dialogues.Eslaf.whoru
	elseif v.choice == "What is this place?" then
		return dialogues.Eslaf.whatdisplace
	elseif v.choice == "Redemption?" then
		return dialogues.Eslaf.redemption
	end
end

function dialogues.Dasher.v1(p,v)
	if v.page == 1 then
		return dialogues.Dasher.p1
	elseif v.page == 2 then
		return dialogues.Dasher.p2
	elseif v.page == 3 then
		return dialogues.Dasher.p3
	elseif v.page == 4 then
		return dialogues.Dasher.p4
	elseif v.choice == "Can you teach me some thief tricks?" then
		return dialogues.Dasher.thieftricks
	elseif v.choice == "Anything I should know about this" then
		return dialogues.Dasher.knowabout
	end
end

function dialogues.Eil.v1(p,v)
	if v.page == 1 then
		return dialogues.Eil.p1
	elseif v.choice == "No."then
		return dialogues.Eil.no
	elseif v.choice == "Yes."then
		return dialogues.Eil.yes
	elseif v.choice == "What is this place?"then
		return dialogues.Eil.whatisthisplace
	elseif v.choice == "Church Knights? What are those?"then
		return dialogues.Eil.whatarethose
	end
end

dialogues.Oliver.v1 = function(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data then
		return
	end
	if v.page == 1 then
		if data.RaceRerolled.Value == true then
			return dialogues.Oliver.alreadyrerolled
		end
		if p:FindFirstChild("Danger") then
			return dialogues.Oliver.combat
		end
		return dialogues.Oliver.p1
	elseif v.choice == "Rare"then
		return dialogues.Oliver.rare
	elseif v.choice == "Uncommon"then
		return dialogues.Oliver.uncommon
	elseif v.choice == "Common"then
		return dialogues.Oliver.common
	elseif v.choice == "Dzin" or v.choice == "Vind" or v.choice == "Fischeran" or v.choice == "Morvid" or v.choice == "Dinakeri" or v.choice == "Madrasian" or v.choice == "LesserNavaran" or v.choice == "Azael" or v.choice == "Metascroom" or v.choice == "Dullahan" or v.choice == "Scroom" or v.choice == "Gaian" or v.choice == "Kasparan" or v.choice == "Castellan" or v.choice == "Ashiin" or v.choice == "Rigan" or v.choice == "Haseldan" or v.choice == "Construct" then
		data.Race.Value = v.choice
		data.RaceRerolled.Value = true
		return dialogues.Oliver.bye
	end
end

dialogues.Isaiah.v1 = function(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data then
		return
	end
	if v.page == 1 then
		return dialogues.Isaiah.normal1
	elseif v.choice == "I've heard you're able to reset my artifact." then
		if data.Artifact.Value == "" or data.Artifact.Value == "None" then
			return dialogues.Isaiah.noartifact
		end
		return dialogues.Isaiah.canreset
	elseif v.choice == "I've heard you're able to reset my subclass." then
		return dialogues.Isaiah.canresetsub
	elseif v.choice == "Reset Artifact" then
		local PlayerData = game.ServerStorage.PlayerData
		local Player = p
		local Commands = require(game.ServerScriptService.Modules.Commands)
		local oldArtifact = PlayerData[Player.Name].Artifact.Value
		if oldArtifact == "Spider Cloak" then
			Commands.ChangeArmor(Player, "Rags")
		elseif oldArtifact == "Fairfrozen" then
			Commands.ChangeWeapon(Player, "None")
		end
		PlayerData[Player.Name].Artifact.Value = "None"
		local v12 = Instance.new("NumberValue");
		v12.Name = "Transparency";
		v12.Value = 0;
		v12.Parent = Player.Character.Boosts;
		task.spawn(function()
			task.wait(1)
			Player:LoadCharacter()
		end)
		return dialogues.Isaiah.reset
	elseif v.choice == "Reset Subclass" then
		local PlayerData = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
		local Player = p
		local Commands = require(game.ServerScriptService.Modules.Commands)
		local Class = PlayerData.Class.Value
		local NoRemoveClasses = {"Spearfisher", "Atlas", "SuperBlacksmith", "Lapidarist", "Candence", "Botanist", "Florist"}
		if table.find(NoRemoveClasses, Class) then
			return dialogues.Isaiah.noartifact
		end
		if table.find(NoRemoveClasses, PlayerData.Hybrid.Value) then
			return dialogues.Isaiah.noartifact
		end
		PlayerData.SubClass.Value = ""
		commands.Learn(p.Character)
		return dialogues.Isaiah.reset
	end
end

function dialogues.Monk.v1(p,v)
	if v.page == 1 then
		return dialogues.Monk.p1
	elseif v.choice == "How do I get stronger?" then
		return dialogues.Monk.stronger
	elseif v.choice == "How can I earn Money?" then
		return dialogues.Monk.earnMoney 
	elseif v.choice == "Any other options?" then
		return dialogues.Monk.anyotheroptions
	elseif v.choice == "Anything else?" then
		return dialogues.Monk.anythinelse1
	elseif v.choice == "How can I get them to acknowledge me?" then 
		return dialogues.Monk.acknolwedgeme
	elseif v.choice == "Αnything else?" then 
		return dialogues.Monk.anythinelse2 
	elseif v.choice == "That's all for now." then 
		return dialogues.Monk.thatsit 
	end
end

dialogues["Baby Yeti"].v1 = function(p,v)
	if v.page == 1 then
		return dialogues["Baby Yeti"].p1
	end
end

function dialogues.Nero.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	local StoryMarker = game:GetService("HttpService"):JSONDecode(data.StoryMarker.Value)
	if not StoryMarker then
		return
	end
	if not StoryMarker["StartedHealer"] then
		return dialogues.Nero.notquest
	end
	if v.page == 1 then
		if StoryMarker["StartedHealer"] and (StoryMarker["StartedHealer"]["Nero"] == true or StoryMarker["StartedHealer"] == "Finished") then
			return dialogues.Nero.tysm
		end
		if StoryMarker["NeroQuest"] and StoryMarker["NeroQuest"] == "Started" then
			if p.Character:FindFirstChild("Desert Mist") or p.Backpack:FindFirstChild("Desert Mist") then
				return dialogues.Nero.returneddesertmist
			else
				return dialogues.Nero.returnednodesertmist
			end
		end
		return dialogues.Nero.p1
	elseif v.choice == "Hey, need any help?" then
		return dialogues.Nero.p2
	elseif v.choice == "I got you" then
		StoryMarker["NeroQuest"] = "Started"
		data.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
		return dialogues.Nero.accepted
	elseif v.choice == "Here you go" then
		if p.Character:FindFirstChild("Desert Mist") or p.Backpack:FindFirstChild("Desert Mist") then
			if p.Character:FindFirstChild("Desert Mist") then
				p.Character:FindFirstChild("Desert Mist"):Destroy()
				commands.RemoveFromInventory(p,"Desert Mist")
			else
				p.Backpack:FindFirstChild("Desert Mist"):Destroy()
				commands.RemoveFromInventory(p,"Desert Mist")
			end
			StoryMarker["StartedHealer"]["Nero"] = true
			data.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
			commands.Learn(p)
			if checkhealerdone(StoryMarker) then
				StoryMarker["StartedHealer"] = "Finished"
				data.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
				return dialogues.Nero.healerdone
			end
			return dialogues.Nero.thankyou
		else
			return dialogues.Nero.confused
		end
	elseif v.choice == "Anytime" then
		return dialogues.Healer.healerstep1done
	end
end

function dialogues.Laputa.v1(p,v)
	if v.page == 1 then
		return dialogues.Laputa.p1
	elseif v.choice == "What is this place?"then
		return dialogues.Laputa.whatthisplaceagin
	end
end

function dialogues.Lerase.v1(p,v)
	if v.page == 1 then
		return dialogues.Lerase.p1
	end
end

dialogues["Monster Officer"].v1 = function(p,v)
	if v.page == 1 then
		return dialogues["Monster Officer"].p1
	elseif v.page == 2 then
		return dialogues["Monster Officer"].p2
	end
end

function dialogues.Rita.v1(p,v)
	if v.page == 1 then
		return dialogues.Rita.p1
	end
end

function dialogues.Reneri.v1(p,v)
	if v.page == 1 then
		return dialogues.Reneri.p1
	end
end

function dialogues.TransFlag.v1(p,v)
	if v.page == 1 then
		return dialogues.TransFlag.p1
	end
end

function dialogues.Silas.v1(p,v)
	if v.page == 1 then
		return dialogues.Silas.p1
	end
end

function dialogues.Dreadhead.v1(p,v)
	if v.page == 1 then
		return dialogues.Dreadhead.p1
	elseif v.page == 2 then
		return dialogues.Dreadhead.p2
	end
end

function dialogues.Mitch.v1(p,v)
	if v.page == 1 then
		return dialogues.Mitch.p1
	elseif v.page == 2 then
		return dialogues.Mitch.p2
	elseif v.page == 3 then
		return dialogues.Mitch.p3
	end
end

function dialogues.Hendrick.v1(p,v)
	if v.page == 1 then
		return dialogues.Hendrick.p1
	end
end

function dialogues.Cedric.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	local StoryMarker = game:GetService("HttpService"):JSONDecode(data.StoryMarker.Value)
	if not StoryMarker then
		return
	end
	if not StoryMarker["StartedHealer"] then
		return dialogues.Cedric.notquest
	end
	if v.page == 1 then
		if StoryMarker["StartedHealer"] and (StoryMarker["StartedHealer"]["Cedric"] == true or StoryMarker["StartedHealer"] == "Finished") then
			return dialogues.Cedric.tysm
		end
		if StoryMarker["CedricQuest"] and StoryMarker["CedricQuest"] == "Started" then
			return dialogues.Cedric.cameback
		end
		return dialogues.Cedric.p1
	elseif v.choice == "Need any help?" then
		return dialogues.Cedric.p2
	elseif v.choice == "Please, I'd love to help." then
		return dialogues.Cedric.p3
	elseif v.choice == "How much money do you need?" then
		return dialogues.Cedric.p4
	elseif v.choice == "Alright" then
		if commands.ChangeMoney(p,data,-2000) then
			commands.Learn(p)
			StoryMarker["StartedHealer"]["Cedric"] = true
			data.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
			if checkhealerdone(StoryMarker) then
				StoryMarker["StartedHealer"] = "Finished"
				data.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
				return dialogues.Cedric.healerdone
			end
			return dialogues.Cedric.p5
		else
			StoryMarker["CedricQuest"] = "Started"
			data.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
			return dialogues.Cedric.nomoney
		end
	elseif v.choice == "I have the money you needed (2000 Money)" then
		if commands.ChangeMoney(p,data,-2000) then
			commands.Learn(p)
			StoryMarker["StartedHealer"]["Cedric"] = true
			data.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
			if checkhealerdone(StoryMarker) then
				StoryMarker["StartedHealer"] = "Finished"
				data.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
				return dialogues.Cedric.healerdone
			end
			return dialogues.Cedric.p5
		else
			StoryMarker["CedricQuest"] = "Started"
			data.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
			return dialogues.Cedric.nomoney
		end
	elseif v.choice == "Sure (50 Money)" then
		if commands.ChangeMoney(p,data,-50) then
			commands.AddToInventory(p, "Health Potion")
			return dialogues.Cedric.tysm2
		else
			return dialogues.Cedric.nomoney
		end
	elseif v.choice == "No problem" then
		return dialogues.Healer.healerstep1done
	end
end

function dialogues.Informant.v1(p,v)
	if v.page == 1 then
		return dialogues.Informant.p1
	end
end

function dialogues.Ellie.v1(p,v)
	if v.page == 1 then
		return dialogues.Ellie.p1
	end
end

function dialogues.Dew.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	if v.page == 1 then
		return dialogues.Dew.p1
	elseif v.choice == "He's weak" then
		return dialogues.Dew.heaint
	elseif v.choice == "hes TRASH" then
		return dialogues.Dew.stopbullu
	end
end
function dialogues.Hespe.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	local StoryMarker = game:GetService("HttpService"):JSONDecode(data.StoryMarker.Value)
	if not StoryMarker then
		return
	end
	if v.page == 1 then
		if StoryMarker["StartedHealer"] and (StoryMarker["StartedHealer"]["Reynauld"] == true or StoryMarker["StartedHealer"] == "Finished") then
			return dialogues.Hespe.finishedquest
		end
		if not StoryMarker["ReynauldQuest"] then
			return dialogues.Hespe.notquest
		end
		return dialogues.Hespe.p1
	elseif v.page == 2 then
		commands.Learn(p)
		StoryMarker["StartedHealer"]["Reynauld"] = true
		data.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
		if checkhealerdone(StoryMarker) then
			StoryMarker["StartedHealer"] = "Finished"
			data.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
			return dialogues.Hespe.healerdone
		end
		return dialogues.Hespe.p2
	elseif v.choice == "..." then
		return dialogues.Healer.healerstep1done
	end
end

function dialogues.Fir.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	local Skills = data.Skills.Value
	local bromquest = data.Skills.Value:find("bromquestgot")

	if Skills:find("cantdofirquest")  then
		return dialogues.Fir.afterquest
	end
	if v.page == 1 then
		if bromquest == nil then
			return dialogues.Fir.p1
		else
			return dialogues.Fir.withquestp2
		end
	elseif v.choice == "What's wrong?" then
		return dialogues.Fir.p2    
	elseif v.choice == "Do you mean Brom?" then
		return dialogues.Fir.withquestp3
	elseif v.choice == "Yeah, I saw him earlier." then
		return dialogues.Fir.withquestp4
	elseif v.choice == "I saw him napping on the job." then
		return dialogues.Fir.nappingonjob
	elseif v.choice == "He broke down. There will be a delay." then
		local skillstoremove = {"bromquestgot"}
		local skills = string.split(data.Skills.Value,",")
		for _,b in pairs(skillstoremove)do
			local toremove = table.find(skills,b)
			if toremove then
				table.remove(skills,toremove)
				data.Skills.Value = table.concat(skills,",")
				data.Alignment.Value += 5
				game.ServerStorage.PlayerData[p.Name].Skills.Value ..= ",cantdofirquest"
				return dialogues.Fir.withquestp5
			end
		end
	end
end

function dialogues.Lachesis.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	local Skills = data.Skills.Value
	if Skills:find("lachesisdone")  then
		return dialogues.Lachesis.questfinished
	end
	if v.page == 1 then
		return dialogues.Lachesis.p1
	elseif v.choice == "What's the matter?" then
		return dialogues.Lachesis.p2
	elseif v.choice == "It's no problem. Can I help?" then
		return dialogues.Lachesis.p3
	elseif v.choice == "Is it a Scroom?" then
		return dialogues.Lachesis.p4
	elseif v.choice == "Glad to help." then
		data.Alignment.Value += 5
		game.ServerStorage.PlayerData[p.Name].Skills.Value ..= ",lachesisdone"
		return dialogues.Lachesis.p5
	end
end

function dialogues.Brom.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	local Skills = data.Skills.Value
	if Skills:find("bromquestgot") then
		return dialogues.Brom.questalreadytaken
	end
	if Skills:find("cantdofirquest") then
		return dialogues.Brom.finishedquest
	end
	if v.page == 1 then
		return dialogues.Brom.p1
	elseif v.page == 2 then
		return dialogues.Brom.p2
	elseif v.choice == "If I see her." then
		game.ServerStorage.PlayerData[p.Name].Skills.Value ..= ",bromquestgot"
		return dialogues.Brom.p3
	end
end

function dialogues.Rowan.v1(p,v)
	if v.page == 1 then
		return dialogues.Rowan.p1
	elseif v.page == 2 then
		return dialogues.Rowan.p2
	elseif v.page == 3 then
		return dialogues.Rowan.p3
	elseif v.page == 4 then
		return dialogues.Rowan.p4
	elseif v.page == 5 then
		return dialogues.Rowan.p5
	end
end

function dialogues.Merrith.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	local Skills = data.Skills.Value
	if Skills:find("merrithquest") or Skills:find("finishedmerrith")  then
		return dialogues.Merrith.FinishedQuest
	end

	if v.page == 1 then
		return dialogues.Merrith.p1
	elseif v.page == 2 then
		return dialogues.Merrith.p2
	elseif v.page == 3 then
		return dialogues.Merrith.p3
	elseif v.page == 4 then
		game.ServerStorage.PlayerData[p.Name].Skills.Value ..= ",merrithquest" 
		game.ServerStorage.PlayerData[p.Name].Skills.Value ..= ",finishedmerrith" 
		return dialogues.Merrith.p4
	end
end

function dialogues.Valda.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	local Skills = data.Skills.Value
	local merrithquest = Skills:find("merrithquest")
	local canopen = Skills:find("canopendoor")

	if Skills:find("canopendoor")  then
		return dialogues.Valda.doensthavequestorfinished
	end
	if v.page == 1 then
		if merrithquest == nil then
			return dialogues.Valda.doensthavequestorfinished
		else
			return dialogues.Valda.p1
		end
	elseif v.choice == "Search the corpse" then
		local skillstoremove = {"merrithquest"}
		local skills = string.split(data.Skills.Value,",")
		for _,b in pairs(skillstoremove)do
			local toremove = table.find(skills,b)
			if toremove then
				table.remove(skills,toremove)
				data.Skills.Value = table.concat(skills,",")
				game.ServerStorage.PlayerData[p.Name].Skills.Value ..= ",canopendoor" 
				return dialogues.Valda.p2
			end
		end
	end
end

dialogues["Corpse"].v1 = function(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	if p.Character:FindFirstChild("Danger") then
		return dialogues["Corpse"].lichcompleted
	end
	if v.page == 1 then
		if data.Race.Value == "Lich" then
			return dialogues["Corpse"].lichcompleted
		elseif data.Vampire.Value == true and data.EvampStep.Value < 3 then
			return dialogues["Corpse"].vamplich
		else
			return dialogues["Corpse"].p1
		end
	elseif v.page == 2 then
		if v.choice == "I require power" then
			if data.DaysSurvived.Value < 8 then
				return dialogues["Corpse"].vampnodays
			else
				if data.EvampStep.Value < 3 then
					if data.EvampStep.Value < 2 then
						if data.EvampStep.Value < 1 then
							return dialogues["Corpse"].vampstep1
						else
							return dialogues["Corpse"].vampstep2
						end
					else
						return dialogues["Corpse"].vampstep3
					end
				end
			end
		else
			if data.TotalGrips.Value < 20 then
				return dialogues["Corpse"].lichreqsnotfulfilled
			else
				return dialogues["Corpse"].lichreqsfulfilled
			end
		end
	elseif v.page == 3 then
		if v.choice == "Yes" then
			if data.EvampStep.Value < 3 then
				if data.EvampStep.Value < 2 then
					if data.EvampStep.Value < 1 then
						if data.Feeds.Value < 30 then
							return dialogues["Corpse"].vampstep1no
						else
							data.EvampStep.Value = 1
							commands.Learn(p.Character)
							return dialogues["Corpse"].vampstep1yes
						end
					else
						if data.VampireGrips.Value < 15 then
							return dialogues["Corpse"].vampstep2no
						else
							data.EvampStep.Value = 2
							commands.Learn(p.Character)
							return dialogues["Corpse"].vampstep2yes
						end
					end
				else
					if data.VampireStarving.Value < 30 and data.Race.Value ~= "Wretch" then
						return dialogues["Corpse"].vampstep3no
					else
						data.EvampStep.Value = 3
						commands.Learn(p.Character)
						return dialogues["Corpse"].vampstep3yes
					end
				end
			end
		elseif v.choice == "Give in to the voices" then
			task.delay(1.5,function()
				_G.Death(p,nil,nil,true)
				p.Character.Humanoid.Health = 0
				p.Character.HumanoidRootPart.Backfire:Play()
				task.wait(1/30)
				coroutine.wrap(function()
					for i,bruh in pairs(p.Character:GetChildren()) do
						if bruh:IsA("Shirt") or bruh:IsA("Pants") then
							bruh:Destroy()
						end
						if bruh:IsA("Part") or bruh:IsA("BasePart") then
							local dec = bruh:FindFirstChildOfClass("Decal")
							if dec then
								dec:Destroy()
							end
							local bv = Instance.new("BodyVelocity")
							game.CollectionService:AddTag(bv,"AllowedBM")
							bv.Velocity = Vector3.new(math.random(-10,10),math.random(-10,10),math.random(-10,10))
							bv.Parent = bruh
							bruh.Material = Enum.Material.Neon
							local tweenInfo02 = TweenInfo.new(1.25,	Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
							local tween02 = TweenService:Create(bruh,tweenInfo02,{Transparency=1,Color=Color3.new()})
							tween02:Play()
						end
					end
				end)()
			end)
		elseif v.choice == "Resist the voices" then
			return dialogues["Corpse"].lichattained1
		end
	elseif v.page == 4 then
		return dialogues["Corpse"].lichattained2
	elseif v.page == 5 then
		if commands.ChangeInsight(p, data, -10) then
			data.Race.Value = "Lich"
			commands.Learn(p.Character)
		end
		return dialogues["Corpse"].lichobtained
	end
end

dialogues["Toilet Hand"].v1 = function(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	local Skills = data.Skills.Value
	local toiletquest = Skills:find("Toilethandqueststarted")
	if Skills:find("toilethanddone") then
		return dialogues["Toilet Hand"].done
	end
	if v.page == 1 then
		if toiletquest == nil then
			return dialogues["Toilet Hand"].p1
		else
			return dialogues["Toilet Hand"].p5
		end
	elseif v.choice == "...?" then
		game.ServerStorage.PlayerData[p.Name].Skills.Value ..= ",Toilethandqueststarted" 
		return dialogues["Toilet Hand"].p2
	elseif v.choice == "Here." and p.Backpack:FindFirstChild("Love Letter") then
		local skillstoremove = {"Toilethandqueststarted"}
		local skills = string.split(data.Skills.Value,",")
		for _,b in pairs(skillstoremove)do
			local toremove = table.find(skills,b)
			if toremove then
				table.remove(skills,toremove)
				data.Skills.Value = table.concat(skills,",")
				game.ServerStorage.PlayerData[p.Name].Skills.Value ..= ",toilethanddone" 
				data.Alignment.Value += 4
				p.Backpack:FindFirstChild("Love Letter"):Destroy()
				return dialogues["Toilet Hand"].p4
			elseif v.choice == "Here." and not p.Backpack:FindFirstChild("Love Letter") then
				return dialogues["Toilet Hand"].p3
			end    
		end    
	end
end

function dialogues.Lilin.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	local Skills = data.Skills.Value
	if Skills:find("toilethanddone") then
		return dialogues.Lilin.p4
	end
	if not Skills:find("Toilethandqueststarted")   then
		return dialogues.Lilin.noquest
	end
	if Skills:find("Toilethandqueststarted") and p.Backpack:FindFirstChild("Love Letter") then
		return dialogues.Lilin.p3
	end
	if v.page == 1 then
		return dialogues.Lilin.p1
	elseif v.choice == "Are you okay?" then
		Instance.new("Tool", p.Backpack).Name = "Love Letter"
		return dialogues.Lilin.p2
	end
end

function dialogues.Alana.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	local StoryMarker = game:GetService("HttpService"):JSONDecode(data.StoryMarker.Value)
	if not StoryMarker then
		return
	end
	if v.page == 1 then
		if StoryMarker["StartedHealer"] and (StoryMarker["StartedHealer"]["Alana"] == true or StoryMarker["StartedHealer"] == "Finished") then
			return dialogues.Alana.tysm
		end
		if StoryMarker["AlanaQuest"] and StoryMarker["AlanaQuest"] == "Started" then
			if p.Backpack:FindFirstChild("Health Potion") or p.Character:FindFirstChild("Health Potion") then
				return dialogues.Alana.anynewswithhealthpot
			else
				return dialogues.Alana.anynewsnopot
			end
		end
		return dialogues.Alana.p1
	elseif v.choice == "What's wrong?" then
		if not StoryMarker["StartedHealer"] then
			return dialogues.Alana.whatswrongnoquest
		else
			return dialogues.Alana.whatswrong
		end
	elseif v.choice == "I'm here to help." then
		return dialogues.Alana.imheretohelp
	elseif v.choice == "I'm sorry to hear that." then
		return dialogues.Alana.srytohear
	elseif v.choice == "Of course." then
		StoryMarker["AlanaQuest"] = "Started"
		data.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
		return dialogues.Alana.ty
	elseif v.choice == "Would this potion be of any use?" then
		if p.Character:FindFirstChild("Health Potion") then
			p.Character:FindFirstChild("Health Potion"):Destroy()
			commands.RemoveFromInventory(p,"Health Potion")
		else
			p.Backpack:FindFirstChild("Health Potion"):Destroy()
			commands.RemoveFromInventory(p,"Health Potion")
		end
		StoryMarker["StartedHealer"]["Alana"] = true
		data.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
		commands.Learn(p)
		if checkhealerdone(StoryMarker) then
			StoryMarker["StartedHealer"] = "Finished"
			data.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
			return dialogues.Alana.healerdone
		end
		return dialogues.Alana.questdonehealthpotion
	elseif v.choice == "Any time" then
		return dialogues.Healer.healerstep1done
	end
end

function dialogues.Reynauld.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	local StoryMarker = game:GetService("HttpService"):JSONDecode(data.StoryMarker.Value)
	if not StoryMarker then
		return
	end
	if StoryMarker["StartedHealer"] and (StoryMarker["StartedHealer"]["Reynauld"] == true or StoryMarker["StartedHealer"] == "Finished") then
		return dialogues.Reynauld.no
	end
	if v.page == 1 then
		if StoryMarker["StartedHealer"] then
			if StoryMarker["ReynauldQuest"] then
				return dialogues.Reynauld.no
			end
			if p.Backpack:FindFirstChild("Health Potion") or p.Character:FindFirstChild("Health Potion") then
				return dialogues.Reynauld.p1
			else
				return dialogues.Reynauld.no
			end
		end
		return dialogues.Reynauld.no
	elseif v.choice == "Give a Health Potion" then
		if p.Character:FindFirstChild("Health Potion") then
			p.Character:FindFirstChild("Health Potion"):Destroy()
			commands.RemoveFromInventory(p,"Health Potion")
		else
			p.Backpack:FindFirstChild("Health Potion"):Destroy()
			commands.RemoveFromInventory(p,"Health Potion")
		end
		StoryMarker["ReynauldQuest"] = "Started"
		data.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
		return dialogues.Reynauld.p2
	elseif v.choice == "I will return it" then
		return dialogues.Reynauld.p3
	end
end

dialogues["Master Assassin"].v1 = function(p,v)
	local character = p.Character
	if v.page == 1 then
		if p:FindFirstChild("Grabbing") then
			local Carrying = p:FindFirstChild("Grabbing")
			local CarryPlayer = game.Players:GetPlayerFromCharacter(Carrying.Value)
			if CarryPlayer then
				if CarryPlayer == p:FindFirstChild("ChaoticMission").Value then
					commands["CarryDrop"](character)
					CarryPlayer.Character:BreakJoints()
					local PData = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
					p:FindFirstChild("ChaoticMission"):Destroy()
					if PData then
						commands["ChangeMoney"](p, PData, 100, true)
						PData.Alignment.Value -= 15
					end
					return {
						speaker = "Master Assassin";
						msg = "Nice one, great splendors await.";
						endchoice = "Bye";
					}
				end
			end
		end		
		if p:FindFirstChild("ChaoticMission") then
			if p:FindFirstChild("ChaoticMission").Value == nil or p:FindFirstChild("ChaoticMission").Value.Parent ~= game.Players then
				p:FindFirstChild("ChaoticMission"):Destroy()
				return dialogues["Master Assassin"].p1
			end
			local Target = p["ChaoticMission"].Value
			local TargetData = game.ServerStorage.PlayerData:FindFirstChild(p:FindFirstChild("ChaoticMission").Value.Name)
			if not TargetData then
				p["ChaoticMission"]:Destroy()
				return dialogues["Master Assassin"].p1
			end
			if Target.Character and Target.Character.Humanoid.DisplayName then
				return {
					speaker = "Master Assassin";
					msg = "%"..Target.Character.Humanoid.DisplayName.."% has been spotted near %"..game.ServerStorage.PlayerData:FindFirstChild(Target.Name).Area.Value.."%, how about you bring them back here?";
					endchoice = "Bye";
				}
			else
				return {
					speaker = "Master Assassin";
					msg = "%"..Target.leaderstats.FirstName.Value.."% has been spotted near %"..game.ServerStorage.PlayerData:FindFirstChild(Target.Name).Area.Value.."%, how about you bring them back here?";
					endchoice = "Bye";
				}
			end
		else
			return dialogues["Master Assassin"].p1
		end
	elseif v.page == 2 then
		if #game.Players:GetPlayers() <= 1 then
			return dialogues["Master Assassin"].p2
		end
		local stringgreat = ""
		for i,v in pairs(game.Players:GetPlayers()) do
			if v ~= p and game.ServerStorage.PlayerData:FindFirstChild(v.Name) and v:FindFirstChild("leaderstats") and v.Character and v.Character.Humanoid.DisplayName then
				stringgreat ..= v.Character.Humanoid.DisplayName.." = "..game.ServerStorage.PlayerData:FindFirstChild(v.Name).Area.Value.. " "
			end
		end
		return {
			speaker = "The Snitch";
			msg = stringgreat;
			endchoice = "Bye";
		}
	end
end

dialogues["Bounty Officer"].v1 = function(p,v)
	local character = p.Character
	if v.page == 1 then
		if p:FindFirstChild("Grabbing") then
			local Carrying = p:FindFirstChild("Grabbing")
			local CarryPlayer = game.Players:GetPlayerFromCharacter(Carrying.Value)
			if CarryPlayer then
				if CarryPlayer == p:FindFirstChild("OrderlyMission").Value then
					commands["CarryDrop"](character)
					CarryPlayer.Character:BreakJoints()
					local PData = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
					p:FindFirstChild("OrderlyMission"):Destroy()
					if PData then
						commands["ChangeMoney"](p, PData, 100, true)
						PData.Alignment.Value += 15
					end
					return {
						speaker = "Bounty Officer";
						msg = "Nice one, tell me if you need anymore bounties.";
						endchoice = "Bye";
					}
				end
			end
		end		
		if p:FindFirstChild("OrderlyMission") then
			if p:FindFirstChild("OrderlyMission").Value == nil or p:FindFirstChild("OrderlyMission").Value.Parent ~= game.Players then
				p:FindFirstChild("OrderlyMission"):Destroy()
				return dialogues["Bounty Officer"].p1
			end
			local Target = p["OrderlyMission"].Value
			local TargetData = game.ServerStorage.PlayerData:FindFirstChild(p:FindFirstChild("OrderlyMission").Value.Name)
			if not TargetData then
				p["OrderlyMission"]:Destroy()
				return dialogues["Bounty Officer"].p1
			end
			if Target.Character and Target.Character.Humanoid.DisplayName then
				return {
					speaker = "Bounty Officer";
					msg = "Ah, it appears %"..Target.Character.Humanoid.DisplayName.."% has been spotted near %"..game.ServerStorage.PlayerData:FindFirstChild(Target.Name).Area.Value.."% recently, how about you bring them back here?";
					endchoice = "Bye";
				}
			else
				return {
					speaker = "Bounty Officer";
					msg = "Ah, it appears %"..Target.leaderstats.FirstName.Value.."% has been spotted near %"..game.ServerStorage.PlayerData:FindFirstChild(Target.Name).Area.Value.."% recently, how about you bring them back here?";
					endchoice = "Bye";
				}
			end
		else
			return dialogues["Bounty Officer"].p1
		end
	elseif v.page == 2 then
		if #game.Players:GetPlayers() <= 1 then
			return dialogues["Bounty Officer"].p2
		end
		local stringgreat = ""
		for i,v in pairs(game.Players:GetPlayers()) do
			if v ~= p and game.ServerStorage.PlayerData:FindFirstChild(v.Name) and v:FindFirstChild("leaderstats") and v.Character and v.Character.Humanoid.DisplayName then
				stringgreat ..= v.Character.Humanoid.DisplayName.." = "..game.ServerStorage.PlayerData:FindFirstChild(v.Name).Area.Value.. " "
			end
		end
				return {
					speaker = "The Snitch";
					msg = stringgreat;
					endchoice = "Bye";
				}
	end
end


function dialogues.Gharnef.v1(p,v)
	local teaccheck = teachskill(p,classdata.Scholar,true)
	if teaccheck ~= "max" then
		return dialogues["Big Hoss"].no
	end
	local teach = teachskill(p,classdata.Necromancer,true)
	if v.page == 1 then
		if teach == "notmax"then
			return dialogues.Gharnef.p1
		elseif teach == "max"then
			return dialogues.Gharnef.max
		elseif teach == "no"then
			return dialogues.Gharnef.no
		end
	elseif v.page == 2 then
		return dialogues.Gharnef.p2
	elseif v.page == 3 then
		local teach = teachskill(p,classdata.Necromancer)
		if teach == "gotskill"then
			return dialogues.Gharnef.gotskill
		elseif teach == "poor"then
			return dialogues.Gharnef.poor
		end
	end
end


function dialogues.Charles.v1(p,v)



	local teach = teachskill(p,classdata["Necromancer"],true)
	if teach ~= "max"then
		return dialogues.Charles.no
	end
	if v.page == 1 then
		local teach = teachskill(p,classdata["Master Necromancer"],true)
		if teach == "notmax"then
			return dialogues.Charles.p1
		elseif teach == "max"then
			return dialogues.Charles.max
		elseif teach == "no"then
			return dialogues.Charles.no
		end
	elseif v.page == 2 then
		return dialogues.Charles.p2
	elseif v.page == 3 then
		local teach = teachskill(p,classdata["Master Necromancer"])
		if teach == "gotskill"then
			return dialogues.Charles.gotskill
		elseif teach == "poor"then
			return dialogues.Charles.poor
		end
	end
end

dialogues["Inn Keeper"].v1 = function(p,v)
	if v.page == 1 then
		return dialogues["Inn Keeper"].p1
	elseif v.page == 2 then
		local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
		if not data or not p.Character then
			return
		end
		data.SpawnPoint.Value = v.npc.Location.Value
		return dialogues["Inn Keeper"].p2
	end
end
dialogues["Fungorian"].v1 = function(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	if v.page == 1 and data.Race.Value == "Scroom" then
		return dialogues["Fungorian"].p1
	elseif v.page == 1 and data.Race.Value ~= "Scroom" then
		return dialogues["Fungorian"].noscroom
	end
end
dialogues["Fungtor"].v1 = function(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	if v.page == 1 and data.Race.Value == "Scroom" then
		return dialogues["Fungtor"].p1
	elseif v.page == 1 and data.Race.Value ~= "Scroom" then
		return dialogues["Fungtor"].noscroom
	end
end
dialogues["Gerich"].v1 = function(p,v)
	local PData = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if v.page == 1 then
		return dialogues["Gerich"].p1
	elseif v.page == 2 then
		if commands.ChangeMoney(p,PData,-6) then
			commands.AddToInventory(p, "Vint")
			return dialogues["Gerich"].p2
		else
			return dialogues["Gerich"].nomoney
		end
	end
end
dialogues["Vincent"].v1 = function(p,v)
	local PData = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if v.page == 1 then
		return dialogues["Vincent"].p1
	elseif v.page == 2 then
		if commands.ChangeMoney(p,PData,-6) then
			commands.AddToInventory(p, "Vint")
			return dialogues["Vincent"].p2
		else
			return dialogues["Vincent"].nomoney
		end
	end
end
dialogues["Johann"].v1 = function(p,v)
	local PData = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if v.page == 1 then
		return dialogues["Johann"].p1
	elseif v.page == 2 then
		if commands.ChangeMoney(p,PData,-6) then
			commands.AddToInventory(p, "Vint")
			return dialogues["Johann"].p2
		else
			return dialogues["Johann"].nomoney
		end
	end
end
dialogues["Fungkeeper"].v1 = function(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	if v.page == 1 and data.Race.Value == "Scroom" then
		return dialogues["Fungkeeper"].p1
	elseif v.page == 1 and data.Race.Value ~= "Scroom" then
		return dialogues["Fungkeeper"].noscroom
	elseif v.page == 2 then
		local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
		if not data or not p.Character then
			return
		end
		data.SpawnPoint.Value = v.npc.Location.Value
		return dialogues["Fungkeeper"].p2
	end
end

dialogues.Sevier.v1 = function(p,v)
	if v.page == 1 then
		return dialogues.Sevier.p1
	elseif v.page == 2 then
		local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
		if not data or not p.Character then
			return
		end
		data.SpawnPoint.Value = v.npc.Location.Value
		return dialogues.Sevier.p2
	end
end

dialogues.Orodin.v1 = function(p,v)
	if v.page == 1 then
		return dialogues.Orodin.p1
	elseif v.page == 2 then
		local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
		if not data or not p.Character then
			return
		end
		data.SpawnPoint.Value = v.npc.Location.Value
		return dialogues.Orodin.p2
	end
end
dialogues.Adralik.v1 = function(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	local globaldata = game.ServerStorage.PlayerData:FindFirstChild(p.Name.."Global")
	local StoryMarker
	if data and data.StoryMarker.Value then
		StoryMarker = game:GetService("HttpService"):JSONDecode(data.StoryMarker.Value)
	end
	if v.page == 1 then
		if StoryMarker and StoryMarker["Ascension"] then
			if StoryMarker["Ascension"]["Azael"]  then
				if StoryMarker["Ascension"]["Azael"] == "Started" then
					return dialogues.Adralik.p1 
				elseif StoryMarker["Ascension"]["Azael"] == "Obelisks" then
					if CheckAzaelAscension(p) then
						StoryMarker["Ascension"]["Azael"] = "RiftGem"
						StoryMarker["NoGate"] = false
						data.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
						if game:GetService("HttpService"):JSONDecode(globaldata.GlobalQuests.Value)["Ascensions"] and game:GetService("HttpService"):JSONDecode(globaldata.GlobalQuests.Value)["Ascensions"]["Azael"] == true then
							StoryMarker["Ascension"]["Azael"] = "As'endo"
							StoryMarker["Ascension"]["NoAs'endo"] = false
							data.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
							return dialogues.Adralik.riftgem
						end
						return dialogues.Adralik.returnfinished
					else
						return dialogues.Adralik.returnnofinished
					end
				elseif StoryMarker["Ascension"]["Azael"] == "RiftGem" then
					return dialogues.Adralik.returnriftgem
				end
			end
		end
		return dialogues.Adralik.notquest
	elseif v.choice == "You're Adralik?" then
		return dialogues.Adralik.p2
	elseif v.choice == "I've been told to seek you out" then
		return dialogues.Adralik.p3
	elseif v.choice == "That's correct" then
		return dialogues.Adralik.p4
	elseif v.choice == "Uh... No" then
		return dialogues.Adralik.p5
	elseif v.choice == "It's my job to enable it?" then
		return dialogues.Adralik.p6
	elseif v.choice == "Alright" then
		StoryMarker["Ascension"]["Azael"] = "Obelisks"
		StoryMarker["Obelisks"] = {}
		StoryMarker["NoGate"] = true
		data.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
		commands.Learn(p,v)
		return dialogues.Adralik.p7
	elseif v.choice == "..." then
		return dialogues.Adralik.p8
	elseif v.choice == "Here you go" then
		if p.Character:FindFirstChild("Rift Gem") or p.Backpack:FindFirstChild("Rift Gem") then
			if p.Character:FindFirstChild("Rift Gem") then
				p.Character:FindFirstChild("Rift Gem"):Destroy()
				commands.RemoveFromInventory(p,"Rift Gem")
			else
				p.Backpack:FindFirstChild("Rift Gem"):Destroy()
				commands.RemoveFromInventory(p,"Rift Gem")
			end
			StoryMarker["Ascension"]["Azael"] = "As'endo"
			StoryMarker["Ascension"]["NoAs'endo"] = false
			data.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
			return dialogues.Adralik.riftgem
		else
			return dialogues.Adralik.noriftgem
		end
	elseif v.choice == "My Ascension?" then
		return dialogues.Adralik.riftgem2
	end
end
dialogues.Squeltch.v1 = function(p,v)
	if v.page == 1 then
		return dialogues.Squeltch.p1
	elseif v.page == 2 then
		local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
		if not data or not p.Character then
			return
		end
		if commands.ChangeMoney(p,data,-4000)then
			data.FirstName.Value = randomize_.FirstName(data.Race.Value,data.Gender.Value)
			return dialogues.Squeltch.bought
		else
			return dialogues.Squeltch.poor
		end
	end
end

local OresGate = workspace.Map:FindFirstChild'ORESFALLGATE'
if OresGate then
	local gatemodule = require(OresGate.GateModule)
	local gate2 = OresGate.GateModule
	dialogues.Steve.v1 = function(p,v)
		local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
		if not data or not p.Character then
			return
		end
		if v.page == 1 then
			if gate2.Opened.Value == false then
				return dialogues.Steve.p1
			else
				return dialogues.Steve.no
			end
		elseif v.page == 2 then
			if commands.ChangeMoney(p,data,-10)then
				spawn(function()
					gatemodule.Pay()
				end)
				return dialogues.Steve.bought
			else
				return dialogues.Steve.poor
			end
		end
	end
end

function dialogues.Engineer.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	if data.Race.Value ~= "Gaian" and data.Race.Value ~= "Metascroom" then
		if data.MetalArm.Value == false then
			if v.page == 1 then
				return dialogues.Engineer.human.p1
			elseif v.page == 2 then
				return dialogues.Engineer.human.p2
			elseif v.page == 3 then
				if commands.ChangeMoney(p,data,-500)then
					commands["Metal Arm"](p)
					return dialogues.Engineer.human.p4
				else
					return dialogues.Engineer.poor
				end
			end
		else
			if v.page == 1 then
				return dialogues.Engineer.human.p3
			elseif v.page == 2 then
				if commands.ChangeMoney(p,data,-1000)then
					data.MetalArm.Value = false
					local arm = p.Character:FindFirstChild("Arm")
					local plate = p.Character:FindFirstChild("ArmPlate")
					if arm then
						arm:Destroy()
					end
					if plate then
						plate:Destroy()
					end
					p.Character["Left Arm"].Transparency = 0
					return dialogues.Engineer.human.p4
				else
					return dialogues.Engineer.poor
				end
			end
		end
	elseif data.Race.Value == "Gaian" then
		if data.Armor.Value ~= "GaianChaotic"then
			if v.page == 1 then
				return dialogues.Engineer.gaian.p1
			elseif v.page == 2 then
				if commands.ChangeMoney(p,data,-500)then
					commands.ChangeArmor(p,"GaianChaotic")
					return dialogues.Engineer.gaian.p2
				else
					return dialogues.Engineer.poor
				end
			end
		else
			if v.page == 1 then
				return dialogues.Engineer.gaian.injuries
			elseif v.page == 2 then
				if commands.ChangeMoney(p,data,-30) then
					local crazy = ""
					local Unfixable = {"MetalArm","vampirism","armless"}
					for i,v in pairs(Unfixable) do 
						if data.Injuries.Value:find(v) then
							crazy = crazy..","..v
						end
					end
					data.Injuries.Value = ""
					data.Injuries.Value = crazy
					return dialogues.Engineer.gaian.fixed
				else
					return dialogues.Engineer.poor
				end
			end
		end
	end
end
function dialogues.Cu.v1(p,v)
	if v.page == 1 then
		local teach = teachskill(p,classdata.Spear,true)
		if teach == "notmax"then
			return dialogues.Cu.p1
		elseif teach == "max"then
			return dialogues.Cu.max
		elseif teach == "no"then
			return dialogues.Cu.no
		end
	elseif v.page == 2 then
		local teach = teachskill(p,classdata.Spear)
		if teach == "gotskill"then
			game.ServerStorage.PlayerData:FindFirstChild(p.Name).BaseSpear.Value = true
			return dialogues.Cu.p2
		elseif teach == "poor"then
			return dialogues.Cu.p3
		end
	end
end
function dialogues.Kyley.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	local skills = string.split(data.Skills.Value,",")
	if not table.find(skills,"Sigil Helmet")then
		table.insert(skills,"Sigil Helmet")
		data.Skills.Value = table.concat(skills,",")
		commands.Learn(p)
		return dialogues.Kyley.p1
	end
	return dialogues.Kyley.p2
end
function dialogues.Dorgza.v1(p, v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data then
		return
	end
	if v.page == 1 then
		return {speaker = "Dorgza",
			msg = "Want one of Dorgza's specials? (6 Money)",
			choices = {"Yes, please."},
			endchoice = "Bye."
		}
	elseif v.page == 2 then
		if commands.ChangeMoney(p, data, -6, true) then
			commands.AddToInventory(p, math.random(1,3) == 1 and "Pizza" or math.random(1,3) == 2 and "Pork Bun" or math.random(1,3) == 3 and "Meat" or "Meat")
			commands.ChangeMoney(p, data, -6)
			return {speaker = "Dorgza",
				msg = "Enjoy Dorgza's specialty!",
				endchoice = "Bye."
			}
		else
			return {speaker = "Dorgza",
				msg = "You poor, Dorgza no sell food to poor man.",
				endchoice = "Bye."
			}
		end
	end
end
function dialogues.Draug.v1(p, v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data then
		return
	end
	if v.page == 1 then
		return {speaker = "Draug",
			msg = "Welcome to castle sanctuary, "..data.FirstName.Value,
			endchoice = "Bye."
		}
	end
end
function dialogues.Dorgan.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data then
		return
	end
	if v.page == 1 then
		if data.Skills.Value:find("PoisonCrafting") then
			return {
				speaker = "Dorgan";
				msg = "Want some meat? (4 Money)";
				choices = {"Alright.","3 Meat.", "Poison the food [Hold the poison]"};
				endchoice = "Bye";
			}
		else
			return dialogues.Dorgan.p1
		end
	elseif v.page == 2 then

		local poisonmode = "None"
		for i,v in pairs(workspace.NPCs:GetChildren()) do
			if v.Name == "Dorgan" and (v.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude <= 30 and v:FindFirstChild("Poisoned") then
				poisonmode = v.Poisoned.Value
			end
		end


		if v.choice == "Alright."then
			if commands.ChangeMoney(p,playerdata[p.Name],-4)then
				if not game.ServerStorage.PlayerData[p.Name].Inventory.Value:find("Frying Pan") and poisonmode == "None" then
					commands.AddToInventory(p,"Meat")
				elseif poisonmode == "None" and game.ServerStorage.PlayerData[p.Name].Inventory.Value:find("Frying Pan") then
					commands.AddToInventory(p,"Uncooked Meat")
				else
					commands.AddToInventory(p, poisonmode.."ous Meat")
				end

				return dialogues.Dorgan.p2
			else
				return dialogues.Dorgan.p3
			end
		elseif v.choice == "3 Meat."then
			if commands.ChangeMoney(p,playerdata[p.Name],-12)then
				for i = 1,3 do
					if not game.ServerStorage.PlayerData[p.Name].Inventory.Value:find("Frying Pan") and poisonmode == "None" then
						commands.AddToInventory(p,"Meat")
					elseif poisonmode == "None" and game.ServerStorage.PlayerData[p.Name].Inventory.Value:find("Frying Pan") then
						commands.AddToInventory(p,"Uncooked Meat")
					else
						commands.AddToInventory(p, poisonmode.."ous Meat")
					end

				end
				return dialogues.Dorgan.p2
			else
				return dialogues.Dorgan.p3
			end
		elseif v.choice == "50 MEATS!!!" then
			if commands.ChangeMoney(p,playerdata[p.Name],-200)then
				for i = 1,50 do
					if not game.ServerStorage.PlayerData[p.Name].Inventory.Value:find("Frying Pan") and poisonmode == "None" then
						commands.AddToInventory(p,"Meat")
					elseif poisonmode == "None" and game.ServerStorage.PlayerData[p.Name].Inventory.Value:find("Frying Pan") then
						commands.AddToInventory(p,"Uncooked Meat")
					else
						commands.AddToInventory(p, poisonmode.."ous Meat")
					end

				end
				return dialogues.Dorgan.p2
			else
				return dialogues.Dorgan.p3
			end
		elseif v.choice == "Poison the food [Hold the poison]" then
			local tool = p.Character:FindFirstChildOfClass("Tool")
			if not tool then
				return {speaker = "Dorgan",
					msg = "Dorgan no want.",
					endchoice = "Bye."
				}
			end
			if tool:FindFirstChild("PoisonValue") and not string.find(tool.Name, "Cure") then
				for i,v in pairs(workspace.NPCs:GetChildren()) do
					if v.Name == "Dorgan" and (p.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude <= 30 and not v:FindFirstChild("Poisoned") and data.Skills.Value:find("PoisonGod") then
						local a = Instance.new("StringValue")
						a.Name = "Poisoned"
						a.Value = tool.Name
						a.Parent = v
						game.Debris:AddItem(a, 180)
					end
				end
			end
		end
	end
end
function dialogues.Dorgoth.v1(p,v)
	if v.page == 1 then
		return dialogues.Dorgoth.p1
	elseif v.page == 2 then
		if v.choice == "Alright."then
			if commands.ChangeMoney(p,playerdata[p.Name],-4)then
				commands.AddToInventory(p,"Turnip")
				return dialogues.Dorgoth.p2
			else
				return dialogues.Dorgoth.p3
			end
		elseif v.choice == "3 Turnips."then
			if commands.ChangeMoney(p,playerdata[p.Name],-12)then
				for i = 1,3 do
					commands.AddToInventory(p,"Turnip")
				end
				return dialogues.Dorgoth.p2
			else
				return dialogues.Dorgoth.p3
			end
		end
	end
end
function dialogues.Yeti.v1(p, v)
	if v.page == 1 then
		if p.Backpack:FindFirstChild("Strange Feather") ~= nil or p.Character:FindFirstChild("Strange Feather") ~= nil then
			return dialogues.Yeti.alreadyhas
		else
			return dialogues.Yeti.take
		end
	elseif v.page == 2 then
		if v.choice == "Sure." then
			if p.Backpack:FindFirstChild("Strange Feather") ~= nil or p.Character:FindFirstChild("Strange Feather") ~= nil then
				return dialogues.Yeti.alreadyhas
			else
				commands.AddToInventory(p, "Strange Feather")
				return dialogues.Yeti.thanks
			end
		end
	end
end
function dialogues.Willow.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	if v.page == 1 then
		return dialogues.Willow.p1
	elseif v.page == 2 then
		local spawns = game.ServerStorage.SpawnPoints[data.SpawnPoint.Value]:GetChildren()
		local chosenspawn = spawns[math.random(1,#spawns)]
		local tpsafe = Instance.new("Vector3Value")
		tpsafe.Name = "TPSafe"
		tpsafe.Value = chosenspawn.Position
		tpsafe.Parent = p.Character
		game:GetService("Debris"):AddItem(tpsafe,1)
		p.Character:SetPrimaryPartCFrame(chosenspawn.CFrame)
		return dialogues.Willow.exit
	end
end

function dialogues.Timothy.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	if v.page == 1 then
		return dialogues.Timothy.p1
	end
end

function dialogues.Golis.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end

	if p.Character:FindFirstChild("Wooden Chair") or p.Backpack:FindFirstChild("Wooden Chair") then 
		return dialogues.Golis.p2
	end

	if v.page == 1 then
		return dialogues.Golis.p1
	elseif v.page == 2 then
		if v.choice == "Sure." then
			data.Skills.Value ..= ",Wooden Chair"
			return dialogues.Golis.p2
		end
	end
end
function dialogues.Feltr.v1(p,v)
	if v.page == 1 then
		return dialogues.Feltr.p1
	end
end
function dialogues.Ferin.v1(p,v)
	if v.page == 1 then
		return dialogues.Ferin.p1
	end
end
function dialogues.Ezlo.v1(p,v)
	if v.page == 1 then
		return dialogues.Ezlo.p1
	elseif v.page == 2 then
		local tool = p.Character:FindFirstChildWhichIsA("Tool")
		if tool and tool:FindFirstChild("Gem")and tool.Name ~="Rift Gem"then
			commands.RemoveFromInventory(p,tool.Name)
			local tpsafe = Instance.new("Vector3Value")
			tpsafe.Name = "TPSafe"
			tpsafe.Value = game.ServerStorage.WarpPoints.Skycastle.SkyTP.Position
			tpsafe.Parent = p.Character
			game:GetService("Debris"):AddItem(tpsafe,1)
			create("NoFall",1,p.Character)
			task.wait()
			p.Character:SetPrimaryPartCFrame(game.ServerStorage.WarpPoints.Skycastle.SkyTP.CFrame)
			return dialogues.Ezlo.exit
		else
			return dialogues.Ezlo.p2
		end
	end
end

local ultraclass = {
	"Faceless",
	"Oni",
	"Whisper",
	"Shinobi",
	"SigilKnightCommander",
	"Ronin",
	"DeepKnight",
	"Lapidarist",
	"AbyssWalker",
	"DragonSlayer",
	"Florist",
	"Master Necromancer",
	"DragonSage",
	"Master Illusionist",
	"Wanderer",
	"Templar",
	"Vanguard",
}

dialogues["The Eagle"].v1 = function(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	if data.IsUltra.Value ~= true and data.Hybrid.Value ~= "" then
		return dialogues["The Eagle"].no
	end
	if p.Backpack:FindFirstChild("Strange Feather") == nil and p.Character:FindFirstChild("Strange Feather") == nil then
		return dialogues["The Eagle"].no
	end
	--	if not game.ServerStorage.Requests.Captcha:Invoke(p) then do return end end
	if v.page == 1 then
		return dialogues["The Eagle"].p1
	end
	if v.page == 2 then
		local InCR = Instance.new("BoolValue")
		InCR.Name = "INCR"
		InCR.Parent = p.Character
		p.Character:SetPrimaryPartCFrame(CFrame.new(4547.28, 741.044, 474.431))
		return dialogues.exit
	end
end

local function checkforobelisk(move, exception, attuneddata)
	if (attuneddata["Deepforest"] == move and exception ~= "Deepforest") or
		(attuneddata["Desert"] == move and exception ~= "Desert") or
		(attuneddata["Forest"] == move and exception ~= "Forest") or
		(attuneddata["Shore"] == move and exception ~= "Shore") or
		(attuneddata["Sigil"] == move and exception ~= "Sigil") or
		(attuneddata["Skycastle"] == move and exception ~= "Skycastle") or
		(attuneddata["Snail"] == move and exception ~= "Snail") or
		(attuneddata["Tundra"] == move and exception ~= "Tundra")
	then
		return false
	else
		return true
	end
end

function dialogues.Currin.v1(p,v)
	if v.page == 1 then
		return dialogues.Currin.p1
	elseif v.page == 2 then
		return dialogues.Currin.p2
	elseif v.page == 3 then
		return dialogues.Currin.p3
	elseif v.page == 4 then
		return dialogues.Currin.p4
	elseif v.page == 5 then
		return dialogues.Currin.p5
	end
end

function dialogues.ObeliskDesert.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	local StoryMarker
	local lastused = p.Character.LastUsed.Value
	local attuned = game:GetService("HttpService"):JSONDecode(data.Attuned.Value)
	if data and data.StoryMarker.Value then
		StoryMarker = game:GetService("HttpService"):JSONDecode(data.StoryMarker.Value)
	end
	if v.page == 1 then
		if data.Race.Value == "Azael" and data.Ascended.Value == true then
			return dialogues.Obelisk.ascended
		end
		if StoryMarker["Ascension"] then
			if StoryMarker["Ascension"]["Azael"] and StoryMarker["Ascension"]["Azael"] == "Obelisks" then
				if not table.find(StoryMarker["Obelisks"], "Desert") then
					return dialogues.Obelisk.p1
				else
					return dialogues.Obelisk.Resonated
				end
			end
		end
		return dialogues.Obelisk.p3;
	elseif v.page == 2 and v.choice == "Resonate" then
		table.insert(StoryMarker["Obelisks"], "Desert")
		data.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
		commands.Learn(p);
		return dialogues.Obelisk.p2;
	elseif v.choice == "Attune Skill" then
		if lastused ~= "" and attuned["Desert"] ~= lastused then
			return {
				speaker = "...",
				msg = "Would you like to attune "..lastused.." with the Desert Obelisk?",
				choices = {"Yes"},
				endchoice = "...",
			};
		else
			return {
				speaker = "...",
				msg = "Looking at the obelisk, you think to yourself: _What am I doing here?_",
				endchoice = "...",
			};
		end
	elseif v.choice == "Yes" then
		commands.Learn(p)
		attuned["Desert"] = lastused
		if attuned["Deepforest"] == lastused then
			attuned["Deepforest"] = ""
		end
		if attuned["Forest"] == lastused then
			attuned["Forest"] = ""
		end
		if attuned["Shore"] == lastused then
			attuned["Shore"] = ""
		end
		if attuned["Sigil"] == lastused then
			attuned["Sigil"] = ""
		end
		if attuned["Skycastle"] == lastused then
			attuned["Skycastle"] = ""
		end
		if attuned["Snail"] == lastused then
			attuned["Snail"] = ""
		end
		if attuned["Tundra"] == lastused then
			attuned["Tundra"] = ""
		end
		data.Attuned.Value = game:GetService("HttpService"):JSONEncode(attuned)
		return {
			speaker = "...",
			msg = "You've attuned "..lastused.." with the Desert Obelisk",
			endchoice = "...",
		};
	end
end
function dialogues.ObeliskShore.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	local lastused = p.Character.LastUsed.Value
	local attuned = game:GetService("HttpService"):JSONDecode(data.Attuned.Value)
	local StoryMarker
	if data and data.StoryMarker.Value then
		StoryMarker = game:GetService("HttpService"):JSONDecode(data.StoryMarker.Value)
	end
	if v.page == 1 then
		if data.Race.Value == "Azael" and data.Ascended.Value == true then
			return dialogues.Obelisk.ascended
		end
		if StoryMarker["Ascension"] then
			if StoryMarker["Ascension"]["Azael"] and StoryMarker["Ascension"]["Azael"] == "Obelisks" then
				if not table.find(StoryMarker["Obelisks"], "Shore") then
					return dialogues.Obelisk.p1
				else
					return dialogues.Obelisk.Resonated
				end
			end
		end
		return dialogues.Obelisk.p3;
	elseif v.page == 2 and v.choice == "Resonate" then
		table.insert(StoryMarker["Obelisks"], "Shore")
		data.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
		commands.Learn(p);
		return dialogues.Obelisk.p2;
	elseif v.choice == "Attune Skill" then
		if lastused ~= "" and attuned["Shore"] ~= lastused then
			return {
				speaker = "...",
				msg = "Would you like to attune "..lastused.." with the Shore Obelisk?",
				choices = {"Yes"},
				endchoice = "...",
			};
		else
			return {
				speaker = "...",
				msg = "Looking at the obelisk, you think to yourself: _What am I doing here?_",
				endchoice = "...",
			};
		end
	elseif v.choice == "Yes" then
		commands.Learn(p)
		attuned["Shore"] = lastused
		if attuned["Deepforest"] == lastused then
			attuned["Deepforest"] = ""
		end
		if attuned["Desert"] == lastused then
			attuned["Desert"] = ""
		end
		if attuned["Forest"] == lastused then
			attuned["Forest"] = ""
		end
		if attuned["Sigil"] == lastused then
			attuned["Sigil"] = ""
		end
		if attuned["Skycastle"] == lastused then
			attuned["Skycastle"] = ""
		end
		if attuned["Snail"] == lastused then
			attuned["Snail"] = ""
		end
		if attuned["Tundra"] == lastused then
			attuned["Tundra"] = ""
		end
		data.Attuned.Value = game:GetService("HttpService"):JSONEncode(attuned)
		return {
			speaker = "...",
			msg = "You've attuned "..lastused.." with the Shore Obelisk",
			endchoice = "...",
		};
	end
end
function dialogues.ObeliskForest.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	local lastused = p.Character.LastUsed.Value
	local attuned = game:GetService("HttpService"):JSONDecode(data.Attuned.Value)
	local StoryMarker
	if data and data.StoryMarker.Value then
		StoryMarker = game:GetService("HttpService"):JSONDecode(data.StoryMarker.Value)
	end
	if v.page == 1 then
		if data.Race.Value == "Azael" and data.Ascended.Value == true then
			return dialogues.Obelisk.ascended
		end
		if StoryMarker["Ascension"] then
			if StoryMarker["Ascension"]["Azael"] and StoryMarker["Ascension"]["Azael"] == "Obelisks" then
				if not table.find(StoryMarker["Obelisks"], "Forest") then
					return dialogues.Obelisk.p1
				else
					return dialogues.Obelisk.Resonated
				end
			end
		end
		return dialogues.Obelisk.p3;
	elseif v.page == 2 and v.choice == "Resonate" then
		table.insert(StoryMarker["Obelisks"], "Forest")
		data.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
		commands.Learn(p);
		return dialogues.Obelisk.p2;
	elseif v.choice == "Attune Skill" then
		if lastused ~= "" and attuned["Forest"] ~= lastused then
			return {
				speaker = "...",
				msg = "Would you like to attune "..lastused.." with the Forest Obelisk?",
				choices = {"Yes"},
				endchoice = "...",
			};
		else
			return {
				speaker = "...",
				msg = "Looking at the obelisk, you think to yourself: _What am I doing here?_",
				endchoice = "...",
			};
		end
	elseif v.choice == "Yes" then
		commands.Learn(p)
		attuned["Forest"] = lastused
		if attuned["Deepforest"] == lastused then
			attuned["Deepforest"] = ""
		end
		if attuned["Desert"] == lastused then
			attuned["Desert"] = ""
		end
		if attuned["Shore"] == lastused then
			attuned["Shore"] = ""
		end
		if attuned["Sigil"] == lastused then
			attuned["Sigil"] = ""
		end
		if attuned["Skycastle"] == lastused then
			attuned["Skycastle"] = ""
		end
		if attuned["Snail"] == lastused then
			attuned["Snail"] = ""
		end
		if attuned["Tundra"] == lastused then
			attuned["Tundra"] = ""
		end
		data.Attuned.Value = game:GetService("HttpService"):JSONEncode(attuned)
		return {
			speaker = "...",
			msg = "You've attuned "..lastused.." with the Forest Obelisk",
			endchoice = "...",
		};
	end
end
function dialogues.Wayfinder.v1(p,v)
	if v.page == 1 then
		local data = game.ServerStorage.PlayerData[p.Name]
		if data.EdictType.Value == "" then
			return dialogues.Wayfinder.p3
		else
			return dialogues.Wayfinder.p1
		end
	elseif v.page == 2 and v.choice == "Yes. (Wipe edict)" then
		local data = game.ServerStorage.PlayerData[p.Name]
		local ed = data.EdictType.Value
		data.EdictType.Value = ""
		data.EdictProgression.Value = 0
		data.EdictWipes.Value = 0
		game.ServerStorage.Requests.SendWebhook:Fire(
			"Edict Update",
			p.Name.." ("..p.UserId..")".." has decided to get rid of "..ed,
			"cyan"
		)
		return dialogues.Wayfinder.p2
	end
end
function dialogues.Igor.v1(p,v)
	if v.page == 1 then
		local data = game.ServerStorage.PlayerData[p.Name]
		if data.Artifact.Value ~= "" or data.PrimaryWeapon.Value == "Fairfrozen" then
			return dialogues.Igor.hasArtifact
		else
			return dialogues.Igor.doesntHave
		end
	elseif v.page == 2 and v.choice == "Sure." then
		local data = game.ServerStorage.PlayerData[p.Name]
		if data.Money.Value >= 5000 and ((data.Artifact.Value ~= "" and data.Artifact.Value ~= "None") or data.PrimaryWeapon.Value == "Fairfrozen") then
			commands.ChangeMoney(p,data,-5000)
			game.ReplicatedStorage.Requests.MoneyChanged:FireClient(p,data.Money.Value)
			if data.Artifact.Value ~= "" then
				if data.Artifact.Value == "Fairfrozen" then
					data.PrimaryWeapon.Value = "None"
				elseif data.Artifact.Value == "Spider Cloak" or data.Artifact.Value == "SpiderCloak" then
					data.Armor.Value = "Rags"
				elseif data.Artifact.Value == "Lannis" then
					if p.Character.Artifacts:FindFirstChild("Lannis") then
						p.Character.Artifacts:FindFirstChild("Lannis"):Destroy()
					end
				elseif data.Artifact.Value == "Philo" then
					if p.Character.Artifacts:FindFirstChild("Philo") then
						p.Character.Artifacts:FindFirstChild("Philo"):Destroy()
					end
				elseif data.Artifact.Value == "Nightstone" then
					pcall(function()
						local hasns = false
						for _,v in pairs(game.ServerStorage.PlayerData:GetChildren()) do
							if v ~= data and v:FindFirstChild("Artifact") and v.Artifact.Value == "Nightstone" then
								hasns = true
							end
						end
						if hasns == false then
							if workspace:FindFirstChild("NightStoneActive") then
								workspace.NightStoneActive:Destroy()
							end
						end
					end)
				end
				data.Artifact.Value = "None"
			elseif data.PrimaryWeapon.Value == "Fairfrozen" then
				data.PrimaryWeapon.Value = "None"
			end
			return dialogues.Igor.success
		elseif data.Money.Value < 5000 and (data.Artifact.Value ~= "" or data.PrimaryWeapon.Value == "Fairfrozen")	then
			return dialogues.Igor.broke
		end
		return dialogues.Igor.doesntHave
	end
end
local canlearnobelisk = false
_G.FriendlyFire = false
local off = false
--[[function dialogues.ObeliskNorpa.v1(p,v)
	if v.page == 1 then
		local hasGate = p.Backpack:FindFirstChild("Gate") or p.Character:FindFirstChild("Gate")
		local hasObelisk = p.Backpack:FindFirstChild("norpObelisk") or p.Character:FindFirstChild("norpObelisk")

		if not hasGate or hasObelisk then
			if p.UserId == 21609523 then
				if canlearnobelisk == false then
					return dialogues.ObeliskNorpa.p4
				elseif canlearnobelisk == true then
					return dialogues.ObeliskNorpa.p5
				end
			end
			return dialogues.ObeliskNorpa.p3;
		end
		if canlearnobelisk == true or (not hasObelisk and p.UserId == 21609523) then
			return dialogues.ObeliskNorpa.p1;
		else
			return dialogues.ObeliskNorpa.p7;
		end
	elseif v.page == 2 and v.choice == "Resonate" then
		local hasObelisk = p.Backpack:FindFirstChild("norpObelisk") or p.Character:FindFirstChild("norpObelisk")
		if hasObelisk then return dialogues.ObeliskNorpa.p3; end;
		local hasGate = p.Backpack:FindFirstChild("Gate") or p.Character:FindFirstChild("Gate")

		if not hasGate then
			return dialogues.ObeliskNorpa.p3;
		end
		game.ServerStorage.Classes.ForestObelisk:Clone().Parent = p.Backpack
		game.ServerStorage.PlayerData[p.Name].Skills.Value = game.ServerStorage.PlayerData[p.Name].Skills.Value..",norpObelisk,nObRequirement"
		commands.Learn(p);
		return dialogues.ObeliskNorpa.p2;
	elseif v.page == 2 and v.choice == "Enable" then
		if p.UserId == 21609523 then
			canlearnobelisk = true
			workspace.NPCs.ObeliskNorpa.HumanoidRootPart.Sound:Play()
			workspace.NPCs.ObeliskNorpa.HumanoidRootPart.on:Emit(100)
			return dialogues.ObeliskNorpa.p6; 
		end
		return dialogues.ObeliskNorpa.p3;
	elseif v.page == 2 and v.choice == "Disable" then
		if p.UserId == 21609523 then
			canlearnobelisk = false
			workspace.NPCs.ObeliskNorpa.HumanoidRootPart.soff:Play()
			workspace.NPCs.ObeliskNorpa.HumanoidRootPart.off:Emit(100)
			return dialogues.ObeliskNorpa.p8; 
		end
		return dialogues.ObeliskNorpa.p3;
	elseif v.page == 2 and v.choice == "Friendly Fire Turrets" then
		if _G.FriendlyFire == true then
			_G.FriendlyFire = false
			workspace.NPCs.ObeliskNorpa.HumanoidRootPart.soff:Play()
			workspace.NPCs.ObeliskNorpa.HumanoidRootPart.off:Emit(100)
			return dialogues.ObeliskNorpa.p8;  
		else
			_G.FriendlyFire = true
			workspace.NPCs.ObeliskNorpa.HumanoidRootPart.Sound:Play()
			workspace.NPCs.ObeliskNorpa.HumanoidRootPart.on:Emit(100)
			return dialogues.ObeliskNorpa.p6; 
		end
	elseif v.page == 2 and v.choice == "Toggle Turrets" then
		if off == true then
			off = false
			for _,v in pairs(workspace.Turrets.norp:GetChildren()) do
				v.Info.State.Value = "IDLE"
			end
			workspace.NPCs.ObeliskNorpa.HumanoidRootPart.soff:Play()
			workspace.NPCs.ObeliskNorpa.HumanoidRootPart.off:Emit(100)
			return dialogues.ObeliskNorpa.p6;  
		else
			off = true
			for _,v in pairs(workspace.Turrets.norp:GetChildren()) do
				v.Info.State.Value = "BROKEN"
			end
			workspace.NPCs.ObeliskNorpa.HumanoidRootPart.Sound:Play()
			workspace.NPCs.ObeliskNorpa.HumanoidRootPart.on:Emit(100)
			return dialogues.ObeliskNorpa.p8; 
		end
	end
end]]
function dialogues.ObeliskDeepForest.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	local lastused = p.Character.LastUsed.Value
	local attuned = game:GetService("HttpService"):JSONDecode(data.Attuned.Value)
	local StoryMarker
	if data and data.StoryMarker.Value then
		StoryMarker = game:GetService("HttpService"):JSONDecode(data.StoryMarker.Value)
	end
	if v.page == 1 then
		if data.Race.Value == "Azael" and data.Ascended.Value == true then
			return dialogues.Obelisk.ascended
		end
		if StoryMarker["Ascension"] then
			if StoryMarker["Ascension"]["Azael"] and StoryMarker["Ascension"]["Azael"] == "Obelisks" then
				if not table.find(StoryMarker["Obelisks"], "Deepforest") then
					return dialogues.Obelisk.p1
				else
					return dialogues.Obelisk.Resonated
				end
			end
		end
		return dialogues.Obelisk.p3;
	elseif v.page == 2 and v.choice == "Resonate" then
		table.insert(StoryMarker["Obelisks"], "Deepforest")
		data.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
		commands.Learn(p);
		return dialogues.Obelisk.p2;
	elseif v.choice == "Attune Skill" then
		if lastused ~= "" and attuned["Deepforest"] ~= lastused then
			return {
				speaker = "...",
				msg = "Would you like to attune "..lastused.." with the Deepforest Obelisk?",
				choices = {"Yes"},
				endchoice = "...",
			};
		else
			return {
				speaker = "...",
				msg = "Looking at the obelisk, you think to yourself: _What am I doing here?_",
				endchoice = "...",
			};
		end
	elseif v.choice == "Yes" then
		commands.Learn(p)
		attuned["Deepforest"] = lastused
		if attuned["Forest"] == lastused then
			attuned["Forest"] = ""
		end
		if attuned["Desert"] == lastused then
			attuned["Desert"] = ""
		end
		if attuned["Shore"] == lastused then
			attuned["Shore"] = ""
		end
		if attuned["Sigil"] == lastused then
			attuned["Sigil"] = ""
		end
		if attuned["Skycastle"] == lastused then
			attuned["Skycastle"] = ""
		end
		if attuned["Snail"] == lastused then
			attuned["Snail"] = ""
		end
		if attuned["Tundra"] == lastused then
			attuned["Tundra"] = ""
		end
		data.Attuned.Value = game:GetService("HttpService"):JSONEncode(attuned)
		return {
			speaker = "...",
			msg = "You've attuned "..lastused.." with the Deepforest Obelisk",
			endchoice = "...",
		};
	end
end

function dialogues.ObeliskSnail.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	local StoryMarker
	local lastused = p.Character.LastUsed.Value
	local attuned = game:GetService("HttpService"):JSONDecode(data.Attuned.Value)
	if data and data.StoryMarker.Value then
		StoryMarker = game:GetService("HttpService"):JSONDecode(data.StoryMarker.Value)
	end
	if v.page == 1 then
		if data.Race.Value == "Azael" and data.Ascended.Value == true then
			return dialogues.Obelisk.ascended
		end
		if StoryMarker["Ascension"] then
			if StoryMarker["Ascension"]["Azael"] and StoryMarker["Ascension"]["Azael"] == "Obelisks" then
				if not table.find(StoryMarker["Obelisks"], "Snail") then
					return dialogues.Obelisk.p1
				else
					return dialogues.Obelisk.Resonated
				end
			end
		end
		return dialogues.Obelisk.p3;
	elseif v.page == 2 and v.choice == "Resonate" then
		table.insert(StoryMarker["Obelisks"], "Snail")
		data.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
		commands.Learn(p);
		return dialogues.Obelisk.p2;
	elseif v.choice == "Attune Skill" then
		if lastused ~= "" and attuned["Snail"] ~= lastused then
			return {
				speaker = "...",
				msg = "Would you like to attune "..lastused.." with the Snail Obelisk?",
				choices = {"Yes"},
				endchoice = "...",
			};
		else
			return {
				speaker = "...",
				msg = "Looking at the obelisk, you think to yourself: _What am I doing here?_",
				endchoice = "...",
			};
		end
	elseif v.choice == "Yes" then
		commands.Learn(p)
		attuned["Snail"] = lastused
		if attuned["Deepforest"] == lastused then
			attuned["Deepforest"] = ""
		end
		if attuned["Desert"] == lastused then
			attuned["Desert"] = ""
		end
		if attuned["Shore"] == lastused then
			attuned["Shore"] = ""
		end
		if attuned["Sigil"] == lastused then
			attuned["Sigil"] = ""
		end
		if attuned["Skycastle"] == lastused then
			attuned["Skycastle"] = ""
		end
		if attuned["Forest"] == lastused then
			attuned["Forest"] = ""
		end
		if attuned["Tundra"] == lastused then
			attuned["Tundra"] = ""
		end
		data.Attuned.Value = game:GetService("HttpService"):JSONEncode(attuned)
		return {
			speaker = "...",
			msg = "You've attuned "..lastused.." with the Snail Obelisk",
			endchoice = "...",
		};
	end
end

function dialogues.ObeliskSigil.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	local StoryMarker
	local lastused = p.Character.LastUsed.Value
	local attuned = game:GetService("HttpService"):JSONDecode(data.Attuned.Value)
	if data and data.StoryMarker.Value then
		StoryMarker = game:GetService("HttpService"):JSONDecode(data.StoryMarker.Value)
	end
	if v.page == 1 then
		if data.Race.Value == "Azael" and data.Ascended.Value == true then
			return dialogues.Obelisk.ascended
		end
		if StoryMarker["Ascension"] then
			if StoryMarker["Ascension"]["Azael"] and StoryMarker["Ascension"]["Azael"] == "Obelisks" then
				if not table.find(StoryMarker["Obelisks"], "Sigil") then
					return dialogues.Obelisk.p1
				else
					return dialogues.Obelisk.Resonated
				end
			end
		end
		return dialogues.Obelisk.p3;
	elseif v.page == 2 and v.choice == "Resonate" then
		table.insert(StoryMarker["Obelisks"], "Sigil")
		data.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
		commands.Learn(p);
		return dialogues.Obelisk.p2;
	elseif v.choice == "Attune Skill" then
		if lastused ~= "" and attuned["Sigil"] ~= lastused then
			return {
				speaker = "...",
				msg = "Would you like to attune "..lastused.." with the Sigil Obelisk?",
				choices = {"Yes"},
				endchoice = "...",
			};
		else
			return {
				speaker = "...",
				msg = "Looking at the obelisk, you think to yourself: _What am I doing here?_",
				endchoice = "...",
			};
		end
	elseif v.choice == "Yes" then
		commands.Learn(p)
		attuned["Sigil"] = lastused
		if attuned["Deepforest"] == lastused then
			attuned["Deepforest"] = ""
		end
		if attuned["Desert"] == lastused then
			attuned["Desert"] = ""
		end
		if attuned["Shore"] == lastused then
			attuned["Shore"] = ""
		end
		if attuned["Forest"] == lastused then
			attuned["Forest"] = ""
		end
		if attuned["Skycastle"] == lastused then
			attuned["Skycastle"] = ""
		end
		if attuned["Snail"] == lastused then
			attuned["Snail"] = ""
		end
		if attuned["Tundra"] == lastused then
			attuned["Tundra"] = ""
		end
		data.Attuned.Value = game:GetService("HttpService"):JSONEncode(attuned)
		return {
			speaker = "...",
			msg = "You've attuned "..lastused.." with the Sigil Obelisk",
			endchoice = "...",
		};
	end
end

function dialogues.ObeliskSkyCastle.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	local StoryMarker
	local lastused = p.Character.LastUsed.Value
	local attuned = game:GetService("HttpService"):JSONDecode(data.Attuned.Value)
	if data and data.StoryMarker.Value then
		StoryMarker = game:GetService("HttpService"):JSONDecode(data.StoryMarker.Value)
	end
	if v.page == 1 then
		if data.Race.Value == "Azael" and data.Ascended.Value == true then
			return dialogues.Obelisk.ascended
		end
		if StoryMarker["Ascension"] then
			if StoryMarker["Ascension"]["Azael"] and StoryMarker["Ascension"]["Azael"] == "Obelisks" then
				if not table.find(StoryMarker["Obelisks"], "Skycastle") then
					return dialogues.Obelisk.p1
				else
					return dialogues.Obelisk.Resonated
				end
			end
		end
		return dialogues.Obelisk.p3;
	elseif v.page == 2 and v.choice == "Resonate" then
		table.insert(StoryMarker["Obelisks"], "Skycastle")
		data.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
		commands.Learn(p);
		return dialogues.Obelisk.p2;
	elseif v.choice == "Attune Skill" then
		if lastused ~= "" and attuned["Skycastle"] ~= lastused then
			return {
				speaker = "...",
				msg = "Would you like to attune "..lastused.." with the Skycastle Obelisk?",
				choices = {"Yes"},
				endchoice = "...",
			};
		else
			return {
				speaker = "...",
				msg = "Looking at the obelisk, you think to yourself: _What am I doing here?_",
				endchoice = "...",
			};
		end
	elseif v.choice == "Yes" then
		commands.Learn(p)
		attuned["Skycastle"] = lastused
		if attuned["Deepforest"] == lastused then
			attuned["Deepforest"] = ""
		end
		if attuned["Desert"] == lastused then
			attuned["Desert"] = ""
		end
		if attuned["Shore"] == lastused then
			attuned["Shore"] = ""
		end
		if attuned["Sigil"] == lastused then
			attuned["Sigil"] = ""
		end
		if attuned["Forest"] == lastused then
			attuned["Forest"] = ""
		end
		if attuned["Snail"] == lastused then
			attuned["Snail"] = ""
		end
		if attuned["Tundra"] == lastused then
			attuned["Tundra"] = ""
		end
		data.Attuned.Value = game:GetService("HttpService"):JSONEncode(attuned)
		return {
			speaker = "...",
			msg = "You've attuned "..lastused.." with the Skycastle Obelisk",
			endchoice = "...",
		};
	end
end

function dialogues.ObeliskTundra.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	local StoryMarker
	local lastused = p.Character.LastUsed.Value
	local attuned = game:GetService("HttpService"):JSONDecode(data.Attuned.Value)
	if data and data.StoryMarker.Value then
		StoryMarker = game:GetService("HttpService"):JSONDecode(data.StoryMarker.Value)
	end
	if v.page == 1 then
		if data.Race.Value == "Azael" and data.Ascended.Value == true then
			return dialogues.Obelisk.ascended
		end
		if StoryMarker["Ascension"] then
			if StoryMarker["Ascension"]["Azael"] and StoryMarker["Ascension"]["Azael"] == "Obelisks" then
				if not table.find(StoryMarker["Obelisks"], "Tundra") then
					return dialogues.Obelisk.p1
				else
					return dialogues.Obelisk.Resonated
				end
			end
		end
		return dialogues.Obelisk.p3;
	elseif v.page == 2 and v.choice == "Resonate" then
		table.insert(StoryMarker["Obelisks"], "Tundra")
		data.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
		commands.Learn(p);
		return dialogues.Obelisk.p2;
	elseif v.choice == "Attune Skill" then
		if lastused ~= "" and attuned["Tundra"] ~= lastused then
			return {
				speaker = "...",
				msg = "Would you like to attune "..lastused.." with the Tundra Obelisk?",
				choices = {"Yes"},
				endchoice = "...",
			};
		else
			return {
				speaker = "...",
				msg = "Looking at the obelisk, you think to yourself: _What am I doing here?_",
				endchoice = "...",
			};
		end
	elseif v.choice == "Yes" then
		commands.Learn(p)
		attuned["Tundra"] = lastused
		if attuned["Desert"] == lastused then
			attuned["Desert"] = ""
		end
		data.Attuned.Value = game:GetService("HttpService"):JSONEncode(attuned)
		return {
			speaker = "...",
			msg = "You've attuned "..lastused.." with the Tundra Obelisk",
			endchoice = "...",
		};
	end
end
function dialogues.Ferryman.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	if data.Lives.Value<= 0 then
		if v.page == 1 then
			if data.Race.Value ~= "Cameo" then
				return dialogues.Ferryman.choices
			else
				return  {
					speaker = "The Ferryman";
					msg = "Ashes to ashes, dust to dust.";
					choices = {"New Lineage\n(free)"};
					endchoice = "Bye";
				};
			end
		elseif v.page == 2 then
			if v.choice == "New Character\n(free)"then
				return dialogues.Ferryman.genderchoice
			elseif v.choice == "Same Character\n(20 R$)" then
				if data.LastWinded.Value == false then
					marketplaceservice:PromptProductPurchase(p,1349079187)
					return dialogues.Ferryman.samecharacter
				else
					return dialogues.Ferryman.nolastwind
				end
			elseif v.choice == "New Lineage\n(10 R$)" then
				marketplaceservice:PromptProductPurchase(p,1349079279)
				return dialogues.Ferryman.newlineage
			elseif v.choice == "New Lineage\n(free)" then
				if data.Race.Value ~= "Cameo" then
					game:GetService("DataStoreService"):GetDataStore("ArdaBans"):SetAsync(p.Name, true)
					p:Kick("Nice one")
				end
				game.ServerStorage.Requests.Wipe:Fire(p,data)
				task.delay(1.5, function()
					game.ServerStorage.Requests.Respawn:Fire(p)
				end)
				return dialogues.Ferryman.newlineage
			end
		elseif v.page == 3 then
			if v.choice == "My Son."then
				data.Gender.Value = "Male"
				random_name1 = randomize_.FirstName(data.Race.Value,data.Gender.Value)
				random_name2 = randomize_.FirstName(data.Race.Value,data.Gender.Value)
				random_name3 = randomize_.FirstName(data.Race.Value,data.Gender.Value)
				return {
					speaker = "The Ferryman";
					msg = "What would you like their name to be?";
					choices = {random_name1,random_name2,random_name3,"None of these."};
					endchoice = "Bye";
				}
			elseif v.choice == "My Daughter."then
				data.Gender.Value = "Female"

				random_name1 = randomize_.FirstName(data.Race.Value,data.Gender.Value)
				random_name2 = randomize_.FirstName(data.Race.Value,data.Gender.Value)
				random_name3 = randomize_.FirstName(data.Race.Value,data.Gender.Value)
				return {
					speaker = "The Ferryman";
					msg = "What would you like their name to be?";
					choices = {random_name1,random_name2,random_name3,"None of these."};
					endchoice = "Bye";
				}
			end
			return dialogues.Ferryman.goodbye
		elseif v.page >= 4 then
			if v.choice == random_name1 then
				data.FirstName.Value = random_name1
				game.ServerStorage.Requests.Wipe:Fire(p,data,nil,true)
				task.delay(2,function()
					game.ServerStorage.Requests.Respawn:Fire(p)
				end)
				return dialogues.Ferryman.goodbye
			elseif v.choice == random_name2 then
				data.FirstName.Value = random_name2
				game.ServerStorage.Requests.Wipe:Fire(p,data,nil,true)
				task.delay(2,function()
					game.ServerStorage.Requests.Respawn:Fire(p)
				end)
				return dialogues.Ferryman.goodbye
			elseif v.choice == random_name3 then
				data.FirstName.Value = random_name3
				game.ServerStorage.Requests.Wipe:Fire(p,data,nil,true)
				task.delay(2,function()
					game.ServerStorage.Requests.Respawn:Fire(p)
				end)
				return dialogues.Ferryman.goodbye
			elseif v.choice == "None of these." then
				random_name1 = randomize_.FirstName(data.Race.Value,data.Gender.Value)
				random_name2 = randomize_.FirstName(data.Race.Value,data.Gender.Value)
				random_name3 = randomize_.FirstName(data.Race.Value,data.Gender.Value)
				return {
					speaker = "The Ferryman";
					msg = "What would you like their name to be?";
					choices = {random_name1,random_name2,random_name3,"None of these."};
					endchoice = "Bye";
				}
			end
		end
	else
		if v.page == 1 then
			return dialogues.Ferryman.haslife
		else
			if v.choice == "Can you send me back?"then
				local spawns = game.ServerStorage.SpawnPoints[data.SpawnPoint.Value]:GetChildren()
				local randomspawn = spawns[math.random(1,#spawns)].CFrame
				data.LastPosition.Value = randomspawn.X..","..randomspawn.Y..","..randomspawn.Z
				game.ServerStorage.Requests.Respawn:Fire(p)
				return dialogues.exit
			end
		end
	end
end
function dialogues.Ethan.v1(p,v)
	if v.page == 1 then
		local teach = teachskill(p,classdata.Akuma,true)
		if teach == "notmax"then
			return dialogues.Ethan.p1
		elseif teach == "max"then
			return dialogues.Ethan.max
		elseif teach == "no"then
			return dialogues.Ethan.no
		end
	elseif v.page == 2 then
		local teach = teachskill(p,classdata.Akuma)
		if teach == "gotskill"then
			return dialogues.Ethan.p2
		elseif teach == "poor"then
			return dialogues.Ethan.p3
		end
	end
end
function dialogues.Drake.v1(p,v)
	local teach = teachskill(p,classdata.Thief,true)
	if teach ~= "max"then
		return dialogues.Drake.no
	end
	if v.page == 1 then
		local teach = teachskill(p,classdata.Spy,true)
		if teach == "notmax"then
			if game.ServerStorage.PlayerData:FindFirstChild(p.Name).BaseDagger.Value == true or game.ServerStorage.PlayerData:FindFirstChild(p.Name).Class.Value == "Spy" then
				return dialogues.Drake.p1
			else
				return dialogues.Drake.no
			end
		elseif teach == "max"then
			if game.ServerStorage.PlayerData:FindFirstChild(p.Name).Skills.Value:find("Freedom") then
				return dialogues.Drake.maxfreedom
			else
				return dialogues.Drake.max
			end
		elseif teach == "no"then
			return dialogues.Drake.no
		end
	elseif v.page == 2 then
		local teach = teachskill(p,classdata.Spy)
		if teach == "gotskill"then
			return dialogues.Drake.p2
		elseif teach == "poor"then
			return dialogues.Drake.poor
		else
			return dialogues.Drake.freedom
		end
	elseif v.page == 3 then
		return dialogues.Drake.freedom2
	end
end

dialogues.Atlas.v1 = function(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	if teachskill(p,classdata.Spear,true)~="max" and data.Class.Value ~= "Atlas" then
		return dialogues.Atlas.no
	end
	if teachskill(p,classdata.Spearfisher,true)~="max" and data.Class.Value ~= "Atlas" then
		return dialogues.Atlas.no
	end
	if v.page == 1 then
		local teach = teachskill(p,classdata.Atlas,true)
		if teach == "notmax"then
			return dialogues.Atlas.p1
		elseif teach == "max"then
			return dialogues.Atlas.max
		elseif teach == "no"then
			return dialogues.Atlas.no
		end
	elseif v.page == 2 then
		local teach = teachskill(p,classdata.Atlas,true)
		if teach == "notmax"then
			return dialogues.Atlas.p2
		elseif teach == "max"then
			return dialogues.Atlas.max
		elseif teach == "no"then
			return dialogues.Atlas.no
		end
	elseif v.page == 3 then
		local teach = teachskill(p,classdata.Atlas)
		if teach == "gotskill"then
			return dialogues.Atlas.p3
		elseif teach == "poor"then
			return dialogues.Atlas.poor
		end
	end
end

function dialogues.Rorschach.v1(p,v)
	local teach = teachskill(p,classdata.Spy,true)
	if teach ~= "max"then
		return dialogues.Rorschach.no
	end
	if game.ServerStorage.PlayerData[p.Name].Class.Value ~= "Whisper" then
		return dialogues.Rorschach.no
	end
	if v.page == 1 then
		local teach = teachskill(p,classdata.Whisper,true)
		if teach == "notmax"then
			return dialogues.Rorschach.p1
		elseif teach == "max"then
			return dialogues.Rorschach.max
		elseif teach == "no"then
			return dialogues.Rorschach.no
		end
	elseif v.page == 2 then
		local teach = teachskill(p,classdata.Whisper)
		if teach == "gotskill"then
			return dialogues.Rorschach.p2
		elseif teach == "poor"then
			return dialogues.Rorschach.poor
		end
	end
end
function dialogues.Frank.v1(p,v)
	local teach = teachskill(p,classdata.Spy,true)
	if teach ~= "max"then
		return dialogues.Frank.no
	end
	if game.ServerStorage.PlayerData[p.Name].Class.Value ~= "Wanderer" then
		return dialogues.Frank.no
	end
	if v.page == 1 then
		local teach = teachskill(p,classdata.Wanderer,true)
		if teach == "notmax"then
			return dialogues.Frank.p1
		elseif teach == "max"then
			return dialogues.Frank.max
		elseif teach == "no"then
			return dialogues.Frank.no
		end
	elseif v.page == 2 then
		local teach = teachskill(p,classdata.Wanderer)
		if teach == "gotskill"then
			return dialogues.Frank.p2
		elseif teach == "poor"then
			return dialogues.Frank.poor
		end
	end
end
function dialogues.Banker.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	local character = p.Character
	if v.page == 1 then
		if data.Banked.Value =="None"then
			return dialogues.Banker.p1
		else
			return{
				speaker = "Banker",
				msg = "Ah, I'm still looking after your %"..data.Banked.Value.."%, don't you worry.",
				choices = {"Could I have it back?"},
				endchoice = "Bye",
			};
		end
	elseif v.page == 2 then
		if data.Banked.Value =="None"then
			local tool = p.Character:FindFirstChild("Artifact",true)
			if tool and tool.Parent:IsA("Tool")then
				commands.RemoveFromInventory(p,tool.Parent.Name)
				data.Banked.Value = tool.Parent.Name
				tool.Parent:Destroy()
				return{
					speaker = "Banker",
					msg = "Alright, I'll take good care of it. ",
					endchoice = "Bye",
				};
			else
				return dialogues.Banker.no
			end
		else
			commands.AddToInventory(p,data.Banked.Value)
			data.Banked.Value = "None"
			return{
				speaker = "Banker",
				msg = "Alright, here you go. If you need me to look after something of yours again, I'd be happy to.",
				endchoice = "Bye",
			};
		end
	end
end
function dialogues.Edict.v1(p,v)
	return dialogues.Edict.v1
end
function dialogues.Owl.v1(p,v)
	local data = playerdata:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	local teach = teachskill(p,classdata.Assassin,true)
	if teach ~= "max"then
		return dialogues.Owl.poor
	end
	if v.page == 1 then
		if data.MetalArm.Value ~= true and data.Race.Value ~= "Gaian" and data.Race.Value ~= "Metascroom" then
			return dialogues.Owl.poor
		end
		local teach = teachskill(p,classdata.Shinobi,true)
		if teach == "notmax"then
			return dialogues.Owl.p1
		elseif teach == "max"then
			return dialogues.Owl.max
		end
	elseif v.page == 2 then
		local teach = teachskill(p,classdata.Shinobi)
		if teach == "gotskill"then
			return dialogues.Owl.gotskill
		end
	end
	return dialogues.Owl.poor
end

local gatemodule = require(workspace.Seats.WraithDoor.GateModule)
function dialogues.PasswordChecker.v1(p,v)
	local data = playerdata:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	local Skills = data.Skills.Value

	local canopen = Skills:find("canopendoor")

	if not Skills:find("canopendoor")  then
		return dialogues.PasswordChecker.noquest
	end
	if v.page == 1 then
		if gatemodule.Opened == false then
			return dialogues.PasswordChecker.p1
		else
			return dialogues.PasswordChecker.p3
		end
	elseif v.page == 2 then
		if v.choice == "Nueris Lopt" then
			spawn(function()
				gatemodule.Pay()
			end)
			data.Skills.Value ..= ",nueriscompleted"
			return dialogues.PasswordChecker.p2
		end
	end
end
--[[function dialogues.LukeGate.v1(p,v)
	local data = playerdata:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	if v.page == 1 then
		if gatemodule.Opened.Value == false then
			return dialogues.LukeGate.p1
		else
			return dialogues.LukeGate.p3
		end
	elseif v.page == 2 then
		if v.choice == "me too!" then
			spawn(function()
				gatemodule.Pay()
			end)
			return dialogues.LukeGate.p2
		end
	end
end]]

function dialogues.GetOut.v1(p, v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end

	if v.page == 1 then
		return {
			speaker = "???";
			msg = "Would you like to leave?";
			choices = {"Yes"};
			endchoice = "Bye";
		}
	elseif v.page == 2 then
		p.Character:SetPrimaryPartCFrame(workspace.WorldEater.CFrame)

		return {
			speaker = "???";
			msg = "...";
			endchoice = "...";
		}
	end
end
function dialogues.Yaalda.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	if v.page == 1 then
		return dialogues.Yaalda.p1
	elseif v.page == 2 then
		if data.Skills.Value:find("Snowball") then
			return dialogues.Yaalda.p3
		else
			return dialogues.Yaalda.p2	
		end
	end
end
function dialogues.Snowman.v1(p,v)
	local char = p.Character
	if not char then
		return
	end
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	if data.Skills.Value:find("Snowball") then
		return dialogues.Snowman.wrong_npc
	end
	if not char:FindFirstChild("DELIVER") then
		local note = Instance.new("Accessory")
		note.Name = "DELIVER"
		note.Parent = char
		return dialogues.Snowman.p1
	else
		return dialogues.Snowman.p2
	end
end
function dialogues.Dormin.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	local StoryMarker = game:GetService("HttpService"):JSONDecode(data.StoryMarker.Value)
	if not StoryMarker then
		return
	end
	if not StoryMarker["StartedHealer"] then
		return dialogues.Dormin.cooldown
	end
	if v.page == 1 then
		if StoryMarker["StartedHealer"] and (StoryMarker["StartedHealer"]["Dormin"] == true or StoryMarker["StartedHealer"] == "Finished") then
			return dialogues.Dormin.cooldown
		end
		if StoryMarker["DorminQuest"] and StoryMarker["DorminQuest"] == "Started" then
			return dialogues.Dormin.cameback
		end
		return dialogues.Dormin.p1
	elseif v.choice == "Need any help?" then
		return dialogues.Dormin.p2
	elseif v.choice == "..." then
		return dialogues.Dormin.p3
	elseif v.choice == "Alright" then
		if p.Character:FindFirstChild("Vint") or p.Backpack:FindFirstChild("Vint") then
			if p.Character:FindFirstChild("Vint") then
				p.Character:FindFirstChild("Vint"):Destroy()
				commands.RemoveFromInventory(p,"Vint")
			else
				p.Backpack:FindFirstChild("Vint"):Destroy()
				commands.RemoveFromInventory(p,"Vint")
			end
			StoryMarker["StartedHealer"]["Dormin"] = true
			data.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
			commands.Learn(p)
			if checkhealerdone(StoryMarker) then
				StoryMarker["StartedHealer"] = "Finished"
				data.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
				return dialogues.Dormin.healerdone
			end
			return dialogues.Dormin.ofc
		else
			StoryMarker["DorminQuest"] = "Started"
			data.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
			return dialogues.Dormin.no
		end
	elseif v.choice == "Here's your vint" then
		if p.Character:FindFirstChild("Vint") or p.Backpack:FindFirstChild("Vint") then
			if p.Character:FindFirstChild("Vint") then
				p.Character:FindFirstChild("Vint"):Destroy()
				commands.RemoveFromInventory(p,"Vint")
			else
				p.Backpack:FindFirstChild("Vint"):Destroy()
				commands.RemoveFromInventory(p,"Vint")
			end
			StoryMarker["StartedHealer"]["Dormin"] = true
			data.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
			commands.Learn(p)
			if checkhealerdone(StoryMarker) then
				StoryMarker["StartedHealer"] = "Finished"
				data.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
				return dialogues.Dormin.healerdone
			end
			return dialogues.Dormin.ofc
		else
			StoryMarker["DorminQuest"] = "Started"
			data.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
			return dialogues.Dormin.no
		end
	elseif v.choice == "Bye" then
		return dialogues.Healer.healerstep1done
	end
end
function dialogues.Tiger.v1(p,v)
	local teach = teachskill(p,classdata.Spear,true)
	if teach ~= "max"then
		return dialogues.Tiger.no
	end
	if v.page == 1 then
		local teach = teachskill(p,classdata.DragonKnight,true)
		if teach == "notmax"then
			return dialogues.Tiger.p1
		elseif teach == "max"then
			return dialogues.Tiger.max
		elseif teach == "no"then
			return dialogues.Tiger.no
		end
	elseif v.page == 2 then
		local teach = teachskill(p,classdata.DragonKnight)
		if teach == "gotskill"then
			return dialogues.Tiger.p2
		elseif teach == "poor"then
			return dialogues.Tiger.p3
		end
	end
end
dialogues.Ishikk.v1 = function(p,v)
	local teach = subclasscheck(p,classdata.Chef, "Chef")
	if teach == "notmax" then
		return dialogues.Ishikk.no
	end
	if v.page == 1 then
		local teach = teachskill(p,classdata.Spearfisher,true)
		if teach == "notmax"then
			if game.ServerStorage.PlayerData:FindFirstChild(p.Name).BaseSpear.Value == true or game.ServerStorage.PlayerData:FindFirstChild(p.Name).Class.Value == "Spearfisher" then
				if game.ServerStorage.PlayerData:FindFirstChild(p.Name).SubClass.Value == "Chef" then
					return dialogues.Ishikk.p1
				else
					return dialogues.Ishikk.no
				end
			else
				return dialogues.Ishikk.no
			end
		elseif teach == "max"then
			return dialogues.Ishikk.max
		elseif teach == "no"then
			return dialogues.Ishikk.no
		end
	elseif v.page == 2 then
		local teach = teachskill(p,classdata.Spearfisher,true)
		if teach == "notmax"then
			return dialogues.Ishikk.p2
		elseif teach == "max"then
			return dialogues.Ishikk.max
		elseif teach == "no"then
			return dialogues.Ishikk.no
		end
	elseif v.page == 3 then
		local teach = teachskill(p,classdata.Spearfisher)
		if teach == "gotskill"then
			return dialogues.Ishikk.p3
		elseif teach == "poor"then
			return dialogues.Ishikk.poor
		end
	end
end
function move_npc(npc,spawns,maxspawn)
	local npc_to_move = game.Workspace.NPCs:FindFirstChild(npc)
	local npc_hum = npc_to_move:FindFirstChild("HumanoidRootPart")
	local spawn_value = npc_to_move:FindFirstChild("SpawnLocation")
	if npc_hum and npc_to_move and spawns and spawn_value then
		if spawn_value.Value >= maxspawn then
			spawn_value.Value = 1
		else
			spawn_value.Value += 1
		end
		local current_value = npc.."Spawn"..spawn_value.Value
		local spawn_loc = spawns:FindFirstChild(current_value)
		if spawn_loc then
			npc_hum.CFrame = spawn_loc.CFrame
		end
	end
end
function dialogues.Fallion.v1(p,v)
	if v.page == 1 then
		local teach = teachskill(p,classdata.Scholar,true)
		if teach == "notmax"then
			return dialogues.Fallion.p1
		elseif teach == "max"then
			return dialogues.Fallion.max
		end
	elseif v.page == 2 then
		return dialogues.Fallion.p2
	elseif v.page == 3 then
		local teach = teachskill(p,classdata.Scholar)
		if teach == "gotskill"then
			move_npc("Fallion",game.Workspace.FallionSpawns,3)
			return dialogues.Fallion.p3
		elseif teach == "poor"then
			return dialogues.Fallion.poor
		end
	end
end
dialogues.Regnier.v1 = function(p,v)
	if teachskill(p,classdata.Warrior,true)~="max" and game.ServerStorage.PlayerData:FindFirstChild(p.Name).JahovanAccepted.Value == false then
		return dialogues.Regnier.no
	end
	if v.page == 1 then
		local teach = teachskill(p,classdata.Greatsword,true)
		if game.ServerStorage.PlayerData:FindFirstChild(p.Name).Class.Value == "SigilKnightCommander" and game.ServerStorage.PlayerData:FindFirstChild(p.Name).JahovanAccepted.Value == true then
			return dialogues.Regnier.sigilknight
		end
		if teach == "notmax"then
			if game.ServerStorage.PlayerData:FindFirstChild(p.Name).BaseSword.Value == true or game.ServerStorage.PlayerData:FindFirstChild(p.Name).Class.Value == "Greatsword" then
				return dialogues.Regnier.p1
			else
				return dialogues.Regnier.no
			end
		elseif teach == "max"then
			return dialogues.Regnier.max
		elseif teach == "no"then
			return dialogues.Regnier.no
		end
	elseif v.page == 2 then
		local teach = teachskill(p,classdata.Greatsword,true)
		if game.ServerStorage.PlayerData:FindFirstChild(p.Name).Class.Value == "SigilKnightCommander" and game.ServerStorage.PlayerData:FindFirstChild(p.Name).JahovanAccepted.Value == true then
			game.ServerStorage.PlayerData:FindFirstChild(p.Name).Class.Value = "Templar"
			local allski = string.split(game.ServerStorage.PlayerData:FindFirstChild(p.Name).Skills.Value, ",")
			table.remove(allski, table.find(allski, "Charged Blow"))
			table.remove(allski, table.find(allski, "Hyper Body"))
			table.remove(allski, table.find(allski, "ChargeMastery"))
			table.remove(allski, table.find(allski, "Charged Blow"))
			table.remove(allski, table.find(allski, "Flame Charge"))
			table.remove(allski, table.find(allski, "Ice Charge"))
			table.remove(allski, table.find(allski, "Thunder Charge"))
			table.insert(allski, "Solan's Will")
			table.insert(allski, "TemplarTraining")
			game.ServerStorage.PlayerData:FindFirstChild(p.Name).Skills.Value = table.concat(allski, ",")
			task.spawn(function()
				task.wait(2)
				p:LoadCharacter()
				local v12 = Instance.new("NumberValue");
				v12.Name = "Transparency";
				v12.Value = 0;
				v12.Parent = p.Character.Boosts;
				task.wait(0.5)
				commands.Learn(p)
			end)
			return dialogues.Regnier.p3
		end
		if teach == "notmax"then
			return dialogues.Regnier.p2
		elseif teach == "max"then
			return dialogues.Regnier.max
		elseif teach == "no"then
			return dialogues.Regnier.no
		end
	elseif v.page == 3 then
		local teach = teachskill(p,classdata.Greatsword)
		if teach == "gotskill"then
			return dialogues.Regnier.p3
		elseif teach == "poor"then
			return dialogues.Regnier.poor
		end
	end
end
function dialogues.ObeliskBlade1.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	local GlobalData = game.ServerStorage.PlayerData:FindFirstChild(p.Name.."Global")
	if not GlobalData or not p.Character then
		return
	end
	local UnlockedEdicts = GlobalData.UnlockedEdicts.Value
	local StoryMarker = HttpService:JSONDecode(data.StoryMarker.Value)
	if v.page == 1 then
		if StoryMarker.BMasterObelisks and not StoryMarker.BMasterObelisks["Obelisk1"] then
			return dialogues.BMObelisk.bmquest
		else
			return dialogues.BMObelisk.notquest
		end
	elseif v.page == 2 then
		StoryMarker.BMasterObelisks["Obelisk1"] = true
		data.StoryMarker.Value = HttpService:JSONEncode(StoryMarker)
		task.delay(1.5,function()
			_G.Death(p,nil,nil,true)
			p.Character.Humanoid.Health = 0
			--v:BreakJoints()
			p.Character.HumanoidRootPart.Backfire:Play()
			task.wait()
			coroutine.wrap(function()
				for i,bruh in pairs(p.Character:GetChildren()) do
					if bruh:IsA("Shirt") or bruh:IsA("Pants") then
						bruh:Destroy()
					end
					if bruh:IsA("Part") or bruh:IsA("BasePart") then
						local dec = bruh:FindFirstChildOfClass("Decal")
						if dec then
							dec:Destroy()
						end
						local bv = Instance.new("BodyVelocity")
						game.CollectionService:AddTag(bv,"AllowedBM")
						bv.Velocity = Vector3.new(math.random(-10,10),math.random(-10,10),math.random(-10,10))
						bv.Parent = bruh
						bruh.Material = Enum.Material.Neon
						local tweenInfo02 = TweenInfo.new(1.25,	Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
						local tween02 = TweenService:Create(bruh,tweenInfo02,{Transparency=1,Color=Color3.new()})
						tween02:Play()
					end
				end
			end)()
		end)
		return dialogues.BMObelisk.offerdone
	end
end
function dialogues.ObeliskBlade2.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	local GlobalData = game.ServerStorage.PlayerData:FindFirstChild(p.Name.."Global")
	if not GlobalData or not p.Character then
		return
	end
	local UnlockedEdicts = GlobalData.UnlockedEdicts.Value
	local StoryMarker = HttpService:JSONDecode(data.StoryMarker.Value)
	if v.page == 1 then
		if StoryMarker.BMasterObelisks and not StoryMarker.BMasterObelisks["Obelisk2"] then
			return dialogues.BMObelisk.bmquest
		else
			return dialogues.BMObelisk.notquest
		end
	elseif v.page == 2 then
		StoryMarker.BMasterObelisks["Obelisk2"] = true
		data.StoryMarker.Value = HttpService:JSONEncode(StoryMarker)
		task.delay(1.5,function()
			_G.Death(p,nil,nil,true)
			p.Character.Humanoid.Health = 0
			--v:BreakJoints()
			p.Character.HumanoidRootPart.Backfire:Play()
			task.wait()
			coroutine.wrap(function()
				for i,bruh in pairs(p.Character:GetChildren()) do
					if bruh:IsA("Shirt") or bruh:IsA("Pants") then
						bruh:Destroy()
					end
					if bruh:IsA("Part") or bruh:IsA("BasePart") then
						local dec = bruh:FindFirstChildOfClass("Decal")
						if dec then
							dec:Destroy()
						end
						local bv = Instance.new("BodyVelocity")
						game.CollectionService:AddTag(bv,"AllowedBM")
						bv.Velocity = Vector3.new(math.random(-10,10),math.random(-10,10),math.random(-10,10))
						bv.Parent = bruh
						bruh.Material = Enum.Material.Neon
						local tweenInfo02 = TweenInfo.new(1.25,	Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
						local tween02 = TweenService:Create(bruh,tweenInfo02,{Transparency=1,Color=Color3.new()})
						tween02:Play()
					end
				end
			end)()
		end)
		return dialogues.BMObelisk.offerdone
	end
end
function dialogues.ObeliskBlade3.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	local GlobalData = game.ServerStorage.PlayerData:FindFirstChild(p.Name.."Global")
	if not GlobalData or not p.Character then
		return
	end
	local UnlockedEdicts = GlobalData.UnlockedEdicts.Value
	local StoryMarker = HttpService:JSONDecode(data.StoryMarker.Value)
	if v.page == 1 then
		if StoryMarker.BMasterObelisks and not StoryMarker.BMasterObelisks["Obelisk3"] then
			return dialogues.BMObelisk.bmquest
		else
			return dialogues.BMObelisk.notquest
		end
	elseif v.page == 2 then
		StoryMarker.BMasterObelisks["Obelisk3"] = true
		data.StoryMarker.Value = HttpService:JSONEncode(StoryMarker)
		task.delay(1.5,function()
			_G.Death(p,nil,nil,true)
			p.Character.Humanoid.Health = 0
			--v:BreakJoints()
			p.Character.HumanoidRootPart.Backfire:Play()
			task.wait()
			coroutine.wrap(function()
				for i,bruh in pairs(p.Character:GetChildren()) do
					if bruh:IsA("Shirt") or bruh:IsA("Pants") then
						bruh:Destroy()
					end
					if bruh:IsA("Part") or bruh:IsA("BasePart") then
						local dec = bruh:FindFirstChildOfClass("Decal")
						if dec then
							dec:Destroy()
						end
						local bv = Instance.new("BodyVelocity")
						game.CollectionService:AddTag(bv,"AllowedBM")
						bv.Velocity = Vector3.new(math.random(-10,10),math.random(-10,10),math.random(-10,10))
						bv.Parent = bruh
						bruh.Material = Enum.Material.Neon
						local tweenInfo02 = TweenInfo.new(1.25,	Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
						local tween02 = TweenService:Create(bruh,tweenInfo02,{Transparency=1,Color=Color3.new()})
						tween02:Play()
					end
				end
			end)()
		end)
		return dialogues.BMObelisk.offerdone
	end
end
function dialogues.ObeliskBlade4.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	local GlobalData = game.ServerStorage.PlayerData:FindFirstChild(p.Name.."Global")
	if not GlobalData or not p.Character then
		return
	end
	local UnlockedEdicts = GlobalData.UnlockedEdicts.Value
	local StoryMarker = HttpService:JSONDecode(data.StoryMarker.Value)
	if v.page == 1 then
		if StoryMarker.BMasterObelisks and not StoryMarker.BMasterObelisks["Obelisk4"] then
			return dialogues.BMObelisk.bmquest
		else
			return dialogues.BMObelisk.notquest
		end
	elseif v.page == 2 then
		StoryMarker.BMasterObelisks["Obelisk4"] = true
		data.StoryMarker.Value = HttpService:JSONEncode(StoryMarker)
		task.delay(1.5,function()
			_G.Death(p,nil,nil,true)
			p.Character.Humanoid.Health = 0
			p.Character.HumanoidRootPart.Backfire:Play()
			task.wait()
			coroutine.wrap(function()
				for i,bruh in pairs(p.Character:GetChildren()) do
					if bruh:IsA("Shirt") or bruh:IsA("Pants") then
						bruh:Destroy()
					end
					if bruh:IsA("Part") or bruh:IsA("BasePart") then
						local dec = bruh:FindFirstChildOfClass("Decal")
						if dec then
							dec:Destroy()
						end
						local bv = Instance.new("BodyVelocity")
						game.CollectionService:AddTag(bv,"AllowedBM")
						bv.Velocity = Vector3.new(math.random(-10,10),math.random(-10,10),math.random(-10,10))
						bv.Parent = bruh
						bruh.Material = Enum.Material.Neon
						local tweenInfo02 = TweenInfo.new(1.25,	Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
						local tween02 = TweenService:Create(bruh,tweenInfo02,{Transparency=1,Color=Color3.new()})
						tween02:Play()
					end
				end
			end)()
		end)
		return dialogues.BMObelisk.offerdone
	end
end
function dialogues.TalNew.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	if v.page == 1 then
		return dialogues.TalNew.p1
	elseif v.page == 2 then
		return dialogues.TalNew.p2
	elseif v.choice == "Sure (20 Money)" then
		if commands.ChangeMoney(p,data,-20) then
			local scroll = ChooseWeightedItem(rollingtal)
			commands.AddToInventory(p,scroll)
			return dialogues.TalNew.p3
		else
			return dialogues.TalNew.poor
		end
	end
end
function dialogues.Source.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	if v.page == 1 then
		return dialogues.Source.p1
	elseif v.page == 2 then
		if commands.ChangeInsight(p,data,-10)then
			local scroll = nil
			--gemrolling["Rift Gem"] += data.GachaLuck.Value
			gemrolling["Sulfurite"] += data.GachaLuck.Value
			gemrolling["Bloodprism"] += data.GachaLuck.Value
			gemrolling["Deathstone"] += data.GachaLuck.Value
			gemrolling["Essence Gem"] += data.GachaLuck.Value
			data.GachaLuck.Value += 10
			scroll = ChooseWeightedItem(gemrolling)
			--gemrolling["Rift Gem"] -= data.GachaLuck.Value - 30
			gemrolling["Sulfurite"]  -= data.GachaLuck.Value - 10
			gemrolling["Bloodprism"]  -= data.GachaLuck.Value - 10
			gemrolling["Deathstone"] -= data.GachaLuck.Value - 10
			gemrolling["Essence Gem"] -= data.GachaLuck.Value - 10
			if scroll == "Diamond" or scroll == "Nightstone" or scroll == "Sulfurite" or scroll == "Bloodprism" or scroll == "Deathstone" or scroll == "Essence Gem" then
				data.GachaLuck.Value = 0
			end
			commands.AddToInventory(p,scroll)
			data.LastGacha.Value = data.DaysSurvived.Value
			return dialogues.Source.p2
		else
			return dialogues.Source.p3
		end
	end
end
dialogues.Gawain.v1 = function(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	if teachskill(p,classdata.Warrior,true)~="max" and data.Class.Value ~= "Vanguard" then
		return dialogues.Gawain.no
	end
	if teachskill(p,classdata.Greatsword,true)~="max" and data.Class.Value ~= "Vanguard" then
		return dialogues.Gawain.no
	end
	if v.page == 1 then
		local teach = teachskill(p,classdata.Vanguard,true)
		if teach == "notmax"then
			return dialogues.Gawain.p1
		elseif teach == "max"then
			return dialogues.Gawain.max
		elseif teach == "no"then
			return dialogues.Gawain.no
		end
	elseif v.page == 2 then
		local teach = teachskill(p,classdata.Vanguard,true)
		if teach == "notmax"then
			return dialogues.Gawain.p2
		elseif teach == "max"then
			return dialogues.Gawain.max
		elseif teach == "no"then
			return dialogues.Gawain.no
		end
	elseif v.page == 3 then
		local teach = teachskill(p,classdata.Vanguard)
		if teach == "gotskill"then
			return dialogues.Gawain.p3
		elseif teach == "poor"then
			return dialogues.Gawain.poor
		end
	end
end
dialogues.Jahovan.v1 = function(p,v)
	local agreed = false
	local teach = teachskill(p,classdata.Vanguard,true)
	return dialogues.Jahovan.no
	--[[if v.page == 1 then
		if playerdata:FindFirstChild(p.Name).Class.Value == "SigilKnightCommander" and playerdata:FindFirstChild(p.Name).JahovanAccepted.Value == false then
			return dialogues.Jahovan.firstmeet
		elseif playerdata:FindFirstChild(p.Name).Class.Value == "SigilKnightCommander" and playerdata:FindFirstChild(p.Name).JahovanAccepted.Value == true then
			return dialogues.Jahovan.firstmeet3
		elseif teach == "max" then
			return dialogues.Jahovan.max
		elseif playerdata:FindFirstChild(p.Name).Class.Value == "Templar" then
			return dialogues.Jahovan.returned
		else
			return dialogues.Jahovan.no
		end
	elseif v.page == 2 then
		if playerdata:FindFirstChild(p.Name).Class.Value == "SigilKnightCommander" then
			return dialogues.Jahovan.firstmeet2
		elseif playerdata:FindFirstChild(p.Name).Class.Value == "Templar" and playerdata:FindFirstChild(p.Name).ShriekerEyeTurnedIn.Value == false then
			return dialogues.Jahovan.firstquest
		elseif playerdata:FindFirstChild(p.Name).Class.Value == "Templar" and playerdata:FindFirstChild(p.Name).ShriekerEyeTurnedIn.Value == true and playerdata:FindFirstChild(p.Name).Bought1stSkillTemplar.Value == false then
			return dialogues.Jahovan.goodjob
		elseif playerdata:FindFirstChild(p.Name).Class.Value == "Templar" and playerdata:FindFirstChild(p.Name).HowlerFangTurnedIn.Value == false and playerdata:FindFirstChild(p.Name).ShriekerEyeTurnedIn.Value == true and playerdata:FindFirstChild(p.Name).Bought1stSkillTemplar.Value == true then
			return dialogues.Jahovan.secondquest
		elseif playerdata:FindFirstChild(p.Name).Class.Value == "Templar" and playerdata:FindFirstChild(p.Name).HowlerFangTurnedIn.Value == true and playerdata:FindFirstChild(p.Name).Bought2ndSkillTemplar.Value == false then	
			return dialogues.Jahovan.goodjob
		elseif playerdata:FindFirstChild(p.Name).Class.Value == "Templar" and playerdata:FindFirstChild(p.Name).EvilEyeTurnedIn.Value == false and playerdata:FindFirstChild(p.Name).HowlerFangTurnedIn.Value == true and playerdata:FindFirstChild(p.Name).Bought2ndSkillTemplar.Value == true then
			return dialogues.Jahovan.thirdquest
		elseif playerdata:FindFirstChild(p.Name).Class.Value == "Templar" and playerdata:FindFirstChild(p.Name).EvilEyeTurnedIn.Value == true and playerdata:FindFirstChild(p.Name).Bought3rdSkillTemplar.Value == false then	
			return dialogues.Jahovan.goodjob
		elseif playerdata:FindFirstChild(p.Name).Class.Value == "Templar" and playerdata:FindFirstChild(p.Name).SerpentFangTurnedIn.Value == false and playerdata:FindFirstChild(p.Name).EvilEyeTurnedIn.Value == true and playerdata:FindFirstChild(p.Name).Bought3rdSkillTemplar.Value == true then
			return dialogues.Jahovan.finalquest
		elseif playerdata:FindFirstChild(p.Name).Class.Value == "Templar" and playerdata:FindFirstChild(p.Name).SerpentFangTurnedIn.Value == true and playerdata:FindFirstChild(p.Name).Bought4thSkillTemplar.Value == false then	
			return dialogues.Jahovan.goodjob
		end
	elseif v.page == 3 then
		if playerdata:FindFirstChild(p.Name).Class.Value == "SigilKnightCommander" then
			playerdata:FindFirstChild(p.Name).JahovanAccepted.Value = true
			return dialogues.Jahovan.firstmeet3
		elseif playerdata:FindFirstChild(p.Name).ShriekerEyeTurnedIn.Value == false then
			local tool = p.Character:FindFirstChildWhichIsA("Tool")
			if tool and tool.Name == "Shrieker Eye" then
				playerdata:FindFirstChild(p.Name).ShriekerEyeTurnedIn.Value = true
				tool:Destroy()
				commands.RemoveFromInventory(p, tool.Name)
				return dialogues.Jahovan.goodjob
			else
				return dialogues.Jahovan.nothave
			end
		elseif playerdata:FindFirstChild(p.Name).ShriekerEyeTurnedIn.Value == true and playerdata:FindFirstChild(p.Name).Bought1stSkillTemplar.Value == false then
			local teach = teachskill(p,classdata.Templar)
			if teach == "gotskill" and playerdata:FindFirstChild(p.Name).Bought1stSkillTemplar.Value == false then
				playerdata:FindFirstChild(p.Name).Bought1stSkillTemplar.Value = true
				return dialogues.Jahovan.training
			elseif teach == "poor" then
				return dialogues.Jahovan.poor
			end
		elseif playerdata:FindFirstChild(p.Name).ShriekerEyeTurnedIn.Value == true and playerdata:FindFirstChild(p.Name).Bought1stSkillTemplar.Value == true and playerdata:FindFirstChild(p.Name).HowlerFangTurnedIn.Value == false then
			local tool = p.Character:FindFirstChildWhichIsA("Tool")
			if tool and tool.Name == "Howler Fang" then
				playerdata:FindFirstChild(p.Name).HowlerFangTurnedIn.Value = true
				tool:Destroy()
				commands.RemoveFromInventory(p, tool.Name)
				return dialogues.Jahovan.goodjob
			else
				return dialogues.Jahovan.nothave
			end
		elseif playerdata:FindFirstChild(p.Name).HowlerFangTurnedIn.Value == true and playerdata:FindFirstChild(p.Name).Bought2ndSkillTemplar.Value == false then
			local teach = teachskill(p,classdata.Templar)
			if teach == "gotskill" and playerdata:FindFirstChild(p.Name).Bought2ndSkillTemplar.Value == false then
				playerdata:FindFirstChild(p.Name).Bought2ndSkillTemplar.Value = true
				return dialogues.Jahovan.training
			elseif teach == "poor" then
				return dialogues.Jahovan.poor
			end
		elseif playerdata:FindFirstChild(p.Name).HowlerFangTurnedIn.Value == true and playerdata:FindFirstChild(p.Name).Bought2ndSkillTemplar.Value == true and playerdata:FindFirstChild(p.Name).EvilEyeTurnedIn.Value == false then
			local tool = p.Character:FindFirstChildWhichIsA("Tool")
			if tool and tool.Name == "Evil Eye" then
				playerdata:FindFirstChild(p.Name).EvilEyeTurnedIn.Value = true
				tool:Destroy()
				commands.RemoveFromInventory(p, tool.Name)
				return dialogues.Jahovan.goodjob
			else
				return dialogues.Jahovan.nothave
			end
		elseif playerdata:FindFirstChild(p.Name).EvilEyeTurnedIn.Value == true and playerdata:FindFirstChild(p.Name).Bought3rdSkillTemplar.Value == false then
			local teach = teachskill(p,classdata.Templar)
			if teach == "gotskill" and playerdata:FindFirstChild(p.Name).Bought3rdSkillTemplar.Value == false then
				playerdata:FindFirstChild(p.Name).Bought3rdSkillTemplar.Value = true
				return dialogues.Jahovan.training
			elseif teach == "poor" then
				return dialogues.Jahovan.poor
			end
		elseif playerdata:FindFirstChild(p.Name).EvilEyeTurnedIn.Value == true and playerdata:FindFirstChild(p.Name).Bought3rdSkillTemplar.Value == true and playerdata:FindFirstChild(p.Name).SerpentFangTurnedIn.Value == false then
			local tool = p.Character:FindFirstChildWhichIsA("Tool")
			if tool and tool.Name == "Serpent Fang" then
				playerdata:FindFirstChild(p.Name).SerpentFangTurnedIn.Value = true
				tool:Destroy()
				commands.RemoveFromInventory(p, tool.Name)
				return dialogues.Jahovan.goodjob
			else
				return dialogues.Jahovan.nothave
			end
		elseif playerdata:FindFirstChild(p.Name).SerpentFangTurnedIn.Value == true and playerdata:FindFirstChild(p.Name).Bought4thSkillTemplar.Value == false then
			local teach = teachskill(p,classdata.Templar)
			if teach == "gotskill" and playerdata:FindFirstChild(p.Name).Bought4thSkillTemplar.Value == false then
				playerdata:FindFirstChild(p.Name).Bought4thSkillTemplar.Value = true
				return dialogues.Jahovan.training
			elseif teach == "poor" then
				return dialogues.Jahovan.poor
			end
		end
	elseif v.page == 4 then
		local teach = teachskill(p,classdata.Templar)
		if teach == "gotskill" and playerdata:FindFirstChild(p.Name).Bought1stSkillTemplar.Value == false then
			playerdata:FindFirstChild(p.Name).Bought1stSkillTemplar.Value = true
			return dialogues.Jahovan.training
		elseif teach == "gotskill" and playerdata:FindFirstChild(p.Name).Bought2ndSkillTemplar.Value == false then
			playerdata:FindFirstChild(p.Name).Bought2ndSkillTemplar.Value = true
			return dialogues.Jahovan.training
		elseif teach == "gotskill" and playerdata:FindFirstChild(p.Name).Bought3rdSkillTemplar.Value == false then
			playerdata:FindFirstChild(p.Name).Bought3rdSkillTemplar.Value = true
			return dialogues.Jahovan.training
		elseif teach == "gotskill" and playerdata:FindFirstChild(p.Name).Bought4thSkillTemplar.Value == false then
			playerdata:FindFirstChild(p.Name).Bought4thSkillTemplar.Value = true
			return dialogues.Jahovan.training
		elseif teach == "poor" then
			return dialogues.Jahovan.poor
		end
	end]]
end
dialogues["Enibras "].v1 = function(p,v)
	if not playerdata[p.Name].Skills.Value:find("ArdorCalls") then
		return dialogues["Enibras "].no
	end
	--[[if teachskill(p,classdata.EnibrasTeaching,true) == "max" then	
		task.spawn(function()
			local v94, v95, v96 = workspace:FindPartOnRayWithIgnoreList(Ray.new(workspace.NPCs["Enibras "].HumanoidRootPart.Position, Vector3.new(0, -20, 0)), { workspace.Live, workspace.Terrain, workspace.NPCs, workspace.Thrown, workspace.Destructibles, workspace.Ingredients })
			if not v94 then
				return
			end
			local v97 = Instance.new("Part")
			v97.BrickColor = BrickColor.White()
			v97.Material = "Neon"
			v97.Transparency = 0
			v97.Anchored = true
			v97.CanCollide = false
			v97.Size = Vector3.new(8, 2, 8)
			v97.CFrame = CFrame.new(v95, v95 + v96) * CFrame.Angles(math.rad(-90), 0, 0)
			local v98 = Instance.new("CylinderMesh", v97)
			v98.Scale = Vector3.new(0, 0.05, 0)
			local v99 = script.Open:clone()
			v99.Parent = v97
			v97.Parent = workspace.Thrown
			game:GetService'Debris':AddItem(v97, 5)
			game.TweenService:Create(v98, TweenInfo.new(1), {
				Scale = Vector3.new(1, 0.01, 1)
			}):Play()
			v99:Play()
			local v110 = v97.Touched:Connect(function(p13)
				local v111 = p13.Parent:FindFirstChild("Humanoid") or p13.Parent and p13.Parent.Parent:FindFirstChild("Humanoid")
				if not v111 then
					return
				end
				local l__Parent__112 = v111.Parent
				local v113 = l__Parent__112 and v111.RootPart
				if not v113 or v111.Health <= 0 then
					return
				end
				if l__Parent__112:FindFirstChild("CantCast") then
					return
				end
				if l__Parent__112:FindFirstChild("TPSafe") then
					return
				end
				if l__Parent__112:FindFirstChild("Executing") or game.CollectionService:HasTag(l__Parent__112,"BeingExecuted")then
					return
				end
				if l__Parent__112:FindFirstChild("Interrogated") or l__Parent__112:FindFirstChild("Interrogating") then
					return
				end
				if l__Parent__112:FindFirstChild("Grabbed")then
					return
				end
				if l__Parent__112:FindFirstChild("Knocked")then
					return
				end
				if v111.SeatPart then
					return
				end
				if game.CollectionService:HasTag(l__Parent__112, "Swimming") then
					return
				end
				if string.find(l__Parent__112.Name, "Terra Serpent") then
					return
				end
				local p8 = l__Parent__112
				local v100 = Instance.new("Folder", p8)
				v100.Name = "NoFall"
				game.Debris:AddItem(v100, 5)
				local l__Grabbing__101 = p8:FindFirstChild("Grabbing")
				if l__Grabbing__101 then
					local v102 = game.Players:FindFirstChild(l__Grabbing__101.Value.Name)
					local v103 = v102 and v102.Character
					if v103 then
						local v104 = Instance.new("Folder", v103)
						v104.Name = "NoFall"
						game.Debris:AddItem(v104, 5)
						local v999 = Instance.new("Vector3Value")
						v999.Name = "TPSafe"
						v999.Parent = v103
						game.Debris:AddItem(v999, 4)
					end
				end
				local l__Humanoid__68 = l__Parent__112.Humanoid
				local v69 = p8.HumanoidRootPart
				task.wait(0.5)
				local v106 = Instance.new("Vector3Value")
				v106.Name = "TPSafe"
				v106.Parent = p8
				game.Debris:AddItem(v106, 4)
				local v105 = game.ServerStorage.WarpPoints.Desert[math.random(1,5)].CFrame
				if not l__Humanoid__68.SeatPart and not l__Humanoid__68.Sit then
					v69.CFrame = v105
				end
				local u16 = {}
			end)
			task.wait(4)
			v110:Disconnect()
			local v126 = script.Close:clone()
			v126.Parent = v97
			v126:Play()
			game.TweenService:Create(v98, TweenInfo.new(0.5), {
				Scale = Vector3.new(0, 0.01, 0)
			}):Play()
			game.Debris:AddItem(v97, 1.5)
		end)
		return {speaker = "Enibras",
			msg = "One gate, coming right in.",
			endchoice = "Bye."
		}
	end]]
	--[[if teachskill(p,classdata.EnibrasTeaching,true) == "max" then	
		return dialogues["Enibras "].askgate
	end]]
	if v.page == 1 then
		local teach = teachskill(p,classdata.EnibrasTeaching,true)
		if teach == "notmax"then
			return dialogues["Enibras "].p1
		elseif teach == "max"then
			return dialogues ["Enibras "].askgate
		elseif teach == "no"then
			return dialogues["Enibras "].no
		end
	elseif v.page == 2 then
		local teach = teachskill(p,classdata.EnibrasTeaching)
		if teach == "gotskill"then
			return dialogues["Enibras "].p2
		elseif teach == "poor"then
			return dialogues["Enibras "].poor
		elseif teach == "max" then
			task.spawn(function()
				local v94, v95, v96 = workspace:FindPartOnRayWithIgnoreList(Ray.new(workspace.NPCs["Enibras "].HumanoidRootPart.Position, Vector3.new(0, -20, 0)), { workspace.Live, workspace.Terrain, workspace.NPCs, workspace.Thrown, workspace.Destructibles, workspace.Ingredients })
				if not v94 then
					return
				end
				local v97 = Instance.new("Part")
				v97.BrickColor = BrickColor.White()
				v97.Material = "Neon"
				v97.Transparency = 0
				v97.Anchored = true
				v97.CanCollide = false
				v97.Size = Vector3.new(8, 2, 8)
				v97.CFrame = CFrame.new(v95, v95 + v96) * CFrame.Angles(math.rad(-90), 0, 0)
				local v98 = Instance.new("CylinderMesh", v97)
				v98.Scale = Vector3.new(0, 0.05, 0)
				local v99 = script.Open:clone()
				v99.Parent = v97
				v97.Parent = workspace.Thrown
				game:GetService'Debris':AddItem(v97, 5)
				game.TweenService:Create(v98, TweenInfo.new(1), {
					Scale = Vector3.new(1, 0.01, 1)
				}):Play()
				v99:Play()
				local v110 = v97.Touched:Connect(function(p13)
					local v111 = p13.Parent:FindFirstChild("Humanoid") or p13.Parent and p13.Parent.Parent:FindFirstChild("Humanoid")
					if not v111 then
						return
					end
					local l__Parent__112 = v111.Parent
					local v113 = l__Parent__112 and v111.RootPart
					if not v113 or v111.Health <= 0 then
						return
					end
					if l__Parent__112:FindFirstChild("CantCast") then
						return
					end
					if l__Parent__112:FindFirstChild("TPSafe") then
						return
					end
					if l__Parent__112:FindFirstChild("Executing") or game.CollectionService:HasTag(l__Parent__112,"BeingExecuted")then
						return
					end
					if l__Parent__112:FindFirstChild("Interrogated") or l__Parent__112:FindFirstChild("Interrogating") then
						return
					end
					if l__Parent__112:FindFirstChild("Grabbed")then
						return
					end
					if l__Parent__112:FindFirstChild("Knocked")then
						return
					end
					if v111.SeatPart then
						return
					end
					if game.CollectionService:HasTag(l__Parent__112, "Swimming") then
						return
					end
					if string.find(l__Parent__112.Name, "Terra Serpent") then
						return
					end
					local p8 = l__Parent__112
					local v100 = Instance.new("Folder", p8)
					v100.Name = "NoFall"
					game.Debris:AddItem(v100, 5)
					local l__Grabbing__101 = p8:FindFirstChild("Grabbing")
					if l__Grabbing__101 then
						local v102 = game.Players:FindFirstChild(l__Grabbing__101.Value.Name)
						local v103 = v102 and v102.Character
						if v103 then
							local v104 = Instance.new("Folder", v103)
							v104.Name = "NoFall"
							game.Debris:AddItem(v104, 5)
							local v999 = Instance.new("Vector3Value")
							v999.Name = "TPSafe"
							v999.Parent = v103
							game.Debris:AddItem(v999, 4)
						end
					end
					local l__Humanoid__68 = l__Parent__112.Humanoid
					local v69 = p8.HumanoidRootPart
					task.wait(0.5)
					local v106 = Instance.new("Vector3Value")
					v106.Name = "TPSafe"
					v106.Parent = p8
					game.Debris:AddItem(v106, 4)
					local v105 = game.ServerStorage.WarpPoints.Desert[math.random(1,5)].CFrame
					if not l__Humanoid__68.SeatPart and not l__Humanoid__68.Sit then
						v69.CFrame = v105
					end
					local u16 = {}
				end)
				task.wait(4)
				v110:Disconnect()
				local v126 = script.Close:clone()
				v126.Parent = v97
				v126:Play()
				game.TweenService:Create(v98, TweenInfo.new(0.5), {
					Scale = Vector3.new(0, 0.01, 0)
				}):Play()
				game.Debris:AddItem(v97, 1.5)
			end)
			return {speaker = "Enibras",
				msg = "One gate, coming right up.",
				endchoice = "Bye."
			}
		end
	end
end
dialogues.Enibras.v1 = function(p,v)
	if teachskill(p,classdata.Greatsword,true)~="max"then
		return dialogues.Enibras.no
	end
	if game.ServerStorage.PlayerData[p.Name].Hybrid.Value ~= "" then
		return dialogues.Enibras.no
	end
	if v.page == 1 then
		if playerdata[p.Name].Skills.Value:find("ArdorCalls") then
			return dialogues.Enibras.max
		else
			return dialogues.Enibras.p1
		end
		--[[if teach == "notmax"then
			return dialogues.Enibras.p1
		elseif teach == "max"then
			return dialogues.Enibras.max
		elseif teach == "no"then
			return dialogues.Enibras.no
		end]]
	elseif v.page == 2 then
		return dialogues.Enibras.p2
	elseif v.page == 3 then
		playerdata[p.Name].Skills.Value ..= ",ArdorCalls"
		playerdata[p.Name].NeckAccessory.Value = "AbyssSkull"
		return dialogues.Enibras.gotskill
	end
end
dialogues.Tanari.v1 = function(p,v)
	if teachskill(p,classdata.Warrior,true)~="max"then
		return dialogues.Tanari.no
	end
	if teachskill(p,classdata.SuperBlacksmith,true)~="max"then
		return dialogues.Tanari.no
	end
	if v.page == 1 then
		local teach = teachskill(p,classdata.Lapidarist,true)
		if teach == "notmax"then
			return dialogues.Tanari.p1
		elseif teach == "max"then
			return dialogues.Tanari.max
		elseif teach == "no"then
			return dialogues.Tanari.no
		end
	elseif v.page == 2 then
		local teach = teachskill(p,classdata.Lapidarist,true)
		if teach == "notmax"then
			return dialogues.Tanari.p2
		elseif teach == "max"then
			return dialogues.Tanari.max
		elseif teach == "no"then
			return dialogues.Tanari.no
		end
	elseif v.page == 3 then
		local teach = teachskill(p,classdata.Lapidarist)
		if teach == "gotskill"then
			return dialogues.Tanari.p3
		elseif teach == "poor"then
			return dialogues.Tanari.poor
		end
	end
end

dialogues.Dummy.v1 = function(p,v)
	if v.page == 1 then
		return dialogues.Dummy.p1
	end
end

dialogues.Aptorgath.v1 = function(p,v)

	local isassassin = false
	local isspy = false
	local isbard = false

	if teachskill(p, classdata.Assassin , true) == "max" then
		isassassin = true
	end
	if teachskill(p, classdata.Spy, true) == "max" then
		isspy = true
	end
	if subclasscheck(p, classdata.Bard, "Bard") == "max" then
		isbard = true
	end

	local iscandence = if game.ServerStorage.PlayerData[p.Name].Class.Value == "Candence" then true else false
	local finalis = isspy or isassassin or iscandence

	if isbard == false or finalis == false then
		return dialogues.Aptorgath.no
	end

	if v.page == 1 then
		local teach = teachskill(p,classdata.Candence,true)
		if teach == "notmax"then
			return dialogues.Aptorgath.p1
		elseif teach == "max"then
			return dialogues.Aptorgath.max
		elseif teach == "no"then
			return dialogues.Aptorgath.no
		end
	elseif v.page == 2 then
		local teach = teachskill(p,classdata.Candence,true)
		if teach == "notmax"then
			return dialogues.Aptorgath.p2
		elseif teach == "max"then
			return dialogues.Aptorgath.max
		elseif teach == "no"then
			return dialogues.Aptorgath.no
		end
	elseif v.page == 3 then
		local teach = teachskill(p,classdata.Candence)
		if teach == "gotskill"then
			return dialogues.Aptorgath.p3
		elseif teach == "poor"then
			return dialogues.Aptorgath.poor
		end
	end
end

function dialogues.Tlachta.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	local teaccheck = teachskill(p,classdata.Scholar,true)
	if teaccheck ~= "max" then
		return dialogues["Tlachta"].no
	end
	if v.page == 1 then
		local teach = teachskill(p,classdata.Botanist,true)
		if teach == "notmax"then
			return dialogues.Tlachta.p1
		elseif teach == "max"then
			return dialogues.Tlachta.max
		elseif teach == "no"then
			return dialogues.Tlachta.no
		end
	elseif v.page == 2 then
		local teach = teachskill(p,classdata.Botanist)
		if teach == "gotskill"then
			return dialogues.Tlachta.p2
		elseif teach == "poor"then
			return dialogues.Tlachta.p3
		end
	end
end
function dialogues.Fungratia.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	local teaccheck = teachskill(p,classdata.Botanist,true)
	if teaccheck ~= "max" then
		return dialogues["Fungratia"].no
	end
	if v.page == 1 then
		local teach = teachskill(p,classdata.Florist,true)
		if teach == "notmax"then
			return dialogues["Fungratia"].p1
		elseif teach == "max"then
			return dialogues["Fungratia"].max
		elseif teach == "no"then
			return dialogues["Fungratia"].no
		end
	elseif v.page == 2 then
		local teach = teachskill(p,classdata.Florist)
		if teach == "gotskill"then
			return dialogues["Fungratia"].p2
		elseif teach == "poor"then
			return dialogues["Fungratia"].p3
		end
	end
end
local function churchstuff(p,data)
	local skillstoremove = {"Sigil Helmet"}
	local skills = string.split(data.Skills.Value,",")
	for _,b in pairs(skillstoremove)do
		local toremove = table.find(skills,b)
		if toremove then
			table.remove(skills,toremove)
			data.Skills.Value = table.concat(skills,",")
		end
	end
	p.Character.Humanoid:UnequipTools()
	for _,abc in pairs(p.Backpack:GetChildren())do
		if skillstoremove[abc.Name]then
			create("DestroySkill",false,abc)
		end
	end
	commands.UpdateSkills(p)
	if data.Armor.Value~="Church Knight" and data.Class.Value~="DeepKnight" then
		commands.ChangeArmor(p,"Church Knight")
	elseif data.Armor.Value~="Deep Knight" and data.Class.Value=="DeepKnight" then
		commands.ChangeArmor(p,"Deep Knight")
	end
	if data.PrimaryWeapon.Value~="Mythril Church Spear"then
		commands.ChangeWeapon(p,"Mythril Church Spear",true)
	end
end
local function deepstuff(p,data)
	local skillstoremove = {"Church Knight Helmet"}
	local skills = string.split(data.Skills.Value,",")
	for _,b in pairs(skillstoremove)do
		local toremove = table.find(skills,b)
		if toremove then
			table.remove(skills,toremove)
			data.Skills.Value = table.concat(skills,",")
		end
	end
	p.Character.Humanoid:UnequipTools()
	for _,abc in pairs(p.Backpack:GetChildren())do
		if skillstoremove[abc.Name]then
			create("DestroySkill",false,abc)
		end
	end
	commands.UpdateSkills(p)
	if data.Armor.Value~="Deep Knight"and not data.Skills.Value:find("PrincesChaos") or not data.Skills.Value:find("PrincesVeins") or data.Race.Value ~= "Wretch" then
		commands.ChangeArmor(p,"Deep Knight")
	end
	if data.Armor.Value~="Evolved Deep Knight" and data.Class.Value=="DeepKnight" and (data.Skills.Value:find("PrincesChaos") or data.Skills.Value:find("PrincesVeins") or data.Race.Value == "Wretch") then
		commands.ChangeArmor(p,"Evolved Deep Knight")
	end
	if data.PrimaryWeapon.Value~="Mythril Church Spear"then
		commands.ChangeWeapon(p,"Mythril Church Spear",true)
	end
end
dialogues["Church Knight"].v1 = function(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	if teachskill(p,classdata.Spear,true)~="max"then
		return dialogues["Church Knight"].no
	end
	local church = teachskill(p,classdata.ChurchKnight,true)
	if church~="max"and church~="no" and data.Class.Value ~= "DeepKnight" then
		if v.page == 1 then
			return dialogues["Church Knight"].p1
		elseif v.page == 2 then
			local teach = teachskill(p,classdata.ChurchKnight,true)
			if teach == "poor"then
				return dialogues["Church Knight"].no
			end
			return dialogues["Church Knight"].p2
		elseif v.page == 3 then
			local teach = teachskill(p,classdata.ChurchKnight)
			churchstuff(p,data)
			return dialogues["Church Knight"].gotskill
		end
	elseif (data.Class.Value=="DeepKnight"or church == "max") then

		local teach = teachskill(p,classdata.DeepKnight,true)
		if teach == "max"then
			deepstuff(p,data)
			return dialogues["Church Knight"].max
		end
		if church == "max" and (data.Hybrid.Value ~= "" or data.PrimaryWeapon.Value ~= "Mythril Church Spear") then
			churchstuff(p,data)
			return dialogues["Church Knight"].max
		end
		if data.Class.Value~="DeepKnight"then
			churchstuff(p,data)
		end
		if v.page == 1 then
			if teach~="max"then
				return dialogues["Church Knight"].p1
			else
				return dialogues["Church Knight"].max
			end
		elseif v.page == 2 then
			if teach == "poor"then
				return dialogues["Church Knight"].no
			elseif teach == "notmax"then
				return dialogues["Church Knight"].p2
			end
		elseif v.page == 3 then
			deepstuff(p,data)
			local teach2 = teachskill(p,classdata.DeepKnight)
			return dialogues["Church Knight"].gotskill
		end
	else
		return dialogues["Church Knight"].no
	end
end
local SecondEnchantGems = {Ruby = true, Opal = true, Emerald = true, Sapphire = true, Diamond = true}
function dialogues.Blacksmith.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	if v.page == 1 then
		local enchants = string.split(data.Enchant.Value, ",")
		if #enchants > 1 then
			return dialogues.Blacksmith.p1nosecond
		end
		return dialogues.Blacksmith.p1
	elseif v.page == 2 then
		if v.choice == "Can you add a second, permanent enchant?" then
			return dialogues.Blacksmith.p2second
		end
		return dialogues.Blacksmith.p2
	elseif v.page == 3 then
		if v.choice == "Add it." then
			local tool = p.Character:FindFirstChildWhichIsA("Tool")
			if not tool or not tool:FindFirstChild("Gem") or not SecondEnchantGems[tool.Name] then
				return dialogues.Blacksmith.wronggem
			end
			if commands.ChangeMoney(p,data,-1000)then
				if data.Enchant.Value == ""then
					data.Enchant.Value = tool.Name
				else
					data.Enchant.Value ..= ","..tool.Name
				end
				data.EnchantTimer.Value = -1
				tool:Destroy()
				commands.RemoveFromInventory(p, tool.Name)
				return dialogues.Blacksmith.p3second
			else
				return dialogues.Blacksmith.poor
			end
		end
		local tool = p.Character:FindFirstChildWhichIsA("Tool")
		if tool and tool:FindFirstChild("Gem") then
			if commands.ChangeMoney(p,data,-100)then
				data.Enchant.Value = tool.Name
				tool:Destroy()
				commands.RemoveFromInventory(p, tool.Name)
				return dialogues.Blacksmith.p3
			else
				return dialogues.Blacksmith.poor
			end
		else
			return dialogues.Blacksmith.no
		end
	end
end
function dialogues.BlacksmithAdvanced.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	if v.page == 1 then
		return dialogues.Blacksmith.p1nosecond
	elseif v.page == 2 then
		return dialogues.BlacksmithAdvanced.p2
	elseif v.page == 3 then
		local tool = p.Character:FindFirstChildWhichIsA("Tool")
		if tool and tool:FindFirstChild("Gem") then
			if commands.ChangeMoney(p,data,-30000)then
				data.Enchant.Value = tool.Name
				return dialogues.Blacksmith.p3
			else
				return dialogues.Blacksmith.poor
			end
		else
			return dialogues.Blacksmith.no
		end
	end
end
function dialogues.Fabiana.v1(p,v)
	if v.page == 1 then
		local teach = teachskill(p,classdata.Thief,true)
		if teach == "notmax"then
			return dialogues.Fabiana.p1
		elseif teach == "max"then
			return dialogues.Fabiana.max
		elseif teach == "no"then
			return dialogues.Fabiana.no
		end
	elseif v.page == 2 then
		local teach = teachskill(p,classdata.Thief)
		if teach == "gotskill"then
			game.ServerStorage.PlayerData:FindFirstChild(p.Name).BaseDagger.Value = true
			return dialogues.Fabiana.p2
		elseif teach == "poor"then
			return dialogues.Fabiana.p3
		end
	end
	return dialogues.Fabiana.no
end
dialogues["Big Hoss"].v1 = function(p,v)
	local teach = teachskill(p,classdata.Akuma,true)
	if teach ~= "max"then
		return dialogues["Big Hoss"].no
	end
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	local teach = teachskill(p,classdata.Oni,true)
	if teach == "max" and playerdata[p.Name].NeckAccessory.Value ~= "AkumaBeads" then
		playerdata[p.Name].NeckAccessory.Value = "AkumaBeads"
		return dialogues["Big Hoss"].beads
	end

	if v.page == 1 then
		local teach = teachskill(p,classdata.Oni,true)
		if teach == "notmax"then
			return dialogues["Big Hoss"].p1
		elseif teach == "max"then
			return dialogues["Big Hoss"].max
		elseif teach == "no"then
			return dialogues["Big Hoss"].no
		end
	elseif v.page == 2 then
		local teach = teachskill(p,classdata.Oni)
		if teach == "gotskill"then
			return dialogues["Big Hoss"].p2
		elseif teach == "poor"then
			return dialogues["Big Hoss"].p3
		end
	end
	return dialogues["Big Hoss"].no
end
dialogues.Gurn.v1 = function(p,v)
	local teach = teachskill(p,classdata.Warrior,true)
	local mode = "samurai"
	if teach ~= "max"then
		return dialogues.Gurn.no
	end
	local teach2 = subclasscheck(p, classdata.Blacksmith, "Blacksmith")
	if teach2 == "max" then
		mode = "blacksmith"
	end
	if v.page == 1 then
		if mode ~= "blacksmith" then
			local teach = teachskill(p,classdata.Samurai,true)
			if teach == "notmax"then
				return dialogues.Gurn.p1
			elseif teach == "max"then
				return dialogues.Gurn.max
			elseif teach == "no"then
				return dialogues.Gurn.no
			end
		else
			local teach = teachskill(p,classdata.SuperBlacksmith,true)
			if teach == "notmax"then
				return {speaker = "Gurn",
					msg = "You wanna learn how to beat iron? gotcha. (100 Money)",
					choices = {"Yeah."},
					endchoice = "Bye."
				}
			elseif teach == "max"then
				return {speaker = "Gurn",
					msg = "I taught you all I can.",
					endchoice = "Bye."
				}
			elseif teach == "no"then
				return {speaker = "Gurn",
					msg = "It seems like once again you had to greet me with goodbye",
					endchoice = "Bye."
				}
			end
		end
	elseif v.page == 2 then
		if mode ~= "blacksmith" then
			local teach = teachskill(p,classdata.Samurai)
			if teach == "gotskill"then
				return dialogues.Gurn.p2
			elseif teach == "poor"then
				return dialogues.Gurn.p3
			end
		else
			local teach = teachskill(p,classdata.SuperBlacksmith)
			if teach == "gotskill"then
				return {speaker = "Gurn",
					msg = "Enjoy.",
					endchoice = "Bye."
				}
			elseif teach == "poor"then
				return {speaker = "Gurn",
					msg = "You're poor.",
					endchoice = "Bye."
				}
			end
		end
	end
	return dialogues.Gurn.no
end

function dialogues.Eliwood.v1(p,v)
	local skilltolearn
	local data = playerdata[p.Name]
	local skills = {
		"LordsTraining",
		"Counter",
		"Disarming Strike",
	}
	if v.page == 1 then


		for i = 1,3 do
			if not playerdata[p.Name].Skills.Value:find(skills[i]) then
				skilltolearn = skills[i]
				return {speaker = "Eliwood",
					msg = "You seem to understand the basics... We'll get started for _100 Money_",
					choices = {"Very well."},
					endchoice = "Bye."

				}
			end
		end

		if not table.find(skills, skilltolearn) then
			return dialogues.Eliwood.max
		end


	elseif v.page == 2 then
		if v.choice == "Very well." then
			for i = 1,3 do
				if not playerdata[p.Name].Skills.Value:find(skills[i]) then
					skilltolearn = skills[i]
				end
			end
			if commands["ChangeMoney"](p,data,-100,true)then
				data.Skills.Value = data.Skills.Value..","..skilltolearn
				commands["ChangeMoney"](p,data,-100,false)
				commands["Learn"](p)

				return {speaker = "Eliwood",
					msg = "Perfect.",
					endchoice = "..."

				}

			else
				return dialogues.Eliwood.poor
			end
		else
			return dialogues.Eliwood.no
		end
	else
		return dialogues.Eliwood.no
	end
end

dialogues.Linari.v1 = function(p,v)
	local teach = teachskill(p,classdata.Samurai,true)
	if teach ~= "max"then
		return dialogues.Linari.no
	end
	if v.page == 1 then
		local teach = teachskill(p,classdata.Ronin,true)
		if teach == "notmax"then
			return dialogues.Linari.p1
		elseif teach == "max"then
			return dialogues.Linari.max
		elseif teach == "no"then
			return dialogues.Linari.no
		end
	elseif v.page == 2 then
		local teach = teachskill(p,classdata.Ronin)
		if teach == "gotskill"then
			return dialogues.Linari.p2
		elseif teach == "poor"then
			return dialogues.Linari.p3
		end
	end
	return dialogues.Gurn.no
end
dialogues.Fang.v1 = function(p,v)
	local teach = teachskill(p,classdata.DragonKnight,true)
	if teach ~= "max"then
		return dialogues["Big Hoss"].no
	end
	local data = game.ServerStorage.PlayerData[p.Name]
	if v.page == 1 then
		local teach = teachskill(p,classdata.DragonSlayer,true)
		if teach == "notmax"then
			return dialogues["Fang"].p1
		elseif teach == "max"then
			if data.Skills.Value:find("StormHerald") or data.Skills.Value:find("TheEmberWyrm") or data.Skills.Value:find("TheAbyssalWyrm") then
				return dialogues["Fang"].pathdone
			elseif data.TotalGrips.Value >= 15 then
				return dialogues["Fang"].pathoffer
			else
				return dialogues["Fang"].max
			end
		elseif teach == "no"then
			return dialogues["Fang"].no
		end
	elseif v.page == 2 then
		if v.choice == "I embrace the storm" then
			commands.Learn(p.Character)
			local randomnumber = math.random(1,18)
				if randomnumber == 1 then data.UberTitle.Value = "Storm Herald"
				elseif randomnumber == 2 then data.UberTitle.Value = "Eye of the Storm"
				elseif randomnumber == 3 then data.UberTitle.Value = "Thunder Cry"
				elseif randomnumber == 4 then data.UberTitle.Value = "Chain Reaction"
				elseif randomnumber == 5 then data.UberTitle.Value = "Unchained Reaction"
				elseif randomnumber == 6 then data.UberTitle.Value = "Playful"
				elseif randomnumber == 7 then data.UberTitle.Value = "Poop)"
				elseif randomnumber == 8 then data.UberTitle.Value = "Lol"
				elseif randomnumber == 9 then data.UberTitle.Value = "Jimmy"
				elseif randomnumber == 10 then data.UberTitle.Value = "Michael"
				elseif randomnumber == 11 then data.UberTitle.Value = "Tesla"
				elseif randomnumber == 12 then data.UberTitle.Value = "Alternating Current"
				elseif randomnumber == 13 then data.UberTitle.Value = "Analogger"
				elseif randomnumber == 14 then data.UberTitle.Value = "The Conductor"
				elseif randomnumber == 15 then data.UberTitle.Value = "The Grounder"
				elseif randomnumber == 16 then data.UberTitle.Value = "Overcharge"
				elseif randomnumber == 17 then data.UberTitle.Value = "Übercharge"
				elseif randomnumber == 18 then data.UberTitle.Value = "Crowd Shocker"
			end
			data.Skills.Value ..= ",StormHerald"
			return dialogues["Fang"].stormherald
		elseif v.choice == "I embrace the ember" then
			commands.Learn(p.Character)
			local randomnumber = math.random(1,13)
				if randomnumber == 1 then data.UberTitle.Value = "Emberwyrm"
				elseif randomnumber == 2 then data.UberTitle.Value = "Great Cinder"
				elseif randomnumber == 3 then data.UberTitle.Value = "Explosivo"
				elseif randomnumber == 4 then data.UberTitle.Value = "Detonator"
				elseif randomnumber == 5 then data.UberTitle.Value = "Heartpopper"
				elseif randomnumber == 6 then data.UberTitle.Value = "Shotgun"
				elseif randomnumber == 7 then data.UberTitle.Value = "Bang Stabber"
				elseif randomnumber == 8 then data.UberTitle.Value = "Terror Spear"
				elseif randomnumber == 9 then data.UberTitle.Value = "Playful"
				elseif randomnumber == 10 then data.UberTitle.Value = "Poop)"
				elseif randomnumber == 11 then data.UberTitle.Value = "Lol"
				elseif randomnumber == 12 then data.UberTitle.Value = "Jimmy"
				elseif randomnumber == 13 then data.UberTitle.Value = "Michael"
			end
			data.Skills.Value ..= ",TheEmberWyrm"
			return dialogues["Fang"].emberwyrm
		elseif v.choice == "I embrace the abyss" then
			commands.Learn(p.Character)
			local randomnumber = math.random(1,14)
				if randomnumber == 1 then data.UberTitle.Value = "The Evil Spear"
				elseif randomnumber == 2 then data.UberTitle.Value = "Abyssdweller"
				elseif randomnumber == 3 then data.UberTitle.Value = "Bloodleech"
				elseif randomnumber == 4 then data.UberTitle.Value = "Life Extractor"
				elseif randomnumber == 5 then data.UberTitle.Value = "Blood Extractor"
				elseif randomnumber == 6 then data.UberTitle.Value = "The Extractor"
				elseif randomnumber == 7 then data.UberTitle.Value = "Relentless"
				elseif randomnumber == 8 then data.UberTitle.Value = "Endgame"
				elseif randomnumber == 9 then data.UberTitle.Value = "Bloodgrabber"
				elseif randomnumber == 10 then data.UberTitle.Value = "Playful"
				elseif randomnumber == 11 then data.UberTitle.Value = "Poop)"
				elseif randomnumber == 12 then data.UberTitle.Value = "Lol"
				elseif randomnumber == 13 then data.UberTitle.Value = "Jimmy"
				elseif randomnumber == 14 then data.UberTitle.Value = "Michael"
			end
			data.Skills.Value ..= ",TheAbyssalWyrm"
			return dialogues["Fang"].abyssalwyrm
		else
			local teach = teachskill(p,classdata.DragonSlayer)
			if teach == "gotskill"then
				return dialogues["Fang"].p2
			elseif teach == "poor"then
				return dialogues["Fang"].p3
			end
		end
	end
end
dialogues.Kalazar.v1 = function(p,v)
	local teach = teachskill(p,classdata.Scholar,true)
	if teach ~= "max"then
		return dialogues["Big Hoss"].no
	end
	if v.page == 1 then
		local teach = teachskill(p,classdata.Illusionist,true)
		if teach == "notmax"then
			return dialogues.Kalazar.begin
		elseif teach == "max"then
			return dialogues.Kalazar.max
		elseif teach == "no"then
			return dialogues.Kalazar.notread
		end
	elseif v.page == 2 then
		local teach = teachskill(p,classdata.Illusionist)
		if teach == "gotskill"then
			return dialogues.Kalazar.getskill
		elseif teach == "poor"then
			return dialogues.Kalazar.poor
		end
	end
end

function dialogues.VoiceFromAbove.v1(p,v)
	local data = game.ServerStorage.PlayerData[p.Name]
	if v.page == 1 then
		if data.Skills.Value:find("TheThunderstorm") or data.Skills.Value:find("TheCalmbeforethestorm") or data.Skills.Value:find("TheLightning") then
			return dialogues.VoiceFromAbove.alreadydone	
		elseif data.TotalGrips.Value >= 15 and data.Class.Value == "DragonSage" then
			return dialogues.VoiceFromAbove.part1
		else
			local frozenCharacter = Instance.new("Model")
			frozenCharacter.Name = "Frozen" .. p.Character.Name
			frozenCharacter.Parent = workspace.Thrown
			game.Debris:AddItem(frozenCharacter, 60)

			for _, v in pairs(p.Character:GetChildren()) do
				if v:IsA("BasePart") then
					local clone = v:Clone()
					clone.Anchored = true
					clone.CanCollide = true
					clone.Material = Enum.Material.Ice
					clone.Color = Color3.fromRGB(159, 173, 192)
					clone.Parent = frozenCharacter
					v.Transparency = 1
					v.CanCollide = false
				elseif v:IsA("Decal") then
					v:Destroy()
				end
			end
			_G.Death(p)
			return dialogues.VoiceFromAbove.notfulfilled
		end
	elseif v.choice == "I roar like a thunderstorm" and data.TotalGrips.Value >= 15 then
		commands.Learn(p.Character)
		data.Skills.Value ..= ",TheThunderstorm"
		local randomnumber = math.random(1,3)
		if randomnumber == 1 then data.UberTitle.Value = "Disciple of Raiden"
		elseif randomnumber == 2 then data.UberTitle.Value = "Fists of Thunder"
		elseif randomnumber == 3 then data.UberTitle.Value = "The Thunderstorm"
		end
		return dialogues.VoiceFromAbove.thunderstorm
	elseif v.choice == "I am the calm before the storm" and data.TotalGrips.Value >= 20 and data.MinutesMeditated.Value >= 10 then
		commands.Learn(p.Character)
		data.Skills.Value ..= ",TheCalmbeforethestorm"
		local randomnumber = math.random(1,3)
		if randomnumber == 1 then data.UberTitle.Value = "The Wise Sage"
		elseif randomnumber == 2 then data.UberTitle.Value = "The Enlightened"
		elseif randomnumber == 3 then data.UberTitle.Value = "Guardian of Dragons"
		end
		return dialogues.VoiceFromAbove.calmofthestorm
	elseif v.choice == "I am as quick as lightning" and data.TotalGrips.Value >= 20 then
		commands.Learn(p.Character)
		data.Skills.Value ..= ",TheLightning"
		local randomnumber = math.random(1,3)
		if randomnumber == 1 then data.UberTitle.Value = "Godspeed"
		elseif randomnumber == 2 then data.UberTitle.Value = "Faster than the Gods"
		elseif randomnumber == 3 then data.UberTitle.Value = "The Flashstorm"
		end
		return dialogues.VoiceFromAbove.lightningquick
	else
		local frozenCharacter = Instance.new("Model")
		frozenCharacter.Name = "Frozen" .. p.Character.Name
		frozenCharacter.Parent = workspace.Thrown
		game.Debris:AddItem(frozenCharacter, 60)

		for _, v in pairs(p.Character:GetChildren()) do
			if v:IsA("BasePart") then
				local clone = v:Clone()
				clone.Anchored = true
				clone.CanCollide = true
				clone.Material = Enum.Material.Ice
				clone.Color = Color3.fromRGB(159, 173, 192)
				clone.Parent = frozenCharacter
				v.Transparency = 1
				v.CanCollide = false
			elseif v:IsA("Decal") then
				v:Destroy()
			end
		end
		_G.Death(p)
		return dialogues.VoiceFromAbove.notfulfilled
	end
end
function dialogues.Heretic.v1(p,v)
	local data = game.ServerStorage.PlayerData[p.Name]
	if v.page == 1 then
		if data.Skills.Value:find("TheRunemaster") or data.Skills.Value:find("TheCursedFlame") or data.Skills.Value:find("TheCursedSwordsman") then
			return dialogues.Heretic.alreadydone	
		elseif data.TotalGrips.Value >= 15 and data.Class.Value == "DarkSigilKnight" then
			return dialogues.Heretic.part1
		else
			local part = Instance.new("Part", game.Workspace.NPCs.Heretic)
			part.Name = "RuneChargeEffect"
			part.Size = Vector3.new(1,1,1)
			part.Material = Enum.Material.Neon
			part.Anchored = true
			part.CanCollide = false
			part.Transparency = 0
			part.CFrame = game.Workspace.NPCs.Heretic.HumanoidRootPart.CFrame
			game.Workspace.NPCs.Heretic.HumanoidRootPart.RuneCharge:Play()
			local goal = {}
			goal.Size = Vector3.new(0,0,0)
			goal.Transparency = 1
			goal.CFrame = game.Workspace.NPCs.Heretic.HumanoidRootPart.CFrame + game.Workspace.NPCs.Heretic.HumanoidRootPart.CFrame.rightVector*math.random(5, 10)
			local tween = game:GetService("TweenService"):Create(part, TweenInfo.new(0.7), goal)
			tween:Play()
			game.Debris:AddItem(part, 1)
			task.spawn(function()
				task.wait(2)
				_G.Death(p,nil,nil,true)
				p.Character.Humanoid.Health = 0
				--v:BreakJoints()
				task.wait()
				coroutine.wrap(function()
					for i,bruh in pairs(p.Character:GetChildren()) do
						if bruh:IsA("Shirt") or bruh:IsA("Pants") then
							bruh:Destroy()
						end
						if bruh:IsA("Part") or bruh:IsA("BasePart") then
							local dec = bruh:FindFirstChildOfClass("Decal")
							if dec then
								dec:Destroy()
							end
							local bv = Instance.new("BodyVelocity")
							game.CollectionService:AddTag(bv,"AllowedBM")
							bv.Velocity = Vector3.new(math.random(-10,10),math.random(-10,10),math.random(-10,10))
							bv.Parent = bruh
							bruh.Material = Enum.Material.Neon
							local tweenInfo02 = TweenInfo.new(1.25,	Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
							local tween02 = TweenService:Create(bruh,tweenInfo02,{Transparency=1,Color=Color3.new()})
							tween02:Play()
						end
					end
				end)()
			end)
			return dialogues.Heretic.death
		end
	elseif v.choice == "Soul of the Runemaster" and data.TotalGrips.Value >= 20 and data.SoulRipsAchieved.Value >= 5 then
		commands.Learn(p.Character)
		data.Skills.Value ..= ",TheRunemaster"
		data.Skills.Value ..= ",True Vision"
		local randomnumber = math.random(1,3)
		if randomnumber == 1 then data.UberTitle.Value = "Runemaster"
		elseif randomnumber == 2 then data.UberTitle.Value = "Harvester"
		elseif randomnumber == 3 then data.UberTitle.Value = "Rune Carver"
		end
		return dialogues.Heretic.runemaster
	elseif v.choice == "Soul of the Cursed Flame" and data.TotalGrips.Value >= 15 then
		commands.Learn(p.Character)
		data.Skills.Value ..= ",TheCursedFlame"
		data.Skills.Value ..= ",True Vision"
		local randomnumber = math.random(1,3)
		if randomnumber == 1 then data.UberTitle.Value = "Inferno"
		elseif randomnumber == 2 then data.UberTitle.Value = "Blaze"
		elseif randomnumber == 3 then data.UberTitle.Value = "Cursed Flame"
		end
		return dialogues.Heretic.cursedflame
	elseif v.choice == "Soul of the Cursed Swordsman" and data.TotalGrips.Value >= 20 then
		commands.Learn(p.Character)
		data.Skills.Value ..= ",TheCursedSwordsman"
		data.Skills.Value ..= ",True Vision"
		local randomnumber = math.random(1,3)
		if randomnumber == 1 then data.UberTitle.Value = "The Man in the Mirror"
		elseif randomnumber == 2 then data.UberTitle.Value = "The Reflection"
		elseif randomnumber == 3 then data.UberTitle.Value = "The Echo"
		end
		return dialogues.Heretic.cursedswordsman
	else
		local part = Instance.new("Part", game.Workspace.NPCs.Heretic)
		part.Name = "RuneChargeEffect"
		part.Size = Vector3.new(1,1,1)
		part.Material = Enum.Material.Neon
		part.Anchored = true
		part.CanCollide = false
		part.Transparency = 0
		part.CFrame = game.Workspace.NPCs.Heretic.HumanoidRootPart.CFrame
		local goal = {}
		goal.Size = Vector3.new(0,0,0)
		goal.Transparency = 1
		goal.CFrame = game.Workspace.NPCs.Heretic.HumanoidRootPart.CFrame + game.Workspace.NPCs.Heretic.HumanoidRootPart.CFrame.rightVector*math.random(5, 10)
		local tween = game:GetService("TweenService"):Create(part, TweenInfo.new(0.7), goal)
		tween:Play()
		game.Debris:AddItem(part, 1)
		game.Workspace.NPCs.Heretic.HumanoidRootPart.RuneCharge:Play()
		task.spawn(function()
			task.wait(2)
			_G.Death(p,nil,nil,true)
			p.Character.Humanoid.Health = 0
			--v:BreakJoints()
			p.Character.HumanoidRootPart.Backfire:Play()
			task.wait()
			coroutine.wrap(function()
				for i,bruh in pairs(p.Character:GetChildren()) do
					if bruh:IsA("Shirt") or bruh:IsA("Pants") then
						bruh:Destroy()
					end
					if bruh:IsA("Part") or bruh:IsA("BasePart") then
						local dec = bruh:FindFirstChildOfClass("Decal")
						if dec then
							dec:Destroy()
						end
						local bv = Instance.new("BodyVelocity")
						game.CollectionService:AddTag(bv,"AllowedBM")
						bv.Velocity = Vector3.new(math.random(-10,10),math.random(-10,10),math.random(-10,10))
						bv.Parent = bruh
						bruh.Material = Enum.Material.Neon
						local tweenInfo02 = TweenInfo.new(1.25,	Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
						local tween02 = TweenService:Create(bruh,tweenInfo02,{Transparency=1,Color=Color3.new()})
						tween02:Play()
					end
				end
			end)()
		end)

		return dialogues.Heretic.death
	end
end
dialogues.Kai.v1 = function(p,v)
	local data = game.ServerStorage.PlayerData[p.Name]

	if v.page == 1 then
		if data.Skills.Value:find("DragonSpeech") and data.Race.Value ~= "Kasparan" then
			return {
				speaker = "Kai",
				msg = "Put what I've taught you to good use.",
				endchoice = "Bye"
			}
		elseif data.Race.Value == "Kasparan" then
			return {speaker = "Kai",
				msg = "...",
				endchoice = "Bye"
			}
		else
			return {speaker = "Kai",
				msg = "You wish to learn dragon speech?",
				choices = {"Yeah. (100 Money)"},
				endchoice = "Bye"
			}
		end
	elseif v.page == 2 then
		if commands.ChangeMoney(p, data, -100, true) then
			commands.ChangeMoney(p, data, -100)
			data.Skills.Value ..= ",DragonSpeech"
			commands.Learn(p)
			return {speaker = "Kai",
				msg = "...",
				endchoice = "Bye"
			}
		else
			return {speaker = "Kai",
				msg = "Yer poor.",
				endchoice = "Bye"
			}
		end
	end
end
dialogues.Rehagan.v1 = function(p,v)
	local teach = teachskill(p,classdata.Illusionist,true)
	if teach ~= "max"then
		return dialogues["Big Hoss"].no
	end
	if v.page == 1 then
		local teach = teachskill(p,classdata["Master Illusionist"],true)
		if teach == "notmax"then
			return dialogues.Rehagan.begin
		elseif teach == "max"then
			return dialogues.Rehagan.max
		elseif teach == "no"then
			return dialogues.Rehagan.notread
		end
	elseif v.page == 2 then
		local teach = teachskill(p,classdata["Master Illusionist"])
		if teach == "gotskill"then
			return dialogues.Rehagan.getskill
		elseif teach == "poor"then
			return dialogues.Rehagan.poor
		end
	end
end
function dialogues.Alfric.v1(p,v)
	if v.page == 1 then
		local teach = teachskill(p,classdata.Warrior,true)
		if teach == "notmax"then
			return dialogues.Alfric.p1
		elseif teach == "max"then
			return dialogues.Alfric.max
		end
	elseif v.page == 2 then
		return dialogues.Alfric.p2
	elseif v.page == 3 then
		local teach = teachskill(p,classdata.Warrior)
		if teach == "gotskill"then
			game.ServerStorage.PlayerData:FindFirstChild(p.Name).BaseSword.Value = true
			return dialogues.Alfric.p3
		elseif teach == "poor"then
			return dialogues.Alfric.p4
		end
	end
end
function dialogues.Chalphy.v1(p,v)
	if v.page == 1 then
		return dialogues.Chalphy.p1
	elseif v.page == 2 then
		return dialogues.Chalphy.p2
	elseif v.page == 3 then
		return dialogues.Chalphy.p3
	end
end
function dialogues.Delia.v1(p,v)
	if v.page == 1 then
		return dialogues.Delia.p1
	elseif v.page == 2 then
		return dialogues.Delia.p2
	end
end
function dialogues.Quinno.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	local teaccheck = teachskill(p,classdata.Scholar,true)
	if teaccheck ~= "max" then
		return dialogues["Big Hoss"].no
	end
	local lastused = p.Character.LastSpell
	local soulsnap = string.split(data.Snaps.Value,",")
	local soulsnaps = {}
	for i,v in pairs(soulsnap) do
		if v ~= "" then
			table.insert(soulsnaps, v)
		end
	end
	if v.page == 1 then
		return dialogues.Quinno.p1
	elseif v.page == 2 then
		if lastused.Value~=""then
			local idkknowdoeslastsnapequalsnapthatyouhave = false
			if table.find(soulsnaps, lastused.Value) then
				idkknowdoeslastsnapequalsnapthatyouhave = true
			end
			if idkknowdoeslastsnapequalsnapthatyouhave then
				return{
					speaker = "Quinno",
					msg = "I'm sorry fellow mage but you already have a advanced version of %"..lastused.Value.."%...",
					endchoice = "Bye",
				};
			end
			if data.Race.Value == "Castellan" then
				if #soulsnaps>1 then
					local choices = {}
					for i,v in pairs(soulsnaps)do
						table.insert(choices,v)
					end
					return{
						speaker = "Quinno",
						msg = "Ah! I see you have another request, so tell me what would you like to change?",
						choices = choices,
						endchoice = "Bye",
					};
				else
					local learned = false
					if lastused.Value == "Contrarium"then
						data.Snaps.Value = data.Snaps.Value..",Contrarium"
						learned = true
					end
					if lastused.Value == "Telorum"then
						data.Snaps.Value = data.Snaps.Value..",Telorum"
						learned = true
					end
					if lastused.Value == "Mori"then
						data.Snaps.Value = data.Snaps.Value..",Mori"
						learned = true
					end
					if lastused.Value == "Ignis"then
						data.Snaps.Value = data.Snaps.Value..",Ignis"
						learned = true
					end
					if lastused.Value == "Snarvindur"then
						data.Snaps.Value = data.Snaps.Value..",Snarvindur"
						learned = true
					end
					if lastused.Value == "Percutiens"then
						data.Snaps.Value = data.Snaps.Value..",Percutiens"
						learned = true
					end
					if lastused.Value == "Celeritas"then
						data.Snaps.Value = data.Snaps.Value..",Celeritas"
						learned = true
					end
					if lastused.Value == "Pondus"then
						data.Snaps.Value = data.Snaps.Value..",Pondus"
						learned = true
					end
					if lastused.Value == "Nocere"then
						data.Snaps.Value = data.Snaps.Value..",Nocere"
						learned = true
					end
					if lastused.Value == "Trahere"then
						data.Snaps.Value = data.Snaps.Value..",Trahere"
						learned = true
					end
					if lastused.Value == "Sagitta Sol"then
						data.Snaps.Value = data.Snaps.Value..",Sagitta Sol"
						learned = true
					end
					if lastused.Value == "Viribus"then
						data.Snaps.Value = data.Snaps.Value..",Viribus"
						learned = true
					end
					if lastused.Value == "Tenebris"then
						data.Snaps.Value = data.Snaps.Value..",Tenebris"
						learned = true
					end
					if lastused.Value == "Manus Dei"then
						data.Snaps.Value = data.Snaps.Value..",Manus Dei"
						learned = true
					end
					if lastused.Value == "Fimbulvetr"then
						data.Snaps.Value = data.Snaps.Value..",Fimbulvetr"
						learned = true
					end
					if lastused.Value == "Bawa Dei"then
						data.Snaps.Value = data.Snaps.Value..",Bawa Dei"
						learned = true
					end
					if lastused.Value == "Armis" then
						data.Snaps.Value = data.Snaps.Value..",Armis"
						learned = true
					end
					if learned then
						commands.Learn(p)

						return{
							speaker = "Quinno",
							msg = "I wish you luck on your journeys, young mage... Your soul has resonated with the spell %'"..lastused.Value.."'% .",
							endchoice = "Bye",
						};
					else
						return{
							speaker = "Quinno",
							msg = "...",
							endchoice = "Bye",
						};
					end
				end
			else 
				if #soulsnaps>0 then
					local choices = {}
					for i,v in pairs(soulsnaps)do
						table.insert(choices,v)
					end
					return{
						speaker = "Quinno",
						msg = "Ah! I see you have another request, so tell me what would you like to change?",
						choices = choices,
						endchoice = "Bye",
					};
				else
					local learned = false
					if lastused.Value == "Telorum"then
						data.Snaps.Value = data.Snaps.Value..",Telorum"
						learned = true
					end
					if lastused.Value == "Contrarium"then
						data.Snaps.Value = data.Snaps.Value..",Contrarium"
						learned = true
					end
					if lastused.Value == "Mori"then
						data.Snaps.Value = data.Snaps.Value..",Mori"
						learned = true
					end
					if lastused.Value == "Ignis"then
						data.Snaps.Value = data.Snaps.Value..",Ignis"
						learned = true
					end
					if lastused.Value == "Snarvindur"then
						data.Snaps.Value = data.Snaps.Value..",Snarvindur"
						learned = true
					end
					if lastused.Value == "Fimbulvetr"then
						data.Snaps.Value = data.Snaps.Value..",Fimbulvetr"
						learned = true
					end
					if lastused.Value == "Percutiens"then
						data.Snaps.Value = data.Snaps.Value..",Percutiens"
						learned = true
					end
					if lastused.Value == "Celeritas"then
						data.Snaps.Value = data.Snaps.Value..",Celeritas"
						learned = true
					end
					if lastused.Value == "Pondus"then
						data.Snaps.Value = data.Snaps.Value..",Pondus"
						learned = true
					end
					if lastused.Value == "Nocere"then
						data.Snaps.Value = data.Snaps.Value..",Nocere"
						learned = true
					end
					if lastused.Value == "Viribus"then
						data.Snaps.Value = data.Snaps.Value..",Viribus"
						learned = true
					end
					if lastused.Value == "Trahere"then
						data.Snaps.Value = data.Snaps.Value..",Trahere"
						learned = true
					end
					if lastused.Value == "Sagitta Sol"then
						data.Snaps.Value = data.Snaps.Value..",Sagitta Sol"
						learned = true
					end
					if lastused.Value == "Tenebris"then
						data.Snaps.Value = data.Snaps.Value..",Tenebris"
						learned = true
					end
					if lastused.Value == "Manus Dei"then
						data.Snaps.Value = data.Snaps.Value..",Manus Dei"
						learned = true
					end
					if lastused.Value == "Bawa Dei"then
						data.Snaps.Value = data.Snaps.Value..",Bawa Dei"
						learned = true
					end
					if lastused.Value == "Armis" then
						data.Snaps.Value = data.Snaps.Value..",Armis"
						learned = true
					end
					if learned then
						commands.Learn(p)

						return{
							speaker = "Quinno",
							msg = "I wish you luck on your journeys, young mage... Your soul has resonated with the spell %'"..lastused.Value.."'% .",
							endchoice = "Bye",
						};
					else
						return{
							speaker = "Quinno",
							msg = "...",
							endchoice = "Bye",
						};
					end
				end
			end
		end
	elseif v.page == 3 then
		if table.find(soulsnaps,v.choice)then
			local learned = false
			if lastused.Value == "Contrarium"then
				data.Snaps.Value = ""
				data.Snaps.Value = data.Snaps.Value..",Contrarium"
				learned = true
			end
			if lastused.Value == "Telorum"then
				data.Snaps.Value = ""
				data.Snaps.Value = data.Snaps.Value..",Telorum"
				learned = true
			end
			if lastused.Value == "Mori"then
				data.Snaps.Value = ""
				data.Snaps.Value = data.Snaps.Value..",Mori"
				learned = true
			end
			if lastused.Value == "Ignis"then
				data.Snaps.Value = ""
				data.Snaps.Value = data.Snaps.Value..",Ignis"
				learned = true
			end
			if lastused.Value == "Snarvindur"then
				data.Snaps.Value = ""
				data.Snaps.Value = data.Snaps.Value..",Snarvindur"
				learned = true
			end
			if lastused.Value == "Percutiens"then
				data.Snaps.Value = ""
				data.Snaps.Value = data.Snaps.Value..",Percutiens"
				learned = true
			end
			if lastused.Value == "Celeritas"then
				data.Snaps.Value = ""
				data.Snaps.Value = data.Snaps.Value..",Celeritas"
				learned = true
			end
			if lastused.Value == "Pondus"then
				data.Snaps.Value = ""
				data.Snaps.Value = data.Snaps.Value..",Pondus"
				learned = true
			end
			if lastused.Value == "Viribus"then
				data.Snaps.Value = ""
				data.Snaps.Value = data.Snaps.Value..",Viribus"
				learned = true
			end
			if lastused.Value == "Trahere"then
				data.Snaps.Value = ""
				data.Snaps.Value = data.Snaps.Value..",Trahere"
				learned = true
			end
			if lastused.Value == "Sagitta Sol"then
				data.Snaps.Value = ""
				data.Snaps.Value = data.Snaps.Value..",Sagitta Sol"
				learned = true
			end
			if lastused.Value == "Tenebris"then
				data.Snaps.Value = ""
				data.Snaps.Value = data.Snaps.Value..",Tenebris"
				learned = true
			end
			if lastused.Value == "Nocere"then
				data.Snaps.Value = ""
				data.Snaps.Value = data.Snaps.Value..",Nocere"
				learned = true
			end
			if lastused.Value == "Manus Dei"then
				data.Snaps.Value = ""
				data.Snaps.Value = data.Snaps.Value..",Manus Dei"
				learned = true
			end
			if lastused.Value == "Fimbulvetr"then
				data.Snaps.Value = ""
				data.Snaps.Value = data.Snaps.Value..",Fimbulvetr"
				learned = true
			end
			if lastused.Value == "Bawa Dei"then
				data.Snaps.Value = ""
				data.Snaps.Value = data.Snaps.Value..",Bawa Dei"
				learned = true
			end
			if lastused.Value == "Armis" then
				data.Snaps.Value = ""
				data.Snaps.Value = data.Snaps.Value..",Armis"
				learned = true
			end
			if learned then
				table.remove(soulsnaps,table.find(soulsnaps,v.choice))
				for i,v in pairs(soulsnaps) do
					if v ~= "" then
						data.Snaps.Value ..= ","..v
					end
				end
				commands.Learn(p)
				return{
					speaker = "Quinno",
					msg = "I wish you luck on your journeys, young mage... Your soul has resonated with the spell %'"..lastused.Value.."'% .",
					endchoice = "Bye",
				};
			else
				return{
					speaker = "Quinno",
					msg = "...",
					endchoice = "Bye",
				};
			end
		else
			return{
				speaker = "Quinno",
				msg = "...",
				endchoice = "Bye",
			};
		end
	end
end
--[[
dialogues["Bounty Officer"].v1 = function(p, v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	if v.page == 1 then
		if p.Character:FindFirstChild("Grabbing") and game.ServerStorage.PlayerData:FindFirstChild(p.Character.Grabbing.Value.Name) and game.ServerStorage.PlayerData[p.Character.Grabbing.Value.Name].Alignment.Value < 0 and not game.CollectionService:HasTag(p.Character.Grabbing.Value, "NoRot") then
			data.Alignment.Value += 1
			commands.ChangeMoney(p, game.ServerStorage.PlayerData[p.Name], 10)
			local tokill = p.Character.Grabbing.Value
			commands.CarryDrop(p.Character)
			create("TPSafe", 2, tokill)
			local selpri = workspace.Jails:GetChildren()[math.random(1, #workspace.Jails:GetChildren())]
			tokill:SetPrimaryPartCFrame(selpri.CFrame * CFrame.new(0, 0, -5))
			game.CollectionService:AddTag(tokill, "NoRot")
			task.spawn(function()
				task.wait(120)
				if tokill then
					if (selpri.Position - tokill.HumanoidRootPart.Position).Magnitude <= 25 and (selpri.CFrame.lookVector.unit:Dot((selpri.Position - tokill.HumanoidRootPart.Position).Unit) >= 0) then
						_G.Death(tokill, p, true)
					end
					if p then
						data.Alignment.Value += 3
						commands.ChangeMoney(p, game.ServerStorage.PlayerData[p.Name], 30)
					end
				end
			end)
			return dialogues["Bounty Officer"].p2
		end
		return dialogues["Bounty Officer"].p1

	elseif v.page == 2 then
		if p.Character:FindFirstChild("Grabbing") and game.ServerStorage.PlayerData:FindFirstChild(p.Character.Grabbing.Value.Name) and game.ServerStorage.PlayerData[p.Character.Grabbing.Value.Name].Alignment.Value < 0 then
			data.Alignment.Value += 4
			commands.ChangeMoney(p, game.ServerStorage.PlayerData[p.Name], 60)
			local tokill = p.Character.Grabbing.Value
			commands.CarryDrop(p.Character)
			_G.Death(tokill, p, true)
			return dialogues["Bounty Officer"].p2
		else
			local targettable = {}
			for i,v in pairs(game.ServerStorage.PlayerData:GetChildren()) do
				if v:FindFirstChild("Alignment") and v.Alignment.Value < 0 and v ~= data and workspace.Live:FindFirstChild(v.Name) then
					table.insert(targettable, v.Name)
				end
			end
			if #targettable > 0 then
				local rand = targettable[math.random(1, #targettable)]
				return {speaker = "Bounty Officer",
					msg = "Can you bring me "..data.Parent[rand].FirstName.Value.." "..data.Parent[rand].LastName.Value.." They has been spotted near "..data.Parent[rand].Area.Value,
					endchoice = "Bye."
				}
			else
				return {speaker = "Bounty Officer",
					msg = "There are no jobs for you.",
					endchoice = "Bye"
				}
			end
		end
	else
		return {speaker = "Bounty Officer",
			msg = "...",
			endchoice = "Bye"
		}
	end
end
]]
dialogues["Mother of Whispers"].v1 = function(p, v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	local teach = teachskill(p, classdata.Spy, true)
	if teach ~= "max" then
		return {speaker = "Mother of Whispers",
			msg = "...",
			endchoice = "Bye.",
		}
	end
	if data.Hybrid.Value ~= "" then
		return {speaker = "Mother of Whispers",
			msg = "It seems that you have already chosen your path.",
			endchoice = "Bye.",
		}
	end
	local blacklists = {"The Shadow", "The Soul", "The Wraith", "Freedom"}
	for i = 1,#blacklists do
		if data.Skills.Value:find(blacklists[i]) then
			if blacklists[i] == "Freedom" then
				return {speaker = "Mother of Whispers",
					msg = "Your freedom is only one that is an illusion. Go plunge yourself in the _sunken pits_, mayhaps you may find someone there to further yourself?",
					endchoice = "Bye.",
				}
			end
			return {speaker = "Mother of Whispers",
				msg = "It seems that you have already chosen your path.",
				endchoice = "Bye.",
			}
		end
	end
	if v.page == 1 then
		local teach = teachskill(p, classdata.Spy, true)
		if teach == "max" then


			return {speaker = "Mother of Whispers",
				msg = "Yes, welcome, my child. I shall bestow upon you a gift of our order. Which gift would you like?",
				choices = blacklists,
				endchoice = "Bye.",
			}
		else
			return {speaker = "Mother of Whispers",
				msg = "...",
				endchoice = "Bye.",
			}
		end
	elseif v.page == 2 then
		if not table.find(blacklists, v.choice) then
			p:Kick("Please don't choose "..v.choice.." again as it isn't allowed.")
			return
		end
		data.Skills.Value ..= ","..v.choice
		commands.Learn(p)
		if v.choice ~= "Freedom" then
			data.Class.Value = "Whisper"
		else
			data.Class.Value = "Wanderer"
		end
		if v.choice == "Freedom" then
			return {speaker = "Mother of Whispers",
				msg = "Ah, you've chosen _Freedom_ then... You are a traitor of our order, and there is no straying off of the path you have chosen. With this, go ahead and jump into the deep pits of the _Sunken Passage_, that is all that you're worth, anyways.",
				endchoice = "Bye.",
			}
		end
		return {speaker = "Mother of Whispers",
			msg = "Go forth, my child.",
			endchoice = "Bye.",
		}
	end
end
dialogues["Miner John"].v1 = function(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end

	if p.Character:FindFirstChild("Pebble") or p.Backpack:FindFirstChild("Pebble") then
		return
	end

	if v.page == 1 then
		return dialogues["Miner John"].Normal1
	elseif v.page == 2 then
		return dialogues["Miner John"].whatstones
	elseif v.page == 3 then
		if commands.ChangeMoney(p, data, -10, true) then
			commands.AddToInventory(p, "Pebble")
			commands.ChangeMoney(p, data, -10)
			return dialogues["Miner John"].iwilltake
		else
			return dialogues["Miner John"].poor
		end
	end
end
dialogues["Soul Master"].v1 = function(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	local lastused = p.Character.LastSpell
	local soulsnap = string.split(data.Snaps.Value,",")
	local soulsnaps = {}
	for i,v in pairs(soulsnap) do
		if v ~= "" then
			table.insert(soulsnaps, v)
		end
	end
	if v.page == 1 then
		return dialogues["Soul Master"].p1
	elseif v.page == 2 then
		if lastused.Value~=""and not table.find(soulsnaps,lastused.Value)then
			if commands.ChangeMoney(p,data,-1000,true)then
				return dialogues["Soul Master"].p2
			else
				return dialogues["Soul Master"].p3
			end
		else
			return{
				speaker = "Soul Master",
				msg = "...",
				endchoice = "Bye",
			};
		end
	elseif v.page == 3 then
		if lastused.Value~=""and not table.find(soulsnaps,lastused.Value)then
			if commands.ChangeMoney(p,data,-1000, true)then
				commands.ChangeMoney(p,data,-1000)
				local learned = false
				if lastused.Value == "Mori"then
					data.Snaps.Value = data.Snaps.Value..",Mori"
					learned = true
				end
				if lastused.Value == "Ignis"then
					data.Snaps.Value = data.Snaps.Value..",Ignis"
					learned = true
				end
				if lastused.Value == "Nocere"then
					data.Snaps.Value = data.Snaps.Value..",Nocere"
					learned = true
				end
				if lastused.Value == "Gelidus"then
					data.Snaps.Value = data.Snaps.Value..",Gelidus"
					learned = true
				end
				if lastused.Value == "Snarvindur"then
					data.Snaps.Value = data.Snaps.Value..",Snarvindur"
					learned = true
				end
				if lastused.Value == "Percutiens"then
					data.Snaps.Value = data.Snaps.Value..",Percutiens"
					learned = true
				end
				if lastused.Value == "Hoppa"then
					data.Snaps.Value = data.Snaps.Value..",Hoppa"
					learned = true
				end
				if lastused.Value == "Celeritas"then
					data.Snaps.Value = data.Snaps.Value..",Celeritas"
					learned = true
				end
				if lastused.Value == "Pondus"then
					data.Snaps.Value = data.Snaps.Value..",Pondus"
					learned = true
				end
				if lastused.Value == "Trahere"then
					data.Snaps.Value = data.Snaps.Value..",Trahere"
					learned = true
				end
				if lastused.Value == "Sagitta Sol"then
					data.Snaps.Value = data.Snaps.Value..",Sagitta Sol"
					learned = true
				end
				if lastused.Value == "Viribus"then
					data.Snaps.Value = data.Snaps.Value..",Viribus"
					learned = true
				end
				if lastused.Value == "Tenebris"then
					data.Snaps.Value = data.Snaps.Value..",Tenebris"
					learned = true
				end
				if lastused.Value == "Manus Dei"then
					data.Snaps.Value = data.Snaps.Value..",Manus Dei"
					learned = true
				end
				if learned then
					commands.Learn(p)
					return{
						speaker = "Soul Master",
						msg = "I wish you luck on your journeys, young mage... Your soul has resonated with the spell %'"..lastused.Value.."'% .",
						endchoice = "Bye",
					};
				else
					return{
						speaker = "Soul Master",
						msg = "...",
						endchoice = "Bye",
					};
				end
			else
				return dialogues["Soul Master"].p3
			end
		else
			return{
				speaker = "Soul Master",
				msg = "...",
				endchoice = "Bye",
			};
		end
	end
end
function dialogues.Eldin.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	local teach = teachskill(p,classdata.SigilKnight,true)
	if teach ~= "max" and data.Class.Value ~= "DarkSigilKnight"then
		return dialogues.Eldin.no
	end
	if v.page == 1 then
		local teach = teachskill(p,classdata.DarkSigilKnight,true)
		if teach == "notmax"then
			return dialogues.Eldin.p1
		elseif teach == "max"then
			local skills = string.split(data.Skills.Value,",")
			if not table.find(skills,"Soul Rip")and data.Race.Value~="Dinakeri"then
				teachskill(p,{
					skills = {
						"Soul Rip",
					};
					price = 0,
				})
			end
			return dialogues.Eldin.no
		elseif teach == "no"then
			return dialogues.Eldin.no
		end
	elseif v.page == 2 then
		local skillstoremove = {"Ice Charge","Thunder Charge","Flame Charge"}
		local skills = string.split(data.Skills.Value,",")
		for _,b in pairs(skillstoremove)do
			local toremove = table.find(skills,b)
			if toremove then
				table.remove(skills,toremove)
				data.Skills.Value = table.concat(skills,",")
			end
		end
		p.Character.Humanoid:UnequipTools()
		for _,abc in pairs(p.Backpack:GetChildren())do
			if skillstoremove[abc.Name]then
				create("DestroySkill",false,abc)
			end
		end
		commands.UpdateSkills(p)
		local teach = teachskill(p,classdata.DarkSigilKnight)
		if teach == "gotskill"then
			return dialogues.Eldin.p2
		elseif teach == "poor"then
			return dialogues.Eldin.no
		end
	end
end



function dialogues.Vinifera.v1(p,v)
	if v.page == 1 then
		local teach = subclasscheck(p,classdata.Bard, "Bard")
		if teach == "notmax"then
			return dialogues.Vinifera.p1
		elseif teach == "max"then
			return dialogues.Vinifera.max
		elseif teach == "got" then
			return dialogues.Vinifera.p4
		end
	elseif v.page == 2 then
		return dialogues.Vinifera.p2
	elseif v.page == 3 then
		local teach = subclassteachskill(p,classdata.Bard, "Bard")
		if teach == "gotskill"then
			return dialogues.Vinifera.p3
		elseif teach == "poor"then
			return dialogues.Vinifera.p4
		end
	end
end
function dialogues.Soma.v1(p,v)
	local teach = subclasscheck(p,classdata.Chef, "Chef")
	if v.page == 1 then
		if teach == "notmax"then
			return dialogues.Soma.p1
		elseif teach == "max"then
			return dialogues.Soma.p4
		elseif teach == "got" then
			return dialogues.Soma.p3
		end
	elseif v.page == 2 then
		return dialogues.Soma.p2
	elseif v.page == 3 then
		local teach = subclassteachskill(p,classdata.Chef, "Chef")
		if teach == "gotskill"then
			require(game.ServerScriptService.Modules.Commands)["Learn"](p)
			return dialogues.Soma.p3

		elseif teach == "poor"then
			return dialogues.Soma.p5
		end
	end
end

function dialogues.Grendel.v1(p,v)
	local bring = "bring"
	if v.page == 1 then
		if not p.Character:FindFirstChild("1"..bring) and not p.Character:FindFirstChild("2"..bring) and not p.Character:FindFirstChild("3"..bring) then

			local teach = subclasscheck(p,classdata.Alchemist, "Alchemist")
			if teach == "notmax"then
				return dialogues.Grendel.p1
			elseif teach == "max"then
				return dialogues.Grendel.max
			elseif teach == "got" then
				return dialogues.Grendel.p4
			end

		elseif p.Character:FindFirstChild("1"..bring) or p.Character:FindFirstChild("2"..bring) or p.Character:FindFirstChild("3"..bring) then
			if p.Character:FindFirstChild("1"..bring) then
				return {speaker = "Grendel",
					msg = "A rose grows from its roots, giving a state of panic to anyone who see it.",
					endchoice = "...",
				}

			elseif p.Character:FindFirstChild("2"..bring) then
				return {speaker = "Grendel",
					msg = "A rose grows from its roots, the one only the kings would desire.",
					endchoice = "...",
				}

			elseif p.Character:FindFirstChild("3"..bring) then
				return {speaker = "Grendel",
					msg = "A rose grows from its roots, made from clarets of fallen warriors.",
					endchoice = "...",
				}
			end
		end
	elseif v.page == 2 then
		return dialogues.Grendel.p2
	elseif v.page == 3 then
		local teach = subclassteachskill(p,classdata.Alchemist, "Alchemist")
		if teach == "gotskill"then
			require(game.ServerScriptService.Modules.Commands)["Learn"](p)
			return dialogues.Grendel.p3
		elseif teach == "poor"then
			return dialogues.Grendel.p4
		end
	end
end

function dialogues.Jafar.v1(p,v)
	local teach = teachskill(p,classdata.Thief,true)
	if teach ~= "max"then
		return dialogues.Jafar.p3
	end
	if v.page == 1 then
		local teach = teachskill(p,classdata.Assassin,true)
		if teach == "notmax"then
			if game.ServerStorage.PlayerData:FindFirstChild(p.Name).BaseDagger.Value == true or game.ServerStorage.PlayerData:FindFirstChild(p.Name).Class.Value == "Assassin" then
				return dialogues.Jafar.p1
			else
				return dialogues.Jafar.p3
			end
		elseif teach == "max"then
			return dialogues.Jafar.max
		end
		return dialogues.Jafar.no
	elseif v.page == 2 then
		return dialogues.Jafar.p2
	elseif v.page == 3 then
		local teach = teachskill(p,classdata.Assassin)
		if teach == "gotskill"then
			return dialogues.Jafar.p3
		elseif teach == "poor"then
			return dialogues.Jafar.p4
		end
	end
end

local function getrandom(number,tables)
	local chosenum = 0
	for i,v in pairs(tables)do
		chosenum = chosenum + v
		if number <= chosenum then
			return i
		end
	end
end
function ChooseWeightedItem(tables)
	local total = 0
	for _,v in pairs(tables)do
		total = total + v
	end
	local random = math.random(1,total)
	local chosen = getrandom(random,tables)
	return chosen
end
function dialogues.Shero.v1(p, v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	if v.page == 1 then
		return dialogues.Shero.p1
	elseif v.page == 2 then
		if v.choice == "Yes." then
			local eyecount = 0
			for i,v in pairs(p.Backpack:GetChildren()) do
				if v.Name == "Shrieker Eye" then
					eyecount += 1
				end
			end
			for i,v in pairs(p.Character:GetChildren()) do
				if v.Name == "Shrieker Eye" then
					eyecount += 1
				end
			end
			if eyecount >= 10 then
				local realcount = 0
				for i,v in pairs(p.Backpack:GetChildren()) do
					if v.Name == "Shrieker Eye" and realcount < 10 then
						realcount += 1
						commands["RemoveFromInventory"](p, v.Name)
						v:Destroy()
					end
				end
				for i,v in pairs(p.Character:GetChildren()) do
					if v.Name == "Shrieker Eye" and realcount < 10 then
						realcount += 1
						commands["RemoveFromInventory"](p, v.Name)
						v:Destroy()
					end
				end
				commands["AddToInventory"](p, "Scroll of Shrieker Summoning")
				return dialogues.Shero.p2
			else
				return dialogues.Shero.p3
			end
		end
	end
end
--[[dialogues.Vine.v1 = function(p,v)
	
end]]
dialogues.Rem.v1 = function(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end

	if v.page == 1 and not data.Skills.Value:find("RemTraining") then
		return {speaker = "Rem",
			msg = "Ah, hello. How can I help you?",
			choices = {"Is there anything you can teach me?"},
			endchoice = "Bye.",
		}
	elseif v.page == 2 then
		if v.choice == "Is there anything you can teach me?" then
			if data.Alignment.Value < 30 then
				return {speaker = "Rem",
					msg = "How about you try helping others first?",
					endchoice = "Bye."
				}
			end
			data.Skills.Value ..= ",RemTraining"
			commands.Learn(p)
		end
	else
		return {speaker = "Rem",
			msg = "Unfortunately. I have taught you all I can.",
			endchoice = "Bye."
		}
	end

end
dialogues["Mysterious Stranger"].v1 = function(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	if not data.HalloweenItems.Value:find("Broom Spear") and not data.HalloweenItems.Value:find("Broom Sword") then 
		return dialogues["Mysterious Stranger"].p3
	end
	if data.PrimaryWeapon.Value == "Broom Spear" or data.PrimaryWeapon.Value == "Broom Sword" then
		return dialogues["Mysterious Stranger"].p3
	end
	if v.page == 1 then
		local weapons = string.split(data.HalloweenItems.Value, ",")
		local choices = {}
		for i,v in pairs(weapons) do
			if v ~= "" then
				table.insert(choices, v)
			end
		end
		return {
			speaker = "Mysterious Stranger",
			msg = "Would you like your weapon back?",
			choices = choices,
			endchoice = "Bye"
		}
	elseif v.page == 2 then
		if commands.ChangeMoney(p,data,-100)then
			data.PrimaryWeapon.Value = v.choice
			return dialogues["Mysterious Stranger"].p3
		else
			return dialogues["Mysterious Stranger"].p2
		end
	end
end


function dialogues.Mirror.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	if v.page == 1 then
		if data.TotalGrips.Value >= 20 and data.Class.Value == "DeepKnight" and not data.Skills.Value:find("PrincesChaos") and not data.Skills.Value:find("PrincesVeins") and data.Race.Value ~= "Wretch" then
			return dialogues.Mirror.reqsmet
		else
			return dialogues.Mirror.reqsnotmet
		end
	elseif v.page == 2 then
		if v.choice == "Offer your mind" then
			if commands.ChangeInsight(p,data,-15)then
				data.Skills.Value ..= ",PrincesChaos"
				local randomnumber = math.random(1,3)
				if randomnumber == 1 then data.UberTitle.Value = "Prince's Blinded"
				elseif randomnumber == 2 then data.UberTitle.Value = "Prince's Torment"
				elseif randomnumber == 3 then data.UberTitle.Value = "Prince's Contempt"
				end
				return dialogues.Mirror.gotthing
			else
				return dialogues.Mirror.reqsnotmet
			end
		end
		if v.choice == "Offer your blade" then
			if data.TotalGrips.Value >= 25 and commands.ChangeInsight(p,data,-10) then
				data.Skills.Value ..= ",PrincesVeins"
				local randomnumber = math.random(1,3)
				if randomnumber == 1 then data.UberTitle.Value = "Prince's Blade"
				elseif randomnumber == 2 then data.UberTitle.Value = "Prince's Vanguard"
				elseif randomnumber == 3 then data.UberTitle.Value = "Prince's Apostle"
				end
				return dialogues.Mirror.gotthing
			else
				return dialogues.Mirror.reqsnotmet
			end
		end
		if v.choice == "Offer your soul" then
			if data.TotalGrips.Value >= 25 and commands.ChangeInsight(p,data,-15) then
				data.Race.Value = "Wretch"
				local randomnumber = math.random(1,3)
				if randomnumber == 1 then data.UberTitle.Value = "The Wretch"
				elseif randomnumber == 2 then data.UberTitle.Value = "The Unsightly"
				elseif randomnumber == 3 then data.UberTitle.Value = "The Dreadful"
				end
				return dialogues.Mirror.gotthing
			else
				return dialogues.Mirror.reqsnotmet
			end
		end
	else
		return dialogues.Mirror.reqsnotmet
	end
end

function dialogues.Dirbys.v1(p,v)
	if v.page == 1 then
		return dialogues.Dirbys.Normal1
	elseif v.choice == "The bust."then
		return dialogues.Dirbys.TheBust
	elseif v.choice == "The tower." then
		return dialogues.Dirbys.TheTower
	elseif v.choice == "The skull." then
		return dialogues.Dirbys.TheSkull
	elseif v.choice == "The figurine." then
		return dialogues.Dirbys.TheFigurine
	end
end

function dialogues.Koris.v1(p,v)
	local data = game.ServerStorage.PlayerData[p.Name]
	if v.page == 1 then
		return dialogues.Koris.Normal1

	elseif v.page == 2 then
		local teach = subclasscheck(p,classdata.Blacksmith, "Blacksmith")
		if teach == "notmax"then
			local teach = subclassteachskill(p,classdata.Blacksmith, "Blacksmith")
			if teach == "gotskill"then
				commands.Learn(p)
				return {speaker = "Koris",
					msg = "Enjoy!",
					endchoice = "Bye."
				}
			elseif teach == "poor"then
				return {speaker = "Koris",
					msg = "...",
					endchoice = "Bye."
				}
			end
		elseif teach == "max"then
			return {speaker = "Koris",
				msg = "... I've taught you all I can.",
				endchoice = "Bye."
			}
		elseif teach == "got" then
			return {speaker = "Koris",
				msg = "...",
				endchoice = "Bye."
			}
		end
	end
end
function dialogues.Xenyari.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	if v.page == 1 then
		if data.LastGacha.Value~=data.DaysSurvived.Value then
			return dialogues.Xenyari.p1
		else
			return dialogues.Xenyari.p4
		end
	elseif v.page == 2 then
		if data.LastGacha.Value~=data.DaysSurvived.Value then
			if commands.ChangeMoney(p,data,-250)then
				local scroll = nil
				if not data.Skills.Value:find("MageShield") then
					rolling["Scroll of Snarvindur"] += data.GachaLuck.Value
					data.GachaLuck.Value += 10
					scroll = ChooseWeightedItem(rolling)
					rolling["Scroll of Snarvindur"] -= data.GachaLuck.Value - 10
					if scroll == "Scroll of Snarvindur" then
						data.GachaLuck.Value = 0
					end
				else
					magerolling["Scroll of Snarvindur"] += data.GachaLuck.Value
					magerolling["Scroll of Percutiens"] += data.GachaLuck.Value
					magerolling["Scroll of Hoppa"] += data.GachaLuck.Value
					magerolling["Scroll of Contrarium"] += data.GachaLuck.Value
					data.GachaLuck.Value += 30
					scroll = ChooseWeightedItem(magerolling)
					magerolling["Scroll of Snarvindur"] -= data.GachaLuck.Value - 10
					magerolling["Scroll of Percutiens"] -= data.GachaLuck.Value - 10
					magerolling["Scroll of Hoppa"] -= data.GachaLuck.Value - 10
					magerolling["Scroll of Contrarium"] -= data.GachaLuck.Value - 10
					if scroll == "Scroll of Snarvindur" or scroll == "Scroll of Hoppa" or scroll == "Scroll of Percutiens" or scroll == "Scroll of Contrarium" then
						data.GachaLuck.Value = 0
					end
				end
				commands.AddToInventory(p,scroll)
				data.LastGacha.Value = data.DaysSurvived.Value
				return dialogues.Xenyari.p2
			else
				return dialogues.Xenyari.p3
			end
		else
			return dialogues.Xenyari.p4
		end
	end
end
function dialogues.Knight.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	local teach = teachskill(p,classdata.Assassin,true)
	if teach ~= "max"then
		return dialogues.Knight.p3
	end
	if v.page == 1 then
		local teach = teachskill(p,classdata.Faceless,true)
		if teach == "notmax"then
			return dialogues.Knight.p1
		elseif teach == "max"then
			if data.Skills.Value:find("TheToxin") or data.Skills.Value:find("TheBlade") or data.Skills.Value:find("TheMaster") then
				return dialogues.Knight.pathdone
			elseif data.TotalGrips.Value >= 20 then
				return dialogues.Knight.pathoffer
			else
				return dialogues.Knight.max
			end
		end
	elseif v.page == 2 then
		if v.choice == "I embrace the venom." then
			commands.Learn(p.Character)
			local randomnumber = math.random(1,6)
			if randomnumber == 1 then data.UberTitle.Value = "Mamba"
			elseif randomnumber == 2 then data.UberTitle.Value = "Suffocator"
			elseif randomnumber == 3 then data.UberTitle.Value = "Strangler"
			elseif randomnumber == 4 then data.UberTitle.Value = "Breathtaker"
			elseif randomnumber == 5 then data.UberTitle.Value = "Pathogen"
			elseif randomnumber == 6 then data.UberTitle.Value = "Hazardous"
			end
			data.Skills.Value ..= ",TheToxin,Septic Burst"
			commands.UpdateSkills(p)
			return dialogues.Knight.venomembrace
		elseif v.choice == "Show me the blade." then
			commands.Learn(p.Character)
			local randomnumber = math.random(1,5)
			if randomnumber == 1 then data.UberTitle.Value = "Psycho"
			elseif randomnumber == 2 then data.UberTitle.Value = "Maniac"
			elseif randomnumber == 3 then data.UberTitle.Value = "Curtain of Red"
			elseif randomnumber == 4 then data.UberTitle.Value = "Perforator"
			elseif randomnumber == 5 then data.UberTitle.Value = "Bladedancer"
			end
			-- no Tool grant here: Twinfang is bought, not taught (see dialogues.shop's
			-- "Twinfang" gate above, which checks this exact skill string)
			data.Skills.Value ..= ",TheBlade"
			return dialogues.Knight.bladeembrace
		elseif v.choice == "I am beyond a name." then
			commands.Learn(p.Character)
			-- TheMaster path gets no random UberTitle like the other two paths - just a fixed
			-- nickname replacing whatever "Faceless One"/"Fungless One" page 3 set
			local randomnumber = math.random(1,5)
			if randomnumber == 1 then data.UberTitle.Value = "Master Assassin"
			elseif randomnumber == 2 then data.UberTitle.Value = "Blade for Hire"
			elseif randomnumber == 3 then data.UberTitle.Value = "Sharpest Dressed"
			elseif randomnumber == 4 then data.UberTitle.Value = "Stalker"
			elseif randomnumber == 5 then data.UberTitle.Value = "Ambusher"
			end
			data.Skills.Value ..= ",TheMaster"
			commands.UpdateSkills(p)
			return dialogues.Knight.masterembrace
		else
			return dialogues.Knight.p2
		end
	elseif v.page == 3 then
		local teach = teachskill(p,classdata.Faceless)
		if teach == "gotskill"then
			if p.Character.Head:FindFirstChildWhichIsA("Decal")then
				p.Character.Head:FindFirstChildWhichIsA("Decal"):Destroy()
			end
			if data.Race.Value == "Scroom" or data.Race.Value == "Metascroom" then
				data.FirstName.Value = "Fungless One"
			else
				data.FirstName.Value = "Faceless One"
			end
			return dialogues.Knight.p3
		elseif teach == "poor"then
			return dialogues.Knight.p4
		end
	end
	return dialogues.Knight.p4
end

local NoAscensionRaces = {
	"Cameo",
	"Dullahan",
	"Howler",
	"LesserNavaran"
}

local HS = game:GetService("HttpService")

local AscensionQuests = {
	["AzaelQuest"] = function(p,v)
		local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
		local globaldata = game.ServerStorage.PlayerData:FindFirstChild(p.Name.."Global")
		if not data or not p.Character then
			return
		end
		local StoryMarker = HS:JSONDecode(data.StoryMarker.Value)
		local GlobalQuests = HS:JSONDecode(globaldata.GlobalQuests.Value)
		if v.page == 1 then
			if GlobalQuests["Ascensions"] and GlobalQuests["Ascensions"]["Azael"] == true then
				StoryMarker["Ascension"] = {}
				StoryMarker["Ascension"]["NoAs'endo"] = true
				data.Ascended.Value = true
				data.StoryMarker.Value = HS:JSONEncode(StoryMarker)
				commands.Learn(p)
				return dialogues["As'endoAzael"].ascended
			end
			if not StoryMarker["Ascension"] or (#StoryMarker["Ascension"] == 0 and not StoryMarker["Ascension"]["Azael"]) then
				return dialogues["As'endoAzael"].startedp1
			elseif StoryMarker["Ascension"]["Azael"] == "As'endo" then
				return dialogues["As'endoAzael"].cameback
			elseif StoryMarker["Ascension"]["Azael"] == "Finished" then
				return dialogues["As'endoAzael"].camebackinsight
			end
		elseif v.choice == "I'm seeking the Ascencion Trial" then
			return dialogues["As'endoAzael"].startedp2
		elseif v.choice == "Where can he be found?" then
			return dialogues["As'endoAzael"].startedp3
		elseif v.choice == "I will not fail" then
			StoryMarker["Ascension"] = {}
			StoryMarker["Ascension"]["Azael"] = "Started"
			StoryMarker["Ascension"]["NoAs'endo"] = true
			data.StoryMarker.Value = HS:JSONEncode(StoryMarker)
			local spawns = game.ServerStorage.SpawnPoints[data.SpawnPoint.Value]:GetChildren()
			local tpcf = spawns[math.random(1,#spawns)].CFrame
			local a = Instance.new("Folder", p.Character)
			a.Name = "TPSafe"
			p.Character.HumanoidRootPart.CFrame = tpcf
			task.delay(0.1,function()
				create("Knocked",2,p.Character)
			end)
			task.delay(2, function()
				a:Destroy()
			end)
			return dialogues["As'endo"].started
		elseif v.choice == "You tricked me" then
			return dialogues["As'endoAzael"].cameback2
		elseif v.choice == "What!?" then
			return dialogues["As'endoAzael"].cameback3
		elseif v.choice == "..." then
			return dialogues["As'endoAzael"].cameback4
		elseif v.choice == "I don't have any other choice" then
			if GlobalQuests["Ascensions"] and GlobalQuests["Ascensions"]["Azael"] == true then
				StoryMarker["Ascension"] = {}
				StoryMarker["Ascension"]["NoAs'endo"] = true
				data.Ascended.Value = true
				data.StoryMarker.Value = HS:JSONEncode(StoryMarker)
				commands.Learn(p)
				return dialogues["As'endoAzael"].ascended
			end
			return dialogues["As'endoAzael"].cameback5
		elseif v.choice == "Let's do it" then
			if commands.ChangeInsight(p,data, -20) then
				StoryMarker["Ascension"] = {}
				StoryMarker["Ascension"]["NoAs'endo"] = true
				if not GlobalQuests["Ascensions"] then
					GlobalQuests["Ascensions"] = {}
				end
				GlobalQuests["Ascensions"]["Azael"] = true
				globaldata.GlobalQuests.Value = game:GetService("HttpService"):JSONEncode(GlobalQuests)
				data.Ascended.Value = true
				data.StoryMarker.Value = HS:JSONEncode(StoryMarker)
				commands.Learn(p)
				return dialogues["As'endoAzael"].ascended
			else
				StoryMarker["Ascension"]["Azael"] = "Finished"
				data.StoryMarker.Value = HS:JSONEncode(StoryMarker)
				return dialogues["As'endoAzael"].noinsight
			end
		end
	end,
	["HaseldanQuest"] = function(p,v)
		local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
		local globaldata = game.ServerStorage.PlayerData:FindFirstChild(p.Name.."Global")
		if not data or not p.Character then
			return
		end
		local StoryMarker = HS:JSONDecode(data.StoryMarker.Value)
		local GlobalQuests = HS:JSONDecode(globaldata.GlobalQuests.Value)
	end,
}

local AscendedDialogues = {
	["AzaelDialogue"] = function(p,v)
		local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
		if not data or not p.Character or (p.Character and p.Character:FindFirstChild("Dead")) then
			return
		end
		return dialogues["As'endoAzael"].ruleroffire
	end,
}

dialogues["As'endo"].v1 = function(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character or (p.Character and p.Character:FindFirstChild("Dead")) then
		return
	end
	if data and (data.IsUltra.Value ~= true and data.Hybrid.Value == "") then
		create("Knocked", 5, p.Character)
		create("Dead",3,p.Character)
		task.delay(2, function()
			_G.Death(p.Character)
		end)
		return dialogues["As'endo"].notquest
	end
	if data.Race.Value and table.find(NoAscensionRaces, data.Race.Value) then
		return dialogues["As'endo"].noobtainmentrace
	end
	if data.Ascended.Value ~= true then
		return AscensionQuests[data.Race.Value.."Quest"](p,v)
	else
		return AscendedDialogues[data.Race.Value.."Dialogue"](p,v)
	end
end

function dialogues.Isaac.v1(p,v)
	if v.page == 1 then
		local teach = teachskill(p,classdata.Monk,true)
		if teach == "notmax"then
			return dialogues.Isaac.p1
		elseif teach == "max"then
			return dialogues.Isaac.max
		end
	elseif v.page == 2 then
		return dialogues.Isaac.p2
	elseif v.page == 3 then
		local teach = teachskill(p,classdata.Monk)
		if teach == "gotskill"then
			return dialogues.Isaac.p3
		elseif teach == "poor"then
			return dialogues.Isaac.p4
		end
	end
	return dialogues.Isaac.p4
end
dialogues["Ragash Al'vul"].v1 = function(p,v)
	local teach = teachskill(p,classdata.Monk,true)
	if not playerdata[p.Name].Skills.Value:find("DragonSpeech") then
		return dialogues["Ragash Al'vul"].nodragonspeech
	end
	if teach ~= "max"then
		return dialogues["Ragash Al'vul"].no
	end
	if v.page == 1 then
		local teach = teachskill(p,classdata.DragonSage,true)
		if teach == "notmax"then
			return dialogues["Ragash Al'vul"].p1
		elseif teach == "max"then
			return dialogues["Ragash Al'vul"].max
		end
	elseif v.page == 2 then
		return dialogues["Ragash Al'vul"].p2
	elseif v.page == 3 then
		local teach = teachskill(p,classdata.DragonSage)
		if teach == "gotskill"then
			return dialogues["Ragash Al'vul"].p3
		elseif teach == "poor"then
			return dialogues["Ragash Al'vul"].p4
		end
	end
	return dialogues["Ragash Al'vul"].p4
end
function dialogues.Frey.v1(p,v)
	local teach = teachskill(p,classdata.Warrior,true)
	if teach ~= "max"then
		return dialogues.Frey.no
	end
	if v.page == 1 then
		local teach = teachskill(p,classdata.SigilKnight,true)
		if teach == "notmax"then
			if game.ServerStorage.PlayerData:FindFirstChild(p.Name).BaseSword.Value == true or game.ServerStorage.PlayerData:FindFirstChild(p.Name).Class.Value == "SigilKnight" then
				return dialogues.Frey.p1
			else
				return dialogues.Frey.no
			end
		elseif teach == "max"then
			return dialogues.Frey.max
		elseif teach == "no"then
			return dialogues.Frey.no
		end
	elseif v.page == 2 then
		return dialogues.Frey.p2
	elseif v.page == 3 then
		local teach = teachskill(p,classdata.SigilKnight)
		if teach == "gotskill"then
			return dialogues.Frey.p3
		elseif teach == "poor"then
			return dialogues.Frey.p4
		end
	end
end
function dialogues.Jagen.v1(p,v)
	local teach = teachskill(p,classdata.SigilKnight,true)
	if teach ~= "max"then
		local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
		if not data then return end
		if data.Class.Value == "Vanguard" and not data.Skills.Value:find("ChargeMastery") then
			data.Skills.Value = data.Skills.Value..",ChargeMastery"
			commands.Learn(p)
			return dialogues.Jagen.ChargeMastery
		end
		return dialogues.Jagen.no
	end
	if v.page == 1 then
		local teach = teachskill(p,classdata.SigilKnightCommander,true)
		if teach == "notmax"then
			return dialogues.Jagen.p1
		elseif teach == "max"then
			return dialogues.Jagen.max
		elseif teach == "no"then
			return dialogues.Jagen.no
		end
	elseif v.page == 2 then
		return dialogues.Jagen.p2
	elseif v.page == 3 then
		local teach = teachskill(p,classdata.SigilKnightCommander)
		if teach == "gotskill"then
			return dialogues.Jagen.p3
		elseif teach == "poor"then
			return dialogues.Jagen.p4
		end
	end
end

dialogues.Cosere.v1 = function(player,v)

end

dialogues["Witch Malady"].v1 = function(player,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(player.Name)
	if not data or not player.Character then
		return
	end
	if v.page == 1 then
		return dialogues["Witch Malady"].p1
	elseif v.page == 2 then
		if v.choice == "I have some Candy." then
			local candy = 0
			for i,v in pairs(player.Backpack:GetChildren()) do
				if v:FindFirstChild("Candy") then
					candy += 1
					v:Destroy()
					commands.RemoveFromInventory(player,v.Name)
				end
			end
			if typeof(candy) ~= "string" then
				candy = tostring(candy)
			end
			data.Candy.Value += candy
			return {
				speaker = "Witch Malady";
				msg = "You now have "..data.Candy.Value.." Candy Points.";
				endchoice = "Bye";
			};
		elseif v.choice == "I'd like to redeem my Candy Points." then
			return dialogues["Witch Malady"].p2
		end
	elseif v.page == 3 then
		if v.choice == "Equipment." then
			return dialogues["Witch Malady"].equipment
		elseif v.choice == "Spells." then
			return dialogues["Witch Malady"].spells
		elseif v.choice == "Anything special?" then
			local value = Instance.new("NumberValue")
			value.Name = "Dullahan_BUY"
			value.Value = 150
			value.Parent = player
			game.Debris:AddItem(value,25)
			return dialogues["Witch Malady"].p3
		elseif v.choice == "I'd like to redeem my Candy Points." then
			return dialogues["Witch Malady"].p2
		end
	elseif v.page == 4 then
		if v.choice == "I'll pay." then
			local checkprice = player:FindFirstChild("Dullahan_BUY")
			local price = checkprice.Value
			if checkprice then
				checkprice:Destroy()
				if data.Candy.Value >= price then
					data.Candy.Value -= price
					data.Race.Value = "Dullahan"
					respawn:Fire(player)
					return dialogues["Witch Malady"].bye
				else
					return dialogues["Witch Malady"].poor
				end
			end
		elseif v.choice == "Nosferatus" then
			local value = Instance.new("NumberValue")
			value.Name = "Nosferatus_BUY"
			value.Value = 75
			value.Parent = player
			game.Debris:AddItem(value,25)
			return {
				speaker = "Witch Malady";
				msg = "Summon a Vampire to siphon the blood of your enemies. It will cost you 75 Candy Points; you currently have "..data.Candy.Value.." Candy Points.";
				choices = {"I'll pay."};
				endchoice = "Bye";
			};
		elseif v.choice == "Gourdus" then
			local value = Instance.new("NumberValue")
			value.Name = "Gourdus_BUY"
			value.Value = 75
			value.Parent = player
			game.Debris:AddItem(value,25)
			return {
				speaker = "Witch Malady";
				msg = "Satiate your hunger every hour with pumpkins. It will cost you 75 Candy Points; you currently have "..data.Candy.Value.." Candy Points.";
				choices = {"I'll pay."};
				endchoice = "Bye";
			};
		elseif v.choice == "Broom Sword" then
			local value = Instance.new("NumberValue")
			value.Name = "BroomSword_BUY"
			value.Value = 25
			value.Parent = player
			game.Debris:AddItem(value,25)
			return {
				speaker = "Witch Malady";
				msg = "A sword made of rare wood that is as sturdy as Mythril. It will cost you 25 Candy Points; you currently have "..data.Candy.Value.." Candy Points.";
				choices = {"I'll pay."};
				endchoice = "Bye";
			};
		elseif v.choice == "Broom Spear" then
			local value = Instance.new("NumberValue")
			value.Name = "BroomSpear_BUY"
			value.Value = 25
			value.Parent = player
			game.Debris:AddItem(value,25)
			return {
				speaker = "Witch Malady";
				msg = "A spear made of rare wood that is as sturdy as my Ladle. It will cost you 25 Candy Points; you currently have "..data.Candy.Value.." Candy Points.";
				choices = {"I'll pay."};
				endchoice = "Bye";
			};
		elseif v.choice == "Orange Cowl" then
			local value = Instance.new("NumberValue")
			value.Name = "OrangeCowl_BUY"
			value.Value = 15
			value.Parent = player
			game.Debris:AddItem(value,25)
			return {
				speaker = "Witch Malady";
				msg = "A cloth dyed in pumpkin blood... It will cost you 15 Candy Points; you currently have "..data.Candy.Value.." Candy Points.";
				choices = {"I'll pay."};
				endchoice = "Bye";
			};
		elseif v.choice == "Jack o'Lantern Chair" then
			local value = Instance.new("NumberValue")
			value.Name = "Jack o'Lantern_BUY"
			value.Value = 50
			value.Parent = player
			game.Debris:AddItem(value,25)
			return {
				speaker = "Witch Malady";
				msg = "A chair carved from my favorite pumpkin... It will cost you 50 Candy Points; you currently have "..data.Candy.Value.." Candy Points.";
				choices = {"I'll pay."};
				endchoice = "Bye";
			};
		elseif v.choice == "Jack o'Lantern Chair Green" then
			local value = Instance.new("NumberValue")
			value.Name = "Jack o'Lantern Green_BUY"
			value.Value = 50
			value.Parent = player
			game.Debris:AddItem(value,25)
			return {
				speaker = "Witch Malady";
				msg = "A chair carved from my favorite pumpkin dyed in green blood... It will cost you 50 Candy Points; you currently have "..data.Candy.Value.." Candy Points.";
				choices = {"I'll pay."};
				endchoice = "Bye";
			};
		elseif v.choice == "Jack o'Lantern Chair Purple" then
			local value = Instance.new("NumberValue")
			value.Name = "Jack o'Lantern Purple_BUY"
			value.Value = 50
			value.Parent = player
			game.Debris:AddItem(value,25)
			return {
				speaker = "Witch Malady";
				msg = "A chair carved from my favorite pumpkin straight from the abyss... It will cost you 50 Candy Points; you currently have "..data.Candy.Value.." Candy Points.";
				choices = {"I'll pay."};
				endchoice = "Bye";
			};
		elseif v.choice == "Purple Cowl" then
			local value = Instance.new("NumberValue")
			value.Name = "PurpleCowl_BUY"
			value.Value = 15
			value.Parent = player
			game.Debris:AddItem(value,25)
			return {
				speaker = "Witch Malady";
				msg = "A hood pulled from the abyss itself... It will cost you 15 Candy Points; you currently have "..data.Candy.Value.." Candy Points.";
				choices = {"I'll pay."};
				endchoice = "Bye";
			};
		end
	elseif v.page == 5 then
		if v.choice == "I'll pay." then
			local checkitem = player:FindFirstChild("Nosferatus_BUY") or player:FindFirstChild("Gourdus_BUY") or player:FindFirstChild("BroomSword_BUY") or player:FindFirstChild("BroomSpear_BUY") or player:FindFirstChild("OrangeCowl_BUY") or player:FindFirstChild("PurpleCowl_BUY") or player:FindFirstChild("Jack o'Lantern_BUY") or player:FindFirstChild("Jack o'Lantern Green_BUY") or player:FindFirstChild("Jack o'Lantern Purple_BUY")
			local price = checkitem.Value
			if checkitem then
				checkitem:Destroy()
				if data.Candy.Value < price then
					return dialogues["Witch Malady"].poor
				end
				if tostring(checkitem) == "Nosferatus_BUY" then
					if not table.find(string.split(data.Skills.Value,","),"Nosferatus") then
						data.Skills.Value = data.Skills.Value..",Nosferatus"
						data.Candy.Value -= price
						return dialogues["Witch Malady"].bye
					else
						return dialogues["Witch Malady"].alreadyowned
					end
				elseif tostring(checkitem) == "Gourdus_BUY" then
					if not table.find(string.split(data.Skills.Value,","),"Gourdus") then
						data.Skills.Value = data.Skills.Value..",Gourdus"
						data.Candy.Value -= price
						return dialogues["Witch Malady"].bye
					else
						return dialogues["Witch Malady"].alreadyowned
					end
				elseif tostring(checkitem) == "BroomSword_BUY" then
					if not data.HalloweenItems.Value:find("Broom Sword") then
						commands.ChangeWeapon(player,"Broom Sword")
						data.Candy.Value -= price
						data.HalloweenItems.Value ..= ",Broom Sword"
						return dialogues["Witch Malady"].bye
					else
						return dialogues["Witch Malady"].alreadyowned
					end
				elseif tostring(checkitem) == "BroomSpear_BUY" then
					if not data.HalloweenItems.Value:find("Broom Spear") then
						commands.ChangeWeapon(player,"Broom Spear")
						data.Candy.Value -= price
						data.HalloweenItems.Value ..= ",Broom Spear"
						return dialogues["Witch Malady"].bye
					else
						return dialogues["Witch Malady"].alreadyowned
					end
				elseif tostring(checkitem) == "OrangeCowl_BUY" then
					if not table.find(string.split(data.Skills.Value,","),"Orange Cowl") then
						data.Skills.Value = data.Skills.Value..",Orange Cowl"
						data.Candy.Value -= price
						return dialogues["Witch Malady"].bye
					else
						return dialogues["Witch Malady"].alreadyowned
					end
				elseif tostring(checkitem) == "Jack o'Lantern_BUY" then
					if not table.find(string.split(data.Skills.Value,","),"Jack o'Lantern Chair") then
						data.Skills.Value = data.Skills.Value..",Jack o'Lantern Chair"
						data.Candy.Value -= price
						return dialogues["Witch Malady"].bye
					else
						return dialogues["Witch Malady"].alreadyowned
					end
				elseif tostring(checkitem) == "Jack o'Lantern Green_BUY" then
					if not table.find(string.split(data.Skills.Value,","),"Jack o'Lantern Chair Green") then
						data.Skills.Value = data.Skills.Value..",Jack o'Lantern Chair Green"
						data.Candy.Value -= price
						return dialogues["Witch Malady"].bye
					else
						return dialogues["Witch Malady"].alreadyowned
					end
				elseif tostring(checkitem) == "Jack o'Lantern Purple_BUY" then
					if not table.find(string.split(data.Skills.Value,","),"Jack o'Lantern Chair Purpl") then
						data.Skills.Value = data.Skills.Value..",Jack o'Lantern Chair Purple"
						data.Candy.Value -= price
						return dialogues["Witch Malady"].bye
					else
						return dialogues["Witch Malady"].alreadyowned
					end
				elseif tostring(checkitem) == "PurpleCowl_BUY" then
					if not table.find(string.split(data.Skills.Value,","),"Purple Cowl") then
						data.Skills.Value = data.Skills.Value..",Purple Cowl"
						data.Candy.Value -= price
						return dialogues["Witch Malady"].bye
					else
						return dialogues["Witch Malady"].alreadyowned
					end
				end
				return dialogues["Witch Malady"].bye
			end
		end
	end
end

local function merchant(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	if v.page == 1 then
		return dialogues.Merchant.p1
	elseif v.page == 2 then
		if v.choice == "Could you appraise this for me?"then
			local tool = p.Character:FindFirstChildWhichIsA("Tool")
			if not tool then
				return{
					speaker = "Merchant",
					msg = "Appraise what? Hold something out.",
					choices = {"Could you appraise this for me?"},
					endchoice = "Bye",
				};
			end
			if tool:FindFirstChild("MoneyValue")then
				local total = tool.MoneyValue.Value
				total = math.round(total)
				v.total = math.round(total * 1000 / 3)
				v.tosell = {}
				table.insert(v.tosell,tool)
				return{
					speaker = "Merchant",
					msg = "Hmm. I'd pay "..total.." Money.",
					choices = {"It's a deal."},
					endchoice = "Bye",
				};
			end
		elseif v.choice == "Can I sell in bulk?"then
			local total = 0
			local tosell = {}
			for _,b in pairs(p.Backpack:GetChildren())do
				if b:FindFirstChild("MoneyValue")and not b:FindFirstChild("SpellType") and not b:FindFirstChild("Candy") then
					if string.find(b.Name, "Dagger") or string.find(b.Name, "Spear") or string.find(b.Name, "Sword") then
						if game.ServerStorage.PlayerData[p.Name].Class.Value == "Lapidarist" then
							b.MoneyValue.Value *= 1.33
						end
					end
					total += b.MoneyValue.Value
					total = math.round(total) * 1000
					table.insert(tosell,b)
				end
			end
			if total<=0 then
				return dialogues.Merchant.p3
			end
			total *= 2
			total = math.round(total / 3)
			v.total = total
			v.tosell = tosell
			return{
				speaker = "Merchant",
				msg = "Hmm. I'd pay "..total.." Money.",
				choices = {"It's a deal."},
				endchoice = "Bye",
			};
		end
	elseif v.page == 3 then
		if v.choice == "It's a deal."then
			if v.total and v.tosell then
				for _,v in pairs(v.tosell)do
					commands.RemoveFromInventory(p,v.Name)
					v:Destroy()
				end
				commands.ChangeMoney(p,playerdata[p.Name],v.total)
				return dialogues.Merchant.p4
			else
				return dialogues.Merchant.p3
			end
		end
	end
end

local function fungchant(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	if v.page == 1 and data.Race.Value == "Scroom" then
		return dialogues.Fungchant.p1
	elseif v.page == 1 and data.Race.Value ~= "Scroom" then
		return dialogues.Fungchant.noscroom
	elseif v.page == 2 then
		if v.choice == "Could you appraise this for me?"then
			local tool = p.Character:FindFirstChildWhichIsA("Tool")
			if not tool then
				return{
					speaker = "Fungchant",
					msg = "Appraise what? Hold something out.",
					choices = {"Could you appraise this for me?"},
					endchoice = "Bye",
				};
			end
			if tool:FindFirstChild("MoneyValue")then
				local total = tool.MoneyValue.Value
				total = math.round(total)
				v.total = total
				v.tosell = {}
				table.insert(v.tosell,tool)
				return{
					speaker = "Fungchant",
					msg = "Hmm. I'd pay "..total.." Money.",
					choices = {"It's a deal."},
					endchoice = "Bye",
				};
			end
		elseif v.choice == "Can I sell in bulk?"then
			local total = 0
			local tosell = {}
			for _,b in pairs(p.Backpack:GetChildren())do
				if b:FindFirstChild("MoneyValue")and not b:FindFirstChild("SpellType") and not b:FindFirstChild("Candy") then
					if string.find(b.Name, "Dagger") or string.find(b.Name, "Spear") or string.find(b.Name, "Sword") then
						if game.ServerStorage.PlayerData[p.Name].Class.Value == "Lapidarist" then
							b.MoneyValue.Value *= 1.33
						end
					end
					total += b.MoneyValue.Value
					total = math.round(total)
					table.insert(tosell,b)
				end
			end
			if total<=0 then
				return dialogues.Fungchant.p3
			end
			total *= 2
			v.total = total
			v.tosell = tosell
			return{
				speaker = "Fungchant",
				msg = "Hmm. I'd pay "..total.." Money.",
				choices = {"It's a deal."},
				endchoice = "Bye",
			};
		end
	elseif v.page == 3 then
		if v.choice == "It's a deal."then
			if v.total and v.tosell then
				for _,v in pairs(v.tosell)do
					commands.RemoveFromInventory(p,v.Name)
					v:Destroy()
				end
				commands.ChangeMoney(p,playerdata[p.Name],v.total)
				return dialogues.Fungchant.p4
			else
				return dialogues.Fungchant.p3
			end
		end
	end
end

local CollectionService = game:GetService("CollectionService")
local HasTag = CollectionService.HasTag
local RemoveTag = CollectionService.RemoveTag
function dialogues.Doctor.v1(p,v)
	local data = playerdata:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	--local Injuries = string.split(data.Injuries.Value,",")
	if data.Race.Value == "Gaian" then
		return dialogues.Doctor.gaian
	end
	if v.page == 1 then
		return dialogues.Doctor.p1
	elseif v.page == 2 then
		--local allin = {}
		--for i,v in pairs(Injuries) do
		--	if v ~= "" then
		--		table.insert(allin, v)
		--	end
		--end
		--local paidamount = math.clamp(#allin * 6, 5, 35)
		if data.Money.Value < 1 then
			return dialogues.Doctor.poor
		else
			commands.ChangeMoney(p,data,-1)
			return {
				speaker = "Doctor",
				msg = "You have some injuries that I can sort out, but the operation will cost you 15 Money.",
				choices = {"Patch me up."},
				endchoice = "Bye",
			};
		end
	elseif v.page == 3 then
		if commands.ChangeMoney(p,data,-15)then
			local crazy = ""
			local Unfixable = {"MetalArm","vampirism","armless"}
			for i,v in pairs(Unfixable) do 
				if data.Injuries.Value:find(v) then
					crazy = crazy..","..v
				end
			end
			data.Injuries.Value = ""
			data.Injuries.Value = crazy
			return dialogues.Doctor.p2
		else
			return dialogues.Doctor.poor
		end
	end
end
dialogues["Lab Assistant"].v1 = function(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	if data.Race.Value == "Construct"then
		return dialogues["Lab Assistant"].max
	else
		if v.page == 1 then
			return dialogues["Lab Assistant"].p1
		elseif v.page == 2 then
			return dialogues["Lab Assistant"].p2
		elseif v.page == 3 then
			return dialogues["Lab Assistant"].p3
		elseif v.page == 4 then
			if workspace.Map.ConstructLabMod.slop.Inside.Value == false then
				if data.Race.Value == "Tepplar"then
					return dialogues["Lab Assistant"].no
				end
				coroutine.wrap(function()
					workspace.Map.ConstructLabMod.slop.Inside.Value = true
					workspace.Map.ConstructLabMod.slop.Sound:Play()
					local Animation = p.Character.Humanoid:LoadAnimation(game.ServerStorage.Assets.ConstructTube.Animation)
					local immortal = Instance.new("Accessory")
					immortal.Name = "Immortal"
					immortal.Parent = p.Character
					local action = Instance.new("Accessory")
					action.Name = "Action"
					action.Parent = p.Character
					local Danger = Instance.new("Accessory")
					Danger.Name = "Danger"
					Danger.Parent = p
					game.Debris:AddItem(Danger,65)
					p.Character:SetPrimaryPartCFrame(workspace.Map.ConstructLabMod.slop.CFrame)
					p.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.Angles(0,math.rad(-90),0)
					p.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.Angles(0,math.rad(180),0)
					Animation:Play()
					local bruh = data.DaysSurvived.Value
					local gotconstruct = false
					if math.random(1,6)<5 then
						gotconstruct = true
					end
					task.wait(20)
					Animation:Stop()
					workspace.Map.ConstructLabMod.slop.Sound:Stop()
					workspace.Map.ConstructLabMod.slop.Inside.Value = false
					if gotconstruct then
						if data.Race.Value == "Ashiin" then
							data.Race.Value = "Construct"
							data.Skills.Value ..= ",TrainedCombat"
						else
							data.Race.Value = "Construct"
						end
						if data.Lives.Value>1 then
							data.Lives.Value = 1
						end
						if Danger and Danger.Parent then
							Danger:Destroy()
						end
						local a = Instance.new("Folder", p.Character)
						a.Name = "TPSafe"
						game.Debris:AddItem(a, 0.5)
						p.Character:PivotTo(workspace.NPCs["Lab Assistant"].HumanoidRootPart.CFrame)
						
					else
						_G.Death(p)
					end
					return
				end)()
				return dialogues.exit
			else
				return dialogues["Lab Assistant"].no
			end
		end
	end
end
function dialogues.Gilderoy.v1(p,v)
	if v.page == 1 then
		return dialogues.Gilderoy.p1
	else
		if commands.ChangeMoney(p,game.ServerStorage.PlayerData[p.Name],-15)then
			commands.AddToInventory(p,"Dye Packet")
		else
			return dialogues.Gilderoy.p3
		end
		return dialogues.Gilderoy.p2
	end
end
function dialogues.Naimere.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	local GlobalData = game.ServerStorage.PlayerData:FindFirstChild(p.Name.."Global")
	if not GlobalData or not p.Character then
		return
	end
	local UnlockedEdicts = GlobalData.UnlockedEdicts.Value
	local UnlockedEdictsJSON = HttpService:JSONDecode(UnlockedEdicts)
	local StoryMarker = HttpService:JSONDecode(data.StoryMarker.Value)
	if v.page == 1 then
		if UnlockedEdictsJSON.Blademaster > 0 or data.TotalGrips.Value < 15 then
			return dialogues.Naimere.notallowed
		end
		if not StoryMarker.StartedBMaster then
			return dialogues.Naimere.bmquest
		elseif StoryMarker.StartedBMaster and StoryMarker.StartedBMaster == "Obelisks" then
			if StoryMarker.BMasterObelisks["Obelisk1"] and 
				StoryMarker.BMasterObelisks["Obelisk2"] and
				StoryMarker.BMasterObelisks["Obelisk3"] and
				StoryMarker.BMasterObelisks["Obelisk4"] 
			then
				StoryMarker.StartedBMaster = "Death"
				data.StoryMarker.Value = HttpService:JSONEncode(StoryMarker)
				return dialogues.Naimere.finished
			else
				return dialogues.Naimere.notfinished
			end
		elseif StoryMarker.StartedBMaster == "Death" then
			return dialogues.Naimere.notfinished2
		elseif StoryMarker.StartedBMaster == "CompletedBMasterEdict" then
			return dialogues.Naimere.completededict
		end
	elseif v.page == 2 then
		return dialogues.Naimere.bmquest1
	elseif v.page == 3 then
		return dialogues.Naimere.bmquest2
	elseif v.page == 4 then
		return dialogues.Naimere.bmquest3
	elseif v.page == 5 then
		StoryMarker.StartedBMaster = "Obelisks"
		StoryMarker.BMasterObelisks = {}
		data.StoryMarker.Value = HttpService:JSONEncode(StoryMarker)
		return dialogues.Naimere.bmquest4
	end
end
function dialogues.Ria.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	if v.page == 1 then
		local Skills = data.Skills.Value
		if not Skills:find("fanariletter") then
			return dialogues.Ria.p1
		end
		commands.ChangeMoney(p,game.ServerStorage.PlayerData[p.Name],200)
		data.Alignment.Value += 5
		local skillstoremove = {"fanariletter"}
		local skills = string.split(data.Skills.Value,",")
		for _,b in pairs(skillstoremove)do
			local toremove = table.find(skills,b)
			if toremove then
				table.remove(skills,toremove)
				data.Skills.Value = table.concat(skills,",")
				game.ServerStorage.PlayerData[p.Name].Skills.Value ..= ",finishedfanariquest"
				return dialogues.Ria.questfanari

			end
		end

	else
		if commands.ChangeMoney(p,game.ServerStorage.PlayerData[p.Name],-15)then
			commands.AddToInventory(p,"Dye Packet")
		else
			return dialogues.Ria.p3
		end
		return dialogues.Ria.p2
	end
end

function dialogues.Fanari.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end

	local Skills = data.Skills.Value
	if Skills:find("finishedfanariquest")  then
		return dialogues.Fanari.endofquest
	end
	if Skills:find("fanariletter")  then
		return dialogues.Fanari.saidsure
	end
	if v.page == 1 then
		return dialogues.Fanari.p1
	elseif v.choice == "What is it?" then
		return dialogues.Fanari.p2
	elseif v.choice == "Sure." then
		game.ServerStorage.PlayerData[p.Name].Skills.Value ..= ",fanariletter" 
		return dialogues.Fanari.saidsure
	end
end

local function CheckEdictObtainment(p)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	local globaldata = game.ServerStorage.PlayerData:FindFirstChild(p.Name.."Global")
	local UnlockedEdicts = game:GetService("HttpService"):JSONDecode(globaldata.UnlockedEdicts.Value)
	local StoryMarker = game:GetService("HttpService"):JSONDecode(data.StoryMarker.Value)
	if StoryMarker["SeerGhosts"] and StoryMarker["SeerGhosts"] == "CompletedSeerEdict" then
		if UnlockedEdicts["Seer"] == 0 then
			UnlockedEdicts["Seer"] = 1
		end
	end
	if StoryMarker["StartedHealer"] and StoryMarker["StartedHealer"] == "CompletedHealerEdict" then
		if UnlockedEdicts["Healer"] == 0 then
			UnlockedEdicts["Healer"] = 1
		end
	end
	if StoryMarker["StartedBMaster"] and StoryMarker["StartedBMaster"] == "CompletedBMasterEdict" then
		if UnlockedEdicts["Blademaster"] == 0 then
			UnlockedEdicts["Blademaster"] = 1
		end
	end
	globaldata.UnlockedEdicts.Value = game:GetService("HttpService"):JSONEncode(UnlockedEdicts)
end

function dialogues.SolanBall.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	if data.Lives.Value <= 0 and data.LostWar.Value == false and data.UberTitle.Value ~= "The Ashiin King" and data.UberTitle.Value ~= "The Haseldan King" then
		if v.page == 1 and data.Lives.Value == 0 then
			return dialogues.SolanBall.p1
		elseif v.choice == "..." then
			return dialogues.SolanBall.p2
		elseif v.choice == "I need another chance" then
			data.Lives.Value = 1
			if data.Race.Value == "Cameo" then
				data.Lives.Value = 2
			end
			local spawns = game.ServerStorage.SpawnPoints[data.SpawnPoint.Value]:GetChildren()
			local randomspawn = spawns[math.random(1,#spawns)].CFrame
			data.LastPosition.Value = randomspawn.X..","..randomspawn.Y..","..randomspawn.Z
			game.ServerStorage.Requests.Respawn:Fire(p)
			return dialogues.SolanBall.done
		elseif v.choice == "I give up" then
			data.Wiped.Value = true
			CheckEdictObtainment(p)
			task.spawn(function()
				task.wait(3)
				p.Character:Destroy()
				local CharacterCreationUI = game.ServerScriptService.WorldHandler.GameLoaded.CharacterCreationGui:Clone()
				CharacterCreationUI.Parent = p:WaitForChild("PlayerGui")
			end)
			return dialogues.SolanBall.done
		end
	elseif data.LostWar.Value == true then
		if v.page == 1 and data.Lives.Value == 0 then
			return dialogues.SolanBall.p1
		elseif v.choice == "..." then
			return dialogues.SolanBall.lostwar
		elseif v.choice == "Very well then" then
			data.Wiped.Value = true
			CheckEdictObtainment(p)
			task.spawn(function()
				task.wait(3)
				p.Character:Destroy()
				local CharacterCreationUI = game.ServerScriptService.WorldHandler.GameLoaded.CharacterCreationGui:Clone()
				CharacterCreationUI.Parent = p:WaitForChild("PlayerGui")
			end)
			return dialogues.SolanBall.done
		end
	elseif data.Lives.Value <= 0 and data.LostWar.Value == false and  (data.UberTitle.Value == "The Ashiin King" or data.UberTitle.Value == "The Haseldan King") then
		if v.page == 1 and data.Lives.Value == 0 then
			return dialogues.SolanBall.cameop1
		elseif v.choice == "..." then
			return dialogues.SolanBall.cameop2
		elseif v.choice == "I need another chance" then
			data.Wiped.Value = true
			CheckEdictObtainment(p)
			task.spawn(function()
				task.wait(3)
				p.Character:Destroy()
				local CharacterCreationUI = game.ServerScriptService.WorldHandler.GameLoaded.CharacterCreationGui:Clone()
				CharacterCreationUI.Parent = p:WaitForChild("PlayerGui")
			end)
			return dialogues.SolanBall.theend
		elseif v.choice == "Forgive me" then
			data.Wiped.Value = true
			CheckEdictObtainment(p)
			task.spawn(function()
				task.wait(3)
				p.Character:Destroy()
				local CharacterCreationUI = game.ServerScriptService.WorldHandler.GameLoaded.CharacterCreationGui:Clone()
				CharacterCreationUI.Parent = p:WaitForChild("PlayerGui")
			end)
			return dialogues.SolanBall.forgiven
		end
	else
		if v.page == 1 then
			return dialogues.SolanBall.haslife
		else
			if v.choice == "I'm lost" then
				local spawns = game.ServerStorage.SpawnPoints[data.SpawnPoint.Value]:GetChildren()
				local randomspawn = spawns[math.random(1,#spawns)].CFrame
				data.LastPosition.Value = randomspawn.X..","..randomspawn.Y..","..randomspawn.Z
				game.ServerStorage.Requests.Respawn:Fire(p)
				return dialogues.SolanBall.done
			end
		end
	end
end

function dialogues.Tal.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	local GlobalData = game.ServerStorage.PlayerData:FindFirstChild(p.Name.."Global")
	if not GlobalData or not p.Character then
		return
	end
	local UnlockedEdicts = GlobalData.UnlockedEdicts.Value
	if game:GetService("HttpService"):JSONDecode(UnlockedEdicts)["Seer"] > 0 or data.EdictType.Value ~= "" or game:GetService("HttpService"):JSONDecode(data.StoryMarker.Value)["StartedHealer"] then
		return dialogues.Tal.SeerUser
	end
	if game:GetService("HttpService"):JSONDecode(data.StoryMarker.Value)["SeerGhosts"] and game:GetService("HttpService"):JSONDecode(data.StoryMarker.Value)["SeerGhosts"] == "TalkedtoTal" then
		return dialogues.Tal.Cameback
	elseif game:GetService("HttpService"):JSONDecode(data.StoryMarker.Value)["SeerGhosts"] and (game:GetService("HttpService"):JSONDecode(data.StoryMarker.Value)["SeerGhosts"] == "Seen" or game:GetService("HttpService"):JSONDecode(data.StoryMarker.Value)["SeerGhosts"] == "SeenOracle") then
		return dialogues.Tal.DifferentFace
	end
	if v.page == 1 then
		return dialogues.Tal.p1
	elseif v.choice == "Hey." then
		return dialogues.Tal.p2
	elseif v.choice == "I'm sorry?" then
		return dialogues.Tal.p3
	elseif v.choice == "..." then
		local StoryMarker = game:GetService("HttpService"):JSONDecode(data.StoryMarker.Value)
		StoryMarker["SeerGhosts"] = "TalkedtoTal"
		StoryMarker["Ghosts"] = "First"
		data.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
		return dialogues.Tal.p4
	end
end

dialogues["Old Man"].v1 = function(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	local GlobalData = game.ServerStorage.PlayerData:FindFirstChild(p.Name.."Global")
	if not GlobalData or not p.Character then
		return
	end
	local UnlockedEdicts = GlobalData.UnlockedEdicts.Value
	local StoryMarker = game:GetService("HttpService"):JSONDecode(data.StoryMarker.Value)
	if game:GetService("HttpService"):JSONDecode(UnlockedEdicts)["Healer"] > 0 or data.EdictType.Value ~= "" or StoryMarker["SeerGhosts"] then
		return dialogues["Old Man"].notquest
	end
	if StoryMarker["StartedHealer"] and StoryMarker["StartedHealer"] == "Cleansing" then
		return dialogues["Old Man"].cleansing
	end
	if StoryMarker["StartedHealer"] and StoryMarker["StartedHealer"] == "CompletedHealerEdict" then
		return dialogues["Old Man"].bornanew
	end
	if StoryMarker["StartedHealer"] and StoryMarker["StartedHealer"] ~= "Finished" then
		return dialogues["Old Man"].cameback
	end
	if v.page == 1 then	
		if StoryMarker["StartedHealer"] and StoryMarker["StartedHealer"] == "Finished" then
			return dialogues["Old Man"].step1done
		end
		return dialogues["Old Man"].p1
	elseif v.choice == "Need any help?" then
		return dialogues["Old Man"].p2
	elseif v.choice == "A dream?" then
		return dialogues["Old Man"].p3
	elseif v.choice == "Please? I'm interested" then
		StoryMarker["StartedHealer"] = {}
		data.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
		return dialogues["Old Man"].p4
	elseif v.choice == "I feel born anew" then
		return dialogues["Old Man"].cleanyourself
	elseif v.choice == "What?" then
		StoryMarker["StartedHealer"] = "Cleansing"
		data.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
		return dialogues["Old Man"].youheardmeright
	end
end

function dialogues.Ghost.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	local GlobalData = game.ServerStorage.PlayerData:FindFirstChild(p.Name.."Global")
	if not GlobalData or not p.Character then
		return
	end
	local StoryMarker = game:GetService("HttpService"):JSONDecode(data.StoryMarker.Value)
	if not StoryMarker["Ghosts"] then
		return dialogues.Ghost.notquest
	elseif StoryMarker["Ghosts"] == "Second" then
		return dialogues.Ghost.forgot
	elseif StoryMarker["Ghosts"] ~= "Second" and StoryMarker["Ghosts"] ~= "First" then
		return dialogues.Ghost.past
	end
	if v.page == 1 then
		return dialogues.Ghost.p1
	elseif v.choice == "I am seeking Clairvoyance" then
		StoryMarker["Ghosts"] = "Second"
		data.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
		return dialogues.Ghost.p2
	end
end

function dialogues.Ghost2.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	local GlobalData = game.ServerStorage.PlayerData:FindFirstChild(p.Name.."Global")
	if not GlobalData or not p.Character then
		return
	end
	local StoryMarker = game:GetService("HttpService"):JSONDecode(data.StoryMarker.Value)
	if not StoryMarker["Ghosts"] then
		return dialogues.Ghost2.notquest
	elseif StoryMarker["Ghosts"] == "Third" then
		return dialogues.Ghost2.forgot
	elseif StoryMarker["Ghosts"] ~= "Third" and StoryMarker["Ghosts"] ~= "Second" then
		return dialogues.Ghost2.past
	end
	if v.page == 1 then
		return dialogues.Ghost2.p1
	elseif v.choice == "What's the price of Clairvoyance?" then
		StoryMarker["Ghosts"] = "Third"
		data.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
		return dialogues.Ghost2.p2
	end
end

function dialogues.Ghost3.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	local GlobalData = game.ServerStorage.PlayerData:FindFirstChild(p.Name.."Global")
	if not GlobalData or not p.Character then
		return
	end
	local StoryMarker = game:GetService("HttpService"):JSONDecode(data.StoryMarker.Value)
	if not StoryMarker["Ghosts"] then
		return dialogues.Ghost3.notquest
	elseif StoryMarker["Ghosts"] == "Fourth" then
		return dialogues.Ghost3.forgot
	elseif StoryMarker["Ghosts"] ~= "Fourth" and StoryMarker["Ghosts"] ~= "Third" then
		return dialogues.Ghost3.past
	end
	if v.page == 1 then
		return dialogues.Ghost3.p1
	elseif v.choice == "You knew about me?" then
		return dialogues.Ghost3.p2
	elseif v.choice == "Where is this brother?" then
		StoryMarker["Ghosts"] = "Fourth"
		data.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
		return dialogues.Ghost3.p3
	end
end

function dialogues.Ghost4.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	local GlobalData = game.ServerStorage.PlayerData:FindFirstChild(p.Name.."Global")
	if not GlobalData or not p.Character then
		return
	end
	local StoryMarker = game:GetService("HttpService"):JSONDecode(data.StoryMarker.Value)
	if not StoryMarker["Ghosts"] then
		return dialogues.Ghost4.notquest
	elseif StoryMarker["SeerGhosts"] == "Seen" then
		return dialogues.Ghost4.forgot
	end
	if v.page == 1 then
		return dialogues.Ghost4.p1
	elseif v.choice == "Could you be the one with the third eye?" then
		StoryMarker["SeerGhosts"] = "Seen"
		data.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
		return dialogues.Ghost4.p2
	end
end

function dialogues.Grimtooth.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	local GlobalData = game.ServerStorage.PlayerData:FindFirstChild(p.Name.."Global")
	if not GlobalData or not p.Character then
		return
	end
	local StoryMarker = game:GetService("HttpService"):JSONDecode(data.StoryMarker.Value)
	if data.Race.Value == "Howler" then
		return dialogues.Grimtooth.howler
	end
	if v.page == 1 then
		if not StoryMarker["HowlerQuest"] then
			return dialogues.Grimtooth.p1
		end
		if StoryMarker["HowlerQuest"]["StartedQuest"] and not StoryMarker["HowlerQuest"]["TurnedinLannis"] and not StoryMarker["HowlerQuest"]["TurnedinHF"] then
			return dialogues.Grimtooth.back
		end
		if StoryMarker["HowlerQuest"]["StartedQuest"] and StoryMarker["HowlerQuest"]["TurnedinLannis"] and not StoryMarker["HowlerQuest"]["TurnedinHF"] then
			return dialogues.Grimtooth.backlannis
		end
		if StoryMarker["HowlerQuest"]["StartedQuest"] and not StoryMarker["HowlerQuest"]["TurnedinLannis"] and StoryMarker["HowlerQuest"]["TurnedinHF"] then
			return dialogues.Grimtooth.backhf
		end
		if StoryMarker["HowlerQuest"]["StartedQuest"] and StoryMarker["HowlerQuest"]["TurnedinLannis"] and StoryMarker["HowlerQuest"]["TurnedinHF"] then
			return dialogues.Grimtooth.gottensmarter
		end
	elseif v.choice == "What is this place?" then
		return dialogues.Grimtooth.p2
	elseif v.choice == "What are you doing here?" then
		return dialogues.Grimtooth.p3
	elseif v.choice == "Could you transform me?" then
		StoryMarker["HowlerQuest"] = {}
		StoryMarker["HowlerQuest"]["StartedQuest"] = true
		data.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
		return dialogues.Grimtooth.p4
	elseif v.choice == "Here" then
		if not StoryMarker["HowlerQuest"]["TurnedinLannis"] and not StoryMarker["HowlerQuest"]["TurnedinHF"] then
			if p.Character and p.Character:FindFirstChild("Lannis Amulet") then
				StoryMarker["HowlerQuest"]["TurnedinLannis"] = true
				data.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
				require(game.ServerScriptService.Modules.Commands).RemoveFromInventory(p,"Lannis Amulet")
				p.Character:FindFirstChild("Lannis Amulet"):Destroy()
				return dialogues.Grimtooth.turnedinlannis
			elseif p.Character and p.Character:FindFirstChild("Howler Friend") then
				StoryMarker["HowlerQuest"]["TurnedinHF"] = true
				data.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
				require(game.ServerScriptService.Modules.Commands).RemoveFromInventory(p,"Howler Friend")
				p.Character:FindFirstChild("Howler Friend"):Destroy()
				return dialogues.Grimtooth.turnedinhowler
			else
				return dialogues.Grimtooth.noitem
			end
		elseif StoryMarker["HowlerQuest"]["TurnedinLannis"] and StoryMarker["HowlerQuest"]["TurnedinLannis"] == true and not StoryMarker["HowlerQuest"]["TurnedinHF"] then
			if p.Character and p.Character:FindFirstChild("Howler Friend") then
				StoryMarker["HowlerQuest"]["TurnedinHF"] = true
				data.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
				require(game.ServerScriptService.Modules.Commands).RemoveFromInventory(p,"Howler Friend")
				p.Character:FindFirstChild("Howler Friend"):Destroy()
				return dialogues.Grimtooth.finishedpart1
			else
				return dialogues.Grimtooth.noitem
			end
		elseif StoryMarker["HowlerQuest"]["TurnedinHF"] and StoryMarker["HowlerQuest"]["TurnedinHF"] == true and not StoryMarker["HowlerQuest"]["TurnedinLannis"] then
			if p.Character and p.Character:FindFirstChild("Lannis Amulet") then
				StoryMarker["HowlerQuest"]["TurnedinLannis"] = true
				data.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
				require(game.ServerScriptService.Modules.Commands).RemoveFromInventory(p,"Lannis Amulet")
				p.Character:FindFirstChild("Lannis Amulet"):Destroy()
				return dialogues.Grimtooth.finishedpart1
			else
				return dialogues.Grimtooth.noitem
			end
		end
	elseif v.choice == "Very well" then
		if commands.ChangeInsight(p,data,-10)then
			data.Race.Value = "Howler"
			return dialogues.Grimtooth.finishedpart2
		else
			return dialogues.Grimtooth.noinsight
		end
	elseif v.choice == "Yes" then
		if commands.ChangeInsight(p,data,-10)then
			data.Race.Value = "Howler"
			return dialogues.Grimtooth.finishedpart2
		else
			return dialogues.Grimtooth.noinsight
		end
	end
end
local TweenService = game:GetService("TweenService")
local SeerPuzzle = game.Workspace.SeerPuzzle
local AllowMovement = SeerPuzzle:FindFirstChild("AllowMovement")
local FirstPosition = CFrame.new(1057.99097, 3781.15088, 87.1486053, -4.37113883e-08, 0, -1, 0, 1, 0, 1, 0, -4.37113883e-08)
local SecondPosition = CFrame.new(1057.99097, 3781.15088, 87.1486053, 0, 0, -1, 0, 1, 0, 1, 0, 0)
local ThirdPosition = CFrame.new(1057.99097, 3781.15088, 87.1499405, -4.37113883e-08, 0, -1, 0, 1, 0, 1, 0, -4.37113883e-08)
function dialogues.SeerPuzzle1.v1(p,v)
	if AllowMovement.Value ~= true or game.workspace.NPCs.SeerPuzzle1.Enabled.Value == false then
		return
	end
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	local GlobalData = game.ServerStorage.PlayerData:FindFirstChild(p.Name.."Global")
	if not GlobalData or not p.Character then
		return
	end
	local StoryMarker = game:GetService("HttpService"):JSONDecode(data.StoryMarker.Value)
	if not StoryMarker["Ghosts"] and
		StoryMarker["SeerGhosts"] ~= "Seen" and
		data.EdictType ~= "Seer" and
		data.EdictProgression.Value ~= 1 and
		(not StoryMarker["Tier1Quest"] or StoryMarker["Tier1Quest"] ~= "SeenOracle") then
		return dialogues.SeerPuzzle.notquest
	end
	if v.page == 1 then
		return dialogues.SeerPuzzle1.move
	elseif v.page == 2 then
		local Position = SeerPuzzle.FirstPosition
		Position.Value += 1
		if Position.Value == 6 then
			Position.Value = 0
		end
		AllowMovement.Value = false
		local NewOrientation = SeerPuzzle.FirstCircle.CFrame * CFrame.Angles(math.rad(60),0,0)
		TweenService:Create(SeerPuzzle.FirstCircle, TweenInfo.new(1), {CFrame = NewOrientation}):Play()
		SeerPuzzle.SeerDoorOuter.Sound:Play()
		task.spawn(function()
			task.wait(1.5)
			AllowMovement.Value = true
		end)
		return dialogues.SeerPuzzle.moved
	end
end

function dialogues.SeerPuzzle2.v1(p,v)
	if AllowMovement.Value ~= true or game.workspace.NPCs.SeerPuzzle2.Enabled.Value == false then
		return
	end
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	local GlobalData = game.ServerStorage.PlayerData:FindFirstChild(p.Name.."Global")
	if not GlobalData or not p.Character then
		return
	end
	local StoryMarker = game:GetService("HttpService"):JSONDecode(data.StoryMarker.Value)
	if not StoryMarker["Ghosts"] and
		StoryMarker["SeerGhosts"] ~= "Seen" and
		data.EdictType ~= "Seer" and
		data.EdictProgression.Value ~= 1 and
		(not StoryMarker["Tier1Quest"] or StoryMarker["Tier1Quest"] ~= "SeenOracle") then
		return dialogues.SeerPuzzle.notquest
	end
	if v.page == 1 then
		return dialogues.SeerPuzzle2.move
	elseif v.page == 2 then
		local Position = SeerPuzzle.SecondPosition
		Position.Value += 1
		if Position.Value == 6 then
			Position.Value = 0
		end
		AllowMovement.Value = false
		local NewOrientation = SeerPuzzle.SecondCircle.CFrame * CFrame.Angles(math.rad(60),0,0)
		TweenService:Create(SeerPuzzle.SecondCircle, TweenInfo.new(1), {CFrame = NewOrientation}):Play()
		SeerPuzzle.SeerDoorOuter.Sound:Play()
		task.spawn(function()
			task.wait(1.5)
			AllowMovement.Value = true
		end)
		return dialogues.SeerPuzzle.moved
	end
end

function dialogues.SeerPuzzle3.v1(p,v)
	if AllowMovement.Value ~= true or game.workspace.NPCs.SeerPuzzle3.Enabled.Value == false then
		return
	end
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	local GlobalData = game.ServerStorage.PlayerData:FindFirstChild(p.Name.."Global")
	if not GlobalData or not p.Character then
		return
	end
	local StoryMarker = game:GetService("HttpService"):JSONDecode(data.StoryMarker.Value)
	if not StoryMarker["Ghosts"] and
		StoryMarker["SeerGhosts"] ~= "Seen" and
		data.EdictType ~= "Seer" and
		data.EdictProgression.Value ~= 1 and
		(not StoryMarker["Tier1Quest"] or StoryMarker["Tier1Quest"] ~= "SeenOracle") then
		return dialogues.SeerPuzzle.notquest
	end
	if v.page == 1 then
		return dialogues.SeerPuzzle3.move
	elseif v.page == 2 then
		local Position = SeerPuzzle.ThirdPosition
		Position.Value += 1
		if Position.Value == 6 then
			Position.Value = 0
		end
		AllowMovement.Value = false
		local NewOrientation = SeerPuzzle.ThirdCircle.CFrame * CFrame.Angles(math.rad(60),0,0)
		TweenService:Create(SeerPuzzle.ThirdCircle, TweenInfo.new(1), {CFrame = NewOrientation}):Play()
		SeerPuzzle.SeerDoorOuter.Sound:Play()
		task.spawn(function()
			task.wait(1.5)
			AllowMovement.Value = true
		end)
		return dialogues.SeerPuzzle.moved
	end
end

function dialogues.GateMaster.v1(p,v)
	if AllowMovement.Value ~= true then
		return
	end
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	local GlobalData = game.ServerStorage.PlayerData:FindFirstChild(p.Name.."Global")
	if not GlobalData or not p.Character then
		return
	end
	local StoryMarker = game:GetService("HttpService"):JSONDecode(data.StoryMarker.Value)
	if not StoryMarker["Ghosts"] and
		StoryMarker["SeerGhosts"] ~= "Seen" and
		data.EdictType ~= "Seer" and
		data.EdictProgression.Value ~= 1 and
		(not StoryMarker["Tier1Quest"] or StoryMarker["Tier1Quest"] ~= "SeenOracle") then
		return dialogues.GateMaster.notquest
	end
	if v.page == 1 then
		return dialogues.GateMaster.p1
	elseif v.page == 2 then
		if SeerPuzzle.FirstPosition.Value == 2 and SeerPuzzle.SecondPosition.Value == 1 and SeerPuzzle.ThirdPosition.Value == 3 then
			SeerPuzzle.FirstPosition.Value = 0
			SeerPuzzle.SecondPosition.Value = 0
			SeerPuzzle.ThirdPosition.Value = 0
			SeerPuzzle.SeerDoorOuter.Sound:Play()
			AllowMovement.Value = false
			TweenService:Create(SeerPuzzle.FirstCircle, TweenInfo.new(1), {Transparency = 1}):Play()
			for i,v in pairs(SeerPuzzle.FirstCircle:GetChildren()) do
				if v:IsA("MeshPart") then
					TweenService:Create(v, TweenInfo.new(1), {Transparency = 1}):Play()
				end
			end
			TweenService:Create(SeerPuzzle.SecondCircle, TweenInfo.new(1), {Transparency = 1}):Play()
			for i,v in pairs(SeerPuzzle.SecondCircle:GetChildren()) do
				if v:IsA("MeshPart") then
					TweenService:Create(v, TweenInfo.new(1), {Transparency = 1}):Play()
				end
			end
			TweenService:Create(SeerPuzzle.ThirdCircle, TweenInfo.new(1), {Transparency = 1}):Play()
			for i,v in pairs(SeerPuzzle.ThirdCircle:GetChildren()) do
				if v:IsA("MeshPart") then
					TweenService:Create(v, TweenInfo.new(1), {Transparency = 1}):Play()
				end
			end
			TweenService:Create(SeerPuzzle.SeerDoorOuter, TweenInfo.new(1), {Transparency = 1}):Play()
			TweenService:Create(SeerPuzzle.Cylinder, TweenInfo.new(1), {Transparency = 1}):Play()
			game.Workspace.NPCs.SeerPuzzle1.Enabled.Value = false
			game.Workspace.NPCs.SeerPuzzle2.Enabled.Value = false
			game.Workspace.NPCs.SeerPuzzle3.Enabled.Value = false
			game.Workspace.NPCs.MistyGate.Enabled.Value = true
			task.spawn(function()
				task.wait(10)
				TweenService:Create(SeerPuzzle.FirstCircle, TweenInfo.new(1), {Transparency = 0}):Play()
				for i,v in pairs(SeerPuzzle.FirstCircle:GetChildren()) do
					if v:IsA("MeshPart") then
						TweenService:Create(v, TweenInfo.new(1), {Transparency = 0}):Play()
					end
				end
				TweenService:Create(SeerPuzzle.SecondCircle, TweenInfo.new(1), {Transparency = 0}):Play()
				for i,v in pairs(SeerPuzzle.SecondCircle:GetChildren()) do
					if v:IsA("MeshPart") then
						TweenService:Create(v, TweenInfo.new(1), {Transparency = 0}):Play()
					end
				end
				TweenService:Create(SeerPuzzle.ThirdCircle, TweenInfo.new(1), {Transparency = 0}):Play()
				for i,v in pairs(SeerPuzzle.ThirdCircle:GetChildren()) do
					if v:IsA("MeshPart") then
						TweenService:Create(v, TweenInfo.new(1), {Transparency = 0}):Play()
					end
				end
				TweenService:Create(SeerPuzzle.SeerDoorOuter, TweenInfo.new(1), {Transparency = 0}):Play()
				TweenService:Create(SeerPuzzle.Cylinder, TweenInfo.new(1), {Transparency = 0}):Play()
				game.Workspace.NPCs.SeerPuzzle1.Enabled.Value = true
				game.Workspace.NPCs.SeerPuzzle2.Enabled.Value = true
				game.Workspace.NPCs.SeerPuzzle3.Enabled.Value = true
				game.Workspace.NPCs.MistyGate.Enabled.Value = false
				TweenService:Create(SeerPuzzle.FirstCircle, TweenInfo.new(1), {CFrame = FirstPosition}):Play()
				TweenService:Create(SeerPuzzle.SecondCircle, TweenInfo.new(1), {CFrame = SecondPosition}):Play()
				TweenService:Create(SeerPuzzle.ThirdCircle, TweenInfo.new(1), {CFrame = ThirdPosition}):Play()
				task.wait(1)
				AllowMovement.Value = true
			end)
			return dialogues.GateMaster.p2
		else
			AllowMovement.Value = false
			SeerPuzzle.FirstPosition.Value = 0
			SeerPuzzle.SecondPosition.Value = 0
			SeerPuzzle.ThirdPosition.Value = 0
			SeerPuzzle.SeerDoorOuter.Sound:Play()
			TweenService:Create(SeerPuzzle.FirstCircle, TweenInfo.new(1), {CFrame = FirstPosition}):Play()
			TweenService:Create(SeerPuzzle.SecondCircle, TweenInfo.new(1), {CFrame = SecondPosition}):Play()
			TweenService:Create(SeerPuzzle.ThirdCircle, TweenInfo.new(1), {CFrame = ThirdPosition}):Play()
			task.spawn(function()
				task.wait(1.5)
				AllowMovement.Value = true
			end)

			return dialogues.GateMaster.p2
		end
	end
end

function dialogues.MistyGate.v1(p,v)
	if game.workspace.NPCs.MistyGate.Enabled.Value == false then return end
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	local GlobalData = game.ServerStorage.PlayerData:FindFirstChild(p.Name.."Global")
	if not GlobalData or not p.Character then
		return
	end
	local StoryMarker = game:GetService("HttpService"):JSONDecode(data.StoryMarker.Value)
	if not StoryMarker["Ghosts"] and
		StoryMarker["SeerGhosts"] ~= "Seen" and
		data.EdictType ~= "Seer" and
		data.EdictProgression.Value ~= 1 and
		(not StoryMarker["Tier1Quest"] or StoryMarker["Tier1Quest"] ~= "SeenOracle") then
		return dialogues.MistyGate.notquest
	end
	if v.page == 1 then
		return dialogues.MistyGate.p1
	elseif v.page == 2 then
		local HumanoidRootPart = p.Character:FindFirstChild("HumanoidRootPart")
		local a = Instance.new("Folder", p.Character)
		a.Name = "TPSafe"
		HumanoidRootPart.CFrame = game.Workspace.SeerTP.CFrame
		task.delay(2, function()
			a:Destroy()
		end)
		return dialogues.MistyGate.p2
	end
end

function dialogues.Oracle.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	local GlobalData = game.ServerStorage.PlayerData:FindFirstChild(p.Name.."Global")
	if not GlobalData or not p.Character then
		return
	end
	local StoryMarker = game:GetService("HttpService"):JSONDecode(data.StoryMarker.Value)
	if v.page == 1 then
		if data.EdictType.Value == "Seer" and data.EdictProgression.Value == 1 then
			return dialogues.Oracle.seerp1
		end
		return dialogues.Oracle.p1
	elseif v.page == 2 then
		if data.EdictType.Value == "Seer" and data.EdictProgression.Value == 1 then
			return dialogues.Oracle.seerp2
		end
		return dialogues.Oracle.p2
	elseif v.page == 3 then
		if data.EdictType.Value == "Seer" and data.EdictProgression.Value == 1 then
			return dialogues.Oracle.seerp3
		end
		return dialogues.Oracle.p3
	elseif v.page == 4 then
		if data.EdictType.Value == "Seer" and data.EdictProgression.Value == 1 then
			return dialogues.Oracle.seerp4
		end
		return dialogues.Oracle.p4
	elseif v.page == 5 then
		if data.EdictType.Value == "Seer" and data.EdictProgression.Value == 1 then
			StoryMarker["Tier1Quest"] = "SeenOracle"
			StoryMarker["Tier1Ghosts"] = {}
			data.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
			local spawns = game.ServerStorage.SpawnPoints[data.SpawnPoint.Value]:GetChildren()
			local tpcf = spawns[math.random(1,#spawns)].CFrame
			local a = Instance.new("Folder", p.Character)
			a.Name = "TPSafe"
			p.Character.HumanoidRootPart.CFrame = tpcf
			task.delay(2, function()
				a:Destroy()
			end)
			return dialogues.Oracle.seerp5
		end
		StoryMarker["SeerGhosts"] = "SeenOracle"
		data.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
		local spawns = game.ServerStorage.SpawnPoints[data.SpawnPoint.Value]:GetChildren()
		local tpcf = spawns[math.random(1,#spawns)].CFrame
		local a = Instance.new("Folder", p.Character)
		a.Name = "TPSafe"
		p.Character.HumanoidRootPart.CFrame = tpcf
		commands.Learn(p.Character)
		data.Skills.Value ..= ",Think"
		task.delay(2, function()
			a:Destroy()
		end)
		return dialogues.Oracle.p5
	end
end

function dialogues.Fallen.v1(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	if data.LastName.Value == ""then
		if v.page == 1 then
			if data.IsUltra.Value == true then
				return dialogues.Fallen.p1
			else
				return dialogues.Fallen.p3
			end
		elseif v.page == 2 then
			if data.IsUltra.Value == true then
				local housegui = game.ServerStorage.HouseMaker:Clone()
				housegui.Parent = p.PlayerGui
				return dialogues.Fallen.p2
			else
				return dialogues.Fallen.p3
			end
		elseif v.page > 2 then
			local gui = p.PlayerGui:FindFirstChild("HouseMaker")
			if gui then
				gui:Destroy()
			end
			return dialogues.exit
		end
	else
		if data.HouseRank.Value == "Owner"then
			if v.page == 1 then
				return dialogues.Fallen.p5
			else
				if v.page == 2 then
					game.ServerStorage.Requests.LeaveHouse:Invoke(p)
					return dialogues.Fallen.p2
				end
			end
		else
			if v.page == 1 then
				return dialogues.Fallen.p4
			else
				if v.page == 2 then
					game.ServerStorage.Requests.LeaveHouse:Invoke(p)
					return dialogues.Fallen.p2
				end
			end
		end
	end
end
function dialogues.Merchant.v1(p,v)
	return merchant(p,v)
end
function dialogues.Fungchant.v1(p,v)
	return fungchant(p,v)
end
function dialogues.Pawnbroker.v1(p,v)
	return merchant(p,v)
end
function dialogues.shop(p,v)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
	if not data or not p.Character then
		return
	end
	local display = v.shopdisplay
	if display.Item.Value ~= "Iron Greatsword" and display.Item.Value ~= "Pronged Mythril Spear" then
		if display:FindFirstChild("RequiresClass")and display.RequiresClass.Value ~= playerdata[p.Name].Class.Value then
			if not p.Backpack:FindFirstChild("Buy"..display.Item.Value)then
				dialogues.cantbuy.speaker = display.Shopkeeper.Value
				return dialogues.cantbuy
			end
		end
	elseif display.Item.Value == "Greatsword" then
		if playerdata[p.Name].Class.Value == "Greatsword" or playerdata[p.Name].Hybrid.Value == "Greatsword" or playerdata[p.Name].Class.Value == "Abysswalker" or playerdata[p.Name].Class.Value == "Templar" or playerdata[p.Name].Class.Value == "Vanguard" then
		else
			dialogues.cantbuy.speaker = display.Shopkeeper.Value
			return dialogues.cantbuy
		end
	elseif display.Item.Value == "Iron Greatsword" then
		if playerdata[p.Name].Class.Value == "Greatsword" or playerdata[p.Name].Hybrid.Value == "Greatsword" or playerdata[p.Name].Class.Value == "Templar" or playerdata[p.Name].Hybrid.Value == "Abysswalker" or playerdata[p.Name].Class.Value == "Vanguard" then
		else
			dialogues.cantbuy.speaker = display.Shopkeeper.Value
			return dialogues.cantbuy
		end
	elseif display.Item.Value == "Pronged Mythril Spear" then
		if playerdata[p.Name].Class.Value == "Spearfisher" or playerdata[p.Name].Hybrid.Value == "Spearfisher" or playerdata[p.Name].Class.Value == "Atlas" then
		else
			dialogues.cantbuy.speaker = display.Shopkeeper.Value
			return dialogues.cantbuy
		end
	elseif display.Item.Value == "Twinfang" then
		-- TheBlade path skill string, not a Backpack Tool - can't use RequiresBpSkill for this
		if playerdata[p.Name].Skills.Value:find("TheBlade") then
		else
			dialogues.cantbuy.speaker = display.Shopkeeper.Value
			return dialogues.cantbuy
		end
	end
	if display:FindFirstChild("RequiresBpSkill") then
		if not p.Backpack:FindFirstChild(display.RequiresBpSkill.Value) then
			dialogues.cantbuy.speaker = display.Shopkeeper.Value
			return dialogues.cantbuy
		end
	end
	if display.Type.Value == "Outfit"and data.Race.Value == "Gaian"then
		dialogues.cantbuy.speaker = display.Shopkeeper.Value
		return dialogues.cantbuy
	end
	if v.page == 1 then
		local add = display.Type.Value == "Outfit"and " Armor"or ""
		local returner = {}
		returner.speaker = display.Shopkeeper.Value
		returner.msg = "If you want that _%"..display.Item.Value..add.."%_, it'll cost you _%"..tostring(display.Price.Value).." Money.%_"
		returner.choices = {"Alright."}
		returner.endchoice = "Bye"
		return returner
	else
		if v.choice == "Alright."then
			--[[if display.Type.Value == "Item"then
				if p.Character:FindFirstChild(display.Item.Value) or p.Backpack:FindFirstChild(display.Item.Value)then
					dialogues.cantbuy.speaker = display.Shopkeeper.Value
					return dialogues.cantbuy
				end
			end]]
			if commands.ChangeMoney(p,playerdata[p.Name],-display.Price.Value)then
				if display.Type.Value == "Outfit"then
					commands.ChangeArmor(p,display.Item.Value)
				elseif display.Type.Value == "PrimaryWeapon"then
					commands.ChangeWeapon(p,display.Item.Value,true)
					local data = game.ServerStorage.PlayerData:FindFirstChild(p.Name)
					if not data or not p.Character then
						return
					end
					data.Enchant.Value = ""
					data.EnchantTimer.Value = 0
					data.OGWeapon.Value = display.Item.Value
				elseif display.Type.Value == "Item"then
					commands.AddToInventory(p,display.Item.Value)
				end
				dialogues.bought.speaker = display.Shopkeeper.Value
				return dialogues.bought
			else
				local returner = {
					msg = "You poor.",
					endchoice = "Bye",
				};
				returner.speaker = display.Shopkeeper.Value
				return returner
			end
		end
	end
end
return dialogues
