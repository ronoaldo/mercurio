
mtt.register("Promise.resolved", function(callback)
    Promise.resolved(5):next(function(result)
        assert(result == 5)
        callback()
    end)
end)

mtt.register("Promise.rejected", function(callback)
    Promise.rejected("nope")
    :catch(function(err)
        assert(err == "nope")
        callback()
    end)
end)

mtt.register("Promise.after", function(callback)
    Promise.after(0.5, 100)
    :next(function(v)
        assert(v == 100)
        callback()
    end)
end)

mtt.register("Promise.after (failed)", function(callback)
    Promise.after(0.5, nil, "err")
    :catch(function(v)
        assert(v == "err")
        callback()
    end)
end)

mtt.register("Promise.after (no value)", function(callback)
    Promise.after(0.5)
    :next(function(v)
        assert(v == nil)
        callback()
    end)
end)

mtt.register("Promise.emerge_area", function(callback)
    Promise.emerge_area({x=0, y=0, z=0}, {x=0, y=0, z=0})
    :next(function(v)
        assert(v == nil)
        callback()
    end)
end)

mtt.register("Promise.handle_async", function(callback)
    local fn = function(x, y)
        return x*y
    end
    Promise.handle_async(fn, 5, 2):next(function(result)
        assert(result == 10)
        callback()
    end)
end)

mtt.register("Promise.handle_async (no params)", function(callback)
    local fn = function()
        return 42
    end
    Promise.handle_async(fn):next(function(result)
        assert(result == 42)
        callback()
    end)
end)

mtt.register("Promise.mods_loaded", function()
    return Promise.mods_loaded()
end)