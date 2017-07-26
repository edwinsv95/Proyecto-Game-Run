

local eachframe = require('libs.eachframe')
local relayout = require('libs.relayout')
local sonidos = require('libs.sonidos')

local _M = {}

local newBomba = require('classes.bomba').newBomba
local newPuff = require('classes.puff').newPuff

function _M.newCannon(params)
	local map = params.map
	local level = params.level

	local torre = display.newImageRect(map.group, 'images/tower.png', 192, 256)
	torre.anchorY = 1
	torre.x, torre.y = map:mapXYToPixels(level.cannon.mapX + 0.5, level.cannon.mapY + 1)
	map.snapshot:invalidate()

	local cannon = display.newImageRect(map.physicsGroup, 'images/cannon.png', 128, 64)
	cannon.anchorX = 0.25
	cannon.x, cannon.y = map:mapXYToPixels(level.cannon.mapX + 0.5, level.cannon.mapY - 3)

	
	cannon.force = 0
	cannon.forceRadius = 0

	cannon.radiusIncrement = 0
	cannon.rotationIncrement = 0

	local radioMin, radioMax = 64, 200


	local fuerzaArea = display.newCircle(map.physicsGroup, cannon.x, cannon.y, radioMax)
	fuerzaArea.strokeWidth = 4
	fuerzaArea:setFillColor(1, 0.5, 0.2, 0.2)
	fuerzaArea:setStrokeColor(1, 0.5, 0.2)
	fuerzaArea.isVisible = false

	
	local tocarArea = display.newCircle(map.physicsGroup, cannon.x, cannon.y, 128)
	tocarArea.isVisible = false
	tocarArea.isHitTestable = true
	tocarArea:addEventListener('touch', cannon)

	local puntos_trayectoria_bomba = {} 
	local bombas = {} 

	function cannon:getAmmoCount()
		return #bombas + (self.bomba and 1 or 0)
	end

	
	function cannon:prepareAmmo()
		local mapX, mapY = level.cannon.mapX - 1, level.cannon.mapY
		for i = #level.ammo, 1, -1 do
			local x, y = map:mapXYToPixels(mapX + 0.5, mapY + 0.5)
			local bomba = newBomba({g = self.parent, type = level.ammo[i], x = x, y = y})
			table.insert(bombas, bomba)
			mapX = mapX - 1
			if (#level.ammo - i + 1) % 3 == 0 then
				mapX, mapY = level.cannon.mapX - 1, mapY - 1
			end
		end
	end


	function cannon:load()
		if #bombas > 0 then
			self.bomba = table.remove(bombas, #bombas)
			transition.to(self.bomba, {time = 500, x = self.x, y = self.y, transition = easing.outExpo})
		end
	end

	
	function cannon:fire()
		if self.bomba and not self.bomba.isLaunched then
			self.bomba:launch(self.rotation, self.force)
			self:removeTrajectoryPoints()
			self.launchTime = system.getTimer() 
			self.lastTrajectoryPointTime = self.launchTime
			newPuff({g = self.parent, x = self.x, y = self.y, isExplosion = true}) 
			map:snapCameraTo(self.bomba)
			sonidos.play('cannon')
		end
	end

	function cannon:setForce(radius, rotation)
		self.rotation = rotation % 360
		if radius > radioMin then
			if radius > radioMax then
				radius = radioMax
			end
			self.force = radius
		else
			self.force = 0
		end
	
		if self.bomba and not self.bomba.isLaunched then
			fuerzaArea.isVisible = true
			fuerzaArea.xScale = 2 * radius / fuerzaArea.width
			fuerzaArea.yScale = fuerzaArea.xScale
		end
		return math.min(radius, radioMax), self.rotation
	end

	function cannon:engageForce()
		fuerzaArea.isVisible = false
		self.forceRadius = 0
		if self.force > 0 then
			self:fire()
		end
	end

	function cannon:touch(event)
		if event.phase == 'began' then
			display.getCurrentStage():setFocus(self, event.id)
			self.isFocused = true
			sonidos.play('cannon_touch')
		elseif self.isFocused then
			if event.phase == 'moved' then
				local x, y = self.parent:contentToLocal(event.x, event.y)
				x, y = x - self.x, y - self.y
				local rotation = math.atan2(y, x) * 180 / math.pi + 180
				local radius = math.sqrt(x ^ 2 + y ^ 2)
				self:setForce(radius, rotation)
			else
				display.getCurrentStage():setFocus(self, nil)
				self.isFocused = false
				self:engageForce()
			end
		end
		return true
	end
	cannon:addEventListener('touch')

	
	function cannon:addTrajectoryPoint()
		local posicion_actual = system.getTimer()
		
		if posicion_actual - self.launchTime < 1000 and posicion_actual - self.lastTrajectoryPointTime > 85 then
			self.lastTrajectoryPointTime = posicion_actual
			local puntos = display.newCircle(self.parent, self.bomba.x, self.bomba.y, 2)
			table.insert(puntos_trayectoria_bomba, puntos)
		end
	end

	
	function cannon:removeTrajectoryPoints()
		for i = #puntos_trayectoria_bomba, 1, -1 do
			table.remove(puntos_trayectoria_bomba, i):removeSelf()
		end
	end

	
	function cannon:eachFrame()
		local paso = 2
	    local damping = 0.99
		if self.bomba then
			if self.bomba.isLaunched then
				local vx, vy = self.bomba:getLinearVelocity()
				if vx ^ 2 + vy ^ 2 < 4 or
					self.bomba.x < 0 or
						self.bomba.x > map.map.tilewidth * map.map.width or
							self.bomba.y > map.map.tilewidth * map.map.height then
					self.bomba:destroy()
					self.bomba = nil
					self:load()
					map:moveCameraSmoothly({x = self.x - relayout._CX, y = self.y - relayout._CY, time = 1000, delay = 500})
				elseif not self.isPaused then
					self:addTrajectoryPoint()
				end
			elseif self.radiusIncrement ~= 0 or self.rotationIncrement ~= 0 then
		        self.radiusIncrement = self.radiusIncrement * damping
		        if math.abs(self.radiusIncrement) < 0.02 then
		            self.radiusIncrement = 0
		        end
				self.rotationIncrement = self.rotationIncrement * damping
		        if math.abs(self.rotationIncrement) < 0.02 then
		            self.rotationIncrement = 0
		        end
				self.forceRadius = self.forceRadius + self.radiusIncrement * paso
				self.forceRadius = self:setForce(math.max(math.abs(self.forceRadius), 1), self.rotation + self.rotationIncrement * paso)
		    end
		end
	end
	eachframe.add(cannon)

	
	function cannon:finalize()
		eachframe.remove(self)
	end
	cannon:addEventListener('finalize')

	cannon:prepareAmmo()
	cannon:load()

	return cannon
end

return _M
