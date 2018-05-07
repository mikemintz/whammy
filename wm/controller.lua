local controller = {}

local fnutils         = require 'wm.fnutils'
local os              = require 'wm.os'
local screenlayout    = require 'wm.screenlayout'
local windowtracker   = require 'wm.windowtracker'
local workspacefinder = require 'wm.workspacefinder'
local _spaces = require('hs._asm.undocumented.spaces')
local screen = require('hs.screen')

function controller:new()
  local obj = {}
  setmetatable(obj, {__index = self})

  obj.windowsMovingToInvisibleSpace = {}

  -- The root of our WM tree; all commands are routed through here.
  obj.screenLayout = screenlayout:new(os.allScreens())

  -- Tracks events on windows.
  obj.windowTracker = windowtracker:new(
    {windowtracker.windowCreated, windowtracker.windowDestroyed, windowtracker.mainWindowChanged},
    function(...) obj:_handleWindowEvent(...) end)
  obj.windowTracker:start()

  -- Tracks space changes.
  obj.spaceWatcher = hs.spaces.watcher.new(function() obj:_handleSpaceChange() end)
  obj.spaceWatcher:start()

  -- Tracks screen layout changes.
  obj.screenWatcher = hs.screen.watcher.new(function(...) obj:_handleScreenLayoutChange(...) end)
  obj.screenWatcher:start()

  return obj
end

function controller:_handleWindowEvent(win, event)
  print(event.." on win "..(win and win:title() or "NIL WINDOW"))

  local  e = os.uiEvents
  if     e.windowCreated     == event then
    self.screenLayout:addWindow(win)
    self:writeWhammyDesktopsFile()
  elseif e.elementDestroyed  == event then
    self.screenLayout:removeWindow(win)
    self:writeWhammyDesktopsFile()
  elseif e.mainWindowChanged == event then
    self.screenLayout:selectWindow(win)
  end
end

function controller:trackWindowMovingToInvisibleSpace(win)
  table.insert(self.windowsMovingToInvisibleSpace, win)
end

function controller:moveWindowToSpace(sp)
  local curspaceID = _spaces.activeSpace()    -- current space id
  local win = hs.window.focusedWindow()      -- current window
  local uuid = win:screen():spacesUUID()     -- uuid for current screen
  local spaceID = _spaces.layout()[uuid][sp]  -- internal index for sp

  if spaceID ~= curspaceID then
    self:trackWindowMovingToInvisibleSpace(win)
    l():removeWindow(win) -- remove window from current whammy workspace
    _spaces.moveWindowToSpace(win:id(), spaceID) -- move window to new space
  end
end

function controller:switchToSpace(sp)
  local curspaceID = _spaces.activeSpace()    -- current space id
  local uuid = screen.mainScreen():spacesUUID()     -- uuid for current screen
  local spaceID = _spaces.layout()[uuid][sp]  -- internal index for sp
  if spaceID ~= curspaceID then
    _spaces.changeToSpace(spaceID, false) -- true to restart dock, may be more reliable
    self:writeWhammyDesktopsFile()
  end
end

function controller:writeWhammyDesktopsFile()
  local activeSpace = _spaces.activeSpace()
  local spaceIdsWithWindows = fnutils.map(l():workspaces(), function(workspace)
    local windows = workspace:allWindows()
    --TODO also include windows that got moved via trackWindowMovingToInvisibleSpace
    if #windows > 0 then
      local window = windows[1]
      local spaceId = _spaces.windowOnSpaces(window:id())[1]
      return spaceId
    end
  end)

  local scr = screen.primaryScreen()
  local screenUUID   = scr:spacesUUID()
  local screenSpaces = _spaces.layout()[screenUUID]
  if screenSpaces then
    file = io.open("/Users/mikemintz/.config/whammy-desktops.txt", "w")
    io.output(file)
    for i = 1, #screenSpaces do
      local hasWindows = fnutils.contains(spaceIdsWithWindows, screenSpaces[i])
      if hasWindows then
        local spaceIsActive = screenSpaces[i] == activeSpace
        io.write(tostring(i).." "..tostring(spaceIsActive).."\n")
      end
    end
    io.close(file)
  end
  hs.execute("open bitbar://refreshPlugin?name=chunkwm_bar.*?.py -g")
  print("writeWhammyDesktopsFile()")
end

function controller:_handleSpaceChange()
  local allVisibleWindows = os.allVisibleWindows()
  -- Get the workspace on each screen and update the screenLayout.
  local screenInfos =
    workspacefinder.find(self.screenLayout:workspaces(), os.allScreens(), allVisibleWindows)
  fnutils.each(screenInfos, function(info)
    self.screenLayout:setWorkspaceForScreen(info.screen, info.workspace)
  end)

  if #self.windowsMovingToInvisibleSpace > 0 then
    fnutils.each(allVisibleWindows, function(win)
      if fnutils.contains(self.windowsMovingToInvisibleSpace, win) then
        print("adding formerly invisible window "..(win and win:title() or "NIL WINDOW"))
        print(#self.windowsMovingToInvisibleSpace)
        self.screenLayout:addWindow(win)
        self.windowsMovingToInvisibleSpace = fnutils.filter(self.windowsMovingToInvisibleSpace, function(w)
          return w ~= win
        end)
        print(#self.windowsMovingToInvisibleSpace)
      end
    end)
    self:writeWhammyDesktopsFile()
  end

  -- Use the OS behavior to determine which screen should be focused. Default to the last focused screen.
  -- The workspace selection will be updated by a later window event.
  local focusedWindow = os.focusedWindow()
  if focusedWindow then
    self.screenLayout:selectScreen(focusedWindow:screen())
  end
end

function controller:_handleScreenLayoutChange()
  -- Prep screenLayout with the new set of screens.
  self.screenLayout:updateScreenLayout(os.allScreens())

  -- After that, handle as if it were a space change.
  self:_handleSpaceChange()
end

return controller
