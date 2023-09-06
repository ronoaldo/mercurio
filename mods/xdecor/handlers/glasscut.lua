-- Tile definitions for cut nodes of glass nodes:
-- * Woodframed Glass (this mod)
-- * Glass (Minetest Game)
-- * Obsidian Glass (Minetest Game)
-- This is done so the glass nodes still look nice
-- when cut.
-- If we would only use the base glass tile, most
-- cut nodes look horrible because there are no
-- clear contours.

local template_suffixes_glass = {
	stair = {
		"_split.png",
		".png",
		"_stairside.png^[transformFX",
		"_stairside.png",
		".png",
		"_split.png",
	},
	stair_inner = {
		"_stairside.png^[transformR270",
		".png",
		"_stairside.png^[transformFX",
		".png",
		".png",
		"_stairside.png",
	},
	stair_outer = {
		"_stairside.png^[transformR90",
		".png",
		"_outer_stairside.png",
		"_stairside.png",
		"_stairside.png^[transformR90",
		"_outer_stairside.png",
	},
	halfstair = {
		"_cube.png",
		".png",
		"_stairside.png^[transformFX",
		"_stairside.png",
		"_split.png^[transformR90",
		"_cube.png",
	},
	slab = {
		".png",
		".png",
		"_split.png",
	},
	cube = { "_cube.png" },
	thinstair = { "_split.png" },
	micropanel = { "_split.png" },
	panel = {
		"_split.png",
		"_split.png",
		"_cube.png",
		"_cube.png",
		"_split.png",
	},
}

-- Template for "grass-covered" and similar nodes.
-- This is defined in a way so that the cut nodes
-- still have a natural-looking grass cover.
-- !TOP and !BOTTOM are special and will be
-- replaced via function argument.

local template_suffixes_grasscover = {	
	stair = {
		"!TOP",
		"!BOTTOM",
		"_stairside.png^[transformFX",
		"_stairside.png",
		".png",
		"_split.png",
	},
	stair_inner = {
		"!TOP",
		"!BOTTOM",
		"_stairside.png^[transformFX",
		".png",
		".png",
		"_stairside.png",
	},
	stair_outer = {
		"!TOP",
		"!BOTTOM",
		"_outer_stairside.png",
		"_stairside.png",
		"_stairside.png^[transformR90",
		"_outer_stairside.png",
	},
	halfstair = {
		"!TOP",
		"!BOTTOM",
		"_stairside.png^[transformFX",
		"_stairside.png",
		".png",
		"_cube.png",
	},
	slab = {
		"!TOP",
		"!BOTTOM",
		"_split.png",
	},
	cube = { "!TOP", "!BOTTOM", "_cube.png" },
	thinstair = { "!TOP", "!BOTTOM", "_cube.png" },
	micropanel = { "!TOP", "!BOTTOM", "!TOP" },
	nanoslab = { "!TOP", "!BOTTOM", "!TOP" },
	microslab = { "!TOP", "!BOTTOM", "!TOP" },
	panel = {
		"!TOP",
		"!BOTTOM",
		"_cube.png",
		"_cube.png",
		"_split.png",
	},
}

local generate_tilenames_glass = function(prefix, default_texture)
	if not default_texture then
		default_texture = prefix
	end
	local cuts = {}
	for t, tiles in pairs(template_suffixes_glass) do
		cuts[t] = {}
		for i=1, #tiles do
			if tiles[i] == ".png" then
				cuts[t][i] = default_texture .. tiles[i]
			else
				cuts[t][i] = prefix .. tiles[i]
			end
		end
	end
	return cuts
end

local generate_tilenames_grasscover = function(prefix, default_texture, base, top, bottom)
	if not default_texture then
		default_texture = prefix
	end
	local cuts = {}
	for t, tiles in pairs(template_suffixes_grasscover) do
		cuts[t] = {}
		for i=1, #tiles do
			if tiles[i] == "!TOP" then
				cuts[t][i] = {name=top, align_style="world"}
			elseif tiles[i] == "!BOTTOM" then
				cuts[t][i] = {name=bottom, align_style="world"}
			else
				if tiles[i] == ".png" then
					cuts[t][i] = default_texture .. tiles[i]
				else
					cuts[t][i] = prefix .. tiles[i]
				end
				if base then
					cuts[t][i] = base .. "^" .. cuts[t][i]
				end
			end
		end
	end
	return cuts
end

xdecor.glasscuts = {
	["xdecor:woodframed_glass"] = generate_tilenames_glass("xdecor_woodframed_glass"),
	["default:glass"] = generate_tilenames_glass("stairs_glass", "default_glass"),
	["default:obsidian_glass"] = generate_tilenames_glass("stairs_obsidian_glass", "default_obsidian_glass"),
	["default:permafrost_with_moss"] = generate_tilenames_grasscover("xdecor_permafrost_moss", "default_moss_side", "default_permafrost.png", "default_moss.png", "default_permafrost.png"),
	["default:permafrost_with_stones"] = generate_tilenames_grasscover("xdecor_permafrost_stones", "default_stones_side", "default_permafrost.png", "default_permafrost.png^default_stones.png", "default_permafrost.png"),
}
