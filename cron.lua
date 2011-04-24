-----------------------------------------------------------------------------------------------------------------------
-- cron.lua - v1.0 (2011-04)
-- Enrique García Cota - enrique.garcia.cota [AT] gmail [DOT] com
-- time-related functions for Lua.
-- inspired by Javascript's setTimeout and setInterval
-----------------------------------------------------------------------------------------------------------------------


local function checkTimeAndCallback(time, callback)
  assert(type(time) == "number" and time > 0, "time must be a positive number")
  assert(type(callback) == "function", "callback must be a function")
end

local entries = {}

local function newEntry(time, callback, update, ...)
  local entry = {
    time = time,
    callback = callback,
    args = {...},
    running = 0,
    update = update
  }
  entries[entry] = entry
  return entry
end

local function updateTimedEntry(self, dt)
  self.running = self.running + dt
  if self.running >= self.time then
    self.callback(unpack(self.args))
    self.expired = true
  end
end

local function updatePeriodicEntry(self, dt)
  self.running = self.running + dt

  while self.running >= self.time do
    self.callback(unpack(self.args))
    self.running = self.running - self.time
  end
end

local cron = {}

function cron.reset()
  entries = {}
end

function cron.after(time, callback, ...)
  checkTimeAndCallback(time, callback)
  return newEntry(time, callback, updateTimedEntry, ...)
end

function cron.every(time, callback, ...)
  checkTimeAndCallback(time, callback)
  return newEntry(time, callback, updatePeriodicEntry, ...)
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

