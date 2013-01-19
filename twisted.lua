local coroutine = require('coroutine')
local table = require('table')

local exports = {}

local _unpack = function(...)
  local args = {...}
  local x = table.remove(args, 1)
  local next_args = table.remove(args, 1)
  return x, next_args, args
end

exports.__inline_callbacks = function(coro, cb, ...)
  local v = ...
  local previous = nil
  local no_errs = true
  local extra_args = {}
  while true do
    previous = v

    if coroutine.status(coro) == 'dead' then
      -- todo- pcall this and shove the result into the second argument or return an error or something
      return cb(unpack(previous))
    end

     -- yielded a function...
    if type(v) == 'function' then
       -- add a callback that will invoke coro
      local f = function(...)
        -- we resume ourselves later
        return exports.__inline_callbacks(coro, cb, ...)
      end
      -- support colon notation implicitly and other extra args
      table.insert(extra_args, f)
      return v(unpack(extra_args))
    end

    no_errs, v, extra_args = _unpack(coroutine.resume(coro, v))

    -- donegoofed?
    if no_errs ~= true then
      return cb(v)
    end

  end
end

exports.inline_callbacks = function(f)
  local coro = coroutine.create(f)
  return function(cb, ...)
    return exports.__inline_callbacks(coro, cb, ...)
  end
end

exports.yield = coroutine.yield

return exports