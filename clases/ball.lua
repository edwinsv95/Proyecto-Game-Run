

local physics = require('physics')
local sounds = require('librerias.sounds')

local _M = {}

local newPuff = require('clases.puff').newPuff

function _M.newBall(params)
	local ball = display.newImageRect(params.g, 'imagenes/ammo/' .. params.type .. '.png', 48, 48)
	ball.x, ball.y = params.x, params.y

	physics.addBody(ball, 'static', {density = 2, friction = 0.5, bounce = 0.5, radius = ball.width / 2})
	ball.isBullet = true 
	ball.angularDamping = 3 
	ball.type = params.type

	function ball:launch(dir, force)
		dir = math.rad(dir) 
		ball.bodyType = 'dynamic' 
		ball:applyLinearImpulse(force * math.cos(dir), force * math.sin(dir), ball.x, ball.y)
		ball.isLaunched = true
	end

	function ball:explode()
		sounds.play('explosion')
		local radius = 192 -- 
		local area = display.newCircle(params.g, self.x, self.y, radius)
		area.isVisible = false
		physics.addBody(area, 'dynamic', {isSensor = true, radius = radius})


		local affected = {} -- 
		function area:collision(event)
			if event.phase == 'began' then
				if not affected[event.other] then
					affected[event.other] = true
					local x, y = event.other.x - self.x, event.other.y - self.y
					local dir = math.atan2(y, x) * 180 / math.pi
					local force = (radius - math.sqrt(x ^ 2 + y ^ 2)) * 4 
					
					if force < 20 then
						force = 20
					end
					event.other:applyLinearImpulse(force * math.cos(dir), force * math.sin(dir), event.other.x, event.other.y)
				end
			end
		end
		area:addEventListener('collision')
		timer.performWithDelay(1, function()
			area:removeSelf()
		end)

		self:removeSelf()
	end

	function ball:destroy()
		
		newPuff({g = params.g, x = self.x, y = self.y, isExplosion = self.type == 'bomb'})
		if self.type == 'bomb' then
			self:explode()
		else
			sounds.play('ball_destroy')
			self:removeSelf()
		end
	end

	return ball
end

return _M
