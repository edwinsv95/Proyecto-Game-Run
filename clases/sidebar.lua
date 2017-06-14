

local composer = require('composer')
local widget = require('widget')
local controller = require('librerias.controller')
local databox = require('librerias.databox')
local overscan = require('librerias.overscan')
local relayout = require('librerias.relayout')
local sounds = require('librerias.sounds')

local _M = {}

local newShade = require('clases.shade').newShade

function _M.newSidebar(params)
	local _W, _CX, _CY = relayout._W, relayout._CX, relayout._CY

	local sidebar = display.newGroup()
	params.g:insert(sidebar)

	local background = display.newImageRect(sidebar, 'imagenes/sidebar.png', 160, 640)
	sidebar.x, sidebar.y = -background.width, _CY

	local visualButtons = {}

	local spacing = background.height / 6 + 12
	local start = -background.height / 2 + spacing / 2 + 24

	local resumeButton = widget.newButton({
		defaultFile = 'imagenes/buttons/resume.png',
		overFile = 'imagenes/buttons/resume-over.png',
		width = 96, height = 105,
		x = 0, y = start,
		onRelease = function()
			sounds.play('tap')
			sidebar:hide()
		end
	})
	resumeButton.isRound = true
	sidebar:insert(resumeButton)
	table.insert(visualButtons, resumeButton)

	if params.levelId then
	
		local restartButton = widget.newButton({
			defaultFile = 'imagenes/buttons/restart.png',
			overFile = 'imagenes/buttons/restart-over.png',
			width = 96, height = 105,
			x = 0, y = start + spacing,
			onRelease = function()
				sounds.play('tap')
				composer.gotoScene('escenas.reload_game', {params = params.levelId})
			end
		})
		restartButton.isRound = true
		sidebar:insert(restartButton)
		table.insert(visualButtons, restartButton)

		local menuButton = widget.newButton({
			defaultFile = 'imagenes/buttons/menu.png',
			overFile = 'imagenes/buttons/menu-over.png',
			width = 96, height = 105,
			x = 0, y = start + spacing * 2,
			onRelease = function()
				sounds.play('tap')
				composer.gotoScene('escenes.menu', {time = 500, effect = 'slideRight'})
			end
		})
		menuButton.isRound = true
		sidebar:insert(menuButton)
		table.insert(visualButtons, menuButton)
	else
	
		local overscanButton = widget.newButton({
			defaultFile = 'imagenes/buttons/overscan.png',
			overFile = 'imagenes/buttons/overscan-over.png',
			width = 96, height = 105,
			x = 0, y = start + spacing * 2,
			onRelease = function()
				sounds.play('tap')
				local value = overscan.value + 1
				if value > 3 then
					value = 0
				end
				databox.overscanValue = value
				overscan.compensate(value)
			end
		})
		overscanButton.isRound = true
		sidebar:insert(overscanButton)
		table.insert(visualButtons, overscanButton)
		overscanButton.isVisible = false
		sidebar.overscanButton = overscanButton
	end

	local soundsButtons = {}
	local musicButtons = {}


	local function updateDataboxAndVisibility()
		databox.isSoundOn = sounds.isSoundOn
		databox.isMusicOn = sounds.isMusicOn
		soundsButtons.on.isVisible = false
		soundsButtons.off.isVisible = false
		musicButtons.on.isVisible = false
		musicButtons.off.isVisible = false
		if databox.isSoundOn then
			soundsButtons.on.isVisible = true
		else
			soundsButtons.off.isVisible = true
		end
		if databox.isMusicOn then
			musicButtons.on.isVisible = true
		else
			musicButtons.off.isVisible = true
		end
	end

	musicButtons.on = widget.newButton({
		defaultFile = 'imagenes/buttons/music_on.png',
		overFile = 'imagenes/buttons/music_on-over.png',
		width = 96, height = 105,
		x = 0, y = start + spacing * 3,
		onRelease = function()
			sounds.play('tap')
			sounds.isMusicOn = false
			updateDataboxAndVisibility()
			if controller.isActive() then
				controller.selectVisualButton(musicButtons.off)
			end
			sounds.stop()
		end
	})
	musicButtons.on.isRound = true
	sidebar:insert(musicButtons.on)
	table.insert(visualButtons, musicButtons.on)

	musicButtons.off = widget.newButton({
		defaultFile = 'imagenes/buttons/music_off.png',
		overFile = 'imagenes/buttons/music_off-over.png',
		width = 96, height = 105,
		x = 0, y = musicButtons.on.y,
		onRelease = function()
			sounds.play('tap')
			sounds.isMusicOn = true
			updateDataboxAndVisibility()
			if controller.isActive() then
				controller.selectVisualButton(musicButtons.on)
			end
			if params.levelId then
				sounds.playStream('game_music')
			else
				sounds.playStream('menu_music')
			end
		end
	})
	musicButtons.off.isRound = true
	sidebar:insert(musicButtons.off)
	table.insert(visualButtons, musicButtons.off)

	soundsButtons.on = widget.newButton({
		defaultFile = 'imageness/buttons/sounds_on.png',
		overFile = 'imagenes/buttons/sounds_on-over.png',
		width = 96, height = 105,
		x = 0, y = start + spacing * 4,
		onRelease = function()
			sounds.play('tap')
			sounds.isSoundOn = false
			updateDataboxAndVisibility()
			if controller.isActive() then
				controller.selectVisualButton(soundsButtons.off)
			end
		end
	})
	soundsButtons.on.isRound = true
	sidebar:insert(soundsButtons.on)
	table.insert(visualButtons, soundsButtons.on)

	soundsButtons.off = widget.newButton({
		defaultFile = 'imagenes/buttons/sounds_off.png',
		overFile = 'imagenes/buttons/sounds_off-over.png',
		width = 96, height = 105,
		x = 0, y = soundsButtons.on.y,
		onRelease = function()
			sounds.play('tap')
			sounds.isSoundOn = true
			updateDataboxAndVisibility()
			if controller.isActive() then
				controller.selectVisualButton(soundsButtons.on)
			end
		end
	})
	soundsButtons.off.isRound = true
	sidebar:insert(soundsButtons.off)
	table.insert(visualButtons, soundsButtons.off)

	updateDataboxAndVisibility()

	local badge = display.newImageRect(sidebar, 'imagenes/badge.png', 200, 279)
	badge.anchorX, badge.anchorY = 1, 1
	badge.x, badge.y = _W - background.width / 2 - 16, background.height / 2 - 16
	badge.isVisible = false
	function badge:touch(event)
		if event.phase == 'began' then
			display.getCurrentStage():setFocus(self, event.id)
			self.isFocused = true
		elseif self.isFocused then
			if event.phase ~= 'moved' then
				display.getCurrentStage():setFocus(self, nil)
				self.isFocused = false
				
			end
		end
		return true
	end
	badge:addEventListener('touch')

	local appleTvRemoteHelp = display.newImageRect(sidebar, 'imagenes/controls/apple_tv_remote.png', 500, 500)
	appleTvRemoteHelp.x, appleTvRemoteHelp.y = _CX - background.width / 2, 0
	appleTvRemoteHelp.isVisible = false

	local razerServalHelp = display.newImageRect(sidebar, 'imagenes/controls/razer_serval.png', 500, 500)
	razerServalHelp.x, razerServalHelp.y = appleTvRemoteHelp.x, appleTvRemoteHelp.y
	razerServalHelp.isVisible = false

	local gamepadHelp = display.newImageRect(sidebar, 'imagenes/controls/gamepad.png', 500, 500)
	gamepadHelp.x, gamepadHelp.y = appleTvRemoteHelp.x, appleTvRemoteHelp.y
	gamepadHelp.isVisible = false

	local touchScreenHelp = display.newImageRect(sidebar, 'imagenes/controls/touchscreen.png', 500, 500)
	touchScreenHelp.x, touchScreenHelp.y = appleTvRemoteHelp.x, appleTvRemoteHelp.y
	touchScreenHelp.isVisible = false
--0000000000000000000000000------------------------------------------------------

	function sidebar:show()
		self.shade = newShade(params.g)
		self:toFront()
		badge.isVisible = true
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
			touchScreenHelp.isVisible = true
		end
		if self.overscanButton and (controller.isActive() or showOverscanButton) then
			self.overscanButton.isVisible = true
		end
		controller.setVisualButtons(visualButtons)
		if params.levelId then
			databox.isHelpShown = true
		end
		transition.to(self, {time = 250, x = background.width / 2, transition = easing.outExpo})
	end

	function sidebar:hide()
		self.shade:hide()
		badge.isVisible = false
		appleTvRemoteHelp.isVisible = false
		razerServalHelp.isVisible = false
		gamepadHelp.isVisible = false
		touchScreenHelp.isVisible = false
		transition.to(self, {time = 250, x = -background.width, transition = easing.outExpo, onComplete = params.onHide})
	end

	function sidebar:relayout()
		sidebar.y = relayout._CY
		appleTvRemoteHelp.x = relayout._CX - background.width / 2
		razerServalHelp.x = appleTvRemoteHelp.x
		gamepadHelp.x = appleTvRemoteHelp.x
		touchScreenHelp.x = appleTvRemoteHelp.x
		badge.x = relayout._W - background.width / 2 - 16
	end

	relayout.add(sidebar)

	return sidebar
end

return _M
