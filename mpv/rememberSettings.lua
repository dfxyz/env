local mp = require 'mp'
local utils = require 'mp.utils'

local stateFilePath = mp.command_native({'expand-path', '~~state/rememberSettings.json'})
local number_properties = {
    'volume',
    'brightness',
    'contrast',
    'saturation',
    'gamma',
}
local string_properties = {
    'glsl-shaders',
}

function loadAndRestoreState()
    local file = io.open(stateFilePath, 'r')
    if (file == nil) then
        return
    end
    local content = file:read('*all')
    file:close()
    if (content == nil) then
        return
    end
    local state = utils.parse_json(content)
    for _, property in pairs(number_properties) do
        local value = state[property]
        if (value ~= nil) then
            mp.set_property_number(property, value)
        end
    end
    for _, property in pairs(string_properties) do
        local value = state[property]
        if (value ~= nil) then
            mp.set_property(property, value)
        end
    end
end

function onShutdown()
    local state = {}
    for _, property in pairs(number_properties) do
        state[property] = mp.get_property_number(property)
    end
    for _, property in pairs(string_properties) do
        state[property] = mp.get_property(property)
    end
    local content = utils.format_json(state)
    local file = io.open(stateFilePath, 'w')
    file:write(content)
    file:close()
end

mp.register_event('shutdown', onShutdown)
loadAndRestoreState()
