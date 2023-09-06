local S = minetest.get_translator("nativevillages")

minetest.register_node("nativevillages:lootchest", {
	description = S("Loot Chest"),
tiles = {
		"default_chest_top.png",
		"default_chest_top.png",
		"default_chest_side.png",
		"default_chest_side.png",
		"default_chest_side.png",
		"default_chest_front.png"
	},
groups = {wood = 1, choppy = 2, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
	drop = {
		max_items = 35,
		items = {
			{items = {"default:iron_lump"}, rarity = 5},
			{items = {"default:apple"}, rarity = 5},
			{items = {"farming:bread"}, rarity = 6},
			{items = {"default:book"}, rarity = 8},
			{items = {"default:coal_lump"}, rarity = 6},
			{items = {"farming:cotton"}, rarity = 6},
			{items = {"bucket:bucket_empty"}, rarity = 10},
			{items = {"default:paper"}, rarity = 8},
			{items = {"farming:string"}, rarity = 8},
			{items = {"farming:seed_wheat"}, rarity = 10},
			{items = {"default:obsidian_shard"}, rarity = 20},
			{items = {"default:stick"}, rarity = 6},
			{items = {"default:torch"}, rarity = 8},
			{items = {"farming:seed_cotton"}, rarity = 9},
			{items = {"people:dogfood"}, rarity = 12},
			{items = {"people:firsaidkit"}, rarity = 12},
			{items = {"farming:beans"}, rarity = 7},
			{items = {"farming:corn_cob"}, rarity = 7},
			{items = {"farming:potato"}, rarity = 7},
			{items = {"farming:soy_pod"}, rarity = 10},
			{items = {"farming:tomato"}, rarity = 10},
			{items = {"farming:sugar"}, rarity = 7},
			{items = {"farming:salt"}, rarity = 7},
			{items = {"farming:turkish_delight"}, rarity = 15},
			{items = {"farming:donut"}, rarity = 15},
			{items = {"farming:porridge"}, rarity = 15},
			{items = {"farming:apple_pie"}, rarity = 15},
			{items = {"farming:pasta"}, rarity = 15},
			{items = {"farming:bibimbap"}, rarity = 15},
			{items = {"farming:burger"}, rarity = 15},
			{items = {"farming:potato_omelet"}, rarity = 15},
			{items = {"farming:paella"}, rarity = 15},
			{items = {"default:flint"}, rarity = 15},
			{items = {"farming:rice"}, rarity = 15},
			{items = {"default:chest"}}
		}
	}
})
