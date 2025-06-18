

-- resolve when all promises complete
function Promise.all(...)
    local promises = {...}
    local results = {}
    local errors = {}
    local failed = false
    local remaining = #promises

    local promise = Promise.new()

    local check_finished = function()
        if remaining > 0 then
            return
        end
        if failed then
            promise:reject(errors)
        else
            promise:resolve(results)
        end
    end

    for i,p in ipairs(promises) do
        p:next(
            function(value)
                results[i] = value
                remaining = remaining - 1
                check_finished()
            end,
            function(err)
                errors[i] = err
                remaining = remaining - 1
                failed = true
                check_finished()
            end
        )
    end

    check_finished()

    return promise
end

-- resolve with first promise to settle (rejected or fulfilled)
function Promise.race(...)
    local promises = {...}
    local promise = Promise.new()

    for _,p in ipairs(promises) do
        p:next(function(value)
            promise:resolve(value)
        end):catch(function(err)
            promise:reject(err)
        end)
    end

    return promise
end

-- resolve with the first fulfilled or all rejected
function Promise.any(...)
    local promises = {...}
    local promise = Promise.new()
    local errors = {}
    local error_count = 0

    for i,p in ipairs(promises) do
        p:next(function(v)
            promise:resolve(v)
        end):catch(function(err)
            errors[i] = err
            error_count = error_count + 1
            if error_count == #promises then
                -- all failed
                promise:reject(errors)
            end
        end)
    end

    return promise
end

