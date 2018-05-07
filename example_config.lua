local wm = require('wm')
local layout = require('wm.layout')
local utils = require('wm.utils')

local direction   = utils.direction
local orientation = utils.orientation

function c() return wm.controller end
function l() return wm.controller.screenLayout end
function w() return wm.controller.screenLayout:selectedWorkspace() end

hs.hotkey.bind({'alt'}, 'left', function() w():focus(direction.left) end)
hs.hotkey.bind({'alt'}, 'down', function() w():focus(direction.down) end)
hs.hotkey.bind({'alt'}, 'up', function() w():focus(direction.up) end)
hs.hotkey.bind({'alt'}, 'right', function() w():focus(direction.right) end)

hs.hotkey.bind({'alt'}, 'a', function() w():selectParent() end)
hs.hotkey.bind({'alt'}, 'd', function() w():selectChild() end)
hs.hotkey.bind({'alt', 'shift'}, 'f', function() w():showFocus() end)
hs.hotkey.bind({'alt', 'shift'}, 'q', function() w():closeSelected() end)

hs.hotkey.bind({'alt', 'shift'}, 'left', function() w():move(direction.left) end)
hs.hotkey.bind({'alt', 'shift'}, 'down', function() w():move(direction.down) end)
hs.hotkey.bind({'alt', 'shift'}, 'up', function() w():move(direction.up) end)
hs.hotkey.bind({'alt', 'shift'}, 'right', function() w():move(direction.right) end)

hs.hotkey.bind({'alt', 'cmd'}, 'left', function() w():resize(direction.left, 0.1) end)
hs.hotkey.bind({'alt', 'cmd'}, 'down', function() w():resize(direction.down, 0.1) end)
hs.hotkey.bind({'alt', 'cmd'}, 'up', function() w():resize(direction.up, 0.1) end)
hs.hotkey.bind({'alt', 'cmd'}, 'right', function() w():resize(direction.right, 0.1) end)
hs.hotkey.bind({'alt', 'ctrl'}, 'left', function() w():resize(direction.left, -0.1) end)
hs.hotkey.bind({'alt', 'ctrl'}, 'down', function() w():resize(direction.down, -0.1) end)
hs.hotkey.bind({'alt', 'ctrl'}, 'up', function() w():resize(direction.up, -0.1) end)
hs.hotkey.bind({'alt', 'ctrl'}, 'right', function() w():resize(direction.right, -0.1) end)

hs.hotkey.bind({'alt'}, 's', function() w():setMode(layout.mode.stacked) end)
hs.hotkey.bind({'alt'}, 'w', function() w():setMode(layout.mode.tabbed) end)
hs.hotkey.bind({'alt'}, 'e', function() w():setMode(layout.mode.default) end)

hs.hotkey.bind({'alt'}, 'x', function() l():addWindow(hs.window.focusedWindow()) end)
hs.hotkey.bind({'alt', 'cmd'}, 'x', function() l():removeWindow(hs.window.focusedWindow()) end)
hs.hotkey.bind({'alt', 'shift'}, 'space', function() w():toggleFloating() end)
--hs.hotkey.bind({'alt'}, 'space', function() w():toggleFocusMode() end)

hs.hotkey.bind({'alt'}, 'f', function() w():toggleFullscreen() end)

hs.hotkey.bind({'alt'}, 'v', function() w():splitCurrent(orientation.vertical) end)
hs.hotkey.bind({'alt'}, 'h', function() w():splitCurrent(orientation.horizontal) end)

hs.hotkey.bind({"alt", "shift"}, "1", function() c():moveWindowToSpace(1) end)
hs.hotkey.bind({"alt", "shift"}, "2", function() c():moveWindowToSpace(2) end)
hs.hotkey.bind({"alt", "shift"}, "3", function() c():moveWindowToSpace(3) end)
hs.hotkey.bind({"alt", "shift"}, "4", function() c():moveWindowToSpace(4) end)
hs.hotkey.bind({"alt", "shift"}, "5", function() c():moveWindowToSpace(5) end)
hs.hotkey.bind({"alt", "shift"}, "6", function() c():moveWindowToSpace(6) end)
hs.hotkey.bind({"alt", "shift"}, "7", function() c():moveWindowToSpace(7) end)
hs.hotkey.bind({"alt", "shift"}, "8", function() c():moveWindowToSpace(8) end)
hs.hotkey.bind({"alt", "shift"}, "9", function() c():moveWindowToSpace(9) end)
hs.hotkey.bind({"alt", "shift"}, "0", function() c():moveWindowToSpace(10) end)

hs.hotkey.bind({"alt"}, "1", function() c():switchToSpace(1) end)
hs.hotkey.bind({"alt"}, "2", function() c():switchToSpace(2) end)
hs.hotkey.bind({"alt"}, "3", function() c():switchToSpace(3) end)
hs.hotkey.bind({"alt"}, "4", function() c():switchToSpace(4) end)
hs.hotkey.bind({"alt"}, "5", function() c():switchToSpace(5) end)
hs.hotkey.bind({"alt"}, "6", function() c():switchToSpace(6) end)
hs.hotkey.bind({"alt"}, "7", function() c():switchToSpace(7) end)
hs.hotkey.bind({"alt"}, "8", function() c():switchToSpace(8) end)
hs.hotkey.bind({"alt"}, "9", function() c():switchToSpace(9) end)
hs.hotkey.bind({"alt"}, "0", function() c():switchToSpace(10) end)

hs.hotkey.bind({"alt"}, "return", function() hs.execute("~/bin/open-terminal.sh", true) end)
hs.hotkey.bind({"alt"}, "space", function() hs.execute("~/bin/open-terminal.sh", true) end)
hs.hotkey.bind({"alt"}, "n", function() hs.execute("~/bin/open-finder.sh", true) end)
hs.hotkey.bind({"alt"}, "c", function() hs.execute("~/bin/open-browser.sh", true) end)
hs.hotkey.bind({"alt"}, "z", function() hs.execute("~/bin/bitbar-plugins/chunkwm_bar.60e0s.py rename", true) end)
