luvit-inlineCallbacks
=====================

This is a basic implemention of Twisted's inlineCallbacks for Luvit.  Instead of using Deferreds, we are forced to use functions to signal the completion of an aync event.  

A callback will automagically be supplied if you yield a function which will resume the coroutine when it is fired.  twisted.inlined_callbacks takes a function as its only argument and will return a function which will take a callback as its first argument.




###Examples

```lua
local http = require('http')
local timer = require('timer')
local coroutine = require('coroutine')

local twisted = require('./twisted')
-- very thin wrapper around coroutine.yield
local yield = twisted.yield


local test = twisted.inline_callbacks(function()
  local res = 2
  -- sync using wrapper
  res = yield(res+2)
  -- sync if you like blue highlighted text
  res = coroutine.yield(res+2)

  -- coroutines are first class citizens in lua
  res = (function() return yield(res+2) end)()

  -- and async
  local f = function(cb)
    p('calling in ' .. res .. ' ms')
    timer.setTimeout(res, cb, {nil, res+2})
  end
  return yield(f)
end)

local cb = function(err, res)
  if err then
    return print('there was an err', err)
  end
  print('the result is: ', res)
end

test(cb)


local failure = twisted.inline_callbacks(function()
  -- throwing an error with return the err to our cb function
  res = yield(2)
  error('oh shit')
end)

failure(cb)
```

###... and the results

```bash
$ luvit ./example.lua 
"calling in 8 ms"
there was an err  ~/luvit-inlineCallbacks/example.lua:41: oh shit
the result is: 	10
```

Notice that no magic takes place (ie, the results are written out of order).
