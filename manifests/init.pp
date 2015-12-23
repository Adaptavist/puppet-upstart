define upstart($app_username,
              $launch_cmd,
              $start_on = false,
              $env = {},
              $template = "$module_name/exec.conf.erb",
              $chdir = false
    ) {
    # Sadly upstart support is missing for now from RedHat within Puppet: http://projects.puppetlabs.com/issues/11989
    case $::osfamily {
        Debian: {
            service { $name:
                    ensure   => 'running',
                    provider => 'upstart',
                    require  => File["/etc/init/${name}.conf"],
            }
        }
        RedHat: {
            service { $name:
                    ensure     => 'running',
                    hasstatus  => true,
                    hasrestart => true,
                    start      => "/sbin/initctl start ${name}",
                    stop       => "/sbin/initctl stop ${name}",
                    status     => "/sbin/initctl status ${name} | grep '/running' 1>/dev/null 2>&1",
                    require    => File["/etc/init/${name}.conf"],
                    provider   => 'base',
            }
        }
    }
    
    file { "/etc/init/${name}.conf":
        content => template($template),
        ensure => 'present',
    }

    # This is required to restart the service after the config file changes.
    # Only needed because of the lack of redhat support for upstart
    exec { "restart-$name":
        require => File["/etc/init/$name.conf"],
        subscribe  => File["/etc/init/$name.conf"],
        command => "/sbin/stop $name; /sbin/start $name",
        refreshonly => true
    }
}
