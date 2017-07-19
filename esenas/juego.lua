

local composer = require('composer') 
local physics = require('physics') 
local widget = require('widget') 
local controller = require('libs.controller') 
local databox = require('libs.databox') 
local eachframe = require('libs.eachframe') 
local relayout = require('libs.relayout') 
local sonidos = require('libs.sonidos') 
local tiled = require('libs.tiled') 

physics.start()
physics.setGravity(0, 20) 

local esena = composer.newScene()



local newCannon = require('classes.cannon').newCannon 
local newBug = require('classes.bug').newBug 
local newBloque = require('classes.bloque').newBloque 
local newbarra_lateral = require('classes.barra_lateral').newbarra_lateral 
local newEndLevelPopup = require('classes.finalizar_nivel').newEndLevelPopup 

function esena:create(event)
	local _W, _H, _CX, _CY = relayout._W, relayout._H, relayout._CX, relayout._CY

	local group = self.view
	self.levelId = event.params
	self.level = require('niveles.' .. self.levelId)
	local background = display.newRect(group, _CX, _CY, _W,  _H)
	background.fill = {
	    type = 'gradient',
	    color1 = {0.2, 0.45, 0.8},
	    color2 = {0.7, 0.8, 1}
	}
	relayout.add(background)


	self.map = tiled.newTiledMap({g = group, filename = 'mapas.' .. self.level.map})
	self.map.camera.low.y = -self.map.map.height * self.map.map.tileheight 
	self.map.camera.high.y = self.map.camera.high.y
	self.map:moveCamera(self.map.camera.high.x, 0) 
	self.map:draw()

	
	self.bugs = {}
	for i = 1, #self.level.bugs do
		local b = self.level.bugs[i]
		table.insert(self.bugs, newBug({g = self.map.physicsGroup, x = b.x, y = b.y}))
	end

	self.bloques = {}
	for i = 1, #self.level.bloques do
		local b = self.level.bloques[i]
		table.insert(self.bloques, newBloque({
			g = self.map.physicsGroup,
			x = b.x, y = b.y,
			rotation = b.rotation,
			material = b.material,
			name = b.name
		}))
	end

	
	self:createTouchRect({delay = 2000})
	self.map.physicsGroup:toFront() 
	self.cannon = newCannon({map = self.map, level = self.level})
	self.map:moveCameraSmoothly({x = self.cannon.x - _CX, y = 0, time = 1000, delay = 1000}) -- Slide it back to the cannon

	
	self.endLevelPopup = newEndLevelPopup({g = group, levelId = self.levelId})
	self.barra_lateral = newbarra_lateral({g = group, levelId = self.levelId, onHide = function()
		self:setIsPaused(false)
		controller.setVisualButtons()
	end})

	local etiqueta_nivel = display.newText({
		parent = group,
		text = 'Nivel: ' .. self.levelId,-- CONTADOR DE NIVELES
		x = _W - 16, y = 16,
		font = native.systemFontBold,
		fontSize = 32
	})
	etiqueta_nivel.anchorX, etiqueta_nivel.anchorY = 1, 0
	relayout.add(etiqueta_nivel)

	local boton_pausar = widget.newButton({
		defaultFile = 'images/buttons/pause.png',--boton pausar
		overFile = 'images/buttons/pause-over.png',
		width = 96, height = 105,
		x = 16, y = 16,
		onRelease = function()
			sonidos.play('tap')
			self.barra_lateral:show()
			self:setIsPaused(true)
		end
	})
	boton_pausar.anchorX, boton_pausar.anchorY = 0, 0
	group:insert(boton_pausar)
	relayout.add(boton_pausar)

	self.barra_lateral:toFront()

	controller.setVisualButtons() 

	local function switchMotionAndRotation()
	
		controller.onMotion, controller.onRotation = controller.onRotation, controller.onMotion
	end

	
	controller.onMotion = function(name, value)
		if not self.isPaused then
			self.map:snapCameraTo()
			if name == 'x' then
				self.map.camera.xIncrement = value
			elseif name == 'y' then
				self.map.camera.yIncrement = value
			end
		end
	end
	
	controller.onRotation = function(name, value)
		if not self.isPaused then
			if self.cannon.bomba and not self.cannon.bomba.isLaunched then
				self.map:snapCameraTo(self.cannon)
			end
			if math.abs(value) >= 0.08 or math.abs(value) < 0.02 then
				if name == 'x' then
					self.cannon.radiusIncrement = -value 
				elseif name == 'y' then
					self.cannon.rotationIncrement = value
				end
			end
		end
	end
	
	controller.onKey = function(keyName, keyType)
		if not self.isPaused then
			if keyType == 'action' then
				if keyName == 'buttonA' and system.getInfo('platformName') == 'tvOS' then
					switchMotionAndRotation()
				else
					self.cannon:engageForce()
				end
			elseif keyType == 'pause' then
				boton_pausar._view._onRelease()
			end
		end
	end

	
	if system.getInfo('platformName') == 'tvOS' then
		switchMotionAndRotation()
	end
end

function esena:show(event)
	if event.phase == 'did' then
		eachframe.add(self) 

		
		self.endLevelCheckTimer = timer.performWithDelay(2000, function()
			self:endLevelCheck()
		end, 0)

		
		if not databox.isHelpShown then
			timer.performWithDelay(2500, function()
				self.barra_lateral:show()
				self:setIsPaused(true)
			end)
		end

		sonidos.playStream('game_music')
	end
end


function esena:eachFrame()
	local tables = {self.bugs, self.bloques}
	for i = 1, #tables do
		local t = tables[i]
		for j = #t, 1, -1 do
			local b = t[j]
			if b.isAlive then
				if b.x < 0 or b.x > self.map.map.tilewidth * self.map.map.width or b.y > self.map.map.tilewidth * self.map.map.height then
					b:destroy()
				end
			else
				table.remove(t, j)
			end
		end
	end
end

function esena:setIsPaused(isPaused)
	self.isPaused = isPaused
	self.cannon.isPaused = self.isPaused 
	if self.isPaused then
		physics.pause()
	else
		physics.start()
	end
end


function esena:endLevelCheck()
	if not self.isPaused then
		if #self.bugs == 0 then
			sonidos.play('win')
			self:setIsPaused(true)
			self.endLevelPopup:show({isWin = true})
			timer.cancel(self.endLevelCheckTimer)
			self.endLevelCheckTimer = nil
			databox['level' .. self.levelId] = true
		elseif self.cannon:getAmmoCount() == 0 then
			sonidos.play('lose')
			self:setIsPaused(true)
			self.endLevelPopup:show({isWin = false})
			timer.cancel(self.endLevelCheckTimer)
			self.endLevelCheckTimer = nil
		end
	end
end


function esena:createTouchRect(params)
	local _W, _H, _CX, _CY = relayout._W, relayout._H, relayout._CX, relayout._CY

	local group = self.view
	local map = self.map
	local delay = params.delay or 1
	local touchRect = display.newRect(group, _CX, _CY, _W, _H)
	touchRect.isVisible = false
	relayout.add(touchRect)

	function touchRect:touch(event)
		if event.phase == 'began' then
			display.getCurrentStage():setFocus(self, event.id)
			self.isFocused = true
			self.xStart, self.yStart = map.camera.x, map.camera.y
		elseif self.isFocused then
			if event.phase == 'moved' then
				map:snapCameraTo()
				map:moveCamera(self.xStart - event.x + event.xStart, self.yStart - event.y + event.yStart)
			else
				display.getCurrentStage():setFocus(self, nil)
				self.isFocused = false
			end
		end
		return true
	end
	touchRect:addEventListener('touch')

	timer.performWithDelay(delay, function()
		touchRect.isHitTestable = true
	end)
end


function esena:gotoPreviousScene()
	native.showAlert('Game Run', 'Estas seguro que quieres salir de este nivel?', {'Si', 'Cancelar'}, function(event)
		if event.action == 'clicked' and event.index == 1 then
			composer.gotoScene('esenas.menu', {time = 500, effect = 'slideRight'})
		end
	end)
end


function esena:hide(event)
	if event.phase == 'will' then
		eachframe.remove(self)
		controller.onMotion = nil
		controller.onRotation = nil
		controller.onKey = nil
		if self.endLevelCheckTimer then
			timer.cancel(self.endLevelCheckTimer)
		end
	elseif event.phase == 'did' then
		physics.stop()
	end
end

esena:addEventListener('create')
esena:addEventListener('show')
esena:addEventListener('hide')

return esena
