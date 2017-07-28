

local relayout = require('libs.relayout')

local _M = {}

function _M.newSombra(group)
	local sombra = display.newRect(group, relayout._CX, relayout._CY, relayout._W, relayout._H)
	sombra:setFillColor(0)
	sombra.alpha = 0
	transition.to(sombra, {time = 200, alpha = 0.5})

	
	function sombra:tap()
		return true
	end
	sombra:addEventListener('tap')

	
	function sombra:touch()
		return true
	end
	sombra:addEventListener('touch')

	function sombra:hide()
		transition.to(self, {time = 200, alpha = 0, onComplete = function(object)
			object:removeSelf()
		end})
	end

	relayout.add(sombra)

	return sombra
end

return _M
