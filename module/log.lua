local naughty = require('naughty')

return function(info)
    naughty.notify({
        preset = naughty.config.presets.info,
        title = "Info",
        text = tostring(info)
    })
end
