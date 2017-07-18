
local composer = require('composer')
local relayout = require('libs.relayout')

local _M = {}

_M.value = 0 -- nivel de compensacion: 0, 1, 2, 3.

local function getVericies(h, v)
  
    local _W, _H = relayout._W, relayout._H
    local vertices = {
        0,0, _W,0, _W,_H, 0,_H,
        0,v, h,v, h,_H-v, _W-h,_H-v, _W-h,v-0.001, 0,v-0.001 
    }
    return vertices
end

function _M.compensate(value)
    local self = _M
    local _W, _H, _CX, _CY = relayout._W, relayout._H, relayout._CX, relayout._CY
    self.value = value
    local porcentage = self.value * 0.025

    if self.overlay then
        self.overlay:removeSelf()
        self.overlay = nil
    end
    if self.value > 0 then
      
        self.overlay = display.newPolygon(_CX, _CY, getVericies(porcentage * _W, porcentage * _H))
        self.overlay:setFillColor(0)
    end

  
    local esenario = composer.stage
    esenario.xScale = 1 - porcentage * 2
    esenario.yScale = esenario.xScale
    esenario.x, esenario.y = porcentage * _W, porcentage * _H
end

return _M
