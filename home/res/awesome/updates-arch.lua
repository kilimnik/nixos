local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local spawn = require("awful.spawn")
local watch = require("awful.widget.watch")
local wibox = require("wibox")

local widget = {}
local i = 0
local function worker(args)

    local args = args or {}

    local main_color = args.main_color or beautiful.fg_normal
    local cmd  = args.cmd or 'checkupdates+aur'

    local updates_widget = wibox.widget{
        markup = '0 updates',
        align  = 'center',
        valign = 'center',
        widget = wibox.widget.textbox
    }

    local lastUpdateCount = 0
    local update_text = function(widget, stdout, _, _, _)
        local _, count = stdout:gsub('\n', '\n')
        
        lastUpdateCount = count
        if (lastUpdateCount == 1) then
            updates_widget.markup = lastUpdateCount .. ' update'
        else
            updates_widget.markup = lastUpdateCount .. ' updates'
        end
    end

    updates_widget:buttons(awful.util.table.join (
        awful.button({}, 1, function()
            if (lastUpdateCount > 0) then
                awful.spawn.raise_or_spawn(string.format('%s -e sh -c "checkupdates+aur; yay -Syu"', awful.util.terminal), {
                    name = "yay",
                    floating = true,
                    dockable = false,
                    requests_no_titlebar = true,
                    skip_taskbar = true,
                    titlebars_enabled = false,
                    ontop = true
                }, function(c) return c.class == "yay" end, "spawned_yay")
            end
        end)
    ))

    watch(cmd, 30, update_text, updates_widget)

    return updates_widget
end

return setmetatable(widget, { __call = function(_, ...)
    return worker(...)
end })