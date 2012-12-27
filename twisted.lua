local coroutine = require('coroutine')


-- unfortunately, we need to call ourselves so we can't declare local
__inlined_callbacks = function(coro, cb, ...)
  local v = ...
  local previous = nil
  local no_errs = true

  while true do
    previous = v

    if coroutine.status(coro) == 'dead' then
      return cb(nil, previous)
    end

    no_errs, v = coroutine.resume(coro, v)
    -- donegoofed?
    if no_errs ~= true then
      return cb(v)
    end

    -- yielded a function...
    if type(v) == 'function' then
       -- shove in a cb and call it (as a tail call just in case)
      return v(function(...)
        -- we resume ourselves later
        return __inlined_callbacks(coro, cb, ...)
      end)
    end

  end
end

local inlined_callbacks = function(f)
  local coro = coroutine.create(f)
  return function(cb, ...)
    return __inlined_callbacks(coro, cb, ...)
  end
end

return {
  inlined_callbacks=inlined_callbacks,
  yield = coroutine.yield
}