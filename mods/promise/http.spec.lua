local http = ...

mtt.register("Promise.http GET", function(callback)
    Promise.http(http, "https://api.chucknorris.io/jokes/random", { json = true }):next(function(joke)
        assert(type(joke.value) == "string")
        callback()
    end):catch(function(e)
        callback(e)
    end)
end)

mtt.register("Promise.http POST", function(callback)
    local opts = { json = true, method = "POST", data = { x=1 }}
    Promise.http(http, "https://postman-echo.com/post", opts):next(function(data)
        assert(type(data) == "table")
        assert(data.json and data.json.x == 1)
        callback()
    end):catch(function(e)
        callback(e)
    end)
end)