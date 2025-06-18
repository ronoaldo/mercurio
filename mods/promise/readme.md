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
assert(p.is_promise == true) -- field value
assert(Promise.is_promise(p)) -- function

p:then(function(result)
    -- TODO: handle the result
end):catch(function(err)
    -- TODO: handle the error
end)

p:finally(function()
    -- always called after error or success
    -- TODO: handle cleanup/common things here
end)
```

Alternatively:
```lua
-- promise without callback
local p = Promise.new()
-- later on: resolve from outside
p:resolve(result)
```

**NOTE:** pass a `0` to the `error` function if you want to evaluate the error directly:

```lua
Promise.new(function()
    error("nope", 0)
end):catch(function(err)
    assert(err == "nope")
end)
```

Reference: https://www.lua.org/manual/5.3/manual.html#pdf-error

## `Promise.resolve(value)`

Returns an already resolved promise with given value

## `Promise.reject(err)`

Returns an already rejected promise with given error

## `Promise.empty()`

Returns an already resolved promise with a `nil` value

## `Promise.all(...)`

Wait for all promises to finish

Example:
```lua
local p1 = Promise.resolve(5)
local p2 = Promise.resolve(10)

Promise.all(p1, p2):next(function(values)
    assert(#values == 2)
    assert(values[1] == 5)
    assert(values[2] == 10)
end)
```

* Javascript version: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/all

## `Promise.race(...)`

Wait for the first promise to finish

Example:
```lua
local p1 = Promise.resolve(5)
local p2 = Promise.new()

Promise.race(p1, p2):next(function(v)
    assert(v == 5)
end)
```

The `race()` function can be used for timeouts, for example:

```lua
local p = Promise.new() -- never resolves
local to = Promise.timeout(5) -- rejects after 5 seconds

Promise.race(p, to):next(function(v)
    -- process "v"
end):catch(function(err)
    -- timeout reached (err == "timeout")
end)
```

* Javascript version: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/race

## `Promise.any(...)`

Returns the first fulfilled promise or rejects if all promises reject.

* Javascript version: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/any

## `Promise.after(delay, value?, err?)`

Returns a delayed promise that resolves to given value or error

## `Promise.timeout(delay)`

Returns a promise that rejects with "timeout" after the given delay. Useful in comination with `Promise.race()`

## `Promise.emerge_area(pos1, pos2?)`

Emerges the given area and resolves afterwards

## `Promise.formspec(playername, formspec, callback?)`

Formspec shorthand / util

Example:
```lua
Promise.formspec(playername, "size[2,2]button_exit[0,0;2,2;mybutton;label]")
:next(function(fields)
    -- formspec closed
    assert(fields.mybutton == true)
end)
```

**NOTE**: the promise only resolves if the player exits the formspec (with a `quit="true"` value, a default in exit_buttons)

Example with optional scroll/dropdown callbacks:
```lua
local callback = function(fields)
    -- TODO: handle CHG, and other "non-quit" events here
end

Promise.formspec(playername, "size[2,2]button_exit[0,0;2,2;mybutton;label]", callback)
:next(function(fields)
    -- formspec closed
    assert(fields.mybutton == true)
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

Rejects with `Promise.HTTP_TIMEOUT` in case of timeouts (or connection errors)

Examples:
```lua
local http = minetest.request_http_api()

-- call chuck norris api: https://api.chucknorris.io/ and expect json-response
Promise.http(http, "https://api.chucknorris.io/jokes/random"):next(function(res)
    return res.json()
end):next(function(joke)
    assert(type(joke.value) == "string")
end):catch(function(e)
    -- conection refused or timed out:
    -- e == Promise.HTTP_TIMEOUT
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

HTTP Status code handling:

* `200`: resolves with a parsed json object
* `204` or `404`: resolves with a `nil` value
* Everything else: rejects with `unexpected status-code`

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

## `Promise.joinplayer(playername, timeout?)`

Resolves with the player object when the player joins (defaults to a 5 second timeout)

## `Promise.leaveplayer(playername, timeout?)`

Resolves when the player leaves (does not resolve with a value, unlike `joinplayer`)

## `Promise.asyncify(fn)`

Turns a normal function into an async function. The first parameter will be the `await` function.

Example:
```lua
-- normal function
local fn = function(await,a,b,c)
    assert(type(await) == "function")
    assert(a == 1)
    assert(b == 2)
    assert(c == 3)
    await(Promise.after(0))
    return "ok"
end

-- async function
local async_fn = Promise.asyncify(fn)

-- invoke with params
local p = async_fn(1,2,3)

-- use as a promise
p:next(function(v)
    assert(v == "ok")
end)
```

## `Promise.handle_asyncify(fn)`

Returns the function wrapped into `Promise.handle_async`

Example:

```lua
local fn = function(a,b)
    return a * b -- something cpu-intensive
end

local async_fn = Promise.handle_asyncify(fn)

async_fn(3,4):next(function(v)
    assert(v == 12)
end)
```

## `Promise.cache(seconds, fn)`

Simple caching utility

Example:
```lua
local somethingExpensive()
    return 42
end

-- cached the result for 5 seconds
local cachedFn = Promise.cache(5, somethingExpensive)

-- function result is cached for 5 seconds
local n = cachedFn()
local n2 = cachedFn()
```

## `Promise.on_punch_pos(pos, timeout?)`

Resolves when the node at `pos` is hit or throws an error if the timeout (in seconds, default: 5) is reached.
Resolving value:
```lua
{
    pos = Vector,
    node = {name="", ...},
    puncher = PlayerObj,
    pointed_thing = { ... }
}
```

## `Promise.on_punch_nodename(nodename, timeout?)`

Resolves when the node with name `nodename` is hit or throws an error if the timeout (in seconds, default: 5) is reached.
Resolving value is the same as `Promise.on_punch_pos`

## `Promise.on_punch_playername(playername, timeout?)`

Resolves when a node is hit by the player with name `playername` or throws an error if the timeout (in seconds, default: 5) is reached.
Resolving value is the same as `Promise.on_punch_pos`

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

## `Promise.register_chatcommand(cmd, def)`

Chatcommand helper with wrappers for success and error.
Shows messages after the returned promise fails or succeeds and prints the error or success-value if the type is "string"

Usage:

```lua
Promise.register_chatcommand("something", {
    description = "Does something",
    func = function(name)
        return Promise.new(function(resolve, reject)
            resolve("processed 123 items")
            -- or: reject("something went wrong")
        end)
    end,
    handle_success = false, -- optional, if false: disable success message
    handle_error = false -- optional, if false: disable error message
})
```

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
    local data, err = await(Promise.reject("nope"))
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
