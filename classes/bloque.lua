

local physics = require('physics')
local sonidos = require('libs.sonidos')

local _M = {}

local newPuff = require('classes.puff').newPuff

local specs = {
	circle = {w = 35, h = 35},
	rectangle1 = {w = 35, h = 35},
	rectangle2 = {w = 70, h = 35},
	rectangle3 = {w = 35, h = 70},
	rectangle4 = {w = 110, h = 35},
	rectangle5 = {w = 35, h = 110},
	rectangle6 = {w = 70, h = 70},
	rectangle7 = {w = 110, h = 70},
	rectangle8 = {w = 70, h = 110}
}

function _M.newBloque(dato)
	local bloque = display.newImageRect(dato.g, 'images/blocks/' .. dato.material .. '/' .. dato.name .. '.png', specs[dato.name].w, specs[dato.name].h)
	bloque.x, bloque.y = dato.x, dato.y
	bloque.rotation = dato.rotation

	local fuerza_inpacto = 75
	local partes_cuerpo = {density = 2, friction = 0.5, bounce = 0.5}
	if dato.name == 'circle' then
		partes_cuerpo.radius = bloque.width / 2
	end

	if dato.material == 'stone' then
		partes_cuerpo.density = 4
		fuerza_inpacto = 150
	end
	physics.addBody(bloque, 'dynamic', partes_cuerpo)
	bloque.angularDamping = 3 
	bloque.isAlive = true

	function bloque:destroy()
		sonidos.play('poof')
		self.isAlive = false
		newPuff({g = dato.g, x = self.x, y = self.y})
		timer.performWithDelay(1, function()
			self:removeSelf()
		end)
	end

	function bloque:postCollision(event)
		if self.isAlive then
		
			if event.force > 20 then
				local vx, vy = event.other:getLinearVelocity()
				if vx + vy > 4 then
					sonidos.play('impact')
				end
			end
			if event.force >= fuerza_inpacto then
				self:destroy()
			end
		end
	end
	bloque:addEventListener('postCollision')

	return bloque
end

return _M
