
mtt.register("Promise.cache", function()
	local i = 0
	local c = Promise.cache(0.2, function()
		i = i + 1
		return i
	end)

	return Promise.async(function(await)
		local v = c()
		assert(v == 1)
		assert(c() == 1)

		await(Promise.after(0.3))
		assert(c() == 2)
	end)
end)
