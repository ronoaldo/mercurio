--[[
    X Bows. Adds bow and arrows with API.
    Copyright (C) 2023 SaKeL <juraj.vajda@gmail.com>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to juraj.vajda@gmail.com
--]]

local S = minetest.get_translator(minetest.get_current_modname())

sfinv = sfinv --[[@as Sfinv]]

---Check if table contains value
---@param table table
---@param value string|number
---@return boolean
local function table_contains(table, value)
    for _, v in ipairs(table) do
        if v == value then
            return true
        end
    end

    return false
end

---Merge two tables with key/value pair
---@param t1 table
---@param t2 table
---@return table
local function mergeTables(t1, t2)
    for k, v in pairs(t2) do t1[k] = v end
    return t1
end

---@type XBows
XBows = {
    pvp = minetest.settings:get_bool('enable_pvp') or false,
    creative = minetest.settings:get_bool('creative_mode') or false,
    mesecons = minetest.get_modpath('mesecons'),
    playerphysics = minetest.get_modpath('playerphysics'),
    player_monoids = minetest.get_modpath('player_monoids'),
    i3 = minetest.get_modpath('i3'),
    unified_inventory = minetest.get_modpath('unified_inventory'),
    u_skins = minetest.get_modpath('u_skins'),
    wardrobe = minetest.get_modpath('wardrobe'),
    _3d_armor = minetest.get_modpath('3d_armor'),
    skinsdb = minetest.get_modpath('skinsdb'),
    player_api = minetest.get_modpath('player_api'),
    registered_bows = {},
    registered_arrows = {},
    registered_quivers = {},
    registered_particle_spawners = {},
    registered_entities = {},
    player_bow_sneak = {},
    settings = {
        x_bows_attach_arrows_to_entities = minetest.settings:get_bool('x_bows_attach_arrows_to_entities', false),
        x_bows_show_damage_numbers = minetest.settings:get_bool('x_bows_show_damage_numbers', false),
        x_bows_show_3d_quiver = minetest.settings:get_bool('x_bows_show_3d_quiver', true)
    },
    charge_sound_after_job = {},
    fallback_quiver = not minetest.global_exists('sfinv')
        and not minetest.global_exists('unified_inventory')
        and not minetest.global_exists('i3')
}

XBows.__index = XBows

---@type XBowsQuiver
XBowsQuiver = {
    hud_item_ids = {},
    after_job = {},
    quiver_empty_state = {}
}
XBowsQuiver.__index = XBowsQuiver
setmetatable(XBowsQuiver, XBows)


---@type XBowsEntityDef
local XBowsEntityDef = {}
XBowsEntityDef.__index = XBowsEntityDef
setmetatable(XBowsEntityDef, XBows)

---create UUID
---@return string
function XBows.uuid()
    local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'

    ---@diagnostic disable-next-line: redundant-return-value
    return string.gsub(template, '[xy]', function(c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
end

---Check if creative is enabled or if player has creative priv
---@param self XBows
---@param name string
---@return boolean
function XBows.is_creative(self, name)
    return self.creative or minetest.check_player_privs(name, { creative = true })
end

---Updates `allowed_ammunition` definition on already registered item, so MODs can add new ammunitions to this list.
---@param self XBows
---@param name string
---@param allowed_ammunition string[]
---@return nil
function XBows.update_bow_allowed_ammunition(self, name, allowed_ammunition)
    local _name = 'x_bows:' .. name
    local def = self.registered_bows[_name]

    if not def then
        return
    end

    local def_copy = table.copy(def)

    minetest.unregister_item(_name)

    for _, v in ipairs(allowed_ammunition) do
        table.insert(def_copy.custom.allowed_ammunition, v)
    end

    self:register_bow(name, def_copy, true)
end

---Reset charged bow to uncharged bow, this will return the arrow item to the inventory also
---@param self XBows
---@param player ObjectRef Player Ref
---@param includeWielded? boolean Will include reset for wielded bow also. default: `false`
---@return nil
function XBows.reset_charged_bow(self, player, includeWielded)
    local _includeWielded = includeWielded or false
    local inv = player:get_inventory()

    if not inv then
        return
    end

    local inv_list = inv:get_list('main')

    for i, st in ipairs(inv_list) do
        local st_name = st:get_name()
        local x_bows_registered_bow_def = self.registered_bows[st_name]
        local reset = _includeWielded or player:get_wield_index() ~= i

        if not st:is_empty()
            and x_bows_registered_bow_def
            and reset
            and minetest.get_item_group(st_name, 'bow_charged') ~= 0
        then
            local item_meta = st:get_meta()
            local arrow_itemstack = ItemStack(minetest.deserialize(item_meta:get_string('arrow_itemstack_string')))

            --return arrow
            if arrow_itemstack and not self:is_creative(player:get_player_name()) then
                if inv:room_for_item('main', { name = arrow_itemstack:get_name() }) then
                    inv:add_item('main', arrow_itemstack:get_name())
                else
                    minetest.item_drop(
                        ItemStack({ name = arrow_itemstack:get_name(), count = 1 }),
                        player,
                        player:get_pos()
                    )
                end
            end

            --reset bow to uncharged bow
            inv:set_stack('main', i, ItemStack({
                name = x_bows_registered_bow_def.custom.name,
                count = st:get_count(),
                wear = st:get_wear()
            }))
        end
    end
end

---Register bows
---@param self XBows
---@param name string
---@param def ItemDef | BowItemDefCustom
---@param override? boolean MOD everride
---@return boolean|nil
function XBows.register_bow(self, name, def, override)
    if name == nil or name == '' then
        return false
    end

    local mod_name = def.custom.mod_name or 'x_bows'
    def.custom.name = mod_name .. ':' .. name
    def.custom.name_charged = mod_name .. ':' .. name .. '_charged'
    def.short_description = def.short_description
    def.description = override and def.short_description or (def.description or name)
    def.custom.uses = def.custom.uses or 150
    def.groups = mergeTables({ bow = 1, flammable = 1, enchantability = 1 }, def.groups or {})
    def.custom.groups_charged = mergeTables(
        { bow_charged = 1, flammable = 1, not_in_creative_inventory = 1 },
        def.groups or {}
    )
    def.custom.strength = def.custom.strength or 30
    def.custom.allowed_ammunition = def.custom.allowed_ammunition or nil
    def.custom.sound_load = def.custom.sound_load or 'x_bows_bow_load'
    def.custom.sound_hit = def.custom.sound_hit or 'x_bows_arrow_hit'
    def.custom.sound_shoot = def.custom.sound_shoot or 'x_bows_bow_shoot'
    def.custom.sound_shoot_crit = def.custom.sound_shoot_crit or 'x_bows_bow_shoot_crit'
    def.custom.gravity = def.custom.gravity or -10

    if def.custom.crit_chance then
        def.description = def.description .. '\n' .. minetest.colorize('#00FF00', S('Critical Arrow Chance') .. ': '
            .. (1 / def.custom.crit_chance) * 100 .. '%')
    end

    def.description = def.description .. '\n' .. minetest.colorize('#00BFFF', S('Strength') .. ': '
        .. def.custom.strength)

    if def.custom.allowed_ammunition then
        local allowed_amm_desc = table.concat(def.custom.allowed_ammunition, '\n')

        if allowed_amm_desc ~= '' then
            def.description = def.description .. '\n' .. S('Allowed ammunition') .. ':\n' .. allowed_amm_desc
        else
            def.description = def.description .. '\n' .. S('Allowed ammunition') .. ': ' .. S('none')
        end
    end

    self.registered_bows[def.custom.name] = def
    self.registered_bows[def.custom.name_charged] = def

    ---not charged bow
    minetest.register_tool(override and ':' .. def.custom.name or def.custom.name, {
        description = def.description,
        inventory_image = def.inventory_image or 'x_bows_bow_wood.png',
        wield_image = def.wield_image or def.inventory_image,
        groups = def.groups,
        wield_scale = { x = 2, y = 2, z = 1.5 },
        ---@param itemstack ItemStack
        ---@param placer ObjectRef|nil
        ---@param pointed_thing PointedThingDef
        ---@return ItemStack|nil
        on_place = function(itemstack, placer, pointed_thing)
            if placer then
                return self:load(itemstack, placer, pointed_thing)
            end
        end,
        ---@param itemstack ItemStack
        ---@param user ObjectRef|nil
        ---@param pointed_thing PointedThingDef
        ---@return ItemStack|nil
        on_secondary_use = function(itemstack, user, pointed_thing)
            if user then
                return self:load(itemstack, user, pointed_thing)
            end
        end
    })

    ---charged bow
    minetest.register_tool(override and ':' .. def.custom.name_charged or def.custom.name_charged, {
        description = def.description,
        inventory_image = def.custom.inventory_image_charged or 'x_bows_bow_wood_charged.png',
        wield_image = def.custom.wield_image_charged or def.custom.inventory_image_charged,
        groups = def.custom.groups_charged,
        wield_scale = { x = 2, y = 2, z = 1.5 },
        range = 0,
        ---@param itemstack ItemStack
        ---@param user ObjectRef|nil
        ---@param pointed_thing PointedThingDef
        ---@return ItemStack|nil
        on_use = function(itemstack, user, pointed_thing)
            if user then
                return self:shoot(itemstack, user, pointed_thing)
            end
        end,
        ---@param itemstack ItemStack
        ---@param dropper ObjectRef|nil
        ---@param pos Vector
        ---@return ItemStack|nil
        on_drop = function(itemstack, dropper, pos)
            if dropper then
                local item_meta = itemstack:get_meta()
                local arrow_itemstack = ItemStack(minetest.deserialize(item_meta:get_string('arrow_itemstack_string')))

                ---return arrow
                if arrow_itemstack and not self:is_creative(dropper:get_player_name()) then
                    minetest.item_drop(
                        ItemStack({ name = arrow_itemstack:get_name(), count = 1 }),
                        dropper,
                        { x = pos.x + 0.5, y = pos.y + 0.5, z = pos.z + 0.5 }
                    )
                end

                itemstack:set_name(def.custom.name)
                ---returns leftover itemstack
                return minetest.item_drop(itemstack, dropper, pos)
            end
        end
    })

    ---recipes
    if def.custom.recipe then
        minetest.register_craft({
            output = def.custom.name,
            recipe = def.custom.recipe
        })
    end

    ---fuel recipe
    if def.custom.fuel_burntime then
        minetest.register_craft({
            type = 'fuel',
            recipe = def.custom.name,
            burntime = def.custom.fuel_burntime,
        })
    end
end

---Register arrows
---@param self XBows
---@param name string
---@param def ItemDef | ArrowItemDefCustom
---@return boolean|nil
function XBows.register_arrow(self, name, def)
    if name == nil or name == '' then
        return false
    end

    local mod_name = def.custom.mod_name or 'x_bows'
    def.custom.name = mod_name .. ':' .. name
    def.description = def.description or name
    def.short_description = def.short_description or name
    def.custom.tool_capabilities = def.custom.tool_capabilities or {
        full_punch_interval = 1,
        max_drop_level = 0,
        damage_groups = { fleshy = 2 }
    }
    def.custom.description_abilities = minetest.colorize('#00FF00', S('Damage') .. ': '
        .. def.custom.tool_capabilities.damage_groups.fleshy) .. '\n' .. minetest.colorize('#00BFFF', S('Charge Time') .. ': '
        .. def.custom.tool_capabilities.full_punch_interval .. 's')
    def.groups = mergeTables({ arrow = 1, flammable = 1 }, def.groups or {})
    def.custom.particle_effect = def.custom.particle_effect or 'arrow'
    def.custom.particle_effect_crit = def.custom.particle_effect_crit or 'arrow_crit'
    def.custom.particle_effect_fast = def.custom.particle_effect_fast or 'arrow_fast'
    def.custom.projectile_entity = def.custom.projectile_entity or 'x_bows:arrow_entity'
    def.custom.on_hit_node = def.custom.on_hit_node or nil
    def.custom.on_hit_entity = def.custom.on_hit_entity or nil
    def.custom.on_hit_player = def.custom.on_hit_player or nil
    def.custom.on_after_activate = def.custom.on_after_activate or nil

    self.registered_arrows[def.custom.name] = def

    minetest.register_craftitem(def.custom.name, {
        description = def.description .. '\n' .. def.custom.description_abilities,
        short_description = def.short_description,
        inventory_image = def.inventory_image,
        groups = def.groups
    })

    ---recipes
    if def.custom.recipe then
        minetest.register_craft({
            output = def.custom.name .. ' ' .. (def.custom.craft_count or 4),
            recipe = def.custom.recipe
        })
    end

    ---fuel recipe
    if def.custom.fuel_burntime then
        minetest.register_craft({
            type = 'fuel',
            recipe = def.custom.name,
            burntime = def.custom.fuel_burntime,
        })
    end
end

---Register quivers
---@param self XBows
---@param name string
---@param def ItemDef | QuiverItemDefCustom
---@return boolean|nil
function XBows.register_quiver(self, name, def)
    if name == nil or name == '' then
        return false
    end

    def.custom.name = 'x_bows:' .. name
    def.custom.name_open = 'x_bows:' .. name .. '_open'
    def.description = def.description or name
    def.short_description = def.short_description or name
    def.groups = mergeTables({ quiver = 1, flammable = 1 }, def.groups or {})
    def.custom.groups_charged = mergeTables({
            quiver = 1, quiver_open = 1, flammable = 1, not_in_creative_inventory = 1
        },
        def.groups or {}
    )

    if def.custom.faster_arrows then
        def.description = def.description .. '\n' .. minetest.colorize('#00FF00', S('Faster Arrows') ..
            ': ' .. (1 / def.custom.faster_arrows) * 100 .. '%')
        def.short_description = def.short_description .. '\n' .. minetest.colorize('#00FF00', S('Faster Arrows') ..
            ': ' .. (1 / def.custom.faster_arrows) * 100 .. '%')
    end

    if def.custom.add_damage then
        def.description = def.description .. '\n' .. minetest.colorize('#FF8080', S('Arrow Damage') ..
            ': +' .. def.custom.add_damage)
        def.short_description = def.short_description .. '\n' .. minetest.colorize('#FF8080', S('Arrow Damage') ..
            ': +' .. def.custom.add_damage)
    end

    self.registered_quivers[def.custom.name] = def
    self.registered_quivers[def.custom.name_open] = def

    ---closed quiver
    minetest.register_tool(def.custom.name, {
        description = def.description,
        short_description = def.short_description,
        inventory_image = def.inventory_image or 'x_bows_quiver.png',
        wield_image = def.wield_image or 'x_bows_quiver.png',
        groups = def.groups,
        wield_scale = { x = 2, y = 2, z = 1 },
        ---@param itemstack ItemStack
        ---@param user ObjectRef|nil
        ---@param pointed_thing PointedThingDef
        ---@return ItemStack|nil
        on_secondary_use = function(itemstack, user, pointed_thing)
            if user then
                return self:open_quiver(itemstack, user)
            end
        end,
        ---@param itemstack ItemStack
        ---@param placer ObjectRef
        ---@param pointed_thing PointedThingDef
        ---@return ItemStack|nil
        on_place = function(itemstack, placer, pointed_thing)
            if pointed_thing.under then
                local node = minetest.get_node(pointed_thing.under)
                local node_def = minetest.registered_nodes[node.name]

                if node_def and node_def.on_rightclick then
                    return node_def.on_rightclick(pointed_thing.under, node, placer, itemstack, pointed_thing)
                end
            end

            return self:open_quiver(itemstack, placer)
        end
    })

    ---open quiver
    minetest.register_tool(def.custom.name_open, {
        description = def.description,
        short_description = def.short_description,
        inventory_image = def.custom.inventory_image_open or 'x_bows_quiver_open.png',
        wield_image = def.custom.wield_image_open or 'x_bows_quiver_open.png',
        groups = def.custom.groups_charged,
        wield_scale = { x = 2, y = 2, z = 1 },
        ---@param itemstack ItemStack
        ---@param dropper ObjectRef|nil
        ---@param pos Vector
        ---@return ItemStack
        on_drop = function(itemstack, dropper, pos)
            if not dropper then
                return itemstack
            end

            local replace_item = XBowsQuiver:get_replacement_item(itemstack, 'x_bows:quiver')
            return minetest.item_drop(replace_item, dropper, pos)
        end
    })

    ---recipes
    if def.custom.recipe then
        minetest.register_craft({
            output = def.custom.name,
            recipe = def.custom.recipe
        })
    end

    ---fuel recipe
    if def.custom.fuel_burntime then
        minetest.register_craft({
            type = 'fuel',
            recipe = def.custom.name,
            burntime = def.custom.fuel_burntime,
        })
    end
end

---Load bow
---@param self XBows
---@param itemstack ItemStack
---@param user ObjectRef
---@param pointed_thing PointedThingDef
---@return ItemStack
function XBows.load(self, itemstack, user, pointed_thing)
    local player_name = user:get_player_name()
    local inv = user:get_inventory() --[[@as InvRef]]
    local bow_name = itemstack:get_name()
    local bow_def = self.registered_bows[bow_name]
    ---@alias ItemStackArrows {["stack"]: ItemStack, ["idx"]: number|integer}[]
    ---@type ItemStackArrows
    local itemstack_arrows = {}

    ---trigger right click event if pointed item has one
    if pointed_thing.under then
        local node = minetest.get_node(pointed_thing.under)
        local node_def = minetest.registered_nodes[node.name]

        if node_def and node_def.on_rightclick then
            return node_def.on_rightclick(pointed_thing.under, node, user, itemstack, pointed_thing)
        end
    end

    ---find itemstack arrow in quiver
    local quiver_result = XBowsQuiver:get_itemstack_arrow_from_quiver(user)
    local itemstack_arrow = quiver_result.found_arrow_stack

    if itemstack_arrow then
        ---we got arrow from quiver
        local itemstack_arrow_meta = itemstack_arrow:get_meta()

        itemstack_arrow_meta:set_int('is_arrow_from_quiver', 1)
        itemstack_arrow_meta:set_int('found_arrow_stack_idx', quiver_result.found_arrow_stack_idx)
        itemstack_arrow_meta:set_string('quiver_name', quiver_result.quiver_name)
        itemstack_arrow_meta:set_string('quiver_id', quiver_result.quiver_id)
    else
        if not inv:is_empty('x_bows:arrow_inv') then
            XBowsQuiver:udate_or_create_hud(user, inv:get_list('x_bows:arrow_inv'))
        else
            ---no ammo (fake stack)
            XBowsQuiver:udate_or_create_hud(user, {
                ItemStack({ name = 'x_bows:no_ammo' })
            })
        end

        ---find itemstack arrow in players inventory
        local arrow_stack = inv:get_stack('x_bows:arrow_inv', 1)
        local is_allowed_ammunition = self:is_allowed_ammunition(bow_name, arrow_stack:get_name())

        if self.registered_arrows[arrow_stack:get_name()] and is_allowed_ammunition then
            table.insert(itemstack_arrows, { stack = arrow_stack, idx = 1 })
        end

        ---if everything else fails
        if self.fallback_quiver then
            local inv_list = inv:get_list('main')

            for i, st in ipairs(inv_list) do
                local st_name = st:get_name()

                if not st:is_empty() and self.registered_arrows[st_name] then
                    local _is_allowed_ammunition = self:is_allowed_ammunition(bow_name, st_name)

                    if self.registered_arrows[st_name] and _is_allowed_ammunition then
                        table.insert(itemstack_arrows, { stack = st, idx = i })
                    end
                end
            end
        end

        -- take 1st found arrow in the list
        itemstack_arrow = #itemstack_arrows > 0 and itemstack_arrows[1].stack or nil
    end

    if itemstack_arrow and bow_def then
        local _tool_capabilities = self.registered_arrows[itemstack_arrow:get_name()].custom.tool_capabilities

        ---@param v_user ObjectRef
        ---@param v_bow_name string
        ---@param v_itemstack_arrow ItemStack
        ---@param v_inv InvRef
        ---@param v_itemstack_arrows ItemStackArrows
        minetest.after(0, function(v_user, v_bow_name, v_itemstack_arrow, v_inv, v_itemstack_arrows)
            local wielded_item = v_user:get_wielded_item()

            if wielded_item:get_name() == v_bow_name then
                local wielded_item_meta = wielded_item:get_meta()
                local v_itemstack_arrow_meta = v_itemstack_arrow:get_meta()

                wielded_item_meta:set_string('arrow_itemstack_string', minetest.serialize(v_itemstack_arrow:to_table()))
                wielded_item_meta:set_string('time_load', tostring(minetest.get_us_time()))

                wielded_item:set_name(v_bow_name .. '_charged')
                v_user:set_wielded_item(wielded_item)

                if not self:is_creative(v_user:get_player_name())
                    and v_itemstack_arrow_meta:get_int('is_arrow_from_quiver') ~= 1
                then
                    v_itemstack_arrow:take_item()
                    v_inv:set_stack('x_bows:arrow_inv', v_itemstack_arrows[1].idx, v_itemstack_arrow)
                end
            end
        end, user, bow_name, itemstack_arrow, inv, itemstack_arrows)

        ---stop previous charged sound after job
        if self.charge_sound_after_job[player_name] then
            for _, v in pairs(self.charge_sound_after_job[player_name]) do
                v:cancel()
            end

            self.charge_sound_after_job[player_name] = {}
        else
            self.charge_sound_after_job[player_name] = {}
        end

        ---sound plays when charge time reaches full punch interval time
        table.insert(self.charge_sound_after_job[player_name], minetest.after(_tool_capabilities.full_punch_interval,
            function(v_user, v_bow_name)
                local wielded_item = v_user:get_wielded_item()
                local wielded_item_name = wielded_item:get_name()

                if wielded_item_name == v_bow_name .. '_charged' then
                    minetest.sound_play('x_bows_bow_loaded', {
                        to_player = v_user:get_player_name(),
                        gain = 0.6
                    })
                end
            end, user, bow_name))

        minetest.sound_play(bow_def.custom.sound_load, {
            to_player = player_name,
            gain = 0.6
        })

        return itemstack
    end

    return itemstack
end

---Shoot bow
---@param self XBows
---@param itemstack ItemStack
---@param user ObjectRef
---@param pointed_thing? PointedThingDef
---@return ItemStack
function XBows.shoot(self, itemstack, user, pointed_thing)
    local time_shoot = minetest.get_us_time();
    local meta = itemstack:get_meta()
    local time_load = tonumber(meta:get_string('time_load'))
    local tflp = (time_shoot - time_load) / 1000000
    ---@type ItemStack
    local arrow_itemstack = ItemStack(minetest.deserialize(meta:get_string('arrow_itemstack_string')))

    if arrow_itemstack:is_empty() then
        return itemstack
    end

    local arrow_itemstack_meta = arrow_itemstack:get_meta()
    local arrow_name = arrow_itemstack:get_name()
    local is_arrow_from_quiver = arrow_itemstack_meta:get_int('is_arrow_from_quiver')
    local quiver_name = arrow_itemstack_meta:get_string('quiver_name')
    local found_arrow_stack_idx = arrow_itemstack_meta:get_int('found_arrow_stack_idx')
    local quiver_id = arrow_itemstack_meta:get_string('quiver_id')
    local detached_inv = XBowsQuiver:get_or_create_detached_inv(
        quiver_id,
        user:get_player_name()
    )

    ---Handle HUD and 3d Quiver
    if is_arrow_from_quiver == 1 then
        XBowsQuiver:udate_or_create_hud(user, detached_inv:get_list('main'), found_arrow_stack_idx)

        if detached_inv:is_empty('main') then
            XBowsQuiver:show_3d_quiver(user, { is_empty = true })
        else
            XBowsQuiver:show_3d_quiver(user)
        end
    else
        local inv = user:get_inventory() --[[@as InvRef]]
        if not inv:is_empty('x_bows:arrow_inv') then
            XBowsQuiver:udate_or_create_hud(user, inv:get_list('x_bows:arrow_inv'))
        else
            ---no ammo (fake stack just for the HUD)
            XBowsQuiver:udate_or_create_hud(user, {
                ItemStack({ name = 'x_bows:no_ammo' })
            })
        end
    end

    local x_bows_registered_arrow_def = self.registered_arrows[arrow_name]

    if not x_bows_registered_arrow_def then
        return itemstack
    end

    local bow_name_charged = itemstack:get_name()
    ---Bow
    local x_bows_registered_bow_charged_def = self.registered_bows[bow_name_charged]
    local bow_name = x_bows_registered_bow_charged_def.custom.name
    local uses = x_bows_registered_bow_charged_def.custom.uses
    local crit_chance = x_bows_registered_bow_charged_def.custom.crit_chance
    ---Arrow
    local projectile_entity = x_bows_registered_arrow_def.custom.projectile_entity
    ---Quiver
    local x_bows_registered_quiver_def = self.registered_quivers[quiver_name]

    local _tool_capabilities = x_bows_registered_arrow_def.custom.tool_capabilities
    local quiver_xbows_def = x_bows_registered_quiver_def

    ---X Enchanting
    local x_enchanting = minetest.deserialize(meta:get_string('x_enchanting')) or {}

    ---@type EnityStaticDataAttrDef
    local staticdata = {
        _arrow_name = arrow_name,
        _bow_name = bow_name,
        _user_name = user:get_player_name(),
        _is_critical_hit = false,
        _tool_capabilities = _tool_capabilities,
        _tflp = tflp,
        _add_damage = 0,
        _x_enchanting = x_enchanting
    }

    ---crits, only on full punch interval
    if crit_chance and crit_chance > 1 and tflp >= _tool_capabilities.full_punch_interval then
        if math.random(1, crit_chance) == 1 then
            staticdata._is_critical_hit = true
        end
    end

    ---speed multiply
    if quiver_xbows_def and quiver_xbows_def.custom.faster_arrows and quiver_xbows_def.custom.faster_arrows > 1 then
        staticdata._faster_arrows_multiplier = quiver_xbows_def.custom.faster_arrows
    end

    ---add quiver damage
    if quiver_xbows_def and quiver_xbows_def.custom.add_damage and quiver_xbows_def.custom.add_damage > 0 then
        staticdata._add_damage = staticdata._add_damage + quiver_xbows_def.custom.add_damage
    end

    ---sound
    local sound_name = x_bows_registered_bow_charged_def.custom.sound_shoot
    if staticdata._is_critical_hit then
        sound_name = x_bows_registered_bow_charged_def.custom.sound_shoot_crit
    end

    -- remove arrow meta to prevent multiple shots while waiting for async `after`
    meta:set_string('arrow_itemstack_string', '')

    ---stop punching close objects/nodes when shooting
    minetest.after(0.2, function()
        local wield_item = user:get_wielded_item()

        if wield_item:get_count() > 0 and wield_item:get_name() == itemstack:get_name() then
            local new_stack = ItemStack(mergeTables(itemstack:to_table(), { name = bow_name }))
            user:set_wielded_item(new_stack)
        end
    end)

    local player_pos = user:get_pos()
    local obj = minetest.add_entity(
        {
            x = player_pos.x,
            y = player_pos.y + 1.5,
            z = player_pos.z
        },
        projectile_entity,
        minetest.serialize(staticdata)
    )

    if not obj then
        return itemstack
    end

    minetest.sound_play(sound_name, {
        gain = 0.3,
        pos = user:get_pos(),
        max_hear_distance = 10
    })

    if not self:is_creative(user:get_player_name()) then
        itemstack:add_wear(65535 / uses)
    end

    if itemstack:get_count() == 0 then
        minetest.sound_play('default_tool_breaks', {
            gain = 0.3,
            pos = user:get_pos(),
            max_hear_distance = 10
        })
    end

    return itemstack
end

---Add new particle to XBow registration
---@param self XBows
---@param name string
---@param def ParticlespawnerDef|ParticlespawnerDefCustom
---@return nil
function XBows.register_particle_effect(self, name, def)
    if self.registered_particle_spawners[name] then
        minetest.log('warning', 'Particle effect "' .. name .. '" already exists and will not be overwritten.')
        return
    end

    self.registered_particle_spawners[name] = def
end

---Get particle effect from registered spawners table
---@param self XBows
---@param name string
---@param pos Vector
---@return number|boolean
function XBows.get_particle_effect_for_arrow(self, name, pos)
    local def = self.registered_particle_spawners[name]

    if not def then
        minetest.log('warning', 'Particle effect "' .. name .. '" is not registered.')
        return false
    end

    def.custom = def.custom or {}
    def.minpos = def.custom.minpos and vector.add(pos, def.custom.minpos) or pos
    def.maxpos = def.custom.maxpos and vector.add(pos, def.custom.maxpos) or pos

    return minetest.add_particlespawner(def--[[@as ParticlespawnerDef]] )
end

---Check if ammunition is allowed to charge this weapon
---@param self XBows
---@param weapon_name string
---@param ammo_name string
---@return boolean
function XBows.is_allowed_ammunition(self, weapon_name, ammo_name)
    local x_bows_weapon_def = self.registered_bows[weapon_name]

    if not x_bows_weapon_def then
        return false
    end

    if not x_bows_weapon_def.custom.allowed_ammunition then
        return true
    end

    if #x_bows_weapon_def.custom.allowed_ammunition == 0 then
        return false
    end

    return table_contains(x_bows_weapon_def.custom.allowed_ammunition, ammo_name)
end

----
--- ENTITY API
----

---Gets total armor level from 3d armor
---@param player ObjectRef
---@return integer
local function get_3d_armor_armor(player)
    local armor_total = 0

    if not player:is_player() or not minetest.get_modpath('3d_armor') or not armor.def[player:get_player_name()] then
        return armor_total
    end

    armor_total = armor.def[player:get_player_name()].level

    return armor_total
end

---Limits number `x` between `min` and `max` values
---@param x integer
---@param min integer
---@param max integer
---@return integer
local function limit(x, min, max)
    return math.min(math.max(x, min), max)
end

---Function receive a "luaentity" table as `self`. Called when the object is instantiated.
---@param self EntityDef|EntityDefCustom|XBows
---@param selfObj EnityCustomAttrDef
---@param staticdata string
---@param dtime_s? integer|number
---@return nil
function XBowsEntityDef.on_activate(self, selfObj, staticdata, dtime_s)
    if not selfObj or not staticdata or staticdata == '' then
        selfObj.object:remove()
        return
    end

    local _staticdata = minetest.deserialize(staticdata) --[[@as EnityStaticDataAttrDef]]

    -- set/reset - do not inherit from previous entity table
    selfObj._velocity = { x = 0, y = 0, z = 0 }
    selfObj._old_pos = nil
    selfObj._attached = false
    selfObj._attached_to = {
        type = '',
        pos = nil
    }
    selfObj._has_particles = false
    selfObj._lifetimer = 60
    selfObj._nodechecktimer = 0.5
    selfObj._is_drowning = false
    selfObj._in_liquid = false
    selfObj._shot_from_pos = selfObj.object:get_pos()
    selfObj._arrow_name = _staticdata._arrow_name
    selfObj._bow_name = _staticdata._bow_name
    selfObj._user_name = _staticdata._user_name
    selfObj._user = minetest.get_player_by_name(_staticdata._user_name)
    selfObj._tflp = _staticdata._tflp
    selfObj._tool_capabilities = _staticdata._tool_capabilities
    selfObj._is_critical_hit = _staticdata._is_critical_hit
    selfObj._faster_arrows_multiplier = _staticdata._faster_arrows_multiplier
    selfObj._add_damage = _staticdata._add_damage
    selfObj._caused_damage = 0
    selfObj._caused_knockback = 0

    local x_bows_registered_arrow_def = self.registered_arrows[selfObj._arrow_name]
    selfObj._arrow_particle_effect = x_bows_registered_arrow_def.custom.particle_effect
    selfObj._arrow_particle_effect_crit = x_bows_registered_arrow_def.custom.particle_effect_crit
    selfObj._arrow_particle_effect_fast = x_bows_registered_arrow_def.custom.particle_effect_fast
    selfObj._flyby_sound_played = {
        ['player_name'] = true
    }

    ---Bow Def
    local x_bows_registered_bow_def = self.registered_bows[selfObj._bow_name]
    selfObj._sound_hit = x_bows_registered_bow_def.custom.sound_hit
    local bow_strength = x_bows_registered_bow_def.custom.strength
    local acc_x_min = x_bows_registered_bow_def.custom.acc_x_min
    local acc_y_min = x_bows_registered_bow_def.custom.acc_y_min
    local acc_z_min = x_bows_registered_bow_def.custom.acc_z_min
    local acc_x_max = x_bows_registered_bow_def.custom.acc_x_max
    local acc_y_max = x_bows_registered_bow_def.custom.acc_y_max
    local acc_z_max = x_bows_registered_bow_def.custom.acc_z_max
    local gravity = x_bows_registered_bow_def.custom.gravity
    local bow_strength_min = x_bows_registered_bow_def.custom.strength_min
    local bow_strength_max = x_bows_registered_bow_def.custom.strength_max

    ---X Enchanting
    selfObj._x_enchanting = _staticdata._x_enchanting or {}

    ---acceleration
    selfObj._player_look_dir = selfObj._user:get_look_dir()

    selfObj._acc_x = selfObj._player_look_dir.x
    selfObj._acc_y = gravity
    selfObj._acc_z = selfObj._player_look_dir.z

    if acc_x_min and acc_x_max then
        selfObj._acc_x = math.random(acc_x_min, acc_x_max)
    end

    if acc_y_min and acc_y_max then
        selfObj._acc_y = math.random(acc_y_min, acc_y_max)
    end

    if acc_z_min and acc_z_max then
        selfObj._acc_z = math.random(acc_z_min, acc_z_max)
    end

    ---strength
    local strength_multiplier = selfObj._tflp

    if strength_multiplier > selfObj._tool_capabilities.full_punch_interval then
        strength_multiplier = 1

        ---faster arrow, only on full punch interval
        if selfObj._faster_arrows_multiplier then
            strength_multiplier = strength_multiplier + (strength_multiplier / selfObj._faster_arrows_multiplier)
        end
    end

    if bow_strength_max and bow_strength_min then
        bow_strength = math.random(bow_strength_min, bow_strength_max)
    end

    selfObj._strength = bow_strength * strength_multiplier

    ---rotation factor
    local x_bows_registered_entity_def = self.registered_entities[selfObj.name]
    selfObj._rotation_factor = x_bows_registered_entity_def._custom.rotation_factor

    if type(selfObj._rotation_factor) == 'function' then
        selfObj._rotation_factor = selfObj._rotation_factor()
    end

    ---add infotext
    selfObj.object:set_properties({
        infotext = selfObj._arrow_name,
    })

    ---idle animation
    if x_bows_registered_entity_def and x_bows_registered_entity_def._custom.animations.idle then
        selfObj.object:set_animation(unpack(x_bows_registered_entity_def._custom.animations.idle)--[[@as table]])
    end

    ---counter, e.g. for initial values set `on_step`
    selfObj._step_count = 0

    ---Callbacks
    local on_after_activate_callback = x_bows_registered_arrow_def.custom.on_after_activate

    if on_after_activate_callback then
        on_after_activate_callback(selfObj)
    end
end

---Function receive a "luaentity" table as `self`. Called when the object dies.
---@param self XBows
---@param selfObj EnityCustomAttrDef
---@param killer ObjectRef|nil
---@return nil
function XBowsEntityDef.on_death(self, selfObj, killer)
    if not selfObj._old_pos then
        selfObj.object:remove()
        return
    end

    -- Infinity enchantment - arrows cannot be retrieved
    if selfObj._x_enchanting.infinity and selfObj._x_enchanting.infinity.value > 0 then
        return
    end

    minetest.item_drop(ItemStack(selfObj._arrow_name), nil, vector.round(selfObj._old_pos))
end

--- Function receive a "luaentity" table as `self`. Called on every server tick, after movement and collision processing.
---`dtime`: elapsed time since last call. `moveresult`: table with collision info (only available if physical=true).
---@param self XBows
---@param selfObj EnityCustomAttrDef
---@param dtime number
---@return nil
function XBowsEntityDef.on_step(self, selfObj, dtime)
    selfObj._step_count = selfObj._step_count + 1

    if selfObj._step_count == 1 then
        ---initialize
        ---this has to be done here for raycast to kick-in asap
        selfObj.object:set_velocity(vector.multiply(selfObj._player_look_dir, selfObj._strength))
        selfObj.object:set_acceleration({ x = selfObj._acc_x, y = selfObj._acc_y, z = selfObj._acc_z })
        selfObj.object:set_yaw(minetest.dir_to_yaw(selfObj._player_look_dir))
    end

    local pos = selfObj.object:get_pos()
    selfObj._old_pos = selfObj._old_pos or pos
    local ray = minetest.raycast(selfObj._old_pos, pos, true, true)
    local pointed_thing = ray:next()

    selfObj._lifetimer = selfObj._lifetimer - dtime
    selfObj._nodechecktimer = selfObj._nodechecktimer - dtime

    -- adjust pitch when flying
    if not selfObj._attached then
        local velocity = selfObj.object:get_velocity()
        local v_rotation = selfObj.object:get_rotation()
        local pitch = math.atan2(velocity.y, math.sqrt(velocity.x ^ 2 + velocity.z ^ 2))

        selfObj.object:set_rotation({
            x = pitch,
            y = v_rotation.y,
            z = v_rotation.z + (selfObj._rotation_factor or math.pi / 2)
        })
    end

    -- remove attached arrows after lifetime
    if selfObj._lifetimer <= 0 then
        selfObj.object:remove()
        return
    end

    -- add particles only when not attached
    if not selfObj._attached and not selfObj._in_liquid then
        selfObj._has_particles = true

        if selfObj._tflp >= selfObj._tool_capabilities.full_punch_interval then
            if selfObj._is_critical_hit then
                self:get_particle_effect_for_arrow(selfObj._arrow_particle_effect_crit, selfObj._old_pos)
            elseif selfObj._faster_arrows_multiplier then
                self:get_particle_effect_for_arrow(selfObj._arrow_particle_effect_fast, selfObj._old_pos)
            else
                self:get_particle_effect_for_arrow(selfObj._arrow_particle_effect, selfObj._old_pos)
            end
        end
    end

    -- remove attached arrows after object dies
    if not selfObj.object:get_attach() and selfObj._attached_to.type == 'object' then
        selfObj.object:remove()
        return
    end

    -- arrow falls down when not attached to node any more
    if selfObj._attached_to.type == 'node' and selfObj._attached and selfObj._nodechecktimer <= 0 then
        local node = minetest.get_node(selfObj._attached_to.pos)
        selfObj._nodechecktimer = 0.5

        if not node then
            return
        end

        if node.name == 'air' then
            selfObj.object:set_velocity({ x = 0, y = -3, z = 0 })
            selfObj.object:set_acceleration({ x = 0, y = -3, z = 0 })
            -- reset values
            selfObj._attached = false
            selfObj._attached_to.type = ''
            selfObj._attached_to.pos = nil
            selfObj.object:set_properties({ collisionbox = { 0, 0, 0, 0, 0, 0 } })

            return
        end
    end

    while pointed_thing do
        local ip_pos = pointed_thing.intersection_point
        local in_pos = pointed_thing.intersection_normal
        selfObj.pointed_thing = pointed_thing

        if not selfObj._attached then
            for _, object in ipairs(minetest.get_objects_inside_radius(selfObj.object:get_pos(), 5)) do
                if object:is_player()
                    and object:get_hp() > 0
                    and object:get_player_name() ~= selfObj._user:get_player_name()
                    and not selfObj._flyby_sound_played[object:get_player_name()]
                then
                    selfObj._flyby_sound_played[object:get_player_name()] = true

                    local p1 = selfObj.object:get_pos()
                    local p2 = object:get_pos()
                    local distance = math.round(vector.distance(p1, p2))
                    local gain = 1 / distance

                    minetest.sound_play('x_bows_arrow_flyby', {
                        to_player = object:get_player_name(),
                        gain = gain
                    }, true)
                end
            end
        end

        if pointed_thing.type == 'object'
            and pointed_thing.ref ~= selfObj.object
            and pointed_thing.ref:get_hp() > 0
            and (
                (
                    pointed_thing.ref:is_player()
                    and pointed_thing.ref:get_player_name() ~= selfObj._user:get_player_name()
                )
                or (
                    pointed_thing.ref:get_luaentity()
                    and pointed_thing.ref:get_luaentity().physical
                    and pointed_thing.ref:get_luaentity().name ~= '__builtin:item'
                )
            )
            and selfObj.object:get_attach() == nil
            and not selfObj._attached
        then
            if pointed_thing.ref:is_player() then
                minetest.sound_play('x_bows_arrow_successful_hit', {
                    to_player = selfObj._user:get_player_name(),
                    gain = 0.3
                })
            else
                minetest.sound_play(selfObj._sound_hit, {
                    to_player = selfObj._user:get_player_name(),
                    gain = 0.6
                })
            end

            selfObj.object:set_velocity({ x = 0, y = 0, z = 0 })
            selfObj.object:set_acceleration({ x = 0, y = 0, z = 0 })

            -- calculate damage
            local target_armor_groups = pointed_thing.ref:get_armor_groups()
            local _damage = 0

            if selfObj._add_damage then
                -- add damage from quiver
                _damage = _damage + selfObj._add_damage
            end

            if selfObj._x_enchanting.power then
                -- add damage from enchantment
                _damage = _damage + _damage * (selfObj._x_enchanting.power.value / 100)
            end

            for group, base_damage in pairs(selfObj._tool_capabilities.damage_groups) do
                _damage = _damage
                    + base_damage
                    * limit(selfObj._tflp / selfObj._tool_capabilities.full_punch_interval, 0.0, 1.0)
                    * ((target_armor_groups[group] or 0) + get_3d_armor_armor(pointed_thing.ref)) / 100.0
            end

            -- crits
            if selfObj._is_critical_hit then
                _damage = _damage * 2
            end

            -- knockback
            local dir = vector.normalize(vector.subtract(selfObj._shot_from_pos, ip_pos))
            local distance = vector.distance(selfObj._shot_from_pos, ip_pos)
            local knockback = minetest.calculate_knockback(
                pointed_thing.ref,
                selfObj.object,
                selfObj._tflp,
                {
                    full_punch_interval = selfObj._tool_capabilities.full_punch_interval,
                    damage_groups = { fleshy = _damage },
                },
                dir,
                distance,
                _damage
            )

            if selfObj._x_enchanting.punch then
                -- add knockback from enchantment
                -- the `punch.value` multiplier is too strong so divide it by half
                knockback = knockback * (selfObj._x_enchanting.punch.value / 2)

                pointed_thing.ref:add_velocity({
                    x = dir.x * knockback * -1,
                    y = 7,
                    z = dir.z * knockback * -1
                })
            else
                pointed_thing.ref:add_velocity({
                    x = dir.x * knockback * -1,
                    y = 5,
                    z = dir.z * knockback * -1
                })
            end

            pointed_thing.ref:punch(
                selfObj.object,
                selfObj._tflp,
                {
                    full_punch_interval = selfObj._tool_capabilities.full_punch_interval,
                    damage_groups = { fleshy = _damage, knockback = knockback }
                },
                {
                    x = dir.x * -1,
                    y = -7,
                    z = dir.z * -1
                }
            )

            selfObj._caused_damage = _damage
            selfObj._caused_knockback = knockback

            XBows:show_damage_numbers(selfObj.object:get_pos(), _damage, selfObj._is_critical_hit)

            -- already dead (entity)
            if not pointed_thing.ref:get_luaentity() and not pointed_thing.ref:is_player() then
                selfObj.object:remove()
                return
            end

            -- already dead (player)
            if pointed_thing.ref:get_hp() <= 0 then
                selfObj.object:remove()
                return
            end

            -- attach arrow prepare
            local rotation = { x = 0, y = 0, z = 0 }

            if in_pos.x == 1 then
                -- x = 0
                -- y = -90
                -- z = 0
                rotation.x = math.random(-10, 10)
                rotation.y = math.random(-100, -80)
                rotation.z = math.random(-10, 10)
            elseif in_pos.x == -1 then
                -- x = 0
                -- y = 90
                -- z = 0
                rotation.x = math.random(-10, 10)
                rotation.y = math.random(80, 100)
                rotation.z = math.random(-10, 10)
            elseif in_pos.y == 1 then
                -- x = -90
                -- y = 0
                -- z = -180
                rotation.x = math.random(-100, -80)
                rotation.y = math.random(-10, 10)
                rotation.z = math.random(-190, -170)
            elseif in_pos.y == -1 then
                -- x = 90
                -- y = 0
                -- z = 180
                rotation.x = math.random(80, 100)
                rotation.y = math.random(-10, 10)
                rotation.z = math.random(170, 190)
            elseif in_pos.z == 1 then
                -- x = 180
                -- y = 0
                -- z = 180
                rotation.x = math.random(170, 190)
                rotation.y = math.random(-10, 10)
                rotation.z = math.random(170, 190)
            elseif in_pos.z == -1 then
                -- x = -180
                -- y = 180
                -- z = -180
                rotation.x = math.random(-190, -170)
                rotation.y = math.random(170, 190)
                rotation.z = math.random(-190, -170)
            end

            if not XBows.settings.x_bows_attach_arrows_to_entities and not pointed_thing.ref:is_player() then
                selfObj.object:remove()
                return
            end

            ---normalize arrow scale when attached to scaled entity
            ---(prevents huge arrows when attached to scaled up entity models)
            local obj_props = selfObj.object:get_properties()
            local obj_to_props = pointed_thing.ref:get_properties()
            local vs = vector.divide(obj_props.visual_size, obj_to_props.visual_size)

            selfObj.object:set_properties({ visual_size = vs })

            -- attach arrow
            local position = vector.subtract(
                ip_pos,
                pointed_thing.ref:get_pos()
            )

            if pointed_thing.ref:is_player() then
                position = vector.multiply(position, 10)
            end

            ---`after` here prevents visual glitch when the arrow still shows as huge for a split second
            ---before the new calculated scale is applied
            minetest.after(0, function()
                selfObj.object:set_attach(
                    pointed_thing.ref,
                    '',
                    position,
                    rotation,
                    true
                )
            end)

            selfObj._attached = true
            selfObj._attached_to.type = pointed_thing.type
            selfObj._attached_to.pos = position

            -- remove last arrow when too many already attached
            local children = {}
            local projectile_entity = self.registered_arrows[selfObj._arrow_name].custom.projectile_entity

            for _, object in ipairs(pointed_thing.ref:get_children()) do
                if object:get_luaentity() and object:get_luaentity().name == projectile_entity then
                    table.insert(children, object)
                end
            end

            if #children >= 5 then
                children[1]:remove()
            end

            if pointed_thing.ref:is_player() then
                local on_hit_player_callback = self.registered_arrows[selfObj._arrow_name].custom.on_hit_player

                if on_hit_player_callback then
                    on_hit_player_callback(selfObj, pointed_thing)
                end
            else
                local on_hit_entity_callback = self.registered_arrows[selfObj._arrow_name].custom.on_hit_entity

                if on_hit_entity_callback then
                    on_hit_entity_callback(selfObj, pointed_thing)
                end
            end

            return

        elseif pointed_thing.type == 'node' and not selfObj._attached then
            local node = minetest.get_node(pointed_thing.under)
            local node_def = minetest.registered_nodes[node.name]

            if not node_def then
                return
            end

            selfObj._velocity = selfObj.object:get_velocity()

            if node_def.drawtype == 'liquid' and not selfObj._is_drowning then
                selfObj._is_drowning = true
                selfObj._in_liquid = true
                local drag = 1 / (node_def.liquid_viscosity * 6)
                selfObj.object:set_velocity(vector.multiply(selfObj._velocity, drag))
                selfObj.object:set_acceleration({ x = 0, y = -1.0, z = 0 })

                XBows:get_particle_effect_for_arrow('bubble', selfObj._old_pos)
            elseif selfObj._is_drowning then
                selfObj._is_drowning = false

                if selfObj._velocity then
                    selfObj.object:set_velocity(selfObj._velocity)
                end

                selfObj.object:set_acceleration({ x = 0, y = -9.81, z = 0 })
            end

            if XBows.mesecons and node.name == 'x_bows:target' then
                local distance = vector.distance(pointed_thing.under, ip_pos)
                distance = math.floor(distance * 100) / 100

                -- only close to the center of the target will trigger signal
                if distance < 0.54 then
                    mesecon.receptor_on(pointed_thing.under)
                    minetest.get_node_timer(pointed_thing.under):start(2)
                end
            end

            if node_def.walkable then
                selfObj.object:set_velocity({ x = 0, y = 0, z = 0 })
                selfObj.object:set_acceleration({ x = 0, y = 0, z = 0 })
                selfObj.object:set_pos(ip_pos)
                selfObj.object:set_rotation(selfObj.object:get_rotation())
                selfObj._attached = true
                selfObj._attached_to.type = pointed_thing.type
                selfObj._attached_to.pos = pointed_thing.under
                selfObj.object:set_properties({ collisionbox = { -0.2, -0.2, -0.2, 0.2, 0.2, 0.2 } })

                -- remove last arrow when too many already attached
                local children = {}
                local projectile_entity = self.registered_arrows[selfObj._arrow_name].custom.projectile_entity

                for _, object in ipairs(minetest.get_objects_inside_radius(pointed_thing.under, 1)) do
                    if not object:is_player()
                        and object:get_luaentity()
                        and object:get_luaentity().name == projectile_entity
                    then
                        table.insert(children, object)
                    end
                end

                if #children >= 5 then
                    children[#children]:remove()
                end

                ---Wiggle
                local x_bows_registered_entity_def = self.registered_entities[selfObj.name]
                if x_bows_registered_entity_def and x_bows_registered_entity_def._custom.animations.on_hit_node then
                    selfObj.object:set_animation(
                        unpack(x_bows_registered_entity_def._custom.animations.on_hit_node)--[[@as table]]
                    )
                end

                ---API callbacks
                local on_hit_node_callback = self.registered_arrows[selfObj._arrow_name].custom.on_hit_node

                if on_hit_node_callback then
                    on_hit_node_callback(selfObj, pointed_thing)
                end

                local new_pos = selfObj.object:get_pos()

                if new_pos then
                    minetest.add_particlespawner({
                        amount = 5,
                        time = 0.25,
                        minpos = { x = new_pos.x - 0.4, y = new_pos.y + 0.2, z = new_pos.z - 0.4 },
                        maxpos = { x = new_pos.x + 0.4, y = new_pos.y + 0.3, z = new_pos.z + 0.4 },
                        minvel = { x = 0, y = 3, z = 0 },
                        maxvel = { x = 0, y = 4, z = 0 },
                        minacc = { x = 0, y = -28, z = 0 },
                        maxacc = { x = 0, y = -32, z = 0 },
                        minexptime = 1,
                        maxexptime = 1.5,
                        node = { name = node_def.name },
                        collisiondetection = true,
                        object_collision = true,
                    })
                end

                minetest.sound_play(selfObj._sound_hit, {
                    pos = pointed_thing.under,
                    gain = 0.6,
                    max_hear_distance = 16
                })

                return
            end
        end
        pointed_thing = ray:next()
    end

    selfObj._old_pos = pos
end

---Function receive a "luaentity" table as `self`. Called when somebody punches the object.
---Note that you probably want to handle most punches using the automatic armor group system.
---Can return `true` to prevent the default damage mechanism.
---@param self XBows
---@param selfObj EnityCustomAttrDef
---@param puncher ObjectRef|nil
---@param time_from_last_punch number|integer|nil
---@param tool_capabilities ToolCapabilitiesDef
---@param dir Vector
---@param damage number|integer
---@return boolean
function XBowsEntityDef.on_punch(self, selfObj, puncher, time_from_last_punch, tool_capabilities, dir, damage)
    local pos = selfObj.object:get_pos()

    if pos then
        minetest.sound_play('default_dig_choppy', {
            pos = pos,
            gain = 0.4
        })
    end

    return false
end

---Register new projectile entity
---@param self XBows
---@param name string
---@param def XBowsEntityDef
function XBows.register_entity(self, name, def)
    def._custom = def._custom or {}
    def._custom.animations = def._custom.animations or {}

    local mod_name = def._custom.mod_name or 'x_bows'
    def._custom.name = mod_name .. ':' .. name
    def.initial_properties = mergeTables({
        ---defaults
        visual = 'wielditem',
        collisionbox = { 0, 0, 0, 0, 0, 0 },
        selectionbox = { 0, 0, 0, 0, 0, 0 },
        physical = false,
        textures = { 'air' },
        hp_max = 1,
        visual_size = { x = 1, y = 1, z = 1 },
        glow = 1
    }, def.initial_properties or {})

    def.on_death = function(selfObj, killer)
        return XBowsEntityDef:on_death(selfObj, killer)
    end

    if def._custom.on_death then
        def.on_death = def._custom.on_death
    end

    def.on_activate = function(selfObj, killer)
        return XBowsEntityDef:on_activate(selfObj, killer)
    end

    def.on_step = function(selfObj, dtime)
        return XBowsEntityDef:on_step(selfObj, dtime)
    end

    def.on_punch = function(selfObj, puncher, time_from_last_punch, tool_capabilities, dir, damage)
        return XBowsEntityDef:on_punch(selfObj, puncher, time_from_last_punch, tool_capabilities, dir, damage)
    end

    if def._custom.on_punch then
        def.on_punch = def._custom.on_punch
    end

    self.registered_entities[def._custom.name] = def

    minetest.register_entity(def._custom.name, {
        initial_properties = def.initial_properties,
        on_death = def.on_death,
        on_activate = def.on_activate,
        on_step = def.on_step,
        on_punch = def.on_punch
    })
end

----
--- QUIVER API
----

---Close one or all open quivers in players inventory
---@param self XBowsQuiver
---@param player ObjectRef
---@param quiver_id? string If `nil` then all open quivers will be closed
---@return nil
function XBowsQuiver.close_quiver(self, player, quiver_id)
    local player_inv = player:get_inventory()

    ---find matching quiver item in players inventory with the open formspec name
    if player_inv and player_inv:contains_item('main', 'x_bows:quiver_open') then
        local inv_list = player_inv:get_list('main')

        for i, st in ipairs(inv_list) do
            local st_meta = st:get_meta()

            if not st:is_empty() and st:get_name() == 'x_bows:quiver_open' then
                if quiver_id and st_meta:get_string('quiver_id') == quiver_id then
                    local replace_item = self:get_replacement_item(st, 'x_bows:quiver')
                    player_inv:set_stack('main', i, replace_item)
                    break
                else
                    local replace_item = self:get_replacement_item(st, 'x_bows:quiver')
                    player_inv:set_stack('main', i, replace_item)
                end
            end
        end
    end
end

---Swap item in player inventory indicating open quiver. Preserve all ItemStack definition and meta.
---@param self XBowsQuiver
---@param from_stack ItemStack transfer data from this item
---@param to_item_name string transfer data to this item
---@return ItemStack ItemStack replacement item
function XBowsQuiver.get_replacement_item(self, from_stack, to_item_name)
    ---@type ItemStack
    local replace_item = ItemStack({
        name = to_item_name,
        count = from_stack:get_count(),
        wear = from_stack:get_wear()
    })
    local replace_item_meta = replace_item:get_meta()
    local from_stack_meta = from_stack:get_meta()

    replace_item_meta:set_string('quiver_items', from_stack_meta:get_string('quiver_items'))
    replace_item_meta:set_string('quiver_id', from_stack_meta:get_string('quiver_id'))
    replace_item_meta:set_string('description', from_stack_meta:get_string('description'))

    return replace_item
end

---Gets arrow from quiver
---@param self XBowsQuiver
---@param player ObjectRef
---@diagnostic disable-next-line: codestyle-check
---@return {["found_arrow_stack"]: ItemStack|nil, ["quiver_id"]: string|nil, ["quiver_name"]: string|nil, ["found_arrow_stack_idx"]: number}
function XBowsQuiver.get_itemstack_arrow_from_quiver(self, player)
    local player_inv = player:get_inventory()
    local wielded_stack = player:get_wielded_item()
    ---@type ItemStack|nil
    local found_arrow_stack
    local found_arrow_stack_idx = 1
    local prev_detached_inv_list = {}
    local quiver_id
    local quiver_name

    ---check quiver inventory slot
    if player_inv and player_inv:contains_item('x_bows:quiver_inv', 'x_bows:quiver') then
        local player_name = player:get_player_name()
        local quiver_stack = player_inv:get_stack('x_bows:quiver_inv', 1)
        local st_meta = quiver_stack:get_meta()
        quiver_id = st_meta:get_string('quiver_id')

        local detached_inv = self:get_or_create_detached_inv(
            quiver_id,
            player_name,
            st_meta:get_string('quiver_items')
        )

        if not detached_inv:is_empty('main') then
            local detached_inv_list = detached_inv:get_list('main')

            ---find arrows inside quiver inventory
            for j, qst in ipairs(detached_inv_list) do
                ---save copy of inv list before we take the item
                table.insert(prev_detached_inv_list, detached_inv:get_stack('main', j))

                if not qst:is_empty() and not found_arrow_stack then
                    local is_allowed_ammunition = self:is_allowed_ammunition(wielded_stack:get_name(), qst:get_name())

                    if is_allowed_ammunition then
                        quiver_name = quiver_stack:get_name()
                        found_arrow_stack = qst:take_item()
                        found_arrow_stack_idx = j

                        ---X Enchanting
                        local wielded_stack_meta = wielded_stack:get_meta()
                        local is_infinity = wielded_stack_meta:get_float('is_infinity')

                        if not self:is_creative(player_name) and is_infinity == 0 then
                            -- take item will be set
                            detached_inv:set_list('main', detached_inv_list)
                            self:save(detached_inv, player, true)
                        end
                    end
                end
            end
        end

        if found_arrow_stack then
            ---show HUD - quiver inventory
            self:udate_or_create_hud(player, prev_detached_inv_list, found_arrow_stack_idx)
        end
    end

    if self.fallback_quiver then
        ---find matching quiver item in players inventory with the open formspec name
        if player_inv and player_inv:contains_item('main', 'x_bows:quiver') then
            local inv_list = player_inv:get_list('main')

            for i, st in ipairs(inv_list) do
                if not st:is_empty() and st:get_name() == 'x_bows:quiver' then
                    local st_meta = st:get_meta()
                    local player_name = player:get_player_name()
                    quiver_id = st_meta:get_string('quiver_id')

                    local detached_inv = self:get_or_create_detached_inv(
                        quiver_id,
                        player_name,
                        st_meta:get_string('quiver_items')
                    )

                    if not detached_inv:is_empty('main') then
                        local detached_inv_list = detached_inv:get_list('main')

                        ---find arrows inside quiver inventory
                        for j, qst in ipairs(detached_inv_list) do
                            ---save copy of inv list before we take the item
                            table.insert(prev_detached_inv_list, detached_inv:get_stack('main', j))

                            if not qst:is_empty() and not found_arrow_stack then
                                local is_allowed_ammunition = self:is_allowed_ammunition(
                                    wielded_stack:get_name(),
                                    qst:get_name()
                                )

                                if is_allowed_ammunition then
                                    quiver_name = st:get_name()
                                    found_arrow_stack = qst:take_item()
                                    found_arrow_stack_idx = j

                                    if not self:is_creative(player_name) then
                                        detached_inv:set_list('main', detached_inv_list)
                                        self:save(detached_inv, player, true)
                                    end
                                end
                            end
                        end
                    end
                end

                if found_arrow_stack then
                    ---show HUD - quiver inventory
                    self:udate_or_create_hud(player, prev_detached_inv_list, found_arrow_stack_idx)

                    break
                end
            end
        end
    end

    return {
        found_arrow_stack = found_arrow_stack,
        quiver_id = quiver_id,
        quiver_name = quiver_name,
        found_arrow_stack_idx = found_arrow_stack_idx
    }
end

---Remove all added HUDs
---@param self XBowsQuiver
---@param player ObjectRef
---@return nil
function XBowsQuiver.remove_hud(self, player)
    local player_name = player:get_player_name()

    if self.hud_item_ids[player_name] then
        for _, v in pairs(self.hud_item_ids[player_name]) do
            if type(v) == 'table' then
                for _, v2 in pairs(v) do
                    player:hud_remove(v2)
                end
            else
                player:hud_remove(v)
            end
        end

        self.hud_item_ids[player_name] = {
            arrow_inv_img = {},
            stack_count = {}
        }
    else
        self.hud_item_ids[player_name] = {
            arrow_inv_img = {},
            stack_count = {}
        }
    end
end

---@todo implement hud_change?
---Update or create quiver HUD
---@param self XBowsQuiver
---@param player ObjectRef
---@param inv_list ItemStack[]
---@param idx? number
---@return nil
function XBowsQuiver.udate_or_create_hud(self, player, inv_list, idx)
    local _idx = idx or 1
    local player_name = player:get_player_name()
    local selected_bg_added = false
    local is_arrow = #inv_list == 1
    local item_def = minetest.registered_items['x_bows:quiver']
    local is_no_ammo = false

    if is_arrow then
        item_def = minetest.registered_items[inv_list[1]:get_name()]
        is_no_ammo = inv_list[1]:get_name() == 'x_bows:no_ammo'
    end

    if is_no_ammo then
        item_def = {
            inventory_image = 'x_bows_arrow_slot.png',
            short_description = S('No Ammo') .. '!'
        }
    end

    if not item_def then
        return
    end

    ---cancel previous timeouts and reset
    if self.after_job[player_name] then
        for _, v in pairs(self.after_job[player_name]) do
            v:cancel()
        end

        self.after_job[player_name] = {}
    else
        self.after_job[player_name] = {}
    end

    self:remove_hud(player)

    ---title image
    self.hud_item_ids[player_name].title_image = player:hud_add({
        hud_elem_type = 'image',
        position = { x = 1, y = 0.5 },
        offset = { x = -120, y = -140 },
        text = item_def.inventory_image,
        scale = { x = 4, y = 4 },
        alignment = 0,
    })

    ---title copy
    self.hud_item_ids[player_name].title_copy = player:hud_add({
        hud_elem_type = 'text',
        position = { x = 1, y = 0.5 },
        offset = { x = -120, y = -75 },
        text = item_def.short_description,
        alignment = 0,
        scale = { x = 100, y = 30 },
        number = 0xFFFFFF,
    })

    ---hotbar bg
    self.hud_item_ids[player_name].hotbar_bg = player:hud_add({
        hud_elem_type = 'image',
        position = { x = 1, y = 0.5 },
        offset = { x = -238, y = 0 },
        text = is_arrow and 'x_bows_single_hotbar.png' or 'x_bows_quiver_hotbar.png',
        scale = { x = 1, y = 1 },
        alignment = { x = 1, y = 0 },
    })

    for j, qst in ipairs(inv_list) do
        if not qst:is_empty() then
            local found_arrow_stack_def = minetest.registered_items[qst:get_name()]

            if is_no_ammo then
                found_arrow_stack_def = item_def
            end

            if not selected_bg_added and j == _idx then
                selected_bg_added = true

                ---ui selected bg
                self.hud_item_ids[player_name].hotbar_selected = player:hud_add({
                    hud_elem_type = 'image',
                    position = { x = 1, y = 0.5 },
                    offset = { x = -308 + (j * 74), y = 2 },
                    text = 'x_bows_hotbar_selected.png',
                    scale = { x = 1, y = 1 },
                    alignment = { x = 1, y = 0 },
                })
            end

            if found_arrow_stack_def then
                ---arrow inventory image
                table.insert(self.hud_item_ids[player_name].arrow_inv_img, player:hud_add({
                    hud_elem_type = 'image',
                    position = { x = 1, y = 0.5 },
                    offset = { x = -300 + (j * 74), y = 0 },
                    text = found_arrow_stack_def.inventory_image,
                    scale = { x = 4, y = 4 },
                    alignment = { x = 1, y = 0 },
                }))

                ---stack count
                table.insert(self.hud_item_ids[player_name].stack_count, player:hud_add({
                    hud_elem_type = 'text',
                    position = { x = 1, y = 0.5 },
                    offset = { x = -244 + (j * 74), y = 23 },
                    text = is_no_ammo and 0 or qst:get_count(),
                    alignment = -1,
                    scale = { x = 50, y = 10 },
                    number = 0xFFFFFF,
                }))
            end
        end
    end

    ---@param v_player ObjectRef
    table.insert(self.after_job[player_name], minetest.after(10, function(v_player)
        self:remove_hud(v_player)
    end, player))
end

---Get existing detached inventory or create new one
---@param self XBowsQuiver
---@param quiver_id string
---@param player_name string
---@param quiver_items? string
---@return InvRef
function XBowsQuiver.get_or_create_detached_inv(self, quiver_id, player_name, quiver_items)
    local detached_inv

    if quiver_id ~= '' then
        detached_inv = minetest.get_inventory({ type = 'detached', name = quiver_id })
    end

    if not detached_inv then
        detached_inv = minetest.create_detached_inventory(quiver_id, {
            ---@param inv InvRef detached inventory
            ---@param from_list string
            ---@param from_index number
            ---@param to_list string
            ---@param to_index number
            ---@param count number
            ---@param player ObjectRef
            allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
                if self:quiver_can_allow(inv, player) then
                    return count
                else
                    return 0
                end
            end,
            ---@param inv InvRef detached inventory
            ---@param listname string listname of the inventory, e.g. `'main'`
            ---@param index number
            ---@param stack ItemStack
            ---@param player ObjectRef
            allow_put = function(inv, listname, index, stack, player)
                if minetest.get_item_group(stack:get_name(), 'arrow') ~= 0 and self:quiver_can_allow(inv, player) then
                    return stack:get_count()
                else
                    return 0
                end
            end,
            ---@param inv InvRef detached inventory
            ---@param listname string listname of the inventory, e.g. `'main'`
            ---@param index number
            ---@param stack ItemStack
            ---@param player ObjectRef
            allow_take = function(inv, listname, index, stack, player)
                if minetest.get_item_group(stack:get_name(), 'arrow') ~= 0 and self:quiver_can_allow(inv, player) then
                    return stack:get_count()
                else
                    return 0
                end
            end,
            ---@param inv InvRef detached inventory
            ---@param from_list string
            ---@param from_index number
            ---@param to_list string
            ---@param to_index number
            ---@param count number
            ---@param player ObjectRef
            on_move = function(inv, from_list, from_index, to_list, to_index, count, player)
                self:save(inv, player)
            end,
            ---@param inv InvRef detached inventory
            ---@param listname string listname of the inventory, e.g. `'main'`
            ---@param index number index where was item put
            ---@param stack ItemStack stack of item what was put
            ---@param player ObjectRef
            on_put = function(inv, listname, index, stack, player)
                local quiver_inv_st = player:get_inventory():get_stack('x_bows:quiver_inv', 1)

                if quiver_inv_st and quiver_inv_st:get_meta():get_string('quiver_id') == inv:get_location().name then
                    if inv:is_empty('main') then
                        self:show_3d_quiver(player, { is_empty = true })
                    else
                        self:show_3d_quiver(player)
                    end
                end

                self:save(inv, player)
            end,
            ---@param inv InvRef detached inventory
            ---@param listname string listname of the inventory, e.g. `'main'`
            ---@param index number
            ---@param stack ItemStack
            ---@param player ObjectRef
            on_take = function(inv, listname, index, stack, player)
                local quiver_inv_st = player:get_inventory():get_stack('x_bows:quiver_inv', 1)

                if quiver_inv_st and quiver_inv_st:get_meta():get_string('quiver_id') == inv:get_location().name then
                    if inv:is_empty('main') then
                        self:show_3d_quiver(player, { is_empty = true })
                    else
                        self:show_3d_quiver(player)
                    end
                end

                self:save(inv, player)
            end,
        }, player_name)

        detached_inv:set_size('main', 3 * 1)
    end

    ---populate items in inventory
    if quiver_items and quiver_items ~= '' then
        self:set_string_to_inv(detached_inv, quiver_items)
    end

    return detached_inv
end

---Create formspec
---@param self XBowsQuiver
---@param name string name of the form
---@return string
function XBowsQuiver.get_formspec(self, name)
    local width = 3
    local height = 1
    local list_w = 8
    local list_pos_x = (list_w - width) / 2

    local formspec = {
        'size[' .. list_w .. ',6]',
        'list[detached:' .. name .. ';main;' .. list_pos_x .. ',0.3;' .. width .. ',1;]',
        'list[current_player;main;0,' .. (height + 0.85) .. ';' .. list_w .. ',1;]',
        'list[current_player;main;0,' .. (height + 2.08) .. ';' .. list_w .. ',3;8]',
        'listring[detached:' .. name .. ';main]',
        'listring[current_player;main]'
    }

    if minetest.global_exists('default') then
        formspec[#formspec + 1] = default.get_hotbar_bg(0, height + 0.85)
    end

    --update formspec
    local inv = minetest.get_inventory({ type = 'detached', name = name })
    local invlist = inv:get_list(name)

    ---inventory slots overlay
    local px, py = list_pos_x, 0.3

    for i = 1, 3 do
        if not invlist or invlist[i]:is_empty() then
            formspec[#formspec + 1] = 'image[' .. px .. ',' .. py .. ';1,1;x_bows_arrow_slot.png]'
        end

        px = px + 1
    end

    formspec = table.concat(formspec, '')

    return formspec
end

---Convert inventory of itemstacks to serialized string
---@param self XBowsQuiver
---@param inv InvRef
---@return {['inv_string']: string, ['content_description']: string}
function XBowsQuiver.get_string_from_inv(self, inv)
    local inv_list = inv:get_list('main')
    local t = {}
    local content_description = ''

    for i, st in ipairs(inv_list) do
        if not st:is_empty() then
            table.insert(t, st:to_table())
            content_description = content_description .. '\n' .. st:get_short_description() .. ' ' .. st:get_count()
        else
            table.insert(t, { is_empty = true })
        end
    end

    return {
        inv_string = minetest.serialize(t),
        content_description = content_description == '' and '\n' .. S('Empty') or content_description
    }
end

---Set items from serialized string to inventory
---@param self XBowsQuiver
---@param inv InvRef inventory to add items to
---@param str string previously stringified inventory of itemstacks
---@return nil
function XBowsQuiver.set_string_to_inv(self, inv, str)
    local t = minetest.deserialize(str)

    for i, item in ipairs(t) do
        if not item.is_empty then
            inv:set_stack('main', i, ItemStack(item))
        end
    end
end

---Save quiver inventory to itemstack meta
---@param self XBowsQuiver
---@param inv InvRef
---@param player ObjectRef
---@param quiver_is_closed? boolean
---@return nil
function XBowsQuiver.save(self, inv, player, quiver_is_closed)
    local player_inv = player:get_inventory() --[[@as InvRef]]
    local inv_loc = inv:get_location()
    local quiver_item_name = quiver_is_closed and 'x_bows:quiver' or 'x_bows:quiver_open'
    local player_quiver_inv_stack = player_inv:get_stack('x_bows:quiver_inv', 1)

    if not player_quiver_inv_stack:is_empty()
        and player_quiver_inv_stack:get_meta():get_string('quiver_id') == inv_loc.name
    then
        local st_meta = player_quiver_inv_stack:get_meta()
        ---save inventory items in quiver item meta
        local string_from_inventory_result = self:get_string_from_inv(inv)

        st_meta:set_string('quiver_items', string_from_inventory_result.inv_string)

        ---update description
        local new_description = player_quiver_inv_stack:get_short_description() .. '\n' ..
            string_from_inventory_result.content_description .. '\n'

        st_meta:set_string('description', new_description)
        player_inv:set_stack('x_bows:quiver_inv', 1, player_quiver_inv_stack)
    elseif player_inv and player_inv:contains_item('main', quiver_item_name) then
        ---find matching quiver item in players inventory with the open formspec name
        local inv_list = player_inv:get_list('main')

        for i, st in ipairs(inv_list) do
            local st_meta = st:get_meta()

            if not st:is_empty() and st:get_name() == quiver_item_name
                and st_meta:get_string('quiver_id') == inv_loc.name
            then
                ---save inventory items in quiver item meta
                local string_from_inventory_result = self:get_string_from_inv(inv)

                st_meta:set_string('quiver_items', string_from_inventory_result.inv_string)

                ---update description
                local new_description = st:get_short_description() .. '\n' ..
                    string_from_inventory_result.content_description .. '\n'

                st_meta:set_string('description', new_description)
                player_inv:set_stack('main', i, st)

                break
            end
        end
    end
end

---Check if we are allowing actions in the correct quiver inventory
---@param self XBowsQuiver
---@param inv InvRef
---@param player ObjectRef
---@return boolean
function XBowsQuiver.quiver_can_allow(self, inv, player)
    local player_inv = player:get_inventory() --[[@as InvRef]]
    local inv_loc = inv:get_location()
    local player_quiver_inv_stack = player_inv:get_stack('x_bows:quiver_inv', 1)

    if not player_quiver_inv_stack:is_empty()
        and player_quiver_inv_stack:get_meta():get_string('quiver_id') == inv_loc.name
    then
        ---find quiver in player `quiver_inv` inv list
        return true
    elseif player_inv and player_inv:contains_item('main', 'x_bows:quiver_open') then
        ---find quiver in player `main` inv list
        ---matching quiver item in players inventory with the open formspec name
        local inv_list = player_inv:get_list('main')

        for i, st in ipairs(inv_list) do
            local st_meta = st:get_meta()

            if not st:is_empty() and st:get_name() == 'x_bows:quiver_open'
                and st_meta:get_string('quiver_id') == inv_loc.name
            then
                return true
            end
        end
    end

    return false
end

---Open quiver
---@param self XBows
---@param itemstack ItemStack
---@param user ObjectRef
---@return ItemStack
function XBows.open_quiver(self, itemstack, user)
    local itemstack_meta = itemstack:get_meta()
    local pname = user:get_player_name()
    local quiver_id = itemstack_meta:get_string('quiver_id')

    ---create inventory id and save it
    if quiver_id == '' then
        quiver_id = itemstack:get_name() .. '_' .. self.uuid()
        itemstack_meta:set_string('quiver_id', quiver_id)
    end

    local quiver_items = itemstack_meta:get_string('quiver_items')

    XBowsQuiver:get_or_create_detached_inv(quiver_id, pname, quiver_items)

    ---show open variation of quiver
    local replace_item = XBowsQuiver:get_replacement_item(itemstack, 'x_bows:quiver_open')

    itemstack:replace(replace_item)

    minetest.sound_play('x_bows_quiver', {
        to_player = user:get_player_name(),
        gain = 0.1
    })

    minetest.show_formspec(pname, quiver_id, XBowsQuiver:get_formspec(quiver_id))
    return itemstack
end

---Register sfinv page
---@param self XBowsQuiver
function XBowsQuiver.sfinv_register_page(self)
    sfinv.register_page('x_bows:quiver_page', {
        title = 'X Bows',
        get = function(this, player, context)
            local formspec = {
                ---arrow
                'label[0,0;' .. minetest.formspec_escape(S('Arrows')) .. ':]',
                'list[current_player;x_bows:arrow_inv;0,0.5;1,1;]',
                'image[0,0.5;1,1;x_bows_arrow_slot.png]',
                'listring[current_player;x_bows:arrow_inv]',
                'listring[current_player;main]',
                ---quiver
                'label[3.5,0;' .. minetest.formspec_escape(S('Quiver')) .. ':]',
                'list[current_player;x_bows:quiver_inv;3.5,0.5;1,1;]',
                'image[3.5,0.5;1,1;x_bows_quiver_slot.png]',
                'listring[current_player;x_bows:quiver_inv]',
                'listring[current_player;main]',
            }

            local player_inv = player:get_inventory() --[[@as InvRef]]
            context._itemstack_arrow = player_inv:get_stack('x_bows:arrow_inv', 1)
            context._itemstack_quiver = player_inv:get_stack('x_bows:quiver_inv', 1)

            if context._itemstack_arrow and not context._itemstack_arrow:is_empty() then
                local x_bows_registered_arrow_def = self.registered_arrows[context._itemstack_arrow:get_name()]
                local short_description = context._itemstack_arrow:get_short_description()

                if x_bows_registered_arrow_def and short_description then
                    formspec[#formspec + 1] = 'label[0,1.5;' ..
                        minetest.formspec_escape(short_description) .. '\n' ..
                        minetest.formspec_escape(x_bows_registered_arrow_def.custom.description_abilities) .. ']'
                end
            end


            if context._itemstack_quiver and not context._itemstack_quiver:is_empty() then
                local st_meta = context._itemstack_quiver:get_meta()
                local quiver_id = st_meta:get_string('quiver_id')
                local short_description = context._itemstack_quiver:get_short_description()

                ---description
                if short_description then
                    formspec[#formspec + 1] = 'label[3.5,1.5;' ..
                        minetest.formspec_escape(short_description) .. ']'
                end

                formspec[#formspec + 1] = 'list[detached:' .. quiver_id .. ';main;4.5,0.5;3,1;]'
                formspec[#formspec + 1] = 'listring[detached:' .. quiver_id .. ';main]'
                formspec[#formspec + 1] = 'listring[current_player;main]'
            end

            return sfinv.make_formspec(player, context, table.concat(formspec, ''), true)
        end
    })
end

---Register i3 page
function XBowsQuiver.i3_register_page(self)
    i3.new_tab('x_bows_quiver_page', {
        description = 'X Bows',
        slots = true,
        formspec = function(player, data, fs)
            local formspec = {
                ---arrow
                'label[0.5,1;' .. minetest.formspec_escape(S('Arrows')) .. ':]',
                'list[current_player;x_bows:arrow_inv;0.5,1.5;1,1;]',
                'listring[current_player;x_bows:arrow_inv]',
                'listring[current_player;main]',
                ---quiver
                'label[5,1;' .. minetest.formspec_escape(S('Quiver')) .. ':]',
                'list[current_player;x_bows:quiver_inv;5,1.5;1,1;]',
                'listring[current_player;x_bows:quiver_inv]',
                'listring[current_player;main]'
            }

            local context = {}
            local player_inv = player:get_inventory()
            context._itemstack_arrow = player_inv:get_stack('x_bows:arrow_inv', 1)
            context._itemstack_quiver = player_inv:get_stack('x_bows:quiver_inv', 1)

            if context._itemstack_arrow and not context._itemstack_arrow:is_empty() then
                local x_bows_registered_arrow_def = self.registered_arrows[context._itemstack_arrow:get_name()]

                if x_bows_registered_arrow_def then
                    formspec[#formspec + 1] = 'label[0.5,3;' ..
                        minetest.formspec_escape(context._itemstack_arrow:get_short_description()) .. '\n' ..
                        minetest.formspec_escape(x_bows_registered_arrow_def.custom.description_abilities) .. ']'
                end
            end

            if context._itemstack_quiver and not context._itemstack_quiver:is_empty() then
                local st_meta = context._itemstack_quiver:get_meta()
                local quiver_id = st_meta:get_string('quiver_id')

                ---description
                formspec[#formspec + 1] = 'label[5,3;' ..
                    minetest.formspec_escape(context._itemstack_quiver:get_short_description()) .. ']'
                formspec[#formspec + 1] = 'list[detached:' .. quiver_id .. ';main;6.3,1.5;3,1;]'
                formspec[#formspec + 1] = 'listring[detached:' .. quiver_id .. ';main]'
                formspec[#formspec + 1] = 'listring[current_player;main]'
            end

            formspec = table.concat(formspec, '')

            fs(formspec)
        end
    })
end

---Register i3 page
function XBowsQuiver.ui_register_page(self)
    unified_inventory.register_page('x_bows:quiver_page', {
        get_formspec = function(player, data, fs)
            local formspec = {
                unified_inventory.style_full.standard_inv_bg,
                'listcolors[#00000000;#00000000]',
                ---arrow
                'label[0.5,0.5;' .. minetest.formspec_escape(S('Arrows')) .. ':]',
                unified_inventory.single_slot(0.4, 0.9),
                'list[current_player;x_bows:arrow_inv;0.5,1;1,1;]',
                'listring[current_player;x_bows:arrow_inv]',
                'listring[current_player;main]',
                ---quiver
                'label[5,0.5;' .. minetest.formspec_escape(S('Quiver')) .. ':]',
                unified_inventory.single_slot(4.9, 0.9),
                'list[current_player;x_bows:quiver_inv;5,1;1,1;]',
                'listring[current_player;x_bows:quiver_inv]',
                'listring[current_player;main]',
            }

            local context = {}
            context._itemstack_arrow = player:get_inventory():get_stack('x_bows:arrow_inv', 1)
            context._itemstack_quiver = player:get_inventory():get_stack('x_bows:quiver_inv', 1)

            if context._itemstack_arrow and not context._itemstack_arrow:is_empty() then
                local x_bows_registered_arrow_def = self.registered_arrows[context._itemstack_arrow:get_name()]

                if x_bows_registered_arrow_def then
                    formspec[#formspec + 1] = 'label[0.5,2.5;' ..
                        minetest.formspec_escape(context._itemstack_arrow:get_short_description()) .. '\n' ..
                        minetest.formspec_escape(x_bows_registered_arrow_def.custom.description_abilities) .. ']'
                end
            end


            if context._itemstack_quiver and not context._itemstack_quiver:is_empty() then
                local st_meta = context._itemstack_quiver:get_meta()
                local quiver_id = st_meta:get_string('quiver_id')

                ---description
                formspec[#formspec + 1] = 'label[5,2.5;' ..
                    minetest.formspec_escape(context._itemstack_quiver:get_short_description()) .. ']'
                formspec[#formspec + 1] = unified_inventory.single_slot(6.4, 0.9)
                formspec[#formspec + 1] = unified_inventory.single_slot(7.65, 0.9)
                formspec[#formspec + 1] = unified_inventory.single_slot(8.9, 0.9)
                formspec[#formspec + 1] = 'list[detached:' .. quiver_id .. ';main;6.5,1;3,1;]'
                formspec[#formspec + 1] = 'listring[detached:' .. quiver_id .. ';main]'
                formspec[#formspec + 1] = 'listring[current_player;main]'
            end

            return {
                formspec = table.concat(formspec, '')
            }
        end
    })

    unified_inventory.register_button('x_bows:quiver_page', {
        type = 'image',
        image = "x_bows_bow_wood_charged.png",
        tooltip = 'X Bows',
    })
end

function XBowsQuiver.show_3d_quiver(self, player, props)
    if not XBows.settings.x_bows_show_3d_quiver or not XBows.player_api then
        return
    end

    local _props = props or {}
    local p_name = player:get_player_name()
    local quiver_texture = 'x_bows_quiver_mesh.png'
    local player_textures

    if _props.is_empty then
        quiver_texture = 'x_bows_quiver_empty_mesh.png'
    end

    if self.skinsdb then
        minetest.after(1, function()
            local textures = player_api.get_textures(player)

            ---cleanup
            for index, value in ipairs(textures) do
                if value == 'x_bows_quiver_blank_mesh.png' or value == 'x_bows_quiver_mesh.png'
                    or value == 'x_bows_quiver_empty_mesh.png'
                then
                    table.remove(textures, index)
                end
            end

            table.insert(textures, quiver_texture)

            player_textures = textures

            if player_textures then
                if _props.is_empty and not self.quiver_empty_state[player:get_player_name()] then
                    self.quiver_empty_state[player:get_player_name()] = true
                    player_api.set_textures(player, player_textures)
                elseif not _props.is_empty and self.quiver_empty_state[player:get_player_name()] then
                    self.quiver_empty_state[player:get_player_name()] = false
                    player_api.set_textures(player, player_textures)
                end
            end
        end)

        return
    elseif self._3d_armor then
        minetest.after(0.1, function()
            player_textures = {
                armor.textures[p_name].skin,
                armor.textures[p_name].armor,
                armor.textures[p_name].wielditem,
                quiver_texture
            }

            if player_textures then
                if _props.is_empty and not self.quiver_empty_state[player:get_player_name()] then
                    self.quiver_empty_state[player:get_player_name()] = true
                    player_api.set_textures(player, player_textures)
                elseif not _props.is_empty and self.quiver_empty_state[player:get_player_name()] then
                    self.quiver_empty_state[player:get_player_name()] = false
                    player_api.set_textures(player, player_textures)
                end
            end
        end)

        return
    elseif self.u_skins then
        local u_skin_texture = u_skins.u_skins[p_name]

        player_textures = {
            u_skin_texture .. '.png',
            quiver_texture
        }
    elseif self.wardrobe and wardrobe.playerSkins and wardrobe.playerSkins[p_name] then
        player_textures = {
            wardrobe.playerSkins[p_name],
            quiver_texture
        }
    else
        local textures = player_api.get_textures(player)

        ---cleanup
        for index, value in ipairs(textures) do
            if value == 'x_bows_quiver_blank_mesh.png' or value == 'x_bows_quiver_mesh.png'
                or value == 'x_bows_quiver_empty_mesh.png'
            then
                table.remove(textures, index)
            end
        end

        table.insert(textures, quiver_texture)

        player_textures = textures
    end

    if player_textures then
        if _props.is_empty and not self.quiver_empty_state[player:get_player_name()] then
            self.quiver_empty_state[player:get_player_name()] = true
            player_api.set_textures(player, player_textures)
        elseif not _props.is_empty and self.quiver_empty_state[player:get_player_name()] then
            self.quiver_empty_state[player:get_player_name()] = false
            player_api.set_textures(player, player_textures)
        end
    end
end

function XBowsQuiver.hide_3d_quiver(self, player)
    if not XBows.settings.x_bows_show_3d_quiver or not XBows.player_api then
        return
    end

    local p_name = player:get_player_name()
    local player_textures

    if self.skinsdb then
        minetest.after(1, function()
            local textures = player_api.get_textures(player)

            ---cleanup
            for index, value in ipairs(textures) do
                if value == 'x_bows_quiver_mesh.png' or value == 'x_bows_quiver_blank_mesh.png'
                    or value == 'x_bows_quiver_empty_mesh.png'
                then
                    table.remove(textures, index)
                end
            end

            table.insert(textures, 'x_bows_quiver_blank_mesh.png')

            player_textures = textures

            if player_textures then
                player_api.set_textures(player, player_textures)
            end
        end)

        return
    elseif self._3d_armor then
        minetest.after(0.1, function()
            player_textures = {
                armor.textures[p_name].skin,
                armor.textures[p_name].armor,
                armor.textures[p_name].wielditem,
                'x_bows_quiver_blank_mesh.png'
            }

            if player_textures then
                player_api.set_textures(player, player_textures)
            end

        end)

        return
    elseif self.u_skins then
        local u_skin_texture = u_skins.u_skins[p_name]

        player_textures = {
            u_skin_texture .. '.png',
            'x_bows_quiver_blank_mesh.png'
        }
    elseif self.wardrobe and wardrobe.playerSkins and wardrobe.playerSkins[p_name] then
        player_textures = {
            wardrobe.playerSkins[p_name],
            'x_bows_quiver_blank_mesh.png'
        }
    else
        local textures = player_api.get_textures(player)

        ---cleanup
        for index, value in ipairs(textures) do
            if value == 'x_bows_quiver_mesh.png' or value == 'x_bows_quiver_blank_mesh.png'
                or value == 'x_bows_quiver_empty_mesh.png'
            then
                table.remove(textures, index)
            end
        end

        table.insert(textures, 'x_bows_quiver_blank_mesh.png')

        player_textures = textures
    end

    if player_textures then
        player_api.set_textures(player, player_textures)
    end
end

---string split to characters
---@param str string
---@return string[] | nil
local function split(str)
    if #str > 0 then
        return str:sub(1, 1), split(str:sub(2))
    end
end

function XBows.show_damage_numbers(self, pos, damage, is_crit)
    if not pos or not self.settings.x_bows_show_damage_numbers then
        return
    end

    ---get damage texture
    local dmgstr = tostring(math.round(damage))
    local results = { split(dmgstr) }
    local texture = ''
    local dmg_nr_offset = 0

    for i, value in ipairs(results) do
        if i == 1 then
            texture = texture .. '[combine:' .. 7 * #results .. 'x' .. 9 * #results .. ':0,0=x_bows_dmg_' .. value .. '.png'
        else
            texture = texture .. ':' .. dmg_nr_offset .. ',0=x_bows_dmg_' .. value .. '.png'
        end

        dmg_nr_offset = dmg_nr_offset + 7
    end

    if texture and texture ~= '' then
        local size = 7

        if is_crit then
            size = 14
            texture = texture .. '^[colorize:#FF0000:255'
        else
            texture = texture .. '^[colorize:#FFFF00:127'
        end

        ---show damage texture
        minetest.add_particlespawner({
            amount = 1,
            time = 0.01,
            minpos = { x = pos.x, y = pos.y + 1, z = pos.z },
            maxpos = { x = pos.x, y = pos.y + 2, z = pos.z },
            minvel = { x = math.random(-1, 1), y = 5, z = math.random(-1, 1) },
            maxvel = { x = math.random(-1, 1), y = 5, z = math.random(-1, 1) },
            minacc = { x = math.random(-1, 1), y = -7, z = math.random(-1, 1) },
            maxacc = { x = math.random(-1, 1), y = -7, z = math.random(-1, 1) },
            minexptime = 2,
            maxexptime = 2,
            minsize = size,
            maxsize = size,
            texture = texture,
            collisiondetection = true,
            glow = 10
        })
    end
end
