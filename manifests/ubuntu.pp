class nagios::ubuntu inherits nagios::base {

    Exec { path =>  ['/usr/local/sbin', '/usr/local/bin', '/usr/sbin', '/usr/bin', '/sbin', '/bin', ] }

    file { '/etc/dpkg/nagios3-cgi.debconf':
        ensure  => present,
        content => template('nagios/debconf/nagios3-cgi.debconf.erb')
    }

    Package['nagios'] { name => 'nagios3' }

    package { [ 'nagios-plugins', 'nagios-snmp-plugins', 'nagios-nrpe-plugin' ]:
        ensure => 'present',
        notify => Service['nagios'],
    }

    Service['nagios'] {
        name => 'nagios3',
        hasstatus => true,
    }

    File['nagios_htpasswd', 'nagios_cgi_cfg'] { group => 'www-data' }

    file { 'nagios_commands_cfg':
            path   => "${nagios::defaults::vars::int_cfgdir}/commands.cfg",
            ensure => present,
            notify => Service['nagios'],
            mode   => 0644, owner => root, group => root;
    }

    file { "${nagios::defaults::vars::int_cfgdir}/stylesheets":
        ensure => directory,
        purge => false,
        recurse => true,
    }

    if $nagios::allow_external_cmd {
        exec { 'nagios_external_cmd_perms_overrides':
            command => 'dpkg-statoverride --update --add nagios www-data 2710 /var/lib/nagios3/rw && dpkg-statoverride --update --add nagios nagios 751 /var/lib/nagios3',
            unless => 'dpkg-statoverride --list nagios www-data 2710 /var/lib/nagios3/rw && dpkg-statoverride --list nagios nagios 751 /var/lib/nagios3',
            logoutput => false,
            notify => Service['nagios'],
        }
        exec { 'nagios_external_cmd_perms_1':
            command => 'chmod 0751 /var/lib/nagios3 && chown nagios:nagios /var/lib/nagios3',
            unless => 'test "`stat -c "%a %U %G" /var/lib/nagios3`" = "751 nagios nagios"',
            notify => Service['nagios'],
        }
        exec { 'nagios_external_cmd_perms_2':
            command => 'chmod 2751 /var/lib/nagios3/rw && chown nagios:www-data /var/lib/nagios3/rw',
            unless => 'test "`stat -c "%a %U %G" /var/lib/nagios3/rw`" = "2751 nagios www-data"',
            notify => Service['nagios'],
        }
    }
}
