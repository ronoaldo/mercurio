local util = {}

-- helper functions
function util.facedir_to_look_horizontal(dir)
	if dir == 0 then
		return 0
	elseif dir == 1 then
		return math.pi * 3/2
	elseif dir == 2 then
		return math.pi
	elseif dir == 3 then
		return math.pi / 2
	else
		return nil
	end
end

function util.vector_rotate_xz(vec, angle)
	local a = angle - (math.pi * 3/2)
	return {
		x = (vec.z * math.sin(a)) - (vec.x * math.cos(a)),
		y = vec.y,
		z = (vec.z * math.cos(a)) - (vec.x * math.sin(a))
	}
end

emote.util = util
