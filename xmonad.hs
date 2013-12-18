-- system-config-printer is the dialog to configure the printers
--
import XMonad
-- for layout combinators, replace previous line by:
--import XMonad hiding ( (|||) )
import XMonad.Config.Azerty
import XMonad.Layout.SimpleDecoration

import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import Graphics.X11.ExtraTypes.XF86
import System.IO
import XMonad.Config.Gnome

-- One window in multiple workspaces
import XMonad.Actions.CopyWindow

-- To bring pointer to focused window with a key press or in log hook
import XMonad.Actions.UpdatePointer

-- For navigation Workspaces
import XMonad.Actions.CycleWS

-- For named scratchpads
import XMonad.StackSet as W
import XMonad.ManageHook
import XMonad.Util.NamedScratchpad

-- smart placement of float windows
import XMonad.Hooks.Place

-- to remove border in full screen
import XMonad.Actions.NoBorders
 

-- for azerty config 
import qualified Data.Map as M

import XMonad.Layout.Tabbed

import XMonad.Util.EZConfig
import XMonad.Prompt
import XMonad.Prompt.Ssh
import XMonad.Hooks.InsertPosition

import XMonad.Actions.UpdatePointer
-- For exit
import System.Exit

-- Scratchpads
scratchpads = [
 -- run htop in xterm, find it by title, use default floating window placement
     NS "htop" "xterm -e htop" (title =? "htop") (customFloating $ W.RationalRect (1/6) (1/6) (1/3) (1/3)) ,
 -- run gvim, find by role, don't float
     NS "notes" "gvim --role notes ~/notes.txt" (role =? "notes") defaultFloating
 --    ,NS "bbbff" "firefox --role bbbff --no-remote -P BigBentoBox" (role =? "bbbff") nonFloating
 ] where role = stringProperty "WM_WINDOW_ROLE"



--main = xmonad azertyConfig

-- myL = simpleDeco shrinkText defaultTheme (layoutHook defaultConfig)
-- myL = simpleTabbed
myManageHook = composeAll
    [ (className =? "Gimp" <&&> resource =? "Dialog")    --> doFloat
-- try for namedscratchpad placement
--,scratchpadManageHook (W.RationalRect 0.325 0.6 0.641 0.35)
    , className =? "Vncviewer" --> doFloat
    , className =? "Display" --> doFloat
    , className =? "Xmessage"  --> doFloat
    , (className =? "Firefox" <&&> resource =? "Dialog") --> doFloat
    , (className =? "Thunderbird" <&&> resource =? "Dialog") --> doFloat
    , (className =? "Terminator" <&&> resource =? "Dialog") --> doFloat
    , className =? "Firefox" --> doShift "web"

    ]
--myConfig = gnomeConfig  azertyConfig
main = do 
    xmproc <- spawnPipe "/usr/bin/xmobar"
    xmonad $ gnomeConfig { 
         -- change the terminal emulator used:
         terminal = "terminator",
        
         -- azerty config
         keys = \c -> azertyKeys c `M.union` keys gnomeConfig c,
         -- placeHook simpleSmart for smart placmeent of float windows
		 -- remove 
		 --   insertPosition Below Newer <+>
		 -- to avoid the trouble that closing a newly opened window don't send you back to the previously focused window
         manageHook = placeHook simpleSmart <+> namedScratchpadManageHook scratchpads <+>manageDocks <+> myManageHook <+> manageHook azertyConfig,
         layoutHook =  avoidStruts $ simpleTabbed |||  layoutHook azertyConfig
        , logHook = dynamicLogWithPP $ xmobarPP
                        { ppOutput = hPutStrLn xmproc
                        , ppTitle = xmobarColor "green" "" . wrap "<" ">"
                        } 
         , XMonad.workspaces  = ["1:term","2:web","3", "4", "5", "6"]
         , modMask = mod4Mask
        } `additionalKeys`
        [((controlMask, xK_Print), spawn "sleep 0.2; scrot -s -e 'mv $f ~/Pictures/screenshots/ &&  display ~/Pictures/screenshots/$f'")
        , ((mod4Mask, xK_Print), spawn "scrot -e 'mv $f ~/Pictures/screenshots/ && display ~/Pictures/screenshots/$f'")

        ]
        `additionalKeysP` -- thx to EZConfig
        [ 
-- Normal Shortcuts start with M-w
-- BigBentoBox shortcuts start with M-b
          ("M-a f", spawn "/usr/bin/firefox") 
          ,("M-a l", spawn "xscreensaver-command --lock")
          ,("M-a t", spawn "/usr/bin/terminator")
          ,("M-a m", spawn "/usr/bin/thunderbird")
          ,("<F3>", spawn "exe=`dmenu_path | dmenu -b` && eval \"exec $exe\"")
          ,("M-p",  spawn "exe=`dmenu_path | ~/.cabal/bin/yeganesh` && eval \"exec $exe\"")
          ,("M-c", kill)
          ,("M-< c", spawn "zenity --question 'halt?' && gksudo -- /sbin/shutdown -h now ") 
          ,("M-< x", spawn "gdmflexiserver") 
          --,("M-n", namedScratchpadAction scratchpads "notes") 
          --,("M-t", namedScratchpadAction scratchpads "htop") 
          ,("M-v", spawn "xte 'mouseclick 3'"  )
          ,("M-S-q", io (exitWith ExitSuccess))
          -- toggle space reservation for xmobar. Usefull for vlc full screen
          ,("M-f", do 
                   sendMessage ToggleStruts  
                  -- withFocused toggleBorder
           )
          -- toggle border of active window
          ,("M-S-b", withFocused toggleBorder)
          -- Go to previous active workspace (1 level, ie loop)
          ,("M-z", toggleWS)
          -- Bring pointero center of current window
          ,("M-m", updatePointer (Relative 0.5 0.5))
          -- Swap screen contents, focus stays on active screen
          ,("M-s", swapNextScreen)
          -- Move window to next screen, focus does not follow
          ,("M-S-s", shiftNextScreen)
          -- Move focus to next Screen
          ,("M-n", nextScreen)
          -- Cycle through non visible workspaces
          ,("M-g",  moveTo Next HiddenNonEmptyWS)
          -- Focus next screen (from CycleWS)
          ,("M-e",  nextScreen)
          -- Screenshot
          ,("<F12>", spawn "gnome-screenshot")
          ,("<F11>", spawn "gnome-screenshot -a")
          -- Sound 
          ,("<XF86AudioRaiseVolume>", spawn "amixer -c 0 set Master 5dB+ &&  notify-send -a Volume Volume `amixer get Master | egrep -o \"[0-9]+%\" | uniq`")
          ,("<XF86AudioLowerVolume>", spawn "amixer -c 0 set Master 5dB- && notify-send -a Volume Volume `amixer get Master | egrep -o \"[0-9]+%\" | uniq`")
          ,("<XF86AudioMute>", spawn "amixer -q sset Master toggle && notify-send -a Volume Volume`amixer get Master | egrep -o '(\\[on\\]|\\[off\\])' | uniq`")
          -- Eject Button
          ,("<XF86Eject>", spawn "eject&&notify-send Ejecting")

          ] 
