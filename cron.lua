-----------------------------------------------------------------------------------------------------------------------
-- cron.lua - v1.0 (2011-04)
-- Enrique García Cota - enrique.garcia.cota [AT] gmail [DOT] com
-- time-related functions for Lua.
-- inspired by Javascript's setTimeout and setInterval
-----------------------------------------------------------------------------------------------------------------------


local entries = {}

local TimedEntry = {}

function TimedEntry:new(time, callback, ...)
  return setmetatable( {
      time = time,
      callback = callback,
      args = {...},
      running = 0
    },
    { __index = TimedEntry }
  )
end

function TimedEntry:update(dt)
  self.running = self.running + dt
  if self.running >= self.time then
    self.callback(unpack(self.args))
    self.expired = true
  end
end

local cron = {}

function cron.reset()
  entries = {}
end

function cron.after(time, callback, ...)
  assert(type(time) == "number" and time > 0, "time must be a positive number")
  assert(type(callback) == "function", "callback must be a function")

  local entry = TimedEntry:new(time, callback, ...)
  entries[entry] = entry
end

function cron.update(dt)
  assert(type(dt) == "number" and dt > 0, "dt must be a positive number")

  local expired = {}

  for _, entry in pairs(entries) do
    entry:update(dt, runningTime)
    if entry.expired then expired[entry] = entry end
  end

  for _, entry in pairs(expired) do entries[entry] = nil end
end

return cron

