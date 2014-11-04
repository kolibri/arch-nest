class thinkpad_t420s() {
    package { ["xf86-video-intel", "xf86-input-synaptics" ]:
        ensure => installed,
    }

    package {"acpid":
        ensure => installed,
    }

    service {"acpid":
        ensure =>service running,
        enable =>service true
    }

    file { '/etc/modprobe.d/modprobe.conf':
        ensure => file,
        content => template("thinkpad_t420s/modprobe.conf.erb"),
    }

    file { '/etc/thinkfan.conf':
        ensure => file,
        content => template("thinkpad_t420s/thinkfan.conf.erb"),
    }

    file { '/etc/X11/xorg.conf.d/20-thinkpad.conf':
        ensure  => file,
        content => template("thinkpad_t420s/thinkpad-trackpoint.conf.erb"),
        require => Class['x11'],
    }
}
