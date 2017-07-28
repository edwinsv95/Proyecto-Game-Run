

display.setStatusBar(display.HiddenStatusBar)
system.activate('multitouch')
if system.getInfo('build') >= '2015.2741' then 
	display.setDefault('isAnchorClamped', false) 
end

local plataforma = system.getInfo('platformName')
if plataforma== 'tvOS' then
	system.setIdleTimer(false)
end


if plataforma == 'Android' then
	native.setProperty('androidSystemUiVisibility', 'immersiveSticky')
end


if plataforma == 'Mac OS X' or plataforma == 'Win' then
	Runtime:addEventListener('key', function(event)
		if event.phase == 'down' and (
				(plataforma == 'Mac OS X' and event.keyName == 'f' and event.isCommandDown and event.isCtrlDown) or
					(plataforma == 'Win' and (event.keyName == 'f11' or (event.keyName == 'enter' and event.isAltDown)))
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
composer.setVariable('levelCount', 10) 


if platform == 'Android' or platform == 'WinPhone' then
	Runtime:addEventListener('key', function(event)
		if event.phase == 'down' and event.keyName == 'back' then
			local esena = composer.getScene(composer.getSceneName('current'))
            if esena then
				if type(esena.gotoPreviousScene) == 'function' then
                	esena:gotoPreviousScene()
                	return true
				elseif type(esena.gotoPreviousScene) == 'string' then
					composer.gotoScene(esena.gotoPreviousScene, {time = 500, effect = 'slideRight'})
					return true
				end
            end
		end
	end)
end

require('libs.controller') 

local databox = require('libs.databox')
databox({
	isSoundOn = true,
	isMusicOn = true,
	isHelpShown = false,
	overscanValue = 0
})


local sonidos = require('libs.sonidos')
sonidos.isSoundOn = databox.isSoundOn
sonidos.isMusicOn = databox.isMusicOn

require('libs.relayout')


local overscan = require('libs.overscan')
overscan.compensate(databox.overscanValue)


composer.gotoScene('esenas.menu')
