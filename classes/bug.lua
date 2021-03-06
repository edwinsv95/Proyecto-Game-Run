

local physics = require('physics')
local sonidos = require('libs.sonidos')

local _M = {}

local newPuff = require('classes.puff').newPuff

function _M.newBug(params)
	local bug = display.newImageRect(params.g, 'images/bug.png', 64, 64)
	bug.x, bug.y = params.x, params.y
	physics.addBody(bug, 'dynamic', {density = 2, friction = 0.5, bounce = 0.5, radius = bug.width * 0.4})
	bug.angularDamping = 3  
	bug.isAlive = true

	function bug:destroy()
		sonidos.play('bug')
		self.isAlive = false
		newPuff({g = params.g, x = self.x, y = self.y})
		timer.performWithDelay(1, function()
			self:removeSelf()
		end)
	end

	function bug:postCollision(event)
	
		if event.force > 30 and self.isAlive then
			self:destroy()
		end
	end
	bug:addEventListener('postCollision')

	return bug
end

return _M
