local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local spawn = require("awful.spawn")
local watch = require("awful.widget.watch")
local wibox = require("wibox")
local naughty  = require("naughty")

local theme = {}
theme.icon_dir                                  = os.getenv("HOME") .. "/.config/awesome/icons"
theme.volhigh                                   = theme.icon_dir .. "/volume-high.png"
theme.vollow                                    = theme.icon_dir .. "/volume-low.png"
theme.volmed                                    = theme.icon_dir .. "/volume-medium.png"
theme.volmutedblocked                           = theme.icon_dir .. "/volume-muted-blocked.png"
theme.voloff                                    = theme.icon_dir .. "/volume-off.png"
local notification = nil

local widget = {}
local i = 0
local function worker(args)
    local my_table = awful.util.table or gears.table -- 4.{0,1} compatibility

    local volumeCmd = "bash -c \"pamixer --get-volume-human\""
    local cmd = "pamixer"

    local volicon = wibox.widget.imagebox()

    local volume = 0
    local muted = false
    local show_notify = function(_, stdout, _, _, _)
        local m = muted
        local v = volume

        local res = stdout:sub(0, -2)
        if res == "muted" then
            m = true
        else
            m = false
            v = tonumber(res:sub(0, -2))
        end

        if (v ~= volume or m ~= muted) then
            volume = v
            muted = m
            
            local preset = { 
                font = "Monospace 12", 
                fg = theme.fg_normal,
                title = string.format("%s%%", volume),
                screeen = awful.screen.focused()
            }

            local tot = 20
            local wib = awful.screen.focused().mywibox
            -- if we can grab mywibox, tot is defined as its height if
            -- horizontal, or width otherwise
            if wib then
                if wib.position == "left" or wib.position == "right" then
                    tot = wib.width
                else
                    tot = wib.height
                end
            end

            local int = math.modf((volume / 100) * tot)
            preset.text = string.format(
                "%s%s%s%s",
                "[",
                string.rep("|", int),
                string.rep(" ", tot - int),
                "]"
            )

            local index = ""
            
            if muted then
                preset.title = preset.title .. " Muted"

                index = "volmutedblocked"
            else
                if volume <= 5 then
                    index = "voloff"
                elseif volume <= 25 then
                    index = "vollow"
                elseif volume <= 75 then
                    index = "volmed"
                else
                    index = "volhigh"
                end
            end

            volicon:set_image(theme[index])

            local x = math.modf((tot - string.len(preset.title)) / 2)

            preset.title = string.format(
                "%s%s%s",
                string.rep(" ", x),
                preset.title,
                string.rep(" ", x)
            )

            if notification == nil then
                notification = naughty.notify {
                    preset  = preset,
                    destroy = function() notification = nil end
                }
            else
                naughty.replace_text(notification, preset.title, preset.text)
            end
        end
    end
    watch(volumeCmd, 0.1, show_notify)

    volicon:buttons(my_table.join (
            awful.button({}, 1, function()
                awful.spawn.raise_or_spawn(string.format('%s -e ncpamixer', awful.util.terminal), {
                    name = "ncpamixer",
                    floating = true,
                    dockable = false,
                    requests_no_titlebar = true,
                    skip_taskbar = true,
                    titlebars_enabled = false,
                    ontop = true
                }, function(c) return c.class == "ncpamixer" end, "spawned_ncpamixer")
            end),
            awful.button({}, 3, function()
                os.execute(string.format("%s --toggle-mute", cmd))
            end),
            awful.button({}, 4, function()
                os.execute(string.format("%s --increase 5", cmd))
            end),
            awful.button({}, 5, function()
                os.execute(string.format("%s --decrease 5", cmd))
            end)
    ))

    return {widget = volicon,
            keys = gears.table.join(
                awful.key({}, 'XF86AudioRaiseVolume', function () 
                    awful.util.spawn(string.format("%s --increase 1", cmd))
                    end,
                    {description = 'volume up', group = 'hotkeys'}),
                awful.key({}, 'XF86AudioLowerVolume', function ()
                    awful.util.spawn(string.format("%s --decrease 1", cmd))
                    end,
                    {description = 'volume down', group = 'hotkeys'}),
                awful.key({}, 'XF86AudioMute', function ()
                    awful.util.spawn(string.format("%s --toggle-mute", cmd))
                    end,
                    {description = 'toggle mute', group = 'hotkeys'})
            )}
end

return setmetatable(widget, { __call = function(_, ...)
    return worker(...)
end })