--Library
----------------------------------------
local awful     = require("awful")
local beautiful = require("beautiful")
local gears     = require("gears")
local wibox     = require("wibox")


function create_text(text,font_name)
    return wibox.widget{
        markup = text,
        font   = font_name or "Time Won 9" ,
        align  = 'center',
        valign = 'center',
        widget = wibox.widget.textbox
    }
end

--Variables
-------------------------------------------------------------------------
local exit_screen           = {}
local exit_screen_grabber   = nil

local alert_icon            = wibox.widget.imagebox(os.getenv("HOME") .. "/.config/awesome/icons/warning.png")
local warning_text          = create_text("WARNING SYSTEM", "Roboto Condensed Bold 30")
local msg_widget            = create_text("DO YOU WANT TO EXIT FROM THE CURRENT SESSION?", "Roboto Condensed Bold 20")

local btn_1
local btn_2

-- functions
------------------------------------
function exit_screen.quit()
    awesome.quit()
end

function exit_screen.reset_buttons()
    btn_1.fg = beautiful.fg_normal
    btn_1.bg = beautiful.bg_minimize

    btn_2.fg = beautiful.fg_normal
    btn_2.bg = beautiful.bg_minimize
end

function exit_screen.hide()
    exit_screen.reset_buttons()
    exit_screen.update(false)
end

function create_button(textbox, font_name)
    local button = wibox.widget {
        {
            {
                text = textbox,
                font = font_name or "Roboto 11 Bold",
                align  = 'center',
                valign = 'center',
                widget = wibox.widget.textbox
            },
            layout = wibox.layout.flex.horizontal
        },
        fg = beautiful.fg_normal,
        bg = beautiful.bg_minimize,
        shape = gears.shape.rounded_rect,
        widget = wibox.container.background
    }

    -- change color
    ------------------------------------------------
    button:connect_signal("mouse::enter", function()
        button.bg = beautiful.bg_urgent
        button.fg = beautiful.fg_urgent
        local w = mouse.current_wibox
        old_cursor, old_wibox = w.cursor, w
        w.cursor = "hand1"
    end)

    button:connect_signal("mouse::leave", function()
        button.bg = beautiful.bg_minimize
        button.fg = beautiful.fg_normal
        if old_wibox then
            old_wibox.cursor = old_cursor
            old_wibox = nil
        end
    end)
    return button
end

function exit_screen.update(visible)
    if visible then
        width                 = screen[mouse.screen].geometry.width
        height                = screen[mouse.screen].geometry.height

        height_exitscreen     = height / 2.8
        width_exitscreen      = width / 2.5
        positionx             = (width - width_exitscreen) / 2 + screen[mouse.screen].geometry.x
        positiony             = (height - height_exitscreen) / 2 + screen[mouse.screen].geometry.y

        exit_screen.widg.screen = mouse.screen
        exit_screen.widg.height = height_exitscreen
        exit_screen.widg.width = width_exitscreen

        exit_screen.widg.x = positionx
        exit_screen.widg.y = positiony
    end

    exit_screen.widg.visible = visible
end

function exit_screen.show()
    --Play sound
    -------------------------------------------------------------
    if not _G.dont_disturb then
        -- Add Sound fx to notif
        -- Depends: libcanberra
        awful.spawn('canberra-gtk-play -i window-attention', false)
    end

    -- run keygrabber
    ---------------------------------------------------------------
    exit_screen_grabber =
    awful.keygrabber.run(function(_, key, event)
        if event == 'release' then
            return
        end
        if key == 'o' or key == 'y' then
            exit_screen.quit()
        elseif key == 'Escape' or key == 'q' or key == 'x' then
            exit_screen.hide()
        else
            awful.keygrabber.stop(exit_screen_grabber)
        end
    end)

    exit_screen.update(true)
end



-- Create the widget
-----------------------------------------------
exit_screen.widg = wibox({
    border_width = 10,
    border_color = beautiful.bg_minimize,
    ontop = true,
    visible = false,
    type = "dock",
    bg = beautiful.bg_normal,
    shape = gears.shape.rounded_rect
})

-- BTN 1
-------------------------------------------------------------
btn_1 = create_button("YES - EXIT")
btn_1:buttons(gears.table.join(awful.button({}, 1, function()
    exit_screen.quit()
end)))

-- BTN 2
-------------------------------------------------------------
btn_2 = create_button("CANCEL")
btn_2:buttons(gears.table.join(awful.button({}, 1, function()
    exit_screen.hide()
end)))




exit_screen.widg:setup {
    {
        {
            {
                alert_icon,
                warning_text,
                layout = wibox.layout.align.horizontal,
            },
            top = 20,
            left = 35,
            bottom = 0,
            widget = wibox.container.margin
        },
        fg = beautiful.fg_normal,
        widget = wibox.container.background
    },
    {
        {
            msg_widget,
            layout = wibox.layout.flex.horizontal
        },
        top = 10,
        right = 10,
        left = 10,
        bottom = 10,
        widget = wibox.container.margin
    },
    {
        {
            btn_1,
            wibox.widget.textbox('  '),
            btn_2,
            expand = "none",
            layout = wibox.layout.flex.horizontal
        },
        top = 20,
        right = 35,
        left = 35,
        bottom = 20,
        widget = wibox.container.margin
    },
    layout = wibox.layout.flex.vertical
}

return exit_screen