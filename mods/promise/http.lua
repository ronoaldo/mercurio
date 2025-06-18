local http_debug = minetest.settings:get_bool("Promise.http_debug", false)

local function response_wrapper(res)
    return {
        code = res.code,
        json = function()
            return Promise.resolve(minetest.parse_json(res.data))
        end,
        text = function()
            return Promise.resolve(res.data)
        end
    }
end

Promise.HTTP_TIMEOUT = "http timeout"

function Promise.http(http, url, opts)
    assert(http, "http instance is nil")
    assert(url, "no url given")

    -- defaults
    opts = opts or {}
    opts.timeout = opts.timeout or 10
    opts.method = opts.method or "GET"

    return Promise.new(function(resolve, reject)
        local extra_headers = {}

        local data = opts.data
        if type(data) == "table" then
            -- serialize as json
            data = minetest.write_json(data)
            table.insert(extra_headers, "Content-Type: application/json")
        end

        for _, h in ipairs(opts.headers or {}) do
            table.insert(extra_headers, h)
        end

        if http_debug then
            minetest.log("action", "[Promise] fetch request: " .. dump({
                method = opts.method,
                timeout = opts.timeout,
                data = data,
                extra_headers = extra_headers,
                url = url
            }))
        end
        http.fetch({
            url = url,
            extra_headers = extra_headers,
            timeout = opts.timeout,
            method = opts.method,
            data = data
        }, function(res)
            if http_debug then
                minetest.log("action", "[Promise] fetch response: " .. dump({
                    url = url,
                    code = res.code,
                    data = res.data
                }))
            end
            if res.succeeded then
                resolve(response_wrapper(res))
            elseif res.code == 0 then
                -- timeout (most likely)
                reject(Promise.HTTP_TIMEOUT)
            else
                reject(res)
            end
        end)
    end)
end

function Promise.json(http, url, opts)
    return Promise.http(http, url, opts):next(function(res)
        if res.code == 200 then
            return res.json()
        elseif res.code == 204 or res.code == 404 then
            return nil
        else
            return Promise.reject("unexpected status-code: " .. res.code)
        end
    end)
end