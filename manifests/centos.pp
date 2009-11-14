class nagios::centos inherits nagios::base {
    package { [ 'nagios-plugins', 'nagios-plugins-smtp','nagios-plugins-http', 'nagios-plugins-ssh', 'nagios-plugins-udp', 'nagios-plugins-tcp', 'nagios-plugins-dig', 'nagios-plugins-nrpe', 'nagios-plugins-load', 'nagios-plugins-dns', 'nagios-plugins-ping', 'nagios-plugins-procs', 'nagios-plugins-users', 'nagios-plugins-ldap', 'nagios-plugins-disk', 'nagios-plugins-swap', 'nagios-plugins-nagios', 'nagios-plugins-perl', 'nagios-plugins-ntp', 'nagios-plugins-snmp' ]:
        ensure => 'present',
        notify => Service[nagios],
    }

    Service[nagios]{
        hasstatus => true,
    }

    # default cmd file from rpm
    # don't forget it to add to the puppet paths
    file { nagios_commands_cfg:
        path => "/etc/nagios/commands.cfg",
        source => [ "puppet://$server/modules/site-nagios/configs/${fqdn}/commands.cfg",
                    "puppet://$server/modules/site-nagios/configs/${operatingsystem}/commands.cfg",
                    "puppet://$server/modules/nagios/configs/${operatingsystem}/commands.cfg" ],
        owner => 'root',
        group => 0,
        mode => '0644',
        notify => Service[nagios],
    }
    # default file from rpm
    file { nagios_localhost_cfg:
        path => "/etc/nagios/localhost.cfg",
        source => [ "puppet://$server/modules/site-nagios/configs/${fqdn}/localhost.cfg",
                    "puppet://$server/modules/site-nagios/configs/${operatingsystem}/localhost.cfg",
                    "puppet://$server/modules/nagios/configs/${operatingsystem}/localhost.cfg" ],
        owner => 'root',
        group => 0,
        mode => '0644',
        notify => Service[nagios],
    }
    file{"/etc/nagios/private":
        source => "puppet://$server/modules/common/empty",
        ensure => directory,
        purge => true,
        recurse => true,
        notify => Service[nagios],
        mode => '0750', owner => root, group => nagios;
    }
    file{"/etc/nagios/private/resource.cfg":
        source => "puppet://$server/modules/nagios/configs/${operatingsystem}/private/resource.cfg.${architecture}",
        notify => Service[nagios],
        owner => root, group => nagios, mode => '0640';
    }
}
