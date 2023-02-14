local ui = unified_inventory

ui.style_full = {
	formspec_x = 1,
	formspec_y = 1,
	formw = 22.0,
	formh = 14.0,
	-- Item browser size, pos
	pagecols = 9,
	pagerows = 7,
	page_x = 11.0,
	page_y = 2.30,
	-- Item browser controls
	page_buttons_x = 11.0,
	page_buttons_y = 11.0,
	searchwidth = 8.4,
	-- Crafting grid positions
	craft_x = 2.8,
	craft_y = 1.6,
	craftresult_x = 7.8,
	craft_arrow_x = 6.55,
	craft_guide_x = 2.8,
	craft_guide_y = 1.6,
	craft_guide_arrow_x = 6.55,
	craft_guide_result_x = 7.8,
	craft_guide_resultstr_x = 0.3,
	craft_guide_resultstr_y = 0.6,
	give_btn_x = 0.3,
	-- Tab switching buttons
	main_button_x = 0.4,
	main_button_y = 11.25,
	main_button_cols = 8,
	main_button_rows = 2 * 1.2,
	-- Tab title position
	form_header_x = 0.3,
	form_header_y = 0.3,
	-- Generic sizes
	btn_spc = 1.2,
	btn_size = 1.1,
	std_inv_x = 0.3,
	std_inv_y = 5.75,
}

for _, style in ipairs({ui.style_full, ui.style_lite}) do
    style.items_per_page =  style.pagecols * style.pagerows
    style.standard_inv = string.format(
        "list[current_player;main;%f,%f;8,4;]",
            style.std_inv_x + ui.list_img_offset,
            style.std_inv_y + ui.list_img_offset)

    style.standard_inv_bg = ui.make_inv_img_grid(style.std_inv_x, style.std_inv_y, 8, 1, true)..
                            ui.make_inv_img_grid(style.std_inv_x, style.std_inv_y + ui.imgscale, 8, 3)

    style.craft_grid =	table.concat({
        ui.make_inv_img_grid(style.craft_x, style.craft_y, 3, 3),
        ui.single_slot(style.craft_x + ui.imgscale*4, style.craft_y), -- the craft result slot
        string.format("image[%f,%f;%f,%f;ui_crafting_arrow.png]",
        style.craft_arrow_x, style.craft_y, ui.imgscale, ui.imgscale),
        string.format("list[current_player;craft;%f,%f;3,3;]",
            style.craft_x + ui.list_img_offset, style.craft_y + ui.list_img_offset),
        string.format("list[current_player;craftpreview;%f,%f;1,1;]",
            style.craftresult_x + ui.list_img_offset, style.craft_y + ui.list_img_offset)
    })
end

ui.standard_background = "bgcolor[#0000]background[0,0;22,14;ui_formbg_custom.png]"