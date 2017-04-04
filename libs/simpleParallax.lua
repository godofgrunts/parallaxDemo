local simpleParallax = {
  _VERSION     = 'simpleParallax v0.1.0',
  _DESCRIPTION = 'An parallax library for LÖVE',
  _URL         = 'https://github.com/godofgrunts/',
  _LICENSE     = [[
    MIT LICENSE

    Copyright (c) 2015 Ryan "GodofGrunts" Whited

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

local Camera = require 'libs/camera'

local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

local function newCamera (w, h, zoom)
  local cam = {}
  cam.w = w/2
  cam.h = h/2
  if zoom ~= nil
  then
    cam.z = zoom
  else
    cam.z = 1
  end
  return Camera(cam.w, cam.h, cam.z)
end

local function newParallax(img, speed, x, y, zoom)
  local imgArray = {}
  local imgArrayCopy = {}
  local scene = {}
  imgArray.img = img
  imgArray.w = img:getWidth()
  imgArray.h = img:getHeight()
  imgArray.speed = speed
  if x ~= nil
  then
    imgArray.x = x
  else
    imgArray.x = 0
  end
  if y ~= nil
  then
    imgArray.y = y
  else
    imgArray.y = 0
  end
  scene.camera = newCamera(imgArray.w, imgArray.h, zoom)
  imgArrayCopy = deepcopy(imgArray)
  scene.a = imgArray
  scene.b = imgArrayCopy
  return scene
end

------------------------------------------------------------------------------

local function loopScene(array, offset)
  if array.camera.x > array.b.x + array.b.w/2 then
    array.a.x = array.b.x + array.b.w + offset
  end
  if array.camera.x < array.b.x + array.b.w/2 then
    array.a.x = array.b.x - array.b.w - offset
  end
  if array.camera.x > array.a.x + array.a.w/2 then
    array.b.x = array.a.x + array.a.w + offset
  end

  if array.camera.x < array.a.x + array.a.w/2 then
    array.b.x = array.a.x - array.a.w - offset
  end
  return array
end


simpleParallax.newParallax = newParallax
simpleParallax.loopScene = loopScene

return simpleParallax
