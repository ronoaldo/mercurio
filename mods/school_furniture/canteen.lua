minetest.register_node("school_furniture:table_canteen", {    
    description = ("table_canteen"),
	drawtype = 'mesh',
	mesh = 'table_canteen.obj',
    tiles = {"table_teacher.png"},
	groups = {cracky=3,oddly_breakable_by_hand=3,torch=1,not_in_creative_inventory=0},
    selection_box = {type = 'fixed',fixed = {{-2.0, -0.5, -1, 2.0, 0.5, 1}, }},
	collision_box = {type = 'fixed',fixed = {{-2.0, -0.5, -1, 2.0, 0.5, 1}, }},

	paramtype = 'light',paramtype2 = 'facedir',
})

minetest.register_craft({output="school_furniture:table_canteen 1",
                         recipe= {{"group:wood","group:wood","group:wood"},
                                  {"group:wood","","group:wood"},
                                  {"default:steel_ingot","","default:steel_ingot"},}})
 
