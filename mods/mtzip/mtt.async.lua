-- mapgen callback for tests in the async env
minetest.register_on_generated(function(vmanip)
    assert(vmanip)
    assert(mtzip)
    assert(type(mtzip.zip) == "function")
    assert(type(mtzip.unzip) == "function")
end)