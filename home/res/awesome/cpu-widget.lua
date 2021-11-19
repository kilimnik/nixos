local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local spawn = require("awful.spawn")
local watch = require("awful.widget.watch")
local wibox = require("wibox")
local lain  = require("lain")

local widget = {}
local i = 0
local function worker(args)

    local cpu_ramp_foreground = {}
    cpu_ramp_foreground[1] = "#aaff77"
    cpu_ramp_foreground[2] = "#aaff77"
    cpu_ramp_foreground[3] = "#aaff77"
    cpu_ramp_foreground[4] = "#aaff77"
    cpu_ramp_foreground[5] = "#fba922"
    cpu_ramp_foreground[6] = "#fba922"
    cpu_ramp_foreground[7] = "#ff5555"
    cpu_ramp_foreground[8] = "#ff5555"

    function create_cpu_core_bar_widget()
        return wibox.widget {
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
    end

    local cpu_widget = {
        layout = wibox.layout.fixed.horizontal,
    }

    local cpu = lain.widget.cpu({
        timeout = 0.5,
        settings = function()
            local s = ""
            for i,v in ipairs(cpu_now) do
                if (cpu_widget[i] == nil) then
                    cpu_widget[i] = create_cpu_core_bar_widget()

                    cpu_widget[i]:buttons(awful.util.table.join (
                        awful.button({}, 1, function()
                            awful.spawn.raise_or_spawn(string.format("%s -e htop", awful.util.terminal), {
                                name = "htop",
                                floating = true,
                                dockable = false,
                                requests_no_titlebar = true,
                                skip_taskbar = true,
                                titlebars_enabled = false,
                                ontop = true
                            }, function(c) return c.class == "htop" end, "spawned_htop")
                        end)
                    ))
                end

                cpu_widget[i].widget.value = v.usage
                
                c = math.floor(v.usage / (100 / #cpu_ramp_foreground)) + 1
                cpu_widget[i].widget.color = cpu_ramp_foreground[c]
            end
        end
    })

    return cpu_widget
end

return setmetatable(widget, { __call = function(_, ...)
    return worker(...)
end })