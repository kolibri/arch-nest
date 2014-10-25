define ko::dotfile(
    $install_dir = "/home/vagrant/dotfiles",
    $git_repo,
    $git_branch,
    $install_script = "bootstrap.sh",
    $install_script_param = "",
) {
    exec { 'get_dotfiles_repository':
        command => "git clone ${git_repo} -b ${git_branch} ${install_dir}",
        path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
        creates => "${install_dir}/${install_script}",
        require => [Package['git'], Package['rsync']],
        user    => $name,
        group   => $name,
    }->
    exec { 'install_dotfiles':
        command     => "${install_dir}/${install_script} ${install_script_param}",
        path        => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
        cwd         => "${install_dir}/",
        user        => $name,
        group       => $name,
        environment => ["HOME=/home/${name}/"],
    }
}
