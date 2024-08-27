
-- Localize things for speed

local random = math.random
local jungletree_nodes = {"default:jungletree", "mcl_core:jungletree"}
local jungletree_leaves = {
	"default:jungleleaves", "moretrees:jungletree_leaves_green", "mcl_core:jungleleaves"}

-- check area to place cocoa pods near jungle trees

local function generate(vmanip, minp, maxp)

	if maxp.y < 0 then return end

	local min, max = vmanip:get_emerged_area()
	local area = VoxelArea:new({MinEdge = min, MaxEdge = max})
	local data = vmanip:get_light_data()
	local cocoa = minetest.find_nodes_in_area(minp, maxp, jungletree_nodes)

	for n = 1, #cocoa do

		local pos = cocoa[n]

		if minetest.find_node_near(pos, 1, jungletree_leaves) then

			local dir = random(80)

			if dir == 1 then pos.x = pos.x + 1
			elseif dir == 2 then pos.x = pos.x - 1
			elseif dir == 3 then pos.z = pos.z + 1
			elseif dir == 4 then pos.z = pos.z -1
			end

			if dir < 5 and minetest.get_node(pos).name == "air" then

				local index = area:index(pos.x, pos.y, pos.z)

				if data[index] > 12 then -- light at pos > 12

					minetest.set_node(pos, {name = "farming:cocoa_" .. random(4)})
--print("Cocoa Pod added at " .. minetest.pos_to_string(pos))
				end
			end
		end
	end
end

-- mapgen

if minetest.save_gen_notify then -- async env (5.9+)
	minetest.register_on_generated(function(vmanip, minp, maxp, blockseed)
		generate(vmanip, minp, maxp)
	end)
else -- main thread (5.8 and earlier)
	minetest.register_on_generated(function(minp, maxp, blockseed)
		generate(minetest.get_mapgen_object("voxelmanip"), minp, maxp)
	end)
end
