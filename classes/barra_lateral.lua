

local composer = require('composer')
local widget = require('widget')
local controller = require('libs.controller')
local databox = require('libs.databox')
local overscan = require('libs.overscan')
local relayout = require('libs.relayout')
local sonidos = require('libs.sonidos')

local _M = {}

local newSombra = require('classes.sombra').newSombra

function _M.newbarra_lateral(dato)
	local _W, _CX, _CY = relayout._W, relayout._CX, relayout._CY

	local barra_lateral = display.newGroup()
	dato.g:insert(barra_lateral)

	local background = display.newImageRect(barra_lateral, 'images/sidebar.png', 160, 640)
	barra_lateral.x, barra_lateral.y = -background.width, _CY

	local visualButtons = {}

	local espaciado = background.height / 6 + 12
	local comienzo = -background.height / 2 + espaciado  / 2 + 24

	local botonReanudar = widget.newButton({
		defaultFile = 'images/buttons/resume.png',
		overFile = 'images/buttons/resume-over.png',
		width = 96, height = 105,
		x = 0, y = comienzo,
		onRelease = function()
			sonidos.play('tap')
			barra_lateral:hide()
		end
	})
	botonReanudar.isRound = true
	barra_lateral:insert(botonReanudar)
	table.insert(visualButtons, botonReanudar)

	if dato.levelId then
	
		local botonReiniciar = widget.newButton({
			defaultFile = 'images/buttons/restart.png',
			overFile = 'images/buttons/restart-over.png',
			width = 96, height = 105,
			x = 0, y = comienzo + espaciado ,
			onRelease = function()
				sonidos.play('tap')
				composer.gotoScene('esenas.recargar_juego', {dato = dato.levelId})
			end
		})
		botonReiniciar.isRound = true
		barra_lateral:insert(botonReiniciar)
		table.insert(visualButtons, botonReiniciar)

		local menuButon = widget.newButton({
			defaultFile = 'images/buttons/menu.png',
			overFile = 'images/buttons/menu-over.png',
			width = 96, height = 105,
			x = 0, y = comienzo + espaciado  * 2,
			onRelease = function()
				sonidos.play('tap')
				composer.gotoScene('esenas.menu', {time = 500, effect = 'slideRight'})
			end
		})
		menuButon.isRound = true
		barra_lateral:insert(menuButon)
		table.insert(visualButtons, menuButon)
	else
	
		local overscanButton = widget.newButton({
			defaultFile = 'images/buttons/overscan.png',
			overFile = 'images/buttons/overscan-over.png',
			width = 96, height = 105,
			x = 0, y = comienzo + espaciado * 2,
			onRelease = function()
				sonidos.play('tap')
				local value = overscan.value + 1
				if value > 3 then
					value = 0
				end
				databox.overscanValue = value
				overscan.compensate(value)
			end
		})
		overscanButton.isRound = true
		barra_lateral:insert(overscanButton)
		table.insert(visualButtons, overscanButton)
		overscanButton.isVisible = false
		barra_lateral.overscanButton = overscanButton
	end

	local boton_sonido = {}
	local boton_musica = {}

	
	local function updateDataboxAndVisibility()
		databox.isSoundOn = sonidos.isSoundOn
		databox.isMusicOn = sonidos.isMusicOn
		boton_sonido.on.isVisible = false
		boton_sonido.off.isVisible = false
		boton_musica.on.isVisible = false
		boton_musica.off.isVisible = false
		if databox.isSoundOn then
			boton_sonido.on.isVisible = true
		else
			boton_sonido.off.isVisible = true
		end
		if databox.isMusicOn then
			boton_musica.on.isVisible = true
		else
			boton_musica.off.isVisible = true
		end
	end

	boton_musica.on = widget.newButton({
		defaultFile = 'images/buttons/music_on.png',
		overFile = 'images/buttons/music_on-over.png',
		width = 96, height = 105,
		x = 0, y = comienzo + espaciado  * 3,
		onRelease = function()
			sonidos.play('tap')
			sonidos.isMusicOn = false
			updateDataboxAndVisibility()
			if controller.isActive() then
				controller.selectVisualButton(boton_musica.off)
			end
			sonidos.stop()
		end
	})
	boton_musica.on.isRound = true
	barra_lateral:insert(boton_musica.on)
	table.insert(visualButtons, boton_musica.on)

	boton_musica.off = widget.newButton({
		defaultFile = 'images/buttons/music_off.png',
		overFile = 'images/buttons/music_off-over.png',
		width = 96, height = 105,
		x = 0, y = boton_musica.on.y,
		onRelease = function()
			sonidos.play('tap')
			sonidos.isMusicOn = true
			updateDataboxAndVisibility()
			if controller.isActive() then
				controller.selectVisualButton(boton_musica.on)
			end
			if dato.levelId then
				sonidos.playStream('game_music')
			else
				sonidos.playStream('menu_music')
			end
		end
	})
	
boton_musica.off.isRound = true
	barra_lateral:insert(boton_musica.off)
	table.insert(visualButtons, boton_musica.off)

	boton_sonido.on = widget.newButton({
		defaultFile = 'images/buttons/sounds_on.png',
		overFile = 'images/buttons/sounds_on-over.png',
		width = 96, height = 105,
		x = 0, y = comienzo + espaciado  * 4,
		onRelease = function()
			sonidos.play('tap')
			sonidos.isSoundOn = false
			updateDataboxAndVisibility()
			if controller.isActive() then
				controller.selectVisualButton(boton_sonido.off)
			end
		end
	})
	boton_sonido.on.isRound = true
	barra_lateral:insert(boton_sonido.on)
	table.insert(visualButtons, boton_sonido.on)

	boton_sonido.off = widget.newButton({
		defaultFile = 'images/buttons/sounds_off.png',
		overFile = 'images/buttons/sounds_off-over.png',
		width = 96, height = 105,
		x = 0, y = boton_sonido.on.y,
		onRelease = function()
			sonidos.play('tap')
			sonidos.isSoundOn = true
			updateDataboxAndVisibility()
			if controller.isActive() then
				controller.selectVisualButton(boton_sonido.on)
			end
		end
	})
	boton_sonido.off.isRound = true
	barra_lateral:insert(boton_sonido.off)
	table.insert(visualButtons, boton_sonido.off)

	updateDataboxAndVisibility()

	

	local appleTvRemoteHelp = display.newImageRect(barra_lateral, 'images/controls/apple_tv_remote.png', 500, 500)
	appleTvRemoteHelp.x, appleTvRemoteHelp.y = _CX - background.width / 2, 0
	appleTvRemoteHelp.isVisible = false

	local razerServalHelp = display.newImageRect(barra_lateral, 'images/controls/razer_serval.png', 500, 500)
	razerServalHelp.x, razerServalHelp.y = appleTvRemoteHelp.x, appleTvRemoteHelp.y
	razerServalHelp.isVisible = false

	local gamepadHelp = display.newImageRect(barra_lateral, 'images/controls/gamepad.png', 500, 500)
	gamepadHelp.x, gamepadHelp.y = appleTvRemoteHelp.x, appleTvRemoteHelp.y
	gamepadHelp.isVisible = false

	--local touchScreenHelp = display.newImageRect(barra_lateral, 'images/controls/touchscreen.png', 500, 500)
	--touchScreenHelp.x, touchScreenHelp.y = appleTvRemoteHelp.x, appleTvRemoteHelp.y
	--touchScreenHelp.isVisible = false

	function barra_lateral:show()
		self.sombra = newSombra(dato.g)
		self:toFront()
		

		local showOverscanButton = false
		if system.getInfo('platformName') == 'tvOS' then
			appleTvRemoteHelp.isVisible = true
			showOverscanButton = true
		elseif system.getInfo('targetAppStore') == 'ouya' then
			razerServalHelp.isVisible = true
			showOverscanButton = true
		elseif controller.isActive() then
			gamepadHelp.isVisible = true
			showOverscanButton = true
		else
			--touchScreenHelp.isVisible = true
		end
		if self.overscanButton and (controller.isActive() or showOverscanButton) then
			self.overscanButton.isVisible = true
		end
		controller.setVisualButtons(visualButtons)
		if dato.levelId then
			databox.isHelpShown = true
		end
		transition.to(self, {time = 250, x = background.width / 2, transition = easing.outExpo})
	end

	function barra_lateral:hide()
		self.sombra:hide()
		
		appleTvRemoteHelp.isVisible = false
		razerServalHelp.isVisible = false
		gamepadHelp.isVisible = false
		--touchScreenHelp.isVisible = false
		transition.to(self, {time = 250, x = -background.width, transition = easing.outExpo, onComplete = dato.onHide})
	end

	function barra_lateral:relayout()
		barra_lateralr.y = relayout._CY
		appleTvRemoteHelp.x = relayout._CX - background.width / 2
		razerServalHelp.x = appleTvRemoteHelp.x
		gamepadHelp.x = appleTvRemoteHelp.x
		--touchScreenHelp.x = appleTvRemoteHelp.x
		

	end

	relayout.add(barra_lateral)

	return barra_lateral
end

return _M