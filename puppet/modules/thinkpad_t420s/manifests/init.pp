class thinkpad_t420s() {
    package { ["xf86-video-intel", "xf86-input-synaptics" ]:
        ensure => installed,
    }

    file { '/etc/modprobe.d/modprobe.conf':
        ensure => file,
        content => template("thinkpad_t420s/modprobe.conf.erb"),
    }

    file { '/etc/thinkfan.conf':
        ensure => file,
        content => template("thinkpad_t420s/thinkfan.conf.erb"),
    }
}
