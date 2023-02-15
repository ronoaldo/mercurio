-- SPDX-FileCopyrightText: 2021 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: CC0-1.0 OR MIT
--
for _, name in ipairs({
    "morelights_modern:barlight_c", "morelights_modern:streetpost_d",
    "morelights_modern:streetpost_l",
}) do
    local node = minetest.registered_nodes[name];
    if node then
        local connects_to = table.copy(node.connects_to);
        table.insert(connects_to,
                     "morelights_modern:barlight_c_morelights_dim_dimmed");
        table.insert(connects_to,
                     "morelights_modern:barlight_c_morelights_dim_off");
        table.insert(connects_to,
                     "morelights_modern:barlight_s_morelights_dim_dimmed");
        table.insert(connects_to,
                     "morelights_modern:barlight_s_morelights_dim_off");
        minetest.override_item(name, {
            connects_to = connects_to,
        });
    end
end

morelights_dim.register_texture_for_dimming("morelights_modern_block.png");
morelights_dim.register_texture_for_dimming("morelights_modern_smallblock.png");
morelights_dim.register_texture_for_dimming("morelights_modern_post.png");
morelights_dim.register_texture_for_dimming("morelights_modern_barlight.png");
morelights_dim.register_texture_for_dimming("morelights_modern_canlight.png");
morelights_dim.register_texture_for_dimming("morelights_modern_walllamp.png");
morelights_dim.register_texture_for_dimming("morelights_modern_tablelamp_o.png",
                                            "#aaaaaa", "#222222");
morelights_dim.register_texture_for_dimming("morelights_modern_tablelamp_d.png");
morelights_dim.register_texture_for_dimming("morelights_modern_tablelamp_l.png");
morelights_dim.register_texture_for_dimming("morelights_modern_pathlight.png");

morelights_dim.register_dim_variants("morelights_modern:block");
morelights_dim.register_dim_variants("morelights_modern:smallblock");
morelights_dim.register_dim_variants("morelights_modern:post_d");
morelights_dim.register_dim_variants("morelights_modern:post_l");
morelights_dim.register_dim_variants("morelights_modern:barlight_c");
morelights_dim.register_dim_variants("morelights_modern:barlight_s");
morelights_dim.register_dim_variants("morelights_modern:ceilinglight");
morelights_dim.register_dim_variants("morelights_modern:canlight_d");
morelights_dim.register_dim_variants("morelights_modern:canlight_l");
morelights_dim.register_dim_variants("morelights_modern:walllamp");
morelights_dim.register_dim_variants("morelights_modern:tablelamp_d");
morelights_dim.register_dim_variants("morelights_modern:tablelamp_l");
morelights_dim.register_dim_variants("morelights_modern:pathlight_d");
morelights_dim.register_dim_variants("morelights_modern:pathlight_l");
