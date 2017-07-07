

display.setStatusBar(display.HiddenStatusBar)
system.activate('multitouch')
if system.getInfo('build') >= '2015.2741' then 
	display.setDefault('isAnchorClamped', false) 
end

local platform = system.getInfo('platformName')
if platform == 'tvOS' then
	system.setIdleTimer(false)
end


if platform == 'Android' then
	native.setProperty('androidSystemUiVisibility', 'immersiveSticky')
end


if platform == 'Mac OS X' or platform == 'Win' then
	Runtime:addEventListener('key', function(event)
		if event.phase == 'down' and (
				(platform == 'Mac OS X' and event.keyName == 'f' and event.isCommandDown and event.isCtrlDown) or
					(platform == 'Win' and (event.keyName == 'f11' or (event.keyName == 'enter' and event.isAltDown)))
			) then
			if native.getProperty('windowMode') == 'fullscreen' then
				native.setProperty('windowMode', 'normal')
			else
				native.setProperty('windowMode', 'fullscreen')
			end
		end
	end)
end

local composer = require('composer')
composer.recycleOnSceneChange = true 
composer.setVariable('levelCount', 10) --contador de niveles 


if platform == 'Android' or platform == 'WinPhone' then
	Runtime:addEventListener('key', function(event)
		if event.phase == 'down' and event.keyName == 'back' then
			local scene = composer.getScene(composer.getSceneName('current'))
            if scene then
				if type(scene.gotoPreviousScene) == 'function' then
                	scene:gotoPreviousScene()
                	return true
				elseif type(scene.gotoPreviousScene) == 'string' then
					composer.gotoScene(scene.gotoPreviousScene, {time = 500, effect = 'slideRight'})
					return true
				end
            end
		end
	end)
end


require('librerias.controller') 


local databox = require('librerias.databox')
databox({
	isSoundOn = true,
	isMusicOn = true,
	isHelpShown = false,
	overscanValue = 0
})

---sonido
local sounds = require('librerias.sounds')
sounds.isSoundOn = databox.isSoundOn
sounds.isMusicOn = databox.isMusicOn


require('librerias.relayout')


local overscan = require('librerias.overscan')
overscan.compensate(databox.overscanValue)


composer.gotoScene('escenas.menu')--llamando a la clase es
