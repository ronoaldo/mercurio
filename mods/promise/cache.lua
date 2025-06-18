
-- simple caching utility
function Promise.cache(seconds, fn)
	local micros = seconds * 1000 * 1000
	local cache_time = 0
	local value
	return function()
		local now = minetest.get_us_time()
		if not value or cache_time < (now - micros) then
			-- value does not exist or is expired
			value = {fn()}
			cache_time = now
		end
		return unpack(value)
	end
end
