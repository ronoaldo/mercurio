
local function get_await(step)
    return function(p)
        assert(coroutine.running(), "running inside a Promise.async() call")
        local result = nil
        local err = nil

        -- add success/error/done callbacks
        p:next(function(...)
            result = {...}
        end):catch(function(e)
            err = e
        end):finally(step)

        -- wait until the promise settles
        coroutine.yield()

        -- check if error or success
        if err then
            return nil, err
        else
            return unpack(result)
        end
    end
end

function Promise.async(fn)
    local t = coroutine.create(fn)
    local p = Promise.new()

    local step = nil
    local result = nil
    local cont = nil
    local _ = nil
    step = function()
        if coroutine.status(t) == "suspended" then
            local await = get_await(step)
            cont, result = coroutine.resume(t, await)
            if not cont then
                -- error in first async() level
                p:reject(result)
                return
            end
        end

        if coroutine.status(t) == "dead" then
            -- async function exited
            p:resolve(result)
        end
    end
    step()

    return p
end
