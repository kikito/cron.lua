cron.lua
========

[![Build Status](https://travis-ci.org/kikito/cron.lua.png?branch=master)](https://travis-ci.org/kikito/cron.lua)

`cron.lua` are a set of functions for executing actions at a certain time interval.

API
===

* `cron.after(time, callback)` will execute callback after the given amount of time units. Returns an identifier (`id`)
* `cron.every(time, callback)` will repeat the same action periodically. Returns an identifier (`id`)
* `cron.cancel(id)` will stop a timed action from happening, and will interrupt the periodical execution of a periodic action.
* `cron.reset()` removes all timed and periodic actions, and resets the time passed back to 0.
* `cron.update(dt)` is needed to be executed on the main program loop. `dt` is the amount of time that has passed since the last iteration. When `cron.update` is executed, cron will check the list of pending actions and execute them if needed.

Examples
========

    local cron = require 'cron'

    local function printMessage()
      print('Hello')
    end

    -- the following calls are equivalent:
    cron.after(5, printMessage)
    cron.after(5, print, 'Hello')

    cron.update(5) -- will print 'Hello' twice (once per each cron.after)

    -- this will print the message periodically:
    local id = cron.every(10, printMessage)

    cron.update(5) -- nothing (total time: 5)
    cron.update(4) -- nothing (total time: 9)
    cron.update(12) -- prints 'Hello' twice (total time is now 21)

    cron.cancel(id) -- stops the execution the element defined by id. Works with periodical or one-time actions.

    cron.reset() -- stops all the current actions, both timed ones and periodical ones.

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


