-- SPDX-FileCopyrightText: 2021 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: CC0-1.0 OR MIT
--
morelights_dim.register_texture_for_dimming("morelights_vintage_block.png");
morelights_dim.register_texture_for_dimming(
        "morelights_vintage_lantern_foreground.png");
morelights_dim.register_texture_for_dimming("morelights_vintage_hangingbulb.png");
morelights_dim.register_texture_for_dimming("morelights_vintage_oil_flame.png");

morelights_dim.register_dim_variants("morelights_vintage:block");
morelights_dim.register_dim_variants("morelights_vintage:smallblock");
morelights_dim.register_dim_variants("morelights_vintage:lantern_f");
morelights_dim.register_dim_variants("morelights_vintage:lantern_c");
morelights_dim.register_dim_variants("morelights_vintage:lantern_w");
morelights_dim.register_dim_variants("morelights_vintage:hangingbulb");
morelights_dim.register_dim_variants("morelights_vintage:chandelier");

do
    local override, dim, off = morelights_dim.make_dim_variants(
                                       "morelights_vintage:oillamp");
    minetest.override_item("morelights_vintage:oillamp", override);
    minetest.register_node(":morelights_vintage:oillamp_morelights_dim_dimmed",
                           dim);
    -- Remove the flame in the off variant.
    off.tiles[1] =
            "[combine:2x16:0,8=[combine\\:2x16\\:0,-8=morelights_vintage_oil_flame.png^[multiply:#dddddd";
    minetest.register_node(":morelights_vintage:oillamp_morelights_dim_off", off);
end
