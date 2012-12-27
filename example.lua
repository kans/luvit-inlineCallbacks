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

  -- and async
  local f = function(cb)
    p('calling in ' .. res .. ' ms')
    timer.setTimeout(res, cb, res+2)
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