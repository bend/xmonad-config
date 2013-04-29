exec trayer --edge top --align right --widthtype pixel --width 150 --SetDockType true --SetPartialStrut true --transparent true --alpha 0 --tint 0x000000 --expand true --heighttype pixel --height 16 &
 
if [ -x /usr/bin/xscreensaver] ; then
    /usr/bin/xscreensaver -no-splash&
fi

#xsetroot -solid blue

if [ -x /usr/bin/feh ] ; then
    /usr/bin/feh --bg-fill ~/Photos/Wallpapers/arch-seda-zaul.jpg
fi

# Start a D-Bus session
source /etc/X11/xinit/xinitrc.d/30-dbus

# Start GNOME Keyring
eval $(/usr/bin/gnome-keyring-daemon --start --components=gpg,pkcs11,secrets,ssh)

export SSH_AUTH_SOCK
export GPG_AGENT_INFO
export GNOME_KEYRING_CONTROL
export GNOME_KEYRING_PI

if [ -x /usr/bin/nm-applet ] ; then
    nm-applet --sm-disable &
fi

if [ -x /usr/bin/pulseaudio ]; then
    /usr/bin/pulseaudio --start
fi

if [ -x /usr/bin/volumeicon ]; then
    /usr/bin/volumeicon &
fi

if [/usr/bin/volumeicon]; then
    /usr/bin/dropboxd &
fi

if [ -x /usr/bin/xfce4-power-manager ] ; then
    /usr/bin/xfce4-power-manager &
fi

exec /usr/bin/xmonad
