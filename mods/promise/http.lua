
local function response_wrapper(res)
    return {
        code = res.code,
        json = function()
            return Promise.resolved(minetest.parse_json(res.data))
        end,
        text = function()
            return Promise.resolved(res.data)
        end
    }
end

function Promise.http(http, url, opts)
    assert(http, "http instance is nil")
    assert(url, "no url given")

    -- defaults
    opts = opts or {}

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

        http.fetch({
            url = url,
            extra_headers = extra_headers,
            timeout = opts.timeout or 10,
            method = opts.method or "GET",
            data = data
        }, function(res)
            if res.succeeded then
                resolve(response_wrapper(res))
            else
                reject(res)
            end
        end)
    end)
end
