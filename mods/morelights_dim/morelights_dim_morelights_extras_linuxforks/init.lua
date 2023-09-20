-- SPDX-FileCopyrightText: 2021-2023 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: CC0-1.0 OR MIT

-- This mod is only meaningful for LinuxForks, and serves as example otherwise.
if not minetest.registered_nodes["morelights_extras:desert_stone_block"] then
    return;
end

morelights_dim.register_texture_for_dimming("morelights_extras_blocklight.png");

morelights_dim.register_dim_variants("morelights_extras:desert_stone_block");
morelights_dim.register_dim_variants("morelights_extras:silver_sandstone_block");
morelights_dim.register_dim_variants("morelights_extras:desert_sandstone_block");
morelights_dim.register_dim_variants("morelights_extras:obsidian_block");

morelights_dim.register_dim_variants("morelights_extras:dirt_with_dry_grass");
morelights_dim.register_dim_variants("morelights_extras:grove_dirt");
morelights_dim.register_dim_variants("morelights_extras:gray_dirt");
