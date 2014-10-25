class x11(
    $keyboard_layout = 'en'
) {
    package { ["xorg-server", "xorg-xinit", "xorg-utils", "xorg-server-utils" ]:
        ensure => installed,
    }

    file { '/etc/X11/xorg.conf.d/00-keyboard.conf':
        ensure => file,
        content => template("arch/00-keyboard.conf.erb"),
    }
}
