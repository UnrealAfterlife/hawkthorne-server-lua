local Gamestate = require 'vendor/gamestate'
local Prompt = require 'prompt'
local sound = require 'vendor/TEsound'
local Alarm = {}
Alarm.__index = Alarm

local image = love.graphics.newImage('images/firealarm.png')
local not_broken_img = love.graphics.newQuad( 0, 0, 24,72, image:getWidth(), image:getHeight() )
local broken_img = love.graphics.newQuad( 24, 0, 24,72, image:getWidth(), image:getHeight() )
local psPaintImage = love.graphics.newImage('images/ps_paint.png')
local psPaint = love.graphics.newParticleSystem(psPaintImage, 100)

local broken = false
local activated = false

function Alarm.new(node, collider)
	initPaint()
    local alarm = {}
    setmetatable(alarm, Alarm)
    alarm.x = node.x
    alarm.y = node.y
    alarm.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    alarm.bb.node = alarm
    alarm.players_touched = {}
    alarm.fixed = false
    alarm.prompt = nil
    collider:setPassive(alarm.bb)
    return alarm
end
    
function Alarm:update(dt)
    if self.prompt then self.prompt:update(dt) end
	psPaint:update(dt)
end

function Alarm:draw()
    if self.broken then
        love.graphics.drawq(image, broken_img, self.x, self.y)
    else
        love.graphics.drawq(image, not_broken_img, self.x, self.y)
    end

    if self.prompt then
        self.prompt:draw(self.x + 78, self.y - 35)
    end
	love.graphics.draw(psPaint, self.x + 12, 40);
end

function Alarm:leave()
    psPaint:stop()
    sound.stopSfx()
end

function Alarm:keypressed( button, player )
  if button == 'ACTION' and self.prompt == nil then
    if not self.activated then
      player.freeze = true
      self.prompt = Prompt.new(120, 55, "Pull the fire alarm?", function(result)
        self.activated = result == 1
        if (result == 1) then
          sound.playSfx( "alarmswitch" )
          if (math.random() > 0.5) then
            player.painted = true
            sound.playSfx( "spray" )
            psPaint:start()
          else
            self.broken = true
          end
        end
        player.freeze = false
        self.prompt = nil
      end)
    elseif not self.broken then
      sound.playSfx( "alarmswitch" )
    end
  end

  if self.prompt then
    return self.prompt:keypressed( button )
  end
end

function initPaint()
	psPaint:setBufferSize(200)
  psPaint:setColors(255,138,20,255,255,138,20,128)
	psPaint:setDirection(1.5)
	psPaint:setEmissionRate(180)
	psPaint:setGravity(20,20)
	psPaint:setLifetime(20)
	psPaint:setParticleLife(1.0,1.0)
	psPaint:setRadialAcceleration(100,100)
	psPaint:setRotation(0,0)
	psPaint:setSizes(0.3,0.4,0.5)
	psPaint:setSpeed(100,200)
	psPaint:setSpin(0,0)
	psPaint:setSpread(1.4)
	psPaint:setTangentialAcceleration(69,0)
	psPaint:stop()
end

return Alarm


