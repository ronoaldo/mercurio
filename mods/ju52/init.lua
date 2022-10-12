ju52={}
ju52.gravity = tonumber(minetest.settings:get("movement_gravity")) or 9.8
ju52.wing_angle_of_attack = 1
ju52.min_speed = 4
ju52.max_speed = 9
ju52.max_engine_acc = 8
ju52.lift = 8 --12
ju52.trunk_slots = 50

ju52.colors ={
    black='#2b2b2b',
    blue='#0063b0',
    brown='#8c5922',
    cyan='#07B6BC',
    dark_green='#567a42',
    dark_grey='#6d6d6d',
    green='#4ee34c',
    grey='#9f9f9f',
    magenta='#ff0098',
    orange='#ff8b0e',
    pink='#ff62c6',
    red='#dc1818',
    violet='#a437ff',
    white='#FFFFFF',
    yellow='#ffe400',
}

ju52.skin_texture = "ju52_painting.png"
ju52.textures = {
    "ju52_metal.png", --bequilha
    "ju52_brown.png", --assentos pilotos
    "ju52_brown.png", --assentos passageiros
    "ju52_brown.png", --assentos passageiros
    "ju52_brown.png", --assentos passageiros
    "ju52_brown.png", --assentos passageiros
    "ju52_brown.png", --assentos passageiros
    ju52.skin_texture, --proteção motor
    "ju52_metal.png", "ju52_black.png", --escapamento
    ju52.skin_texture, --superficies controle
    "ju52_compass.png", --bussola
    "ju52_white.png", --ponteiros
    "ju52_metal.png", "ju52_black.png", --manetes potencia
    "ju52_glass.png", --vidro porta
    "ju52_bege.png", --interno porta
    "ju52_compass_plan.png", --indicador ADF
    "ju52_engine.png", "ju52_black.png", --motor
    "ju52_engine.png", "ju52_black.png", --motores
    ju52.skin_texture, --fuselagem
    "ju52_black.png", -- aros mostradores
    "ju52_climber.png", --climbers
    "ju52_speed.png", --indicadores de velocidade
    "ju52_altimeter.png", --altimetros
    "ju52_fuel.png", --combustivel
    "ju52_compass_ind.png", --indicador da bussola
    "ju52_glass.png", -- vidros laterais
    ju52.skin_texture, -- estabilizador horizontal
    "ju52_bege.png", -- interior
    "ju52_metal.png", "ju52_black.png", --assoalho
    "ju52_metal.png", -- interno cabine - pes
    "ju52_bege.png", -- interior cauda
    ju52.skin_texture, --trem de pouso
    "ju52_panel_color.png", "ju52_black.png", --painel
    "ju52_panel_color.png", "ju52_black.png", --console de manetes
    "ju52_black.png", "ju52_metal.png", --pneu da bequilha
    ju52.skin_texture, --estabilizador vertical
    "ju52_black.png", "ju52_metal.png", --pneus do trem principal
    "ju52_glass.png", "ju52_metal.png", -- vidros parabrisa
    ju52.skin_texture, --asas
    --"ju52_red.png", --
    --"ju52_white.png", --asas
}


dofile(minetest.get_modpath("ju52") .. DIR_DELIM .. "ju52_global_definitions.lua")
dofile(minetest.get_modpath("ju52") .. DIR_DELIM .. "ju52_crafts.lua")
dofile(minetest.get_modpath("ju52") .. DIR_DELIM .. "ju52_control.lua")
dofile(minetest.get_modpath("ju52") .. DIR_DELIM .. "ju52_fuel_management.lua")
dofile(minetest.get_modpath("ju52") .. DIR_DELIM .. "ju52_custom_physics.lua")
dofile(minetest.get_modpath("ju52") .. DIR_DELIM .. "ju52_utilities.lua")
dofile(minetest.get_modpath("ju52") .. DIR_DELIM .. "ju52_entities.lua")
dofile(minetest.get_modpath("ju52") .. DIR_DELIM .. "ju52_forms.lua")

--
-- helpers and co.
--

--
-- items
--

-- add chatcommand to eject from demoiselle

minetest.register_chatcommand("ju52_eject", {
	params = "",
	description = "Ejects from ju52",
	privs = {interact = true},
	func = function(name, param)
        local colorstring = core.colorize('#ff0000', " >>> you are not inside your ju52")
        local player = minetest.get_player_by_name(name)
        local attached_to = player:get_attach()

		if attached_to ~= nil then
            local parent = attached_to:get_attach()
            if parent ~= nil then
                local entity = parent:get_luaentity()
                if entity.driver_name == name and entity.name == "ju52:ju52" then
                    ju52.dettachPlayer(entity, player)
                else
			        minetest.chat_send_player(name,colorstring)
                end
            end
		else
			minetest.chat_send_player(name,colorstring)
		end
	end
})


