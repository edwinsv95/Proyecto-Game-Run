

local _M = {}

_M.isSoundOn = true
_M.isMusicOn = true

local sonidos = {
    menu_music = 'sonidos/menu_music.mp3',
    game_music = 'sonidos/game_music.mp3',
    tap = 'sonidos/tap.wav',
    bug = 'sonidos/bug.wav',
    cannon_touch = 'sonidos/cannon_touch.wav',
    ball_destroy = 'sonidos/ball_destroy.wav',
	explosion = 'sonidos/explosion.wav',
	poof = 'sonidos/poof.wav',
	impact = 'sonidos/impact.wav',
	cannon = 'sonidos/cannon.wav',
	win = 'sonidos/win.wav',
	lose = 'sonidos/lose.wav'
}


local audioChannel, otherAudioChannel, currentStreamSound = 1, 2
function _M.playStream(sound, force)
    if not _M.isMusicOn then return end
    if not sonidos[sound] then
        print('sonidos: No hay sonidos Disponibles: ' .. tostring(sound))
        return
    end
    sound = sonidos[sound]
    if currentStreamSound == sound and not force then return end
    audio.fadeOut({channel = audioChannel, time = 1000})
    audioChannel, otherAudioChannel = otherAudioChannel, audioChannel
    audio.setVolume(0.5, {channel = audioChannel})
    audio.play(audio.loadStream(sound), {channel = audioChannel, loops = -1, fadein = 1000})
    currentStreamSound = sound
end
audio.reserveChannels(2)


local cargarSonidos = {}
local function loadSound(sound)
    if not cargarSonidos[sound] then
        cargarSonidos[sound] = audio.loadSound(sonidos[sound])
    end
    return cargarSonidos[sound]
end

function _M.play(sound, params)
    if not _M.isSoundOn then return end
    if not sonidos[sound] then
        print('sonidos: No hay sonidos: ' .. tostring(sound))
        return
    end
    return audio.play(loadSound(sound), params)
end

function _M.stop()
    currentStreamSound = nil
    audio.stop()
end

return _M
