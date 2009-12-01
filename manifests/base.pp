class nagios::base {

    package { 'nagios':
        alias => 'nagios',
        ensure => present,   
    }

    service { 'nagios':
        ensure => running,
        enable => true,
        #hasstatus => true, #fixme!
        require => Package['nagios'],
    }

    # manage nagios cfg files
    file { 'nagios_cfg_dir':
        path => "${nagios_cfg_dir}/",
        source => "puppet://$server/modules/common/empty",
        ensure => directory,
        recurse => true,
        purge => true,
        notify => Service['nagios'],
        mode => 0755, owner => root, group => root;
    }

    # this file should contain all the nagios_puppet-paths:
    file { 'nagios_main_cfg':
            path => "${nagios_cfg_dir}/nagios.cfg",
            source => [ "puppet://$server/files/nagios/configs/${fqdn}/nagios.cfg",
                        "puppet://$server/files/nagios/configs/${operatingsystem}/nagios.cfg",
                        "puppet://$server/files/nagios/configs/nagios.cfg",
                        "puppet://$server/nagios/configs/${operatingsystem}/nagios.cfg",
                        "puppet://$server/nagios/configs/nagios.cfg" ],
            notify => Service['nagios'],
            mode => 0644, owner => root, group => root;
    }    

    file { 'nagios_cgi_cfg':
        path => "${nagios_cfg_dir}/cgi.cfg",
        source => [ "puppet://$server/files/nagios/configs/${fqdn}/cgi.cfg",
                    "puppet://$server/files/nagios/configs/${operatingsystem}/cgi.cfg",
                    "puppet://$server/files/nagios/configs/cgi.cfg",
                    "puppet://$server/nagios/configs/${operatingsystem}/cgi.cfg",
                    "puppet://$server/nagios/configs/cgi.cfg" ],
        mode => '0644', owner => 'root', group => 0,
        notify => Service['apache'],
    }

    file { 'nagios_htpasswd':
        path => "${nagios_cfg_dir}/htpasswd.users",
        source => [ "puppet://$server/files/nagios/htpasswd.users",
                    "puppet://$server/nagios/htpasswd.users" ],
        mode => 0640, owner => root, group => apache;
    }

    file { 'nagios_private':
        path => "${nagios_cfg_dir}/private/",
        source => "puppet://$server/modules/common/empty",
        ensure => directory,
        purge => true,
        recurse => true,
        notify => Service['nagios'],
        mode => '0750', owner => root, group => nagios;
    }

    file { 'nagios_private_resource_cfg':
        path => "${nagios_cfg_dir}/private/resource.cfg",
        source => "puppet://$server/nagios/configs/${operatingsystem}/private/resource.cfg.${architecture}",
        notify => Service['nagios'],
        owner => root, group => nagios, mode => '0640';
    }

    file { 'nagios_defaults':
        path => "${nagios_cfg_dir}/defaults/",
        source => "puppet://$server/modules/common/empty",
        ensure => directory,
        purge => true,
        recurse => true,
        notify => Service['nagios'],
        mode => '0755', owner => root, group => nagios;
    }

    file{[ "${nagios_cfg_dir}/nagios_command.cfg", 
           "${nagios_cfg_dir}/nagios_contact.cfg", 
           "${nagios_cfg_dir}/nagios_contactgroup.cfg",
           "${nagios_cfg_dir}/nagios_host.cfg",
           "${nagios_cfg_dir}/nagios_hostextinfo.cfg",
           "${nagios_cfg_dir}/nagios_hostgroup.cfg",
           "${nagios_cfg_dir}/nagios_hostgroupescalation.cfg",
           "${nagios_cfg_dir}/nagios_service.cfg",
           "${nagios_cfg_dir}/nagios_servicedependency.cfg",
           "${nagios_cfg_dir}/nagios_serviceescalation.cfg",
           "${nagios_cfg_dir}/nagios_serviceextinfo.cfg",
           "${nagios_cfg_dir}/nagios_timeperdiod.cfg" ]:
        ensure => file,
        replace => false,
        notify => Service['nagios'],
        mode => 0644, owner => root, group => 0;
    }

    Nagios_command <<||>>
    Nagios_contact <<||>>
    Nagios_contactgroup <<||>>
    Nagios_host <<||>>
    Nagios_hostextinfo <<||>>
    Nagios_hostgroup <<||>>
    Nagios_hostgroupescalation <<||>>
    Nagios_service <<||>>
    Nagios_servicedependency <<||>>
    Nagios_serviceescalation <<||>>
    Nagios_serviceextinfo <<||>>
    Nagios_timeperiod <<||>>

    if $use_munin {
        include munin::plugins::nagios
    }

    if $nagios_allow_external_cmd {
        file { '/var/spool/nagios/cmd':
            ensure => 'directory',
            require => Package['nagios'],
            mode => 2660, owner => apache, group => nagios,
        }
    }
}
