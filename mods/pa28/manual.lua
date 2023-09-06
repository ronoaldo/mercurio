
--------------
-- Manual --
--------------

function pa28.manual_formspec(name)
    local basic_form = table.concat({
        "formspec_version[3]",
        "size[16,10]",
        "background[-0.7,-0.5;17.5,11.5;pa28_manual_bg.png]"
	}, "")

	basic_form = basic_form.."button[1.75,1.5;4,1;short;Shortcuts]"
	basic_form = basic_form.."button[1.75,3.5;4,1;panel;Panel]"
	basic_form = basic_form.."button[1.75,5.5;4,1;fuel;Refueling]"
	basic_form = basic_form.."button[1.75,7.5;4,1;op;Operation]"
	basic_form = basic_form.."button[10.25,1.5;4,1;paint;Painting]"
	basic_form = basic_form.."button[10.25,3.5;4,1;tips;Tips]"

    minetest.show_formspec(name, "pa28:manual_main", basic_form)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "pa28:manual_main" then
		if fields.short then
			local text = {
				"Shortcuts \n\n",
                "* Right click: enter in/get off plane \n",
                "* Left click (with biofuel): add fuel to plane \n",
                "* Right click and Sneak: enter in flight instructor mode \n",
                "      (limited vision, so use external camera) \n",
                "* E (aux1) + Shift (sneak): flaps \n",
                "* Jump: Increase power, forward on ground \n",
                "* Sneak: Decrease power, brake on ground \n",
                "* Backward: go up flying - nose up \n",
                "* Forward: go down flying - nose down \n",
                "* Left/right: Turn to left/right, work on and out ground. \n",
                "* Left and Right together: center all commands \n",
                "* Sneak and Jump together: activates the autopilot \n",
                "* Up and Down together: enable/disable mouse control \n",
                "* E and Right click: inventory (only external) \n"
			}
			local shortcut_form = table.concat({
				"formspec_version[3]",
				"size[16,10]",
				"background[-0.7,-0.5;17.5,11.5;pa28_manual_bg.png]",
				"image[0.5,3.75;6,6;pa28_manual_up_view.png]",
				"label[9.25,0.5;", table.concat(text, ""), "]",
			}, "")
			minetest.show_formspec(player:get_player_name(), "pa28:manual_shortcut", shortcut_form)
		end
		if fields.panel then
			local text = {
				"The Panel \n\n",
				"In front of the pilot is the instrument panel. \n",
				"It's used to obtain important flight information. \n",
				"The climber is the instrument that indicates the rate \n",
                "    of climb or descent, marked with the letter C in blue. \n",
				"The speed indicator indicates the longitudinal speed of \n",
                "    the airplane. Is marked with the letter S in white. \n",
				"The power gauge indicates the power applied to the \n",
				"    engine, marked with a P. \n",
				"The fuel gauge, indicates the fuel available. \n",
				"     It's marked with the green F.\n",
				"The altimeter, with values multiplied by 100, \n",
				"    indicates the current height. \n",
                "At Panel center you see the compass, used for navigation.\n",
                "    The compass have a second function as Automatic \n",
                "    direction finding (ADF). It can be activated through \n",
                "    the plane menu, checking it and setting the \n",
                "    destination coordinates."
			}
			local panel_form = table.concat({
				"formspec_version[3]",
				"size[16,10]",
				"background[-0.7,-0.5;17.5,11.5;pa28_manual_bg.png]",
				"image[0.2,1.75;7,5;pa28_manual_panel.png]",
				"label[8.5,0.5;", table.concat(text, ""), "]",
			}, "")
			minetest.show_formspec(player:get_player_name(), "pa28:manual_panel", panel_form)
		end
		if fields.fuel then
			local text = {
				"Fuel \n\n",
				"To fly, the aircraft needs fuel for its engine. So it is \n",
				"necessary to supply it. To do this, it is necessary to \n",
				"have the selected fuel in hand and punch it to the plane. \n",
				"Depending on the fuel mod used and which container, a \n",
				"greater or lesser number of fuel units may be required to \n",
				"fill the tank. In the case of the Lokrates biofuel mod, \n",
                "with 15 bottles it is possible to fill the tank. With the \n",
                "vial, 60 units will be needed. \n",
                "Don't forget to check the fuel gauge on the panel."
			}
			local fuel_form = table.concat({
				"formspec_version[3]",
				"size[16,10]",
				"background[-0.7,-0.5;17.5,11.5;pa28_manual_bg.png]",
				"image[2,3.75;4,2;pa28_manual_fuel.png]",
				"label[9.25,0.5;", table.concat(text, ""), "]",
			}, "")
			minetest.show_formspec(player:get_player_name(), "pa28:fuel", fuel_form)
		end
		if fields.op then
			local text = {
				"Operation \n\n",
				"The aircraft can operate only on land.  \n",
				"When boarding the aircraft, centralize the commands (A  \n",
				"and D keys), press E to start the engine and hold Jump  \n",
				"until full power. When the speed reaches the green range, \n",
				"lightly pull the stick using the S key. Always keep the \n",
				"speed within the green range to avoid stalling. To land, \n",
                "remove all power, but keep the speed at the limit \n",
                "between the green and white range. \n",
                "You can use the flaps, but do not exceeed the operational \n",
                "speed for it, or it will retract. \n",
                "When you are about to touch the soil, lightly pull \n",
                "the stick to level and touch it gently. It's possible to \n",
                "operate with an external camera, activating the HUD. \n",
                "The autopilot (jump and sneak) only keeps the airplane at the \n",
                "activation level, limited by power and designed ceiling. \n",
                "It's possible for a passenger to board the aircraft, just \n",
                "click the right the plane. But it will only be \n",
                "able to enter if the pilot has already boarded."
			}
			local op_form = table.concat({
				"formspec_version[3]",
				"size[16,10]",
				"background[-0.7,-0.5;17.5,11.5;pa28_manual_bg.png]",
                "image[0.5,1.75;6,6;pa28_manual_side_view.png]",
				"label[9.25,0.25;", table.concat(text, ""), "]",
			}, "")
			minetest.show_formspec(player:get_player_name(), "pa28:op", op_form)
		end
		if fields.paint then
			local text = {
				"Painting \n\n",
				"Painting the aircraft is quite simple. It works in the same \n",
				"way as the fuel supply, but instead of using fuel to punch \n",
				"the floater, use a dye of the chosen color."
			}
			local paint_form = table.concat({
				"formspec_version[3]",
				"size[16,10]",
				"background[-0.7,-0.5;17.5,11.5;pa28_manual_colors.png]",
				"label[9.25,0.5;", table.concat(text, ""), "]",
			}, "")
			minetest.show_formspec(player:get_player_name(), "pa28:paint", paint_form)
		end
		if fields.tips then
			local text = {
				"Tips \n\n",
				"* During a stall, centralize the controls (A + D shortcut) \n",
				"    and apply maximum power, then gently pull the control. \n",
                "* The \"repair tool\" can repair damage suffered by the \n",
                "    aircraft. To use it, have some steel ingots in the \n",
                "    inventory, which will be subtracted for repair \n",
				"* When boarding as a flight instructor, use \n",
				"    the external camera with the hud on. \n",
				"* As an instructor, only pass control to the student at \n",
				"    altitudes that allow time for reaction, unless you \n",
				"    already trust that student.",
			}
			local tips_form = table.concat({
				"formspec_version[3]",
				"size[16,10]",
				"background[-0.7,-0.5;17.5,11.5;pa28_manual_bg.png]",
				"label[0.2,0.5;", table.concat(text, ""), "]",
			}, "")
			minetest.show_formspec(player:get_player_name(), "pa28:tips", tips_form)
		end
	end
end)

