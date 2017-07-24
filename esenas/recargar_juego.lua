

local composer = require('composer')
local relayout = require('libs.relayout')

local esena = composer.newScene()

function esena:create()
    local _W, _H, _CX, _CY = relayout._W, relayout._H, relayout._CX, relayout._CY

    local group = self.view

    local background = display.newRect(group, _CX, _CY, _W, _H)
    background.fill = {
        type = 'gradient',
        color1 = {0.2, 0.45, 0.8},
        color2 = {0.35, 0.4, 0.5}
    }
    relayout.add(background)

    local mensaje = display.newText({
		parent = group,
		text = 'CARGANDO...',
		x = _W - 32, y = _H - 32,
		font = native.systemFontBold,
		fontSize = 32
	})
    mensaje.anchorX, mensaje.anchorY = 1, 1
    relayout.add(mensaje)

    local bombasGroup = display.newGroup()
	bombasGroup.x, bombasGroup.y = _CX, _CY
	group:insert(bombasGroup)
	relayout.add(bombasGroup)

   
    for i = 0, 2 do
        local bomba = display.newImageRect(bombasGroup, 'images/ammo/normal.png', 64, 64)
        bomba.x, bomba.y = 0, 0
        bomba.anchorX = -0.5
        bomba.rotation = 120 * i
        transition.to(bomba, {time = 1500, rotation = 360, delta = true, iterations = -1})
    end
end

function esena:show(event)
    if event.phase == 'will' then
       
        composer.loadScene('esenas.juego', {params = event.params})
    elseif event.phase == 'did' then
       
        timer.performWithDelay(500, function()
            composer.gotoScene('esenas.juego', {params = event.params})
        end)
    end
end

esena:addEventListener('create')
esena:addEventListener('show')

return esena
