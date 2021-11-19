local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local spawn = require("awful.spawn")
local watch = require("awful.widget.watch")
local wibox = require("wibox")
local lain  = require("lain")
local json = require("json")
local naughty = require("naughty")

local widget = {}
local theme                                     = {}
theme.font                                      = "Monospace 8"

theme.icon_dir                                  = os.getenv("HOME") .. "/.config/awesome/icons"
theme.mic                                       = theme.icon_dir .. "/microphone.png"
theme.mic_off                                   = theme.icon_dir .. "/microphone-off.png"

local function worker(args)
    local cmd  = 'bash -c "echo | netcat localhost 6878"'

    local percentage_ramp_foreground = {}
    percentage_ramp_foreground[1] = "#aaff77"
    percentage_ramp_foreground[2] = "#aaff77"
    percentage_ramp_foreground[3] = "#aaff77"
    percentage_ramp_foreground[4] = "#aaff77"
    percentage_ramp_foreground[5] = "#fba922"
    percentage_ramp_foreground[6] = "#fba922"
    percentage_ramp_foreground[7] = "#ff5555"
    percentage_ramp_foreground[8] = "#ff5555"

    local percentage_bar = wibox.widget {
        {
            max_value = 100,
            value = 0,
            forced_height = 15,
            forced_width = 25,
            paddings = 0,
            margins = {
                top = 1,
                bottom = 1,
            },
            border_width = 0,
            border_color = beautiful.bg_focus,
            background_color = beautiful.bg_normal,
            bar_border_width = 0,
            bar_border_color = beautiful.bg_focus,
            widget = wibox.widget.progressbar
        },
        direction = 'east',
        layout = wibox.container.rotate
    }
    local mic_icon = wibox.widget.imagebox()

    local hyperx_widget = wibox.widget {
        layout = wibox.layout.fixed.horizontal,
        mic_icon,
        wibox.widget.textbox('  '),
        percentage_bar
    }

    local temp_percentage = 0
    local update_percentage = function(widget, percentage)
        if (percentage == -1) then
            temp_percentage = (temp_percentage + 10) % 100
        else
            temp_percentage = percentage
        end

        widget.widget.value = temp_percentage
                
        c = 8 - math.floor(temp_percentage / (100 / #percentage_ramp_foreground)) + 1
        widget.widget.color = percentage_ramp_foreground[c]
    end

    local update_level = function(level)
        if (level > 0) then
            awful.util.spawn("amixer -D pulse sset Master " .. level .. "%+")
        elseif (level < 0) then
            awful.util.spawn("amixer -D pulse sset Master " .. (level * -1) .. "%-")
        end
    end

    local update = function(widget, stdout, _, _, _)
        x = json.parse(stdout)

        local bat_percentage = tonumber(x.bat_level)
        update_percentage(percentage_bar, bat_percentage)

        local volume_level_change = tonumber(x.audio_level_change)
        update_level(volume_level_change)

        if (x.muted) then
            mic_icon:set_image(theme["mic_off"])
        else
            mic_icon:set_image(theme["mic"])
        end
        
    end
    watch(cmd, 0.1, update, hyperx_widget)

    return hyperx_widget
end

return setmetatable(widget, { __call = function(_, ...)
    return worker(...)
end })