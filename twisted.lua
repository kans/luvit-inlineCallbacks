local coroutine = require('coroutine')

local exports = {}

exports.__inline_callbacks = function(coro, cb, ...)
  local v = ...
  local previous = nil
  local no_errs = true

  while true do
    previous = v

    if coroutine.status(coro) == 'dead' then
      return cb(nil, previous)
    end

     -- yielded a function...
    if type(v) == 'function' then
       -- add a callback that will invoke coro and bail
      return v(function(...)
        -- we resume ourselves later
        return exports.__inline_callbacks(coro, cb, ...)
      end)
    end

    no_errs, v = coroutine.resume(coro, v)
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
