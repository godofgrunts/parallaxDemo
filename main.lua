--[[
This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <http://unlicense.org>
--]]

--tested on LOVE 0.10.2 (Super Toast)

local anim8 = require 'libs/anim8' -- https://github.com/kikito/anim8
local Camera = require 'libs/camera'
local par = require 'libs/simpleParallax'
local img, playerAnimation, flip
local player = {x = 0, y = 0, flip = 1, iW = nil, img = nil, speed = 100}


function love.load()
  windowx = love.graphics.getWidth()
  bg = {}
  bg.img = love.graphics.newImage('assets/background/layers/skill-desc_0003_bg.png')
  bg.x = 0
  bg.w = bg.img:getWidth()

  farBldg = love.graphics.newImage('assets/background/layers/skill-desc_0002_far-buildings.png')
  medBldg = love.graphics.newImage('assets/background/layers/skill-desc_0001_buildings.png')
  cloBldg = love.graphics.newImage('assets/background/layers/skill-desc_0000_foreground.png')

  far = par.newParallax(farBldg, 20, 0, 0, 3.5)
  med = par.newParallax(medBldg, 60, 0, 0, 3.5)
  clo = par.newParallax(cloBldg, 100, 0, 0, 3.5)


  player.img = love.graphics.newImage('assets/hero.png') --sprite sheet downloaded from http://opengameart.org/content/classic-hero under public domain license
  player.iW = 0
  local g = anim8.newGrid(16, 16, player.img:getWidth(), player.img:getHeight(), 16, 16)
  local idleFrames = g('1-4',1)
  local runFrames = g('1-6', 2)
  idleAnimation = anim8.newAnimation(idleFrames, 0.3)
  runAnimation = anim8.newAnimation(runFrames, 0.1)
  currentAnimation = idleAnimation
  music = love.audio.newSource('assets/snow.ogg', 'static') --downloaded from http://www.freesound.org/people/ShadyDave/sounds/262259/ CC BY-NC 3.0 author ShadyDave
  music:setLooping(true)
  music:play()
  playerCam = Camera(player.x, player.y - 16 * 3, 3.5)
  bgCam = Camera(bg.img:getWidth()/2, bg.img:getHeight()/2, 3.5)

end

function love.draw()

  bgCam:attach()
  love.graphics.draw(bg.img, 0, 0, 0, 1, 1)
  bgCam:detach()

  far.camera:attach()
    love.graphics.draw(far.a.img, far.a.x, far.a.y, 0, 1, 1)
    love.graphics.draw(far.b.img, far.b.x, far.b.y, 0, 1, 1)
  far.camera:detach()

  med.camera:attach()
    love.graphics.draw(med.a.img, med.a.x, med.a.y, 0, 1, 1)
    love.graphics.draw(med.b.img, med.b.x, med.b.y, 0, 1, 1)
  med.camera:detach()

  clo.camera:attach()
    love.graphics.draw(clo.a.img, clo.a.x, clo.a.y, 0, 1, 1)
    love.graphics.draw(clo.b.img, clo.b.x, clo.b.y, 0, 1, 1)
  clo.camera:detach()

  playerCam:attach()
  currentAnimation:draw(player.img, player.x, player.y, 0, player.flip, 1, player.iW, 0)
  playerCam:detach()
end

function love.update(dt)

  if (love.keyboard.isDown('right')) then
    currentAnimation = runAnimation
    player.flip = 1 -- set to 8 to make the image large enough to see the animations
    player.iW = 0 -- when facing right we don't need an offset
    player.x = player.x + player.speed * dt
  end
  if (love.keyboard.isDown('left')) then
    currentAnimation = runAnimation
    player.flip = -1 -- set to -8 to flip the image and make it large enough to see animations
    player.iW = 16 -- since image is flipped at origin point, we need to move the image to the right 16
    player.x = player.x - player.speed * dt
  end
  if (love.keyboard.isDown('left') ) and (love.keyboard.isDown('right') )  then
    currentAnimation = idleAnimation
  end

  if player.x + 90 < playerCam.x then
    playerCam:move(-player.speed * dt,0)
    far.camera:move(-far.a.speed * dt,0)
    med.camera:move(-med.a.speed * dt,0)
    clo.camera:move(-clo.a.speed * dt,0)
  end
  if player.x - 25 > playerCam.x then
    playerCam:move(player.speed * dt,0)
    far.camera:move(far.a.speed * dt,0)
    med.camera:move(med.a.speed * dt,0)
    clo.camera:move(clo.a.speed * dt,0)
  end

  far = par.loopScene(far, 50)
  med = par.loopScene(med, 0)
  clo = par.loopScene(clo, 0)

  currentAnimation:update(dt)

end

function love.keyreleased(key)
  if key == 'right' or key == 'left' then
    currentAnimation = idleAnimation
    idleAnimation:gotoFrame(1)
  end
end
