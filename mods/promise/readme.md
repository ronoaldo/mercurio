promise library for minetest

![](https://github.com/mt-mods/promise/workflows/luacheck/badge.svg)
![](https://github.com/mt-mods/promise/workflows/test/badge.svg)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](license.txt)
[![Download](https://img.shields.io/badge/Download-ContentDB-blue.svg)](https://content.minetest.net/packages/mt-mods/promise)
[![Coverage Status](https://coveralls.io/repos/github/mt-mods/promise/badge.svg?branch=master)](https://coveralls.io/github/mt-mods/promise?branch=master)

# Overview

Features:
* Async event handling
* Utilities for formspec, emerge_area, handle_async, http and minetest.after
* async/await helpers (js example [here](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/async_function))

# Examples


Simple promise and handling:
```lua
-- create promise
local p = Promise.new(function(resolve, reject)
    -- async operation here, mocked for this example
    minetest.after(1, function()
        resolve("result-from-a-long-operation")
    end)
end)

-- handle the result later
p:next(function(result)
    assert(result == "result-from-a-long-operation")
end)
```

Chained async operations:
```lua
Promise.emerge_area(pos1, pos2):next(function()
    -- delay a second before next operation
    return Promise.after(1)
end):next(function()
    -- called after emerge + 1 second delay
end)
```

Wait for multiple http requests:
```lua
local http = minetest.request_http_api()
local toJson = function(res) return res.json() end

local p1 = Promise.http(http, "http://localhost/x"):next(toJson)
local p2 = Promise.http(http, "http://localhost/y"):next(toJson)

Promise.all(p1, p2):next(function(values)
    local x = values[1]
    local y = values[2]
end)
```

Wait for multiple async workers:
```lua
local fn = function(x,y)
    return x*y
end

local p1 = Promise.handle_async(fn, 1, 1)
local p2 = Promise.handle_async(fn, 2, 2)
local p3 = Promise.handle_async(fn, 10, 2)

Promise.all(p1, p2, p3):next(function(values)
    assert(values[1] == 1)
    assert(values[2] == 4)
    assert(values[3] == 20)
end)
```

# Api

## `Promise.new(callback)`

Creates a new promise

Example:
```lua
local p = Promise.new(function(resolve, reject)
    -- TODO: async operation and resolve(value) or reject(err)
end)

-- test if the value is a promise
assert(p.is_promise == true)

p:then(function(result)
    -- TODO: handle the result
end):catch(function(err)
    -- TODO: handle the error
end)
```

Alternatively:
```lua
-- promise without callback
local p = Promise.new()
-- later on: resolve from outside
p:resolve(result)
```

## `Promise.resolved(value)`

Returns an already resolved promise with given value

## `Promise.rejected(err)`

Returns an already rejected promise with given error

## `Promise.empty()`

Returns an already resolved promise with a `nil` value

## `Promise.all(...)`

Wait for all promises to finish

Example:
```lua
local p1 = Promise.resolved(5)
local p2 = Promise.resolved(10)

Promise.all(p1, p2):next(function(values)
    assert(#values == 2)
    assert(values[1] == 5)
    assert(values[2] == 10)
end)
```

## `Promise.race(...)`

Wait for the first promise to finish

Example:
```lua
local p1 = Promise.resolved(5)
local p2 = Promise.new()

Promise.race(p1, p2):next(function(v)
    assert(v == 5)
end)
```

**NOTE**: errors don't get propagated when calling `race` only successful results

## `Promise.after(delay, value?, err?)`

Returns a delayed promise that resolves to given value or error

## `Promise.emerge_area(pos1, pos2?)`

Emerges the given area and resolves afterwards

## `Promise.formspec(player, formspec, callback?)`

Formspec shorthand / util

Example:
```lua
Promise.formspec(player, "size[2,2]button_exit[0,0;2,2;mybutton;label]")
:next(function(data)
    -- formspec closed
    assert(data.player:get_player_name())
    assert(data.fields.mybutton == true)
end)
```

**NOTE**: the promise only resolves if the player exits the formspec (with a `quit="true"` value, a default in exit_buttons)

Example with optional scroll/dropdown callbacks:
```lua
local callback = function(fields)
    -- TODO: handle CHG, and other "non-quit" events here
end

Promise.formspec(player, "size[2,2]button_exit[0,0;2,2;mybutton;label]", callback)
:next(function(data)
    -- formspec closed
    assert(data.player:get_player_name())
    assert(data.fields.mybutton == true)
end)
```

## `Promise.handle_async(fn, args...)`

Executes the function `fn` in the async environment with given arguments

**NOTE:** This falls back to a simple function-call if the `minetest.handle_async` function isn't available.

## `Promise.http(http, url, opts?)`

Http query

* `http` The http instance returned from `minetest.request_http_api()`
* `url` The url to call
* `opts` Table with options:
  * `method` The http method (default: "GET")
  * `timeout` Timeout in seconds (default: 10)
  * `data` Data to transfer, serialized as json if type is `table`
  * `headers` table of additional headers

Examples:
```lua
local http = minetest.request_http_api()

-- call chuck norris api: https://api.chucknorris.io/ and expect json-response
Promise.http(http, "https://api.chucknorris.io/jokes/random"):next(function(res)
    return res.json()
end):next(function(joke)
    assert(type(joke.value) == "string")
end)

-- post json-payload with 10 second timeout and expect raw string-response (or error)
Promise.http(http, "http://localhost/stuff", { method = "POST", timeout = 10, data = { x=123 } }):next(function(res)
    return res.text()
end):next(function(result)
    assert(result)
end):catch(function(res)
    -- something went wrong with the http call itself (no response)
    -- dump the raw http response (res.code, res.timeout)
    print(dump(res))
end)
```

## `Promise.json(http, url, opts?)`

Helper function for `Promise.http` that parses a json response

Example:
```lua
-- call chuck norris api: https://api.chucknorris.io/ and expect json-response
Promise.json(http, "https://api.chucknorris.io/jokes/random"):next(function(joke)
    assert(type(joke.value) == "string")
end, function(err)
    -- request not successful or response-status not 200
    print("something went wrong while calling the api: " .. err)
end)
```

## `Promise.mods_loaded()`

Resolved on mods loaded (`minetest.register_on_mods_loaded`)

Example:
```lua
Promise.mods_loaded():next(function()
    -- stuff that runs when all mods are loaded
end)
```

## `Promise.on_punch(pos, timeout?)`

Resolves when the node at `pos` is hit or throws an error if the timeout (in seconds, default: 5) is reached.

## `Promise.dynamic_add_media(options)`

Dynamic media push

Example:
```lua
Promise.dynamic_add_media({ filepath = "world/image.png", to_player = "singleplayer" })
:next(function(name)
    -- player callback
end):catch(function()
    -- error handling
end)
```

**NOTE**: experimental, only works if the `to_player` property is set

# async/await with `Promise.async`

Similar to [javascripts](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/async_function) implementation async/await can be used in lua too with the help of [coroutines](https://www.lua.org/pil/9.1.html)

Example: fetch a joke with async/await
```lua
Promise.async(function(await)
    local joke = await(Promise.json(http, "https://api.chucknorris.io/jokes/random"))
    assert(type(joke.value) == "string")
    -- do stuff here with the joke
end)
```

Example: sleep for a few seconds
```lua
Promise.async(function(await)
    await(Promise.after(5))
    -- 5 seconds passed
end)
```

`Promise.async` returns a Promise that can be used with `:next` or `await` in another async function, for example:

```lua
Promise.async(function(await)
    local data = await(Promise.json(http, "https://my-api"))
    return data.value * 200 -- "value" is a number
end):next(function(n)
    -- n is the result of the multiplication in the previous function
end)
```

Error handling:
```lua
Promise.async(function(await)
    -- second result from await is the error if rejected
    local data, err = await(Promise.rejected("nope"))
    assert(err == "nope")
end)
```

Error handling with http/json:
```lua
Promise.async(function(await)
    local result, err = await(Promise.json(http, "https://httpbin.org/status/500"))
    assert(err == "unexpected status-code: 500")
end)
```


# License

* Code: MIT (adapted from https://github.com/Billiam/promise.lua)

<details>

![Yo dawg](yo.jpg)
</details>