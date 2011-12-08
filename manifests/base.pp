class nagios::base {
    # include the variables
    include nagios::defaults::vars

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

    # this file should contain all the nagios_puppet-paths:
    file { 'nagios_main_cfg':
            path => "${nagios::defaults::vars::int_nagios_cfgdir}/nagios.cfg",
            source => [ "puppet:///modules/site-nagios/configs/${fqdn}/nagios.cfg",
                        "puppet:///modules/site-nagios/configs/${operatingsystem}/nagios.cfg",
                        "puppet:///modules/site-nagios/configs/nagios.cfg",
                        "puppet:///modules/nagios/configs/${operatingsystem}/nagios.cfg",
                        "puppet:///modules/nagios/configs/nagios.cfg" ],
            notify => Service['nagios'],
            mode => 0644, owner => root, group => root;
    }    

    file { 'nagios_commands_cfg':
            path   => "${nagios::defaults::vars::int_nagios_cfgdir}/commands.cfg",
            ensure => present,
            notify => Service['nagios'],
            mode   => 0644, owner => root, group => root;
    }

    file { 'nagios_cgi_cfg':
        path => "${nagios::defaults::vars::int_nagios_cfgdir}/cgi.cfg",
        source => [ "puppet:///modules/site-nagios/configs/${fqdn}/cgi.cfg",
                    "puppet:///modules/site-nagios/configs/${operatingsystem}/cgi.cfg",
                    "puppet:///modules/site-nagios/configs/cgi.cfg",
                    "puppet:///modules/nagios/configs/${operatingsystem}/cgi.cfg",
                    "puppet:///modules/nagios/configs/cgi.cfg" ],
        mode => '0644', owner => 'root', group => 0,
        notify => Service['apache'],
    }

    file { 'nagios_htpasswd':
        path => "${nagios::defaults::vars::int_nagios_cfgdir}/htpasswd.users",
        source => [ "puppet:///modules/site-nagios/htpasswd.users",
                    "puppet:///modules/nagios/htpasswd.users" ],
        mode => 0640, owner => root, group => apache;
    }

    file { 'nagios_private':
        path => "${nagios::defaults::vars::int_nagios_cfgdir}/private/",
        source => "puppet:///modules/common/empty",
        ensure => directory,
        purge => true,
        recurse => true,
        notify => Service['nagios'],
        mode => '0750', owner => root, group => nagios;
    }

    file { 'nagios_private_resource_cfg':
        path => "${nagios::defaults::vars::int_nagios_cfgdir}/private/resource.cfg",
        source => [ "puppet:///modules/site-nagios/configs/${operatingsystem}/private/resource.cfg.${architecture}",
                    "puppet:///modules/nagios/configs/${operatingsystem}/private/resource.cfg.${architecture}" ],
        notify => Service['nagios'],
        owner => root, group => nagios, mode => '0640';
    }

    file { 'nagios_confd':
        path => "${nagios::defaults::vars::int_nagios_cfgdir}/conf.d/",
        source => "puppet:///modules/common/empty",
        ensure => directory,
        purge => true,
        recurse => true,
        notify => Service['nagios'],
        mode => '0750', owner => root, group => nagios;
    }
    Package <<| tag == 'nagios::plugin::deploy::package' |>>
    File <<| tag == 'nagios::plugin::deploy::file' |>>
    Nagios_command <<||>>
    Nagios_contactgroup <<||>>
    Nagios_contact <<||>>
    Nagios_hostdependency <<||>>
    Nagios_hostescalation <<||>>
    Nagios_hostextinfo <<||>>
    Nagios_hostgroup <<||>>
    Nagios_host <<||>>
    Nagios_servicedependency <<||>>
    Nagios_serviceescalation <<||>>
    Nagios_servicegroup <<||>>
    Nagios_serviceextinfo <<||>>
    Nagios_service <<||>>
    Nagios_timeperiod <<||>>
    File <<| tag == 'nagios_plugin' |>>

    Nagios_command <||> {
        target => "${nagios::defaults::vars::int_nagios_cfgdir}/conf.d/nagios_command.cfg",
        require => File['nagios_confd'],
        notify => Service['nagios'],
    }
    Nagios_contact <||> {
        target => "${nagios::defaults::vars::int_nagios_cfgdir}/conf.d/nagios_contact.cfg",
        require => File['nagios_confd'],
        notify => Service['nagios'],
    }
    Nagios_contactgroup <||> {
        target => "${nagios::defaults::vars::int_nagios_cfgdir}/conf.d/nagios_contactgroup.cfg",
        require => File['nagios_confd'],
        notify => Service['nagios'],
    }
    Nagios_host <||> {
        target => "${nagios::defaults::vars::int_nagios_cfgdir}/conf.d/nagios_host.cfg",
        require => File['nagios_confd'],
        notify => Service['nagios'],
    }
    Nagios_hostdependency <||> {
        target => "${nagios::defaults::vars::int_nagios_cfgdir}/conf.d/nagios_hostdependency.cfg",
        notify => Service['nagios'],
    }
    Nagios_hostescalation <||> {
        target => "${nagios::defaults::vars::int_nagios_cfgdir}/conf.d/nagios_hostescalation.cfg",
        notify => Service['nagios'],
    }
    Nagios_hostextinfo <||> {
        target => "${nagios::defaults::vars::int_nagios_cfgdir}/conf.d/nagios_hostextinfo.cfg",
        require => File['nagios_confd'],
        notify => Service['nagios'],
    }
    Nagios_hostgroup <||> {
        target => "${nagios::defaults::vars::int_nagios_cfgdir}/conf.d/nagios_hostgroup.cfg",
        require => File['nagios_confd'],
        notify => Service['nagios'],
    }
    Nagios_service <||> {
        target => "${nagios::defaults::vars::int_nagios_cfgdir}/conf.d/nagios_service.cfg",
        require => File['nagios_confd'],
        notify => Service['nagios'],
    }
    Nagios_servicegroup <||> {
        target => "${nagios::defaults::vars::int_nagios_cfgdir}/conf.d/nagios_servicegroup.cfg",
        notify => Service['nagios'],
    }
    Nagios_servicedependency <||> {
        target => "${nagios::defaults::vars::int_nagios_cfgdir}/conf.d/nagios_servicedependency.cfg",
        require => File['nagios_confd'],
        notify => Service['nagios'],
    }
    Nagios_serviceescalation <||> {
        target => "${nagios::defaults::vars::int_nagios_cfgdir}/conf.d/nagios_serviceescalation.cfg",
        require => File['nagios_confd'],
        notify => Service['nagios'],
    }
    Nagios_serviceextinfo <||> {
        target => "${nagios::defaults::vars::int_nagios_cfgdir}/conf.d/nagios_serviceextinfo.cfg",
        require => File['nagios_confd'],
        notify => Service['nagios'],
    }
    Nagios_timeperiod <||> {
        target => "${nagios::defaults::vars::int_nagios_cfgdir}/conf.d/nagios_timeperiod.cfg",
        require => File['nagios_confd'],
        notify => Service['nagios'],
    }

    file{[ "${nagios::defaults::vars::int_nagios_cfgdir}/conf.d/nagios_command.cfg", 
           "${nagios::defaults::vars::int_nagios_cfgdir}/conf.d/nagios_contact.cfg", 
           "${nagios::defaults::vars::int_nagios_cfgdir}/conf.d/nagios_contactgroup.cfg",
           "${nagios::defaults::vars::int_nagios_cfgdir}/conf.d/nagios_host.cfg",
           "${nagios::defaults::vars::int_nagios_cfgdir}/conf.d/nagios_hostdependency.cfg",
           "${nagios::defaults::vars::int_nagios_cfgdir}/conf.d/nagios_hostescalation.cfg",
           "${nagios::defaults::vars::int_nagios_cfgdir}/conf.d/nagios_hostextinfo.cfg",
           "${nagios::defaults::vars::int_nagios_cfgdir}/conf.d/nagios_hostgroup.cfg",
           "${nagios::defaults::vars::int_nagios_cfgdir}/conf.d/nagios_hostgroupescalation.cfg",
           "${nagios::defaults::vars::int_nagios_cfgdir}/conf.d/nagios_service.cfg",
           "${nagios::defaults::vars::int_nagios_cfgdir}/conf.d/nagios_servicedependency.cfg",
           "${nagios::defaults::vars::int_nagios_cfgdir}/conf.d/nagios_serviceescalation.cfg",
           "${nagios::defaults::vars::int_nagios_cfgdir}/conf.d/nagios_serviceextinfo.cfg",
           "${nagios::defaults::vars::int_nagios_cfgdir}/conf.d/nagios_servicegroup.cfg",
           "${nagios::defaults::vars::int_nagios_cfgdir}/conf.d/nagios_timeperiod.cfg" ]:
        ensure => file,
        replace => false,
        notify => Service['nagios'],
        mode => 0644, owner => root, group => 0;
    }

    # manage nagios cfg files
    # must be defined after exported resource overrides and cfg file defs
    file { 'nagios_cfgdir':
        path => "${nagios::defaults::vars::int_nagios_cfgdir}/",
        source => "puppet:///modules/common/empty",
        ensure => directory,
        recurse => true,
        purge => true,
        notify => Service['nagios'],
        mode => 0755, owner => root, group => root;
    }

    if $use_munin {
        include nagios::munin
    }

}
