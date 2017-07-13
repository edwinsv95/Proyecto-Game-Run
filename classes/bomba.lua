

local physics = require('physics')
local sonidos = require('libs.sonidos')

local _M = {}

local newPuff = require('classes.puff').newPuff

function _M.newBomba(params)
	local bomba = display.newImageRect(params.g, 'images/ammo/' .. params.type .. '.png', 48, 48)
	bomba.x, bomba.y = params.x, params.y

	physics.addBody(bomba, 'static', {density = 2, friction = 0.5, bounce = 0.5, radius = bomba.width / 2})
	bomba.isBullet = true 
	bomba.angularDamping = 3 
	bomba.type = params.type

	function bomba:launch(dir, fuerza)
		dir = math.rad(dir) 
		bomba.bodyType = 'dynamic' 
		bomba:applyLinearImpulse(fuerza * math.cos(dir), fuerza * math.sin(dir), bomba.x, bomba.y)
		bomba.isLaunched = true
	end

	function bomba:explode()
		sonidos.play('explosion')
		local radio = 192 
		local area = display.newCircle(params.g, self.x, self.y, radio)
		area.isVisible = false
		physics.addBody(area, 'dynamic', {isSensor = true, radius = radio})

		
		local afectado = {} 
		function area:collision(event)
			if event.phase == 'began' then
				if not afectado[event.other] then
					afectado[event.other] = true
					local x, y = event.other.x - self.x, event.other.y - self.y
					local dir = math.atan2(y, x) * 180 / math.pi
					local fuerza = (radio - math.sqrt(x ^ 2 + y ^ 2)) * 4 
					
					if fuerza < 20 then
						fuerza= 20
					end
					event.other:applyLinearImpulse(fuerza * math.cos(dir), fuerza * math.sin(dir), event.other.x, event.other.y)
				end
			end
		end
		area:addEventListener('collision')
		timer.performWithDelay(1, function()
			area:removeSelf()
		end)

		self:removeSelf()
	end

	function bomba:destroy()
		
		newPuff({g = params.g, x = self.x, y = self.y, isExplosion = self.type == 'bomb'})
		if self.type == 'bomb' then
			self:explode()
		else
			sonidos.play('bomba')
			self:removeSelf()
		end
	end

	return bomba
end

return _M
