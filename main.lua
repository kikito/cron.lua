local cron = require 'cron'

local counter  = 10
local exploded = false
local defused  = false

local bombClock
local exitClock

function ticktack()
  if exploded or defused then return end
  counter = counter - 1
  if counter <= 0 then
    exploded = true
    exitClock = cron.after(2, love.event.quit)
  end
end

function love.keypressed(key, unicode)
  if exploded or defused then return end
  if key == ' ' then
    defused = true
    exitClock = cron.after(2, love.event.quit)
  end
end

function love.load()
  bombClock = cron.every(1, ticktack) -- execute the ticktack function every second
end

function love.update(dt)
  bombClock:update(dt)
  if exitClock then exitClock:update(dt) end
end

function love.draw()
  local msg
  if exploded then
    msg = 'BOOM! Game over. Bye!'
  elseif defused then
    msg = "Good job! You saved the day! Bye!"
  else
    msg = 'You have ' .. tostring(counter) .. ' seconds left to defuse the bomb - press space to defuse it!'
  end
  love.graphics.print(msg, 100, 200 )
end


