

local composer = require('composer')
local widget = require('widget')
local controller = require('libs.controller')
local relayout = require('libs.relayout')
local sonidos = require('libs.sonidos')

local esena = composer.newScene()


local newbarra_lateral = require('classes.barra_lateral').newbarra_lateral

function esena:create()
	local _W, _H, _CX, _CY = relayout._W, relayout._H, relayout._CX, relayout._CY

	local group = self.view

	local background = display.newRect(group, _CX, _CY, _W, _H)
	background.fill = {
	    type = 'gradient',
	    color1 = {0.2, 0.45, 0.8},
	    color2 = {0.7, 0.8, 1}
	}
	relayout.add(background)

	local bottomGroup = display.newGroup()
	bottomGroup.x, bottomGroup.y = _CX, _H
	group:insert(bottomGroup)
	relayout.add(bottomGroup)

	local torre = display.newImageRect(bottomGroup, 'images/tower.png', 192, 256)
	torre.anchorY = 1
	torre.x, torre.y = -_W * 0.17, -64

	local cannon = display.newImageRect(bottomGroup, 'images/cannon.png', 128, 64)
	cannon.anchorX = 0.25
	cannon.x, cannon.y = torre.x, torre.y - 256

	
	transition.to(cannon, {time = 4000, rotation = -180, iterations = 0, transition = easing.continuousLoop})

	local numTiles = math.ceil(_W / 64 / 2)
	for i = -numTiles - 4, numTiles + 4 do 
		local tile = display.newImageRect(bottomGroup, 'images/green_tiles/3.png', 64, 64)
		tile.anchorY = 1
		tile.x, tile.y = i * 64, 0
	end

	local titleGroup = display.newGroup()
	titleGroup.x, titleGroup.y = _CX, 128
	group:insert(titleGroup)
	relayout.add(titleGroup)

	local title = 'JUEGO GAMERUN'
	local j = 1
	for i = -6, 6 do
		local character = display.newGroup()
		titleGroup:insert(character)
		local rect = display.newRect(character, 0, 0, 64, 64)
		rect.strokeWidth = 2
		rect:setFillColor(0.2)
		rect:setStrokeColor(0.8)

		local text = display.newText({--TIPO DE TEXTO DEL TITULO
			parent = character,
			text = title:sub(j, j),
			x = 0, y = 0,
			font = native.systemFontBold,
			fontSize = 64
		})
		text:setFillColor(0.8, 0.5, 0.2)

		character.x, character.y = i * 72, 0
		transition.from(character, {time = 500, delay = 100 * j, y = _H + 100, transition = easing.outExpo})
		j = j + 1
	end

	self.playButton = widget.newButton({
		defaultFile = 'images/buttons/play.png',
		overFile = 'images/buttons/play-over.png',
		width = 380, height = 200,
		x = 400 - 190, y = -200 - 100,
		onRelease = function()
			sonidos.play('tap')
			composer.gotoScene('esenas.seleccionar_nivel', {time = 500, effect = 'slideLeft'})
		end
	})
	group:insert(self.playButton)

	transition.to(self.playButton, {time = 1200, delay = 500, y = _H - 128 - self.playButton.height / 2, transition = easing.inExpo, onComplete = function(object1)
		transition.to(object1, {time = 800, x = _W - 64 - self.playButton.width / 2, transition = easing.outExpo, onComplete = function(object2)
			relayout.add(object2)
		end})
	end})

	local barra_lateral = newbarra_lateral({g = group, onHide = function()
		self:setVisualButtons()
	end})

	self.settingsButton = widget.newButton({
		defaultFile = 'images/buttons/settings.png',
		overFile = 'images/buttons/settings-over.png',
		width = 96, height = 105,
		x = 64 + 48, y = _H - 32 - 52,
		onRelease = function()
			sonidos.play('tap')
			barra_lateral:show()
		end
	})
	self.settingsButton.isRound = true
	group:insert(self.settingsButton)
	relayout.add(self.settingsButton)

	self:setVisualButtons()
	sonidos.playStream('menu_music')
end

function esena:setVisualButtons()
	controller.setVisualButtons({self.playButton, self.settingsButton})
end

-- Para Android's 
function esena:gotoPreviousScene()
	native.showAlert('Game Run', 'seguro quieres salir del juego?', {'Si', 'Cancelar'}, function(event)
		if event.action == 'clicked' and event.index == 1 then
			native.requestExit()
		end
	end)
end

function esena:show(event)
	if event.phase == 'did' then
		
		system.activate('controllerUserInteraction')
	end
end

function esena:hide(event)
	if event.phase == 'will' then
		
		system.deactivate('controllerUserInteraction')
	end
end

esena:addEventListener('create')
esena:addEventListener('show')
esena:addEventListener('hide')

return esena
