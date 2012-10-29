-----------------------------------------------------------------------------------------------------------------------
-- cron.lua - v1.2.1 (2012-10)
-- Enrique García Cota - enrique.garcia.cota [AT] gmail [DOT] com
-- time-related functions for Lua.
-- inspired by Javascript's setTimeout and setInterval
-----------------------------------------------------------------------------------------------------------------------

-- Copyright (c) 2011 Enrique García Cota
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


-- Private functions

local entries, taggedEntries, scopeCacheRoot -- initialized in cron.reset
local cron = {}

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

local function addTags(...)
  local tags = {...}
  local len  = #tags
  for i=1, len do
    local tag = tags[i]
    taggedEntries[tag] = taggedEntries[tag] or setmetatable({}, {__mode = 'k'})
  end
  return tags, len
end

local function scopedEntry(scope, entry)
  for i=1, scope.len do
    taggedEntries[scope.tags[i]][entry] = entry
  end
  entry.tags = scope.tags
  return entry
end

local function scopedUpdate(scope, dt)
  for i=1, scope.len do
    for _,entry in pairs(taggedEntries[scope.tags[i]]) do
      entry:update(dt)
    end
  end
end

local function scopedCancel(scope)
  for i=1, scope.len do
    local tag = scope.tags[i]
    for _,entry in pairs(taggedEntries[tag]) do
      cron.cancel(entry)
    end
    taggedEntries[tag] = nil
  end
end

local function getScopeFromCache(tags, len)
  local node = scopeCacheRoot
  for i=1, len do
    node = node.children[tags[i]]
    if not node then return nil end
  end
  return node.scope
end

local function storeScopeInCache(scope)
  local node = scopeCacheRoot
  for i=1, scope.len do
    local tag = scope.tags[i]
    node.children[tag] = node.children[tag] or { children=setmetatable({},{__mode='k'}) }
    node = node.children[tag]
  end
  node.scope = scope
end

local function newTaggedScope(tags, len)
  local scope = getScopeFromCache(tags, len)
  if not scope then
    scope = { tags = tags, len = len }

    scope.after  = function(...) return scopedEntry(scope, cron.after(...)) end
    scope.every  = function(...) return scopedEntry(scope, cron.every(...)) end
    scope.update = function(dt) scopedUpdate(scope, dt) end
    scope.cancel = function(dt) scopedCancel(scope) end

    storeScopeInCache(scope)
  end
  return scope
end

-- Public functions

function cron.cancel(id)
  entries[id] = nil
  if id.tags then
    for i=1, #id.tags do
      taggedEntries[id.tags[i]][id] = nil
    end
  end
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

function cron.tagged(first, ...)
  assert(first ~= nil, "cron.tagged requires at least one tag")
  return newTaggedScope(addTags(first, ...))
end

function cron.reset()
  entries = {}
  taggedEntries = setmetatable({}, {__mode='k'})
  scopeCacheRoot = { children = setmetatable({}, {__mode='k'}) }
end

-- tagged functions


cron.reset()

return cron

