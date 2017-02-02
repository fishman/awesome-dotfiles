--[[
awesome.lua - main config of my window manager
awesome v3.5.4 (Brown Paper Bag)
os: archlinux x86_64
cpu: Intel(R) Core(TM) i5-4200U CPU @ 1.60GHz
grapic:  Intel Graphics 4400
screen: 1920 x 1080
--]]

-- {{{ Awesome Library
print("[awesome] Entered awesome.lua: "..os.date())

-- Standard awesome library
local gears       = require("gears")
local awful       = require("awful")
local tyrannical  = require("tyrannical")
local collision   = require("collision")
awful.rules       = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox       = require("wibox")
-- Theme handling library
local beautiful   = require("beautiful")
-- Notification library
local _dbus       = dbus
dbus              = nil
local naughty     = require("naughty")
dbus              = _dbus
local menubar     = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget
-- widget library
local vicious     = require("vicious")
vicious.contrib   = require("vicious.contrib")
--local lognotify = require("lognotify")
-- calendar widget
local cal         = require("utils.cal")
-- wrapper for pango markup
local markup      = require("utils.markup")
-- scan for wlan accesspoints using iwlist
local iwlist      = require("utils.iwlist")
-- MPD widget based on mpd.lua
local wimpd       = require("utils.wimpd")
local mpc         = wimpd.new()
local scratch     = require("scratch")
local dmenu       = require("dmenu")
local lain        = require("lain")
local lain_icons_dir = require("lain.helpers").icons_dir
markup2 = lain.util.markup
-- load the 'run or raise' function
local ror         = require("aweror")
local radical     = require("radical")


local wifi="wlp109s0"
local disk="nvme0n1"
local lightup="light -A 5"
local lightdown="light -U 5"
-- local lightup="xcubiclight -i"
-- local lightdown="xcubiclight -d -z"
-- local lightup="xbacklight +5"
-- local lightdown="xbacklight -5"

-- require("revelation")

-- enable luajit
pcall(function() jit.on() end)
-- }}}

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
--local theme_path = "/usr/share/awesome/themes/default/theme.lua"
--local theme_path = "/usr/share/awesome/themes/sky/theme.lua"
-- local theme_path = awful.util.getdir("config").."/foobar/theme.lua"
local theme_path = awful.util.getdir("config").."/themes/steamburn/theme.lua"

beautiful.init(theme_path)

-- Use normal colors instead of focus colors for tooltips
beautiful.tooltip_bg_color = beautiful.bg_normal
beautiful.tooltip_fg_color = beautiful.fg_normal

-- This is used later as the default terminal and editor to run.
local spawn_with_systemd = function(app)
  return "systemd-run --user --unit '"..app.."' '"..app.."'"
end
terminal   = os.getenv("TERMINAL") or "urxvtc"
xterminal   = "uxterm"
local editor     = os.getenv("EDITOR") or "vim"
local browser    = os.getenv("BROWSER") or "firefox"
local mail       = "thunderbird"
local editor_cmd = terminal.." -e "..editor
local configpath = os.getenv("HOME") .. "/.config/awesome/"
local passmenu = "rofimenu"
local ranger = terminal .. " -e ranger"
local dmenurun = "rofi -show run -font \"snap 10\" -fg \"#D3D3D3\" -bg \"#000000\" -hlfg \"#ffb964\" -hlbg \"#000000\" -o 85"
local dwinshow = "rofi -show window -font \"snap 10\" -fg \"#D3D3D3\" -bg \"#000000\" -hlfg \"#ffb964\" -hlbg \"#000000\" -o 85"


-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
local modkey    = "Mod4"
local modkey2   = "Mod1"
local icon_path = awful.util.getdir("config").."/icons/"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
  awful.layout.suit.tile,               -- 1
  awful.layout.suit.tile.left,          -- 2
  awful.layout.suit.tile.bottom,        -- 3
  awful.layout.suit.tile.top,           -- 4
  --awful.layout.suit.fair,
  --awful.layout.suit.fair.horizontal,
  --awful.layout.suit.spiral,
  --awful.layout.suit.spiral.dwindle,
  awful.layout.suit.floating,           -- 5
  awful.layout.suit.max,                -- 7
  awful.layout.suit.max.fullscreen,     -- 8
  --awful.layout.suit.magnifier,
}

-- }}}

-- {{{ Helper functions
local function client_menu_toggle_fn()
    local instance = nil

    return function ()
        if instance and instance.wibox.visible then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ theme = { width = 250 } })
        end
    end
end
-- }}}
-- {{{ Shifty configuration
-- tag settings
-- the exclusive in each definition seems to be overhead, but it prevent new on-the-fly tags to be exclusive
-- the follow function make it easier to swap tags

-- local scount = screen.count()
-- tags = {
--     names  = { "term", "coding", "web", "im", "vms", "media" },
--     layout = {
--         awful.layout.suit.tile.bottom, layouts[1], awful.layout.suit.max, awful.layout.suit.floating, awful.layout.suit.floating,
--         awful.layout.suit.floating, awful.layout.suit.floating, awful.layout.suit.floating, awful.layout.suit.floating
--     }
-- }
-- for s = 1, scount do
--     -- Each screen has its own tag table.
--     tags[s] = awful.tag(tags.names, s, tags.layout)
-- end

-- First, set some settings
tyrannical.settings.default_layout = awful.layout.suit.tile.left
tyrannical.settings.mwfact = 0.66

tyrannical.tags = {
  {
    name = "1:dev",
    position = 1,
    exclusive = true,
    init = true,
    screen = 1,
    -- gap = 4,
    layout = awful.layout.suit.tile,
    class       = {
      "urxvt" , "aterm", "emacs", "qutebrowser"
    },
    match       = {
      "konsole"
    }
  },
  {
    name = "2:web",
    position = 2,
    init = true,
    exclusive = true,
    screen = 1,
    -- gap = 4,
    layout = awful.layout.suit.max,
    exec_once = { browser },
    class = { "Firefox", "Opera", "Chromium", "Aurora", "birdie",
    "Thunderbird", "evolution", "Corebird", "Caprine", "vimb" },
  },
  {
    name = "3:im",
    position = 3,
    exclusive = true,
    mwfact = 0.25,
    -- gap = 4,
    init = true,
    layout = awful.layout.suit.tile,
    exec_once = { "pidgin" },
    class = { "Kopete", "Pidgin", "gajim" }
  },
  -- {
  --   name = "4:emacs",
  --   position = 4,
  --   exclusive = true,
  --   init = true,
  --   -- gap = 4,
  --   layout = awful.layout.suit.tile,
  --   -- exec_once = { spawn_with_systemd("emacs") },
  --   class = { "emacs" }
  -- },
  {
    exclusive = true,
    init = false,
    layout = awful.layout.suit.tile,
    class = { "Wine" }
  },
  {
    name = "doc",
    position = 5,
    exclusive = false,
    init = false,
    layout = awful.layout.suit.max,
    -- exec_once = { spawn_with_systemd("keepass") },
    class = { "Evince", "GVim", "keepassxc", "KeePass2", "libreoffice", "calibre-gui", "Calibre", "Zathura" }
  },
  {
    name = "6:java",
    position = 6,
    exclusive = false,
    init = false,
    layout = awful.layout.suit.tile,
    class = { "Eclipse", "NetBeans IDE", "jetbrains%-idea%-ce", "sun-awt-X11-XFramePeer", "jetbrains-idea-ce" }
  },
  {
    name = "d:own",
    position = 7,
    exclusive = true,
    init = false,
    layout = awful.layout.suit.tile,
    class = { "gpodder", "JDownloader", "transmission-gtk" }
  },
  {
    name = "s:kype",
    position = 8,
    exclusive = true,
    init = false,
    layout = awful.layout.suit.tile,
    class = { "skype" }
  },
  {
    name = "s:pacefm",
    position = 8,
    exclusive = true,
    init = false,
    layout = awful.layout.suit.tile,
    -- exec_once = { spawn_with_systemd("pcmanfm") },
    class = { "pcmanfm", "dolphin", "nautilus", "thunar", "spacefm", "doublecmd"}
  },
  {
    name = "a:udio",
    position = 10,
    exclusive = true,
    init = false,
    layout = awful.layout.suit.max,
    class = { "sonata", "ncmpcpp"},
    match = { "ncmpcpp" }
  },
  {
    name = "v:ideo",
    position = 11,
    exclusive = true,
    init = false,
    layout = awful.layout.suit.max,
    class = { "MPlayer", "VLC", "Smplayer", "bomi", "mpv", "Kodi"}
  },
  {
    name = "s:lack",
    position = 12,
    exclusive = true,
    init = false,
    layout = awful.layout.suit.max,
    class = { "slack" }
  },
}

tyrannical.properties.intrusive = {
  "cmst", "arandr", "gmrun", "qalculate", "gnome-calculator", "Komprimieren", "wicd", "Wicd-client.py", "scratchpad", "bashrun", "mpv", "pinentry", "Nm-connection-editor", "Nm-applet", "nm-openvpn-auth-dialog", "Blueman-manager", "Gcr-prompter", "xev", "Hamster", "lxqt-policykit-agent", "Lxpolkit", "maya-calendar", "conmann-gtk", "Connman-gtk", "CMST - Connman System Tray"
}

tyrannical.properties.ontop = {
  "gmrun", "qalculate", "gnome-calculator", "Komprimieren", "cmst", "conmann-gtk", "Connman-gtk", "wicd", "Wicd-client.py", "MPlayer", "mpv", "pinentry", "scratchpad", "bashrun", "Gcr-prompter", "Hamster", "lxqt-policykit-agent", "Lxpolkit"
}

tyrannical.properties.floating = {
  "arandr", "cmst", "Conmann-gtk", "connman-gtk"
}

-- tyrannical.properties.floating = {
--   "MPlayer", "Mpv", "pinentry", "scratchpad", "bashrun", "idaq.exe", "idaq64.exe", "Tor Browser", "Gcr-prompter", "Gxmessage", "xev", "Hamster", "bashrun", "lxqt-policykit-agent", "Lxpolkit", "Zathura", "maya-calendar", "Cantata"
-- }

tyrannical.properties.centered = {
  "Gxmessage", "Hamster", "connman-gtk", "cmst", "connman-gtk", "Connman-gtk", "CMST - Connman System Tray"
}

-- full_screen_apps = {"dwb", "Opera", "Chromium", "Aurora", "Thunderbird", "evolution", "luakit"}

tyrannical.settings.group_children = true
tyrannical.settings.block_children_focus_stealing = true --Block popups ()
-- tyrannical.properties.maximized_horizontal = full_screen_apps
-- tyrannical.properties.maximized_vertical = full_screen_apps
tyrannical.properties.size_hints_honor = {
  xterm = false, aterm = false, scratchpad = false, bashrun = false
}

--}}}

-- {{{ Wallpaper
if beautiful.wallpaper then
  for s = 1, screen.count() do
    gears.wallpaper.maximized(beautiful.wallpaper, s, true)
  end
end
-- }}}


-- {{{ Menu
-- Create a laucher widget and a main menu
local myawesomemenu = {
   { "hotkeys", function() return false, hotkeys_popup.show_help end},
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/awesome.lua" },
   { "powersafe off", "xset s off" },
   { "xrandr", "xrandr --auto" },
   { "arandr", "arandr" },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

local mymainmenu = awful.menu({ items = {
  { "awesome", myawesomemenu, beautiful.awesome_icon },
  { "open terminal", terminal },
  { "Firefox", spawn_with_systemd("firefox") },
  { "Lock", "slimlock" },
  { "Sleep", "systemctl suspend" },
  { "Hibernate", "systemctl hibernate" },
  { "Reboot", "systemctl reboot", icon_path.."restart.png" },
  { "Shutdown", "systemctl poweroff", icon_path.."poweroff.png" },
}})

local mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })
-- }}}

-- {{{ Naughty log notify
-- print("[awesome] Enable naughty log notify")
-- ilog = lognotify{
--    logs = {
--       mpd = { file = os.getenv("HOME").."/.mpd/log", ignore = {"player_thread: played"} },
--       pacman = { file = "/var/log/pacman.log", },
--       kernel = { file = "/var/log/kernel.log", ignore = {"Mark"} },
--       awesome = { file = awful.util.getdir("config").."/log", ignore = {"[awesome]"} },
--    },
--    interval = 1,
--    naughty_timeout = 15
-- }
-- ilog:start()
 -- Transparent notifications
naughty.config.presets.normal.opacity = 0.8
naughty.config.presets.low.opacity = 0.8
naughty.config.presets.critical.opacity = 0.8
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout:new()

-- {{{ Vicious and MPD
print("[awesome] initialize vicious")

spr = wibox.widget.textbox(' ')
arrl = wibox.widget.imagebox()
arrl:set_image(beautiful.arrl)
arrl_dl = wibox.widget.imagebox()
arrl_dl:set_image(beautiful.arrl_dl)
arrl_ld = wibox.widget.imagebox()
arrl_ld:set_image(beautiful.arrl_ld)
arrl_ld_grey = wibox.widget.imagebox()
arrl_ld_grey:set_image(beautiful.arrl_ld_grey)
arrl_ld_grey2 = wibox.widget.imagebox()
arrl_ld_grey2:set_image(beautiful.arrl_ld_grey2)
arrr = wibox.widget.imagebox()
arrr:set_image(beautiful.arrr)
arrr_dl = wibox.widget.imagebox()
arrr_dl:set_image(beautiful.arrr_dl)
arrr_ld = wibox.widget.imagebox()
arrr_ld:set_image(beautiful.arrr_ld)
spr5px = wibox.widget.imagebox()
spr5px:set_image(beautiful.spr5px)
-- {{{ Date and time
-- Create a textclock widget
local mytextclock = wibox.widget.textclock()
local clockicon = wibox.widget.imagebox()
clockicon:set_image(beautiful.widget_clock)
-- Register calendar tooltip
-- To use fg_focus, you have to set a different tooltip_fg_color since the
-- default is already beautiful.fg_focus.
-- (beautiful.bg_normal in my case)
cal.register(clockicon, markup.fg(beautiful.fg_focus,"<b>%s</b>"))
local uptimetooltip = awful.tooltip({})
uptimetooltip:add_to_object(mytextclock)
mytextclock:connect_signal("mouse::enter",  function()
  local args = vicious.widgets.uptime()
  local text = (" <b>Uptime</b> %dd %dh %dmin "):format(args[1], args[2], args[3])
  uptimetooltip:set_markup(text)
end)
-- }}}

-- Create a wibox for each screen and add it
local taglist_buttons = awful.util.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() and c.first_tag then
                                                      c.first_tag:view_only()
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, client_menu_toggle_fn()),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- {{{ Battery
local batwidget = wibox.widget.textbox()
local baticon   = wibox.widget.imagebox()
baticon:set_image(beautiful.widget_battery)
vicious.register(batwidget, vicious.widgets.bat, "$1$2% $3h", 7, "BAT0")


-- baticon = wibox.widget.imagebox(beautiful.widget_battery)
-- local batwidget = lain.widgets.bat({
--     settings = function()
--         if bat_now.perc == "N/A" then
--             widget:set_markup(" AC ")
--             baticon:set_image(beautiful.widget_ac)
--             return
--         elseif tonumber(bat_now.perc) <= 5 then
--             baticon:set_image(beautiful.widget_battery_empty)
--         elseif tonumber(bat_now.perc) <= 15 then
--             baticon:set_image(beautiful.widget_battery_low)
--         else
--             baticon:set_image(beautiful.widget_battery)
--         end
--         widget:set_markup(" " .. bat_now.perc .. "% ")
--     end
-- })
-- }}}

--{{{ Pulseaudio
volicon = wibox.widget.imagebox(beautiful.widget_vol)
myvolumebar = lain.widgets.alsabar({
  ticks  = true,
  width  = 40,
  height = 10,
  colors = {
    background = "#383838",
    unmute     = "#80CCE6",
    mute       = "#FF9F9F"
  },
  notifications = {
    font_size = "12",
    bar_size  = 32
  },
  settings = function()
    if volume_now.status == "off" then
      volicon:set_image(beautiful.widget_vol_mute)
    elseif tonumber(volume_now.level) == 0 then
      volicon:set_image(beautiful.widget_vol_no)
    elseif tonumber(volume_now.level) <= 60 then
      volicon:set_image(beautiful.widget_vol_low)
    else
      volicon:set_image(beautiful.widget_vol)
    end
  end
})
alsamargin = wibox.container.margin(myvolumebar.bar, 5, 8, 40)
wibox.container.margin.set_top(alsamargin, 6)
wibox.container.margin.set_bottom(alsamargin, 6)
volumewidget = wibox.container.background(alsamargin)

local function alsa_volume(delta)
  awful.spawn("amixer -q set Master " .. delta)
  vicious.force({ volumewidget, })
end

local function alsa_toggle()
  awful.spawn("amixer set Master 1+ toggle", false)
  -- awful.spawn("amixer sset Master toggle", false)
  vicious.force({ volumewidget, })
end

volumewidget:buttons(awful.util.table.join(
  awful.button({ }, 1, function() awful.spawn(terminal .. " -e alsamixer") end), --left click
  awful.button({ }, 2, function() alsa_toggle() end),
  awful.button({ }, 4, function() alsa_volume("2db+") end), -- scroll up
  awful.button({ }, 5, function() alsa_volume("2db-") end))) -- scroll down

-- local function pulse_volume(delta)
--   vicious.contrib.pulse.add(delta, "alsa_output.pci-0000_00_1b.0.analog-stereo")
--   vicious.force({ pulsewidget, pulsebar})
-- end

-- local function pulse_toggle()
--   vicious.contrib.pulse.toggle("alsa_output.pci-0000_00_1b.0.analog-stereo")
--   vicious.force({ pulsewidget, pulsebar})
-- end

-- vicious.register(pulsewidget, vicious.contrib.pulse,
-- function (widget, args)
--   return string.format("%.f%%", args[1])
-- end, 7, "alsa_output.pci-0000_00_1b.0.analog-stereo")


-- pulsewidget:buttons(awful.util.table.join(
--   awful.button({ }, 1, function() awful.spawn("pavucontrol") end), --left click
--   awful.button({ }, 2, function() pulse_toggle() end),
--   awful.button({ }, 4, function() pulse_volume(5) end), -- scroll up
--   awful.button({ }, 5, function() pulse_volume(-5) end))) -- scroll down

-- pulsebar:buttons(pulsewidget:buttons())
-- pulseicon:buttons(pulsewidget:buttons())
--}}}

-- {{{ CPU usage
local cpuwidget = wibox.widget.textbox()
local cpubg     = wibox.container.background(cpuwidget, "#313131")
local cpuicon = wibox.widget.imagebox()
cpuicon:set_image(beautiful.widget_cpu)
-- Initialize widgets
vicious.register(cpuwidget, vicious.widgets.cpu,
function (widget, args)
local text
-- list all cpu cores
for i=1,#args do
  -- alerts, if system is stressed
  --args[i] = markup.fg(markup.gradient(1,100,args[i]),args[i])
  if args[i] > 90 then
    args[i] = markup.fg("#FF5656", args[i]) -- light red
  elseif args[i] > 70 then
    args[i] = markup.fg("#AECF96", args[i]) -- light green
  end

  -- append to list
  if i > 2 then text = text.."/"..args[i].."%"
  else text = args[i].."%" end
end
return text
end, 10)
-- Register buttons
cpuwidget:buttons( awful.button({ }, 1, function () awful.spawn(terminal .. " -e htop") end) )
cpuicon:buttons( cpuwidget:buttons() )

-- }}}

-- {{{ CPU temperature
local thermalwidget = wibox.widget.textbox()
local thermalicon = wibox.widget.imagebox()
thermalicon:set_image(beautiful.widget_temp)
vicious.register(thermalwidget, vicious.widgets.thermal, "$1°C", 10, {"thermal_zone0", "sys"})
-- }}}

-- {{{ Memory usage
-- Initialize widget
local memwidget = wibox.widget.textbox()
local memicon = wibox.widget.imagebox()
memicon:set_image(beautiful.widget_mem)
vicious.register(memwidget, vicious.widgets.mem, "$2MB/$3MB ", 10)
-- Register buttons
memwidget:buttons( cpuwidget:buttons() )
memicon:buttons( cpuwidget:buttons() )
-- }}}

-- {{{ Net usage
local netwidget = wibox.widget.textbox()
local netbg     = wibox.container.background(netwidget, "#313131")
local neticon  = wibox.widget.imagebox()
neticon:set_image(beautiful.widget_net)
-- Register widget
vicious.register(netwidget, vicious.widgets.net, '<span color="#CC9393">${' .. wifi .. ' down_kb}</span> <span color="#7F9F7F">${' .. wifi .. ' up_kb}</span>', 10)
netwidget:buttons( awful.button({ }, 1, function () awful.spawn(xterminal .. " -e sudo nethogs -d 2 -p " .. wifi) end) )
neticon:buttons( netwidget:buttons() )
-- }}}

-- {{{ Disk I/O
local ioicon = wibox.widget.imagebox()
ioicon:set_image(beautiful.widget_hdd)
ioicon.visible = true
local iowidget = wibox.widget.textbox()
local iobg     = wibox.container.background(iowidget, "#313131")
vicious.register(iowidget, vicious.widgets.dio, "SSD ${".. disk .. " read_mb}/${" .. disk .. " write_mb}MB", 7)
-- Register buttons
iowidget:buttons( awful.button({ }, 1, function () awful.spawn(terminal .. " -e sudo iotop") end) )
-- }}}

--{{{ Pacman
-- local pkgwidget = wibox.widget.textbox()
-- local pkgicon = wibox.widget.imagebox()
-- pkgicon:set_image(icon_path.."pacman.png")
-- -- Don't show icon by default
-- pkgicon.visible = false

-- -- Use a cronjob to update the packagelist http://bbs.archlinux.org/viewtopic.php?id=84115
-- vicious.register(pkgwidget, vicious.widgets.pkg,
-- function(widget, args)
--  -- Check wheter pacman db is locked. Don't use aweful.util.file_readable,
--  -- because the db.lck isn't readable at all.
--  local db_locked = os.execute("[[ -f /var/lib/pacman/db.lck ]] && exit 1 || exit 0")
--  -- Don't disturb me, unless enough updates are collect and pacman doesn't run
--  if args[1] < 8 or db_locked ~= 0 then
--     -- If you use powerpill, it is important to check wheter it runs!
--     pkgicon.visible = false
--     return ""
--  else
--     pkgicon.visible = true
--     return markup.urgent("<b>Updates</b> "..args[1]).." "
--  end
-- end, 1, "Arch")

-- pkgwidget:buttons( awful.button({ }, 1,
-- function ()
--  pkgwidget.visible, pkgicon.visible = false, false
--  -- URxvt specific
--  awful.spawn(terminal.." -title 'Packer Upgrade' -e zsh -c 'packer -Syu'")
-- end))
-- pkgicon:buttons( pkgwidget:buttons() )
--}}}

-- {{{ MPD
local wimpc = wibox.widget.textbox()
local mpdicon = wibox.widget.imagebox(beautiful.widget_music)
mpc.attach(wimpc)
-- mpdicon = wibox.widget.imagebox(beautiful.widget_music)
-- mpdwidget = lain.widgets.mpd({
--     settings = function()
--         if mpd_now.state == "play" then
--             artist = " " .. mpd_now.artist .. " "
--             title  = mpd_now.title  .. " "
--             mpdicon:set_image(beautiful.widget_music_on)
--         elseif mpd_now.state == "pause" then
--             artist = " mpd "
--             title  = "paused "
--         else
--             artist = ""
--             title  = ""
--             mpdicon:set_image(beautiful.widget_music)
--         end

--         widget:set_markup(markup2("#EA6F81", artist) .. title)
--     end
-- })
-- Redshift

local markup = lain.util.markup

local myredshift = wibox.widget{
    checked      = false,
    check_color  = beautiful.redshift_bg,
    border_color = beautiful.bg_normal,
    border_width = beautiful.redshift_border,
    shape        = gears.shape.square,
    widget       = wibox.widget.checkbox
}

local myredshift_text = wibox.widget{
    align  = "center",
    widget = wibox.widget.textbox,
}

local myredshift_stack = wibox.widget{
    myredshift,
    myredshift_text,
    layout = wibox.layout.stack
}

lain.widgets.contrib.redshift:attach(
    myredshift,
    function (active)
        if active then
            myredshift_text:set_markup(markup(beautiful.bg_normal, "<b>R</b>"))
        else
            myredshift_text:set_markup(markup(beautiful.fg_normal, "R"))
        end
        myredshift.checked = active
    end
)

-- Register Buttons in both widget
mpdicon:buttons( wimpc:buttons(awful.util.table.join(
awful.button({ }, 1, function () mpc:toggle_play() mpc:update()      end), -- left click
awful.button({ }, 2, function () awful.spawn("sonata")          end), -- middle click
awful.button({ }, 3, function () awful.spawn("urxvt -name ncmpcpp -e ncmpcpp")end), -- right click
awful.button({ }, 4, function () mpc:seek(5) mpc:update()            end), -- scroll up
awful.button({ }, 5, function () mpc:seek(-5) mpc:update()           end)  -- scroll down
)))
-- }}}

--{{{ Wifi
-- local m = radical.context {
-- 	style      = radical.style.classic      ,
-- 	item_style = radical.item.style.classic ,
-- 	layout     = radical.layout.vertical    }
-- local menubar = radical.bar{}
-- menubar:connect_signal("button::press",function(data,item,button,mods)
--     if mods.Control then
--         print("Foo menu pressed!",item.text,button,data.rowcount)
--     end
-- end)

-- -- Also work on items
-- menubar:add_item{text="bar"}:connect_signal("button::release",function(d,i,b,m)
--     print("bar click released!")
-- end)

-- local menu = radical.context{}
-- menu:add_item {text="Screen 1",button1=function(_menu,item,mods) print("Hello World! ") end}
-- menu:add_item {text="Screen 9",icon= beautiful.awesome_icon}
-- menu:add_item {text="Sub Menu",sub_menu = function()
-- 	local smenu = radical.context{}
-- 	smenu:add_item{text="item 1"}
-- 	smenu:add_item{text="item 2"}
-- 	return smenu
-- end}

local wifiwidget = wibox.widget.textbox()
local wifibg     = wibox.container.background(wifiwidget, "#313131")
local wifiicon   = wibox.widget.imagebox()
local wifitooltip= awful.tooltip({})
wifitooltip:add_to_object(wifiwidget)
wifiicon:set_image(beautiful.widget_net)
vicious.register(wifiwidget, vicious.widgets.wifi,
  function(widget, args)
    local tooltip = ("<b>mode</b> %s <b>chan</b> %s <b>rate</b> %s Mb/s"):format(
    args["{mode}"], args["{chan}"], args["{rate}"])
    local quality = 0
    if args["{linp}"] > 0 then
      quality = args["{link}"] / args["{linp}"] * 100
    end
    wifitooltip:set_markup(tooltip)
    return args["{ssid}"]
  end, 5, wifi)
wifiicon:buttons( wifiwidget:buttons(awful.util.table.join(
awful.button({ "Shift" }, 1, function()
local networks = iwlist.scan_networks(wifi)
if #networks > 0 then
    local msg = {}
    for i, ap in ipairs(networks) do
        local line = "<b>ESSID:</b> %s <b>MAC:</b> %s <b>Qual.:</b> %.2f%% <b>%s</b>"
        local enc = iwlist.get_encryption(ap)
        msg[i] = line:format(ap.essid, ap.address, ap.quality, enc)
    end
    naughty.notify({text = table.concat(msg, "\n")})
else
end
end)
-- awful.button({ }, 1, function ()
--     -- local wpa_cmd = terminal .. " -name wicd -e wicd-curses"
--     -- awful.spawn("cmst")
--     menubar.show()

--     -- restart-auto-wireless is just a script of mine,
--     -- which just restart netcfg
--     -- local wpa_cmd = "sudo restart-auto-wireless && notify-send 'wpa_actiond' 'restarted' || notify-send 'wpa_actiond' 'error on restart'"
--     -- awful.spawn_with_shell(wpa_cmd)
-- end), -- left click
-- awful.button({ }, 3, function ()  vicious.force{wifiwidget} end) -- right click
)))
-- wifiwidget:set_menu(menu) -- 3 = right mouse button, 1 = left mouse button
--}}}



local connman = require("connman_widget")
-- override the GUI client.
connman.gui_client = "cmst"
--
--
--
-- }}}

-- {{{ Wibox
print("[awesome] initialize wibox")

-- Create a wibox for each screen and add it
mywibox = {}
mystatusbox = {}
local mypromptbox = {}
local mylayoutbox = {}
local mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
local mytasklist = {}
mytasklist.buttons = awful.util.table.join(
   awful.button({ }, 1,
     function (c)
       if c == client.focus then
         c.minimized = true
       else
         -- Without this, the following
         -- :isvisible() makes no sense
         c.minimized = false
         if not c:isvisible() then
           awful.tag.viewonly(c:tags()[1])
         end
         -- This will also un-minimize
         -- the client, if needed
         client.focus = c
         c:raise()
       end
     end),
   awful.button({ }, 3,
     function ()
       if instance then
         instance:hide()
         instance = nil
       else
         instance = awful.menu.clients({ width=250 })
       end
     end),
   awful.button({ }, 4,
     function ()
       awful.client.focus.byidx(1)
       if client.focus then client.focus:raise() end
     end),
   awful.button({ }, 5,
     function ()
       awful.client.focus.byidx(-1)
       if client.focus then client.focus:raise() end
     end))

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)


    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            s.mytaglist,
            arrr,
            spr,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            -- if s == 1 then 
            arrl,
            -- end
            wibox.widget.systray(),
            arrl_ld,
            wifiicon,
            wifibg,
            connman,
            arrl_dl,
            mykeyboardlayout,
            baticon,
            batwidget,
            spr,
            -- right_layout:add(bat2widget)
            arrl,
            myredshift_stack,
            arrl,
            volicon,
            volumewidget,
            clockicon,
            arrl,
            mytextclock,
            arrl_ld,
            s.mylayoutbox,
        },
    }



    -- Create the wibox
    s.mystatusbox = awful.wibar({ position = "bottom", screen = s })

    -- Add widgets to the wibox
    s.mystatusbox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            cpuicon,
            cpubg,
            arrr_ld,
            memicon,
            memwidget,
            arrr_dl,
            ioicon,
            iobg,
            arrr_ld,
            thermalicon,
            thermalwidget,
            arrr_dl,
            neticon,
            netbg,
            arrr_ld,
        }
        ,
        {
            layout = wibox.layout.fixed.horizontal,
        },
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            -- arrl_ld,
            -- mpdicon,
            -- arrl_dl,
            wimpc,
        }
    }

  -- right_layout2:add(mpcicon)
  -- right_layout2:add(wimpc)
  -- right_layout2:add(arrl)
  -- right_layout2:add(pkgicon)
  -- right_layout2:add(pkgwidget)
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

local function random_string(len)
  local res = {}
  for i=1, len do
    -- from range a-z
    res[i] = string.char(math.random(97, 122))
  end
  return table.concat(res)
end

-- {{{ Key bindings
local globalkeys = awful.util.table.join(
    awful.key({ modkey, "Shift"   }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    -- awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
    --           {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

  -- awful.key({ modkey,           }, "e", revelation),
    awful.key({ modkey,           }, "w", function () awful.spawn(dwinshow) end),
    awful.key({ modkey,           }, "`", function() scratch("urxvt -name scratchpad -e tmux-scratchpad", "top", "center", 0.90, 0.30) end),
    -- awful.key({ modkey,           }, "`", function () quakeconsole[mouse.screen]:toggle() end),
    -- awful.key({ modkey,           }, "`", function () drop(terminal .. " -name scratchpad") end),
    awful.key({ modkey, "Shift"   }, "q", function () awful.spawn("lxsession-logout") end),
    awful.key({ modkey,           }, "Delete", function () awful.spawn("xkill", false) end),
    -- lockscreen
    awful.key({ modkey, "Shift"   }, "l", function () awful.spawn("xautolock -locknow") end),


    -- move float clients without a mouse
    awful.key({ modkey, modkey2 }, "h", function () awful.client.moveresize(-20, 0, 0, 0) end),
    awful.key({ modkey, modkey2 }, "j", function () awful.client.moveresize(0, 20, 0, 0)  end),
    awful.key({ modkey, modkey2 }, "k", function () awful.client.moveresize(0, -20, 0, 0) end),
    awful.key({ modkey, modkey2 }, "l", function () awful.client.moveresize(20, 0, 0, 0)  end),

    -- Standard program
    awful.key({ modkey, "Shift"   }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    -- awful.key({ modkey, "Shift"   }, "q", awesome.quit,
    --           {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                      client.focus = c
                      c:raise()
                  end
              end,
              {description = "restore minimized", group = "client"}),

  --}}
    -- Prompt
    -- awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
    --           {description = "run prompt", group = "launcher"}),
  -- awful.key({ modkey }, "r",     function () mypromptbox[mouse.screen]:run() end),
  -- awful.key({ modkey }, "r", function () awful.spawn("dmenu_run -fn '-xos4-terminus-medium-r-*-*-28-' -hist " .. os.getenv("HOME") .. "/.dmenu.history  -nb '".. beautiful.bg_normal .."' -nf '".. beautiful.fg_normal .."' -sb '#955'") end),
  -- awful.key({ modkey }, "r", function () awful.spawn("mutate") end),
  -- Menubar
  -- awful.key({ modkey }, "r", function() menubar.show() end),
  awful.key({ modkey }, "r", function() awful.spawn('supermenu') end),
  awful.key({ modkey, "Shift" }, "p", function() awful.spawn('rofi-pass') end),
  -- awful.key({ modkey }, "r", function ()  awful.spawn(dmenurun) end),

  -- awful.key({ modkey }, "r", function() awful.spawn('urxvt -name bashrun -e sh -c "/bin/zsh -i -t" ') end),
  -- awful.key({ modkey }, "g", function () mydmenu:show() end),
  -- awful.key({ modkey }, "r",
  -- function ()
  --   awful.prompt.run({ prompt = "Run: ", hooks = {
  --     {{         },"Return",function(command)
  --       local result = awful.spawn(command)
  --       mypromptbox[mouse.screen].widget:set_text(type(result) == "string" and result or "")
  --       return true
  --     end},
  --     {{"Mod1"   },"Return",function(command)
  --       local result = awful.spawn(command,{intrusive=true})
  --       mypromptbox[mouse.screen].widget:set_text(type(result) == "string" and result or "")
  --       return true
  --     end},
  --     {{"Shift"  },"Return",function(command)
  --       local result = awful.spawn(command,{intrusive=true,ontop=true,floating=true})
  --       mypromptbox[mouse.screen].widget:set_text(type(result) == "string" and result or "")
  --       return true
  --     end}
  --   }},
  --   mypromptbox[mouse.screen].widget,nil,
  --   awful.completion.shell,
  --   awful.util.getdir("cache") .. "/history")
  -- end),
  --  awful.key({ modkey }, "s", function () menubar.show() end),
  --  

  -- {{{ Custom Bindings
  -- backlight control
  awful.key({ }, "XF86MonBrightnessUp", function () awful.spawn(lightup) end),
  awful.key({ }, "XF86MonBrightnessDown", function () awful.spawn(lightdown) end),
  awful.key({ modkey, "Shift", "Control" }, "r", function () redshift:toggle() end),

  -- printscreen
  awful.key({ }, "Print", function () awful.spawn("maim --select ~/Screenshots/$(date +%F-%T).png") end),

  -- mpd control
  -- awful.key({ "Shift" }, "space", function () mpc:toggle_play() mpc:update() end),
  -- Smplayer/Gnome mplayer control
  awful.key({ modkey2 }, "space", function ()
    local result = os.execute("smplayer -send-action play_or_pause") -- return 0 on succes
    if result ~= 0 then
      awful.spawn("dbus-send / com.gnome.mplayer.Play") -- if state is play it pause
    end
  end),
  awful.key({ }, "XF86AudioPlay", function () mpc:toggle_play() mpc:update() end),
  awful.key({ }, "XF86AudioNext", function () mpc:next()        mpc:update() end),
  awful.key({ }, "XF86AudioPrev", function () mpc:previous()    mpc:update() end),

  awful.key({ modkey }, "F10", function () mpc:toggle_play() mpc:update() end),
  awful.key({ modkey }, "F12", function () mpc:next()        mpc:update() end),
  awful.key({ modkey }, "F11", function () mpc:previous()    mpc:update() end),
  -- use a systemd.path to automatically upload this image to my server and copy
  -- the public link to clipboard
  awful.key({modkey }, "Print", function ()
    awful.spawn("scrot '%Y-%m-%d."..random_string(5)..".png' --exec 'eog \"$f\"; mv \"$f\" /home/joerg/Bilder'")
  end),
  awful.key({modkey, "Shift" }, "Print", false, function ()
    awful.spawn("scrot '%Y-%m-%d."..random_string(5)..".png' --select --exec 'eog \"$f\"; mv \"$f\" /home/joerg/Bilder'")
  end),

  awful.key({ }, "XF86Display", function()
    -- switch between external and internal display
    -- source: https://wiki.archlinux.org/index.php/Xrandr#Scripts
    os.execute('bash -c \'xrandr --output eDP1 --mode "1400x1050"; sleep 1; xrandr --output eDP1 --mode "1920x1080"\'')
  end),

  -- awful.key({ }, "XF86LaunchA", function()
  --   -- switch between external and internal display
  --   -- source: https://wiki.archlinux.org/index.php/Xrandr#Scripts
  --   -- os.execute('bash -c \'xrandr --output eDP1 --mode "2560x1600"; sleep 1; xrandr --output eDP1 --mode "1920x1080"\'')
  --   os.execute('bash -c \'~/bin/togglescreen\'')
  -- end),
  awful.key({ }, "XF86LaunchA", function () awful.spawn("autorandr --change", false) end),
  awful.key({ }, "XF86LaunchB", function () awful.spawn("teiler", false) end),
  -- awful.key({ }, "XF86KbdBrightnessDown", function () end),

  -- Volume keyboard control
--   awful.key({ }, "XF86AudioRaiseVolume", function () pulse_volume(5) end),
--   awful.key({ }, "XF86AudioLowerVolume", function () pulse_volume(-5)end),
--   awful.key({ }, "XF86AudioMute",        function () pulse_toggle()  end),
  awful.key({ }, "XF86AudioRaiseVolume", function () alsa_volume("2dB+") end),
  awful.key({ }, "XF86AudioLowerVolume", function () alsa_volume("2dB-") end),
  awful.key({ }, "XF86AudioMute",        function () alsa_toggle() end),


  -- Calculator
  awful.key({ modkey }, "c", function () awful.spawn("qalculate-gtk") end),
  -- awful.key({ modkey }, "v", function () awful.spawn("keepassxc") end),
  -- }}}

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"})
)

local clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "y",      function (c) collision.resize.display(c,true) end),
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey,           }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "maximize", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- generate and add the 'run or raise' key bindings to the globalkeys table
globalkeys = awful.util.table.join(globalkeys, ror.genkeys(modkey))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
        },
        class = {
          "Arandr",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Wpa_gui",
          "pinentry",
          "veromix",
          "xtightvncviewer"},

        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to dialogs
    { rule_any = {type = { "dialog" }
      }, properties = { titlebars_enabled = true }
    },
    { rule_any = { class = { "Pcmanfm", "Nautilus", "Thunar" } },
      properties = { floating = true },
      callback = awful.placement.centered },
    { rule_any = { class = { "Xmessage",  "Gxmessage", "Hamster-time-tracker", "cmst", "connman-gtk" } },
      properties = { floating = true },
      callback = awful.placement.centered },
    { rule_any = { class = { "Zathura", "Epdfview", "Remmina", "Bottlechooser.rb", "Evince", "GV"} },
      properties = { floating = true } },
    -- media
    { rule_any = { class = { "Smplayer", "MPlayer", "mpv", "Deadbeef", "gtkpod", "gpodder", "Mpv" } },
      properties = { floating = true }},
    --   callback = function(c)
    --           awful.client.movetotag(tags[mouse.screen][7], c)
    --           awful.tag.viewonly(tags[mouse.screen][7])
    --   end},
    { rule_any = { class = { "Dxtime", "Zim", "pinentry", "gimp", "Synapse", "TogglDesktop", "GenieSQL", "wicd"} },
      properties = { floating = true } },
    -- { rule_any = { class = { "Gvim", "Anjuta", "Emacs" } },
    --   properties = { tag = tags[1][2], switchtotag = true } },
    -- { rule_any = { class = { "Firefox", "Iron", "Opera", "luakit", "Uzbl-core" } },
    --   callback = function(c)
    --           awful.client.movetotag(tags[mouse.screen][3], c)
    --           awful.tag.viewonly(tags[mouse.screen][3])
    --   end},
    -- this is flash
    { rule_any = { name = { "plugin-container" }, class = { "Exe" } },
      properties = { floating = true },
      callback = function(c)
            c.fullscreen = true
      end},
    { rule = { class = "Firefox" },
      except = { instance = "Navigator" },
      properties = { floating = true } },
    -- { rule = { class = "Firefox", instance = "Navigator" },
    --   properties = { maximize_vertical = true, maximized_horizontal = true } },
    -- { rule = { class = "Iron" },
    --   properties = { maximize_vertical = true, maximized_horizontal = true } },
      -- thunderbird
    -- { rule = { class = "URxvt" },
    --   properties = { tag = tags[1][1], switchtotag = true } },
    -- { rule = { class = "Thunderbird" },
    --   properties = { tag = tags[1][3] } },
    -- { rule_any = { class = { "Skype", "Pidgin" } },
    --   properties = { switchtotag = true, tag = tags[1][4] },
      -- callback = function(c) awful.client.movetotag(tags[mouse.screen][5], c) end},
    -- { rule = { class = "Pidgin", role = "buddy_list" },
    --   properties = {switchtotag = true, floating=true,
    --                 maximized_vertical=true, maximized_horizontal=false },
    --   callback = function (c)
    --       local cl_width = 400    -- width of buddy list window
    --       local def_left = true   -- default placement. note: you have to restart
    --                               -- pidgin for changes to take effect

    --       local scr_area = screen[c.screen].workarea
    --       local cl_strut = c:struts()
    --       local geometry = nil

    --       -- adjust scr_area for this client's struts
    --       if cl_strut ~= nil then
    --           if cl_strut.left ~= nil and cl_strut.left > 0 then
    --               geometry = {x=scr_area.x-cl_strut.left, y=scr_area.y,
    --                           width=cl_strut.left}
    --           elseif cl_strut.right ~= nil and cl_strut.right > 0 then
    --               geometry = {x=scr_area.x+scr_area.width, y=scr_area.y,
    --                           width=cl_strut.right}
    --           end
    --       end
    --       -- scr_area is unaffected, so we can use the naive coordinates
    --       if geometry == nil then
    --           if def_left then
    --               c:struts({left=cl_width, right=0})
    --               geometry = {x=scr_area.x, y=scr_area.y,
    --                           width=cl_width}
    --           else
    --               c:struts({right=cl_width, left=0})
    --               geometry = {x=scr_area.x+scr_area.width-cl_width, y=scr_area.y,
    --                           width=cl_width}
    --           end
    --       end
    --       c:geometry(geometry)
    --   end },
    { rule = { class = "Skype"},
      except = { name = "Chat" },
      properties = { floating = true } },
    -- { rule_any = { class = { "Vmware", "VirtualBox", "Qemu-system-x86_64" } },
    --   properties = { tag = tags[1][5] } },
      -- office
    -- { rule_any = { class = { "libreoffice-startcenter",  "libreoffice-impress" }, name = { "PowerPoint % [~]" }  },
    --   properties = { tag = tags[1][7] } },
      -- dia
    -- { rule = { class = "Dia", role = "diagram_window" },
    --   properties = { tag = tags[1][8], fullscreen = true } },
    -- { rule = { class = "Dia", role = "toolbox_window" },
    --   properties = { tag = tags[1][8], fullscreen = true },
    --   callback = function(c) c.ontop = true end},
    { rule = { class = "scratchpad" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "Wicd-client.py" },
      properties = { floating = true } },
    { rule = { class = "Firefox" },
      except = { instance = "Navigator" },
      properties = { floating = true } },
    { rule = { class = "Tor Browser" },
      except = { instance = "Navigator" },
      properties = { floating = true } },
    { rule = { class = "Chromium" },
      except = { role = "browser" },
      properties = { floating = true } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    -- if not awesome.startup then
    --     -- Set the windows at the slave,
    --     -- i.e. put it at the end of others instead of setting it master.
    --     -- awful.client.setslave(c)

    --     -- Put windows in a smart way, only if they does not set an initial position.
    --     if not c.size_hints.user_position and not c.size_hints.program_position then
    --         awful.placement.no_overlap(c)
    --         awful.placement.no_offscreen(c)
    --     end
    -- end
    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = awful.util.table.join(
        awful.button({ }, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- -- Enable sloppy focus, so that focus follows mouse.
-- client.connect_signal("mouse::enter", function(c)
--     if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
--         and awful.client.focus.filter(c) then
--         client.focus = c
--     end
-- end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

collision()
-- }}}

-- {{{ Timer
-- }}}

-- {{{ Welcome Message
print("[awesome] Send welcome message")

awful.spawn.easy_async("hostname",
function(stdout, stderr, reason, exit_code)
  naughty.notify{
    title = "Awesome "..awesome.version.." started!",
    text  = string.format("Welcome %s. Your host is %s.\nIt is %s",
    os.getenv("USER"), stdout:match("[^\n]*"), os.date()),
    timeout = 5
  }
end)

-- }}}
-- battery warning
local function trim(s)
  return s:find'^%s*$' and '' or s:match'^%s*(.*%S)'
end

local function bat_notification()
  local f_capacity = assert(io.open("/sys/class/power_supply/BAT0/capacity", "r"))
  local f_status = assert(io.open("/sys/class/power_supply/BAT0/status", "r"))
  local bat_capacity = tonumber(f_capacity:read("*all"))
  local bat_status = trim(f_status:read("*all"))

  if (bat_capacity <= 10 and bat_status == "Discharging") then
    naughty.notify({ title      = "Battery Warning"
      , text       = "Battery low! " .. bat_capacity .."%" .. " left!"
      , fg="#ffffff"
      , bg="#C91C1C"
      , timeout    = 15
      , position   = "top_right"
    })
  end
  if (bat_capacity <= 4 and bat_status == "Discharging") then
    awful.spawn('systemctl hybrid-sleep')
  end
end

battimer = gears.timer({timeout = 60})
battimer:connect_signal("timeout", bat_notification)
battimer:start()

-- end here for battery warning

-- dofile(configpath .. "50pidgin.lua")
-- Java helper
awful.spawn("wmname LG3D")
-- awful.spawn("urxvt -name scratchpad")
--vicious.suspend()
--vicious.activate(batwidget)
--vicious.activate(batbar)
--vicious.activate(wifiwidget)


-- {{{ obsolete
-- local scratch = require("scratch")
-- local quake = require("quake")
-- require("quake")
-- local quakeconsole = {}
-- for s = 1, screen.count() do
--    quakeconsole[s] = quake({ terminal = terminal,
--            name = "scratchpad",
--            height = 0.3,
--            screen = s })
-- end

-- mydmenu = dmenu({
--   chromium = "chromium  --force-device-scale-factor=1.8",
--   mc = terminal .. " -e mc",
--   vim = terminal .. " -e vim",
--   ida = "dex ~/.local/share/applications/idaq.desktop",
--   urxvt = function()
--     local matcher = function (c)
--       return awful.rules.match(c, {class = 'scratchpad'})
--     end
--     awful.client.run_or_raise(exec, matcher)
--   end
-- })
-- }}}
-- vim: foldmethod=marker:filetype=lua:expandtab:shiftwidth=4:tabstop=4:softtabstop=4:textwidth=80
