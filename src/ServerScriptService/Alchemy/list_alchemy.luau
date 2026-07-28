local module = {}

module.ingredients = {}

module.ingredients["Acorn Light"] = {rarity = 18, color = Color3.fromRGB(226, 155, 64), hot = true, silver = 3, tooltip = "An odd acorn-shaped light."}
module.ingredients["Blood Thorn"] = {rarity = 1, color = Color3.fromRGB(0, 32, 96), hot = false, silver = 5, tooltip = "This flower's plant thrives in areas of conflict, soaking in blood."}

module.ingredients["Canewood"] = {rarity = 65, color = Color3.fromRGB(85, 212, 64), hot = false, tooltip = "Strangely shaped root that grows deep into forests."}
module.ingredients["Crown Flower"] = {rarity = 4, color = Color3.fromRGB(0, 32, 96), hot = false, silver = 4, tooltip = "A flower valued for its vibrant royal-blue color used to produce dyes. Also, highly toxic."}
module.ingredients["Freeleaf"] = {rarity = 45, color = Color3.fromRGB(175, 221, 255), hot = false}
module.ingredients["Glow Shroom"] = {rarity = 65, color = Color3.fromRGB(0, 255, 255), hot = false, tooltip = "Bioluminescent, or radioactive?"}
module.ingredients["Creely"] = {rarity = 55, color = Color3.fromRGB(128, 187, 219), hot = false}

module.ingredients["Desert Mist"] = {rarity = 7, color = Color3.fromRGB(159, 243, 233), hot = false, silver = 10, tooltip = "A strangely heavy vapor."}
module.ingredients["Dire Flower"] = {rarity = 30, color = Color3.fromRGB(0, 16, 176), hot = false}
module.ingredients["Ice Jar"] = {rarity = 2, color = Color3.fromRGB(200, 200, 255), hot = false, silver = 3}

module.ingredients["Lava Flower"] = {rarity = 30, color = Color3.fromRGB(190, 104, 98), hot = true, tooltip = "Strangely warm to the touch."}
module.ingredients["Moss Plant"] = {rarity = 65, color = Color3.fromRGB(177, 167, 255), hot = false}
module.ingredients["Orcher Leaf"] = {rarity = 15, color = Color3.fromRGB(218, 133, 65), hot = true}

module.ingredients["Periashroom"] = {rarity = 60, color = Color3.fromRGB(91, 154, 76), hot = false}
module.ingredients["Polar Plant"] = {rarity = 15, color = Color3.fromRGB(233, 218, 218), hot = true, tooltip = "A volatile alchemic ingredient."}

module.ingredients["Potato"] = {rarity = 70, color = Color3.fromRGB(159, 137, 136), hot = false, tooltip = "I can't eat this raw."}
module.ingredients["Scroom"] = {rarity = 70, color = Color3.fromRGB(255, 89, 89), hot = true, tooltip = "A common mushroom species native to the Sea of Dust."}

module.ingredients["Sky Orchid"] = {rarity = 4, color = Color3.fromRGB(180, 128, 255), hot=false, silver = 4}
module.ingredients["Snowshroom"] = {rarity = 2, color = Color3.fromRGB(255, 255, 255), hot = false, silver = 3}
module.ingredients["Strange Tentacle"] = {rarity = 40, color = Color3.fromRGB(204, 255, 204), hot = false}
module.ingredients["Tellbloom"] = {rarity = 50, color = Color3.fromRGB(164, 189, 71), hot = false}
module.ingredients["Trote"] = {rarity = 60, color = Color3.fromRGB(177, 167, 255), hot = true, tooltip = "A binding agent for protective potions."}
module.ingredients["Uncanny Tentacle"] = {rarity = 40, color = Color3.fromRGB(124, 92, 70), hot = false}
module.ingredients["Vile Seed"] = {rarity = 20, color = Color3.fromRGB(51, 88, 130), hot = true, silver = 1, tooltip = "It's actually a bean."}
module.ingredients["Zombie Scroom"] = {rarity = 50, color = Color3.fromRGB(159, 137, 136), hot = true, tooltip = "Is this... a baby?"}
--module.ingredients["Evoflower"] = {rarity = 3, color = Color3.fromRGB(144, 199, 169), hot = false, tooltip = "A flower whose petals curiously change color throughout the seasons."}

module.recipes = {
	["Cooked Scroom"] = {recipe = {"Scroom"}},
	["Cooked Glowshroom"] = {recipe = {"Glow Shroom"}},
	["Cooked Periashroom"] = {recipe = {"Periashroom"}},
	["Cooked Zombie Scroom"] = {recipe = {"Zombie Scroom"}},
	
	["Bone Grow"] = {recipe = {"Uncanny Tentacle","Strange Tentacle","Trote"}},
	["Creatine"] = {recipe = {"Potato","Potato","Trote"}},
	["Feather Feet"] = {recipe = {"Dire Flower","Creely","Polar Plant"}},
	["Fire Protection"] = {recipe = {"Scroom","Scroom","Trote"}},
	["Health Potion"] = {recipe = {"Scroom","Scroom","Lava Flower"}},
	["Ice Protection"] = {recipe = {"Snowshroom","Snowshroom","Trote"}},
	["Kingsbane"] = {recipe = {"Crown Flower","Vile Seed","Vile Seed"}},
	["Liquid Wisdom"] = {recipe = {"Freeleaf","Desert Mist","Crown Flower","Periashroom"}},
	["Lordsbane"] = {recipe = {"Crown Flower","Crown Flower","Crown Flower"}},
	["Preworkout"] = {recipe = {"Vile Seed","Vile Seed","Scroom"}},
	["Silver Sun"] = {recipe = {"Freeleaf","Polar Plant","Desert Mist"}},
	["Switch Witch"] = {recipe = {"Dire Flower","Glow Shroom","Glow Shroom"}},
	["Tespian Elixir"] = {recipe = {"Moss Plant","Moss Plant","Lava Flower","Scroom"}},
	
}

return module
