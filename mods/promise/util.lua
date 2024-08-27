
function Promise.resolved(value)
    local p = Promise.new()
    p:resolve(value)
    return p
end

-- empty promise
function Promise.empty()
    return Promise.resolved(nil)
end

function Promise.rejected(value)
    local p = Promise.new()
    p:reject(value)
    return p
end

function Promise.after(delay, value, err)
    return Promise.new(function(resolve, reject)
        minetest.after(delay, function()
            if err then
                reject(err)
            else
                resolve(value)
            end
        end)
    end)
end

function Promise.emerge_area(pos1, pos2)
    pos2 = pos2 or pos1
    return Promise.new(function(resolve)
        minetest.emerge_area(pos1, pos2, function(_, _, calls_remaining)
            if calls_remaining == 0 then
                resolve()
            end
        end)
    end)
end

function Promise.handle_async(fn, ...)
    local args = {...}
    return Promise.new(function(resolve)
        if minetest.handle_async then
            -- use threaded async env
            minetest.handle_async(fn, resolve, unpack(args))
        else
            -- fall back to unthreaded async call
            resolve(fn(unpack(args)))
        end
    end)
end

function Promise.dynamic_add_media(options)
    return Promise.new(function(resolve, reject)
        local success = minetest.dynamic_add_media(options, resolve)
        if not success then
            reject()
        end
    end)
end

local mods_loaded_promise = Promise.new()
function Promise.mods_loaded()
    return mods_loaded_promise
end

minetest.register_on_mods_loaded(function()
    mods_loaded_promise:resolve()
end)

-- pos-hash -> list<Promise>
local punchnode_promises = {}

minetest.register_on_punchnode(function(pos, node, puncher, pointed_thing)
    local hash = minetest.hash_node_position(pos)

    -- get and clear list for this pos
    local list = punchnode_promises[hash]
    punchnode_promises[hash] = nil

    -- execute promise resolve
    if list then
        for _, p in ipairs(list) do
            p:resolve({
                pos = pos,
                node = node,
                puncher = puncher,
                pointed_thing = pointed_thing
            })
        end
    end
end)

function Promise.on_punch(pos, timeout)
    timeout = timeout or 5

    local p = Promise.new()
    local pt = Promise.after(timeout, "timeout")

    local hash = minetest.hash_node_position(pos)

    -- create and/or append
    local list = punchnode_promises[hash]
    if not list then
        list = {}
        punchnode_promises[hash] = list
    end
    table.insert(list, p)

    return Promise.new(function(resolve, reject)
        Promise.race(p, pt):next(function(data)
            if data == "timeout" then
                reject("timeout")
            else
                resolve(data)
            end
        end)
    end)
end