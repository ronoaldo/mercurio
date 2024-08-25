
mtt.register("simple promise", function(callback)
    Promise.new(function(resolve)
        resolve(5)
    end):next(function(result)
        assert(result == 5)
        callback()
    end)
end)

mtt.register("simple promise (resolved with false)", function(callback)
    Promise.new(function(resolve)
        resolve(false)
    end):next(function(result)
        assert(result == false)
        callback()
    end)
end)

mtt.register("simple promise (resolved with nil, chained with nil-result)", function(callback)
    Promise.new(function(resolve)
        resolve(nil)
    end):next(function(result)
        assert(result == nil)
    end):next(function(result)
        assert(result == nil)
        return Promise.resolved()
    end):next(function(result)
        assert(result == nil)
        callback()
    end)
end)

mtt.register("returned promise", function(callback)
    local p1 = Promise.new(function(resolve)
        resolve(5)
    end)

    local p2 = Promise.new(function(resolve)
        resolve(10)
    end)

    p1:next(function(result)
        assert(result == 5)
        return p2
    end):next(function(result)
        assert(result == 10)
        callback()
    end)
end)

mtt.register("error handling", function(callback)
    Promise.new(function(_, reject)
        reject("nope")
    end):catch(function(err)
        assert(err == "nope")
        callback()
    end)
end)

mtt.register("error handling 2", function(callback)
    Promise.rejected("nope"):catch(function(err)
        -- "nope"
        assert(err)
    end)

    Promise.rejected("nope"):next(function() end):catch(function(err)
        -- "/home/user/.minetest/mods/promise/promise.lua:13: nope"
        assert(err)
        callback()
    end)
end)

mtt.register("Promise.all", function(callback)
    local p1 = Promise.new(function(resolve)
        resolve(5)
    end)

    local p2 = Promise.new(function(resolve)
        resolve(10)
    end)

    Promise.all(p1, p2):next(function(values)
        assert(#values == 2)
        assert(values[1] == 5)
        assert(values[2] == 10)
        callback()
    end):catch(function(err)
        callback(err)
    end)
end)

mtt.register("Promise.race", function(callback)
    local p1 = Promise.new(function(resolve)
        resolve(5)
    end)

    local p2 = Promise.new()

    Promise.race(p1, p2):next(function(v)
        assert(v == 5)
        callback()
    end)
end)

mtt.register("Promise control logic", function(callback)
    Promise.new(function(resolve)
        resolve(math.random())
    end):next(function(r)
        if r < 0.5 then
            -- branch 1
            return Promise.new(function(resolve)
                resolve(math.random())
            end)
        else
            -- branch 2
            return Promise.new(function(resolve)
                resolve(math.random())
            end)
        end
    end):next(function()
        callback()
    end)
end)