if minetest.get_modpath("hunger_ng") ~= nil then
hunger_ng.add_hunger_data('nativevillages:bucket_milk', {
		satiates = 1.0,
	})
	hunger_ng.add_hunger_data('nativevillages:cheese', {
		satiates = 1.0,
	})
	hunger_ng.add_hunger_data('nativevillages:catfish_raw', {
		satiates = 1.0,
	})
	hunger_ng.add_hunger_data('nativevillages:catfish_cooked', {
		satiates = 2.0,
	})
	hunger_ng.add_hunger_data('nativevillages:chicken_raw', {
		satiates = 1.0,
	})
	hunger_ng.add_hunger_data('nativevillages:chicken_cooked', {
		satiates = 2.0,
	})
	hunger_ng.add_hunger_data('nativevillages:chicken_egg_fried', {
		satiates = 1.0,
	})
	hunger_ng.add_hunger_data('nativevillages:butter', {
		satiates = 1.0,
	})
	hunger_ng.add_hunger_data('nativevillages:driedhumanmeat', {
		satiates = 2.0,
	})
end