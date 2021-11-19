local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local spawn = require("awful.spawn")
local watch = require("awful.widget.watch")
local wibox = require("wibox")
local lain  = require("lain")

local widget = {}
local theme                                     = {}
theme.font                                      = "Monospace 8"

local function worker(args)

    local ram_ramp_foreground = {}
    ram_ramp_foreground[1] = "#aaff77"
    ram_ramp_foreground[2] = "#aaff77"
    ram_ramp_foreground[3] = "#fba922"
    ram_ramp_foreground[4] = "#ff5555"

    local ram_widget_bar = wibox.widget {
        max_value = 100,
        value = 0,
        forced_height = 15,
        forced_width = 150,
        ticks_size = 0.1,
        border_width = 0,
        border_color = beautiful.bg_focus,
        background_color = args.background .. beautiful.bg_normal,
        bar_border_width = 0,
        bar_border_color = beautiful.bg_focus,
        widget = wibox.widget.progressbar
    }

    local ram_widget_text = wibox.widget {
        forced_height = 15,
        forced_width = 150,
        align = 'center',
        valign = 'center',
        widget = wibox.widget.textbox
    }

    local ram_widget = wibox.widget {
        layout  = wibox.layout.stack,
        ram_widget_bar,
        ram_widget_text
    }

    local markup = lain.util.markup

    local mem = lain.widget.mem({
        timeout = 0.5,
        settings = function()
            ram_widget_bar.value = mem_now.perc
                
            c = math.floor(mem_now.perc / (100 / #ram_ramp_foreground)) + 1
            ram_widget_bar.color = ram_ramp_foreground[c]

            ram_widget_text.markup = markup.fontfg(theme.font, "#ffffff", string.format("%.2f", (mem_now.used / 1024)) .. ' GiB /' .. string.format("%.2f", (mem_now.total/ 1024)) .. ' GiB')
        end
    })

    return ram_widget
end

return setmetatable(widget, { __call = function(_, ...)
    return worker(...)
end })