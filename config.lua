local normalW, normalH = 640, 960

if not display then return end 


local w, h = display.pixelWidth, display.pixelHeight
local scale = math.max(normalW / w, normalH / h)
w, h = w * scale, h * scale

application = {
    content = {
		width = w,
        height = h,
        scale = 'letterbox',
        fps = 60,
        imageSuffix = {
			['@2x'] = 1.1,
            --['@4x'] = 2.1
		}
    }
}
