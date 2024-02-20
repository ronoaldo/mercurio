
function Promise.resolved(value)
    local p = Promise.new()
    p:resolve(value)
    return p
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
