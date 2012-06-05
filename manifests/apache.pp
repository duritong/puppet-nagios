class nagios::apache inherits ::apache {
    class{'nagios':
      httpd => 'apache'
    }

    case $::operatingsystem {
        'debian': {
            file { "${nagios::defaults::vars::int_cfgdir}/apache2.conf":
                ensure => present,
                source => ["puppet:///site_nagios/configs/${::fqdn}/apache2.conf",
                           "puppet:///site_nagios/configs/apache2.conf",
                           "puppet:///nagios/configs/apache2.conf"],
            }

            apache::config::global { "nagios3.conf":
                ensure => link,
                target => "${nagios::defaults::vars::int_cfgdir}/apache2.conf",
                require => File["${nagios::defaults::vars::int_cfgdir}/apache2.conf"],
            }
        }
    }
}
