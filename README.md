cron.lua
========

[![Build Status](https://travis-ci.org/kikito/cron.lua.png?branch=master)](https://travis-ci.org/kikito/cron.lua)

`cron.lua` are a set of functions for executing actions at a certain time interval.

API
===

`local clock = cron.after(time, callback, ...)`.
Creates a clock that will execute `callback` after `time` passes. If additional params were provided, they are passed to `callback`.

`local clock = cron.every(time, callback, ...)`.
Creates a clock that will execute `callback` every `time`, periodically. Additional parameters are passed to the `callback` too.


Clock methods:

`local expired = clock:update(dt)`.
Increases the internal timer in the clock by `dt`.

* On one-time clocks, if the internal timer surpasses the clock's `time`, then the clock's `callback` is invoked.
* On periodic clocks, the `callback` is executed 0 or more times, depending on how big `dt` is and the clock's internal timer.
* `expired` will be true for one-time clocks whose time has passed, so their function has been invoked.

`clock:reset([running])`
Changes the internal timer manually to `running`, or to 0 if nothing is specified. It never invokes `callback`.


Examples
========

    local cron = require 'cron'

    local function printMessage()
      print('Hello')
    end

    -- the following calls are equivalent:
    local c1 = cron.after(5, printMessage)
    local c2 = cron.after(5, print, 'Hello')

    c1:update(2) -- will print nothing, the action is not done yet
    c1:update(5) -- will print 'Hello' once

    c1:reset() -- reset the counter to 0

    -- prints 'hey' 5 times and then prints 'hello'
    while not c1:update(1) do
      print('hey')
    end

    -- Create a periodical clock:
    local c3 = cron.every(10, printMessage)

    c3:update(5) -- nothing (total time: 5)
    c3:update(4) -- nothing (total time: 9)
    c3:update(12) -- prints 'Hello' twice (total time is now 21)

Gotchas / Warnings
==================

* `cron.lua` does *not* implement any hardware or software clock; you will have to provide it with the access to the hardware timers, in the form of periodic calls to `cron.update`
* `cron` does not have any defined time units (seconds, milliseconds, etc). You define the units it uses by passing it a `dt` on `cron.update`. If `dt` is in seconds, then `cron` will work in seconds. If `dt` is in milliseconds, then `cron` will work in milliseconds.

Installation
============


Just copy the cron.lua file somewhere in your projects (maybe inside a /lib/ folder) and require it accordingly.

Remember to store the value returned by require somewhere! (I suggest a local variable named `cron`)

    local cron = require 'cron'

Also, make sure to read the license file; the text of that license file must appear somewhere in your projects' files.

Specs
=====

This project uses [busted](https://olivinelabs.com/busted) for its specs. If you want to run the specs, you will have to install it first. Then run:

    cd path/where/the/spec/folder/is
    busted


