
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
            if res.succeeded and res.code >= 200 and res.code < 400 then
                if opts.json and res.data and #res.data > 0 then
                    resolve(minetest.parse_json(res.data))
                else
                    resolve(res.data)
                end
            else
                reject({
                    code = res.code or 0,
                    data = res.data
                })
            end
        end)
    end)
end
