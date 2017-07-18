

local json = require('json')
local iCloud

local dato = {}
local defaultData = {}

local path = system.pathForFile('databox.json', system.DocumentsDirectory)
local isiOS = system.getInfo('platformName') == 'iPhone OS'
local istvOS = system.getInfo('platformName') == 'tvOS'
local isOSX = system.getInfo('platformName') == 'Mac OS X'

if isiOS or istvOS or isOSX then
    iCloud = require('plugin.iCloud')
end


local function shallowcopy(t)
    local copiar = {}
    for k, v in pairs(t) do
        if type(k) == 'string' then
            if type(v) == 'number' or type(v) == 'string' or type(v) == 'boolean' then
                copiar[k] = v
            else
                print('databox: Values of type "' .. type(v) .. '" are not supported.')
            end
        end
    end
    return copiar
end


local function saveData()
    if iCloud then
        iCloud.set('databox', dato)
    end
    if not istvOS then
        local file = io.open(path, 'w')
        if file then
            file:write(json.encode(dato))
            io.close(file)
        end
    end
end


local function loadData()
    local iCloudData
    if iCloud then
        iCloudData = iCloud.get('databox')
    end
    if iCloudData then
        dato = iCloudData
    else
        if istvOS then
            dato = shallowcopy(defaultData)
            saveData()
        else
            local file = io.open(path, 'r')
            if file then
              dato = json.decode(file:read('*a'))
                io.close(file)
            else
               dato= shallowcopy(defaultData)
                saveData()
            end
        end
    end
end


local function patchIfNewDefaultData()
    local isPatched = false
    for k, v in pairs(defaultData) do
        if dato[k] == nil then
            dato[k] = v
            isPatched = true
        end
    end
    if isPatched then
        saveData()
    end
end


local mt = {
    __index = function(t, k) 
        return dato[k]
    end,
    __newindex = function(t, k, value) 
        dato[k] = value
        saveData()
    end,
    __call = function(t, value) 
        if type(value) == 'table' then
            defaultData = shallowcopy(value)
        end
        loadData()
        patchIfNewDefaultData()
    end
}

local _M = {}
setmetatable(_M, mt)
return _M
