
mtt.register("Promise.resolve", function(callback)
    Promise.resolve(5):next(function(result)
        assert(result == 5)
        callback()
    end)
end)

mtt.register("Promise.empty", function(callback)
    Promise.empty():next(function(result)
        assert(not result)
        callback()
    end)
end)

mtt.register("Promise.timeout", function(callback)
    Promise.timeout(0.1):next(function()
        callback("unexpected success")
    end):catch(function(err)
        assert(err == "timeout")
        callback()
    end)
end)

mtt.register("Promise.is_promise", function(callback)
    assert(Promise.is_promise(Promise.new()))
    assert(not Promise.is_promise(nil))
    assert(not Promise.is_promise(false))
    assert(not Promise.is_promise(true))
    assert(not Promise.is_promise({}))
    assert(not Promise.is_promise("xy"))
    callback()
end)

mtt.register("Promise.reject", function(callback)
    Promise.reject("nope")
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

mtt.register("Promise.handle_asyncify", function(callback)
    local fn = function(x, y)
        return x*y
    end

    local async_fn = Promise.handle_asyncify(fn)
    async_fn(5, 2):next(function(result)
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

mtt.register("Promise.asyncify (success)", function()
    local fn = Promise.asyncify(function(await,a,b,c)
        assert(type(await) == "function")
        assert(a == 1)
        assert(b == 2)
        assert(c == 3)
        await(Promise.after(0))
        return "ok"
    end)
    return fn(1,2,3):next(function(v)
        assert(v == "ok")
    end)
end)

mtt.register("Promise.asyncify (fail)", function(callback)
    local fn = Promise.asyncify(function()
        error("stuff", 0)
    end)
    fn():catch(function(err)
        assert(err == "stuff")
        callback()
    end)
end)

if minetest.get_modpath("fakelib") then
    mtt.register("Promise.on_punch_pos", function()
        local pos = vector.new(10,20,30)
        local p = Promise.on_punch_pos(pos)

        local node = { name="default:mese" }
        local puncher = fakelib.create_player()
        local pointed_thing = {}
        for _, fn in ipairs(minetest.registered_on_punchnodes) do
            fn(pos, node, puncher, pointed_thing)
        end

        return p:next(function(data)
            assert(vector.equals(data.pos, pos))
            assert(data.node == node)
            assert(data.puncher == puncher)
            assert(data.pointed_thing == pointed_thing)
        end)
    end)

    mtt.register("Promise.on_punch_pos (another pos)", function(callback)
        local pos = vector.new(10,20,30)
        local p = Promise.on_punch_pos(pos, 1)

        local node = { name="default:mese" }
        local puncher = fakelib.create_player()
        local pointed_thing = {}
        for _, fn in ipairs(minetest.registered_on_punchnodes) do
            fn(vector.add(pos, 1), node, puncher, pointed_thing)
        end

        p:catch(function()
            callback()
        end)
    end)

    mtt.register("Promise.on_punch_pos (timeout)", function(callback)
        local pos = vector.new(10,20,30)
        local p = Promise.on_punch_pos(pos, 1)

        p:catch(function()
            callback()
        end)
    end)

    mtt.register("Promise.on_punch_nodename", function()
        local pos = vector.new(10,20,30)
        local p = Promise.on_punch_nodename("default:mese")

        local node = { name="default:mese" }
        local puncher = fakelib.create_player()
        local pointed_thing = {}
        for _, fn in ipairs(minetest.registered_on_punchnodes) do
            fn(pos, node, puncher, pointed_thing)
        end

        return p:next(function(data)
            assert(vector.equals(data.pos, pos))
            assert(data.node == node)
            assert(data.puncher == puncher)
            assert(data.pointed_thing == pointed_thing)
        end)
    end)


    mtt.register("Promise.on_punch_playername", function()
        local pos = vector.new(10,20,30)
        local puncher = fakelib.create_player()
        local p = Promise.on_punch_playername(puncher:get_player_name())

        local node = { name="default:mese" }
        local pointed_thing = {}
        for _, fn in ipairs(minetest.registered_on_punchnodes) do
            fn(pos, node, puncher, pointed_thing)
        end

        return p:next(function(data)
            assert(vector.equals(data.pos, pos))
            assert(data.node == node)
            assert(data.puncher == puncher)
            assert(data.pointed_thing == pointed_thing)
        end)
    end)
end