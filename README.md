luvit-inlineCallbacks
=====================

This is a basic implemention of Twisted's inlineCallbacks for Luvit.  Instead of using Deferreds, we are forced to use functions to signal the completion of an aync event.

A callback will automagically be supplied if you yield a function which will resume the coroutine when it is fired.  twisted.inlined_callbacks takes a function as its only argument and will return a function which will take a callback as its first argument.




###Examples

```lua
#!/usr/bin/env luvit

local timer = require('timer')
local coroutine = require('coroutine')

local lic = require('./init')
-- very thin wrapper around coroutine.yield
local yield = lic.yield

local test = lic.inline_callbacks(function()
  local res = 0
  -- sync using wrapper
  res = yield(res+1)
  -- sync if you like blue highlighted text
  res = coroutine.yield(res+1)

  -- coroutines are first class citizens in lua
  res = (function() return yield(res+1) end)()

  -- and async
  local f = function(a, cb)
    timer.setTimeout(0, cb, a+1)
  end

  res = yield(f, res)

  -- async with args is tricky cause lua is stupid
  local f2 = function(a, b, cb)
    return cb(a+1)
  end
  -- you must pass in the sentinel value if the final arg can be nil
  --because there is no way to tell it exists otherwise
  res = yield(f2, res, nil, lic.SENTINEL)
  return {nil, res}
end)

local cb = function(err, res)
  if err then
    return p('there was an err', err)
  end
  p('the result is: ', res)
end

test(cb)


local failure = lic.inline_callbacks(function()
  -- throwing an error with return the err to our cb function
  res = yield(2)
  error('oh shit')
end)

failure(cb)
```

###... and the results

```bash
$ luvit ./example.lua
"there was an err"  "/racker/luvit-inlineCallbacks/example.lua:50: oh shit"
"the result is: " 5
```

Notice that no magic takes place (ie, the results are written out of order).
