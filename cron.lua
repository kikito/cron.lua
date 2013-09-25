local cron = {
  __VERSION     = 'cron.lua 2.0.0',
  __DESCRIPTION = 'Time-related functions for lua',
  __URL         = 'https://github.com/kikito/cron.lua',
  __LICENSE     = [[
    Copyright (c) 2011 Enrique García Cota

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  ]]
}

-- Private functions

local entries --  initialized in cron.reset

local function isCallable(callback)
  local tc = type(callback)
  if tc == 'function' then return true end
  if tc == 'table' then
    local mt = getmetatable(callback)
    return type(mt) == 'table' and type(mt.__call) == 'function'
  end
  return false
end

local function checkTimeAndCallback(time, callback)
  assert(type(time) == "number" and time > 0, "time must be a positive number")
  assert(isCallable(callback), "callback must be a function")
end

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

local function updateTimedEntry(self, dt) -- returns true if expired
  self.running = self.running + dt
  if self.running >= self.time then
    self.callback(unpack(self.args))
    cron.cancel(self)
  end
end

local function updatePeriodicEntry(self, dt)
  self.running = self.running + dt

  while self.running >= self.time do
    self.callback(unpack(self.args))
    self.running = self.running - self.time
  end
end

-- Public functions

function cron.cancel(id)
  entries[id] = nil
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
  assert(type(dt) == "number" and dt >= 0, "dt must be a non-negative number")

  for _, entry in pairs(entries) do entry:update(dt) end
end

function cron.reset()
  entries = {}
end

cron.reset()

return cron

