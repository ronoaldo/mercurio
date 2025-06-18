
function Promise.resolve(value)
    local p = Promise.new()
    p:resolve(value)
    return p
end
-- legacy
Promise.resolved = Promise.resolve

-- empty promise
function Promise.empty()
    return Promise.resolve(nil)
end

-- rejects with a timeout after a given delay
function Promise.timeout(delay)
    return Promise.after(delay, nil, "timeout")
end

function Promise.reject(value)
    local p = Promise.new()
    p:reject(value)
    return p
end
-- legacy
Promise.rejected = Promise.reject

function Promise.is_promise(p)
    return type(p) == "table" and p.is_promise
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

function Promise.asyncify(fn)
    return function(...)
        local args = {...}
        return Promise.async(function(await)
            table.insert(args, 1, await)
            return fn(unpack(args))
        end)
    end
end

function Promise.handle_asyncify(fn)
    return function(...)
        return Promise.handle_async(fn, ...)
    end
end

-- punchnode callbacks: hashes -> list<Promise>
local punchnode_pos_hashes = {}
local punchnode_nodenames = {}
local punchnode_playernames = {}

local function run_callbacks(callbacks, key, data)
    -- get entry
    local list = callbacks[key]
    if not list then
        -- nothing to do
        return
    end

    -- clear entry and resolve promises
    callbacks[key] = nil
    for _, p in ipairs(list) do
        p:resolve(data)
    end
end

local function add_callback(callbacks, key, p)
    local list = callbacks[key]
    if not list then
        list = {}
        callbacks[key] = list
    end
    table.insert(list, p)
end

-- cleanup playername callbacks
minetest.register_on_leaveplayer(function(player)
    local playername = player:get_player_name()
    punchnode_playernames[playername] = nil
end)

minetest.register_on_punchnode(function(pos, node, puncher, pointed_thing)
    local data = {
        pos = pos,
        node = node,
        puncher = puncher,
        pointed_thing = pointed_thing
    }

    -- pos callback
    run_callbacks(punchnode_pos_hashes, minetest.hash_node_position(pos), data)

    -- nodename callback
    if node and node.name then
        run_callbacks(punchnode_nodenames, node.name, data)
    end

    -- playername callbacks
    if puncher then
        run_callbacks(punchnode_playernames, puncher:get_player_name(), data)
    end
end)

function Promise.on_punch_pos(pos, timeout)
    local p = Promise.new()
    add_callback(punchnode_pos_hashes, minetest.hash_node_position(pos), p)
    return Promise.race(p, Promise.timeout(timeout or 5))
end

function Promise.on_punch_nodename(nodename, timeout)
    local p = Promise.new()
    add_callback(punchnode_nodenames, nodename, p)
    return Promise.race(p, Promise.timeout(timeout or 5))
end

function Promise.on_punch_playername(playername, timeout)
    local p = Promise.new()
    add_callback(punchnode_playernames, playername, p)
    return Promise.race(p, Promise.timeout(timeout or 5))
end