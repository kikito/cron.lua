local cron = require 'cron'

describe( 'cron', function()

  local counter = 0
  local function count(amount)
    amount = amount or 1
    counter = counter + amount
  end
  local countable = setmetatable({}, {__call = count})

  before(function()
    counter = 0
    cron.reset()
  end)

  describe('.update', function()
    it('throws an error if dt is a negative number', function()
      assert_error(function() cron.update() end)
      assert_error(function() cron.update(-1) end)
      assert_not_error(function() cron.update(1) end)
    end)
  end)

  describe('.reset', function()
    it('Cancels all timed actions', function()
      cron.after(1, count)
      cron.after(2, count)
      cron.update(1)
      assert_equal(counter, 1)
      cron.reset()
      cron.update(1)
      assert_equal(counter, 1)
    end)

    it('Cancels all periodical actions', function()
      cron.every(1, count)
      cron.update(1)
      assert_equal(counter, 1)
      cron.reset()
      cron.update(1)
      assert_equal(counter, 1)
    end)

  end)

  describe('.after', function()
    it('Throws error if time is not a positive number, or callback is not callable', function()
      assert_error(function() cron.after('error', count) end)
      assert_error(function() cron.after(2, 'error') end)
      assert_error(function() cron.after(-2, count) end)
      assert_error(function() cron.after(2, {}) end)
      assert_not_error(function() cron.after(2, count) end)
      assert_not_error(function() cron.after(2, countable) end)
    end)

    it('Executes timed actions only once, at the right time', function()
      cron.after(2, count)
      cron.after(4, count)
      cron.update(1)
      assert_equal(counter, 0)
      cron.update(1)
      assert_equal(counter, 1)
      cron.update(1)
      assert_equal(counter, 1)
      cron.update(1)
      assert_equal(counter, 2)
    end)

    it('Passes on parameters to the function, if specified', function()
      cron.after(1, count, 2)
      cron.update(1)
      assert_equal(counter, 2)
    end)
  end)

  describe('.every', function()
    it('Throws errors if time is not a positive number, or callback is not function', function()
      assert_error(function() cron.every('error', count) end)
      assert_error(function() cron.every(2, 'error') end)
      assert_error(function() cron.every(-2, count) end)
      assert_error(function() cron.every(-2, {}) end)
      assert_not_error(function() cron.every(2, count) end)
      assert_not_error(function() cron.every(2, countable) end)
    end)

    it('Executes periodical actions periodically', function()
      cron.every(3, count)
      cron.update(1)
      assert_equal(counter, 0)
      cron.update(2)
      assert_equal(counter, 1)
      cron.update(2)
      assert_equal(counter, 1)
      cron.update(1)
      assert_equal(counter, 2)
    end)

    it('Executes the same action multiple times on a single update if appropiate', function()
      cron.every(1, count)
      cron.update(2)
      assert_equal(counter, 2)
    end)

    it('Respects parameters', function()
      cron.every(1, count, 2)
      cron.update(2)
      assert_equal(counter, 4)
    end)
  end)

  describe('.cancel', function()
    it('Cancels timed entries', function()
      local id = cron.after(1, count)
      cron.update(1)
      assert_equal(counter, 1)
      cron.cancel(id)
      cron.update(1)
      assert_equal(counter, 1)
    end)

    it('Cancels periodical entries', function()
      local id = cron.every(1, count)
      cron.update(1)
      assert_equal(counter, 1)
      cron.cancel(id)
      cron.update(1)
      assert_equal(counter, 1)
    end)
  end)

  describe('.tagged', function()
    before(function()
      cron.tagged('hello').every(5, count) -- A
      cron.tagged('hello').after(2, count) -- B
      cron.every(1, count)                 -- C
    end)

    it('filters update', function()
      cron.tagged('hello').update(5)
      assert_equal(counter, 2)  -- A + B, but not C
    end)

    it('filters cancel', function()
      cron.tagged('hello', 'girl').every(5, count) -- D

      cron.tagged('hello').update(5) -- A + B + D - C
      assert_equal(counter, 3)

      cron.tagged('girl').cancel()
      cron.tagged('hello').update(5) -- A + B - C
      assert_equal(counter, 4)

      cron.tagged('girl').update(5) -- nothing (D is cancelled)
      assert_equal(counter, 4)
    end)
  end)
end)
