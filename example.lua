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
  local f = function(arg, cb)
    p('calling in ' .. res .. ' ms ')
    p("I'm an arg: " .. arg)
    timer.setTimeout(res, function() return cb(nil, res+2) end)
  end
  err, res = yield(f, 'extra arg')
  p(err, res)
  return err, res
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