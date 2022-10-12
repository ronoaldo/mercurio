
-- entity for locked emotes (attached to nodes, etc)
local attacher = {
	description = "Attachment entity for emotes",
	physical = false,
	visual = "upright_sprite",
	visual_size = {x = 1/16, y = 1/16},
	spritediv = {x = 1/16, y = 1/16},
	collisionbox = {-1/16, -1/16, -1/16, 1/16, 1/16, 1/16},
	textures = {"emote_blank.png"},
	static_save = false,
	init = function(self, player)
		self.player = player
	end,
}

function attacher:on_step()
	if not minetest.is_player(self.player) then
		self.object:remove()
		return
	end

	local ctrl = self.player:get_player_control()
	if ctrl and ctrl.jump then
		self:detach()
	end
end

function attacher:detach()
	emote.attached[self.player] = nil

	if not minetest.is_player(self.player) then
		return
	end

	self.player:set_detach()
	self.object:remove()

	emote.stop(self.player)
end

minetest.register_entity("emote:attacher", attacher)
