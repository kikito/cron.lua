local cron = require 'cron'

describe( 'cron', function()

  local counter
  local function count(amount)
    amount = amount or 1
    counter = counter + amount
  end
  local countable = setmetatable({}, {__call = count})

  before_each(function()
    counter = 0
  end)


  describe('clock', function()

    describe(':update', function()
      it('throws an error if dt is a negative number', function()
        local clock = cron.every(1, count)
        assert.error(function() clock:update() end)
        assert.error(function() clock:update(-1) end)
        assert.not_error(function() clock:update(1) end)
      end)
    end)

  end)


  describe('.after', function()
    it('checks parameters', function()
      assert.error(function() cron.after('error', count) end)
      assert.error(function() cron.after(2, 'error') end)
      assert.error(function() cron.after(-2, count) end)
      assert.error(function() cron.after(2, {}) end)
      assert.not_error(function() cron.after(2, count) end)
      assert.not_error(function() cron.after(2, countable) end)
    end)

    it('produces a clock that executes actions only once, at the right time', function()
      local c1 = cron.after(2, count)
      local c2 = cron.after(4, count)

      -- 1
      c1:update(1)
      assert.equal(counter, 0)
      c2:update(1)
      assert.equal(counter, 0)

      -- 2
      c1:update(1)
      assert.equal(counter, 1)
      c2:update(1)
      assert.equal(counter, 1)

      -- 3
      c1:update(1)
      assert.equal(counter, 1)
      c2:update(1)
      assert.equal(counter, 1)

      -- 4
      c1:update(1)
      assert.equal(counter, 1)
      c2:update(1)
      assert.equal(counter, 2)

    end)

    it('Passes on parameters to the callback', function()
      local c1 = cron.after(1, count, 2)
      c1:update(1)
      assert.equal(counter, 2)
    end)
  end)

  describe('.every', function()
    it('checks parameters', function()
      assert.error(function() cron.every('error', count) end)
      assert.error(function() cron.every(2, 'error') end)
      assert.error(function() cron.every(-2, count) end)
      assert.error(function() cron.every(-2, {}) end)
      assert.not_error(function() cron.every(2, count) end)
      assert.not_error(function() cron.every(2, countable) end)
    end)

    it('Invokes callback periodically', function()
      local c = cron.every(3, count)

      c:update(1)
      assert.equal(counter, 0)

      c:update(2)
      assert.equal(counter, 1)

      c:update(2)
      assert.equal(counter, 1)

      c:update(1)
      assert.equal(counter, 2)
    end)

    it('Executes the same action multiple times on a single update if appropiate', function()
      local c = cron.every(1, count)
      c:update(2)
      assert.equal(counter, 2)
    end)

    it('Respects parameters', function()
      local c = cron.every(1, count, 2)
      c:update(2)
      assert.equal(counter, 4)
    end)
  end)

end)
