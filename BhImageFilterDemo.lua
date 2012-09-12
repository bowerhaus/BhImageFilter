--[[ 
BhImageFilterDemo.lua

A demonstration of the BhSnapshot.mm plugin for Gideros Studio
 
MIT License
Copyright (C) 2012. Andy Bower, Bowerhaus LLP

Permission is hereby granted, free of charge, to any person obtaining a copy of this software
and associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute,
sublicense, and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]

require "BhImageFilter"
require "BhSnapshot"
require "BhHelpers"

BhImageFilterDemo=Core.class(Sprite)

local function makeRectShape(x, y, width, height, color)
	local rect=Shape.new()
	rect:beginPath()
	rect:setFillStyle(Shape.SOLID, color)
	rect:moveTo(x, y)
	rect:lineTo(x+width, y)
	rect:lineTo(x+width, y+height)
	rect:lineTo(x, y+height)
	rect:lineTo(x, y)
	rect:endPath()
	return rect
end

function BhImageFilterDemo:onMouseDown(event)
	if self:hitTestPoint(event.x, event.y) then	
		--local filename=BhSnapshot.snapshotToFile(BhSnapshot.LANDSCAPE_LEFT)
	
		BhImageFilter.loadImage(BhImageFilter.getPathForFile(self.filename))
		local width=self.image:getWidth()
		local height=self.image:getHeight()
		--BhImageFilter.resize(width/4, height/4)
		BhImageFilter.blur(90)
		--BhImageFilter.resize(width, height)
		
		local filename=BhImageFilter.getPathForFile("|D|"..self.filename)
		BhImageFilter.saveImage(filename)
		self:loadImage(filename)
		os.remove(filename)

		event:stopPropagation()
	end
end

function BhImageFilterDemo:loadImage(filename)
	if self.image then
		self.image:removeEventListener(Event.MOUSE_DOWN, self.onMouseDown, self)
		self.image:removeFromParent()
	end
	local image=Bitmap.new(Texture.new(filename))
	image:setAnchorPoint(0.5, 0.5)
	image:setPosition(stage:bhGetCenter())
	self:addChild(image)
	image:addEventListener(Event.MOUSE_DOWN, self.onMouseDown, self)
	self.image=image
	self.filename=filename
	return image
end

function BhImageFilterDemo:init()
	self.bg=makeRectShape(0, 0, application:getContentWidth(), application:getContentHeight(), 0xfc9fd6)
	self:addChild(self.bg)
	local currentDirectory=BhImageFilter.getResourcesDirectory()
	self:loadImage("FunnyPlane.png")
	stage:addChild(self)
	print(BhImageFilter.getPathForFile("FunnyPlane.png"))
	end