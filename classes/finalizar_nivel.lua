

local composer = require('composer')
local widget = require('widget')
local controller = require('libs.controller')
local relayout = require('libs.relayout')
local sonidos = require('libs.sonidos')

local _M = {}

local newSombra = require('classes.sombra').newSombra

function _M.newEndLevelPopup(dato)
	local popup = display.newGroup()
	dato.g:insert(popup)

	local background = display.newImageRect(popup, 'images/end_level.png', 480, 480)
	popup.x, popup.y = relayout._CX, -background.height

	local visualButtons = {}

	local label = display.newText({
		parent = popup,
		text = '',
		x = 0, y = -80,
		font = native.systemFontBold,
		fontSize = 64
	})

	local menuButon = widget.newButton({
		defaultFile = 'images/buttons/menu.png',
		overFile = 'images/buttons/menu-over.png',
		width = 96, height = 105,
		x = -120, y = 80,
		onRelease = function()
			sonidos.play('tap')
			composer.gotoScene('esenas.menu', {time = 500, effect = 'slideRight'})
		end
	})
	menuButon.isRound = true
	popup:insert(menuButon)
	table.insert(visualButtons, menuButon)

	local boton_reiniciar = widget.newButton({
		defaultFile = 'images/buttons/restart.png',
		overFile = 'images/buttons/restart-over.png',
		width = 96, height = 105,
		x = 0, y = menuButon.y,
		onRelease = function()
			sonidos.play('tap')
			composer.gotoScene('esenas.recargar_juego', {params = dato.levelId})
		end
	})
	boton_reiniciar.isRound = true
	popup:insert(boton_reiniciar)
	table.insert(visualButtons, boton_reiniciar)


	if dato.levelId < composer.getVariable('levelCount') then
		local nextButton = widget.newButton({
			defaultFile = 'images/buttons/resume.png',
			overFile = 'images/buttons/resume-over.png',
			width = 96, height = 105,
			x = -menuButon.x, y = menuButon.y,
			onRelease = function()
				sonidos.play('tap')
				composer.gotoScene('esenas.recargar_juego', {params = dato.levelId + 1})
			end
		})
		nextButton.isRound = true
		popup:insert(nextButton)
		table.insert(visualButtons, nextButton)
	end

	local superdato = dato
	function popup:show(dato)
		
		self.sombra = newSombra(superdato.g)
		self:toFront()

		if dato.isWin then
			label.text = 'Ganaste!'--MENSAJE DE ADVERTENCIA
		else
			label.text = 'Perdiste!'
		end

		controller.setVisualButtons(visualButtons)
		self.x = relayout._CX
		transition.to(self, {time = 250, y = relayout._CY, transition = easing.outExpo, onComplete = function()
			relayout.add(self)
		end})
	end

	return popup
end

return _M
